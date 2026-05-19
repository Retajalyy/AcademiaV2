import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/registration_model.dart';

class RegistrationService {
  final _db = Supabase.instance.client;

  Future<int> _getStudentId() async {
    final userId = _db.auth.currentUser!.id;
    final row = await _db
        .from('students')
        .select('id')
        .eq('profile_id', userId)
        .single();
    return row['id'] as int;
  }

  Future<RegistrationState> fetchRegistrationState() async {
    final row = await _db
        .from('registration_windows')
        .select('status')
        .order('id', ascending: false)
        .limit(1)
        .maybeSingle();

    if (row == null) return RegistrationState.notOpenedYet;
    switch (row['status'] as String) {
      case 'open':   return RegistrationState.open;
      case 'closed': return RegistrationState.closed;
      default:       return RegistrationState.notOpenedYet;
    }
  }

  Future<List<CourseGroup>> fetchGroups(String semesterTab) async {
    final data = await _db
        .from('registration_groups')
        .select('''
          id, label, total_credits,
          registration_group_sections(
            course_name, course_code, credit_hours,
            lecture_day, lecture_start, lecture_end, lecture_instructor, lecture_room,
            section_day, section_start, section_end, section_instructor, section_room,
            prerequisite_warning, is_locked
          )
        ''')
        .order('id');

    return (data as List).map((g) {
      final sections = (g['registration_group_sections'] as List? ?? []);
      return CourseGroup(
        id: g['id'].toString(),
        label: g['label'] as String,
        creditHours: (g['total_credits'] as int?) ?? 0,
        lectures: sections.map((s) {
          final secStart = s['section_start'] as String?;
          final secEnd   = s['section_end']   as String?;
          return CourseLecture(
            courseCode:         s['course_code']        as String,
            courseName:         s['course_name']        as String,
            creditHours:        (s['credit_hours'] as int?) ?? 3,
            day:                s['lecture_day']        as String? ?? '',
            timeFrom:           s['lecture_start']      as String? ?? '',
            timeTo:             s['lecture_end']        as String? ?? '',
            instructor:         s['lecture_instructor'] as String? ?? '',
            room:               s['lecture_room']       as String?,
            sectionDay:         s['section_day']        as String?,
            sectionInstructor:  s['section_instructor'] as String?,
            sectionTime: (secStart != null && secEnd != null)
                ? '$secStart - $secEnd'
                : null,
            sectionRoom:          s['section_room']           as String?,
            prerequisiteWarning:  s['prerequisite_warning']   as String?,
            isLocked:             s['is_locked']              as bool? ?? false,
          );
        }).toList(),
      );
    }).toList();
  }

  Future<SemesterInfo> fetchSemesterInfo() async {
    final row = await _db
        .from('registration_windows')
        .select('next_semester_label, next_year_label, registration_open, registration_close, semester_start')
        .order('id', ascending: false)
        .limit(1)
        .single();

    return SemesterInfo(
      semester:           row['next_semester_label'] as String? ?? 'Semester B',
      year:               row['next_year_label']     as String? ?? '',
      registrationOpen:   _fmt(row['registration_open']),
      registrationClosed: _fmt(row['registration_close']),
      semesterStart:      _fmt(row['semester_start']),
    );
  }

  Future<BalanceInfo> fetchBalanceInfo() async {
    final studentId = await _getStudentId();
    final row = await _db
        .from('student_fees')
        .select('amount, currency, due_date, is_paid')
        .eq('student_id', studentId)
        .order('id', ascending: false)
        .limit(1)
        .maybeSingle();

    if (row == null) {
      return const BalanceInfo(
        outstandingAmount: 0,
        currency: 'EGP',
        isPaid: true,
        dueDate: '',
      );
    }

    return BalanceInfo(
      outstandingAmount: (row['amount'] as num).toDouble(),
      currency:          row['currency']  as String? ?? 'EGP',
      isPaid:            row['is_paid']   as bool?   ?? false,
      dueDate:           _fmt(row['due_date']),
    );
  }

  Future<void> submitRegistration({
    required String groupId,
    required List<String> forceAddedCodes,
  }) async {
    final userId = _db.auth.currentUser!.id;

    // Resolve student id
    final sRow = await _db
        .from('students')
        .select('id')
        .eq('profile_id', userId)
        .single();
    final studentId = sRow['id'] as int;

    // Save / overwrite the student's registration group
    await _db.from('student_registrations').upsert({
      'student_id': studentId,
      'group_id':   int.parse(groupId),
    }, onConflict: 'student_id');

    // Fetch sections linked to this group
    final sections = await _db
        .from('registration_group_sections')
        .select('section_id, course_code, is_locked')
        .eq('group_id', int.parse(groupId));

    // Build list of section IDs to enroll in:
    // include unlocked courses + locked courses that the student force-added
    final sectionIds = (sections as List)
        .where((s) {
          final locked = s['is_locked'] as bool? ?? false;
          final code   = s['course_code'] as String;
          return !locked || forceAddedCodes.contains(code);
        })
        .map((s) => s['section_id'] as int?)
        .whereType<int>()
        .toList();

    if (sectionIds.isEmpty) return;

    // Remove old enrollments for this student
    await _db.from('enrollments').delete().eq('student_id', studentId);

    // Create new enrollments
    await _db.from('enrollments').insert(
      sectionIds.map((id) => {'student_id': studentId, 'section_id': id}).toList(),
    );
  }

  Future<String> initiatePayment({required double amount}) async {
    // TODO: redirect to payment portal
    return '';
  }

  String _fmt(dynamic raw) {
    if (raw == null) return 'N/A';
    try {
      final dt = DateTime.parse(raw as String);
      const m = ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${m[dt.month]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return raw.toString();
    }
  }
}
