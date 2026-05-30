import 'package:flutter/material.dart';

// ─── Professor Option (for dropdown) ─────────────────────────────────────────

class ProfessorOption {
  final int    id;
  final String name;
  final String department;

  const ProfessorOption({
    required this.id,
    required this.name,
    required this.department,
  });
}

// ─── Per-course assignment state ──────────────────────────────────────────────

class CourseAssignment {
  // Lecture
  int?    lectureProfessorId;
  String? lectureDay;
  String? lectureHall;
  String? lectureFrom;
  String? lectureTo;

  // Section (optional)
  bool    hasSection;
  int?    sectionProfessorId;
  String? sectionDay;
  String? sectionHall;
  String? sectionFrom;
  String? sectionTo;

  CourseAssignment({
    this.lectureProfessorId,
    this.lectureDay,
    this.lectureHall,
    this.lectureFrom,
    this.lectureTo,
    this.hasSection       = false,
    this.sectionProfessorId,
    this.sectionDay,
    this.sectionHall,
    this.sectionFrom,
    this.sectionTo,
  });
}

// ─── Course Model ─────────────────────────────────────────────────────────────

class CourseModel {
  final String   id;
  final String   name;
  final String   type;
  final int      credits;
  final IconData icon;
  final Color    themeColor;
  bool           isSelected;

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
        id: id, name: name, type: type, credits: credits,
        icon: icon, themeColor: themeColor,
        isSelected: isSelected ?? this.isSelected,
      );
}

// ─── Group Model ──────────────────────────────────────────────────────────────

class GroupModel {
  final String  id;
  final String  name;
  final String  department;
  final String  level;
  final int     capacity;

  const GroupModel({
    required this.id,
    required this.name,
    required this.department,
    required this.level,
    this.capacity = 30,
  });

  GroupModel copyWith({int? capacity}) => GroupModel(
        id: id, name: name, department: department,
        level: level, capacity: capacity ?? this.capacity,
      );
}

// ─── Semester Plan Model ──────────────────────────────────────────────────────

class SemesterPlanModel {
  final String          id;
  final String          faculty;
  final int             level;
  final String          major;
  final List<CourseModel> courses;
  final List<GroupModel>  groups;

  const SemesterPlanModel({
    required this.id,
    required this.faculty,
    required this.level,
    required this.major,
    this.courses = const [],
    this.groups  = const [],
  });
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
  final Color  borderColor;
  final Color  creditBackgroundColor;
  final Color  creditsTextColor;

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
