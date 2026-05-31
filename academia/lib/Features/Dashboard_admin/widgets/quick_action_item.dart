import 'package:flutter/material.dart';
import '../../../Core/utilities/colors.dart';

class QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color borderColor;
  final Color iconColor;
  final Color backgroundColor;

  const QuickActionItem({
    super.key,
    required this.icon,
    required this.title,
    required this.borderColor,
    required this.iconColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130, // 👈 was 95
      height: 130, // 👈 was 120
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ICON BOX
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(14),
           
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 30,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w800,
                
              ),
            ),
          ],
        ),
      ),
    );
  }
}