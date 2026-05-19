import 'package:academia/Features/Academic_results/models/course_result_model.dart';
import 'package:flutter/material.dart';
import '../../../Core/utilities/colors.dart';
import 'subject_row.dart';

class SemesterResultsCard extends StatelessWidget {
  final String semesterLabel;
  final double gpa;
  final List<CourseResultModel> courses;

  const SemesterResultsCard({
    super.key,
    required this.semesterLabel,
    required this.gpa,
    required this.courses,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  semesterLabel,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
                          ),
                        ),
                        TextSpan(
                          text: gpa.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Color(0xFFB18334),
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                        ),
                        const TextSpan(
                          text: '/4.0',
                          style: TextStyle(
                            color: Color(0xFFB18334),
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey.shade300, height: 1),
          ...courses.asMap().entries.map((e) => SubjectRow(
                subject:     e.value.courseName,
                grade:       e.value.grade.toString(),
                gpa:         e.value.gpaPoints.toStringAsFixed(1),
                letter:      e.value.letter,
                badgeColor:  e.value.badgeColor,
                letterColor: e.value.letterColor,
                isLast:      e.key == courses.length - 1,
              )),
        ],
      ),
    );
  }
}
