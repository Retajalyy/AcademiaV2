// lib/Features/plan_admin/services/plan_admin_service.dart

import 'package:flutter/material.dart';
import '../model/plan_admin_model.dart';
import '../../../Core/utilities/colors.dart';

class PlanAdminService {
  // ─── Static course catalog ────────────────────────────────────────────────
  List<CourseModel> getAvailableCourses() {
    return [
      CourseModel(
        id: 'course_001',
        name: "Cloud Computing",
        type: "Core",
        credits: 3,
        icon: Icons.storage_rounded,
        themeColor: const Color(0xFFDDEDFA),
      ),
      CourseModel(
        id: 'course_002',
        name: "Internet of Things",
        type: "Core",
        credits: 3,
        icon: Icons.language_rounded,
        themeColor: const Color(0xFFDDEDFA),
      ),
      CourseModel(
        id: 'course_003',
        name: "SW Quality and Analysis",
        type: "Core",
        credits: 3,
        icon: Icons.manage_search_rounded,
        themeColor: const Color(0xFFDDEDFA),
      ),
      CourseModel(
        id: 'course_004',
        name: "Digital Marketing",
        type: "Elective",
        credits: 2,
        icon: Icons.image_aspect_ratio_rounded,
        themeColor: const Color(0xFFFFF3DF),
      ),
      CourseModel(
        id: 'course_005',
        name: "Principles of Economics",
        type: "Elective",
        credits: 2,
        icon: Icons.trending_up_rounded,
        themeColor: const Color(0xFFFFF3DF),
      ),
    ];
  }

  // ─── Static schedule data (Screen 3) ─────────────────────────────────────
  List<LectureScheduleModel> getScheduleForGroup(String groupName) {
    return [
      LectureScheduleModel(
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
      LectureScheduleModel(
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
    ];
  }

  // ─── Save plan (simulate API) ─────────────────────────────────────────────
  Future<bool> savePlan(SemesterPlanModel plan) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }

  // ─── Publish plan (simulate API) ─────────────────────────────────────────
  Future<bool> publishPlan(String planId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return true;
  }
}