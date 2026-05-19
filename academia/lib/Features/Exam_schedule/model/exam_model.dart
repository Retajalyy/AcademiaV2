// lib/features/exam/data/models/exam_model.dart

enum ExamStatus { next, upcoming, completed }

class ExamModel {
  final String id;
  final String title;
  final String date;        // e.g. "24"
  final String month;       // e.g. "APR"
  final String time;        // e.g. "10:00 AM - 11:00 AM"
  final String room;        // e.g. "Room 3B"
  final ExamStatus status;

  const ExamModel({
    required this.id,
    required this.title,
    required this.date,
    required this.month,
    required this.time,
    required this.room,
    required this.status,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      id:     json['id']    as String,
      title:  json['title'] as String,
      date:   json['date']  as String,
      month:  json['month'] as String,
      time:   json['time']  as String,
      room:   json['room']  as String,
      status: ExamStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ExamStatus.upcoming,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id':     id,
    'title':  title,
    'date':   date,
    'month':  month,
    'time':   time,
    'room':   room,
    'status': status.name,
  };
}

class ExamPeriodModel {
  final String title;       // e.g. "Midterms exams period"
  final String subtitle;    // e.g. "April 23 - May 1, 2026"

  const ExamPeriodModel({
    required this.title,
    required this.subtitle,
  });

  factory ExamPeriodModel.fromJson(Map<String, dynamic> json) {
    return ExamPeriodModel(
      title:    json['title']    as String,
      subtitle: json['subtitle'] as String,
    );
  }
}