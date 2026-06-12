import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/course_admin_model.dart';

class CourseAdminService {
  final _db = Supabase.instance.client;

  Future<List<Map<String, String>>> fetchFaculties() async {
    final data = await _db.from('faculties').select('code, name').order('name');
    return (data as List)
        .map((r) => {'code': r['code'] as String, 'name': r['name'] as String})
        .toList();
  }

  Future<List<Map<String, String>>> fetchMajors() async {
    final data = await _db
        .from('majors')
        .select('code, name, faculty_code')
        .order('name');
    return (data as List)
        .map((r) => {
              'code':         r['code']         as String,
              'name':         r['name']         as String,
              'faculty_code': r['faculty_code'] as String,
            })
        .toList();
  }

  Future<CourseStatsModel> fetchStats() async {
    final results = await Future.wait([
      _db.from('courses').select('id'),
      _db.from('professors').select('id'),
      _db.from('faculties').select('code'),
    ]);
    return CourseStatsModel(
      totalCourses: (results[0] as List).length,
      professors:   (results[1] as List).length,
      faculties:    (results[2] as List).length,
    );
  }

  Future<List<CourseAdminModel>> fetchCourses(
    Map<String, String> facMap,
    Map<String, String> majMap,
  ) async {
    // Resolve which course codes belong to the active/open registration window
    Set<String> activeCodes = {};
    String semesterLabel = '';
    try {
      final window = await _db
          .from('registration_windows')
          .select('id, next_semester_label, next_year_label')
          .inFilter('status', ['active', 'open'])
          .limit(1)
          .maybeSingle();

      if (window != null) {
        semesterLabel =
            '${window['next_semester_label'] ?? ''} ${window['next_year_label'] ?? ''}'
                .trim();

        final groups = await _db
            .from('registration_groups')
            .select('id')
            .eq('window_id', window['id'] as int);

        final groupIds =
            (groups as List).map((g) => g['id'] as int).toList();

        if (groupIds.isNotEmpty) {
          final sections = await _db
              .from('registration_group_sections')
              .select('course_code')
              .inFilter('group_id', groupIds);

          activeCodes = (sections as List)
              .map((s) => s['course_code'] as String)
              .toSet();
        }
      }
    } catch (_) {
      // Fall through — courses will render without active labels
    }

    final data = await _db
        .from('courses')
        .select('id, name, code, credit_hours, type, year_level, faculty_code, major_code')
        .order('name');

    return (data as List).map((row) {
      final code     = row['code'] as String? ?? '';
      final isActive = activeCodes.contains(code);
      return CourseAdminModel.fromDb(
        row, facMap, majMap,
        isActive:      isActive,
        semesterLabel: isActive ? semesterLabel : '',
      );
    }).toList();
  }

  Future<CourseAdminModel> addCourse(
    CourseFormModel form,
    Map<String, String> facMap,
    Map<String, String> majMap,
  ) async {
    final row = await _db
        .from('courses')
        .insert({
          'name':         form.name,
          'code':         _generateCode(form.name, form.level),
          'credit_hours': int.tryParse(form.credits) ?? 3,
          'type':         form.type,
          'year_level':   _yearToInt(form.level),
          'faculty_code': form.facultyCode.isEmpty ? null : form.facultyCode,
          'major_code':   form.majorCode.isEmpty  ? null : form.majorCode,
        })
        .select('id, name, credit_hours, type, year_level, faculty_code, major_code')
        .single();
    return CourseAdminModel.fromDb(row, facMap, majMap);
  }

  Future<CourseAdminModel> editCourse(
    String id,
    CourseFormModel form,
    Map<String, String> facMap,
    Map<String, String> majMap,
  ) async {
    final row = await _db
        .from('courses')
        .update({
          'name':         form.name,
          'credit_hours': int.tryParse(form.credits) ?? 3,
          'type':         form.type,
          'year_level':   _yearToInt(form.level),
          'faculty_code': form.facultyCode.isEmpty ? null : form.facultyCode,
          'major_code':   form.majorCode.isEmpty  ? null : form.majorCode,
        })
        .eq('id', int.parse(id))
        .select('id, name, credit_hours, type, year_level, faculty_code, major_code')
        .single();
    return CourseAdminModel.fromDb(row, facMap, majMap);
  }

  Future<void> deleteCourse(String id) async {
    await _db.from('courses').delete().eq('id', int.parse(id));
  }

  // Auto-generate a short unique code from course name + year level + timestamp
  String _generateCode(String name, String level) {
    final initials = name
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase())
        .take(4)
        .join();
    final year   = _yearToInt(level);
    final suffix = (DateTime.now().millisecondsSinceEpoch % 1000)
        .toString()
        .padLeft(3, '0');
    return '$initials$year$suffix';
  }

  int _yearToInt(String level) {
    final match = RegExp(r'\d').firstMatch(level);
    return match != null ? int.parse(match.group(0)!) : 1;
  }
}
