import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/exam_model.dart';

class ExamService {
  final _db = Supabase.instance.client;

  Future<List<ExamModel>> fetchExams() async {
    final userId = _db.auth.currentUser!.id;
    final studentRow = await _db
        .from('students')
        .select('id, level')
        .eq('profile_id', userId)
        .single();
    final studentId = studentRow['id'] as int;
    final rawLevel = studentRow['level'] as int?;
    final studentLevel = rawLevel != null ? 'Level $rawLevel' : null;

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

      return ExamModel.fromMap(row, status, level: studentLevel);
    }).toList();
  }

  Future<ExamPeriodModel?> fetchExamPeriod() async {
    final userId = _db.auth.currentUser!.id;
    final studentRow = await _db
        .from('students')
        .select('faculty')
        .eq('profile_id', userId)
        .single();
    final facultyCode = studentRow['faculty'] as String? ?? '';

    final today = DateTime.now().toIso8601String().substring(0, 10);
    final row = await _db
        .from('exam_schedule_uploads')
        .select('exam_type, semester, academic_year, period_from, period_to')
        .eq('faculty_code', facultyCode)
        .lte('period_from', today)
        .gte('period_to', today)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (row == null) return null;

    final examType    = row['exam_type']     as String? ?? '';
    final semester    = row['semester']      as String? ?? '';
    final academicYear = row['academic_year'] as String? ?? '';
    final yearSuffix  = academicYear.split('/').lastOrNull ?? academicYear;

    final title = [
      if (examType.isNotEmpty) '$examType Exams',
      if (semester.isNotEmpty) '$semester $yearSuffix',
    ].join(' · ');

    return ExamPeriodModel(
      title:    title,
      subtitle: '${_fmtDate(row['period_from'])} – ${_fmtDate(row['period_to'])}',
    );
  }

  static String _fmtDate(dynamic raw) {
    if (raw == null) return '';
    try {
      final d = DateTime.parse(raw as String);
      const m = ['','Jan','Feb','Mar','Apr','May','Jun',
                     'Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${m[d.month]} ${d.day}, ${d.year}';
    } catch (_) {
      return raw.toString();
    }
  }
}
