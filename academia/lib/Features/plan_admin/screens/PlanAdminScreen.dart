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

class Planadminscreen1 extends StatefulWidget {
  const Planadminscreen1({super.key});

  @override
  State<Planadminscreen1> createState() => _Planadminscreen1State();
}

class _Planadminscreen1State extends State<Planadminscreen1> {
  late final PlanAdminController c;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<PlanAdminController>()) {
      Get.put(PlanAdminController(), permanent: true);
    }
    c = Get.find<PlanAdminController>();
    // Load faculties after first frame to avoid build-time side effects
    WidgetsBinding.instance.addPostFrameCallback((_) {
      c.loadFaculties();
      c.loadProfessors();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                            onMajorSelected: (major) {},
                          ),
                        ],

                        /// STEP 4 — appears after major selected
                        if (c.showCourses.value) ...[
                          const SizedBox(height: 20),
                          const AddCoursesWidget(),
                        ],

                        /// STEP 5 — appears after courses selected
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
