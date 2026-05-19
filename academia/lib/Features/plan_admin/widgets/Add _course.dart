// lib/Features/plan_admin/widgets/Add _course.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../controller/plan_admin_controller.dart';

class CourseModel {
  final String name;
  final String type;
  final int credits;
  final IconData icon;
  final Color themeColor;

  CourseModel({
    required this.name,
    required this.type,
    required this.credits,
    required this.icon,
    required this.themeColor,
  });
}

class AddCoursesWidget extends StatefulWidget {
  const AddCoursesWidget({super.key});

  @override
  State<AddCoursesWidget> createState() => _AddCoursesWidgetState();
}

class _AddCoursesWidgetState extends State<AddCoursesWidget> {
  // Track selected state for ALL courses
  final Set<String> _selectedCourses = {};

  final List<CourseModel> courses = [
    CourseModel(
      name: "Cloud Computing",
      type: "Core",
      credits: 3,
      icon: Icons.storage_rounded,
      themeColor: const Color(0xFFDDEDFA),
    ),
    CourseModel(
      name: "Internet of Things",
      type: "Core",
      credits: 3,
      icon: Icons.language_rounded,
      themeColor: const Color(0xFFDDEDFA),
    ),
    CourseModel(
      name: "SW Quality and Analysis",
      type: "Core",
      credits: 3,
      icon: Icons.manage_search_rounded,
      themeColor: const Color(0xFFDDEDFA),
    ),
    CourseModel(
      name: "Digital Marketing",
      type: "Elective",
      credits: 2,
      icon: Icons.image_aspect_ratio_rounded,
      themeColor: const Color(0xFFFFF3DF),
    ),
    CourseModel(
      name: "Principles of Economics",
      type: "Elective",
      credits: 2,
      icon: Icons.trending_up_rounded,
      themeColor: const Color(0xFFFFF3DF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PlanAdminController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER
        Row(
          children: [
            const Text(
              "ADD COURSES",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.smalltext,
              ),
            ),

            const SizedBox(width: 10),

            if (_selectedCourses.isNotEmpty)
              Text(
                ". ${_selectedCourses.length} SELECTED",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0XFFB18334),
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        // LIST
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: courses.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final course = courses[index];
            final bool isSelected = _selectedCourses.contains(course.name);

            final Color accentColor = course.type == "Core"
                ? AppColors.accentProgramming1
                : AppColors.assignmentColor;

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.accentProgramming1
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: course.themeColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(course.icon, color: accentColor, size: 28),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentProgramming1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${course.type} • ${course.credits} credits",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.smalltext,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ✅ All courses tappable
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedCourses.remove(course.name);
                        } else {
                          _selectedCourses.add(course.name);
                        }
                      });
                      // Show assign button if any course is selected
                      c.showAssignButton.value = _selectedCourses.isNotEmpty;
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accentProgramming1
                            : course.themeColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSelected ? Icons.check : Icons.add,
                        color: isSelected ? Colors.white : accentColor,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}