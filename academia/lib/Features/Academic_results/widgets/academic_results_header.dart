import 'package:flutter/material.dart';
import '../../../Core/utilities/colors.dart';
import '../../../Core/utilities/text_style.dart';
import 'package:academia/Features/Services/screens/services_main_screen.dart';

class AcademicResultsHeader extends StatelessWidget {
  const AcademicResultsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.24, // ✅ responsive height
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: screenHeight * 0.03, // ✅ responsive padding
      ),
      color: AppColors.primaryBlue,

      child: SafeArea( // ✅ prevents overflow with notch/status bar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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

            SizedBox(height: screenHeight * 0.02),

            // Title
            Text(
              "Academic Results",
              style: TextStyles.header2.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 30
              ),
            ),

            SizedBox(height: screenHeight * 0.008),

            // Subtitle
            Text(
              "Final exam results • All semesters",
              style: TextStyles.caption.copyWith(
                color: const Color(0xFFDEDEDE),
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}