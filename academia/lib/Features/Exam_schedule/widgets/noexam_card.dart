import 'package:flutter/material.dart';
import '../../../Core/utilities/colors.dart';
import '../../../Core/utilities/text_style.dart';

class NoExamCard extends StatelessWidget {
  const NoExamCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Padding(
  padding: const EdgeInsets.symmetric(vertical: 16), // space between boxes
  child: Container(
    height: 73,
    width: 73,
    decoration: BoxDecoration(
      color: const Color(0xFFEAF4FF), // enhanced light blue
      borderRadius: BorderRadius.circular(18),
     
    ),
    child: const Center(
      child: Icon(
        Icons.calendar_month,
        color: AppColors.primaryBlue,
        size: 40,
      ),
    ),
  ),
),

        const SizedBox(height: 15),

        Text(
          "No exams scheduled yet",
          style: TextStyles.body.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 40,
          ),
          child: Text(
            "The exam schedule for the current period "
            "hasn't been published yet. You'll get a "
            "notification as soon as it's available.",

            textAlign: TextAlign.center,
           style: TextStyle(
           fontSize: 14,
          fontFamily: 'Inter',
           fontWeight: FontWeight.w500,
           color: Color(0xFF979696), // Medium
           
),
          ),
        ),
      ],
    );
  }
}