import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/exam_model.dart';

class ExamService {
  final _db = Supabase.instance.client;

  Future<int> getStudentId(String userId) async {
    final data = await _db
        .from('students')
        .select('id')
        .eq('profile_id', userId)
        .single();
    return data['id'] as int;
  }

  Future<ExamPeriodModel?> getActivePeriod() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final data  = await _db
        .from('exam_periods')
        .select()
        .lte('start_date', today)
        .gte('end_date', today)
        .maybeSingle();
    return data == null ? null : ExamPeriodModel.fromMap(data);
  }

  Future<List<ExamModel>> getExams(int studentId) async {
    final data = await _db
        .from('exam_schedules')
        .select('course_name, exam_date, start_time, end_time, room, exam_type')
        .eq('student_id', studentId)
        .order('exam_date')
        .order('start_time');

    return (data as List).map((row) => ExamModel.fromMap(row)).toList();
  }
}
