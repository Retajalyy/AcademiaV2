import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../controllers/attendance_session_detail_controller.dart';
import '../models/attendance_models.dart';

class AttendanceSessionDetailScreen extends StatelessWidget {
  const AttendanceSessionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(AttendanceSessionDetailController());

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4FC),
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
              return Column(
                children: [
                  // Group filter chips
                  _GroupChips(c: c),
                  const SizedBox(height: 4),
                  // Student list
                  Expanded(child: _StudentList(c: c)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AttendanceSessionDetailController c) {
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
                Text('Attendance Records',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(c.sessionLabel,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

// ── Group Filter Chips ────────────────────────────────────────────────────────

class _GroupChips extends StatelessWidget {
  final AttendanceSessionDetailController c;
  const _GroupChips({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() => SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            children: c.groups.map((g) {
              final selected = c.selectedGroup.value == g;
              return GestureDetector(
                onTap: () => c.selectedGroup.value = g,
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primaryBlue
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? AppColors.primaryBlue
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Text(g,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : const Color(0xFF6B7280))),
                ),
              );
            }).toList(),
          ),
        ));
  }
}

// ── Student List ──────────────────────────────────────────────────────────────

class _StudentList extends StatelessWidget {
  final AttendanceSessionDetailController c;
  const _StudentList({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final students = c.filtered;
      if (students.isEmpty) {
        return Center(
            child: Text('No students found',
                style: TextStyle(
                    color: Colors.grey.shade400, fontSize: 14)));
      }
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: students.asMap().entries.map((e) {
                return Column(
                  children: [
                    _StudentRow(record: e.value),
                    if (e.key < students.length - 1)
                      const Divider(
                          height: 1,
                          color: Color(0xFFF3F4F6),
                          indent: 16,
                          endIndent: 16),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      );
    });
  }
}

class _StudentRow extends StatelessWidget {
  final SessionStudentRecord record;
  const _StudentRow({required this.record});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primaryBlue,
            child: Text(record.initials,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ),
          const SizedBox(width: 14),

          // Name
          Expanded(
            child: Text(record.name,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A2B4A))),
          ),

          // Present / Absent badge
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: record.isPresent
                  ? const Color(0xFFE6F4EA)
                  : const Color(0xFFFFEEEE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              record.isPresent ? 'Present' : 'Absent',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: record.isPresent
                      ? const Color(0xFF137333)
                      : AppColors.fail),
            ),
          ),
        ],
      ),
    );
  }
}
