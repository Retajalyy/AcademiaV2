import 'package:flutter/material.dart';
import '../../../Core/utilities/colors.dart';
import '../../../Core/utilities/text_style.dart';
import 'package:academia/Features/Services/screens/services_main_screen.dart';
class AssessmentHeader extends StatelessWidget {
  const AssessmentHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primaryBlue,

      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // ✅ prevents overflow

            children: [
              // Top Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white,size: 28),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ServicesScreen(),
                    ),
                  );
                },
              ),
                  Icon(Icons.notifications, color: Colors.white, size: 28),
                ],
              ),

              const SizedBox(height: 16),

              // Title
              Text(
                "Assessments",
                style: TextStyles.header2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),

              const SizedBox(height: 6),

              // Subtitle
              Text(
                "Track your midterm and participation results",
                style: TextStyles.caption.copyWith(
                  color: Color(0xFFDEDEDE),
                  fontSize: 15
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}