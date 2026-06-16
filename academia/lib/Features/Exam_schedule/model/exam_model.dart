enum ExamStatus { next, upcoming, completed }

class ExamModel {
  final String id;
  final String title;
  final String date;
  final String month;
  final String time;
  final String room;
  final String examType;
  final ExamStatus status;
  final String? level;
  final int daysUntil;

  const ExamModel({
    required this.id,
    required this.title,
    required this.date,
    required this.month,
    required this.time,
    required this.room,
    required this.examType,
    required this.status,
    this.level,
    this.daysUntil = 0,
  });

  factory ExamModel.fromMap(Map<String, dynamic> row, ExamStatus status, {String? level}) {
    final examDate  = DateTime.parse(row['exam_date'] as String);
    final startTime = _fmtTime(row['start_time'] as String?);
    final endTime   = _fmtTime(row['end_time']   as String?);
    const months    = ['','JAN','FEB','MAR','APR','MAY','JUN',
                           'JUL','AUG','SEP','OCT','NOV','DEC'];

    // Prefer joined course name, fall back to stored text
    String title = row['course_name'] as String? ?? '';
    final sectionData = row['sections'];
    if (sectionData is Map) {
      final courseData = sectionData['courses'];
      if (courseData is Map) {
        title = courseData['name'] as String? ?? title;
      }
    }

    final today    = DateTime.now();
    final todayDay = DateTime(today.year, today.month, today.day);
    final examDay  = DateTime(examDate.year, examDate.month, examDate.day);
    final days     = examDay.difference(todayDay).inDays;

    return ExamModel(
      id:        row['id'].toString(),
      title:     title,
      date:      examDate.day.toString(),
      month:     months[examDate.month],
      time:      '$startTime - $endTime',
      room:      row['room'] as String? ?? '',
      examType:  row['exam_type'] as String? ?? 'Midterm',
      status:    status,
      level:     level,
      daysUntil: days,
    );
  }

  static String _fmtTime(String? raw) {
    if (raw == null) return '--';
    try {
      final parts = raw.split(':');
      int h = int.parse(parts[0]);
      final m = parts[1].padLeft(2, '0');
      final suffix = h >= 12 ? 'PM' : 'AM';
      if (h > 12) h -= 12;
      if (h == 0) h = 12;
      return '$h:$m $suffix';
    } catch (_) {
      return raw;
    }
  }

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      id:       json['id']       as String,
      title:    json['title']    as String,
      date:     json['date']     as String,
      month:    json['month']    as String,
      time:     json['time']     as String,
      room:     json['room']     as String,
      examType: json['examType'] as String? ?? 'Midterm',
      status:   ExamStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ExamStatus.upcoming,
      ),
    );
  }
}

class ExamPeriodModel {
  final String title;
  final String subtitle;

  const ExamPeriodModel({required this.title, required this.subtitle});

  factory ExamPeriodModel.fromMap(Map<String, dynamic> row) {
    return ExamPeriodModel(
      title:    row['label'] as String,
      subtitle: '${_fmtDate(row['start_date'])} - ${_fmtDate(row['end_date'])}',
    );
  }

  static String _fmtDate(dynamic raw) {
    if (raw == null) return '';
    try {
      final d = DateTime.parse(raw as String);
      const m = ['','Jan','Feb','Mar','Apr','May','Jun',
                     'Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${m[d.month]} ${d.day}, ${d.year}';
    } catch (_) {
      return raw.toString();
    }
  }
}
