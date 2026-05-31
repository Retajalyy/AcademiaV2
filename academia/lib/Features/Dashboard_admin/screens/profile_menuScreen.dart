import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import 'package:academia/Features/Dashboard_admin/widgets/pending_task.dart';
import 'package:academia/Features/Dashboard_admin/widgets/Dashboard_headr.dart';
import 'package:academia/Features/Dashboard_admin/widgets/Quick_actions.dart';
import '../widgets/profile_popup.dart';

class ProfileMenuScreen extends StatelessWidget {
  const ProfileMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,

      body: SafeArea(
        child: Stack(
          children: [

            /// DASHBOARD CONTENT
            SingleChildScrollView(
              child: Column(
                children: const [

                  DashboardHeader(),

                  SizedBox(height: 18),

                  QuickActionsSection(),

                  SizedBox(height: 18),

                  PendingTasksSection(),
                ],
              ),
            ),

            /// FADED BACKGROUND
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.35),
                ),
              ),
            ),

            /// PROFILE POPUP
            const Positioned(
              top: 75,
              right: 18,
              child: ProfilePopup(),
            ),
          ],
        ),
      ),
    );
  }
}