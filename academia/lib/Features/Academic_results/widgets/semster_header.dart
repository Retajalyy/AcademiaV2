import 'package:flutter/material.dart';
import '../../../Core/utilities/colors.dart';

class SemesterHeaderRow extends StatelessWidget {
  final String label;
  const SemesterHeaderRow({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 27,
            width: 27,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Icon(Icons.arrow_back, size: 21, color: AppColors.primaryBlue),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
