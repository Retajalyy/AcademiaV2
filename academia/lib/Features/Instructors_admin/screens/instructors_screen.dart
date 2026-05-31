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
        top: false,
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
                style: const TextStyle(fontSize: 16),
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
                    '${c.filtered.length} INSTRUCTORS',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6B7280),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  Obx(() {
                    final active = c.sortBy.value;
                    final label = active.isEmpty
                        ? 'Sort'
                        : 'Sort: ${active[0].toUpperCase()}${active.substring(1)}';
                    return PopupMenuButton<String>(
                      onSelected: c.setSortBy,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          Icon(Icons.sort, size: 18,
                              color: active.isNotEmpty
                                  ? AppColors.primaryBlue
                                  : const Color(0xFF6B7280)),
                          const SizedBox(width: 4),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: active.isNotEmpty
                                  ? AppColors.primaryBlue
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(Icons.arrow_drop_down, size: 18,
                              color: active.isNotEmpty
                                  ? AppColors.primaryBlue
                                  : const Color(0xFF6B7280)),
                        ],
                      ),
                      itemBuilder: (_) => [
                        'name', 'role', 'department',
                      ].map((opt) => PopupMenuItem<String>(
                        value: opt,
                        child: Row(
                          children: [
                            Icon(
                              active == opt
                                  ? Icons.check_rounded
                                  : Icons.sort,
                              size: 16,
                              color: active == opt
                                  ? AppColors.primaryBlue
                                  : const Color(0xFF6B7280),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${opt[0].toUpperCase()}${opt.substring(1)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: active == opt
                                    ? AppColors.primaryBlue
                                    : const Color(0xFF1A1A2E),
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    );
                  }),
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
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 14, 16, 20),
      color: AppColors.primaryBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chevron_left_rounded,
                    color: Colors.white70, size: 22),
                Text('Dashboard',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text('Instructors',
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
          const SizedBox(height: 4),
          Text(
            '${c.allInstructors.length} Instructors',
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : const Color(0xFF374151))),
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
    final hasBottom = instructor.courses.isNotEmpty || instructor.groups.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.09),
          width: 1,
        ),
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
          // ── Top row: avatar + name + badges ───────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: instructor.avatarColor,
                  child: Text(instructor.initials,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(instructor.name,
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E))),
                      const SizedBox(height: 3),
                      Text('ID: ${instructor.uniId}',
                          style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF9CA3AF))),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _badge(instructor.role,       instructor.roleColor),
                    const SizedBox(height: 4),
                    _badge(instructor.department, instructor.deptColor),
                  ],
                ),
              ],
            ),
          ),

          // ── F3F3F3 bottom: courses + groups ───────────────────────
          if (hasBottom)
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF3F3F3),
                borderRadius: BorderRadius.only(
                  bottomLeft:  Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    height: 1,
                    color: Colors.black.withValues(alpha: 0.09),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                    child: Column(
                      children: [
                        if (instructor.courses.isNotEmpty)
                          _InfoRow(
                            label: 'COURSE',
                            chips: instructor.courses,
                            color: instructor.deptColor,
                          ),
                        if (instructor.courses.isNotEmpty && instructor.groups.isNotEmpty)
                          const SizedBox(height: 8),
                        if (instructor.groups.isNotEmpty)
                          _InfoRow(
                            label: 'GROUPS',
                            chips: instructor.groups,
                            color: instructor.deptColor,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _badge(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color:        color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border:       Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
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
          width: 64,
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
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(chip,
                          style: TextStyle(
                              fontSize: 13,
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
