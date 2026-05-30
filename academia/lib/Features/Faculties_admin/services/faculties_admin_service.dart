import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/faculty_admin_model.dart';

class FacultiesAdminService {
  final _db = Supabase.instance.client;

  Future<List<FacultyAdminModel>> fetchFaculties() async {
    // 1. Fetch all faculties
    final facultiesData = await _db
        .from('faculties')
        .select('code, name')
        .order('name');

    final faculties = (facultiesData as List).cast<Map<String, dynamic>>();

    // 2. Fetch all data in parallel for all faculties
    final results = await Future.wait([
      _db.from('majors').select('code, name, faculty_code'),
      _db.from('students').select('faculty'),
      _db.from('professors').select('department'),
      _db.from('courses').select('faculty_code'),
    ]);

    final majors      = (results[0] as List).cast<Map<String, dynamic>>();
    final students    = (results[1] as List).cast<Map<String, dynamic>>();
    final professors  = (results[2] as List).cast<Map<String, dynamic>>();
    final courses     = (results[3] as List).cast<Map<String, dynamic>>();

    return faculties.map((f) {
      final code = f['code'] as String;
      final name = f['name'] as String;

      final majorNames = majors
          .where((m) => m['faculty_code'] == code)
          .map((m) => m['name'] as String)
          .toList();

      final studentCount    = students.where((s) => s['faculty'] == code).length;
      final instructorCount = professors.where((p) => p['department'] == code).length;
      final courseCount     = courses.where((c) => c['faculty_code'] == code).length;

      return FacultyAdminModel(
        code:            code,
        name:            name,
        majorNames:      majorNames,
        studentCount:    studentCount,
        instructorCount: instructorCount,
        courseCount:     courseCount,
      );
    }).toList();
  }
}
