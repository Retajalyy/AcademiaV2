import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:academia/Core/utilities/colors.dart';
import 'package:academia/Features/Home/models/schedule_item_model.dart';
import 'package:academia/Features/schedule/controllers/schedule_controller.dart';
import 'package:academia/Core/widgets/notification_bell.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ScheduleController());

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: Column(
        children: [
          _Header(c: c),
          Expanded(
            child: Obx(() {
              if (c.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.secondaryYellow),
                );
              }
              if (c.errorMessage.value != null) {
                return _ErrorState(
                  message: c.errorMessage.value!,
                  onRetry: () => c.loadScheduleForDay(c.selectedDayIndex.value),
                );
              }
              if (c.classes.isEmpty) {
                return const _EmptyState();
              }
              return RefreshIndicator(
                onRefresh: () => c.loadScheduleForDay(c.selectedDayIndex.value),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (c.upcomingClass != null) ...[
                        _SectionLabel(label: 'UPCOMING'),
                        const SizedBox(height: 12),
                        _UpcomingCard(item: c.upcomingClass!, c: c),
                        const SizedBox(height: 20),
                      ],
                      if (c.laterClasses.isNotEmpty) ...[
                        _SectionLabel(label: c.isToday ? 'LATER TODAY' : 'SCHEDULE'),
                        const SizedBox(height: 12),
                        ...c.laterClasses.map((item) => _LaterCard(item: item)),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final ScheduleController c;
  const _Header({required this.c});

  static const _tabs = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryBlue,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: back + title + bell
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Schedule',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const NotificationBell(),
                ],
              ),
            ),

            // Group info
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Obx(() => Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.secondaryYellow, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            c.groupLabel.value.isNotEmpty
                                ? c.groupLabel.value
                                    .substring(0, c.groupLabel.value.length.clamp(0, 3))
                                : 'G',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Group ${c.groupLabel.value}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (c.groupDept.value.isNotEmpty)
                            Text(
                              '${c.groupDept.value}${c.groupLevel.value.isNotEmpty ? ' · Level ${c.groupLevel.value}' : ''}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.65),
                                fontSize: 13,
                              ),
                            ),
                        ],
                      ),
                    ],
                  )),
            ),

            // Day tabs
            Obx(() => Row(
                  children: List.generate(7, (i) {
                    final selected = c.selectedDayIndex.value == i;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => c.loadScheduleForDay(i),
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                _tabs[i],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: selected
                                      ? AppColors.secondaryYellow
                                      : Colors.white.withValues(alpha: 0.5),
                                  fontWeight: selected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Container(
                              height: 2,
                              color: selected
                                  ? AppColors.secondaryYellow
                                  : Colors.transparent,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                )),
          ],
        ),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Container(height: 1, color: Colors.grey.shade300)),
      ],
    );
  }
}

// ── Upcoming card ─────────────────────────────────────────────────────────────

class _UpcomingCard extends StatelessWidget {
  final ScheduleItem item;
  final ScheduleController c;
  const _UpcomingCard({required this.item, required this.c});

  @override
  Widget build(BuildContext context) {
    final parts     = item.time.split(' - ');
    final startTime = parts[0].trim();
    final endTime   = parts.length > 1 ? parts[1].trim() : '';
    final mins      = c.minutesUntilClass(item);
    final timeLabel = mins > 0
        ? '$startTime – $endTime · Starting in $mins min'
        : '$startTime – $endTime · In progress';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dark header
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0E3460),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: AppColors.secondaryYellow,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E4A7A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.type,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _InfoRow(icon: Icons.access_time_rounded, text: timeLabel),
                const SizedBox(height: 8),
                _InfoRow(
                    icon: Icons.person_outline_rounded, text: item.instructor),
                const SizedBox(height: 8),
                _InfoRow(
                    icon: Icons.location_on_outlined, text: item.location),
                const SizedBox(height: 14),
                _TakeMeThereButton(room: item.location),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade400),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ),
      ],
    );
  }
}

class _TakeMeThereButton extends StatelessWidget {
  final String room;
  const _TakeMeThereButton({required this.room});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed('/navigation'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.secondaryYellow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.navigation_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Take me there',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Step-by-step directions to $room',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Colors.white, size: 22),
          ],
        ),
      ),
    );
  }
}

// ── Later today card ──────────────────────────────────────────────────────────

class _LaterCard extends StatelessWidget {
  final ScheduleItem item;
  const _LaterCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final parts     = item.time.split(' - ');
    final startTime = parts[0].trim();
    final endTime   = parts.length > 1 ? parts[1].trim() : '';

    final isSection = item.type.toLowerCase() == 'section';
    final timeBlockColor  = isSection ? AppColors.secondaryYellow : const Color(0xFF0E3460);
    const cardColor       = Colors.white;
    final badgeBgColor   = isSection ? AppColors.LightYellow : AppColors.lightblue;
    final badgeTextColor = isSection ? AppColors.assignmentColor : AppColors.primaryBlue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          // Time block
          Container(
            width: 78,
            padding: const EdgeInsets.symmetric(vertical: 22),
            decoration: BoxDecoration(
              color: timeBlockColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(startTime,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(height: 10),
                Text(endTime,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ),

          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            color: AppColors.primaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeBgColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.type,
                          style: TextStyle(
                            color: badgeTextColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.person_outline_rounded,
                          size: 14, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(item.instructor,
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 14, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(item.location,
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 13)),
                    ],
                  ),
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

// ── Empty / Error states ──────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_available_outlined,
              size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'No classes today',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
