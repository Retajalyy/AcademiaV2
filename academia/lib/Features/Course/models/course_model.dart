class CourseModel {
  final int courseId;
  final int sectionId;
  final String title;
  final String code;
  final String doctor;
  final String type;
  final String credits;
  final String day;
  final String time;
  final String location;

  CourseModel({
    this.courseId = 0,
    required this.sectionId,
    required this.title,
    required this.code,
    required this.doctor,
    required this.type,
    required this.credits,
    required this.day,
    required this.time,
    required this.location,
  });

  factory CourseModel.fromRgs(Map<String, dynamic> row, {int courseId = 0, String type = ''}) {
    final start = (row['lecture_start'] as String?)?.substring(0, 5) ?? '--:--';
    final end   = (row['lecture_end']   as String?)?.substring(0, 5) ?? '--:--';
    return CourseModel(
      courseId:  courseId,
      sectionId: row['section_id']        as int?    ?? 0,
      title:     row['course_name']       as String? ?? '',
      code:      row['course_code']       as String? ?? '',
      doctor:    row['lecture_instructor'] as String? ?? '',
      type:      type,
      credits:   '${row['credit_hours'] ?? 3} credits',
      day:       row['lecture_day']       as String? ?? '',
      time:      '$start - $end',
      location:  row['lecture_room']      as String? ?? '',
    );
  }

  factory CourseModel.fromMap(Map<String, dynamic> row) {
    final section   = row['sections'] as Map<String, dynamic>;
    final course    = section['courses'] as Map<String, dynamic>;
    final profName  = (section['professors']?['profiles']?['full_name'] as String?) ?? '';
    final schedules = section['schedules'] as List? ?? [];
    final schedule  = schedules.isNotEmpty ? schedules.first : null;

    final start = schedule != null
        ? (schedule['start_time'] as String).substring(0, 5)
        : '--:--';
    final end = schedule != null
        ? (schedule['end_time'] as String).substring(0, 5)
        : '--:--';

    return CourseModel(
      sectionId: section['id'] as int,
      title:    course['name']         ?? '',
      code:     course['code']         ?? '',
      doctor:   profName,
      type:     course['type']         ?? 'Core',
      credits:  '${course['credit_hours'] ?? 3} credits',
      day:      schedule?['day']       ?? '',
      time:     '$start - $end',
      location: section['room']        ?? '',
    );
  }
}
