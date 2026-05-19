// lib/features/exam/presentation/screens/no_exam_schedule_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/exam_controller.dart';
import '../widgets/exam_header.dart';
import '../widgets/noexam_card.dart';
import 'package:academia/Features/Exam_schedule/widgets/while_waitingcard.dart';
import '../../../../core/utilities/colors.dart';

class NoExamScheduleScreen extends StatelessWidget {
  const NoExamScheduleScreen({super.key});

ExamController get _c => Get.put(ExamController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.babyblue,
      body: SafeArea(
        child: Column(
          children: [
            const ExamHeader(),
            Expanded(
              child: Obx(() {
                if (_c.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return SingleChildScrollView(
                  child: Column(
                    children: const [
                      SizedBox(height: 15),
                      NoExamCard(),
                      SizedBox(height: 20),
                      WhileWaitingCard(),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      
    );
  }

 
}