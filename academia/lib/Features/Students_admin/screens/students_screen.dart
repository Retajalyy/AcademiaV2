import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../controllers/students_admin_controller.dart';
import '../models/student_admin_model.dart';

class AdminStudentsScreen extends StatefulWidget {
  const AdminStudentsScreen({super.key});

  @override
  State<AdminStudentsScreen> createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends State<AdminStudentsScreen> {
  late final StudentsAdminController c;

  @override
  void initState() {
    super.initState();
    Get.delete<StudentsAdminController>(force: true);
    c = Get.put(StudentsAdminController());
  }

  @override
  void dispose() {
    Get.delete<StudentsAdminController>(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            _Header(c: c),

            // ── Search ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                onChanged: c.onSearch,
                decoration: InputDecoration(
                  hintText: 'Search Students...',
                  hintStyle: const TextStyle(color: Color(0xFFB3B3B3), fontSize: 16),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // ── Faculty filter chips ─────────────────────────────────────
            Obx(() => SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                children: [
                  _FacultyChip(label: 'All',   code: '', c: c),
                  ...c.faculties.map((f) =>
                    _FacultyChip(label: f['name']!, code: f['code']!, c: c),
                  ),
                ],
              ),
            )),

            // ── Count + Sort ─────────────────────────────────────────────
            Obx(() => Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: Row(
                children: [
                  Text(
                    '${c.filtered.length} STUDENTS',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.smalltext,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: c.toggleSort,
                    child: Row(
                      children: [
                        Icon(Icons.sort, size: 20,
                            color: c.sortByLevel.value
                                ? AppColors.primaryBlue
                                : const Color(0xFF6B7280)),
                        const SizedBox(width: 4),
                        Text(
                          'Sort by Level',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: c.sortByLevel.value
                                ? AppColors.primaryBlue
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),

            // ── Student list ─────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (c.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryBlue),
                  );
                }
                if (c.filtered.isEmpty) {
                  return const Center(
                    child: Text('No students found.',
                        style: TextStyle(color: Color(0xFF9CA3AF))),
                  );
                }
                return RefreshIndicator(
                  onRefresh: c.refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: c.filtered.length,
                    itemBuilder: (_, i) => _StudentCard(student: c.filtered[i]),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final StudentsAdminController c;
  const _Header({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
    
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back + breadcrumb
          GestureDetector(
            onTap: () => Get.back(),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chevron_left_rounded,
                    color: Colors.white70, size: 30),
                Text('Dashboard',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text('Total Students',
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
          const SizedBox(height: 4),
          Obx(() {
            final sem = c.semesterLabel.value;
            final count = c.filtered.length;
            final subtitle = sem.isNotEmpty
                ? '$sem · $count enrolled'
                : '$count enrolled';
            return Text(
              subtitle,
              style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.greytext,
                  fontWeight: FontWeight.w400),
            );
          }),
        ],
      ),
    );
  }
}

// ── Faculty filter chip ───────────────────────────────────────────────────────

class _FacultyChip extends StatelessWidget {
  final String                  label;
  final String                  code;
  final StudentsAdminController c;
  const _FacultyChip({required this.label, required this.code, required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = c.selectedFaculty.value == code;
      return GestureDetector(
        onTap: () => c.selectFaculty(code),
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryBlue : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.primaryBlue : const Color(0xFFE5E7EB),
            ),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.smalltext)),
        ),
      );
    });
  }
}

// ── Student card ──────────────────────────────────────────────────────────────

class _StudentCard extends StatelessWidget {
  final StudentAdminModel student;
  const _StudentCard({required this.student});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          // ── Top row ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 22,
                  backgroundColor: student.avatarColor,
                  backgroundImage: student.avatarUrl != null
                      ? NetworkImage(student.avatarUrl!)
                      : null,
                  child: student.avatarUrl == null
                      ? Text(student.initials,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15))
                      : null,
                ),
                const SizedBox(width: 12),

                // Name + ID + major info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.name,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.black)),
                      const SizedBox(height: 4),
                      Text('ID: ${student.uniId}',
                          style: const TextStyle(
                              fontSize: 14, color: AppColors.smalltext)),
                      const SizedBox(height: 3),
                      Text(
                        [
                          if (student.major.isNotEmpty) student.major,
                          'Level ${student.level}',
                          if (student.groupLabel.isNotEmpty) student.groupLabel,
                        ].join(' · '),
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.smalltext,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),

                // Badges on the far right
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _Badge(
                        label: student.facultyBadge,
                        color: student.facultyBadgeColor),
                    const SizedBox(height: 4),
                    _Badge(
                        label: student.majorBadge,
                        color: student.majorBadgeColor),
                  ],
                ),
              ],
            ),
          ),

          // ── Divider ────────────────────────────────────────────────────
          const Divider(height: 1, color: Color(0xFFF3F4F6)),

          // ── Bottom row: phone + GPA ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
            child: Row(
              children: [
                const Icon(Icons.phone_outlined,
                    size: 20, color: Color(0xFF67737D)),
                const SizedBox(width: 6),
                Text(student.phone.isNotEmpty ? student.phone : '—',
                    style: const TextStyle(
                        fontSize: 14, color: Color(0xFF67737D))),
                const Spacer(),
                const Text('GPA ',
                    style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF67737D),
                        fontWeight: FontWeight.w500)),
                Container(
                  width: 8, height: 8,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: student.gpaColor,
                    shape: BoxShape.circle,
                  ),
                ),
                Text(student.gpaStr,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: student.gpaColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Badge ─────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color  color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color)),
    );
  }
}
