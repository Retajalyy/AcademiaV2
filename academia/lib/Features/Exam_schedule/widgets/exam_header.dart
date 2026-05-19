import 'package:flutter/material.dart';
import '../../../Core/utilities/colors.dart';
import '../../../Core/utilities/text_style.dart';

class ExamHeader extends StatelessWidget {
  const ExamHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 198,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: AppColors.primaryBlue,

      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 👈 KEY FIX
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Top row
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.arrow_back, color: Colors.white, size: 32),
                Icon(Icons.notifications, color: Colors.white, size: 32),
              ],
            ),

            const SizedBox(height: 16),

            /// Title
            Text(
              "Exam Schedule",
              style: TextStyles.header2.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),

            const SizedBox(height: 4),

            /// Subtitle
            Text(
              "Review your scheduled exams and timings",
              style: TextStyles.caption.copyWith(
                color: const Color(0xFFDEDEDE),
                fontSize: 15,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}