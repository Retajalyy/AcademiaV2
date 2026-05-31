class ExamScheduleUpload {
  final int id;
  final String facultyCode;
  final String facultyName;
  final String examType;
  final String examDate;
  final String? level;
  final String? majorCode;
  final String? majorName;
  final String? semester;
  final String? academicYear;
  final String? periodFrom;
  final String? periodTo;
  final String? fileUrl;
  final String? fileName;

  const ExamScheduleUpload({
    required this.id,
    required this.facultyCode,
    required this.facultyName,
    required this.examType,
    required this.examDate,
    this.level,
    this.majorCode,
    this.majorName,
    this.semester,
    this.academicYear,
    this.periodFrom,
    this.periodTo,
    this.fileUrl,
    this.fileName,
  });

  factory ExamScheduleUpload.fromMap(Map<String, dynamic> m) =>
      ExamScheduleUpload(
        id:           m['id']           as int,
        facultyCode:  m['faculty_code'] as String,
        facultyName:  m['faculty_name'] as String,
        examType:     m['exam_type']    as String,
        examDate:     m['exam_date']    as String,
        level:        m['level']        as String?,
        majorCode:    m['major_code']   as String?,
        majorName:    m['major_name']   as String?,
        semester:     m['semester']     as String?,
        academicYear: m['academic_year'] as String?,
        periodFrom:   m['period_from']  as String?,
        periodTo:     m['period_to']    as String?,
        fileUrl:      m['file_url']     as String?,
        fileName:     m['file_name']    as String?,
      );
}
