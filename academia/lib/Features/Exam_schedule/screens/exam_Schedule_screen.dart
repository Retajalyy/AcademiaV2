// lib/features/exam/presentation/screens/exam_schedule_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/exam_controller.dart';
import '../widgets/exam_header.dart';
import '../widgets/exam_card.dart';
import '../../../../core/utilities/colors.dart';

class ExamScheduleScreen extends StatelessWidget {
  const ExamScheduleScreen({super.key});

  // Register (or find) without binding
  ExamController get _c => Get.put(ExamController());

  Widget _sectionTitle(String title) => Padding(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: SafeArea(
        child: Column(
          children: [
            const ExamHeader(),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(color: AppColors.babyblue),
                child: Obx(() {
                  if (_c.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_c.errorMessage.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_c.errorMessage.value),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _c.refresh,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView(
                    children: [
                      // ── Highlighted period banner ─────────────────
                      if (_c.examPeriod.value != null)
                        ExamCard(
                          isHighlighted: true,
                          title:    _c.examPeriod.value!.title,
                          subtitle: _c.examPeriod.value!.subtitle,
                        ),

                      const SizedBox(height: 16),

                      // ── Next exam ────────────────────────────────
                      if (_c.nextExam != null) ...[
                        _sectionTitle('Next Exam'),
                        const SizedBox(height: 12),
                        ExamCard(
                          date:   _c.nextExam!.date,
                          month:  _c.nextExam!.month,
                          title:  _c.nextExam!.title,
                          time:   _c.nextExam!.time,
                          room:   _c.nextExam!.room,
                          isNext: true,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // ── Upcoming ──────────────────────────────────
                      if (_c.upcomingExams.isNotEmpty) ...[
                        _sectionTitle('Upcoming'),
                        const SizedBox(height: 12),
                        ..._c.upcomingExams.map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ExamCard(
                              date:  e.date,
                              month: e.month,
                              title: e.title,
                              time:  e.time,
                              room:  e.room,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],

                      // ── Completed ─────────────────────────────────
                      if (_c.completedExams.isNotEmpty) ...[
                        _sectionTitle('Completed'),
                        const SizedBox(height: 12),
                        ..._c.completedExams.map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ExamCard(
                              date:        e.date,
                              month:       e.month,
                              title:       e.title,
                              time:        e.time,
                              room:        e.room,
                              isCompleted: true,
                            ),
                          ),
                        ),
                      ],
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