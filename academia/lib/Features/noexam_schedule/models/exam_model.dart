class ExamPeriodModel {
  final String label;
  final DateTime startDate;
  final DateTime endDate;

  ExamPeriodModel({
    required this.label,
    required this.startDate,
    required this.endDate,
  });

  String get subtitle {
    final months = ['','Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[startDate.month]} ${startDate.day} - '
           '${months[endDate.month]} ${endDate.day}, ${endDate.year}';
  }

  factory ExamPeriodModel.fromMap(Map<String, dynamic> row) {
    return ExamPeriodModel(
      label:     row['label']      as String,
      startDate: DateTime.parse(row['start_date'] as String),
      endDate:   DateTime.parse(row['end_date']   as String),
    );
  }
}

class ExamModel {
  final String courseName;
  final DateTime examDate;
  final String startTime;
  final String endTime;
  final String room;
  final String examType;

  ExamModel({
    required this.courseName,
    required this.examDate,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.examType,
  });

  String get day   => examDate.day.toString();
  String get month {
    const months = ['','JAN','FEB','MAR','APR','MAY','JUN',
                    'JUL','AUG','SEP','OCT','NOV','DEC'];
    return months[examDate.month];
  }
  String get timeLabel => '$startTime - $endTime';

  bool get isCompleted {
    final today = DateTime.now();
    final d = DateTime(today.year, today.month, today.day);
    return examDate.isBefore(d);
  }

  factory ExamModel.fromMap(Map<String, dynamic> row) {
    final start = (row['start_time'] as String).substring(0, 5);
    final end   = (row['end_time']   as String).substring(0, 5);
    return ExamModel(
      courseName: row['course_name'] as String,
      examDate:   DateTime.parse(row['exam_date'] as String),
      startTime:  _to12h(start),
      endTime:    _to12h(end),
      room:       row['room']       as String,
      examType:   row['exam_type']  as String,
    );
  }

  static String _to12h(String hhmm) {
    final parts  = hhmm.split(':');
    var   hour   = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    return '$hour:$minute $period';
  }
}
