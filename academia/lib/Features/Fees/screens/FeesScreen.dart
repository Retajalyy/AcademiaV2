import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:academia/Core/widgets/shared_bottom_nav.dart';
import '../controllers/fees_controller.dart';
import '../widgets/Fees_headr.dart';
import '../widgets/DueFee_card.dart';
import '../widgets/Paid_Fees.dart';
import '../widgets/pay_button.dart';
import '../../../Core/utilities/colors.dart';

class Feesscreen extends StatelessWidget {
  const Feesscreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(FeesController());

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pushReplacementNamed(context, '/services');
      },
      child: Scaffold(
        backgroundColor: AppColors.primaryBlue,
        bottomNavigationBar: const SharedBottomNav(),
        body: SafeArea(
          child: Obx(() {
            if (ctrl.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            return Column(
              children: [
                FeesHeader(ctrl: ctrl),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(color: AppColors.babyblue),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (ctrl.dueFees.isNotEmpty) ...[
                            DueFeeCard(fees: ctrl.dueFees),
                            const SizedBox(height: 20),
                          ],
                          if (ctrl.paidFees.isNotEmpty) ...[
                            PaidFeeCard(fees: ctrl.paidFees),
                            const SizedBox(height: 20),
                          ],
                          if (ctrl.dueFees.isNotEmpty)
                            PayButton(ctrl: ctrl),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
