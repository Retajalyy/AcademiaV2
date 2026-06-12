import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../controllers/course_controller.dart';
import 'package:academia/Core/widgets/custom_header.dart';
import 'package:academia/Core/widgets/shared_bottom_nav.dart';
import '../widgets/search_bar.dart';
import '../widgets/course_card .dart';

class CourseScreen extends StatelessWidget {
  const CourseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CourseController());

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      bottomNavigationBar: const SharedBottomNav(),
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(
              title: 'Courses',
              description: 'View and manage your courses',
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(color: AppColors.babyblue),
                child: Column(
                  children: [
                    const SearchBarWidget(),
                    const SizedBox(height: 18),
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (controller.courses.isEmpty) {
                          return const Center(
                            child: Text('No courses found', style: TextStyle(color: Colors.grey)),
                          );
                        }
                        return ListView.separated(
                          itemCount: controller.courses.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final course = controller.courses[index];
                            return CourseCard(
                              courseId:  course.courseId,
                              sectionId: course.sectionId,
                              title:     course.title,
                              doctor:    course.doctor,
                              type:      course.type,
                              credits:   course.credits,
                              day:       course.day,
                              time:      course.time,
                              location:  course.location,
                            );
                          },
                        );
                      }),
                    ),
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
