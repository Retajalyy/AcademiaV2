class SectionOption {
  final int sectionId;
  final String courseName;
  final String courseCode;
  final String type;

  const SectionOption({
    required this.sectionId,
    required this.courseName,
    required this.courseCode,
    required this.type,
  });

  String get displayLabel => '$courseCode — $courseName ($type)';
}

class ExamScheduleEntry {
  final String courseName;
  final String examType;
  final String examDate;
  final String startTime;
  final String endTime;
  final String room;
  final int studentCount;

  const ExamScheduleEntry({
    required this.courseName,
    required this.examType,
    required this.examDate,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.studentCount,
  });
}
