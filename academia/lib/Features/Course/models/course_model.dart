class CourseModel {
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
