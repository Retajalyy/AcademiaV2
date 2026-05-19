import 'package:flutter/material.dart';

import '../../../Core/utilities/colors.dart';
import '../../../Core/utilities/text_style.dart';

class AcademicHeader extends StatelessWidget {
  const AcademicHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: screenHeight * 0.02,
      ),
      color: AppColors.primaryBlue,

      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Align(
              alignment: Alignment.centerRight,
              child: Icon(
                Icons.notifications,
                color: Colors.white,
                size: 28,
              ),
            ),

            SizedBox(height: screenHeight * 0.015),

            Text(
              "Academic Results",
              style: TextStyles.header2.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),

            SizedBox(height: screenHeight * 0.006),

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