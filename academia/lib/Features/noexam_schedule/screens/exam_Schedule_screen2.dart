import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/exam_controller.dart';
import 'package:academia/Core/widgets/custom_header.dart';
import 'package:academia/Core/widgets/shared_bottom_nav.dart';
import '../widgets/exam_card.dart';
import '../../../Core/utilities/colors.dart';

class ExamScheduleScreen2 extends StatelessWidget {
  const ExamScheduleScreen2({super.key});

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF908C8C),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ExamController());

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      bottomNavigationBar: const SharedBottomNav(),
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(
              title: 'Exam Schedule',
              description: 'Review your scheduled exams and timings',
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.babyblue,
                ),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final period = controller.period.value;
                  final nextExam = controller.nextExam;
                  final upcoming = controller.upcomingExams;
                  final completed = controller.completedExams;

                  return ListView(
                    children: [
                      // Period banner
                      ExamCard(
                        isHighlighted: true,
                        title: period?.label ?? "Exam Period",
                        subtitle: period?.subtitle,
                      ),

                      const SizedBox(height: 16),

                      // Next Exam
                      if (nextExam != null) ...[
                        _sectionTitle("Next Exam"),
                        const SizedBox(height: 12),
                        ExamCard(
                          date: nextExam.day,
                          month: nextExam.month,
                          title: nextExam.courseName,
                          time: nextExam.timeLabel,
                          room: nextExam.room,
                          isNext: true,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Upcoming
                      if (upcoming.isNotEmpty) ...[
                        _sectionTitle("Upcoming"),
                        const SizedBox(height: 12),
                        ...upcoming.map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: ExamCard(
                                date: e.day,
                                month: e.month,
                                title: e.courseName,
                                time: e.timeLabel,
                                room: e.room,
                              ),
                            )),
                        const SizedBox(height: 4),
                      ],

                      // Completed
                      if (completed.isNotEmpty) ...[
                        _sectionTitle("Completed"),
                        const SizedBox(height: 12),
                        ...completed.map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: ExamCard(
                                date: e.day,
                                month: e.month,
                                title: e.courseName,
                                time: e.timeLabel,
                                room: e.room,
                                isCompleted: true,
                              ),
                            )),
                      ],

                      if (nextExam == null && upcoming.isEmpty && completed.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 48),
                            child: Text(
                              "No exams found.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
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
