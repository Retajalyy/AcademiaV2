import 'package:academia/Features/Academic_results/controllers/course_results_controller.dart';
import 'package:academia/Features/Academic_results/models/semester_result_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/academic_results_header2.dart';
import '../widgets/semster_result.dart';
import '../widgets/semster_header.dart';

import '../../../Core/utilities/colors.dart';

class AcademicResultsCourseScreen extends StatelessWidget {
  const AcademicResultsCourseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final int semId        = args['id']        as int?    ?? 0;
    final String semLabel  = args['label']     as String? ?? '';
    final String yearLabel = args['yearLabel'] as String? ?? '';

    final controller = Get.isRegistered<CourseResultsController>()
        ? Get.find<CourseResultsController>()
        : Get.put(CourseResultsController(
            semesterResultId: semId,
            semesterLabel: semLabel,
          ));

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,

      body: SafeArea(
        child: Column(
          children: [
            const AcademicHeader(),

            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),

                decoration: const BoxDecoration(
                  color: AppColors.babyblue,
                ),

                child: Obx(() {
                  /// Loading
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  /// Error
                  if (controller.hasError.value) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            controller.errorMessage.value,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: controller.retry,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  /// No Data
                  if (controller.courseResults.isEmpty) {
                    return const Center(
                      child: Text('No semester results found'),
                    );
                  }

                  final semester = SemesterResultModel(
                    id:        semId,
                    number:    0,
                    label:     semLabel,
                    yearLabel: yearLabel,
                    status:    '',
                    gpa:       controller.gpa.value,
                  );

                  return ListView(
                    children: [
                      SemesterHeaderRow(label: semLabel),
                      const SizedBox(height: 12),
                      SemesterResultsCard(
                        semester: semester,
                        courses:  controller.courseResults,
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
