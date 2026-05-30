// lib/Features/registration/widgets/semester_card.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../controller/registiration_controller.dart';

class SemesterCard extends StatelessWidget {
  final String planId;
  final String title;
  final String faculty;
  final double progress;
  final String progressText;
  final String courses;
  final String enrolled;
  final String groups;
  final String openDate;
  final String closeDate;
  final bool   isActive;

  const SemesterCard({
    super.key,
    required this.planId,
    required this.title,
    required this.faculty,
    required this.progress,
    required this.progressText,
    required this.courses,
    required this.enrolled,
    required this.groups,
    required this.openDate,
    required this.closeDate,
    required this.isActive,
  });

  void _showEditDialog(BuildContext context) {
    final ctrl  = Get.find<RegistrationController>();
    final parts = title.split(' · ');
    final semCtrl  = TextEditingController(text: parts.isNotEmpty ? parts[0] : '');
    final yearCtrl = TextEditingController(text: parts.length > 1 ? parts[1] : '');

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Plan Labels'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: semCtrl,
              decoration: const InputDecoration(labelText: 'Semester Label'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: yearCtrl,
              decoration: const InputDecoration(labelText: 'Academic Year'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ctrl.updatePlanLabels(
                  planId, semCtrl.text.trim(), yearCtrl.text.trim());
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<RegistrationController>();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row: title + edit button ──────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      faculty,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.smalltext,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showEditDialog(context),
                icon: const Icon(Icons.edit_outlined, size: 20),
                color: AppColors.smalltext,
                tooltip: 'Edit labels',
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              const Text(
                "Overall enrollment",
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.smalltext,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                progressText,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 8,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.greytext,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(child: _InfoBox(value: courses, label: "Courses")),
              const SizedBox(width: 10),
              Expanded(child: _InfoBox(value: enrolled, label: "Enrolled")),
              const SizedBox(width: 10),
              Expanded(child: _InfoBox(value: groups,   label: "Groups")),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _DateBox(label: "Opened", date: openDate),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DateBox(label: "Closes", date: closeDate, dateIsRed: true),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Status toggle button ──────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: Obx(() {
              final loading = ctrl.isActionLoading.value;
              final open    = _resolveIsActive(ctrl);
              return OutlinedButton.icon(
                onPressed: loading
                    ? null
                    : () => ctrl.togglePlanStatus(planId),
                icon: Icon(
                  open ? Icons.lock_outline : Icons.lock_open_outlined,
                  size: 18,
                ),
                label: Text(open ? 'Close Registration' : 'Open Registration'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: open ? AppColors.fail : AppColors.darkGreen,
                  side: BorderSide(
                    color: open ? AppColors.fail : AppColors.darkGreen,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  bool _resolveIsActive(RegistrationController ctrl) {
    try {
      return ctrl.activePlans.firstWhere((p) => p.id == planId).isActive;
    } catch (_) {
      return isActive;
    }
  }
}

class _DateBox extends StatelessWidget {
  final String label;
  final String date;
  final bool   dateIsRed;

  const _DateBox({required this.label, required this.date, this.dateIsRed = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5F7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.smalltext,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            date,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: dateIsRed ? AppColors.fail : AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String value;
  final String label;

  const _InfoBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF4FC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.smalltext,
            ),
          ),
        ],
      ),
    );
  }
}
