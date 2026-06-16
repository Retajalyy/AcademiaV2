import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Enums ─────────────────────────────────────────────────────────────────────

enum CameraPermissionState { checking, granted, denied }

// ── Location model ────────────────────────────────────────────────────────────

class NavLocation {
  final String id;
  final String room;
  final String floor;
  final String building;

  const NavLocation({
    required this.id,
    required this.room,
    required this.floor,
    required this.building,
  });

  String get display => '$room – $floor, $building';

  factory NavLocation.fromMap(Map<String, dynamic> m) => NavLocation(
        id:       m['id']       as String,
        room:     m['room']     as String,
        floor:    m['floor']    as String,
        building: m['building'] as String,
      );
}

// ── Controller ────────────────────────────────────────────────────────────────

class NavigationController extends GetxController {
  final _db = Supabase.instance.client;

  final locations           = <NavLocation>[].obs;
  final isLoadingLocations  = true.obs;
  final selectedDestination = Rxn<NavLocation>();
  final currentLocation     = Rxn<NavLocation>();
  final scannerController   = MobileScannerController();
  final isScanning          = true.obs;

  // Camera permission state
  final cameraPermission = CameraPermissionState.checking.obs;

  // Route state
  final routeSteps     = <String>[].obs;
  final isLoadingRoute = false.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchLocations();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    // Let MobileScanner handle permission natively — just mark as granted
    // so the scanner widget is shown and iOS triggers its own permission dialog
    cameraPermission.value = CameraPermissionState.granted;
  }

  Future<void> requestCameraPermission() async {
    await openAppSettings();
  }

  Future<void> _fetchLocations() async {
    isLoadingLocations.value = true;
    try {
      final data = await _db
          .from('navigation_locations')
          .select('id, room, floor, building')
          .order('building')
          .order('floor')
          .order('room');
      locations.value =
          (data as List).map((m) => NavLocation.fromMap(m)).toList();
    } catch (_) {
      locations.value = [];
    } finally {
      isLoadingLocations.value = false;
    }
  }

  void onQrDetected(BarcodeCapture capture) {
    if (!isScanning.value) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;

    final match = locations.firstWhereOrNull(
      (l) => l.id == raw.trim().toUpperCase() ||
             l.room.toLowerCase() == raw.trim().toLowerCase(),
    );

    if (match != null) {
      currentLocation.value = match;
    } else {
      // Try extracting the last path segment in case the QR is a URL
      // e.g. "https://example.com/B1" → "B1"
      final extracted = raw.trim().split(RegExp(r'[/\\\s]')).last.toUpperCase();
      final matchByExtract = locations.firstWhereOrNull(
        (l) => l.id == extracted ||
               l.room.toLowerCase() == extracted.toLowerCase(),
      );

      if (matchByExtract != null) {
        currentLocation.value = matchByExtract;
      } else {
        // Show raw value so user knows what was scanned
        Get.snackbar(
          'QR Scanned',
          'Value: "${raw.trim()}" — not found in locations. '
          'Make sure your QR encodes exactly the location ID (e.g. B1)',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1A2E45),
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
        currentLocation.value = NavLocation(
          id: raw.trim().toUpperCase(),
          room: 'Scanned: ${raw.trim()}',
          floor: 'Not in database',
          building: 'Check QR code value',
        );
      }
    }
    isScanning.value = false;
    scannerController.stop();
    // Auto-fetch route if destination already chosen
    _tryFetchRoute();
  }

  void onDestinationChanged(NavLocation? val) {
    selectedDestination.value = val;
    routeSteps.value = [];
    // Auto-fetch route if location already scanned
    _tryFetchRoute();
  }

  void _tryFetchRoute() {
    final from = currentLocation.value;
    final to   = selectedDestination.value;
    if (from != null && to != null) fetchRoute(from.id, to.id);
  }

  Future<void> fetchRoute(String fromId, String toId) async {
    isLoadingRoute.value = true;
    routeSteps.value = [];
    try {
      final data = await _db
          .from('navigation_routes')
          .select('step_number, instruction')
          .eq('from_id', fromId)
          .eq('to_id', toId)
          .order('step_number', ascending: true);
      routeSteps.value = (data as List)
          .map((r) => r['instruction'] as String)
          .toList();
      if (routeSteps.isEmpty) {
        Get.snackbar('No Route', 'No directions found for this route',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF1A2E45),
            colorText: Colors.white);
      }
    } catch (_) {
      Get.snackbar('No Route', 'No directions found for this route',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1A2E45),
          colorText: Colors.white);
    } finally {
      isLoadingRoute.value = false;
    }
  }

  void resetScan() {
    currentLocation.value = null;
    isScanning.value = true;
    routeSteps.value = [];
    scannerController.start();
  }

  @override
  void onClose() {
    scannerController.dispose();
    super.onClose();
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────

class NavigationScreen extends StatelessWidget {
  const NavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(NavigationController());

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Destination picker ─────────────────────────────────
                    _SectionLabel('WHERE DO YOU WANT TO GO?'),
                    const SizedBox(height: 10),
                    _DestinationDropdown(c: c),
                    const SizedBox(height: 28),

                    // ── Step label ─────────────────────────────────────────
                    _StepBadge(label: 'STEP 1 OF 2'),
                    const SizedBox(height: 14),

                    const Text(
                      'Where are you right now?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Scan any QR code posted on the wall near you to pinpoint your location.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Current location card ──────────────────────────────
                    Obx(() {
                      final loc = c.currentLocation.value;
                      if (loc == null) return const SizedBox.shrink();
                      return _LocationCard(location: loc, onReset: c.resetScan);
                    }),

                    const SizedBox(height: 20),

                    // ── QR Scanner ─────────────────────────────────────────
                    Obx(() {
                      if (c.cameraPermission.value ==
                          CameraPermissionState.checking) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(
                                color: Color(0xFF5B9BD5)),
                          ),
                        );
                      }
                      if (c.cameraPermission.value ==
                          CameraPermissionState.denied) {
                        return _CameraPermissionBox(c: c);
                      }
                      return c.isScanning.value
                          ? _QrScannerBox(c: c)
                          : _ScanDoneBox(onReScan: c.resetScan);
                    }),

                    const SizedBox(height: 28),

                    // ── Route loading / instructions ───────────────────────
                    Obx(() {
                      if (c.isLoadingRoute.value) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: CircularProgressIndicator(
                                color: Color(0xFFF5A623)),
                          ),
                        );
                      }
                      if (c.routeSteps.isNotEmpty) {
                        return _RouteInstructions(
                          steps: c.routeSteps.toList(),
                          from:  c.currentLocation.value!,
                          to:    c.selectedDestination.value!,
                          onReScan: c.resetScan,
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Top Bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20),
            onPressed: Get.back,
          ),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Navigate',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Scan to set your start point',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.5),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
      ),
    );
  }
}

// ── Step Badge ────────────────────────────────────────────────────────────────

class _StepBadge extends StatelessWidget {
  final String label;
  const _StepBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFFF5A623),
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

// ── Destination Dropdown ──────────────────────────────────────────────────────

class _DestinationDropdown extends StatelessWidget {
  final NavigationController c;
  const _DestinationDropdown({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.isLoadingLocations.value) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2E45),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF2A4A6B), width: 1),
          ),
          child: const Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Color(0xFF5B9BD5)),
              ),
              SizedBox(width: 12),
              Text('Loading locations…',
                  style: TextStyle(color: Color(0xFF5B9BD5), fontSize: 14)),
            ],
          ),
        );
      }
      return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2E45),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF2A4A6B), width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<NavLocation>(
              value: c.selectedDestination.value,
              isExpanded: true,
              dropdownColor: const Color(0xFF1A2E45),
              hint: Text(
                'Select your destination',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 14,
                ),
              ),
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF5B9BD5)),
              items: c.locations
                  .map((loc) => DropdownMenuItem(
                        value: loc,
                        child: Text(
                          loc.display,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                  .toList(),
              onChanged: c.onDestinationChanged,
            ),
          ));
    });
  }
}

// ── Location Card ─────────────────────────────────────────────────────────────

class _LocationCard extends StatelessWidget {
  final NavLocation location;
  final VoidCallback onReset;
  const _LocationCard({required this.location, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2E45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF5A623).withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF5A623).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.location_on_rounded,
                color: Color(0xFFF5A623), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.room,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${location.floor} . ${location.building}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onReset,
            child: const Icon(Icons.refresh_rounded,
                color: Color(0xFF5B9BD5), size: 20),
          ),
        ],
      ),
    );
  }
}

// ── Camera Permission Box ─────────────────────────────────────────────────────

class _CameraPermissionBox extends StatelessWidget {
  final NavigationController c;
  const _CameraPermissionBox({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2E45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A4A6B)),
      ),
      child: Column(
        children: [
          const Icon(Icons.camera_alt_outlined,
              color: Color(0xFF5B9BD5), size: 44),
          const SizedBox(height: 14),
          const Text(
            'Camera Access Required',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Allow camera access to scan QR codes and detect your location.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 13,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: c.requestCameraPermission,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF5A623),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Grant Camera Permission',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dashed Border Painter ─────────────────────────────────────────────────────

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFC258).withValues(alpha: 0.55)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 6.0;
    const dashSpace = 5.0;
    const radius = Radius.circular(20);

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0.75, 0.75, size.width - 1.5, size.height - 1.5),
        radius,
      ));

    for (final metric in path.computeMetrics()) {
      double start = 0;
      while (start < metric.length) {
        canvas.drawPath(metric.extractPath(start, start + dashWidth), paint);
        start += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── QR Scanner Box ────────────────────────────────────────────────────────────

class _QrScannerBox extends StatelessWidget {
  final NavigationController c;
  const _QrScannerBox({required this.c});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _DashedBorderPainter(),
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          color: const Color(0xFF1A2E45),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Container(
                      color: Colors.white,
                      child: MobileScanner(
                        controller: c.scannerController,
                        onDetect: c.onQrDetected,
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xFFF5A623), width: 2.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Point your camera at a QR code on the wall',
              style: TextStyle(color: Colors.white, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Scan Done Box ─────────────────────────────────────────────────────────────

class _ScanDoneBox extends StatelessWidget {
  final VoidCallback onReScan;
  const _ScanDoneBox({required this.onReScan});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF1A2E45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A4A6B)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Color(0xFF4CAF50), size: 36),
            const SizedBox(height: 8),
            const Text(
              'Location detected!',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: onReScan,
              child: const Text(
                'Tap to scan again',
                style: TextStyle(color: Color(0xFF5B9BD5), fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Route Instructions ────────────────────────────────────────────────────────

class _RouteInstructions extends StatelessWidget {
  final List<String> steps;
  final NavLocation from;
  final NavLocation to;
  final VoidCallback onReScan;

  const _RouteInstructions({
    required this.steps,
    required this.from,
    required this.to,
    required this.onReScan,
  });

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepBadge(label: 'STEP 2 OF 2'),
        const SizedBox(height: 14),

        const Text(
          'Your Directions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),

        // From → To summary card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2E45),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF2A4A6B)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('From',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 11)),
                    const SizedBox(height: 2),
                    Text(from.room,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded,
                  color: Color(0xFFF5A623), size: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('To',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 11)),
                    const SizedBox(height: 2),
                    Text(to.room,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                        textAlign: TextAlign.end),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Steps list
        ...steps.asMap().entries.map((entry) {
          final stepNum = entry.key + 1;
          final text    = entry.value;
          final isLast  = stepNum == steps.length;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step number + connector line
              Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5A623),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$stepNum',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 36,
                      color: const Color(0xFF2A4A6B),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 20),
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),

        const SizedBox(height: 8),

        // Re-scan button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onReScan,
            icon: const Icon(Icons.qr_code_scanner,
                color: Color(0xFF5B9BD5), size: 18),
            label: const Text('Scan a different location',
                style: TextStyle(color: Color(0xFF5B9BD5))),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF2A4A6B)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }
}
