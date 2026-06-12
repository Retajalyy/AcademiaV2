import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/plan_admin_model.dart';

class PlanAdminService {
  final _db = Supabase.instance.client;

  // ── Fetch faculties from DB ───────────────────────────────────────────────
  Future<List<Map<String, String>>> fetchFaculties() async {
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
  }

  // ── Fetch majors for a faculty from the majors table ─────────────────────
  Future<List<Map<String, String>>> fetchMajors(String facultyCode) async {
    final data = await _db
        .from('majors')
        .select('code, name')
        .eq('faculty_code', facultyCode)
        .order('name');
    return (data as List)
        .map((r) => {
              'code': r['code'] as String,
              'name': r['name'] as String,
            })
        .toList();
  }

  // ── Fetch courses filtered by faculty, year level, and major ─────────────
  Future<List<Map<String, dynamic>>> fetchCoursesRaw({
    String? facultyCode,
    int?    yearLevel,
    String? majorCode,
  }) async {
    const select =
        'id, code, name, credit_hours, type, year_level, faculty_code, major_code';

    if (facultyCode == null) {
      final data = await _db.from('courses').select(select).order('name');
      return data.cast<Map<String, dynamic>>();
    }

    if (yearLevel == null) {
      final data = await _db
          .from('courses').select(select)
          .eq('faculty_code', facultyCode)
          .order('year_level').order('name');
      return data.cast<Map<String, dynamic>>();
    }

    if (majorCode == null) {
      final data = await _db
          .from('courses').select(select)
          .eq('faculty_code', facultyCode)
          .eq('year_level', yearLevel)
          .order('name');
      return data.cast<Map<String, dynamic>>();
    }

    // Two separate queries to avoid broken .or() behaviour:
    // 1. Shared courses (major_code IS NULL) for this faculty+year
    // 2. Major-specific courses for this faculty+year+major
    final results = await Future.wait([
      _db.from('courses').select(select)
          .eq('faculty_code', facultyCode)
          .eq('year_level',   yearLevel)
          .filter('major_code', 'is', null)
          .order('name'),
      _db.from('courses').select(select)
          .eq('faculty_code', facultyCode)
          .eq('year_level',   yearLevel)
          .eq('major_code',   majorCode)
          .order('name'),
    ]);

    return [
      ...(results[0] as List).cast<Map<String, dynamic>>(),
      ...(results[1] as List).cast<Map<String, dynamic>>(),
    ];
  }

  // ── Fetch saved schedule for a group (Screen 3) ───────────────────────────
  Future<List<Map<String, dynamic>>> fetchGroupSchedule(int groupId) async {
    final data = await _db
        .from('registration_group_sections')
        .select('''
          course_name, course_code, credit_hours,
          lecture_day, lecture_start, lecture_end, lecture_instructor, lecture_room,
          section_day, section_start, section_end, section_instructor, section_room
        ''')
        .eq('group_id', groupId);
    return (data as List).cast<Map<String, dynamic>>();
  }

  // ── Fetch professors from DB ───────────────────────────────────────────────
  Future<List<ProfessorOption>> fetchProfessors() async {
    final data = await _db
        .from('professors')
        .select('id, profiles!inner(full_name, fname, lname), department');

    return (data as List).map((row) {
      final profile = row['profiles'] as Map<String, dynamic>;
      final name    = profile['full_name'] as String?
          ?? '${profile['fname']} ${profile['lname']}';
      return ProfessorOption(
        id:         row['id'] as int,
        name:       name,
        department: row['department'] as String? ?? '',
      );
    }).toList();
  }

  // ── Save group assignments to DB ──────────────────────────────────────────
  Future<int> saveGroupAssignments({
    required String faculty,
    required String major,
    required int    level,
    required int    groupCapacity,
    required Map<String, CourseAssignment> assignments,
    required Map<int, String> professorNames,
    String? groupLabel,
  }) async {
    // 1. Find the active registration window
    final windowRow = await _db
        .from('registration_windows')
        .select('id')
        .eq('status', 'open')
        .order('id', ascending: false)
        .limit(1)
        .maybeSingle();

    if (windowRow == null) throw Exception('No active registration window found.');
    final windowId = windowRow['id'] as int;

    // 2. Always create a new group with the given label (SE1, SE2, LG1, etc.)
    final newGroup = await _db
        .from('registration_groups')
        .insert({
          'label':         groupLabel ?? 'Group $faculty-$major-$level',
          'total_credits': 0,
          'faculty':       faculty,
          'major':         major,
          'level':         level,
          'window_id':     windowId,
        })
        .select('id')
        .single();
    final int groupId = newGroup['id'] as int;

    // 3. For each course assignment, create section + schedule + rgs
    for (final entry in assignments.entries) {
      final courseName = entry.key;
      final a          = entry.value;

      if (a.lectureProfessorId == null) continue; // skip unassigned courses

      // Find course by name — limit(1) guards against duplicate names
      final courseRow = await _db
          .from('courses')
          .select('id, code, credit_hours')
          .eq('name', courseName)
          .limit(1)
          .maybeSingle();

      if (courseRow == null) continue;
      final courseId   = courseRow['id']          as int;
      final courseCode = courseRow['code']         as String;
      final credits    = (courseRow['credit_hours'] as int?) ?? 3;

      // Create lecture section
      final lectureSection = await _db
          .from('sections')
          .insert({
            'course_id':    courseId,
            'professor_id': a.lectureProfessorId,
            'room':         a.lectureHall ?? '',
            'type':         'Lecture',
          })
          .select('id')
          .single();
      final lectureSectionId = lectureSection['id'] as int;

      // Create lecture schedule
      if (a.lectureDay != null && a.lectureFrom != null && a.lectureTo != null) {
        await _db.from('schedules').insert({
          'section_id': lectureSectionId,
          'day':        a.lectureDay,
          'start_time': _toTime(a.lectureFrom!),
          'end_time':   _toTime(a.lectureTo!),
        });
      }

      // Resolve professor name from pre-built map (avoids extra DB round-trip)
      final profName = professorNames[a.lectureProfessorId] ?? 'Unknown';

      // Create registration_group_sections for lecture
      await _db.from('registration_group_sections').insert({
        'group_id':           groupId,
        'section_id':         lectureSectionId,
        'course_name':        courseName,
        'course_code':        courseCode,
        'credit_hours':       credits,
        'lecture_day':        a.lectureDay,
        'lecture_start':      a.lectureFrom,
        'lecture_end':        a.lectureTo,
        'lecture_instructor': profName,
        'lecture_room':       a.lectureHall,
        'is_locked':          false,
      });

      // Create section entry if assigned
      if (a.hasSection && a.sectionProfessorId != null) {
        final secSection = await _db
            .from('sections')
            .insert({
              'course_id':    courseId,
              'professor_id': a.sectionProfessorId,
              'room':         a.sectionHall ?? '',
              'type':         'Section',
            })
            .select('id')
            .single();
        final secSectionId = secSection['id'] as int;

        if (a.sectionDay != null && a.sectionFrom != null && a.sectionTo != null) {
          await _db.from('schedules').insert({
            'section_id': secSectionId,
            'day':        a.sectionDay,
            'start_time': _toTime(a.sectionFrom!),
            'end_time':   _toTime(a.sectionTo!),
          });
        }

        final secProfName = professorNames[a.sectionProfessorId] ?? 'Unknown';

        // Update the rgs row with section info
        await _db
            .from('registration_group_sections')
            .update({
              'section_day':        a.sectionDay,
              'section_start':      a.sectionFrom,
              'section_end':        a.sectionTo,
              'section_instructor': secProfName,
              'section_room':       a.sectionHall,
            })
            .eq('group_id',   groupId)
            .eq('course_code', courseCode);
      }
    }

    // Update total_credits on the group
    final totalCredits = assignments.length * 3;
    await _db
        .from('registration_groups')
        .update({'total_credits': totalCredits})
        .eq('id', groupId);

    return groupId;
  }

  // Convert "09:00" → "09:00:00"
  String _toTime(String t) => t.contains(':') && t.split(':').length == 2
      ? '$t:00'
      : t;
}

