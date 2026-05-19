import 'package:flutter/material.dart';
import 'package:academia/Core/utilities/colors.dart';

class CourseResultModel {
  final String courseName;
  final int grade;
  final double gpaPoints;
  final String letter;

  CourseResultModel({
    required this.courseName,
    required this.grade,
    required this.gpaPoints,
    required this.letter,
  });

  Color get badgeColor {
    switch (letter) {
      case 'A+':
      case 'A':
      case 'B+':
      case 'B':
        return const Color(0xFFDDEDFA);
      case 'C+':
      case 'C':
        return const Color(0xFFFFF3DF);
      default:
        return const Color(0xFFFFE8E8);
    }
  }

  Color get letterColor {
    switch (letter) {
      case 'A+':
      case 'A':
      case 'B+':
      case 'B':
        return AppColors.primaryBlue;
      case 'C+':
      case 'C':
        return const Color(0xFFB18334);
      default:
        return Colors.red;
    }
  }

  factory CourseResultModel.fromMap(Map<String, dynamic> row) {
    return CourseResultModel(
      courseName: row['course_name'] as String,
      grade:      row['grade']       as int,
      gpaPoints:  (row['gpa_points'] as num).toDouble(),
      letter:     row['letter']      as String,
    );
  }
}
