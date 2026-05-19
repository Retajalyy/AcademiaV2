import 'package:academia/Features/Dashboard_admin/widgets/pending_task.dart';
import 'package:academia/Features/Dashboard_admin/controller/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:academia/Features/Dashboard_admin/widgets/Dashboard_headr.dart';
import 'package:academia/Features/Dashboard_admin/widgets/Quick_actions.dart';
import '../../../Core/utilities/colors.dart';
import '../../../Core/widgets/side_menu.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ── Inject controller here, no binding needed ──
    final controller = Get.put(DashboardController());

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      drawer: const SideMenu(activeItem: "Dashboard"),
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
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.refresh,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return Column(
            children: [
              const DashboardHeader(),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.babyblue,
                  ),
                  child: const SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        QuickActionsSection(),
                        SizedBox(height: 18),
                        PendingTasksSection(),
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