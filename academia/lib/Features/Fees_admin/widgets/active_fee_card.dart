// lib/Features/fees_admin/widgets/active_fee_card.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../controller/fee_admin_controller.dart';
import '../model/fee_admin_model.dart';

class ActiveFeesContainer extends StatelessWidget {
  const ActiveFeesContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<FeesAdminController>();

    return Obx(() {
      final fees = c.activeFees;

      if (fees.isEmpty) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: fees.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey.shade200,
          ),
          itemBuilder: (context, index) {
            return _FeeItem(fee: fees[index]);
          },
        ),
      );
    });
  }
}

class _FeeItem extends StatelessWidget {
  final ActiveFeeModel fee;

  const _FeeItem({required this.fee});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── TOP ROW ─────────────────────────────────────────────────────
          Row(
            children: [
              // ICON
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.bluegroundicon,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  fee.icon,
                  size: 23,
                  color: AppColors.accentProgramming1,
                ),
              ),

              const SizedBox(width: 10),

              // TITLE + SUBTITLE
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fee.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      fee.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.smalltext,
                      ),
                    ),
                  ],
                ),
              ),

              // AMOUNT
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text:
                          "${fee.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} ",
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const TextSpan(
                      text: "EGP",
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.smalltext,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── PROGRESS LABEL ───────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Collection progress",
                style: TextStyle(fontSize: 13, color: AppColors.smalltext),
              ),
              Text(
                fee.progressText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // ── PROGRESS BAR ─────────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: fee.progress,
              minHeight: 7,
              backgroundColor: AppColors.greytext,
              borderRadius: BorderRadius.circular(8),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primaryBlue,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ── DUE DATE ─────────────────────────────────────────────────────
          Row(
            children: [
              Icon(
                fee.isOverdue
                    ? Icons.error_outline
                    : Icons.access_time_outlined,
                size: 15,
                color: fee.isOverdue ? AppColors.fail : AppColors.smalltext,
              ),
              const SizedBox(width: 4),
              Text(
                fee.dueDateLabel,
                style: TextStyle(
                  fontSize: 12,
                  color: fee.isOverdue ? AppColors.fail : AppColors.smalltext,
                  fontWeight:
                      fee.isOverdue ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}