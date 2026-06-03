import 'package:flutter/material.dart';

class StudentAdminModel {
  final int     id;
  final String  uniId;
  final String  name;
  final String  faculty;
  final String  major;
  final int     level;
  final String  phone;
  final String? avatarUrl;
  final String  groupLabel;
  final double  gpa;

  StudentAdminModel({
    required this.id,
    required this.uniId,
    required this.name,
    required this.faculty,
    required this.major,
    required this.level,
    required this.phone,
    this.avatarUrl,
    required this.groupLabel,
    required this.gpa,
  });

  factory StudentAdminModel.fromMap(Map<String, dynamic> row) {
    final profile = row['profiles'] as Map<String, dynamic>;
    final name    = profile['full_name'] as String?
        ?? '${profile['fname']} ${profile['lname']}';

    // Latest registration group — handle Map or List return from PostgREST
    final regsRaw = row['student_registrations'];
    final regs = regsRaw is List
        ? regsRaw
        : (regsRaw is Map ? [regsRaw] : <dynamic>[]);
    String groupLabel = '';
    if (regs.isNotEmpty) {
      final grp = regs.last['registration_groups'];
      if (grp is Map) groupLabel = grp['label'] as String? ?? '';
    }

    // Average GPA — handle Map or List return
    final semsRaw = row['semester_results'];
    final sems = semsRaw is List
        ? semsRaw
        : (semsRaw is Map ? [semsRaw] : <dynamic>[]);
    double gpa = 0;
    final gpas = sems
        .map((s) => (s['gpa'] as num?)?.toDouble())
        .whereType<double>()
        .toList();
    if (gpas.isNotEmpty) {
      gpa = gpas.reduce((a, b) => a + b) / gpas.length;
    }

    return StudentAdminModel(
      id:         row['id']          as int,
      uniId:      profile['uni_id']  as String? ?? '',
      name:       name,
      faculty:    row['faculty']     as String? ?? '',
      major:      row['major']       as String? ?? '',
      level:      (row['level']      as int?) ?? 1,
      phone:      row['phone']       as String? ?? '',
      avatarUrl:  row['avatar_url']  as String?,
      groupLabel: groupLabel,
      gpa:        double.parse(gpa.toStringAsFixed(2)),
    );
  }

  // ── Computed ──────────────────────────────────────────────────────────────
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, 2).toUpperCase();
  }

  String get majorBadge   => '$major$level';  // e.g. "SE4"
  String get facultyBadge => faculty;          // e.g. "FCI"
  String get gpaStr       => gpa.toStringAsFixed(1);

  Color get gpaColor {
    if (gpa >= 3.5) return const Color(0xFF2E7D32);
    if (gpa >= 2.5) return const Color(0xFFE65100);
    return const Color(0xFFC62828);
  }

  Color get avatarColor {
    final colors = [
      const Color(0xFF1565C0),
      const Color(0xFF2E7D32),
      const Color(0xFF6A1B9A),
      const Color(0xFF00695C),
      const Color(0xFF37474F),
      const Color(0xFFAD1457),
    ];
    return colors[name.codeUnitAt(0) % colors.length];
  }

  Color get facultyBadgeColor {
    switch (faculty) {
      case 'FCI': return const Color(0xFF1565C0);
      case 'FBA': return const Color(0xFFE65100);
      case 'FLT': return const Color(0xFF2E7D32);
      default:    return const Color(0xFF546E7A);
    }
  }

  Color get majorBadgeColor {
    switch (faculty) {
      case 'FCI': return const Color(0xFF1976D2);
      case 'FBA': return const Color(0xFFF57C00);
      case 'FLT': return const Color(0xFF388E3C);
      default:    return const Color(0xFF607D8B);
    }
  }
}
