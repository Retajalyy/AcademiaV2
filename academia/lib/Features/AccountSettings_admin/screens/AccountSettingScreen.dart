import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import 'package:academia/Features/AccountSettings_admin/controller/account_settings_controller.dart';
import 'package:academia/Features/AccountSettings_admin/widgets/Accountheader.dart';          // ✅ fixed
import 'package:academia/Features/AccountSettings_admin/widgets/University_info.dart';  // ✅ fixed
import 'package:academia/Features/AccountSettings_admin/widgets/personal_info.dart';    // ✅ fixed

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AccountSettingsController());

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (controller.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.errorMessage.value,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: controller.loadAccount,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              AccountHeader(controller: controller),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.babyblue,
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        UniversityInfoWidget(controller: controller),
                        const SizedBox(height: 24),
                        PersonalInfoWidget(controller: controller),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}