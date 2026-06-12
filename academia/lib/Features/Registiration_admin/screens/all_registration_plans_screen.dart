import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../controller/registiration_controller.dart';
import '../widgets/semster_card.dart';

class AllRegistrationPlansScreen extends StatelessWidget {
  const AllRegistrationPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RegistrationController>();

    return Scaffold(
      backgroundColor: AppColors.babyblue,
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            color: AppColors.primaryBlue,
            padding: const EdgeInsets.fromLTRB(16, 54, 16, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: Get.back,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chevron_left_rounded,
                          color: Colors.white70, size: 28),
                      Text('Registration',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text('Registration Plans',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Obx(() => Text(
                      '${controller.activePlans.length} plan${controller.activePlans.length == 1 ? '' : 's'} created',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 14),
                    )),
              ],
            ),
          ),

          // ── Body ─────────────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoading) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryBlue));
              }

              final plans = controller.activePlans;

              if (plans.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.event_note_outlined,
                          size: 56, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text('No registration plans yet',
                          style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 15)),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refresh,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  itemCount: plans.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (_, i) {
                    final plan = plans[i];
                    return SemesterCard(
                      planId:       plan.id,
                      title:        plan.title,
                      faculty:      plan.faculty,
                      progress:     plan.progress,
                      progressText: plan.progressText,
                      courses:      plan.courses,
                      enrolled:     plan.enrolled,
                      groups:       plan.groups,
                      openDate:     plan.openDate,
                      closeDate:    plan.closeDate,
                      isActive:     plan.isActive,
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
