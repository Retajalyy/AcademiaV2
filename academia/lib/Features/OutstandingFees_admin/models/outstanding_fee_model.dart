import 'package:flutter/material.dart';

class OutstandingFeeStudent {
  final int         id;               // students.id
  final List<int>   feeIds;           // all unpaid student_fees.id for this student
  final List<int>   unremindedFeeIds; // fee ids where isDueSoon && !reminder_sent
  final String      name;
  final String      uniId;
  final String      faculty;
  final String      major;
  final int         level;
  final String      groupLabel;
  final double      totalAmount;      // sum of all unpaid fees
  final DateTime    nearestDueDate;   // earliest unpaid due_date
  final String?     avatarUrl;

  const OutstandingFeeStudent({
    required this.id,
    required this.feeIds,
    required this.unremindedFeeIds,
    required this.name,
    required this.uniId,
    required this.faculty,
    required this.major,
    required this.level,
    required this.groupLabel,
    required this.totalAmount,
    required this.nearestDueDate,
    this.avatarUrl,
  });

  // ── Computed ────────────────────────────────────────────────────────────────

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty
        ? name.substring(0, name.length.clamp(0, 2)).toUpperCase()
        : '??';
  }

  String get majorBadge  => groupLabel.isNotEmpty ? groupLabel : '$major$level';
  String get facultyBadge => faculty;

  int  get daysUntilDue          => nearestDueDate.difference(DateTime.now()).inDays;
  bool get isOverdue             => daysUntilDue < 0;
  bool get isDueSoon             => !isOverdue && daysUntilDue <= 10;
  bool get needsReminder         => unremindedFeeIds.isNotEmpty;
  // Overdue by more than 7 days → blocked from registration, skip entirely
  bool get isRegistrationBlocked => daysUntilDue < -7;

  String get dueDateLabel {
    const m = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${m[nearestDueDate.month]} ${nearestDueDate.day}';
  }

  String get dueDateStatus {
    if (isOverdue) {
      final d = daysUntilDue.abs();
      return 'Overdue · $d day${d == 1 ? '' : 's'}';
    }
    return 'Due $dueDateLabel';
  }

  String get amountLabel {
    final s = totalAmount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return 'EGP $s';
  }

  int get feeCount => feeIds.length;

  Color get avatarColor {
    switch (faculty) {
      case 'FCI': return const Color(0xFF0C4D83);
      case 'FBA': return const Color(0xFFFFC258);
      case 'FLT': return const Color(0xFF3E6584);
      default:    return const Color(0xFF0C4D83);
    }
  }

  Color get facultyBadgeColor {
    switch (faculty) {
      case 'FCI': return const Color(0xFF1565C0);
      case 'FBA': return const Color(0xFFE65100);
      case 'FLT': return const Color(0xFF2E7D32);
      default:    return const Color(0xFF546E7A);
    }
  }
}
