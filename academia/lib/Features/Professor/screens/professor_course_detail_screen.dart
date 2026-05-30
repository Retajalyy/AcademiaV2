import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../controllers/professor_course_detail_controller.dart';
import '../models/professor_course_detail_model.dart';

class ProfessorCourseDetailScreen extends StatelessWidget {
  const ProfessorCourseDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ProfessorCourseDetailController());

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      body: SafeArea(
        child: Obx(() => Column(
              children: [
                _Header(c: c),
                Expanded(
                  child: c.isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: c.refresh,
                          child: _Body(c: c),
                        ),
                ),
              ],
            )),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final ProfessorCourseDetailController c;
  const _Header({required this.c});

  @override
  Widget build(BuildContext context) {
    final detail = c.detail.value;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back row
          Row(
            children: [
              GestureDetector(
                onTap: Get.back,
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Courses',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Course name + year badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  c.course.courseName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ),
              if (detail != null && detail.level > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Year ${detail.level}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          // Course code + major
          Row(
            children: [
              Text(
                c.course.courseCode,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 13,
                ),
              ),
              if (detail != null && detail.major.isNotEmpty) ...[
                Text(
                  '  •  ',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
                ),
                Text(
                  detail.major,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  final ProfessorCourseDetailController c;
  const _Body({required this.c});

  @override
  Widget build(BuildContext context) {
    final detail = c.detail.value;
    if (detail == null) return const SizedBox.shrink();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        _StatsRow(detail: detail),
        const SizedBox(height: 20),
        _MaterialsSection(detail: detail, courseId: c.course.courseId, ctrl: c),
        const SizedBox(height: 20),
        _ActionsGrid(c: c),
        const SizedBox(height: 20),
        _GroupsSection(detail: detail),
      ],
    );
  }
}

// ── Stats Row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final ProfessorCourseDetailModel detail;
  const _StatsRow({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.people_alt_outlined,
            value: '${detail.totalStudents}',
            label: 'Students',
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.grid_view_rounded,
            value: '${detail.groupCount}',
            label: 'Groups',
            color: const Color(0xFF7C3AED),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.school_outlined,
            value: detail.major.isEmpty ? '—' : detail.major,
            label: 'Major',
            color: const Color(0xFFF59E0B),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _StatCard(
      {required this.icon,
      required this.value,
      required this.label,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

// ── Materials Section ─────────────────────────────────────────────────────────

class _MaterialsSection extends StatelessWidget {
  final ProfessorCourseDetailModel detail;
  final int courseId;
  final ProfessorCourseDetailController ctrl;
  const _MaterialsSection({required this.detail, required this.courseId, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Course Material',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A2B4A),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${detail.materials.length} Files',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
              const Spacer(),
              Obx(() => GestureDetector(
                onTap: ctrl.isUploading.value ? null : ctrl.uploadFile,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ctrl.isUploading.value
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'New File',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              )),
            ],
          ),
          if (detail.materials.isEmpty) ...[
            const SizedBox(height: 16),
            Center(
              child: Text(
                'No materials uploaded yet',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
              ),
            ),
            const SizedBox(height: 4),
          ] else ...[
            const SizedBox(height: 12),
            ...detail.materials.map((m) => _MaterialRow(material: m)),
          ],
        ],
      ),
    );
  }
}

class _MaterialRow extends StatelessWidget {
  final CourseMaterialModel material;
  const _MaterialRow({required this.material});

  Color get _typeColor {
    switch (material.fileType) {
      case 'PDF':
        return const Color(0xFFEF4444);
      case 'DOCX':
      case 'DOC':
        return const Color(0xFF2563EB);
      case 'PPTX':
      case 'PPT':
        return const Color(0xFFF97316);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _typeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                material.fileType.length > 4
                    ? material.fileType.substring(0, 4)
                    : material.fileType,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: _typeColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A2B4A),
                  ),
                ),
                if (material.sizeLabel.isNotEmpty)
                  Text(
                    material.sizeLabel,
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
              ],
            ),
          ),
          Icon(Icons.download_outlined,
              size: 20, color: Colors.grey.shade400),
        ],
      ),
    );
  }
}

// ── Actions Grid ──────────────────────────────────────────────────────────────

class _ActionsGrid extends StatelessWidget {
  final ProfessorCourseDetailController c;
  const _ActionsGrid({required this.c});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionItem(
        icon: Icons.fact_check_outlined,
        label: 'Take Attendance',
        color: AppColors.primaryBlue,
        onTap: () => Get.snackbar('Attendance',
            'Attendance tracking coming soon',
            snackPosition: SnackPosition.BOTTOM),
      ),
      _ActionItem(
        icon: Icons.grade_outlined,
        label: 'Assign Grades',
        color: const Color(0xFF7C3AED),
        onTap: () => Get.snackbar('Grades', 'Grade assignment coming soon',
            snackPosition: SnackPosition.BOTTOM),
      ),
      _ActionItem(
        icon: Icons.bar_chart_rounded,
        label: 'View Results',
        color: const Color(0xFFF59E0B),
        onTap: () => Get.snackbar('Results', 'Results view coming soon',
            snackPosition: SnackPosition.BOTTOM),
      ),
      _ActionItem(
        icon: Icons.history_edu_outlined,
        label: 'Attendance Records',
        color: const Color(0xFF10B981),
        onTap: () => Get.snackbar('Records', 'Attendance records coming soon',
            snackPosition: SnackPosition.BOTTOM),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A2B4A),
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: actions
              .map((a) => _ActionCard(item: a))
              .toList(),
        ),
      ],
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionItem(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});
}

class _ActionCard extends StatelessWidget {
  final _ActionItem item;
  const _ActionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(item.icon, color: item.color, size: 17),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A2B4A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Groups Section ─────────────────────────────────────────────────────────────

class _GroupsSection extends StatelessWidget {
  final ProfessorCourseDetailModel detail;
  const _GroupsSection({required this.detail});

  @override
  Widget build(BuildContext context) {
    if (detail.groups.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Groups',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A2B4A),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: detail.groups
                .asMap()
                .entries
                .map((entry) => _GroupRow(
                      group: entry.value,
                      isLast: entry.key == detail.groups.length - 1,
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _GroupRow extends StatelessWidget {
  final CourseGroupInfo group;
  final bool isLast;
  const _GroupRow({required this.group, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    group.label.length > 3
                        ? group.label.substring(0, 3)
                        : group.label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  group.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A2B4A),
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(Icons.people_outline,
                      size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    '${group.studentCount} students',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            color: Colors.grey.shade100,
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }
}
