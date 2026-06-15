import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../controllers/assessment_controller.dart';
import 'package:academia/Core/widgets/custom_header.dart';
import 'package:academia/Core/widgets/shared_bottom_nav.dart';
import '../widgets/search_bar.dart';
import '../widgets/stats_card.dart';
import '../widgets/course_card.dart';

class Assessmentscreen extends StatelessWidget {
  const Assessmentscreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AssessmentController());

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      bottomNavigationBar: const SharedBottomNav(),
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(
              title: 'Assessments',
              description: 'Track your midterm and participation results',
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(color: AppColors.babyblue),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SearchBarWidget(
                          onChanged: (v) => controller.searchQuery.value = v,
                        ),
                        const SizedBox(height: 18),

                        // Stats row
                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                label: 'Avg midterm',
                                value: controller.avgMidterm.toStringAsFixed(0),
                                showOutOfHundred: true,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: StatCard(
                                label: 'Avg participation',
                                value: controller.avgParticipation.toStringAsFixed(0),
                                showOutOfHundred: true,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: StatCard(
                                label: 'Avg attendance',
                                value: '${controller.avgAttendance.toStringAsFixed(0)}%',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // Course assessment cards
                        if (controller.filtered.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 60),
                            child: Column(
                              children: [
                                Icon(Icons.search_off_rounded,
                                    size: 52,
                                    color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                Text(
                                  'No assessments found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Try a different search term',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ...controller.filtered.asMap().entries.map((e) {
                            final a = e.value;
                            final color = e.key % 2 == 0
                                ? AppColors.primaryBlue
                                : AppColors.secondaryYellow;
                            return CourseCard(
                              sectionId: a.sectionId,
                              title: a.courseName,
                              type: a.courseType,
                              midterm: a.midtermStr,
                              midtermStatus: a.midtermStatus,
                              participation: a.participationStr,
                              participationStatus: a.participationStatus,
                              attendance: a.attendanceStr,
                              attendanceStatus: a.attendanceStatus,
                              progress: a.progress,
                              progressColor: color,
                            );
                          }),

                        const SizedBox(height: 20),
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
