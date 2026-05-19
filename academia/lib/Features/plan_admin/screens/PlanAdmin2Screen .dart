// lib/Features/plan_admin/screens/PlanAdmin2Screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:academia/Features/plan_admin/widgets/planAdminHeader2.dart';
import 'package:academia/Features/plan_admin/widgets/group_widget.dart';
import 'package:academia/Features/plan_admin/widgets/save_button.dart';
import '../controller/plan_admin_controller.dart';
import '../../../Core/utilities/colors.dart';

class Planadminscreen2 extends StatelessWidget {
  const Planadminscreen2({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<PlanAdminController>()) {
      Get.put(PlanAdminController(), permanent: true);
    }

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: SafeArea(
        child: Column(
          children: [
            const PlanHeader2(currentStep: 2),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(color: AppColors.babyblue),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// GROUP FORM
                      GroupFormWidget(
                        onAddAnotherGroup: () {},
                      ),

                      const SizedBox(height: 24),

                      /// SAVE BUTTON
                      const Center(
                        child: SizedBox(
                          width: 190,
                          child: SaveButton(),
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