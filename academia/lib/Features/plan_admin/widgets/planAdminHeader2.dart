import 'package:flutter/material.dart';
import '../../../Core/utilities/colors.dart';
import 'package:academia/Core/widgets/Architecture_progress.dart';
import 'package:academia/Features/plan_admin/screens/PlanAdminScreen.dart';

class PlanHeader2 extends StatelessWidget {
  final int currentStep;

  const PlanHeader2({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 14,
        left: 16,
        right: 16,
        bottom: 22,
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
                      builder: (_) => const Planadminscreen1(),
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

          /// CENTER TITLE (SEPARATE LINE)
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
    );
  }
}