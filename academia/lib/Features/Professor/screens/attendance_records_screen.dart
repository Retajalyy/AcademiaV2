import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../controllers/attendance_records_controller.dart';
import '../models/attendance_models.dart';

class AttendanceRecordsScreen extends StatelessWidget {
  const AttendanceRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(AttendanceRecordsController());

    return Scaffold(
      backgroundColor: AppColors.babyblue,
      body: Column(
        children: [
          _buildHeader(c),
          Expanded(
            child: Obx(() {
              if (c.isLoading.value) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryBlue));
              }
              if (c.sessions.isEmpty) {
                return Center(
                  child: Text('No sessions recorded yet',
                      style: TextStyle(
                          color: Colors.grey.shade400, fontSize: 15)),
                );
              }
              return RefreshIndicator(
                onRefresh: c.refresh,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                  children: [
                    _SectionLabel('ALL SESSIONS'),
                    const SizedBox(height: 12),
                    ...c.sessions.map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Dismissible(
                            key: Key('session_${s.sessionId}'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 22),
                              decoration: BoxDecoration(
                                color: AppColors.fail,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.white,
                                  size: 26),
                            ),
                            confirmDismiss: (_) async {
                              return await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Delete session?'),
                                  content: Text(
                                    'Remove ${s.sectionType == 'LEC' ? 'Lecture' : 'Section'} '
                                    '${s.sessionNum} on ${s.dateLabel}?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Get.back(result: false),
                                        child: const Text('Cancel')),
                                    TextButton(
                                        onPressed: () =>
                                            Get.back(result: true),
                                        child: const Text('Delete',
                                            style: TextStyle(
                                                color: AppColors.fail))),
                                  ],
                                ),
                              ) ?? false;
                            },
                            onDismissed: (_) => c.deleteSession(s.sessionId),
                            child: _SessionCard(session: s),
                          ),
                        )),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AttendanceRecordsController c) {
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
          const Text('Attendance Records',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Row(
            children: [
              _HeaderBadge(c.courseName),
              const SizedBox(width: 8),
              _HeaderBadge('Spring ${DateTime.now().year}'),
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

class _SessionCard extends StatelessWidget {
  final AttendanceSessionSummary session;
  const _SessionCard({required this.session});

  void _openDetail() => Get.toNamed('/attendanceSessionDetail', arguments: {
        'sessionId':    session.sessionId,
        'sessionLabel': '${session.sectionType == 'LEC' ? 'Lecture' : 'Section'} ${session.sessionNum}',
      });

  Color get _barColor {
    if (session.percentage >= 75) return AppColors.primaryBlue;
    if (session.percentage >= 50) return AppColors.accentAI;
    return AppColors.fail;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openDetail,
      child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          // LEC / SEC badge
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFDDEDFA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(session.sectionType,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue)),
                Text('${session.sessionNum}',
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue)),
              ],
            ),
          ),

          const SizedBox(width: 14),

          // Date + groups
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.dateLabel,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A2B4A))),
                const SizedBox(height: 3),
                Text(
                  session.groups.isNotEmpty
                      ? session.groups.join(', ')
                      : '—',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Percentage + bar + count
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${session.percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _barColor)),
              const SizedBox(height: 5),
              SizedBox(
                width: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: session.percentage / 100,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(_barColor),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text('${session.presentCount}/${session.totalCount}',
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF9CA3AF))),
            ],
          ),

          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded,
              color: Colors.grey.shade300, size: 20),
        ],
      ),
    ));
  }
}
