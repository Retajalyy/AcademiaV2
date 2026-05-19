import 'package:flutter/material.dart';
import '../../../Core/utilities/colors.dart';
import 'package:academia/Core/utilities/text_style.dart';
import '../models/fee_model.dart';

class PaidFeeCard extends StatelessWidget {
  final List<FeeModel> fees;
  const PaidFeeCard({super.key, required this.fees});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.darkGreen,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              "PAID FEES",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppColors.mainGreen,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...fees.map((fee) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PaidFeeItem(fee: fee),
            )),
      ],
    );
  }
}

class _PaidFeeItem extends StatelessWidget {
  final FeeModel fee;
  const _PaidFeeItem({required this.fee});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: const Color(0xFFE1F5EF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.menu_book,
                    color: AppColors.darkGreen, size: 28),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fee.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        fontFamily: 'Instrument Sans',
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      "Amount paid",
                      style: TextStyles.percenatge
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      fee.formattedAmount,
                      style: const TextStyle(
                        color: AppColors.darkGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Paid",
                  style: TextStyle(
                    color: AppColors.darkGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFE5E7EB), height: 20, thickness: 1),
          Row(
            children: [
              const Icon(Icons.check_circle,
                  size: 18, color: Color(0xFFB3B3B3)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  fee.formattedPaidOn != null
                      ? "Paid on ${fee.formattedPaidOn}"
                      : "Payment confirmed",
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF848282)),
                ),
              ),
              const Icon(Icons.download,
                  size: 15, color: AppColors.primaryBlue),
              const SizedBox(width: 4),
              const Text(
                "Download invoice",
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
