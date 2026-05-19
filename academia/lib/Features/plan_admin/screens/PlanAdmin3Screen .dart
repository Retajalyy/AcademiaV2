// lib/Features/plan_admin/screens/PlanAdmin3Screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:academia/Features/plan_admin/widgets/planAdminHeader3.dart';
import 'package:academia/Features/plan_admin/widgets/group_card.dart';
import 'package:academia/Features/plan_admin/widgets/lecture_schedule_card.dart';
import 'package:academia/Features/plan_admin/widgets/publish_button.dart';
import '../controller/plan_admin_controller.dart';
import '../../../Core/utilities/colors.dart';

class Planadminscreen3 extends StatelessWidget {
  const Planadminscreen3({super.key});

  @override
  Widget build(BuildContext context) {
    // Always ensure controller exists
    final PlanAdminController c;
    if (Get.isRegistered<PlanAdminController>()) {
      c = Get.find<PlanAdminController>();
    } else {
      c = Get.put(PlanAdminController(), permanent: true);
    }

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: SafeArea(
        child: Column(
          children: [
            PlanHeader3(
              activeTab: c.activeGroupTab,
              onTabSelected: c.selectGroupTab,
            ),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.babyblue,
                  border: Border(
                    top: BorderSide(color: Colors.white, width: 2),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// GROUP CARD
                      GroupSE1Card(
                        groupName: "SE1",
                        department: "Software Engineering",
                        level: "Level 4",
                        courseCount: 6,
                      ),

                      const SizedBox(height: 20),

                      /// SCHEDULE CARDS
                      LectureScheduleCard(
                        courseName: "Cloud Computing",
                        credits: "3 Credits",
                        lectureDay: "Sun",
                        lectureDoctor: "Dr. Youssef Senousy",
                        lectureTime: "08:00 - 09:30",
                        lectureRoom: "Room B3",
                        sectionDay: "Tue",
                        sectionDoctor: "Mr. Ahmed Mohamed",
                        sectionTime: "11:00 - 12:30",
                        sectionRoom: "Lab 01",
                        borderColor: AppColors.accentProgramming1,
                        creditBackgroundColor: AppColors.bluegroundicon,
                        creditsTextColor: AppColors.accentProgramming1,
                      ),

                      const SizedBox(height: 12),

                      LectureScheduleCard(
                        courseName: "Digital Marketing",
                        credits: "2 Credits",
                        lectureDay: "Sun",
                        lectureDoctor: "Dr. Khuloud Farag",
                        lectureTime: "08:00 - 09:30",
                        lectureRoom: "Room B3",
                        sectionDay: "Tue",
                        sectionDoctor: "Mr. Ahmed Mohamed",
                        sectionTime: "11:00 - 12:30",
                        sectionRoom: "Lab 01",
                        borderColor: AppColors.accentAI,
                        creditBackgroundColor: AppColors.LightYellow,
                        creditsTextColor: AppColors.assignmentColor,
                      ),

                      const SizedBox(height: 30),

                      /// PUBLISH BUTTON
                      PublishSemesterButton(
                        onPressed: () async {
                          await c.publishPlan();
                        },
                      ),
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