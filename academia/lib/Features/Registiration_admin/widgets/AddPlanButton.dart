// lib/Features/Registiration_admin/widgets/AddPlanButton.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../controller/registiration_controller.dart';

class AddNewPlan extends StatelessWidget {
  const AddNewPlan({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RegistrationController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 38),
      child: Obx(() {
        final loading = controller.isActionLoading.value;

        return SizedBox(
          width: double.infinity,
          height: 50,
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
                    // Navigate to plan creation flow.
                    // On completion, call controller.createNewPlan(data).
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
                    "Add New Plan",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
          ),
        );
      }),
    );
  }
}