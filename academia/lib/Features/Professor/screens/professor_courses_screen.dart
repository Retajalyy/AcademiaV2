import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../controllers/professor_courses_controller.dart';
import '../models/professor_course_model.dart';

class ProfessorCoursesScreen extends StatelessWidget {
  const ProfessorCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ProfessorCoursesController());

    return Scaffold(
      backgroundColor: AppColors.babyblue,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(),
          Expanded(child: _Body(c: c)),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 12, 20, 26),
      color: AppColors.primaryBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Courses',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'View and manage this semester courses',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  final ProfessorCoursesController c;
  const _Body({required this.c});

  // Colour palette for left bar + badges — cycles per card index
  static const _palette = [
    _CourseColor(
      bar:      Color(0xFF1A4F8A),
      badgeBg:  Color(0xFFDDEDFA),
      badgeText: Color(0xFF1A4F8A),
    ),
    _CourseColor(
      bar:      Color(0xFFB18334),
      badgeBg:  Color(0xFFFFF3DF),
      badgeText: Color(0xFFB18334),
    ),
    _CourseColor(
      bar:      Color(0xFF5A7FA8),
      badgeBg:  Color(0xFFE8EEF5),
      badgeText: Color(0xFF5A7FA8),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
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
              Icon(Icons.book_outlined,
                  size: 56, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text('No courses assigned',
                  style: TextStyle(
                      fontSize: 15, color: Colors.grey.shade500)),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: c.refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
          children: [
            // Section label
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'THIS SEMESTER – ${c.courses.length} COURSE${c.courses.length == 1 ? '' : 'S'}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 0.8,
                ),
              ),
            ),

            // Course cards
            ...c.courses.asMap().entries.map((entry) {
              final color = _palette[entry.key % _palette.length];
              return _CourseCard(
                course:      entry.value,
                color:       color,
                professorId: c.professorId,
                isTA:        c.isTA.value,
              );
            }),
          ],
        ),
      );
    });
  }
}

// ── Course Card ───────────────────────────────────────────────────────────────

class _CourseCard extends StatelessWidget {
  final ProfessorCourseModel course;
  final _CourseColor         color;
  final int                  professorId;
  final bool                 isTA;
  const _CourseCard({
    required this.course,
    required this.color,
    required this.professorId,
    required this.isTA,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        '/professorCourseDetail',
        arguments: {
          'course':      course,
          'professorId': professorId,
          'isTA':        isTA,
        },
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
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
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Colored left bar
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: color.bar,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Course name + chevron
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              course.courseName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A2B4A),
                              ),
                            ),
                          ),
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F4FA),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.grey.shade500,
                              size: 20,
                            ),
                          ),
                        ],
                      ),

                      // TA / Instructor row
                      if (course.taName.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.person_outline_rounded,
                                size: 15,
                                color: Colors.grey.shade400),
                            const SizedBox(width: 5),
                            Text(
                              '${isTA ? 'Dr.' : 'TA'}  ${course.taName}',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ],

                      // Groups row
                      if (course.sectionLabels.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.people_alt_outlined,
                                size: 15,
                                color: Colors.grey.shade400),
                            const SizedBox(width: 8),
                            Wrap(
                              spacing: 6,
                              children: course.sectionLabels
                                  .map((label) => _GroupBadge(
                                        label: label,
                                        bg: color.badgeBg,
                                        textColor: color.badgeText,
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Group Badge ───────────────────────────────────────────────────────────────

class _GroupBadge extends StatelessWidget {
  final String label;
  final Color  bg;
  final Color  textColor;
  const _GroupBadge(
      {required this.label,
       required this.bg,
       required this.textColor});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: textColor)),
      );
}

// ── Colour data ───────────────────────────────────────────────────────────────

class _CourseColor {
  final Color bar;
  final Color badgeBg;
  final Color badgeText;
  const _CourseColor(
      {required this.bar,
       required this.badgeBg,
       required this.badgeText});
}
