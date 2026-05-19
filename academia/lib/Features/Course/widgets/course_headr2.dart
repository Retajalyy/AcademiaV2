import 'package:flutter/material.dart';
import '../../../Core/utilities/colors.dart';
import '../../../Core/utilities/text_style.dart';
import 'package:academia/Features/Course/screens/CourseScreen.dart';

class CourseHeaderDetails extends StatelessWidget {
  const CourseHeaderDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      color: AppColors.primaryBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔵 Top Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white,size: 28),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CourseScreen(),
                    ),
                  );
                },
              ),
              const Icon(Icons.notifications, color: Colors.white,size: 28),
            ],
          ),

          const SizedBox(height: 16),

          /// 🔵 Title
          Text(
            "Course Details",
            style: TextStyles.header2.copyWith(
              color: Colors.white,
              fontSize: 30,
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          /// 🔵 Inner Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF2468A0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Title + Credits
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Cloud Computing",
                      style: TextStyles.title.copyWith(color: Colors.white),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentAI,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "3 credits",
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Instrument Sans',
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentProgramming1,
                        ),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  "Dr. Youssef Senousy",
                  style: TextStyles.doctor2.copyWith(color: Colors.white70),
                ),

                const SizedBox(height: 12),

                /// Progress Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Course Progress",
                      style: TextStyles.doctor2
                          .copyWith(color: AppColors.accentAI),
                    ),
                    Text(
                      "65% completed",
                      style: TextStyles.percenatge
                          .copyWith(color: AppColors.accentAI),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                /// Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: 0.65,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: const AlwaysStoppedAnimation(
                      AppColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}