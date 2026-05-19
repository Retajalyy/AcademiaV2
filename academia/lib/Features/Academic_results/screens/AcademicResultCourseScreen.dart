import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/course_results_controller.dart';
import 'package:academia/Core/widgets/custom_header.dart';
import 'package:academia/Core/widgets/shared_bottom_nav.dart';
import '../widgets/semster_result.dart';
import '../widgets/semster_header.dart';
import '../../../Core/utilities/colors.dart';

class AcademicResultsCourseScreen extends StatelessWidget {
  const AcademicResultsCourseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args       = Get.arguments as Map<String, dynamic>;
    final controller = Get.put(CourseResultsController(
      semesterResultId: args['id'] as int,
      semesterLabel:    args['label'] as String,
    ));

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      bottomNavigationBar: const SharedBottomNav(),
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(
              title: 'Academic Results',
              description: 'Final exam results • All semesters',
              showBackButton: false,
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(color: AppColors.babyblue),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ListView(
                    children: [
                      SemesterHeaderRow(label: controller.semesterLabel),
                      const SizedBox(height: 12),
                      SemesterResultsCard(
                        semesterLabel: controller.semesterLabel.split('·').first.trim(),
                        gpa:           controller.gpa.value,
                        courses:       controller.courseResults,
                      ),
                      const SizedBox(height: 20),
                    ],
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
