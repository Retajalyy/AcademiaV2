import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/registration_model.dart';

class RegistrationService {
  final _db = Supabase.instance.client;

  // ── Internal helpers ──────────────────────────────────────────────────────

  Future<Map<String, dynamic>> _getStudentRow() async {
    final userId = _db.auth.currentUser!.id;
    return await _db
        .from('students')
        .select('id, faculty, major, level')
        .eq('profile_id', userId)
        .single();
  }

  // ── Public API ────────────────────────────────────────────────────────────

  Future<RegistrationState> fetchRegistrationState() async {
    final row = await _db
        .from('registration_windows')
        .select('id, status')
        .order('id', ascending: false)
        .limit(1)
        .maybeSingle();

    if (row == null) return RegistrationState.notOpenedYet;

    final status   = row['status'] as String;
    final windowId = row['id'];

    // If window is open, check if the student already registered in this window
    if (status == 'open') {
      final student   = await _getStudentRow();
      final studentId = student['id'] as int;

      final existing = await _db
          .from('student_registrations')
          .select('id, registration_groups!inner(window_id)')
          .eq('student_id', studentId)
          .eq('registration_groups.window_id', windowId)
          .maybeSingle();

      if (existing != null) return RegistrationState.done;

      // Student hasn't registered yet — check for unpaid fees in this window
      final feeRow = await _db
          .from('student_fees')
          .select('is_paid')
          .eq('student_id', studentId)
          .eq('window_id', windowId)
          .order('id', ascending: false)
          .limit(1)
          .maybeSingle();

      // feeRow == null → admin hasn't uploaded fees yet → allow registration
      if (feeRow != null && feeRow['is_paid'] == false) {
        return RegistrationState.feesRequired;
      }

      return RegistrationState.open;
    }

    switch (status) {
      case 'closed': return RegistrationState.closed;
      default:       return RegistrationState.notOpenedYet;
    }
  }

  Future<List<CourseGroup>> fetchGroups(String semesterTab) async {
    // 1. Student profile for filtering
    final student   = await _getStudentRow();
    final studentId = student['id'] as int;
    final faculty   = student['faculty'] as String?;
    final major     = student['major']   as String?;
    final level     = student['level']   as int?;

    // 2. Active registration window
    final windowRow = await _db
        .from('registration_windows')
        .select('id')
        .eq('status', 'open')
        .order('id', ascending: false)
        .limit(1)
        .maybeSingle();
    final windowId = windowRow?['id'];

    // 3. Fetch groups filtered by student's faculty/major/level
    final filters = <String, dynamic>{};
    if (windowId != null) filters['window_id'] = windowId;
    if (faculty  != null) filters['faculty']   = faculty;
    if (major    != null) filters['major']     = major;
    if (level    != null) filters['level']     = level;

    const select = '''
      id, label, total_credits,
      registration_group_sections(
        course_name, course_code, credit_hours,
        lecture_day, lecture_start, lecture_end, lecture_instructor, lecture_room,
        section_day, section_start, section_end, section_instructor, section_room,
        prerequisite_warning, is_locked, section_id
      )
    ''';

    final rawGroups = await _db
        .from('registration_groups')
        .select(select)
        .match(filters.cast<String, Object>())
        .order('id');

    // 4. Collect all section_ids across all groups
    final allSectionIds = (rawGroups as List)
        .expand((g) => (g['registration_group_sections'] as List? ?? []))
        .map((s) => s['section_id'])
        .whereType<int>()
        .toSet()
        .toList();

    // 5. Build section_id → course_id map
    Map<int, int> sectionToCourse = {};
    if (allSectionIds.isNotEmpty) {
      final sectionsData = await _db
          .from('sections')
          .select('id, course_id')
          .inFilter('id', allSectionIds);
      sectionToCourse = {
        for (final s in sectionsData as List)
          (s['id'] as int): (s['course_id'] as int),
      };
    }

    // 6. Fetch prerequisites for all courses in these groups
    final allCourseIds = sectionToCourse.values.toSet().toList();
    Map<int, List<int>> prereqMap = {};
    if (allCourseIds.isNotEmpty) {
      final prereqData = await _db
          .from('course_prerequisites')
          .select('course_id, prereq_id')
          .inFilter('course_id', allCourseIds);
      for (final p in prereqData as List) {
        final cId = p['course_id'] as int;
        final pId = p['prereq_id'] as int;
        prereqMap.putIfAbsent(cId, () => []).add(pId);
      }
    }

    // 7. Fetch student's passed course_ids from completed semester results
    Set<int> passedCourseIds = {};
    if (prereqMap.isNotEmpty) {
      final semResults = await _db
          .from('semester_results')
          .select('id')
          .eq('student_id', studentId);
      final semIds = (semResults as List).map((s) => s['id'] as int).toList();
      if (semIds.isNotEmpty) {
        final passed = await _db
            .from('course_results')
            .select('course_id')
            .inFilter('semester_result_id', semIds)
            .not('course_id', 'is', null)
            .neq('letter', 'F');
        passedCourseIds = (passed as List)
            .map((r) => r['course_id'] as int?)
            .whereType<int>()
            .toSet();
      }
    }

    // 8. Build CourseGroup list with dynamic prerequisite locking
    return rawGroups.map<CourseGroup>((g) {
      final sections = (g['registration_group_sections'] as List? ?? []);
      return CourseGroup(
        id:          g['id'].toString(),
        label:       g['label'] as String,
        creditHours: (g['total_credits'] as int?) ?? 0,
        lectures: sections.map<CourseLecture>((s) {
          final sectionId = s['section_id'] as int?;
          final courseId  = sectionId != null ? sectionToCourse[sectionId] : null;

          // Start with admin-set values, then override dynamically
          bool   isLocked     = s['is_locked']            as bool?   ?? false;
          String? prereqWarn  = s['prerequisite_warning'] as String?;

          if (courseId != null && prereqMap.containsKey(courseId)) {
            final unmet = prereqMap[courseId]!
                .where((pId) => !passedCourseIds.contains(pId))
                .toList();
            if (unmet.isNotEmpty) {
              isLocked    = true;
              prereqWarn ??= 'Prerequisite not completed';
            }
          }

          final secStart = s['section_start'] as String?;
          final secEnd   = s['section_end']   as String?;
          return CourseLecture(
            courseCode:          s['course_code']       as String,
            courseName:          s['course_name']       as String,
            creditHours:         (s['credit_hours']     as int?) ?? 3,
            day:                 s['lecture_day']       as String? ?? '',
            timeFrom:            s['lecture_start']     as String? ?? '',
            timeTo:              s['lecture_end']       as String? ?? '',
            instructor:          s['lecture_instructor'] as String? ?? '',
            room:                s['lecture_room']      as String?,
            sectionDay:          s['section_day']       as String?,
            sectionInstructor:   s['section_instructor'] as String?,
            sectionTime: (secStart != null && secEnd != null)
                ? '$secStart - $secEnd' : null,
            sectionRoom:         s['section_room']        as String?,
            prerequisiteWarning: prereqWarn,
            isLocked:            isLocked,
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
    final student   = await _getStudentRow();
    final studentId = student['id'] as int;

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
      currency:          row['currency'] as String? ?? 'EGP',
      isPaid:            row['is_paid']  as bool?   ?? false,
      dueDate:           _fmt(row['due_date']),
    );
  }

  Future<void> submitRegistration({
    required String groupId,
    required List<String> forceAddedCodes,
  }) async {
    await _db.rpc('enroll_student_sections', params: {
      'p_group_id':    int.parse(groupId),
      'p_force_codes': forceAddedCodes,
    });
  }

  Future<String> initiatePayment({required double amount}) async {
    return '';
  }

  String _fmt(dynamic raw) {
    if (raw == null) return 'N/A';
    try {
      final dt = DateTime.parse(raw as String);
      const m = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${m[dt.month]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return raw.toString();
    }
  }
}
