import 'package:academia/Core/utilities/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:academia/Core/widgets/notification_bell.dart';
import '../controllers/registration_controller.dart';

class RegistrationAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RegistrationAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(175);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<RegistrationController>();

    return Container(
      color: AppColors.primaryBlue,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const NotificationBell(),
                ],
              ),
            ),

            // ── Title + subtitle ──────────────────────────────────────────
            const Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Registration',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Enroll in and manage your courses',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFDEDEDE),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Group tabs ────────────────────────────────────────────────
            Obx(() {
              final groups = ctrl.availableGroups;
              if (groups.isEmpty) return const SizedBox(height: 20);
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Row(
                  children: groups.asMap().entries.map((entry) {
                    final i = entry.key;
                    return Padding(
                      padding: EdgeInsets.only(
                          right: i < groups.length - 1 ? 28 : 0),
                      child: _GroupTab(
                        label: entry.value.label,
                        isSelected: ctrl.selectedTabIndex.value == i,
                        onTap: () => ctrl.onTabChanged(i),
                      ),
                    );
                  }).toList(),
                ),
              );
            }),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _GroupTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GroupTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF6B7A9F),
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 3,
            width: isSelected ? 70 : 0,
            decoration: BoxDecoration(
              color: AppColors.secondaryYellow,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
