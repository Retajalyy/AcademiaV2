class ProfessorCourseModel {
  final int courseId;
  final String courseName;
  final String courseCode;
  final String taName;
  final List<String> sectionLabels;

  ProfessorCourseModel({
    required this.courseId,
    required this.courseName,
    required this.courseCode,
    required this.taName,
    required this.sectionLabels,
  });
}
