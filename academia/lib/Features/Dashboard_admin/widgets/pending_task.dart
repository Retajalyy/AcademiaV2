import 'package:academia/Core/utilities/colors.dart';
import 'package:academia/Features/Dashboard_admin/controller/dashboard_controller.dart';
import 'package:academia/Features/Dashboard_admin/model/dashboard_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/text_style.dart';
import 'pending_task_card.dart';

class PendingTasksSection extends StatelessWidget {
  const PendingTasksSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pending Tasks',
            style: TextStyles.title.copyWith(color: Colors.black),
          ),
          const SizedBox(height: 14),

          Obx(() => Column(
            children: controller.pendingTasks
                .map((task) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildCard(task),
                    ))
                .toList(),
          )),
        ],
      ),
    );
  }

  Widget _buildCard(PendingTaskModel task) {
    switch (task.type) {
      case 'warn':
        return PendingTaskCard(
          icon: Icons.warning_amber_rounded,
          title: task.title,
          subtitle: task.subtitle,
          buttonText: 'Warn',
          leftBarColor: AppColors.accentAI,
          iconBgColor: const Color(0xFFFFF3DF),
          iconColor: const Color(0xFFB18334),
          buttonColor: AppColors.accentAI,
          buttonTextColor: AppColors.accentProgramming1,
        );
      case 'block':
        return PendingTaskCard(
          icon: Icons.block_outlined,
          title: task.title,
          subtitle: task.subtitle,
          buttonText: 'Block',
          leftBarColor: AppColors.fail,
          iconBgColor: const Color(0xFFFFF2F3),
          iconColor: AppColors.fail,
          buttonColor: const Color(0xFFFFF2F3),
          buttonTextColor: AppColors.fail,
        );
      default: // 'notify'
        return PendingTaskCard(
          icon: Icons.credit_card_outlined,
          title: task.title,
          subtitle: task.subtitle,
          buttonText: 'Notify',
          leftBarColor: AppColors.accentAI,
          iconBgColor: const Color(0xFFFFF3DF),
          iconColor: const Color(0xFFB18334),
          buttonColor: AppColors.accentAI,
          buttonTextColor: AppColors.accentProgramming1,
        );
    }
  }
}