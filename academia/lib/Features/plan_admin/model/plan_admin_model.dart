// lib/Features/plan_admin/models/plan_admin_model.dart

import 'package:flutter/material.dart';

// ─── Course Model ────────────────────────────────────────────────────────────

class CourseModel {
  final String id;
  final String name;
  final String type; // "Core" | "Elective"
  final int credits;
  final IconData icon;
  final Color themeColor;
  bool isSelected;

  CourseModel({
    required this.id,
    required this.name,
    required this.type,
    required this.credits,
    required this.icon,
    required this.themeColor,
    this.isSelected = false,
  });

  CourseModel copyWith({bool? isSelected}) => CourseModel(
        id: id,
        name: name,
        type: type,
        credits: credits,
        icon: icon,
        themeColor: themeColor,
        isSelected: isSelected ?? this.isSelected,
      );
}

// ─── Group Model ─────────────────────────────────────────────────────────────

class GroupModel {
  final String id;
  final String name;         // e.g. "SE1"
  final String department;   // e.g. "Software Engineering"
  final String level;        // e.g. "Level 4"
  final int capacity;
  final String scheduleType; // "LECTURE" | "SECTION"
  final String? professor;
  final String? day;
  final String? hall;
  final String? fromTime;
  final String? toTime;

  const GroupModel({
    required this.id,
    required this.name,
    required this.department,
    required this.level,
    this.capacity = 30,
    this.scheduleType = "LECTURE",
    this.professor,
    this.day,
    this.hall,
    this.fromTime,
    this.toTime,
  });

  GroupModel copyWith({
    String? name,
    String? department,
    String? level,
    int? capacity,
    String? scheduleType,
    String? professor,
    String? day,
    String? hall,
    String? fromTime,
    String? toTime,
  }) =>
      GroupModel(
        id: id,
        name: name ?? this.name,
        department: department ?? this.department,
        level: level ?? this.level,
        capacity: capacity ?? this.capacity,
        scheduleType: scheduleType ?? this.scheduleType,
        professor: professor ?? this.professor,
        day: day ?? this.day,
        hall: hall ?? this.hall,
        fromTime: fromTime ?? this.fromTime,
        toTime: toTime ?? this.toTime,
      );
}

// ─── Semester Plan Model ──────────────────────────────────────────────────────

class SemesterPlanModel {
  final String id;
  final String faculty;
  final int level;
  final String major;
  final List<CourseModel> courses;
  final List<GroupModel> groups;

  const SemesterPlanModel({
    required this.id,
    required this.faculty,
    required this.level,
    required this.major,
    this.courses = const [],
    this.groups = const [],
  });

  SemesterPlanModel copyWith({
    String? faculty,
    int? level,
    String? major,
    List<CourseModel>? courses,
    List<GroupModel>? groups,
  }) =>
      SemesterPlanModel(
        id: id,
        faculty: faculty ?? this.faculty,
        level: level ?? this.level,
        major: major ?? this.major,
        courses: courses ?? this.courses,
        groups: groups ?? this.groups,
      );
}

// ─── Schedule Card Model (Screen 3) ──────────────────────────────────────────

class LectureScheduleModel {
  final String courseName;
  final String credits;

  final String lectureDay;
  final String lectureDoctor;
  final String lectureTime;
  final String lectureRoom;

  final String sectionDay;
  final String sectionDoctor;
  final String sectionTime;
  final String sectionRoom;

  final Color borderColor;
  final Color creditBackgroundColor;
  final Color creditsTextColor;

  const LectureScheduleModel({
    required this.courseName,
    required this.credits,
    required this.lectureDay,
    required this.lectureDoctor,
    required this.lectureTime,
    required this.lectureRoom,
    required this.sectionDay,
    required this.sectionDoctor,
    required this.sectionTime,
    required this.sectionRoom,
    required this.borderColor,
    required this.creditBackgroundColor,
    required this.creditsTextColor,
  });
}