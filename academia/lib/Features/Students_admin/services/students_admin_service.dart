import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/student_admin_model.dart';

class StudentsAdminService {
  final _db = Supabase.instance.client;

  Future<List<StudentAdminModel>> fetchStudents({
    String? facultyCode,
  }) async {
    var query = _db
        .from('students')
        .select('''
          id, student_number, major, level, faculty, phone, avatar_url,
          profiles!inner(uni_id, full_name, fname, lname),
          student_registrations(
            registration_groups(label)
          ),
          semester_results(gpa)
        ''');

    if (facultyCode != null) {
      query = query.eq('faculty', facultyCode);
    }

    final data = await query.order('id');
    return (data as List)
        .map((r) => StudentAdminModel.fromMap(r))
        .toList();
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
      // Fallback if faculties table not accessible
      return [
        {'code': 'FCI', 'name': 'Computers and Information'},
        {'code': 'FBA', 'name': 'Business'},
        {'code': 'FLT', 'name': 'Languages & Translation'},
      ];
    }
  }
}
