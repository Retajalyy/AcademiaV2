import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/dashboard_model.dart';

class DashboardService {
  final _db = Supabase.instance.client;

  Future<DashboardModel> fetchDashboardData() async {
    final results = await Future.wait<dynamic>([
      _db.from('students').select('major'),                                    // [0]
      _db.from('professors').select('department'),                             // [1]
      _db.from('courses').select('id'),                                        // [2]
      _db.from('registration_windows')                                         // [3]
          .select('next_semester_label, semester_start, week_count')
          .order('id', ascending: false)
          .limit(1)
          .maybeSingle(),
      _db.from('student_fees').select('student_id').eq('is_paid', false),      // [4]
      _db.from('grades')                                                       // [5]
          .select('attendance, enrollments!inner(student_id)')
          .gt('attendance', 0),
      _db.from('password_reset_requests').select('id').eq('status', 'pending'), // [6]
      _db.from('student_fees')                                                  // [7]
          .select('due_date')
          .eq('is_paid', false)
          .order('due_date', ascending: true)
          .limit(1)
          .maybeSingle(),
    ]);

    final studentsList   = results[0] as List;
    final professorsList = results[1] as List;
    final coursesList    = results[2] as List;
    final window         = results[3] as Map<String, dynamic>?;
    final nearestDueRow  = results[7] as Map<String, dynamic>?;
    final unpaidFees     = results[4] as List;
    final gradesRaw      = results[5] as List;
    final resetRequests  = results[6] as List;

    // ── Counts ────────────────────────────────────────────────────────────
    final totalStudents = studentsList.length;
    final majors = studentsList
        .map((s) => s['major'] as String?)
        .whereType<String>()
        .toSet()
        .length;
    final instructors = professorsList.length;
    final faculties = professorsList
        .map((p) => p['department'] as String?)
        .whereType<String>()
        .toSet()
        .length;
    final totalCourses = coursesList.length;

    // ── Semester & week ───────────────────────────────────────────────────
    final semester  = window?['next_semester_label'] as String? ?? '--';
    final weekCount = (window?['week_count'] as int?) ?? 16;
    String academicWeek = '--';
    if (window?['semester_start'] != null) {
      final start = DateTime.parse(window!['semester_start'] as String);
      final now   = DateTime.now();
      if (now.isAfter(start)) {
        final week = (now.difference(start).inDays ~/ 7) + 1;
        academicWeek = 'Week ${week.clamp(1, weekCount)}';
      } else {
        academicWeek = 'Not started';
      }
    }

    // ── Pending: outstanding fees ─────────────────────────────────────────
    final studentsWithFees = unpaidFees
        .map((f) => f['student_id'])
        .toSet()
        .length;

    // ── Pending: password reset requests ──────────────────────────────────
    final pendingResets = resetRequests.length;

    // ── Pending: attendance thresholds (<75% warn, <60% block) ───────────
    final Map<dynamic, List<double>> studentAttendance = {};
    for (final g in gradesRaw) {
      final enrollment = g['enrollments'];
      final studentId  = enrollment is Map
          ? enrollment['student_id']
          : (enrollment is List && enrollment.isNotEmpty)
              ? enrollment.first['student_id']
              : null;
      if (studentId == null) continue;
      final att = (g['attendance'] as num?)?.toDouble();
      if (att == null) continue;
      studentAttendance.putIfAbsent(studentId, () => []).add(att);
    }

    int warningCount = 0;
    int blockedCount = 0;
    for (final attendances in studentAttendance.values) {
      final avg = attendances.reduce((a, b) => a + b) / attendances.length;
      if (avg < 60) {
        blockedCount++;
      } else if (avg < 75) {
        warningCount++;
      }
    }

    // ── Nearest unpaid fee due date ───────────────────────────────────────
    String feesDueSubtitle = 'No unpaid fees';
    if (studentsWithFees > 0) {
      final rawDue = nearestDueRow?['due_date'];
      if (rawDue != null) {
        try {
          final due  = DateTime.parse(rawDue.toString().substring(0, 10));
          final diff = due.difference(DateTime.now()).inDays;
          const m = ['','Jan','Feb','Mar','Apr','May','Jun',
                         'Jul','Aug','Sep','Oct','Nov','Dec'];
          final label = '${m[due.month]} ${due.day}';
          feesDueSubtitle = diff < 0
              ? 'Due $label · ${diff.abs()} day${diff.abs() == 1 ? '' : 's'} overdue'
              : diff == 0
                  ? 'Due today'
                  : 'Due $label · $diff day${diff == 1 ? '' : 's'} left';
        } catch (_) {
          feesDueSubtitle = 'Fees not yet paid';
        }
      } else {
        feesDueSubtitle = 'Fees not yet paid';
      }
    }

    // ── Build General Overview — always show all 3 core cards ─────────────
    final pendingTasks = <PendingTaskModel>[
      PendingTaskModel(
        type: 'notify',
        title: studentsWithFees == 0
            ? 'No outstanding fees'
            : '$studentsWithFees student${studentsWithFees == 1 ? '' : 's'} have outstanding fees',
        subtitle: feesDueSubtitle,
        count: studentsWithFees,
      ),
      PendingTaskModel(
        type: 'warn',
        title: warningCount == 0
            ? 'No students at absence warning'
            : '$warningCount student${warningCount == 1 ? '' : 's'} reached absence limit',
        subtitle: warningCount == 0
            ? 'All students within attendance limits'
            : '${(75).toInt()} % threshold · Formal warning issued',
        count: warningCount,
      ),
      PendingTaskModel(
        type: 'block',
        title: blockedCount == 0
            ? 'No students exceeded absence limit'
            : '$blockedCount student${blockedCount == 1 ? '' : 's'} exceeded absence limit',
        subtitle: blockedCount == 0
            ? 'No students blocked from exams'
            : '${(60).toInt()} % threshold · Blocked from final exam',
        count: blockedCount,
      ),
      if (pendingResets > 0)
        PendingTaskModel(
          type: 'reset',
          title: '$pendingResets student${pendingResets == 1 ? '' : 's'} with\na password reset request',
          subtitle: 'Pending reset · Requires admin action',
          count: pendingResets,
        ),
    ];

    return DashboardModel(
      totalStudents: _fmt(totalStudents),
      faculties:     faculties.toString(),
      majors:        majors.toString(),
      instructors:   _fmt(instructors),
      totalCourses:  totalCourses.toString(),
      academicWeek:  academicWeek,
      totalWeeks:    weekCount.toString(),
      semester:      semester,
      pendingTasks:  pendingTasks,
    );
  }

  // Format large numbers as e.g. 2.5K
  String _fmt(int n) => n >= 1000
      ? '${(n / 1000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}K'
      : n.toString();
}
