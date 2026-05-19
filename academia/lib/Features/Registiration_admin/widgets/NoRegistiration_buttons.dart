// lib/Features/Registiration_admin/widgets/NoRegistiration_buttons.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../controller/registiration_controller.dart';
import 'package:academia/Features/plan_admin/screens/PlanAdminScreen.dart';

class RegistrationButtons extends StatelessWidget {
  const RegistrationButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RegistrationController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 38),
      child: Obx(() {
        final loading = controller.isActionLoading.value;

        return Column(
          children: [
            // ── Create New Plan ────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
                onPressed: loading
                    ? null
                    : () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const Planadminscreen1(),
                          ),
                        );
                      },
                child: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Create New Plan",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Duplicate Previous Plan ───────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
                onPressed: loading
                    ? null
                    : () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const Planadminscreen1(),
                          ),
                        );
                      },
                child: const Text(
                  "Duplicate Previous Plan",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}