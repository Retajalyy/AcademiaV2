import 'package:academia/Features/Dashboard_admin/controller/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../controllers/instructors_admin_controller.dart';
import '../models/instructor_admin_model.dart';

class AdminInstructorsScreen extends StatefulWidget {
  const AdminInstructorsScreen({super.key});

  @override
  State<AdminInstructorsScreen> createState() => _AdminInstructorsScreenState();
}

class _AdminInstructorsScreenState extends State<AdminInstructorsScreen> {
  late final InstructorsAdminController c;

  @override
  void initState() {
    super.initState();
    Get.delete<InstructorsAdminController>(force: true);
    c = Get.put(InstructorsAdminController());
  }

  @override
  void dispose() {
    Get.delete<InstructorsAdminController>(force: true);
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
            // ── Header ───────────────────────────────────────────────
            Obx(() => _buildHeader()),

            // ── Search ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: TextField(
                onChanged: c.onSearch,
                decoration: InputDecoration(
                  hintText: 'Search Professors...',
                  hintStyle: const TextStyle(
                      color: Color(0xFF9CA3AF), fontSize: 16),
                  prefixIcon:
                      const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // ── Faculty filter chips ──────────────────────────────────
            Obx(() => SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                children: [
                  _Chip(label: 'All', code: '', c: c),
                  ...c.faculties.map((f) =>
                      _Chip(label: f['name']!, code: f['code']!, c: c)),
                ],
              ),
            )),

            // ── Count + Sort ─────────────────────────────────────────
            Obx(() => Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Row(
                children: [
                  Text(
                    '${c.filtered.length} INSTRUCTOR',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
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
                            color: c.sortByRole.value
                                ? AppColors.primaryBlue
                                : const Color(0xFF6B7280)),
                        const SizedBox(width: 4),
                        Text('Sort by Role',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: c.sortByRole.value
                                    ? AppColors.primaryBlue
                                    : AppColors.smalltext)),
                      ],
                    ),
                  ),
                ],
              ),
            )),

            // ── List ─────────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (c.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryBlue),
                  );
                }
                if (c.filtered.isEmpty) {
                  return const Center(
                    child: Text('No instructors found.',
                        style: TextStyle(color: Color(0xFF9CA3AF))),
                  );
                }
                return RefreshIndicator(
                  onRefresh: c.refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: c.filtered.length,
                    itemBuilder: (_, i) =>
                        _InstructorCard(instructor: c.filtered[i]),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final dashboard = Get.find<DashboardController>();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
       
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chevron_left_rounded,
                    color: AppColors.greytext, size: 30),
                Text('Dashboard',
                    style: TextStyle(
                        color: AppColors.greytext,
                        fontSize: 18,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text('Instructors',
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 4),
          Text(
            '${dashboard.semester} . ${c.allInstructors.length} Instructors',
            style: const TextStyle(
                fontSize: 15,
                color: Colors.white70,
                fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}

// ── Filter chip ───────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String                    label;
  final String                    code;
  final InstructorsAdminController c;
  const _Chip({required this.label, required this.code, required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = c.selectedDept.value == code;
      return GestureDetector(
        onTap: () => c.selectDept(code),
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryBlue : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? AppColors.primaryBlue
                  : const Color(0xFFE5E7EB),
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

// ── Instructor card ───────────────────────────────────────────────────────────

class _InstructorCard extends StatelessWidget {
  final InstructorAdminModel instructor;
  const _InstructorCard({required this.instructor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all( color: Color(0xFFE5E7EB)),
     
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            // ── Top row: avatar + name + badges ───────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 22,
                  backgroundColor: instructor.avatarColor,
                  child: Text(instructor.initials,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                ),
                const SizedBox(width: 12),
                // Name + ID
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(instructor.name,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.black)),
                      const SizedBox(height: 3),
                      Text('ID: ${instructor.uniId}',
                          style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.smalltext)),
                    ],
                  ),
                ),
                // Role + Dept badges
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _badge(instructor.role,   instructor.roleColor),
                    const SizedBox(height: 4),
                    _badge(instructor.department, instructor.deptColor),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 3),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
            const SizedBox(height: 12),

            // ── Info rows ─────────────────────────────────────────────
            if (instructor.majors.isNotEmpty)
              _InfoRow(
                label: 'MAJOR',
                chips: instructor.majors,
                color: instructor.deptColor,
              ),

            if (instructor.courses.isNotEmpty) ...[
              const SizedBox(height: 8),
              _InfoRow(
                label: 'COURSE',
                chips: instructor.courses,
                color: instructor.deptColor,
              ),
            ],

            if (instructor.groups.isNotEmpty) ...[
              const SizedBox(height: 8),

              _InfoRow(
                label: 'GROUPS',
                chips: instructor.groups,
                color: instructor.deptColor,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color:        color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color)),
      );
}

// ── Info row (COURSE / GROUPS) ────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String       label;
  final List<String> chips;
  final Color        color;
  const _InfoRow(
      {required this.label, required this.chips, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 58,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 0.4)),
        ),
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: chips
                .map((chip) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color:        color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(chip,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: color)),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}
