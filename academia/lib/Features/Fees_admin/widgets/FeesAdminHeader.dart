// lib/Features/fees_admin/widgets/fees_header.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../controller/fee_admin_controller.dart';

class FeesAdminHeader extends StatelessWidget {
  const FeesAdminHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<FeesAdminController>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
      ),
      child: Obx(() {
        if (c.isLoading.value || c.summary.value == null) {
          return const SizedBox(
            height: 140,
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        final s = c.summary.value!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── TOP ROW ───────────────────────────────────────────────────
            Row(
              children: [
                Builder(
                  builder: (ctx) => GestureDetector(
                    onTap: () => Scaffold.of(ctx).openDrawer(),
                    child: const Icon(
                      Icons.menu,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Fees & Payments",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Manage semester fees",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0XFFDEDEDE),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ── STATS CARD ─────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // TOTAL COLLECTED LABEL + REMIND BUTTON
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "TOTAL\nCOLLECTED",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0XFFDEDEDE),
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),

                      Obx(() => GestureDetector(
                            onTap:
                                c.isReminding.value ? null : c.remindUnpaid,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: const Color(0XFF296292),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.accentAI,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.notifications_outlined,
                                    color: AppColors.accentAI,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    c.isReminding.value
                                        ? "Sending..."
                                        : "Remind Unpaid",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // ✅ LIVE TOTAL COLLECTED
                  Obx(() => Text(
                        c.liveTotalCollectedFormatted,
                        style: const TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      )),

                  const SizedBox(height: 2),

                  Text(
                    s.semester,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0XFFDEDEDE),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // PAID / PROGRESS / UNPAID
                  Row(
                    children: [
                      const SizedBox(width: 25),
                      _StatChip(label: "Paid", value: s.paid.toString()),
                      const SizedBox(width: 60),
                      _StatChip(label: "Progress", value: s.progress),
                      const SizedBox(width: 60),
                      _StatChip(label: "Unpaid", value: s.unpaid.toString()),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ✅ LIVE PROGRESS BAR
                  Obx(() => ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: c.liveProgress,
                          minHeight: 8,
                          backgroundColor: const Color(0XFFE5E7EB),
                          borderRadius: BorderRadius.circular(20),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.accentAI,
                          ),
                        ),
                      )),

                  const SizedBox(height: 8),

                  // ✅ LIVE DETAIL TEXT
                  Obx(() => Center(
                        child: Text(
                          c.liveCollectedDetailFormatted,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0XFFDEDEDE),
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0XFFDEDEDE),
          ),
        ),
      ],
    );
  }
}