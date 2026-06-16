import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../controllers/professor_exam_schedule_controller.dart';

class ProfessorExamScheduleScreen extends StatelessWidget {
  const ProfessorExamScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ProfessorExamScheduleController());

    return Scaffold(
      backgroundColor: AppColors.babyblue,
      body: Column(
        children: [
          _Header(),
          Expanded(
            child: Obx(() {
              if (c.isLoading.value) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryBlue));
              }
              if (c.error.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(c.error.value,
                          style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 12),
                      TextButton(
                          onPressed: c.refresh,
                          child: const Text('Retry')),
                    ],
                  ),
                );
              }
              if (c.exams.isEmpty) {
                return const Center(
                  child: Text('No exams scheduled.',
                      style: TextStyle(color: Colors.grey, fontSize: 15)),
                );
              }

              final upcoming = c.upcoming;
              final past     = c.past;

              return RefreshIndicator(
                onRefresh: c.refresh,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  children: [
                    if (upcoming.isNotEmpty) ...[
                      _sectionLabel(
                          'UPCOMING – ${upcoming.length} EXAM${upcoming.length == 1 ? '' : 'S'}'),
                      const SizedBox(height: 12),
                      ...upcoming.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _ExamCard(entry: e),
                          )),
                    ],
                    if (past.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _sectionLabel('COMPLETED – ${past.length}'),
                      const SizedBox(height: 12),
                      ...past.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _ExamCard(entry: e, dimmed: true),
                          )),
                    ],
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF9CA3AF),
          letterSpacing: 0.8,
        ),
      );
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.primaryBlue,
      padding: EdgeInsets.fromLTRB(16, top + 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: Get.back,
            child: const Row(
              children: [
                Icon(Icons.chevron_left_rounded,
                    color: Colors.white70, size: 22),
                SizedBox(width: 2),
                Text('Homepage',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Exam Schedule',
            style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your courses this semester',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ── Exam Card ─────────────────────────────────────────────────────────────────

class _ExamCard extends StatelessWidget {
  final ProfessorExamEntry entry;
  final bool dimmed;

  const _ExamCard({required this.entry, this.dimmed = false});

  Color get _countdownBg {
    final d = entry.daysUntil;
    if (d < 0)  return const Color(0xFFEEEEEE);
    if (d <= 7) return const Color(0xFFE8F0FE);
    return const Color(0xFFFFF3DF);
  }

  Color get _countdownText {
    final d = entry.daysUntil;
    if (d < 0)  return Colors.grey;
    if (d <= 7) return AppColors.primaryBlue;
    return const Color(0xFFB45309);
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dimmed ? 0.6 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Main row ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Countdown box
                  Container(
                    width: 72,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _countdownBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          entry.isPast
                              ? '✓'
                              : entry.daysUntil.toString(),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: _countdownText,
                          ),
                        ),
                        if (!entry.isPast)
                          Text(
                            'days',
                            style: TextStyle(
                                fontSize: 12, color: _countdownText),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Course name + type badge
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                entry.courseName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A2A4A),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F0FE),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                entry.examType,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Date
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined,
                                size: 13, color: Color(0xFF9CA3AF)),
                            const SizedBox(width: 5),
                            Text(
                              entry.formattedDate,
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF6B7280)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),

                        // Time
                        Row(
                          children: [
                            const Icon(Icons.access_time_outlined,
                                size: 13, color: Color(0xFF9CA3AF)),
                            const SizedBox(width: 5),
                            Text(
                              entry.formattedTime,
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF6B7280)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),

                        // Room
                        if (entry.room.isNotEmpty)
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 13, color: Color(0xFF9CA3AF)),
                              const SizedBox(width: 5),
                              Text(
                                entry.room,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF6B7280)),
                              ),
                            ],
                          ),

                        // Level
                        if (entry.level != null && entry.level!.isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(Icons.school_outlined,
                                  size: 13, color: Color(0xFF9CA3AF)),
                              const SizedBox(width: 5),
                              Text(
                                entry.level!,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF6B7280)),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Groups row ────────────────────────────────────────────────
            if (entry.groups.isNotEmpty) ...[
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: entry.groups
                      .map((g) => _GroupChip(label: g))
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GroupChip extends StatelessWidget {
  final String label;
  const _GroupChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        'Group $label',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF374151),
        ),
      ),
    );
  }
}
