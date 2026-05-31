import 'package:flutter/material.dart';

class FacultyAdminModel {
  final String       code;
  final String       name;
  final List<String> majorNames;
  final int          studentCount;
  final int          instructorCount;
  final int          courseCount;

  const FacultyAdminModel({
    required this.code,
    required this.name,
    required this.majorNames,
    required this.studentCount,
    required this.instructorCount,
    required this.courseCount,
  });

  IconData get icon {
    switch (code) {
      case 'FCI': return Icons.computer_outlined;
      case 'FBA': return Icons.bar_chart_outlined;
      case 'FLT': return Icons.translate_outlined;
      default:    return Icons.account_balance_outlined;
    }
  }

  Color get color {
    switch (code) {
      case 'FCI': return const Color(0xFF0C4D83);
      case 'FBA': return const Color(0xFFB18334);
      case 'FLT': return const Color(0xFF2E7D32);
      default:    return const Color(0xFF546E7A);
    }
  }
}
