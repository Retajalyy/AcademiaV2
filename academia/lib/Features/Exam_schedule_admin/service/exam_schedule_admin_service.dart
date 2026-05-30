import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/exam_schedule_admin_model.dart';

class ExamScheduleAdminService {
  final _db = Supabase.instance.client;

  Future<List<SectionOption>> fetchSections() async {
    final data = await _db
        .from('sections')
        .select('id, type, courses(name, code)')
        .order('id');

    return (data as List).map((row) {
      final course = row['courses'] as Map<String, dynamic>? ?? {};
      return SectionOption(
        sectionId:  row['id'] as int,
        courseName: course['name'] as String? ?? '',
        courseCode: course['code'] as String? ?? '',
        type:       row['type']   as String? ?? '',
      );
    }).toList();
  }

  Future<List<ExamScheduleEntry>> fetchPublishedExams() async {
    final data = await _db
        .from('exam_schedules')
        .select('course_name, exam_type, exam_date, start_time, end_time, room')
        .order('exam_date', ascending: true);

    final list = data as List;

    // Deduplicate by (course_name, exam_type, exam_date, start_time)
    final seen = <String, ExamScheduleEntry>{};
    final counts = <String, int>{};

    for (final row in list) {
      final key =
          '${row['course_name']}_${row['exam_type']}_${row['exam_date']}_${row['start_time']}';
      seen.putIfAbsent(
        key,
        () => ExamScheduleEntry(
          courseName:   row['course_name']  as String? ?? '',
          examType:     row['exam_type']    as String? ?? '',
          examDate:     row['exam_date']    as String? ?? '',
          startTime:    _fmt(row['start_time'] as String?),
          endTime:      _fmt(row['end_time']   as String?),
          room:         row['room']         as String? ?? '',
          studentCount: 0,
        ),
      );
      counts[key] = (counts[key] ?? 0) + 1;
    }

    return seen.entries.map((e) {
      final entry = e.value;
      return ExamScheduleEntry(
        courseName:   entry.courseName,
        examType:     entry.examType,
        examDate:     entry.examDate,
        startTime:    entry.startTime,
        endTime:      entry.endTime,
        room:         entry.room,
        studentCount: counts[e.key] ?? 0,
      );
    }).toList();
  }

  Future<int> publishExamSchedule({
    required int sectionId,
    required String courseName,
    required String examDate,
    required String startTime,
    required String endTime,
    required String room,
    required String examType,
  }) async {
    // Find all students enrolled in this section
    final enrollments = await _db
        .from('enrollments')
        .select('student_id')
        .eq('section_id', sectionId);

    final studentIds = (enrollments as List)
        .map((e) => e['student_id'] as int?)
        .whereType<int>()
        .toList();

    if (studentIds.isEmpty) {
      throw Exception('No students enrolled in this section.');
    }

    final rows = studentIds
        .map((id) => {
              'student_id':  id,
              'section_id':  sectionId,
              'course_name': courseName,
              'exam_date':   examDate,
              'start_time':  startTime,
              'end_time':    endTime,
              'room':        room,
              'exam_type':   examType,
            })
        .toList();

    await _db.from('exam_schedules').insert(rows);
    return studentIds.length;
  }

  static String _fmt(String? raw) {
    if (raw == null || raw.length < 5) return '';
    return raw.substring(0, 5);
  }
}
