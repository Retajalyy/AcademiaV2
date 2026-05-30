import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/registiration_model.dart';

class RegistrationService {
  final _db = Supabase.instance.client;

  // ── Has any plans? ────────────────────────────────────────────────────────
  Future<bool> fetchHasActivePlans() async {
    final data = await _db
        .from('registration_windows')
        .select('id')
        .limit(1);
    return (data as List).isNotEmpty;
  }

  // ── Current registration status ───────────────────────────────────────────
  Future<RegistrationStatusModel> fetchRegistrationStatus() async {
    final row = await _db
        .from('registration_windows')
        .select('status, registration_open, registration_close')
        .order('id', ascending: false)
        .limit(1)
        .maybeSingle();

    if (row == null) {
      return const RegistrationStatusModel(
        isOpen: false,
        message: 'No registration window created yet',
        closingDate: '',
        daysRemaining: '',
      );
    }

    final isOpen      = row['status'] == 'open';
    final closeRaw    = row['registration_close'] as String?;
    String closing    = closeRaw != null ? _fmt(closeRaw) : '';
    String remaining  = '';

    if (closeRaw != null) {
      final diff = DateTime.parse(closeRaw).difference(DateTime.now()).inDays;
      remaining = diff > 0 ? '$diff days remaining' : 'Closing today';
    }

    return RegistrationStatusModel(
      isOpen:        isOpen,
      message:       isOpen ? 'Registration is currently open' : 'Registration is closed',
      closingDate:   closing,
      daysRemaining: remaining,
    );
  }

  // ── Active plans list ─────────────────────────────────────────────────────
  Future<List<RegistrationPlanModel>> fetchActivePlans() async {
    final windows = await _db
        .from('registration_windows')
        .select('id, next_semester_label, next_year_label, registration_open, registration_close, status')
        .order('id', ascending: false);

    final plans = <RegistrationPlanModel>[];

    for (final w in windows as List) {
      final windowId = w['id'] as int;

      // Groups for this window
      final groups = await _db
          .from('registration_groups')
          .select('id, faculty, major, level')
          .eq('window_id', windowId);

      if ((groups as List).isEmpty) continue;

      final firstGroup  = groups.first;
      final faculty     = firstGroup['faculty'] as String? ?? '';
      final major       = firstGroup['major']   as String? ?? '';
      final level       = firstGroup['level']   as int?    ?? 1;
      final groupIds    = groups.map((g) => g['id'] as int).toList();

      // Total matching students
      final totalStudents = await _db
          .from('students')
          .select('id')
          .eq('faculty', faculty)
          .eq('major', major)
          .eq('level', level);
      final totalCount = (totalStudents as List).length;

      // Enrolled students (registered in this window)
      final enrolled = await _db
          .from('student_registrations')
          .select('id, registration_groups!inner(window_id)')
          .eq('registration_groups.window_id', windowId);
      final enrolledCount = (enrolled as List).length;

      // Distinct course count
      final sections = await _db
          .from('registration_group_sections')
          .select('course_code')
          .inFilter('group_id', groupIds);
      final courseCount = (sections as List)
          .map((s) => s['course_code'])
          .toSet()
          .length;

      final progress    = totalCount > 0 ? (enrolledCount / totalCount).clamp(0.0, 1.0) : 0.0;
      final enrolledPct = totalCount > 0
          ? '${(progress * 100).toStringAsFixed(0)}%'
          : '0%';

      plans.add(RegistrationPlanModel(
        id:           windowId.toString(),
        title:        '${w['next_semester_label'] ?? 'Semester'} · ${w['next_year_label'] ?? ''}',
        faculty:      '$faculty · Level $level · $major',
        progress:     progress,
        progressText: '$enrolledCount/$totalCount students',
        courses:      courseCount.toString(),
        enrolled:     enrolledPct,
        groups:       groups.length.toString(),
        openDate:     _fmt(w['registration_open']),
        closeDate:    _fmt(w['registration_close']),
        isActive:     w['status'] == 'open',
      ));
    }

    return plans;
  }

  // ── Create plan ───────────────────────────────────────────────────────────
  Future<RegistrationPlanModel> createPlan(Map<String, dynamic> data) async {
    final semLabel  = data['semesterLabel']    as String;
    final yearLabel = data['yearLabel']        as String;
    final semNumber = data['semesterNumber']   as int;
    final faculty   = data['faculty']          as String;
    final major     = data['major']            as String;
    final level     = data['level']            as int;
    final regOpen   = data['registrationOpen'] as String;
    final regClose  = data['registrationClose'] as String;
    final semStart  = data['semesterStart']    as String;
    final weekCount = data['weekCount']        as int? ?? 16;

    // 1. Find or create semester
    final existingSem = await _db
        .from('semesters')
        .select('id')
        .eq('number', semNumber)
        .maybeSingle();

    final int semId;
    if (existingSem != null) {
      semId = existingSem['id'] as int;
    } else {
      final newSem = await _db
          .from('semesters')
          .insert({'number': semNumber, 'label': semLabel, 'year_label': yearLabel})
          .select('id')
          .single();
      semId = newSem['id'] as int;
    }

    // 2. Create registration window
    final window = await _db
        .from('registration_windows')
        .insert({
          'status':               'open',
          'next_semester_label':  semLabel,
          'next_year_label':      yearLabel,
          'registration_open':    regOpen,
          'registration_close':   regClose,
          'semester_start':       semStart,
          'semester_id':          semId,
          'week_count':           weekCount,
        })
        .select('id')
        .single();

    final windowId = window['id'] as int;
    // Groups are created by the 3-screen plan admin flow, not here

    return RegistrationPlanModel(
      id:           windowId.toString(),
      title:        '$semLabel · $yearLabel',
      faculty:      '$faculty · Level $level · $major',
      progress:     0.0,
      progressText: '0/0 students',
      courses:      '0',
      enrolled:     '0%',
      groups:       '1',
      openDate:     _fmt(regOpen),
      closeDate:    _fmt(regClose),
      isActive:     true,
    );
  }

  // ── Toggle open / closed / not_opened_yet ────────────────────────────────
  Future<void> updateWindowStatus(int windowId, String status) async {
    await _db
        .from('registration_windows')
        .update({'status': status})
        .eq('id', windowId);
  }

  // ── Edit semester label & academic year ───────────────────────────────────
  Future<void> updateWindowLabels(
      int windowId, String semLabel, String yearLabel) async {
    await _db.from('registration_windows').update({
      'next_semester_label': semLabel,
      'next_year_label':     yearLabel,
    }).eq('id', windowId);
  }

  // ── Close (soft-delete) a plan ────────────────────────────────────────────
  Future<bool> deletePlan(String planId) async {
    await _db
        .from('registration_windows')
        .update({'status': 'closed'})
        .eq('id', int.parse(planId));
    return true;
  }

  // ── Helper ────────────────────────────────────────────────────────────────
  String _fmt(dynamic raw) {
    if (raw == null) return 'N/A';
    try {
      final d = DateTime.parse(raw as String);
      const m = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${m[d.month]} ${d.day}, ${d.year}';
    } catch (_) {
      return raw.toString();
    }
  }
}
