import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../controllers/professor_home_controller.dart';

class AcademicOverviewScreen extends StatelessWidget {
  const AcademicOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ProfessorHomeController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4FC),
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            color: AppColors.primaryBlue,
            padding: EdgeInsets.fromLTRB(
                16, MediaQuery.of(context).padding.top + 12, 16, 22),
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
                      Text('Home',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text('Academic Overview',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text('Assignments, at-risk students & upcoming exams',
                    style:
                        TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),

          // ── Body ────────────────────────────────────────────────────────
          Expanded(
            child: Obx(() => ListView(
                  padding:
                      const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  children: [
                    if (c.latestAssignment.value != null) ...[
                      _SectionLabel('LATEST ASSIGNMENT'),
                      const SizedBox(height: 10),
                      _OverviewCard(
                        iconData: Icons.assignment_outlined,
                        iconBg: const Color(0xFFE8F0FE),
                        iconColor: AppColors.primaryBlue,
                        title: c.latestAssignment.value!['title'] as String,
                        subtitle:
                            c.latestAssignment.value!['course'] as String,
                        badge: c.latestAssignment.value!['badge'] as String,
                        badgeColor: const Color(0xFFE6F4EA),
                        badgeTextColor: const Color(0xFF137333),
                      ),
                      const SizedBox(height: 20),
                    ],

                    _SectionLabel('STUDENTS AT RISK'),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => Get.toNamed('/studentsAtRisk',
                          arguments: {
                            'professorId': c.professorId,
                            'isTA':        c.isTA.value,
                          }),
                      child: _OverviewCard(
                        iconData: Icons.person_off_outlined,
                        iconBg: const Color(0xFFFFEEEE),
                        iconColor: AppColors.fail,
                        title: 'Students at risk',
                        subtitle: 'Approaching absence limit',
                        badge:
                            '${c.studentsAtRisk.value} student${c.studentsAtRisk.value == 1 ? '' : 's'}',
                        badgeColor: const Color(0xFFFFEEEE),
                        badgeTextColor: AppColors.fail,
                        showArrow: true,
                      ),
                    ),

                    if (c.nextExamInfo.value != null) ...[
                      const SizedBox(height: 20),
                      _SectionLabel('NEXT EXAM'),
                      const SizedBox(height: 10),
                      _OverviewCard(
                        iconData: Icons.calendar_today_outlined,
                        iconBg: const Color(0xFFFFF3DF),
                        iconColor: AppColors.assignmentColor,
                        title: 'Next exam',
                        subtitle:
                            c.nextExamInfo.value!['subtitle'] as String,
                        badge: c.nextExamInfo.value!['badge'] as String,
                        badgeColor: const Color(0xFFFFF3DF),
                        badgeTextColor: AppColors.assignmentColor,
                      ),
                    ],
                  ],
                )),
          ),
        ],
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Text(text,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 0.8)),
          const SizedBox(width: 8),
          const Expanded(
              child: Divider(color: Color(0xFFD1D5DB), thickness: 1)),
        ],
      );
}

// ── Overview card ─────────────────────────────────────────────────────────────

class _OverviewCard extends StatelessWidget {
  final IconData iconData;
  final Color    iconBg;
  final Color    iconColor;
  final String   title;
  final String   subtitle;
  final String   badge;
  final Color    badgeColor;
  final Color    badgeTextColor;
  final bool     showArrow;

  const _OverviewCard({
    required this.iconData,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.badgeTextColor,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(iconData, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A2B4A))),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF9CA3AF))),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(20)),
              child: Text(badge,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: badgeTextColor)),
            ),
            if (showArrow) ...[
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded,
                  color: Colors.grey.shade400, size: 20),
            ],
          ],
        ),
      );
}
