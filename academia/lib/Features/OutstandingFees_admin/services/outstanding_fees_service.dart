import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/outstanding_fee_model.dart';

class OutstandingFeesService {
  final _db = Supabase.instance.client;

  Future<List<OutstandingFeeStudent>> fetchOutstandingFees() async {
    final data = await _db
        .from('student_fees')
        .select('''
          id, amount, due_date, reminder_sent,
          students!inner(
            id, faculty, major, level, avatar_url,
            profiles!inner(uni_id, full_name, fname, lname),
            student_registrations(registration_groups(label))
          )
        ''')
        .eq('is_paid', false)
        .order('due_date', ascending: true);

    // ── Group fee rows by student id ─────────────────────────────────────────
    final Map<int, List<Map<String, dynamic>>> grouped = {};
    for (final row in data as List) {
      final studentId = (row['students'] as Map)['id'] as int;
      grouped.putIfAbsent(studentId, () => []).add(row);
    }

    return grouped.entries.map((entry) {
      final rows    = entry.value;
      final student = rows.first['students'] as Map<String, dynamic>;
      final profile = student['profiles']   as Map<String, dynamic>;

      final name = (profile['full_name'] as String?)?.trim().isNotEmpty == true
          ? profile['full_name'] as String
          : '${profile['fname'] ?? ''} ${profile['lname'] ?? ''}'.trim();

      final regsRaw = student['student_registrations'];
      final regs = regsRaw is List
          ? regsRaw
          : (regsRaw is Map ? [regsRaw] : <dynamic>[]);
      String groupLabel = '';
      if (regs.isNotEmpty) {
        final grp = regs.last['registration_groups'];
        if (grp is Map) groupLabel = grp['label'] as String? ?? '';
      }

      // Aggregate across all fee rows for this student
      final feeIds = rows.map((r) => r['id'] as int).toList();
      final totalAmount = rows.fold<double>(
          0, (sum, r) => sum + _parseDouble(r['amount']));

      // Earliest due date
      final dueDates = rows
          .where((r) => r['due_date'] != null)
          .map((r) => DateTime.parse((r['due_date'] as String).substring(0, 10)))
          .toList()
        ..sort();
      final nearestDue = dueDates.isNotEmpty ? dueDates.first : DateTime.now();

      // Fees due within 10 days that haven't been reminded yet
      final now = DateTime.now();
      final unreminded = rows
          .where((r) {
            if (r['reminder_sent'] == true) return false;
            if (r['due_date'] == null) return false;
            final due = DateTime.parse((r['due_date'] as String).substring(0, 10));
            final days = due.difference(now).inDays;
            return days >= 0 && days <= 10;
          })
          .map((r) => r['id'] as int)
          .toList();

      return OutstandingFeeStudent(
        id:               student['id']       as int,
        feeIds:           feeIds,
        unremindedFeeIds: unreminded,
        name:             name,
        uniId:            profile['uni_id']   as String? ?? '',
        faculty:          student['faculty']  as String? ?? '',
        major:            student['major']    as String? ?? '',
        level:            (student['level']   as int?) ?? 1,
        groupLabel:       groupLabel,
        totalAmount:      totalAmount,
        nearestDueDate:   nearestDue,
        avatarUrl:        student['avatar_url'] as String?,
      );
    }).where((s) => !s.isRegistrationBlocked).toList()
      // Sort by nearest due date
      ..sort((a, b) => a.nearestDueDate.compareTo(b.nearestDueDate));
  }

  Future<List<Map<String, String>>> fetchFacultyFilters() async {
    try {
      final data = await _db
          .from('faculties')
          .select('code, name')
          .order('name');
      return (data as List)
          .map((r) => {'code': r['code'] as String, 'name': r['name'] as String})
          .toList();
    } catch (_) {
      return [
        {'code': 'FCI', 'name': 'Computers and Information'},
        {'code': 'FBA', 'name': 'Business'},
        {'code': 'FLT', 'name': 'Languages & Translation'},
      ];
    }
  }

  double _parseDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  // Only sends reminders for fees due in ≤10 days that haven't been reminded yet.
  Future<void> sendReminders(List<OutstandingFeeStudent> students) async {
    for (final s in students) {
      try {
        await _db.from('notifications').insert({
          'student_id': s.id,
          'title':      'Fee Payment Reminder',
          'body':       'You have outstanding fees totalling ${s.amountLabel.replaceAll(' outstanding', '')}. '
                        'Nearest due date: ${s.dueDateLabel}. Please pay before the due date.',
          'type':       'fee_reminder',
        });
        // Mark only the qualifying fees as reminded
        for (final feeId in s.unremindedFeeIds) {
          await _db
              .from('student_fees')
              .update({'reminder_sent': true})
              .eq('id', feeId);
        }
      } catch (_) {
        // Non-fatal: skip silently if a single insert fails
      }
    }
  }
}
