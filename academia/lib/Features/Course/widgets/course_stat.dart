import 'package:flutter/material.dart';
import '../../../Core/utilities/colors.dart';
import '../../../Core/utilities/text_style.dart';

class CourseStats extends StatelessWidget {
  const CourseStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: const [
          Expanded(
            child: CircleStat(
              title: "Classwork",
              value: "75%",
              percent: 0.75,
              color: AppColors.accentProgramming1,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: CircleStat(
              title: "Assignments",
              value: "75%",
              percent: 0.75,
              color: AppColors.accentAI,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: CircleStat(
              title: "Attendance",
              value: "15%",
              percent: 0.15,
              color: AppColors.fail, // fixed (fail → alertError)
            ),
          ),
        ],
      ),
    );
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

  Color getColor() {
    return percent >= 0.5
        ? AppColors.accentProgramming1 // blue
        : AppColors.fail;        // red
  }

  @override
  Widget build(BuildContext context) {
    final dynamicColor = getColor(); // ✅ override based on percent

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
                    valueColor:
                        AlwaysStoppedAnimation<Color>(dynamicColor), // ✅
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  value,
                  style: TextStyles.percenatge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: dynamicColor, // ✅ match color
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyles.percenatge.copyWith(fontWeight: FontWeight.w500,color:  Color(0xFF848282)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}