import 'package:flutter/material.dart';

class CourseScheduleGroupModel {
  final int id;
  final String label;
  final String majorCode;
  final String majorName;
  final String facultyCode;
  final String facultyName;
  final int level;
  final int courseCount;

  const CourseScheduleGroupModel({
    required this.id,
    required this.label,
    required this.majorCode,
    required this.majorName,
    required this.facultyCode,
    required this.facultyName,
    required this.level,
    required this.courseCount,
  });

  Color get facultyColor {
    switch (facultyCode) {
      case 'FCI': return const Color(0xFF0C4D83);
      case 'FBA': return const Color(0xFFB18334);
      case 'FLT': return const Color(0xFF2E7D32);
      default:    return const Color(0xFF546E7A);
    }
  }
}

// One session = one lecture OR one section slot for a course on a given day.
class CourseSessionModel {
  final String courseName;
  final String startTime;   // "8:00"
  final String endTime;     // "9:30"
  final String instructor;
  final String room;
  final String type;        // 'Lecture' | 'Section'

  const CourseSessionModel({
    required this.courseName,
    required this.startTime,
    required this.endTime,
    required this.instructor,
    required this.room,
    required this.type,
  });

  static String fmtTime(String? raw) {
    if (raw == null || raw.length < 5) return '';
    final parts = raw.substring(0, 5).split(':');
    final hour  = int.tryParse(parts[0]) ?? 0;
    final min   = parts.length > 1 ? parts[1] : '00';
    return '$hour:$min'; // "08:30" → "8:30"
  }
}
