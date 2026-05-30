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
    final enrollments = await _db
        .from('enrollments')
        .select('section_id')
        .eq('student_id', studentId);

    final sectionIds = (enrollments as List)
        .map((e) => e['section_id'])
        .where((id) => id != null)
        .map((id) => id is int ? id : int.tryParse(id.toString()))
        .whereType<int>()
        .toList();

    if (sectionIds.isEmpty) return [];

    // Fetch schedule info from registration_group_sections
    final data = await _db
        .from('registration_group_sections')
        .select(
          'course_name, course_code, credit_hours, '
          'lecture_instructor, lecture_day, lecture_start, lecture_end, lecture_room, '
          'section_id',
        )
        .inFilter('section_id', sectionIds);

    // Fetch course_id for each section_id
    final sectionsData = await _db
        .from('sections')
        .select('id, course_id')
        .inFilter('id', sectionIds);

    final sectionToCourseId = {
      for (final s in sectionsData as List)
        s['id'] as int: s['course_id'] as int,
    };

    return (data as List).map((row) {
      final sId = row['section_id'] as int? ?? 0;
      return CourseModel.fromRgs(row, courseId: sectionToCourseId[sId] ?? 0);
    }).toList();
  }
}
