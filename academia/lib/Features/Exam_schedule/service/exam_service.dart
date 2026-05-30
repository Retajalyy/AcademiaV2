import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/exam_model.dart';

class ExamService {
  final _db = Supabase.instance.client;

  Future<List<ExamModel>> fetchExams() async {
    final userId = _db.auth.currentUser!.id;
    final studentRow = await _db
        .from('students')
        .select('id')
        .eq('profile_id', userId)
        .single();
    final studentId = studentRow['id'] as int;

    final data = await _db
        .from('exam_schedules')
        .select('''
          id, course_name, exam_date, start_time, end_time, room, exam_type,
          sections(courses(name))
        ''')
        .eq('student_id', studentId)
        .order('exam_date');

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // Mark the first future exam as 'next', rest as 'upcoming'
    bool nextAssigned = false;
    return (data as List).map((row) {
      final examDate = DateTime.parse(row['exam_date'] as String);
      final examDay  = DateTime(examDate.year, examDate.month, examDate.day);

      ExamStatus status;
      if (examDay.isBefore(todayDate)) {
        status = ExamStatus.completed;
      } else if (!nextAssigned) {
        status = ExamStatus.next;
        nextAssigned = true;
      } else {
        status = ExamStatus.upcoming;
      }

      return ExamModel.fromMap(row, status);
    }).toList();
  }

  Future<ExamPeriodModel?> fetchExamPeriod() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final row = await _db
        .from('exam_periods')
        .select('label, start_date, end_date')
        .lte('start_date', today)
        .gte('end_date', today)
        .maybeSingle();

    if (row == null) return null;
    return ExamPeriodModel.fromMap(row);
  }
}
