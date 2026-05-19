class ScheduleItem {
  final String time;        // "09:00 - 11:00"
  final String title;       // "Cloud Computing"
  final String location;    // "Room B1"
  final String instructor;  // "Dr. Youssef"
  final String type;        // "Lecture" | "Lab" | "Tutorial"

  ScheduleItem({
    required this.time,
    required this.title,
    required this.location,
    required this.instructor,
    required this.type,
  });

  factory ScheduleItem.fromMap(Map<String, dynamic> map) {
    final section     = map['sections'];
    final schedule    = (section['schedules'] as List).first;
    final course      = section['courses'];
    final professor   = section['professors'];
    final profProfile = professor['profiles'];

    final start = _formatTime(schedule['start_time']);
    final end   = _formatTime(schedule['end_time']);

    return ScheduleItem(
      time:       '$start - $end',
      title:      course['name']           ?? '',
      location:   section['room']          ?? '',
      instructor: profProfile['full_name'] ?? '',
      type:       section['type']          ?? '',
    );
  }

  static String _formatTime(String? raw) {
    if (raw == null || raw.length < 5) return '';
    return raw.substring(0, 5);
  }
}