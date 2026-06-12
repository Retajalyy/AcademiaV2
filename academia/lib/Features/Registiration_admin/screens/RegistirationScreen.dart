// lib/Features/Registiration_admin/screens/RegistrationScreen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../../../Core/widgets/side_menu.dart';
import '../controller/registiration_controller.dart';
import '../../../Features/plan_admin/screens/PlanAdminScreen.dart';
import '../widgets/create_plan_sheet.dart';
import '../widgets/RegistirationHeader.dart';
import '../widgets/RegistirationStatusCard.dart';
import '../widgets/Active_Section.dart';
import '../widgets/NoRegistration_section.dart';
import '../widgets/Registiration_steps.dart';
import '../widgets/NoRegistiration_buttons.dart';

class RegistrationAdminScreen extends StatelessWidget {
  const RegistrationAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Find already-registered controller (no binding needed)
    final controller = Get.put(RegistrationController());

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      drawer: const SideMenu(activeItem: "Registration"),
      floatingActionButton: Obx(() {
        if (!controller.hasActivePlans) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreatePlanSheet(
                onCreated: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Planadminscreen1()),
                ),
              ),
            ),
          ),
          backgroundColor: AppColors.primaryBlue,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('New Plan',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        );
      }),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            /// HEADER
            const RegistrationHeader(),

            /// BODY
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.babyblue,
                ),
                child: Obx(() {
                  if (controller.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(controller.errorMessage.value,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red)),
                          const SizedBox(height: 12),
                          ElevatedButton(
                              onPressed: controller.refresh,
                              child: const Text("Retry")),
                        ],
                      ),
                    );
                  }

                  // ── No plans yet → show creation flow ─────────────────
                  if (controller.noActivePlans) {
                    return const SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 28),
                          NoRegistrationSection(),
                          SizedBox(height: 28),
                          RegistrationSteps(),
                          SizedBox(height: 28),
                          RegistrationButtons(),
                        ],
                      ),
                    );
                  }

                  // ── Plans exist → show active plans ────────────────────
                  return const SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RegistrationStatusCard(),
                        SizedBox(height: 18),
                        ActivePlansSection(),
                        SizedBox(height: 80), // space for FAB
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}