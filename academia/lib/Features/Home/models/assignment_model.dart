import 'package:flutter/material.dart';

class Assignment {
  final String title;
  final String courseName;
  final String dueDate;  // "Today" | "Tomorrow" | "Apr 20"
  final Color color;
  final IconData icon;

  Assignment({
    required this.title,
    required this.courseName,
    required this.dueDate,
    required this.color,
    required this.icon,
  });

  factory Assignment.fromMap(Map<String, dynamic> map) {
    final section    = map['sections'];
    final assignment = (section['assignments'] as List).first;
    final course     = section['courses'];

    final type    = assignment['type'] ?? 'Assignment';
    final due     = DateTime.parse(assignment['due_date']);

    return Assignment(
      title:      assignment['title'] ?? '',
      courseName: course['name']      ?? '',
      dueDate:    _dueDateLabel(due),
      color:      _colorForType(type),
      icon:       _iconForType(type),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static String _dueDateLabel(DateTime due) {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final d     = DateTime(due.year, due.month, due.day);
    final diff  = d.difference(today).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';

    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May',
      'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[due.month]} ${due.day}';
  }

  static Color _colorForType(String type) {
    switch (type) {
      case 'Quiz':    return const Color(0xFFE67E22);
      case 'Report':  return const Color(0xFF8E44AD);
      case 'Project': return const Color(0xFF27AE60);
      default:        return const Color(0xFF2D4B94); // Assignment
    }
  }

  static IconData _iconForType(String type) {
    switch (type) {
      case 'Quiz':    return Icons.quiz_outlined;
      case 'Report':  return Icons.description_outlined;
      case 'Project': return Icons.folder_outlined;
      default:        return Icons.assignment_outlined;
    }
  }
}