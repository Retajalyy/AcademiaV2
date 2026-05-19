// lib/Features/Course/screens/course_screen_details.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/course_headr.dart';
import '../widgets/course_stat.dart';
import '../widgets/material_list.dart';
import '../controllers/course_detail_controller.dart';
import '../../../Core/utilities/colors.dart';

class CourseScreenDetails extends StatelessWidget {
  const CourseScreenDetails({super.key});

  @override
  Widget build(BuildContext context) {
    // Registers controller if not yet registered; returns existing one if it is.
    final ctrl = Get.put(CourseDetailsController());

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: SafeArea(
        child: Column(
          children: [
            const CourseHeaderDetails(),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(color: AppColors.babyblue),
                child: Obx(() {
                  if (ctrl.errorMessage.isNotEmpty && !ctrl.isLoading.value) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            ctrl.errorMessage.value,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              final courseId =
                                  (Get.arguments as Map<String, dynamic>?)?[
                                          'courseId'] as String? ??
                                      'default-id';
                              ctrl.fetchDetails(courseId);
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (ctrl.isLoading.value && ctrl.course.value == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        CourseStats(),
                        SizedBox(height: 20),
                        CourseMaterialList(),
                        SizedBox(height: 20),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}