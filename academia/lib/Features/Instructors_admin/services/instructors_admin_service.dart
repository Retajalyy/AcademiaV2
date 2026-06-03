import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/instructor_admin_model.dart';

class InstructorsAdminService {
  final _db = Supabase.instance.client;

  Future<List<InstructorAdminModel>> fetchInstructors({
    String? departmentCode,
  }) async {
    // ── 1. Professors + profiles + sections via professor_id ──────────
    var query = _db.from('professors').select('''
      id, department, is_ta,
      profiles!inner(uni_id, full_name, fname, lname),
      sections!professor_id(id, type, courses(name))
    ''');

    if (departmentCode != null) {
      query = query.eq('department', departmentCode);
    }

    final profData  = await query.order('id');
    final professors = (profData as List).cast<Map<String, dynamic>>();
    if (professors.isEmpty) return [];

    // ── 2. For TAs also fetch sections via ta_id ──────────────────────
    final taIds = professors
        .where((p) => p['is_ta'] == true)
        .map((p) => p['id'] as int)
        .toList();

    final Map<int, List<Map<String, dynamic>>> taSectionsMap = {};
    if (taIds.isNotEmpty) {
      final taSectData = await _db
          .from('sections')
          .select('id, type, ta_id, courses(name)')
          .inFilter('ta_id', taIds);
      for (final s in taSectData as List) {
        final taId = s['ta_id'] as int?;
        if (taId != null) {
          taSectionsMap.putIfAbsent(taId, () => []).add(s);
        }
      }
    }

    // ── 3. Fetch majors grouped by faculty code ───────────────────────
    final majorsData = await _db.from('majors').select('code, name, faculty_code');
    final facultyMajors = <String, List<String>>{};
    for (final m in majorsData as List) {
      final fc   = m['faculty_code'] as String? ?? '';
      final name = m['name']         as String? ?? '';
      if (fc.isNotEmpty && name.isNotEmpty) {
        facultyMajors.putIfAbsent(fc, () => []).add(name);
      }
    }

    // ── 4. Collect all section IDs (both professor + TA sections) ─────
    final allSectionIds = <int>{};
    for (final p in professors) {
      final sRaw = p['sections'];
      final sList = sRaw is List ? sRaw : (sRaw is Map ? [sRaw] : <dynamic>[]);
      for (final s in sList) {
        final id = s['id'] as int?;
        if (id != null) allSectionIds.add(id);
      }
      final profId = p['id'] as int;
      for (final s in taSectionsMap[profId] ?? []) {
        final id = s['id'] as int?;
        if (id != null) allSectionIds.add(id);
      }
    }

    // ── 5. Fetch groups for all section IDs ───────────────────────────
    final Map<int, List<String>> sectionGroups = {};
    if (allSectionIds.isNotEmpty) {
      final rgsData = await _db
          .from('registration_group_sections')
          .select('section_id, registration_groups(label, major, level)')
          .inFilter('section_id', allSectionIds.toList());

      for (final r in rgsData as List) {
        final sId = r['section_id'] as int?;
        if (sId == null) continue;
        final grp = r['registration_groups'];
        if (grp is! Map) continue;
        final label  = grp['label']?.toString() ?? '';
        if (label.isNotEmpty) {
          sectionGroups.putIfAbsent(sId, () => []).add(label);
        }
      }
    }

    // ── 6. Build models ───────────────────────────────────────────────
    return professors.map((row) {
      final profile = row['profiles'] as Map<String, dynamic>;
      final name    = profile['full_name'] as String?
          ?? '${profile['fname']} ${profile['lname']}';

      final profId  = row['id'] as int;
      final isTA    = row['is_ta'] as bool? ?? false;

      // Merge sections from professor_id and ta_id
      final sRaw = row['sections'];
      final profSections = sRaw is List ? sRaw : (sRaw is Map ? [sRaw] : <dynamic>[]);
      final taSections   = taSectionsMap[profId] ?? [];
      final sections     = [...profSections, ...taSections];

      final courses = sections
          .map((s) {
            final c = s['courses'];
            return c is Map ? c['name'] as String? : null;
          })
          .whereType<String>()
          .toSet()
          .toList();

      final groups = sections
          .map((s) => s['id'] as int?)
          .whereType<int>()
          .expand((id) => sectionGroups[id] ?? <String>[])
          .toSet()
          .toList();

      final dept   = row['department'] as String? ?? '';
      final majors = facultyMajors[dept] ?? [];

      return InstructorAdminModel(
        id:         profId,
        uniId:      profile['uni_id']  as String? ?? '',
        name:       name,
        department: dept,
        role:       isTA ? 'T.A.' : 'Professor',
        courses:    courses,
        groups:     groups,
        majors:     majors,
      );
    }).toList();
  }

  Future<List<Map<String, String>>> fetchFacultyFilters() async {
    try {
      final data = await _db
          .from('faculties')
          .select('code, name')
          .order('name');
      return (data as List)
          .map((r) => {
                'code': r['code'] as String,
                'name': r['name'] as String,
              })
          .toList();
    } catch (_) {
      return [
        {'code': 'FCI', 'name': 'Computers and Information'},
        {'code': 'FBA', 'name': 'Business'},
        {'code': 'FLT', 'name': 'Languages & Translation'},
      ];
    }
  }
}
