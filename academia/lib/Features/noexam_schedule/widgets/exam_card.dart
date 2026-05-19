import 'package:flutter/material.dart';
import '../../../Core/utilities/colors.dart';
import '../../../Core/utilities/text_style.dart';

class ExamCard extends StatelessWidget {
  final String? date;
  final String? month;
  final String title;
  final String? time;
  final String? room;
  final String? subtitle;

  final bool isNext;
  final bool isCompleted;
  final bool isHighlighted;

  const ExamCard({
    super.key,
    this.date,
    this.month,
    required this.title,
    this.time,
    this.room,
    this.subtitle,
    this.isNext = false,
    this.isCompleted = false,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    /// 🎨 Background Logic
    Color bgColor = AppColors.cardBackground;

    if (isHighlighted) {
      bgColor = const Color(0xFFFFF3DF);
    } else if (isCompleted) {
      bgColor = const Color(0xFFF7F7F7);
    }

    bool isMidtermExam =
        title.toLowerCase().contains('midterm') ||
        title.toLowerCase().contains('midterms');

    return Opacity(
      opacity: isCompleted ? 0.7 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),

          border: isNext
              ? Border.all(
                  color: AppColors.primaryBlue,
                  width: 2,
                )
              : null,

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isHighlighted ? 0.15 : 0.06),
              blurRadius: isHighlighted ? 5 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 📅 DATE
            if (date != null)
              SizedBox(
                width: 60,
                child: Column(
                  children: [
                    Text(
                      date!,
                      style: TextStyles.header2.copyWith(
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      month ?? "",
                      style: TextStyles.caption.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 2,
                      height: 40,
                      color: AppColors.disabledText.withValues(alpha: 0.2),
                    ),
                  ],
                ),
              ),

            if (date != null) const SizedBox(width: 12),

            /// 📄 CONTENT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔝 TITLE ROW
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 🧾 ICON (SAFE)
                      if (isMidtermExam)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: Image.asset(
                            'assets/images/exam_icon.png',
                            width: 40,
                            height: 40,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.assignment,
                                size: 30,
                                color: AppColors.primaryBlue,
                              );
                            },
                          ),
                        ),

                      /// 📝 TITLE + SUBTITLE
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyles.title.copyWith(
                                color: AppColors.primaryBlue, // ✅ FIXED visibility
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            if (isMidtermExam && subtitle != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  subtitle!,
                                  style: TextStyles.bodySecondary.copyWith(
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      /// 🔵 Tomorrow badge
                      if (isNext)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.lightblue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Tomorrow",
                            style: TextStyle(
                              color: AppColors.primaryText,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 3),

                  /// ⏰ TIME
                  if (time != null)
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 5),
                        
                        Text(
                          time!,
                          style: TextStyles.bodySecondary.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 25),
                       
                  /// 📍 ROOM
                  if (room != null)
                  
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 5),
                        Text(
                          room!,
                          style: TextStyles.bodySecondary.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}