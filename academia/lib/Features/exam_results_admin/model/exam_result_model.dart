// ─────────────────────────────────────────────────────────────────────────────
// Model: ExamResultModel
// Represents a single published exam-result record returned from the API.
// ─────────────────────────────────────────────────────────────────────────────

class ExamResultModel {
  final String id;
  final String title;
  final String faculty;
  final String level;
  final String major;
  final String semester;
  final String academicYear;
  final int studentsCount;
  final double passRate;
  final double avgGpa;
  final String fileName;
  final DateTime uploadedAt;

  const ExamResultModel({
    required this.id,
    required this.title,
    required this.faculty,
    required this.level,
    required this.major,
    required this.semester,
    required this.academicYear,
    required this.studentsCount,
    required this.passRate,
    required this.avgGpa,
    required this.fileName,
    required this.uploadedAt,
  });

  // ── JSON ──────────────────────────────────────────────────────────────────
  factory ExamResultModel.fromJson(Map<String, dynamic> json) {
    return ExamResultModel(
      id: json['id'] as String,
      title: json['title'] as String,
      faculty: json['faculty'] as String,
      level: json['level'] as String,
      major: json['major'] as String,
      semester: json['semester'] as String,
      academicYear: json['academic_year'] as String,
      studentsCount: json['students_count'] as int,
      passRate: (json['pass_rate'] as num).toDouble(),
      avgGpa: (json['avg_gpa'] as num).toDouble(),
      fileName: json['file_name'] as String,
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'faculty': faculty,
        'level': level,
        'major': major,
        'semester': semester,
        'academic_year': academicYear,
        'students_count': studentsCount,
        'pass_rate': passRate,
        'avg_gpa': avgGpa,
        'file_name': fileName,
        'uploaded_at': uploadedAt.toIso8601String(),
      };
}