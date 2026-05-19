// lib/Features/Registiration_admin/screens/NoRegistrationScreen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../../../Core/widgets/side_menu.dart';
import '../controller/registiration_controller.dart';
import '../widgets/RegistirationHeader.dart';
import '../widgets/NoRegistration_section.dart';
import '../widgets/Registiration_steps.dart';
import '../widgets/NoRegistiration_buttons.dart';

class NoRegistrationAdminScreen extends StatelessWidget {
  const NoRegistrationAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Find already-registered controller (no binding needed)
    final controller = Get.put(RegistrationController());

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      drawer: const SideMenu(activeItem: "Registration"),
      body: SafeArea(
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
                  // Show full-screen loader while fetching
                  if (controller.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Show error with retry
                  if (controller.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            controller.errorMessage.value,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: controller.refresh,
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    );
                  }

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
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}