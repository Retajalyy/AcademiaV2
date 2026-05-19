class CourseMaterial {
  final String title;
  final String subtitle;
  final String type;
  final bool isAssignment;

  const CourseMaterial({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.isAssignment,
  });
}

class CourseDetailsModel {
  final String id;
  final String courseName;
  final String doctorName;
  final int credits;
  final double progress;
  final double classworkPercent;
  final double assignmentsPercent;
  final double attendancePercent;
  final List<CourseMaterial> materials;

  const CourseDetailsModel({
    required this.id,
    required this.courseName,
    required this.doctorName,
    required this.credits,
    required this.progress,
    required this.classworkPercent,
    required this.assignmentsPercent,
    required this.attendancePercent,
    required this.materials,
  });
}
