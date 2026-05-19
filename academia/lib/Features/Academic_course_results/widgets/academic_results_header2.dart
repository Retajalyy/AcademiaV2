import 'package:flutter/material.dart';
import '../../../Core/utilities/colors.dart';
import '../../../Core/utilities/text_style.dart';

class AcademicHeader extends StatelessWidget {
  const AcademicHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.23,
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: screenHeight * 0.03,
      ),
      color: AppColors.primaryBlue,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bell only (no back arrow ✅)
            const Align(
              alignment: Alignment.centerRight,
              child: Icon(Icons.notifications, color: Colors.white, size: 28),
            ),

            SizedBox(height: screenHeight * 0.02),

            Text(
              "Academic Results",
              style: TextStyles.header2.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),

            SizedBox(height: screenHeight * 0.008),

            Text(
              "Final exam results • All semesters",
              style: TextStyles.caption.copyWith(
                color: AppColors.greytext,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}