import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../controllers/professor_submissions_controller.dart';
import '../models/assignment_submission_info.dart';

class ProfessorSubmissionsScreen extends StatelessWidget {
  const ProfessorSubmissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ProfessorSubmissionsController());

    return Scaffold(
      backgroundColor: AppColors.babyblue,
      body: Column(
        children: [
          _Header(c: c),
          Expanded(
            child: Obx(() {
              if (c.isLoading.value) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryBlue));
              }
              if (c.assignments.isEmpty) {
                return const Center(
                  child: Text('No assignments with due dates found.',
                      style: TextStyle(
                          color: Color(0xFF9CA3AF), fontSize: 14)),
                );
              }
              return RefreshIndicator(
                onRefresh: c.refresh,
                child: ListView(
                  padding:
                      const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  children: [
                    const _SectionLabel('ASSIGNMENTS'),
                    const SizedBox(height: 12),
                    ...c.assignments.map((a) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _AssignmentCard(item: a),
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
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final ProfessorSubmissionsController c;
  const _Header({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primaryBlue,
      padding: EdgeInsets.fromLTRB(
          16, MediaQuery.of(context).padding.top + 12, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: Get.back,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chevron_left_rounded,
                    color: Colors.white70, size: 26),
                Text('Course Details',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text('Submissions',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              _Badge(c.course.courseName),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge(this.text);

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      );
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF9CA3AF),
            letterSpacing: 0.8),
      );
}

// ── Assignment card ───────────────────────────────────────────────────────────

class _AssignmentCard extends StatelessWidget {
  final AssignmentSubmissionInfo item;
  const _AssignmentCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        children: [
          // ── Top row ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F0FE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.assignment_outlined,
                      color: AppColors.primaryBlue, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A2B4A))),
                      if (item.dueDateLabel.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined,
                                size: 12,
                                color: Color(0xFF9CA3AF)),
                            const SizedBox(width: 4),
                            Text(item.dueDateLabel,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9CA3AF))),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                _StatusBadge(isOpen: item.isOpen),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF3F4F6)),

          // ── Stats row ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 10),
            child: Row(
              children: [
                _StatDot(
                    color: const Color(0xFF16A34A),
                    label: '${item.onTime} on time'),
                const SizedBox(width: 16),
                _StatDot(
                    color: const Color(0xFFD97706),
                    label: '${item.late} late'),
                const SizedBox(width: 16),
                _StatDot(
                    color: const Color(0xFFDC2626),
                    label: '${item.pending} pending'),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF3F4F6)),

          // ── View submissions link ─────────────────────────────────────
          GestureDetector(
            onTap: () {
              final ctrl = Get.find<ProfessorSubmissionsController>();
              Get.toNamed('/studentSubmissionsDetail', arguments: {
                'course':      ctrl.course,
                'assignment':  item,
                'professorId': ctrl.professorId,
                'isTA':        ctrl.isTA,
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('View students submissions',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue)),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.primaryBlue, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isOpen;
  const _StatusBadge({required this.isOpen});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isOpen
              ? const Color(0xFFDCFCE7)
              : const Color(0xFFFFEEEE),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          isOpen ? 'Open' : 'Closed',
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isOpen
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFDC2626)),
        ),
      );
}

class _StatDot extends StatelessWidget {
  final Color  color;
  final String label;
  const _StatDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 8,
              height: 8,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      );
}
