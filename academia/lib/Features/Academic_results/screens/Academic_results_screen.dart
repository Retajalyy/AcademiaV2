import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/results_controller.dart';
import '../models/semester_result_model.dart';
import 'package:academia/Core/widgets/custom_header.dart';
import 'package:academia/Core/widgets/shared_bottom_nav.dart';
import '../widgets/gpa_card.dart';
import '../widgets/result_semseter.dart';
import '../../../Core/utilities/colors.dart';

class AcademicResultsScreen extends StatelessWidget {
  const AcademicResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ResultsController());

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      bottomNavigationBar: const SharedBottomNav(),
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(
              title: 'Academic Results',
              description: 'Final exam results • All semesters',
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
                      GpaCard(
                        cumulativeGpa: controller.cumulativeGpa,
                        semesterGpas:  controller.semesterGpas,
                      ),
                      const SizedBox(height: 12),
                      ..._buildSemesterList(controller.semesters),
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

  List<Widget> _buildSemesterList(List<SemesterResultModel> semesters) {
    final widgets = <Widget>[];
    String? lastYear;

    for (final sem in semesters) {
      final yearPart = sem.yearLabel.split('·').first.trim();
      if (lastYear != null && yearPart != lastYear) {
        widgets.add(_yearDivider(lastYear));
        widgets.add(const SizedBox(height: 12));
      }
      lastYear = yearPart;

      widgets.add(ResultSemesterCard(
        status:      sem.status,
        semester:    sem.label,
        subtitle:    sem.yearLabel,
        gpa:         sem.gpa?.toStringAsFixed(1) ?? '-',
        statusColor: const Color(0xFF266192),
        onTap: sem.isPublished
            ? () => Get.toNamed(
                  '/academicresultscourses',
                  arguments: {'id': sem.id, 'label': '${sem.label} · ${sem.yearLabel}'},
                )
            : null,
      ));
      widgets.add(const SizedBox(height: 12));
    }
    return widgets;
  }

  Widget _yearDivider(String year) {
    return Row(
      children: [
        const Expanded(child: Divider(thickness: 0.8, color: Color(0xFFD3D4D4))),
        const SizedBox(width: 8),
        Text(
          year,
          style: const TextStyle(
            color: Color(0xFF979696),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(child: Divider(thickness: 1, color: Color(0xFFD3D4D4))),
      ],
    );
  }
}
