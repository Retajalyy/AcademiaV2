// lib/Features/Registiration_admin/screens/RegistrationEntryScreen.dart
//
// This is the single entry point for the Registration feature.
// It registers the controller once, then routes to the correct screen
// based on the controller's reactive state — no Binding class needed.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/registiration_controller.dart';
import 'package:academia/Features/Registiration_admin/screens/NoRegistirationScreen.dart';
 import 'package:academia/Features/Registiration_admin/screens/RegistirationScreen.dart'; 
import '../../../Core/utilities/colors.dart';

class RegistrationEntryScreen extends StatelessWidget {
  const RegistrationEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Put the controller lazily — safe to call multiple times (GetX deduplicates)
    Get.put(RegistrationController(), permanent: false);

    final controller = Get.find<RegistrationController>();

    return Obx(() {
      switch (controller.status.value) {
        // ── Loading ────────────────────────────────────────────────────────
        case RegistrationStatus.initial:
        case RegistrationStatus.loading:
          return Scaffold(
            backgroundColor: AppColors.primaryBlue,
            body: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );

        // ── No plans yet ──────────────────────────────────────────────────
        case RegistrationStatus.noPlans:
          return const NoRegistrationAdminScreen();

        // ── Has active plans ──────────────────────────────────────────────
        case RegistrationStatus.hasPlans:
          return const RegistrationAdminScreen();

        // ── Error ─────────────────────────────────────────────────────────
        case RegistrationStatus.error:
          return Scaffold(
            backgroundColor: AppColors.babyblue,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.refresh,
                    child: const Text("Retry"),
                  ),
                ],
              ),
            ),
          );
      }
    });
  }
}