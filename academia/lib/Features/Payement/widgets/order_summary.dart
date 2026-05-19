import 'package:flutter/material.dart';
import 'package:academia/Core/utilities/colors.dart';
import 'package:academia/Features/Payement/model/order_summary_model.dart';

class OrderSummary extends StatelessWidget {
  final OrderSummaryModel model;

  const OrderSummary({super.key, required this.model});

  Widget _row({
    required String left,
    required String right,
    TextStyle? leftStyle,
    TextStyle? rightStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(left, style: leftStyle),
          const Spacer(),
          Text(right, style: rightStyle),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ORDER SUMMARY',
          style: TextStyle(
            color: AppColors.textgrey,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _row(
                left: 'Fee',
                right: model.fee,
                leftStyle: const TextStyle(
                    color: Color(0xFF848282),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter'),
                rightStyle: const TextStyle(
                    color: AppColors.accentProgramming1,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter'),
              ),
              _row(
                left: 'Semester',
                right: model.semester,
                leftStyle: const TextStyle(
                    color: Color(0xFF848282),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter'),
                rightStyle: const TextStyle(
                    color: AppColors.accentProgramming1,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter'),
              ),
              const Divider(),
              _row(
                left: 'Total',
                right:
                    '${model.totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} EGP',
                leftStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 15),
                rightStyle: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ],
          ),
        ),
      ],
    );
  }
}