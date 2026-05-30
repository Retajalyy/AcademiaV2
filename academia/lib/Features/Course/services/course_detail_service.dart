import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/course_detail_model.dart';

class CourseDetailsService {
  final _db = Supabase.instance.client;

  Future<CourseDetailsModel> fetchCourseDetails(int courseId) async {
    // Course info
    final courseRow = await _db
        .from('courses')
        .select('id, name, code, credit_hours')
        .eq('id', courseId)
        .maybeSingle();

    final courseName   = courseRow?['name']         as String? ?? '';
    final credits      = courseRow?['credit_hours'] as int?    ?? 3;

    // Materials from course_materials table
    List<CourseMaterial> materials = [];
    try {
      final mData = await _db
          .from('course_materials')
          .select('id, name, file_type, file_size_kb, file_url, uploaded_at')
          .eq('course_id', courseId)
          .order('uploaded_at', ascending: true);
      materials = (mData as List)
          .map((m) => CourseMaterial.fromMap(m))
          .toList();
    } catch (_) {}

    return CourseDetailsModel(
      id:                   courseId.toString(),
      courseName:           courseName,
      doctorName:           '',
      credits:              credits,
      progress:             0,
      classworkPercent:     0,
      assignmentsPercent:   0,
      attendancePercent:    0,
      materials:            materials,
    );
  }
}
