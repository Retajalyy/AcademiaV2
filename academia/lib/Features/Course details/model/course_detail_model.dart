class CourseMaterial {
  final String title;
  final String subtitle;
  final String type; // 'pdf' | 'docx' | 'video'
  final bool isAssignment;

  const CourseMaterial({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.isAssignment,
  });

  factory CourseMaterial.fromJson(Map<String, dynamic> json) {
    return CourseMaterial(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      type: json['type'] as String,
      isAssignment: json['isAssignment'] as bool,
    );
  }
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

  factory CourseDetailsModel.fromJson(Map<String, dynamic> json) {
    return CourseDetailsModel(
      id: json['id'] as String,
      courseName: json['courseName'] as String,
      doctorName: json['doctorName'] as String,
      credits: json['credits'] as int,
      progress: (json['progress'] as num).toDouble(),
      classworkPercent: (json['classworkPercent'] as num).toDouble(),
      assignmentsPercent: (json['assignmentsPercent'] as num).toDouble(),
      attendancePercent: (json['attendancePercent'] as num).toDouble(),
      materials: (json['materials'] as List<dynamic>)
          .map((e) => CourseMaterial.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  String get progressLabel =>
      '${(progress * 100).toStringAsFixed(0)}% completed';
}