// lib/Features/plan_admin/screens/PlanAdminScreen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:academia/Features/plan_admin/widgets/planAdminHeader.dart';
import 'package:academia/Features/plan_admin/widgets/Faculty_selection.dart';
import 'package:academia/Features/plan_admin/widgets/select_level.dart';
import 'package:academia/Features/plan_admin/widgets/major_selection.dart';
import 'package:academia/Features/plan_admin/widgets/Add%20_course.dart';
import 'package:academia/Features/plan_admin/widgets/Assign_button.dart';
import '../controller/plan_admin_controller.dart';
import '../../../Core/utilities/colors.dart';

class Planadminscreen1 extends StatelessWidget {
  const Planadminscreen1({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<PlanAdminController>()) {
      Get.put(PlanAdminController(), permanent: true);
    }
    final c = Get.find<PlanAdminController>();

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: SafeArea(
        child: Column(
          children: [
            const PlanHeader1(currentStep: 1),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(color: AppColors.babyblue),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Obx(() {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// STEP 1 — always visible
                        FacultySelectionWidget(
                          onFacultySelected: () {
                            c.showLevel.value = true;
                          },
                        ),

                        /// STEP 2 — appears after faculty selected
                        if (c.showLevel.value) ...[
                          const SizedBox(height: 20),
                          LevelSelectorWidget(
                            onLevelConfirmed: () {
                              c.showMajor.value = true;
                            },
                          ),
                        ],

                        /// STEP 3 — appears after level selected
                        if (c.showMajor.value) ...[
                          const SizedBox(height: 20),
                          MajorSelectorWidget(
                            onMajorSelected: (major) {
                              c.showCourses.value =
                                  major == "Software Engineering";
                              c.showAssignButton.value = false;
                            },
                          ),
                        ],

                        /// STEP 4 — appears after major selected
                        if (c.showCourses.value) ...[
                          const SizedBox(height: 20),
                          const AddCoursesWidget(),
                        ],

                        /// STEP 5 — appears after cloud course selected
                        if (c.showAssignButton.value) ...[
                          const SizedBox(height: 20),
                          const AddNewPlan(),
                        ],

                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}