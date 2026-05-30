import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../../../Core/utilities/text_style.dart';
import '../controllers/course_details_controller.dart';

class CourseStats extends StatelessWidget {
  const CourseStats({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CourseDetailsController>();

    return Obx(() {
      final c = ctrl.course.value;
      final classwork   = c?.classworkPercent    ?? 0.0;
      final assignments = c?.assignmentsPercent  ?? 0.0;
      final attendance  = c?.attendancePercent   ?? 0.0;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: CircleStat(
                title:   "Classwork",
                value:   "${(classwork * 100).toStringAsFixed(0)}%",
                percent: classwork,
                color:   AppColors.accentProgramming1,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CircleStat(
                title:   "Assignments",
                value:   "${(assignments * 100).toStringAsFixed(0)}%",
                percent: assignments,
                color:   AppColors.accentAI,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CircleStat(
                title:   "Attendance",
                value:   "${(attendance * 100).toStringAsFixed(0)}%",
                percent: attendance,
                color:   AppColors.fail,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class CircleStat extends StatelessWidget {
  final String title;
  final String value;
  final double percent;
  final Color color;

  const CircleStat({
    super.key,
    required this.title,
    required this.value,
    required this.percent,
    required this.color,
  });

  Color get _dynamicColor =>
      percent >= 0.5 ? AppColors.accentProgramming1 : AppColors.fail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 55,
            height: 55,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 46,
                  height: 46,
                  child: CircularProgressIndicator(
                    value: percent,
                    strokeWidth: 6,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(_dynamicColor),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  value,
                  style: TextStyles.percenatge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _dynamicColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyles.percenatge.copyWith(
              fontWeight: FontWeight.w500,
              color: const Color(0xFF848282),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
