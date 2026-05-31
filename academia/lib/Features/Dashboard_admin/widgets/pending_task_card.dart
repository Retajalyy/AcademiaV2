import 'package:academia/Core/utilities/colors.dart';
import 'package:flutter/material.dart';

class PendingTaskCard extends StatelessWidget {
  final IconData icon;
  final String   title;
  final String   subtitle;
  final String   buttonText; // kept for compatibility, not shown
  final Color    leftBarColor;
  final Color    iconBgColor;
  final Color    iconColor;
  final Color    buttonColor;
  final Color    buttonTextColor;

  const PendingTaskCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.leftBarColor,
    required this.iconBgColor,
    required this.iconColor,
    required this.buttonColor,
    required this.buttonTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(color: leftBarColor, width: 5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 12),

          // ── Icon ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Container(
              height: 51,
              width:  50,
              decoration: BoxDecoration(
                color:        iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 30),
            ),
          ),

          const SizedBox(width: 12),

          // ── Text ──────────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment:  MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize:   14,
                      fontWeight: FontWeight.w700,
                      color:      AppColors.accentProgramming1,
                      height:     1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize:   11,
                      color:      AppColors.smalltext,
                      fontWeight: FontWeight.w400,
                      height:     1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Chevron ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(
              Icons.chevron_right_rounded,
              color: AppColors.smalltext,
              size: 25,
            ),
          ),
        ],
      ),
    );
  }
}
