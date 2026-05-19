import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:academia/Features/Course details/screens/CourseScreendetails.dart';
import '../../../Core/utilities/colors.dart';
import '../../../Core/utilities/text_style.dart';
import 'package:academia/Features/Academic_results/screens/Academic_results_screen.dart';

class WhileWaitingCard extends StatelessWidget {
  const WhileWaitingCard({super.key});

  Widget item(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    bool isAcademic = false,
    bool isCourses = false,
  }) {
    final bool isAcademicItem =
        isAcademic || title.contains("Academic Results");

    const double textSize = 14;

    final TextStyle baseStyle = const TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.w500,
      fontSize: textSize,
      color: Color(0xFF979696),
    );

    final TextStyle linkStyle = const TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.w500,
      fontSize: textSize,
      color: AppColors.primaryBlue,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.primaryBlue,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: icon == Icons.show_chart
                  ? const Color(0xFFFFF6E7)
                  : const Color(0xFFDDEDFA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: icon == Icons.show_chart
                  ? const Color(0xFFFFC258)
                  : AppColors.primaryBlue,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isAcademicItem
                    ? Text.rich(
                        TextSpan(
                          style: baseStyle,
                          children: [
                            const TextSpan(text: "Check your "),
                            TextSpan(
                              text: "Academic Results",
                              style: linkStyle,
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const AcademicResultsScreen(),
                                    ),
                                  );
                                },
                            ),
                          ],
                        ),
                      )
                    : Text(
                        title,
                        style: baseStyle,
                      ),

                const SizedBox(height: 4),

                isCourses
                    ? Text.rich(
                        TextSpan(
                          style: baseStyle,
                          children: [
                            const TextSpan(text: "In the "),
                            TextSpan(
                              text: "Courses",
                              style: linkStyle,
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                           CourseScreenDetails(),
                                    ),
                                  );
                                },
                            ),
                            const TextSpan(text: " section"),
                          ],
                        ),
                      )
                    : Text(
                        subtitle,
                        style: baseStyle,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "While you wait",
            style: TextStyles.subtitle.copyWith(
              color: AppColors.primaryBlue,
            ),
          ),

          const SizedBox(height: 14),

          item(
            context,
            icon: Icons.menu_book_outlined,
            title: "Review your course materials",
            subtitle: "In the Courses section",
            isCourses: true,
          ),

          item(
            context,
            icon: Icons.show_chart,
            title: "Check your Academic Results",
            subtitle: "to see where to focus",
            isAcademic: true,
          ),

          item(
            context,
            icon: Icons.access_time,
            title: "Exam schedules are usually published",
            subtitle: "2 weeks before the period starts",
          ),
        ],
      ),
    );
  }
}