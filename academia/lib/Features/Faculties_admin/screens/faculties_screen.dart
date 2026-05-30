import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../controllers/faculties_admin_controller.dart';
import '../models/faculty_admin_model.dart';

class AdminFacultiesScreen extends StatefulWidget {
  const AdminFacultiesScreen({super.key});

  @override
  State<AdminFacultiesScreen> createState() => _AdminFacultiesScreenState();
}

class _AdminFacultiesScreenState extends State<AdminFacultiesScreen> {
  late final FacultiesAdminController c;

  @override
  void initState() {
    super.initState();
    Get.delete<FacultiesAdminController>(force: true);
    c = Get.put(FacultiesAdminController());
  }

  @override
  void dispose() {
    Get.delete<FacultiesAdminController>(force: true);
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
            // ── Header ────────────────────────────────────────────────
            Obx(() => _buildHeader()),

            // ── Search ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: TextField(
                onChanged: c.onSearch,
                decoration: InputDecoration(
                  hintText: 'Search Faculty...',
                  hintStyle: const TextStyle(
                      color: Color(0xFF9CA3AF), fontSize: 14),
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

            // ── Count ─────────────────────────────────────────────────
            Obx(() => Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Text(
                '${c.filtered.length} FACULTIES',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6B7280),
                  letterSpacing: 0.5,
                ),
              ),
            )),

            // ── List ──────────────────────────────────────────────────
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
                    child: Text('No faculties found.',
                        style: TextStyle(color: Color(0xFF9CA3AF))),
                  );
                }
                return RefreshIndicator(
                  onRefresh: c.refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: c.filtered.length,
                    itemBuilder: (_, i) =>
                        _FacultyCard(faculty: c.filtered[i]),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Built inside Obx so reactive reads are properly tracked
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft:  Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
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
                    color: Colors.white70, size: 22),
                Text('Dashboard',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text('Faculties',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
          const SizedBox(height: 4),
          Obx(() {
            final year  = c.yearLabel.value;
            final count = '${c.allFaculties.length} Faculties · ${c.totalMajors} Majors';
            return Text(
              year.isNotEmpty ? '$year · $count' : count,
              style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                  fontWeight: FontWeight.w400),
            );
          }),
        ],
      ),
    );
  }
}

// ── Faculty card ──────────────────────────────────────────────────────────────

class _FacultyCard extends StatelessWidget {
  final FacultyAdminModel faculty;
  const _FacultyCard({required this.faculty});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Faculty name + icon
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: faculty.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(faculty.icon,
                      color: faculty.color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(faculty.name,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E))),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Major chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: faculty.majorNames
                  .map((m) => _MajorChip(
                      label: m, color: faculty.color))
                  .toList(),
            ),

            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFF3F4F6)),
            const SizedBox(height: 14),

            // Stats row
            Row(
              children: [
                _Stat(
                    value: faculty.studentCount.toString(),
                    label: 'Students',
                    color: faculty.color),
                _vDivider(),
                _Stat(
                    value: faculty.instructorCount.toString(),
                    label: 'Instructor',
                    color: faculty.color),
                _vDivider(),
                _Stat(
                    value: faculty.courseCount.toString(),
                    label: 'Courses',
                    color: faculty.color),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _vDivider() => Container(
        width: 1, height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        color: const Color(0xFFF3F4F6),
      );
}

// ── Major chip ────────────────────────────────────────────────────────────────

class _MajorChip extends StatelessWidget {
  final String label;
  final Color  color;
  const _MajorChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color:        color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border:       Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color)),
      );
}

// ── Stat item ─────────────────────────────────────────────────────────────────

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final Color  color;
  const _Stat(
      {required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w500)),
          ],
        ),
      );
}
