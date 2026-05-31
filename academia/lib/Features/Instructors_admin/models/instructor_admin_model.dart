import 'package:academia/Core/utilities/colors.dart';
import 'package:flutter/material.dart';

class InstructorAdminModel {
  final int          id;
  final String       uniId;
  final String       name;
  final String       department; // faculty code e.g. FCI
  final String       role;       // 'Professor' | 'T.A.'
  final List<String> courses;
  final List<String> groups;
  final List<String> majors;

  const InstructorAdminModel({
    required this.id,
    required this.uniId,
    required this.name,
    required this.department,
    required this.role,
    required this.courses,
    required this.groups,
    required this.majors,
  });

  factory InstructorAdminModel.fromMap(Map<String, dynamic> row) {
    final profile = row['profiles'] as Map<String, dynamic>;
    final name    = profile['full_name'] as String?
        ?? '${profile['fname']} ${profile['lname']}';

    final sections = row['sections'] as List? ?? [];

    // Role: Professor if they have any Lecture section, else T.A.
    final hasLecture = sections.any((s) =>
        (s['type'] as String?)?.toLowerCase() == 'lecture');
    final role = hasLecture ? 'Professor' : 'T.A.';

    // Unique course names
    final courses = sections
        .map((s) {
          final c = s['courses'];
          return c is Map ? c['name'] as String? : null;
        })
        .whereType<String>()
        .toSet()
        .toList();

    // Unique group short labels
    final groups = <String>{};
    for (final s in sections) {
      final rgsList = s['registration_group_sections'] as List? ?? [];
      for (final rgs in rgsList) {
        final grp = rgs['registration_groups'];
        if (grp is Map) {
          final major = grp['major'] as String? ?? '';
          final level = grp['level']?.toString() ?? '';
          final label = grp['label'] as String? ?? '';
          // Extract suffix (A/B) from label e.g. "Group FCI-CS-4-A" → "A"
          final suffix = label.isNotEmpty ? label[label.length - 1] : '';
          final short  = '$major$level$suffix';
          if (short.length > 1) groups.add(short);
        }
      }
    }

    return InstructorAdminModel(
      id:         row['id']         as int,
      uniId:      profile['uni_id'] as String? ?? '',
      name:       name,
      department: row['department'] as String? ?? '',
      role:       role,
      courses:    courses,
      groups:     groups.toList(),
      majors:     [],
    );
  }

  // ── Computed ──────────────────────────────────────────────────────────────
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, 2).toUpperCase();
  }

  Color get avatarColor {
    final colors = [
      AppColors.accentProgramming1, const Color(0xFF6A1B9A),
      const Color(0xFF2E7D32), const Color(0xFF00695C),
      const Color(0xFFAD1457), const Color(0xFF37474F),
    ];
    return colors[name.codeUnitAt(0) % colors.length];
  }

  Color get roleColor =>
      role == 'Professor' ? AppColors.accentProgramming1 : const Color(0xFFE65100);

  Color get deptColor {
    switch (department) {
      case 'FCI': return AppColors.accentProgramming1;
      case 'FBA': return const Color(0xFFE65100);
      case 'FLT': return AppColors.assignmentColor;
      default:    return const Color(0xFF546E7A);
    }
  }
}
