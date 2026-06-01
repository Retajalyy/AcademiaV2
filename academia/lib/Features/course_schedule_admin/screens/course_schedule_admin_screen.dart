import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../../../Core/widgets/side_menu.dart';
import '../controller/course_schedule_admin_controller.dart';
import '../models/course_schedule_admin_model.dart';
import 'course_schedule_group_detail_screen.dart';

class CourseScheduleAdminScreen extends StatelessWidget {
  const CourseScheduleAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CourseScheduleAdminController>()) {
      Get.put(CourseScheduleAdminController());
    }
    final c = Get.find<CourseScheduleAdminController>();

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      drawer: const SideMenu(activeItem: 'Course Schedule'),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _Header(c: c),
            Expanded(
              child: Container(
                color: const Color(0xFFF0F4FA),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                      child: TextField(
                        onChanged: (v) => c.searchQuery.value = v,
                        style: const TextStyle(fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Search schedules...',
                          hintStyle: const TextStyle(
                              color: Color(0xFF9CA3AF), fontSize: 16),
                          prefixIcon: const Icon(Icons.search,
                              color: Color(0xFF9CA3AF), size: 20),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    _FacultyChips(c: c),
                    Expanded(child: _GroupsList(c: c)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final CourseScheduleAdminController c;
  const _Header({required this.c});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (ctx) {
        final top = MediaQuery.of(ctx).padding.top;
        return Container(
        color: AppColors.primaryBlue,
        padding: EdgeInsets.fromLTRB(8, top + 12, 16, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () => Scaffold.of(ctx).openDrawer(),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.menu, color: Colors.white, size: 26),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Course Schedule',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Browse all groups timetables',
                  style: TextStyle(color: Colors.white60, fontSize: 15),
                ),
              ],
            ),
          ],
        ),
      );
      },
    );
  }
}

// ── Faculty Chips ─────────────────────────────────────────────────────────────

class _FacultyChips extends StatelessWidget {
  final CourseScheduleAdminController c;
  const _FacultyChips({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final uniqueFaculties = <String, String>{};
      for (final g in c.groups) {
        uniqueFaculties.putIfAbsent(g.facultyCode, () => g.facultyName);
      }
      return SizedBox(
        height: 37,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            GestureDetector(
              onTap: () => c.selectedFaculty.value = '',
              child: _Chip(
                  label: 'All',
                  selected: c.selectedFaculty.value.isEmpty),
            ),
            ...uniqueFaculties.entries.map((e) => GestureDetector(
                  onTap: () => c.selectedFaculty.value = e.key,
                  child: _Chip(
                      label: e.value,
                      selected: c.selectedFaculty.value == e.key),
                )),
          ],
        ),
      );
    });
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  const _Chip({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppColors.primaryBlue : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? AppColors.primaryBlue : const Color(0xFFE5E7EB),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : const Color(0xFF6B7280),
        ),
      ),
    );
  }
}

// ── Groups List ───────────────────────────────────────────────────────────────

class _GroupsList extends StatelessWidget {
  final CourseScheduleAdminController c;
  const _GroupsList({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue),
        );
      }

      if (c.errorMsg.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 10),
              Text(c.errorMsg.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 12),
              ElevatedButton(
                  onPressed: c.loadData, child: const Text('Retry')),
            ],
          ),
        );
      }

      final grouped = c.groupedByFaculty;

      if (grouped.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off_rounded,
                  size: 52, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text('No groups found',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500)),
              const SizedBox(height: 6),
              Text('Try a different search term',
                  style:
                      TextStyle(fontSize: 13, color: Colors.grey.shade400)),
            ],
          ),
        );
      }

      final items = <Widget>[];
      for (final entry in grouped.entries) {
        items.add(_SectionHeader(title: entry.key.toUpperCase()));
        for (final group in entry.value) {
          items.add(_GroupCard(
            group: group,
            onTap: () => _showDetail(context, group, c),
          ));
        }
      }

      return ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: items,
      );
    });
  }

  void _showDetail(BuildContext context, CourseScheduleGroupModel group,
      CourseScheduleAdminController c) {
    c.loadGroupSchedule(group.id);
    Get.to(() => CourseScheduleGroupDetailScreen(group: group));
  }
}

// ── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7280),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Divider(height: 1, color: Colors.grey.shade300)),
        ],
      ),
    );
  }
}

// ── Group Card ────────────────────────────────────────────────────────────────

class _GroupCard extends StatelessWidget {
  final CourseScheduleGroupModel group;
  final VoidCallback onTap;
  const _GroupCard({required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = group.facultyColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Colored left strip
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Group circle
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: Border.all(
                      color: const Color(0xFFFFC258), width: 2.5),
                ),
                child: Center(
                  child: Text(
                    group.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Group ${group.label}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A2A4A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${group.majorName} · Level ${group.level}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Course count
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${group.courseCount}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    Text(
                      'Courses',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
