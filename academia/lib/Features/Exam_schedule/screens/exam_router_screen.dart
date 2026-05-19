import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/exam_controller.dart';
import 'exam_schedule_screen.dart';
import 'no_exam_screen.dart';

class ExamRouterScreen extends StatelessWidget {
  const ExamRouterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ExamController());

    return Obx(() {
      if (c.isLoading.value) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }
      return c.hasExams
          ? const ExamScheduleScreen()
          : const NoExamScheduleScreen();
    });
  }
}