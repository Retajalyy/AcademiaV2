import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../controllers/take_attendance_controller.dart';
import '../models/attendance_models.dart';

class TakeAttendanceScreen extends StatelessWidget {
  const TakeAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(TakeAttendanceController());

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4FC),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue));
        }
        return Column(
          children: [
            _buildHeader(c),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionLabel('SELECT GROUP'),
                    const SizedBox(height: 12),
                    _GroupList(c: c),
                    const SizedBox(height: 24),
                    _SectionLabel('ATTENDANCE SHEET'),
                    const SizedBox(height: 12),
                    _CameraArea(c: c),
                    if (c.showResults.value) ...[
                      const SizedBox(height: 24),
                      _SectionLabel('RESULTS'),
                      const SizedBox(height: 12),
                      _ResultsList(c: c),
                      const SizedBox(height: 20),
                      _SaveButton(c: c),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildHeader(TakeAttendanceController c) {
    return Container(
      color: AppColors.primaryBlue,
      padding: const EdgeInsets.fromLTRB(16, 54, 16, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: Get.back,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chevron_left_rounded,
                    color: Colors.white70, size: 28),
                Text('Course Details',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text('Take Attendance',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Row(
            children: [
              Obx(() => _HeaderBadge(c.dateLabel)),
              const SizedBox(width: 8),
              Obx(() => _HeaderBadge('Session ${c.sessionNum.value}')),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  final String label;
  const _HeaderBadge(this.label);

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      );
}

// ── Section Label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Text(text,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 0.8)),
          const SizedBox(width: 10),
          const Expanded(
              child: Divider(color: Color(0xFFD1D5DB), thickness: 1)),
        ],
      );
}

// ── Group List ────────────────────────────────────────────────────────────────

class _GroupList extends StatelessWidget {
  final TakeAttendanceController c;
  const _GroupList({required this.c});

  @override
  Widget build(BuildContext context) {
    if (c.groups.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14)),
        child: const Center(
            child: Text('No groups assigned',
                style: TextStyle(color: Color(0xFF9CA3AF)))),
      );
    }
    return Column(
      children: c.groups
          .map((g) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _GroupCard(group: g, c: c),
              ))
          .toList(),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final AttendanceGroupInfo       group;
  final TakeAttendanceController  c;
  const _GroupCard({required this.group, required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = c.selectedGroup.value?.groupId == group.groupId;
      return GestureDetector(
        onTap: () => c.selectGroup(group),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Coloured left bar
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primaryBlue
                        : const Color(0xFFD1D5DB),
                    borderRadius: const BorderRadius.only(
                      topLeft:    Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Group ${group.label}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A2B4A))),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  if (group.timeRange.isNotEmpty) ...[
                                    Icon(Icons.access_time_outlined,
                                        size: 13,
                                        color: Colors.grey.shade400),
                                    const SizedBox(width: 4),
                                    Text(group.timeRange,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade500)),
                                    const SizedBox(width: 12),
                                  ],
                                  if (group.room.isNotEmpty) ...[
                                    Icon(Icons.location_on_outlined,
                                        size: 13,
                                        color: Colors.grey.shade400),
                                    const SizedBox(width: 4),
                                    Text(group.room,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade500)),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Radio
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected
                                  ? AppColors.primaryBlue
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: selected
                              ? Center(
                                  child: Container(
                                    width: 11,
                                    height: 11,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primaryBlue,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

// ── Camera Area ───────────────────────────────────────────────────────────────

class _CameraArea extends StatelessWidget {
  final TakeAttendanceController c;
  const _CameraArea({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() => GestureDetector(
          onTap: c.isProcessing.value ? null : c.captureSheet,
          child: Container(
            width: double.infinity,
            height: 260,
            decoration: BoxDecoration(
              color: const Color(0xFF0F2236),
              borderRadius: BorderRadius.circular(16),
            ),
            child: c.isProcessing.value
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white54),
                        SizedBox(height: 14),
                        Text('Scanning sheet...',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 14)),
                      ],
                    ),
                  )
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      // Corner brackets
                      Positioned.fill(
                          child: CustomPaint(painter: _CornerPainter())),

                      // Camera icon + label
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_outlined,
                                color: Colors.white, size: 28),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Point camera at the signed\nattendance sheet and tap\nto capture',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white60,
                                fontSize: 13,
                                height: 1.5),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ));
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white30
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const margin = 20.0;
    const len    = 28.0;
    final l = margin, r = size.width - margin;
    final t = margin, b = size.height - margin;

    // Top-left
    canvas.drawLine(Offset(l, t + len), Offset(l, t), paint);
    canvas.drawLine(Offset(l, t), Offset(l + len, t), paint);
    // Top-right
    canvas.drawLine(Offset(r - len, t), Offset(r, t), paint);
    canvas.drawLine(Offset(r, t), Offset(r, t + len), paint);
    // Bottom-left
    canvas.drawLine(Offset(l, b - len), Offset(l, b), paint);
    canvas.drawLine(Offset(l, b), Offset(l + len, b), paint);
    // Bottom-right
    canvas.drawLine(Offset(r - len, b), Offset(r, b), paint);
    canvas.drawLine(Offset(r, b), Offset(r, b - len), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Results List ──────────────────────────────────────────────────────────────

class _ResultsList extends StatelessWidget {
  final TakeAttendanceController c;
  const _ResultsList({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final students = c.selectedGroup.value?.students ?? [];
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Summary row
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  _SummaryChip(
                      '${c.presentCount} Present',
                      const Color(0xFFE6F4EA),
                      const Color(0xFF137333)),
                  const SizedBox(width: 8),
                  _SummaryChip(
                      '${c.absentCount} Absent',
                      const Color(0xFFFFEEEE),
                      AppColors.fail),
                  const Spacer(),
                  Text('Tap to toggle',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade400)),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFF3F4F6)),
            ...students.asMap().entries.map((e) => _StudentRow(
                  student: e.value,
                  isLast: e.key == students.length - 1,
                  onTap: () => c.toggleStudent(e.value),
                )),
          ],
        ),
      );
    });
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final Color  bg;
  final Color  text;
  const _SummaryChip(this.label, this.bg, this.text);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: text)),
      );
}

class _StudentRow extends StatelessWidget {
  final AttendanceStudentInfo student;
  final bool                  isLast;
  final VoidCallback          onTap;
  const _StudentRow(
      {required this.student, required this.isLast, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 18,
                  backgroundColor: student.isPresent
                      ? const Color(0xFFE6F4EA)
                      : const Color(0xFFFFEEEE),
                  child: Text(student.initials,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: student.isPresent
                              ? const Color(0xFF137333)
                              : AppColors.fail)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.name,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A2B4A))),
                      Text(student.uniId,
                          style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF9CA3AF))),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: student.isPresent
                        ? const Color(0xFFE6F4EA)
                        : const Color(0xFFFFEEEE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    student.isPresent ? 'Present' : 'Absent',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: student.isPresent
                            ? const Color(0xFF137333)
                            : AppColors.fail),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          const Divider(
              height: 1,
              color: Color(0xFFF3F4F6),
              indent: 14,
              endIndent: 14),
      ],
    );
  }
}

// ── Save Button ───────────────────────────────────────────────────────────────

class _SaveButton extends StatelessWidget {
  final TakeAttendanceController c;
  const _SaveButton({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() => SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: c.isSaving.value ? null : c.saveAttendance,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: c.isSaving.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white))
                : const Text('Save Attendance',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ));
  }
}
