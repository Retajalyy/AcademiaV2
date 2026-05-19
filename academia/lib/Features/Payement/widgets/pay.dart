import 'package:flutter/material.dart';
import 'package:academia/Core/utilities/colors.dart';

class PayButton extends StatelessWidget {
  final bool isLoading;
  final double totalAmount;
  final VoidCallback onPressed;

  const PayButton({
    super.key,
    required this.isLoading,
    required this.totalAmount,
    required this.onPressed,
  });

  String get _label {
    final formatted = totalAmount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return 'Pay  $formatted EGP';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.babyblue,
          disabledBackgroundColor: AppColors.babyblue.withOpacity(0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryBlue,
                ),
              )
            : Text(
                _label,
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}