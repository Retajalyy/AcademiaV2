class ExamResultModel {
  final String id;
  final int semesterId;
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
    required this.semesterId,
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

  factory ExamResultModel.fromDb(Map<String, dynamic> row) {
    return ExamResultModel(
      id:            row['id'].toString(),
      semesterId:    (row['semester_id'] as int?) ?? 0,
      title:         row['title']          as String,
      faculty:       row['faculty']        as String? ?? '',
      level:         row['year_level'] != null ? 'Level ${row['year_level']}' : '',
      major:         row['major']          as String? ?? '',
      semester:      row['semester_label'] as String? ?? '',
      academicYear:  row['academic_year']  as String? ?? '',
      studentsCount: (row['students_count'] as int?) ?? 0,
      passRate:      (row['pass_rate']  as num?)?.toDouble() ?? 0,
      avgGpa:        (row['avg_gpa']    as num?)?.toDouble() ?? 0,
      fileName:      row['file_name']      as String? ?? '',
      uploadedAt:    row['uploaded_at'] != null
                       ? DateTime.parse(row['uploaded_at'] as String)
                       : DateTime.now(),
    );
  }
}
