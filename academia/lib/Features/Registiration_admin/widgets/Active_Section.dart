// lib/Features/Registiration_admin/widgets/Active_Section.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../controller/registiration_controller.dart';
import 'semster_card.dart';

class ActivePlansSection extends StatelessWidget {
  const ActivePlansSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RegistrationController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              "ACTIVE PLANS",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.smalltext,
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
              ),
              child: const Text(
                "View all >",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        /// Reactive list — rebuilds only when activePlans changes
        Obx(() {
          final plans = controller.activePlans;

          if (plans.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  "No active plans",
                  style: TextStyle(color: AppColors.smalltext),
                ),
              ),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: plans.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final plan = plans[index];
              return SemesterCard(
                title: plan.title,
                faculty: plan.faculty,
                progress: plan.progress,
                progressText: plan.progressText,
                courses: plan.courses,
                enrolled: plan.enrolled,
                groups: plan.groups,
                openDate: plan.openDate,
                closeDate: plan.closeDate,
              );
            },
          );
        }),
      ],
    );
  }
}