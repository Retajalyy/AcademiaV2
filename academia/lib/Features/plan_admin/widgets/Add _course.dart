import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../controller/plan_admin_controller.dart';

class AddCoursesWidget extends StatelessWidget {
  const AddCoursesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PlanAdminController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => Row(
              children: [
                const Text('ADD COURSES',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.smalltext)),
                const SizedBox(width: 10),
                if (c.selectedCourseNames.isNotEmpty)
                  Text(
                    '· ${c.selectedCourseNames.length} SELECTED',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFB18334)),
                  ),
              ],
            )),
        const SizedBox(height: 12),
        Obx(() {
          if (c.coursesLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (c.availableCourses.isEmpty) {
            return const Text('No courses found.',
                style: TextStyle(color: AppColors.smalltext));
          }
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: c.availableCourses.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final course      = c.availableCourses[index];
              final accentColor = course.type == 'Core'
                  ? AppColors.accentProgramming1
                  : AppColors.assignmentColor;

              return Obx(() {
                final isSelected = c.isCourseSelected(course.name);
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
                            Text(course.name,
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: accentColor)),
                            const SizedBox(height: 4),
                            Text('${course.type} · ${course.credits} credits',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.smalltext)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => c.toggleCourse(course.name, !isSelected),
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
              });
            },
          );
        }),
      ],
    );
  }
}
