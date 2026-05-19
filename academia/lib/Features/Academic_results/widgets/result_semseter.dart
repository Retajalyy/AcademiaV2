import 'package:flutter/material.dart';
import '../../../Core/utilities/colors.dart';

class ResultSemesterCard extends StatelessWidget {
  final String status;
  final String semester;
  final String subtitle;
  final String gpa;
  final Color statusColor;
  final VoidCallback? onTap;

  const ResultSemesterCard({
    super.key,
    required this.status,
    required this.semester,
    required this.subtitle,
    required this.gpa,
    required this.statusColor,
    this.onTap,
  });

  Color getStatusColor() {
    switch (status.toLowerCase()) {
      case "latest results":
        return const Color(0xFF4A90E2);

      case "completed":
        return const Color(0xFFFFC966);

      case "in progress":
        return const Color(0xFFE9EEF3);

      case "not published yet":
        return const Color(0xFFC9D4DF);

      default:
        return Colors.grey;
    }
  }

  Color getStatusTextColor() {
    switch (status.toLowerCase()) {
      case "not published yet":
        return const Color(0xFF848282);

      case "in progress":
        return const Color(0xFF266192);

      case "completed":
        return const Color(0xFFB18334);

      case "latest results":
        return const Color(0xFF266192);

      default:
        return Colors.black;
    }
  }

  bool get isNotPublished => status.toLowerCase() == "not published yet";

  @override
  Widget build(BuildContext context) {
    final displayStatusColor = getStatusColor();
    final displayTextColor = getStatusTextColor();

    return GestureDetector(
      onTap: isNotPublished ? null : onTap,
      child: Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          /// LEFT SIDE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: displayStatusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: displayTextColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  semester,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFFBCBDBE),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          /// RIGHT SIDE
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 70,
                child: Center(
                  child: isNotPublished
                      ? const Icon(
                          Icons.access_time,
                          color: Color.fromARGB(255, 177, 182, 185),
                          size: 21,
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              gpa,
                              style: TextStyle(
                                color: status.toLowerCase() == "completed"
                                    ? const Color.fromARGB(255, 56, 84, 139)
                                    : const Color.fromARGB(255, 255, 194, 88),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              "/4.0 GPA",
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.disabledText,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(width: 6),

              if (!isNotPublished)
                InkWell(
                  onTap: onTap,
                  child: Icon(
                    Icons.chevron_right,
                    color: onTap != null
                        ? AppColors.disabledText
                        : const Color(0xFFB0B0B0),
                    size: 22,
                  ),
                ),
            ],
          ),
        ],
      ),
    ),
    );
  }
}