import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/registration_controller.dart';
import '../models/registration_model.dart';

/// Shown when registration is closed.
/// Matches Image 2: lock icon, "Registration is now closed", info table.
class RegistrationClosedWidget extends StatelessWidget {
  const RegistrationClosedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<RegistrationController>();

    return Obx(() {
      if (ctrl.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(48),
            child: CircularProgressIndicator(color: Color(0xFF1A6EFF)),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          _LockIcon(),
          const SizedBox(height: 24),
          const Text(
            'Registration is now closed',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'The registration window for Semester B has\nclosed. You can no longer add or change\ncourses for this semester.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          if (ctrl.semesterInfo.value != null)
            _SemesterInfoTable(info: ctrl.semesterInfo.value!),
        ],
      );
    });
  }
}

// ── Lock Icon ─────────────────────────────────────────────────────────────────

class _LockIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFF3F4F6),
      ),
      child: const Icon(
        Icons.lock_outline_rounded,
        size: 38,
        color: Color(0xFF9CA3AF),
      ),
    );
  }
}

// ── Semester Info Table ────────────────────────────────────────────────────────

class _SemesterInfoTable extends StatelessWidget {
  final SemesterInfo info;
  const _SemesterInfoTable({required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _InfoRow(
            label: 'Semester',
            value: '${info.semester} · ${info.year}',
          ),
          _Divider(),
          _InfoRow(
            label: 'Registration open',
            value: info.registrationOpen,
          ),
          _Divider(),
          _InfoRow(
            label: 'Registration closed',
            value: info.registrationClosed,
            valueColor: const Color(0xFFEF4444),
          ),
          _Divider(),
          _InfoRow(
            label: 'Semester starts',
            value: info.semesterStart,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 20, endIndent: 20);
  }
}