import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/course_detail_model.dart';

class CourseDetailsService {
  final _db = Supabase.instance.client;

  Future<CourseDetailsModel> fetchCourseDetails(int courseId) async {
    final userId = _db.auth.currentUser!.id;

    final results = await Future.wait([
      _db.from('courses').select('name, credit_hours').eq('id', courseId).maybeSingle(),
      _db.from('students').select('id').eq('profile_id', userId).maybeSingle(),
    ]);

    final courseRow  = results[0];
    final studentRow = results[1];
    final courseName = courseRow?['name']         as String? ?? '';
    final credits    = courseRow?['credit_hours'] as int?    ?? 3;
    final studentId  = studentRow?['id']          as int?;

    double classworkPercent   = 0;
    double assignmentsPercent = 0;
    double attendancePercent  = 0;
    List<CourseMaterial> materials = [];

    await Future.wait([
      _fetchGradeStats(studentId, courseId).then((g) {
        classworkPercent   = g['classwork']!;
        assignmentsPercent = g['assignments']!;
        attendancePercent  = g['attendance']!;
      }),
      _fetchMaterials(courseId).then((m) => materials = m),
    ]);

    return CourseDetailsModel(
      id:                 courseId.toString(),
      courseName:         courseName,
      doctorName:         '',
      credits:            credits,
      progress:           0,
      classworkPercent:   classworkPercent,
      assignmentsPercent: assignmentsPercent,
      attendancePercent:  attendancePercent,
      materials:          materials,
    );
  }

  Future<Map<String, double>> _fetchGradeStats(
      int? studentId, int courseId) async {
    const empty = {'classwork': 0.0, 'assignments': 0.0, 'attendance': 0.0};
    if (studentId == null) return empty;

    double classworkFraction   = 0;
    double assignmentsFraction = 0;
    double attendanceFraction  = 0;

    try {
      final sectionData = await _db
          .from('sections')
          .select('id')
          .eq('course_id', courseId);
      final sectionIds = (sectionData as List).map((s) => s['id'] as int).toList();
      if (sectionIds.isEmpty) return empty;

      // Classwork & assignments from grades table (returns 0–1 fractions)
      final enrollData = await _db
          .from('enrollments')
          .select('grades(participation, participation_total, quiz, quiz_total)')
          .eq('student_id', studentId)
          .inFilter('section_id', sectionIds);

      for (final e in enrollData as List) {
        final gradesRaw = e['grades'];
        final Map<String, dynamic>? g = gradesRaw is Map<String, dynamic>
            ? gradesRaw
            : (gradesRaw is List && gradesRaw.isNotEmpty)
                ? gradesRaw.first as Map<String, dynamic>
                : null;
        if (g == null) continue;

        final participation = (g['participation']       as num?)?.toDouble() ?? 0;
        final partTotal     = (g['participation_total'] as num?)?.toDouble() ?? 25;
        final quiz          = (g['quiz']                as num?)?.toDouble() ?? 0;
        final quizTotal     = (g['quiz_total']          as num?)?.toDouble() ?? 10;

        classworkFraction   = partTotal  > 0 ? (participation / partTotal).clamp(0.0, 1.0)  : 0;
        assignmentsFraction = quizTotal  > 0 ? (quiz          / quizTotal).clamp(0.0, 1.0)  : 0;
        break;
      }

      // Attendance from live tracking tables (attendance_sessions + attendance_records)
      final sessionsRaw = await _db
          .from('attendance_sessions')
          .select('id')
          .inFilter('section_id', sectionIds);
      final sessionIds = (sessionsRaw as List).map((s) => s['id'] as int).toList();

      if (sessionIds.isNotEmpty) {
        final recordsRaw = await _db
            .from('attendance_records')
            .select('is_present')
            .eq('student_id', studentId)
            .inFilter('session_id', sessionIds);

        final total   = sessionIds.length;
        final present = (recordsRaw as List)
            .where((r) => r['is_present'] == true)
            .length;
        attendanceFraction = total > 0 ? (present / total).clamp(0.0, 1.0) : 0;
      }
    } catch (_) {}

    return {
      'classwork':   classworkFraction,
      'assignments': assignmentsFraction,
      'attendance':  attendanceFraction,
    };
  }

  Future<List<CourseMaterial>> _fetchMaterials(int courseId) async {
    try {
      final mData = await _db
          .from('course_materials')
          .select('id, name, file_type, file_size_kb, file_url, uploaded_at')
          .eq('course_id', courseId)
          .order('uploaded_at', ascending: true);
      return (mData as List).map((m) => CourseMaterial.fromMap(m)).toList();
    } catch (_) {
      return [];
    }
  }
}
