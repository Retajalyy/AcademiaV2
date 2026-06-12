class StudentModel {
  final String name;
  final String id;
  final String level;
  final String faculty;
  final String major;
  final String email;
  final String phone;
  final String? avatarUrl;
  final double gpa;
  final int attendancePercent;
  final int coursesEnrolled;
  final int semesterCompleted;
  final int completedCredits;
  final int totalCredits;
  final int remainingCredits;

  StudentModel({
    required this.name,
    required this.id,
    required this.level,
    required this.faculty,
    required this.major,
    required this.email,
    required this.phone,
    this.avatarUrl,
    required this.gpa,
    required this.attendancePercent,
    required this.coursesEnrolled,
    required this.semesterCompleted,
    required this.completedCredits,
    required this.totalCredits,
    required this.remainingCredits,
  });

  double get degreeProgress => totalCredits > 0 ? completedCredits / totalCredits : 0;
}
