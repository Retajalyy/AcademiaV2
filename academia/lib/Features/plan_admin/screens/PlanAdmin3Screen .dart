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
        top: false,
        child: Column(
          children: [
            PlanHeader3(
              activeTab:     c.activeGroupTab,
              groupLabels:   c.savedGroupLabels,
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
                      /// GROUP CARD — from controller
                      Obx(() => GroupSE1Card(
                        groupName:   '${c.selectedMajor.value}${c.selectedLevel.value}',
                        department:  c.selectedMajorName.value,
                        level:       'Level ${c.selectedLevel.value}',
                        courseCount: c.scheduleCards.length,
                      )),

                      const SizedBox(height: 20),

                      /// SCHEDULE CARDS — from DB
                      Obx(() {
                        if (c.scheduleCards.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(
                              child: Text(
                                'No schedule data yet.',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          );
                        }
                        return Column(
                          children: c.scheduleCards.asMap().entries.map((e) {
                            final s = e.value;
                            return Padding(
                              padding: EdgeInsets.only(
                                  bottom: e.key < c.scheduleCards.length - 1
                                      ? 12
                                      : 0),
                              child: LectureScheduleCard(
                                courseName:            s.courseName,
                                credits:               s.credits,
                                lectureDay:            s.lectureDay,
                                lectureDoctor:         s.lectureDoctor,
                                lectureTime:           s.lectureTime,
                                lectureRoom:           s.lectureRoom,
                                sectionDay:            s.sectionDay,
                                sectionDoctor:         s.sectionDoctor,
                                sectionTime:           s.sectionTime,
                                sectionRoom:           s.sectionRoom,
                                borderColor:           s.borderColor,
                                creditBackgroundColor: s.creditBackgroundColor,
                                creditsTextColor:      s.creditsTextColor,
                              ),
                            );
                          }).toList(),
                        );
                      }),

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