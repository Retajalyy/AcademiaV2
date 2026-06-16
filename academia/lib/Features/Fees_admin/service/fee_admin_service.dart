import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/fee_admin_model.dart';

class FeesAdminService {
  final _db = Supabase.instance.client;

  Future<FeesSummaryModel> fetchSummary() async {
    final feesData = await _db.from('student_fees').select('is_paid, amount');
    final window   = await _db
        .from('registration_windows')
        .select('next_semester_label, next_year_label')
        .order('id', ascending: false)
        .limit(1)
        .maybeSingle();

    final list = feesData as List;

    final semLabel  = window?['next_semester_label'] as String? ?? '';
    final yearLabel = window?['next_year_label']     as String? ?? '';
    final parts     = [semLabel, yearLabel].where((s) => s.isNotEmpty).toList();
    final semester  = parts.isEmpty ? 'Current Semester' : parts.join(' – ');

    if (list.isEmpty) {
      return FeesSummaryModel(
        semester: semester,
        paid: 0,
        progress: '0%',
        unpaid: 0,
        collectedRaw: 0,
        totalRaw: 0,
      );
    }

    final paidCount   = list.where((f) => f['is_paid'] == true).length;
    final unpaidCount = list.where((f) => f['is_paid'] == false).length;
    final collected   = list
        .where((f) => f['is_paid'] == true)
        .fold<double>(0, (s, f) => s + (f['amount'] as num).toDouble());
    final total = list
        .fold<double>(0, (s, f) => s + (f['amount'] as num).toDouble());
    final pct = total == 0 ? 0 : (collected / total * 100).round();

    return FeesSummaryModel(
      semester: semester,
      paid: paidCount,
      progress: '$pct%',
      unpaid: unpaidCount,
      collectedRaw: collected,
      totalRaw: total,
    );
  }

  Future<List<String>> fetchFaculties() async {
    final data = await _db
        .from('faculties')
        .select('name')
        .order('name');
    return ['All Faculties',
        ...(data as List).map((f) => f['name'] as String)];
  }

  Future<List<ActiveFeeModel>> fetchActiveFees() async {
    final data = await _db
        .from('student_fees')
        .select('id, amount, due_date, is_paid, currency, label')
        .order('id', ascending: false);

    final list = data as List;
    if (list.isEmpty) return [];

    // Group by label + amount + due_date to create one card per fee batch
    final grouped = <String, Map<String, dynamic>>{};
    for (final row in list) {
      final key = '${row['label']}_${row['amount']}_${row['due_date']}';
      grouped.putIfAbsent(key, () => {
        'label':    row['label']    ?? 'Tuition Fee',
        'amount':   row['amount'],
        'due_date': row['due_date'],
        'currency': row['currency'] ?? 'EGP',
        'total':    0,
        'paid':     0,
      });
      grouped[key]!['total'] = (grouped[key]!['total'] as int) + 1;
      if (row['is_paid'] == true) {
        grouped[key]!['paid'] = (grouped[key]!['paid'] as int) + 1;
      }
    }

    final today    = DateTime.now();
    final todayDay = DateTime(today.year, today.month, today.day);
    const months   = ['','Jan','Feb','Mar','Apr','May','Jun',
                          'Jul','Aug','Sep','Oct','Nov','Dec'];

    return grouped.values.map((g) {
      final total    = g['total'] as int;
      final paidCnt  = g['paid']  as int;
      final progress = total == 0 ? 0.0 : paidCnt / total;
      final amount   = (g['amount'] as num).toDouble();

      DateTime? dueDate;
      final rawDue = g['due_date'];
      if (rawDue != null) {
        try { dueDate = DateTime.parse(rawDue.toString().substring(0, 10)); }
        catch (_) {}
      }

      final isOverdue  = dueDate != null && dueDate.isBefore(todayDay);
      final dueDateStr = dueDate != null
          ? '${months[dueDate.month]} ${dueDate.day}, ${dueDate.year}'
          : 'N/A';
      final dueDateLabel = isOverdue
          ? 'Overdue — $dueDateStr'
          : 'Due $dueDateStr';

      return ActiveFeeModel(
        id:           '${g['label']}_${g['amount']}_${g['due_date']}',
        title:        g['label'] as String? ?? 'Tuition Fee',
        subtitle:     '$paidCnt of $total students paid',
        amount:       amount,
        progress:     progress,
        progressText: '${(progress * 100).round()}%',
        dueDate:      dueDateStr,
        rawDueDate:   dueDate,
        isOverdue:    isOverdue,
        dueDateLabel: dueDateLabel,
        icon:         Icons.menu_book_outlined,
      );
    }).toList();
  }

  Future<bool> submitFee(AddFeeFormModel form) async {
    final amount = double.tryParse(form.amount) ?? 0;
    if (amount <= 0) throw Exception('Invalid amount.');
    if (form.dueDate == null) throw Exception('Due date is required.');

    // Fetch current open registration window to scope the fee
    final windowData = await _db
        .from('registration_windows')
        .select('id')
        .eq('status', 'open')
        .order('id', ascending: false)
        .limit(1)
        .maybeSingle();
    final windowId = windowData?['id'] as int?;

    // Build student filter based on faculty / level selection
    final filters = <String, dynamic>{};
    if (form.faculty != null && form.faculty != 'All Faculties') {
      // students.faculty stores the code (e.g. 'CI'), not the display name
      final facultyRow = await _db
          .from('faculties')
          .select('code')
          .eq('name', form.faculty!)
          .maybeSingle();
      final code = facultyRow?['code'] as String?;
      if (code != null) {
        filters['faculty'] = code;
      }
    }
    if (form.level != null && form.level != 'All') {
      final lvl = int.tryParse(form.level!);
      if (lvl != null) filters['level'] = lvl;
    }

    final studentsData = filters.isEmpty
        ? await _db.from('students').select('id')
        : await _db
            .from('students')
            .select('id')
            .match(filters.cast<String, Object>());

    final students = studentsData as List;
    if (students.isEmpty) {
      throw Exception('No students found for the selected criteria.');
    }

    final dueDate = form.dueDate!.toIso8601String().substring(0, 10);
    final label   = form.feeType?.label ?? 'Tuition Fee';

    final rows = students.map((s) {
      final row = <String, dynamic>{
        'student_id': s['id'],
        'amount':     amount,
        'currency':   'EGP',
        'due_date':   dueDate,
        'is_paid':    false,
        'label':      label,
      };
      if (windowId != null) row['window_id'] = windowId;
      return row;
    }).toList();

    await _db.from('student_fees').insert(rows);
    return true;
  }

  Future<bool> remindUnpaid() async => true;

  /// Deletes this fee for all students who haven't paid it yet.
  /// Rows already marked as paid are left untouched so payment history
  /// isn't lost.
  Future<void> deleteFee(ActiveFeeModel fee) async {
    final builder = _db
        .from('student_fees')
        .delete()
        .eq('label', fee.title)
        .eq('amount', fee.amount)
        .eq('is_paid', false);

    if (fee.rawDueDate != null) {
      await builder.eq('due_date', fee.rawDueDate!.toIso8601String().substring(0, 10));
    } else {
      await builder.isFilter('due_date', null);
    }
  }

  /// Updates the amount/due date of this fee for all students who haven't
  /// paid it yet. Already-paid rows are left untouched.
  Future<void> editFee(
    ActiveFeeModel fee, {
    required double newAmount,
    required DateTime newDueDate,
  }) async {
    final newDueDateStr = newDueDate.toIso8601String().substring(0, 10);

    final builder = _db
        .from('student_fees')
        .update({'amount': newAmount, 'due_date': newDueDateStr})
        .eq('label', fee.title)
        .eq('amount', fee.amount)
        .eq('is_paid', false);

    if (fee.rawDueDate != null) {
      await builder.eq('due_date', fee.rawDueDate!.toIso8601String().substring(0, 10));
    } else {
      await builder.isFilter('due_date', null);
    }
  }
}
