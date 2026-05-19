import 'package:academia/Features/Academic_results/models/course_result_model.dart';
import 'package:academia/Features/Academic_results/models/semester_result_model.dart';
import 'package:flutter/material.dart';

import '../../../Core/utilities/colors.dart';
import 'subject_row.dart';

class SemesterResultsCard extends StatelessWidget {
  final SemesterResultModel semester;
  final List<CourseResultModel> courses;

  const SemesterResultsCard({
    super.key,
    required this.semester,
    required this.courses,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),

      child: Column(
        children: [
          /// HEADER
          Padding(
            padding: const EdgeInsets.all(10),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Semester info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        semester.label,
                        style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        semester.yearLabel,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                /// GPA Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),

                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4DE),
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'GPA ',
                          style: TextStyle(
                            color: Color(0xFFB18334),
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            fontFamily: 'Inter',
                          ),
                        ),

                        TextSpan(
                          text: semester.gpa?.toStringAsFixed(1) ?? '-',
                          style: const TextStyle(
                            color: Color(0xFFB18334),
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            fontFamily: 'Inter',
                          ),
                        ),

                        const TextSpan(
                          text: '/4.0',
                          style: TextStyle(
                            color: Color(0xFFB18334),
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(
            color: Colors.grey.shade300,
            height: 1,
          ),

          /// SUBJECTS
          ...courses.asMap().entries.map((entry) {
            final index = entry.key;
            final course = entry.value;

            final isLast = index == courses.length - 1;

            return SubjectRow(
              subject: course.courseName,
              grade: '${course.grade}',
              gpa: course.gpaPoints.toStringAsFixed(1),
              letter: course.letter,
              badgeColor: course.badgeColor,
              letterColor: course.letterColor,
              isLast: isLast,
            );
          }),
        ],
      ),
    );
  }
}
