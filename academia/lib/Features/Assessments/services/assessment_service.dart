import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/assessment_model.dart';

class AssessmentService {
  final _db = Supabase.instance.client;

  Future<int> getStudentId(String userId) async {
    final data = await _db
        .from('students')
        .select('id')
        .eq('profile_id', userId)
        .single();
    return data['id'] as int;
  }

  Future<List<AssessmentModel>> getAssessments(int studentId) async {
    final data = await _db
        .from('enrollments')
        .select('''
          section_id,
          sections!inner(
            courses(name, type)
          ),
          grades(
            midterm, midterm_total,
            final, final_total,
            quiz, quiz_total,
            participation, participation_total,
            attendance
          )
        ''')
        .eq('student_id', studentId);

    return (data as List).map((row) => AssessmentModel.fromMap(row)).toList();
  }
}
