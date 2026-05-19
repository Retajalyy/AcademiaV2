import 'package:flutter/material.dart';
import 'package:academia/Features/plan_admin/widgets/planAdminHeader.dart';
import 'package:academia/Features/plan_admin/widgets/Faculty_selection.dart';
import 'package:academia/Features/plan_admin/widgets/select_level.dart';
import 'package:academia/Features/plan_admin/widgets/major_selection.dart';
import 'package:academia/Features/plan_admin/widgets/Add%20_course.dart';
import 'package:academia/Features/plan_admin/widgets/Assign_button.dart';
import '../../../Core/utilities/colors.dart';

class Planadminscreen1 extends StatefulWidget {
  const Planadminscreen1({super.key});

  @override
  State<Planadminscreen1> createState() =>
      _Planadminscreen1State();
}

class _Planadminscreen1State extends State<Planadminscreen1> {
  bool showLevel = false;
  bool showMajor = false;
  bool showCourses = false;
  bool showAddPlan = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            const PlanHeader1(currentStep: 1),

            /// BODY
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
                      /// FACULTY
                      FacultySelectionWidget(
                        onFacultySelected: () {
                          setState(() {
                            showLevel = true;
                          });
                        },
                      ),

                      const SizedBox(height: 20),

                      /// LEVEL
                      if (showLevel)
                        LevelSelectorWidget(
                          onLevelConfirmed: () {
                            setState(() {
                              showMajor = true;
                            });
                          },
                        ),

                      const SizedBox(height: 20),

                      /// MAJOR
                      if (showMajor)
                        MajorSelectorWidget(
                          onMajorSelected: (major) {
                            setState(() {
                              showCourses =
                                  major == "Software Engineering";
                            });
                          },
                        ),

                      const SizedBox(height: 20),

                      /// COURSES
                      if (showCourses)
                        AddCoursesWidget(
                          onCloudSelected: () {
                            setState(() {
                              showAddPlan = true;
                            });
                          },
                        ),

                      const SizedBox(height: 20),

                      /// BUTTON (ONLY AFTER CLOUD SELECTION)
                      if (showAddPlan)
                        const AddNewPlan(),
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