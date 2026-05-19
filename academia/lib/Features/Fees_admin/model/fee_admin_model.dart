// lib/Features/fees_admin/model/fee_admin_model.dart

import 'package:flutter/material.dart';

// ─── Fee Type Enum ────────────────────────────────────────────────────────────

enum FeeType { semesterFee, labFee, other }

extension FeeTypeExtension on FeeType {
  String get label {
    switch (this) {
      case FeeType.semesterFee:
        return "Semester Fee";
      case FeeType.labFee:
        return "Lab Fee";
      case FeeType.other:
        return "Other";
    }
  }
}

// ─── Summary Model ────────────────────────────────────────────────────────────

class FeesSummaryModel {
  final String semester;
  final int paid;
  final String progress;
  final int unpaid;
  final double collectedRaw;  // e.g. 1246000
  final double totalRaw;      // e.g. 1734000

  const FeesSummaryModel({
    required this.semester,
    required this.paid,
    required this.progress,
    required this.unpaid,
    required this.collectedRaw,
    required this.totalRaw,
  });
}

// ─── Active Fee Model ─────────────────────────────────────────────────────────

class ActiveFeeModel {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final double progress;
  final String progressText;
  final String dueDate;
  final bool isOverdue;
  final String dueDateLabel;
  final IconData icon;

  const ActiveFeeModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.progress,
    required this.progressText,
    required this.dueDate,
    required this.isOverdue,
    required this.dueDateLabel,
    required this.icon,
  });
}

// ─── Add Fee Form Model ───────────────────────────────────────────────────────

class AddFeeFormModel {
  final FeeType? feeType;
  final String amount;
  final String? faculty;
  final String? level;
  final DateTime? dueDate;

  const AddFeeFormModel({
    this.feeType,
    this.amount = '',
    this.faculty,
    this.level,
    this.dueDate,
  });
}