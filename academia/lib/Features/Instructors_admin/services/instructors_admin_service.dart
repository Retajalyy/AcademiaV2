import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/instructor_admin_model.dart';

class InstructorsAdminService {
  final _db = Supabase.instance.client;

  Future<List<InstructorAdminModel>> fetchInstructors({
    String? departmentCode,
  }) async {
    // ── 1. Professors + profiles + sections (with courses) ────────────
    var query = _db.from('professors').select('''
      id, department,
      profiles!inner(uni_id, full_name, fname, lname),
      sections(id, type, courses(name))
    ''');

    if (departmentCode != null) {
      query = query.eq('department', departmentCode);
    }

    final profData = await query.order('id');
    final professors = (profData as List).cast<Map<String, dynamic>>();
    if (professors.isEmpty) return [];

    // ── 2. Collect all section IDs ─────────────────────────────────────
    final sectionIds = professors
        .expand((p) => (p['sections'] as List? ?? []))
        .map((s) => s['id'])
        .whereType<int>()
        .toList();

    // ── 3. Fetch groups for those sections (separate query) ────────────
    final Map<int, List<String>> sectionGroups = {};
    if (sectionIds.isNotEmpty) {
      final rgsData = await _db
          .from('registration_group_sections')
          .select('section_id, registration_groups(label, major, level)')
          .inFilter('section_id', sectionIds);

      for (final r in rgsData as List) {
        final sId = r['section_id'] as int?;
        if (sId == null) continue;
        final grp = r['registration_groups'];
        if (grp is! Map) continue;
        final major  = grp['major']?.toString() ?? '';
        final level  = grp['level']?.toString() ?? '';
        final label  = grp['label']?.toString() ?? '';
        final suffix = label.isNotEmpty ? label[label.length - 1] : '';
        final short  = '$major$level$suffix';
        if (short.length > 1) {
          sectionGroups.putIfAbsent(sId, () => []).add(short);
        }
      }
    }

    // ── 4. Build models ────────────────────────────────────────────────
    return professors.map((row) {
      final profile  = row['profiles'] as Map<String, dynamic>;
      final name     = profile['full_name'] as String?
          ?? '${profile['fname']} ${profile['lname']}';
      final sections = row['sections'] as List? ?? [];

      final hasLecture = sections.any(
          (s) => (s['type'] as String?)?.toLowerCase() == 'lecture');

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

      return InstructorAdminModel(
        id:         row['id']          as int,
        uniId:      profile['uni_id']  as String? ?? '',
        name:       name,
        department: row['department']  as String? ?? '',
        role:       hasLecture ? 'Professor' : 'T.A.',
        courses:    courses,
        groups:     groups,
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
