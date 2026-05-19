import 'package:flutter/material.dart';
import '../../../Core/utilities/colors.dart';
import '../controllers/fees_controller.dart';
import 'package:academia/Features/Payement/screens/PayementScreen.dart';

class PayButton extends StatelessWidget {
  final FeesController ctrl;
  const PayButton({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PayementScreen()),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.babyblue,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
          ),
        ),
        child: Text(
          "Pay outstanding ${ctrl.formattedOutstanding}",
          style: const TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
