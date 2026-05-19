import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/semester_result_model.dart';
import '../models/course_result_model.dart';

class ResultsService {
  final _db = Supabase.instance.client;

  Future<int> getStudentId(String userId) async {
    final data = await _db
        .from('students')
        .select('id')
        .eq('profile_id', userId)
        .single();
    return data['id'] as int;
  }

  Future<List<SemesterResultModel>> getSemesterResults(int studentId) async {
    final data = await _db
        .from('semester_results')
        .select('id, gpa, status, semesters(number, label, year_label)')
        .eq('student_id', studentId)
        .order('number', referencedTable: 'semesters', ascending: false);

    return (data as List)
        .map((row) => SemesterResultModel.fromMap(row))
        .toList();
  }

  Future<List<CourseResultModel>> getCourseResults(int semesterResultId) async {
    final data = await _db
        .from('course_results')
        .select('course_name, grade, gpa_points, letter')
        .eq('semester_result_id', semesterResultId);

    return (data as List)
        .map((row) => CourseResultModel.fromMap(row))
        .toList();
  }
}
