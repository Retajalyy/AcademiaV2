import 'package:academia/Features/Payement/widgets/pay.dart';
import 'package:flutter/material.dart';
import 'package:academia/Features/Payement/widgets/PayementHeader.dart';
import '../../../Core/utilities/colors.dart';
import 'package:academia/Features/Payement/widgets/payment_method.dart';
import 'package:academia/Features/Payement/widgets/card_details.dart';
import 'package:academia/Features/Payement/widgets/order_summary.dart';
import 'package:get/get.dart';
import 'package:academia/Features/Payement/controller/payement_controller.dart';

class PayementScreen extends StatefulWidget {
  const PayementScreen({super.key});

  @override
  State<PayementScreen> createState() => _PayementScreenState();
}

class _PayementScreenState extends State<PayementScreen> {
  final _cardFormKey = GlobalKey<CardDetailsFormState>();
  late final PaymentController ctrl;

  @override
  void initState() {
    super.initState();
    ctrl = Get.put(PaymentController());
  }

  void _onPayPressed() {
    // Validate here in the screen, not in the controller
    final isValid = _cardFormKey.currentState?.validate() ?? false;
    if (!isValid) return;
    ctrl.pay(); // no key passed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: SafeArea(
        child: Column(
          children: [
            const PayementHeader(),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(color: AppColors.babyblue),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const PaymentMethodCard(),
                      const SizedBox(height: 20),
                      CardDetailsForm(
                        formKey: _cardFormKey,
                        onCardNumberChanged: ctrl.updateCardNumber,
                        onExpiryChanged: ctrl.updateExpiry,
                        onCvvChanged: ctrl.updateCvv,
                        onNameChanged: ctrl.updateName,
                      ),
                      const SizedBox(height: 20),
                      Obx(() => OrderSummary(model: ctrl.orderSummary.value)),
                      const SizedBox(height: 20),
                      Obx(
                        () => PayButton(
                          isLoading: ctrl.isLoading.value,
                          totalAmount: ctrl.orderSummary.value.totalAmount,
                          onPressed: _onPayPressed, // ← screen handles validation
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