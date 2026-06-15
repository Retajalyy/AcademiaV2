import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:academia/Core/utilities/colors.dart';
import 'package:academia/Features/Fees/screens/FeesScreen.dart';
import 'package:academia/Features/Payement/model/payement_status_model.dart';
import 'package:academia/Features/Payement/widgets/PayementStatusHeader.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final PaymentStatusModel status;

  const PaymentSuccessScreen({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.babyblue,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// 🔵 HEADER
              const PayementStatusHeader(),

              const SizedBox(height: 60),

              /// 🔵 TWO CIRCLES ONLY
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: status.isSuccess
                      ? AppColors.darkGreen.withOpacity(0.15)
                      : AppColors.fail.withOpacity(0.15),
                ),
                child: Center(
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: status.isSuccess
                          ? AppColors.darkGreen
                          : AppColors.fail,
                    ),
                    child: Center(
                      child: Icon(
                        status.isSuccess
                            ? Icons.check
                            : Icons.warning_amber_rounded,
                        color: Colors.white,
                        size: 45,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              /// 🔵 MESSAGE (DYNAMIC COLOR)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  status.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                    color: status.isSuccess
                        ? AppColors.darkGreen
                        : AppColors.fail,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              /// 🔵 SUBTEXT
              if (status.transactionId != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Your transaction has been processed",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      color: status.isSuccess
                          ? AppColors.textgrey
                          : AppColors.fail.withOpacity(0.8),
                    ),
                  ),
                ),

              const SizedBox(height: 40),

              /// 🔵 DONE BUTTON
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.offAll(() => const FeesScreen()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}