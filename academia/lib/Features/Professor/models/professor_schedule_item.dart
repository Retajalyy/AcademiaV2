class ProfessorScheduleItem {
  final int sectionId;
  final String time;
  final String startTime;
  final String endTime;
  final String title;
  final String code;
  final String location;
  final String type;
  final List<String> groups;

  ProfessorScheduleItem({
    required this.sectionId,
    required this.time,
    required this.startTime,
    required this.endTime,
    required this.title,
    required this.code,
    required this.location,
    required this.type,
    this.groups = const [],
  });

  factory ProfessorScheduleItem.fromMap(
    Map<String, dynamic> map, {
    List<String> groups = const [],
  }) {
    final schedule = (map['schedules'] as List).first;
    final course = map['courses'] as Map<String, dynamic>;
    final start = _fmt(schedule['start_time']);
    final end = _fmt(schedule['end_time']);

    return ProfessorScheduleItem(
      sectionId: map['id'] as int,
      time: '$start - $end',
      startTime: start,
      endTime: end,
      title: course['name'] as String? ?? '',
      code: course['code'] as String? ?? '',
      location: map['room'] as String? ?? '',
      type: map['type'] as String? ?? '',
      groups: groups,
    );
  }

  static String _fmt(String? raw) {
    if (raw == null || raw.length < 5) return '';
    return raw.substring(0, 5);
  }
}
