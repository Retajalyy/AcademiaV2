import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course_model.dart';

class CourseService {
  final _db = Supabase.instance.client;

  Future<int> getStudentId(String userId) async {
    final data = await _db
        .from('students')
        .select('id')
        .eq('profile_id', userId)
        .single();
    return data['id'] as int;
  }

  Future<List<CourseModel>> getEnrolledCourses(int studentId) async {
    final data = await _db
        .from('enrollments')
        .select('''
          sections!inner(
            id,
            room,
            courses(name, code, credit_hours, type),
            professors(
              profiles(full_name)
            ),
            schedules(day, start_time, end_time)
          )
        ''')
        .eq('student_id', studentId);

    return (data as List).map((row) => CourseModel.fromMap(row)).toList();
  }
}
