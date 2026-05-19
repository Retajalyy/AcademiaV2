// lib/Features/plan_admin/widgets/planAdminHeader3.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import 'package:academia/Core/widgets/Architecture_progress.dart';
import 'package:academia/Features/plan_admin/screens/PlanAdmin2Screen .dart';
class PlanHeader3 extends StatelessWidget {
  // Changed: accepts reactive activeTab and onTabSelected from controller
  final RxString activeTab;
  final void Function(String tab) onTabSelected;

  const PlanHeader3({
    super.key,
    required this.activeTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 14,
                left: 16,
                right: 16,
                bottom: 29,
              ),
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const Planadminscreen2(),
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  const Center(
                    child: Text(
                      "New Semester Plan",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const ArchitectureProgress(currentStep: 3),
                ],
              ),
            ),

            /// SE TABS — reactive
            Positioned(
              bottom: -24,
              left: 16,
              child: Obx(() {
                return Row(
                  children: ['SE1', 'SE2', 'SE3'].map((tab) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 40),
                      child: GestureDetector(
                        onTap: () => onTabSelected(tab),
                        child: _SETab(
                          label: tab,
                          isActive: activeTab.value == tab,
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),
            ),
          ],
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}

class _SETab extends StatelessWidget {
  final String label;
  final bool isActive;

  const _SETab({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.accentAI : const Color(0XFF87A8C4),
            fontSize: 17,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 3,
          width: 50,
          color: isActive ? AppColors.accentAI : Colors.transparent,
        ),
      ],
    );
  }
}