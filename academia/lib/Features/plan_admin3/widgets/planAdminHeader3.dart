import 'package:flutter/material.dart';
import '../../../Core/utilities/colors.dart';
import 'package:academia/Core/widgets/Architecture_progress.dart';
import 'package:academia/Features/plan_admin2/screens/PlanAdmin2Screen .dart';

class PlanHeader3 extends StatelessWidget {
  final int currentStep;

  const PlanHeader3({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// BLUE HEADER CONTAINER
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
                  /// TOP ROW (BACK BUTTON ONLY)
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

                  /// CENTER TITLE
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

                  /// PROGRESS BAR
                  ArchitectureProgress(
                    currentStep: currentStep,
                  ),
                ],
              ),
            ),

            /// SE TABS — overlapping the bottom edge of the blue container
            Positioned(
              bottom: -24,
              left: 16,
              child: Row(
                children: [
                  _SETab(label: 'SE1', isActive: true),
                  const SizedBox(width: 40),
                  _SETab(label: 'SE2', isActive: false),
                  const SizedBox(width: 40),
                  _SETab(label: 'SE3', isActive: false),
                ],
              ),
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

  const _SETab({
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.accentAI : Color(0XFF87A8C4),
            fontSize: 17,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        /// yellow underline aligns with bottom of blue container
        Container(
          height: 3,
          width: 50,
          color: isActive ? AppColors.accentAI : Colors.transparent,
        ),
      ],
    );
  }
}