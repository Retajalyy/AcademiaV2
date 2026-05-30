import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/registration_controller.dart';
import '../models/registration_model.dart';

/// Shown when registration window is open but student has unpaid fees.
class RegistrationFeesRequiredWidget extends StatelessWidget {
  const RegistrationFeesRequiredWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<RegistrationController>();

    return Obx(() {
      if (ctrl.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(48),
            child: CircularProgressIndicator(color: Color(0xFF1A6EFF)),
          ),
        );
      }

      final balance = ctrl.balanceInfo.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          _LockIcon(),
          const SizedBox(height: 24),
          const Text(
            'Pay your fees to register',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Registration is open, but you must clear\nyour outstanding balance first.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          if (balance != null)
            _OutstandingBalanceBanner(
              balance: balance,
              onPayNow: ctrl.payNow,
              isSubmitting: ctrl.isSubmitting.value,
            ),
        ],
      );
    });
  }
}

class _LockIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFFFF7ED),
      ),
      child: const Icon(
        Icons.lock_outline_rounded,
        size: 38,
        color: Color(0xFFF97316),
      ),
    );
  }
}

class _OutstandingBalanceBanner extends StatelessWidget {
  final BalanceInfo balance;
  final VoidCallback onPayNow;
  final bool isSubmitting;

  const _OutstandingBalanceBanner({
    required this.balance,
    required this.onPayNow,
    required this.isSubmitting,
  });

  @override
  Widget build(BuildContext context) {
    final formattedAmount = NumberFormat('#,###').format(balance.outstandingAmount);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFF97316), size: 16),
              SizedBox(width: 6),
              Text(
                'Outstanding balance',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF92400E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Pay your fees in full to access course registration.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF92400E),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$formattedAmount ${balance.currency}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  Text(
                    'Due ${balance.dueDate}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : onPayNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A6EFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    elevation: 0,
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Pay now',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
