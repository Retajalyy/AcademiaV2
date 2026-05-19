import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/fee_model.dart';

class FeesService {
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

  Future<List<FeeModel>> fetchFees() async {
    final studentId = await _getStudentId();
    final data = await _db
        .from('student_fees')
        .select('id, label, amount, currency, due_date, is_paid, paid_on')
        .eq('student_id', studentId)
        .order('is_paid')        // unpaid first
        .order('due_date');

    return (data as List).map((row) => FeeModel.fromMap(row)).toList();
  }
}
