// lib/Features/fees_admin/screens/fees_admin_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../../../Core/widgets/side_menu.dart';
import '../controller/fee_admin_controller.dart';
import '../widgets/FeesAdminHeader.dart';
import '../widgets/active_fee_card.dart';
import '../widgets/add_fee_sheet.dart';

class FeesAdminScreen extends StatelessWidget {
  const FeesAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<FeesAdminController>()) {
      Get.put(FeesAdminController(), permanent: true);
    }
    final c = Get.find<FeesAdminController>();

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      drawer: const SideMenu(activeItem: "Fees & Payments"),
      body: SafeArea(
        child: Column(
          children: [
            const FeesAdminHeader(),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(color: AppColors.babyblue),
                child: Obx(() {
                  if (c.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (c.errorMessage.value.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            c.errorMessage.value,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: c.loadData,
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Active Fees",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ✅ All fees in ONE container with dividers
                        const ActiveFeesContainer(),

                        const SizedBox(height: 80),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => AddFeeSheet.show(context),
        backgroundColor: AppColors.primaryBlue,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}