import 'package:flutter/material.dart';
import 'package:academia/Core/utilities/colors.dart';
import '../controller/account_settings_controller.dart';

class UniversityInfoWidget extends StatelessWidget {
  final AccountSettingsController controller;
  const UniversityInfoWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // ✅ Read once — no Obx needed, data is already loaded before this widget shows
    final acc = controller.account.value;
    if (acc == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Info Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFDDEDFA),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline,
                size: 16,
                color: AppColors.accentProgramming1,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Name, Employee ID, and department are set\nby the university and cannot be edited.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.accentProgramming1,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'UNIVERSITY INFO',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.smalltext,
            letterSpacing: 1.2,
          ),
        ),

        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildLockedField(
                icon: Icons.person,
                fieldLabel: 'Full name',
                value: acc.fullName,
              ),
              _buildLockedField(
                icon: Icons.credit_card_outlined,
                fieldLabel: 'Employee ID',
                value: acc.employeeId,
              ),
              _buildLockedField(
                icon: Icons.account_balance,
                fieldLabel: 'Department',
                value: acc.department,
              ),
              _buildLockedField(
                icon: Icons.email,
                fieldLabel: 'University email',
                value: acc.universityEmail,
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLockedField({
    required IconData icon,
    required String fieldLabel,
    required String value,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF0EF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 25, color: const Color(0xFFB3B3B3)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fieldLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.smalltext.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.smalltext.withOpacity(0.43),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.lock_outlined,
                size: 19,
                color: AppColors.smalltext.withOpacity(0.56),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
      ],
    );
  }
}