import 'package:academia/Features/Payement/widgets/pay.dart';
import 'package:flutter/material.dart';
import 'package:academia/Features/Payement/widgets/PayementHeader.dart';
import '../../../Core/utilities/colors.dart';
import 'package:academia/Features/Payement/widgets/payment_method.dart';
import 'package:academia/Features/Payement/widgets/card_details.dart';
import 'package:academia/Features/Payement/widgets/order_summary.dart';
import 'package:get/get.dart';
import 'package:academia/Features/Payement/controller/payement_controller.dart';

class PayementScreen extends StatelessWidget {
  const PayementScreen({super.key});

  @override
  Widget build(BuildContext context) {
  final PaymentController ctrl = Get.put(PaymentController());

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: SafeArea(
        child: Column(
          children: [
            /// 🔵 HEADER
            const PayementHeader(),

            /// 🔵 BODY
              Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.babyblue,
                ),
                child:  SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column( // ✅ wrap in Column
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PaymentMethodCard(),
                      SizedBox(height: 20),
                       CardDetailsForm(
                        onCardNumberChanged: ctrl.updateCardNumber,
                        onExpiryChanged:     ctrl.updateExpiry,
                        onCvvChanged:        ctrl.updateCvv,
                        onNameChanged:       ctrl.updateName,
                      ),
                      const SizedBox(height: 20),
                      Obx(() => OrderSummary(model: ctrl.orderSummary.value)),
                      const SizedBox(height: 20),
                      Obx(
                        () => PayButton(
                          isLoading: ctrl.isLoading.value,
                          totalAmount: ctrl.orderSummary.value.totalAmount,
                          onPressed: ctrl.pay,
                        ),
                      ),

                    ],
                  ),
              ),
             ),
            ),
          ],
        ),
      ),
    );
  }
}
