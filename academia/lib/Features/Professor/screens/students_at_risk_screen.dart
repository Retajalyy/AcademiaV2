import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../controllers/students_at_risk_controller.dart';
import '../models/attendance_models.dart';

class StudentsAtRiskScreen extends StatelessWidget {
  const StudentsAtRiskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.delete<StudentsAtRiskController>(force: true);
    final c = Get.put(StudentsAtRiskController());

    return Scaffold(
      backgroundColor: AppColors.babyblue,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Obx(() {
              if (c.isLoading.value) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryBlue));
              }
              if (c.courses.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline_rounded,
                          size: 56, color: Colors.green.shade300),
                      const SizedBox(height: 12),
                      Text('No students at risk',
                          style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 15)),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: c.refresh,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  itemCount: c.courses.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: 14),
                  itemBuilder: (_, i) =>
                      _CourseCard(course: c.courses[i]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
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
                Text('Homepage',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text('Students at risk',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('May be blocked from final examination',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }
}

// ── Course Card ───────────────────────────────────────────────────────────────

class _CourseCard extends StatelessWidget {
  final AtRiskCourse course;
  const _CourseCard({required this.course});

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course header row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(course.courseName,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A2B4A))),
                ),
                Text(
                  '${course.students.length} student${course.students.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF3F4F6)),

          // Student rows
          ...course.students.asMap().entries.map((e) => Column(
                children: [
                  _StudentRow(student: e.value),
                  if (e.key < course.students.length - 1)
                    const Divider(
                        height: 1,
                        color: Color(0xFFF3F4F6),
                        indent: 14,
                        endIndent: 14),
                ],
              )),
        ],
      ),
    );
  }
}

// ── Student Row ───────────────────────────────────────────────────────────────

class _StudentRow extends StatelessWidget {
  final AtRiskStudent student;
  const _StudentRow({required this.student});

  @override
  Widget build(BuildContext context) {
    final badgeColor = student.isBlocked
        ? AppColors.fail
        : student.absencesLeft <= 1
            ? const Color(0xFFF97316)
            : AppColors.fail;

    final badgeLabel = student.isBlocked
        ? 'BLOCKED'
        : '${student.absencesLeft} left';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primaryBlue,
            child: Text(student.initials,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ),
          const SizedBox(width: 12),

          // Name + attended
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.name,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A2B4A))),
                const SizedBox(height: 3),
                Text('${student.attended}/${student.totalSessions} attended',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF9CA3AF))),
              ],
            ),
          ),

          // Badge
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(badgeLabel,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: badgeColor)),
          ),
        ],
      ),
    );
  }
}
