// lib/Features/fees_admin/service/fee_admin_service.dart

import 'package:flutter/material.dart';
import '../model/fee_admin_model.dart';

class FeesAdminService {
  Future<FeesSummaryModel> fetchSummary() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const FeesSummaryModel(
      semester: "Semester 7 · Fall 2025 · All Faculties",
      paid: 2806,
      progress: "72%",
      unpaid: 34,
      collectedRaw: 1246000,
      totalRaw: 1734000,
    );
  }

  Future<List<ActiveFeeModel>> fetchActiveFees() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const [
      ActiveFeeModel(
        id: 'fee_001',
        title: "Semester Fee",
        subtitle: "Computers & Info · All Levels",
        amount: 17000,
        progress: 0.78,
        progressText: "78%",
        dueDate: "April 20, 2026",
        isOverdue: true,
        dueDateLabel: "Due April 20, 2026 — 8 days left",
        icon: Icons.menu_book_outlined,
      ),
      ActiveFeeModel(
        id: 'fee_002',
        title: "Semester Fee",
        subtitle: "Business Administration · All Levels",
        amount: 14000,
        progress: 0.91,
        progressText: "91%",
        dueDate: "April 30, 2026",
        isOverdue: false,
        dueDateLabel: "Due April 30, 2026",
        icon: Icons.menu_book_outlined,
      ),
      ActiveFeeModel(
        id: 'fee_003',
        title: "Graduation Project Fee",
        subtitle: "All Faculties · Level 4",
        amount: 500,
        progress: 0.21,
        progressText: "21%",
        dueDate: "April 30, 2026",
        isOverdue: false,
        dueDateLabel: "Due April 30, 2026",
        icon: Icons.school_outlined,
      ),
    ];
  }

  Future<bool> submitFee(AddFeeFormModel form) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return true;
  }

  Future<bool> remindUnpaid() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }
}