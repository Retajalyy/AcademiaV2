import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/professor_course_model.dart';
import '../models/professor_course_detail_model.dart';
import '../models/professor_schedule_item.dart';
import '../models/attendance_models.dart';
import '../models/assignment_submission_info.dart';
import '../models/student_submission_record.dart';

class ProfessorService {
  final _db = Supabase.instance.client;

  // ── Identity ─────────────────────────────────────────────────────────────────

  Future<int> getProfessorId(String userId) async {
    final data = await _db
        .from('professors')
        .select('id')
        .eq('profile_id', userId)
        .single();
    return data['id'] as int;
  }

  /// Returns professor id, isTA flag, and computed display title.
  /// Title logic:
  ///   Professor (any faculty) → Dr
  ///   TA in FCI              → Eng
  ///   TA in FLT / FBA        → Mrs (F) or Mr (M)
  Future<({int id, bool isTA, String title})> getProfessorInfo(
      String userId) async {
    final data = await _db
        .from('professors')
        .select('id, is_ta, department, profiles!inner(gender)')
        .eq('profile_id', userId)
        .single();

    final isTA       = data['is_ta']      as bool?   ?? false;
    final department = data['department'] as String? ?? '';
    final gender     = (data['profiles'] as Map?)?['gender'] as String? ?? 'M';

    final String title;
    if (!isTA) {
      title = 'Dr';
    } else if (department == 'FCI') {
      title = 'Eng';
    } else {
      title = gender == 'F' ? 'Mrs' : 'Mr';
    }

    return (id: data['id'] as int, isTA: isTA, title: title);
  }

  Future<String> getProfessorName(String userId) async {
    final data = await _db
        .from('profiles')
        .select('full_name, fname, lname')
        .eq('id', userId)
        .single();
    final full = data['full_name'] as String?;
    if (full != null && full.isNotEmpty) return full;
    final f = data['fname'] as String? ?? '';
    final l = data['lname'] as String? ?? '';
    return '$f $l'.trim();
  }


  // ── Schedule ──────────────────────────────────────────────────────────────────

  Future<List<ProfessorScheduleItem>> getTodaySchedule(
          int professorId, {bool isTA = false}) =>
      getScheduleForDay(professorId, _todayName(), isTA: isTA);

  Future<List<ProfessorScheduleItem>> getScheduleForDay(
    int professorId,
    String day, {
    bool isTA = false,
  }) async {
    // Step 1 — sections + courses + schedules for this professor/TA
    final sectionsData = await _db
        .from('sections')
        .select('id, room, type, courses(name, code), schedules(day, start_time, end_time)')
        .eq(isTA ? 'ta_id' : 'professor_id', professorId);

    // Keep only sections that have a slot on the requested day
    final todaySections = <Map<String, dynamic>>[];
    for (final row in sectionsData as List) {
      final slots = (row['schedules'] as List? ?? [])
          .where((s) => s['day'] == day)
          .toList();
      if (slots.isEmpty) continue;
      final copy = Map<String, dynamic>.from(row);
      copy['schedules'] = slots;
      todaySections.add(copy);
    }
    if (todaySections.isEmpty) return [];

    // Step 2 — fetch groups for those section IDs
    final sectionIds = todaySections.map((r) => r['id'] as int).toList();
    final groupsBySection = await _fetchGroupsBySection(sectionIds);

    // Step 3 — build items, deduplicating by (courseId, time, type)
    final seen  = <String>{};
    final items = <ProfessorScheduleItem>[];
    for (final row in todaySections) {
      final course   = row['courses'] as Map<String, dynamic>;
      final schedule = (row['schedules'] as List).first;
      final key = '${course['id']}-${schedule['start_time']}-${row['type']}';
      if (seen.contains(key)) continue;
      seen.add(key);
      items.add(ProfessorScheduleItem.fromMap(
        row,
        groups: groupsBySection[row['id'] as int] ?? [],
      ));
    }

    items.sort((a, b) => a.time.compareTo(b.time));
    return items;
  }

  Future<ProfessorScheduleItem?> getNextClass(int professorId,
      {bool isTA = false}) async {
    final schedule = await getTodaySchedule(professorId, isTA: isTA);
    final now = TimeOfDay.now();

    for (final item in schedule) {
      final parts = item.startTime.split(':');
      if (parts.length < 2) continue;
      final classTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
      if (_toMins(classTime) > _toMins(now)) return item;
    }
    return null;
  }

  // ── Courses ───────────────────────────────────────────────────────────────────

  Future<List<ProfessorCourseModel>> getCourses(int professorId,
      {bool isTA = false}) async {
    // Step 1 — sections + courses + relevant person's profile
    // Professor view: fetch TA name via ta_id
    // TA view: fetch main instructor name via professor_id
    final select = isTA
        ? 'id, course_id, courses(id, name, code), professors!professor_id(profiles(full_name, fname, lname))'
        : 'id, course_id, courses(id, name, code), professors!ta_id(profiles(full_name, fname, lname))';

    final data = await _db
        .from('sections')
        .select(select)
        .eq(isTA ? 'ta_id' : 'professor_id', professorId);

    final list = data as List;
    if (list.isEmpty) return [];

    // Step 2 — fetch groups for all section IDs
    final sectionIds = list.map((r) => r['id'] as int).toList();
    final groupsBySection = await _fetchGroupsBySection(sectionIds);

    // Step 3 — group sections by course, collect group labels + TA name
    final courseMap      = <int, Map<String, dynamic>>{};
    final groupsByCourse = <int, Set<String>>{};
    final taByCourse     = <int, String>{};

    for (final row in list) {
      final course   = row['courses'] as Map<String, dynamic>;
      final courseId = course['id']   as int;
      final sId      = row['id']      as int;

      courseMap[courseId] = course;
      groupsByCourse.putIfAbsent(courseId, () => {});
      for (final g in groupsBySection[sId] ?? <String>[]) {
        groupsByCourse[courseId]!.add(g);
      }

      // Extract TA / instructor name from the joined professors → profiles data
      if (!taByCourse.containsKey(courseId)) {
        final taProf = row['professors'] as Map?;
        if (taProf != null) {
          final profile  = taProf['profiles'] as Map?;
          final fullName = profile?['full_name'] as String?;
          final fname    = profile?['fname']     as String? ?? '';
          final lname    = profile?['lname']     as String? ?? '';
          final name = (fullName != null && fullName.trim().isNotEmpty)
              ? fullName.trim()
              : '$fname $lname'.trim();
          if (name.isNotEmpty) taByCourse[courseId] = name;
        }
      }
    }

    final result = courseMap.entries.map((e) {
      final labels = (groupsByCourse[e.key] ?? {}).toList()..sort();
      return ProfessorCourseModel(
        courseId:      e.key,
        courseName:    e.value['name'] as String? ?? '',
        courseCode:    e.value['code'] as String? ?? '',
        taName:        taByCourse[e.key] ?? '',
        sectionLabels: labels,
      );
    }).toList();

    result.sort((a, b) => a.courseName.compareTo(b.courseName));
    return result;
  }

  // ── Overview stats ────────────────────────────────────────────────────────────

  Future<Map<String, int>> getOverviewStats(int professorId,
      {bool isTA = false}) async {
    final sections = await _db
        .from('sections')
        .select('id, course_id')
        .eq(isTA ? 'ta_id' : 'professor_id', professorId);

    final list = sections as List;
    final courseIds = list.map((s) => s['course_id']).whereType<int>().toSet();

    return {
      'sections': list.length,
      'courses': courseIds.length,
    };
  }

  // ── Course detail ─────────────────────────────────────────────────────────────

  Future<ProfessorCourseDetailModel> getCourseDetail(
    int professorId,
    int courseId, {
    bool isTA = false,
  }) async {
    // 1. Section IDs for this professor/TA for this course
    final sectionsData = await _db
        .from('sections')
        .select('id')
        .eq(isTA ? 'ta_id' : 'professor_id', professorId)
        .eq('course_id', courseId);
    final sectionIds =
        (sectionsData as List).map((s) => s['id'] as int).toList();

    List<CourseGroupInfo> groups = [];
    String major = '';
    int level = 0;

    if (sectionIds.isNotEmpty) {
      // 2. Get group IDs from registration_group_sections (explicit query, no FK join)
      final rgsData = await _db
          .from('registration_group_sections')
          .select('group_id')
          .inFilter('section_id', sectionIds)
          .not('group_id', 'is', null);

      final groupIds = (rgsData as List)
          .map((r) => r['group_id'] as int?)
          .whereType<int>()
          .toSet()
          .toList();

      if (groupIds.isNotEmpty) {
        // 3. Fetch group details directly
        final groupsData = await _db
            .from('registration_groups')
            .select('id, label, major, level')
            .inFilter('id', groupIds);

        final groupMap = <int, Map<String, dynamic>>{};
        for (final grp in groupsData as List) {
          final gId = grp['id'] as int?;
          if (gId == null) continue;
          groupMap[gId] = Map<String, dynamic>.from(grp);
          if (major.isEmpty) major = grp['major'] as String? ?? '';
          if (level == 0) level = grp['level'] as int? ?? 0;
        }

        // 4. Student counts from student_registrations
        final regData = await _db
            .from('student_registrations')
            .select('group_id')
            .inFilter('group_id', groupIds);

        final countByGroup = <int, int>{};
        for (final r in regData as List) {
          final gId = r['group_id'] as int?;
          if (gId != null) countByGroup[gId] = (countByGroup[gId] ?? 0) + 1;
        }

        groups = groupMap.entries
            .map((e) => CourseGroupInfo(
                  groupId: e.key,
                  label: e.value['label'] as String? ?? '',
                  studentCount: countByGroup[e.key] ?? 0,
                ))
            .toList()
          ..sort((a, b) => a.label.compareTo(b.label));
      }
    }

    // 4. Materials — graceful fallback if table doesn't exist
    List<CourseMaterialModel> materials = [];
    try {
      final mData = await _db
          .from('course_materials')
          .select('id, name, file_type, file_size_kb, uploaded_at, file_url, material_type, due_date')
          .eq('course_id', courseId)
          .order('uploaded_at', ascending: true);
      materials = (mData as List)
          .map((m) => CourseMaterialModel(
                id:           m['id']            as int,
                name:         m['name']          as String? ?? 'Untitled',
                fileType:    (m['file_type']     as String? ?? 'FILE').toUpperCase(),
                fileSizeKb:   m['file_size_kb']  as int?,
                uploadedAt:   DateTime.parse(m['uploaded_at'] as String),
                fileUrl:      m['file_url']      as String?,
                materialType: m['material_type'] as String?,
                dueDate:      m['due_date'] != null
                    ? DateTime.tryParse(m['due_date'] as String)
                    : null,
              ))
          .toList();
    } catch (_) {}

    return ProfessorCourseDetailModel(
      totalStudents: groups.fold(0, (sum, g) => sum + g.studentCount),
      groupCount: groups.length,
      major: (level == 1 || level == 2) ? 'General' : major,
      level: level,
      groups: groups,
      materials: materials,
    );
  }

  // ── Material upload ───────────────────────────────────────────────────────────

  Future<CourseMaterialModel> uploadCourseMaterial({
    required int       courseId,
    required String    fileName,
    required String    fileExtension,
    required Uint8List bytes,
    String?   materialType,
    DateTime? dueDate,
  }) async {
    final fileSizeKb  = bytes.length ~/ 1024;
    final timestamp   = DateTime.now().millisecondsSinceEpoch;
    final safeFileName = fileName
        .replaceAll(RegExp(r'[^\w.\-]'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    final storagePath = '$courseId/${timestamp}_$safeFileName';
    final contentType = fileExtension == 'pdf'
        ? 'application/pdf'
        : 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';

    await _db.storage.from('course-materials').uploadBinary(
          storagePath,
          bytes,
          fileOptions: FileOptions(contentType: contentType, upsert: false),
        );

    final fileUrl =
        _db.storage.from('course-materials').getPublicUrl(storagePath);

    final insertMap = <String, dynamic>{
      'course_id':     courseId,
      'name':          fileName,
      'file_type':     fileExtension.toUpperCase(),
      'file_size_kb':  fileSizeKb,
      'file_url':      fileUrl,
      'uploaded_at':   DateTime.now().toIso8601String(),
      'material_type': materialType,
      'due_date': dueDate?.toIso8601String().substring(0, 10),
    };

    final result = await _db
        .from('course_materials')
        .insert(insertMap)
        .select()
        .single();

    return CourseMaterialModel(
      id:           result['id']            as int,
      name:         result['name']          as String,
      fileType:     result['file_type']     as String,
      fileSizeKb:   result['file_size_kb']  as int?,
      uploadedAt:   DateTime.parse(result['uploaded_at'] as String),
      fileUrl:      result['file_url']      as String?,
      materialType: result['material_type'] as String?,
      dueDate:      result['due_date'] != null
          ? DateTime.tryParse(result['due_date'] as String)
          : null,
    );
  }

  // ── Academic overview ─────────────────────────────────────────────────────────

  Future<int> getStudentsAtRiskCount(int professorId,
      {bool isTA = false}) async {
    final courses = await getStudentsAtRisk(professorId, isTA: isTA);
    return courses.fold<int>(0, (sum, c) => sum + c.students.length);
  }

  Future<Map<String, dynamic>?> getLatestAssignmentInfo(int professorId,
      {bool isTA = false}) async {
    try {
      final sectionsData = await _db
          .from('sections')
          .select('id, course_id, courses(name)')
          .eq(isTA ? 'ta_id' : 'professor_id', professorId);
      final list = sectionsData as List;
      if (list.isEmpty) return null;

      // Collect distinct course IDs
      final courseIds = list
          .map((s) => s['course_id'] as int?)
          .whereType<int>()
          .toSet()
          .toList();

      // Latest course_material with a due_date across all professor's courses
      final data = await _db
          .from('course_materials')
          .select('id, name, course_id, material_type, due_date')
          .inFilter('course_id', courseIds)
          .not('due_date', 'is', null)
          .order('due_date', ascending: false)
          .limit(1)
          .maybeSingle();

      if (data == null) return null;

      final cId      = data['course_id'] as int;
      final dueRaw   = data['due_date']  as String?;
      final due      = dueRaw != null ? DateTime.tryParse(dueRaw) : null;
      final sectionRow = list.firstWhere(
          (s) => s['course_id'] == cId,
          orElse: () => <String, dynamic>{});
      final courseName =
          (sectionRow['courses'] as Map?)?['name'] as String? ?? '';

      const months = ['','Jan','Feb','Mar','Apr','May','Jun',
                         'Jul','Aug','Sep','Oct','Nov','Dec'];
      final dueLabel = due != null
          ? 'Due ${months[due.month]} ${due.day}'
          : '';

      return {
        'title':       data['name']          as String? ?? 'Assignment',
        'course':      courseName,
        'badge':       dueLabel,
        'materialId':  data['id']            as int,
        'courseId':    cId,
        'dueDate':     dueRaw,
        'materialType': data['material_type'] as String? ?? 'Assignment',
        'professorId': professorId,
        'isTA':        isTA,
      };
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getNextExamInfo(int professorId,
      {bool isTA = false}) async {
    try {
      final sectionsData = await _db
          .from('sections')
          .select('id, courses(name)')
          .eq(isTA ? 'ta_id' : 'professor_id', professorId);
      final list = sectionsData as List;
      if (list.isEmpty) return null;

      final sectionIds = list.map((s) => s['id'] as int).toList();

      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';

      final data = await _db
          .from('exam_schedules')
          .select('id, exam_type, exam_date, section_id, course_name')
          .inFilter('section_id', sectionIds)
          .isFilter('student_id', null)
          .gte('exam_date', todayStr)
          .order('exam_date', ascending: true)
          .limit(1)
          .maybeSingle();

      if (data == null) return null;

      final sectionRow = list.firstWhere(
          (s) => s['id'] == data['section_id'],
          orElse: () => <String, dynamic>{});
      final joinedName = (sectionRow['courses'] as Map?)?['name'] as String?;
      final courseName = (joinedName?.isNotEmpty == true)
          ? joinedName!
          : (data['course_name'] as String? ?? '');
      final examDate  = DateTime.parse(data['exam_date'] as String);
      final examDay   = DateTime(examDate.year, examDate.month, examDate.day);
      final todayDay  = DateTime(today.year, today.month, today.day);
      final days      = examDay.difference(todayDay).inDays;
      final examType  = data['exam_type'] as String? ?? 'Exam';

      return {
        'subtitle': '$courseName · $examType',
        'badge':    days == 0 ? 'Today' : '$days Day${days == 1 ? '' : 's'}',
      };
    } catch (_) {
      return null;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  /// Fetches registration group labels for a list of section IDs.
  /// Returns a map: sectionId → [groupLabel, ...]
  /// Primary path: registration_group_sections → registration_groups.
  /// Fallback for sections with no RGS entry: enrollments → student_registrations → registration_groups.
  Future<Map<int, List<String>>> _fetchGroupsBySection(
      List<int> sectionIds) async {
    if (sectionIds.isEmpty) return {};

    final result = <int, List<String>>{};

    // ── Primary path ───────────────────────────────────────────────────────
    final rgsData = await _db
        .from('registration_group_sections')
        .select('section_id, group_id')
        .inFilter('section_id', sectionIds)
        .not('group_id', 'is', null);

    final rgs = rgsData as List;
    if (rgs.isNotEmpty) {
      final groupIds = rgs
          .map((r) => r['group_id'] as int?)
          .whereType<int>()
          .toSet()
          .toList();

      final groupsData = await _db
          .from('registration_groups')
          .select('id, label')
          .inFilter('id', groupIds);

      final labelMap = <int, String>{
        for (final g in groupsData as List)
          g['id'] as int: (g['label'] as String? ?? ''),
      };

      for (final row in rgs) {
        final sId = row['section_id'] as int?;
        final gId = row['group_id']   as int?;
        if (sId == null || gId == null) continue;
        final label = labelMap[gId] ?? '';
        if (label.isNotEmpty) result.putIfAbsent(sId, () => []).add(label);
      }
    }

    // ── Fallback: sections still missing — look up via enrollments ─────────
    final missing = sectionIds.where((id) => !result.containsKey(id)).toList();
    if (missing.isNotEmpty) {
      final enrollData = await _db
          .from('enrollments')
          .select('section_id, student_id')
          .inFilter('section_id', missing);

      final studentIds = (enrollData as List)
          .map((e) => e['student_id'] as int?)
          .whereType<int>()
          .toSet()
          .toList();

      if (studentIds.isNotEmpty) {
        final regData = await _db
            .from('student_registrations')
            .select('student_id, group_id')
            .inFilter('student_id', studentIds)
            .not('group_id', 'is', null);

        final fallbackGroupIds = (regData as List)
            .map((r) => r['group_id'] as int?)
            .whereType<int>()
            .toSet()
            .toList();

        if (fallbackGroupIds.isNotEmpty) {
          final gData = await _db
              .from('registration_groups')
              .select('id, label')
              .inFilter('id', fallbackGroupIds);

          final fallbackLabelMap = <int, String>{
            for (final g in gData as List)
              g['id'] as int: (g['label'] as String? ?? ''),
          };

          final studentToGroup = <int, int>{};
          for (final r in regData) {
            final stuId = r['student_id'] as int?;
            final gId   = r['group_id']   as int?;
            if (stuId != null && gId != null) studentToGroup[stuId] = gId;
          }

          for (final e in enrollData) {
            final secId = e['section_id'] as int?;
            final stuId = e['student_id'] as int?;
            if (secId == null || stuId == null) continue;
            final gId   = studentToGroup[stuId];
            if (gId == null) continue;
            final label = fallbackLabelMap[gId] ?? '';
            if (label.isNotEmpty) {
              result.putIfAbsent(secId, () => []);
              if (!result[secId]!.contains(label)) result[secId]!.add(label);
            }
          }
        }
      }
    }

    return result;
  }

  String _todayName() {
    const days = [
      'Monday', 'Tuesday', 'Wednesday',
      'Thursday', 'Friday', 'Saturday', 'Sunday',
    ];
    return days[DateTime.now().weekday - 1];
  }

  int _toMins(TimeOfDay t) => t.hour * 60 + t.minute;

  // ── Attendance ────────────────────────────────────────────────────────────────

  Future<List<AttendanceGroupInfo>> loadAttendanceGroups(
      int professorId, int courseId, {bool isTA = false}) async {
    // 1. Get section IDs + rooms
    final sectionsData = await _db
        .from('sections')
        .select('id, room')
        .eq(isTA ? 'ta_id' : 'professor_id', professorId)
        .eq('course_id', courseId);
    final sections = sectionsData as List;
    if (sections.isEmpty) return [];

    final sectionIds = sections.map((s) => s['id'] as int).toList();
    final roomBySection = {
      for (final s in sections) s['id'] as int: s['room'] as String? ?? ''
    };

    // 2. Get group IDs + schedule info + actual schedule days
    final rgsData = await _db
        .from('registration_group_sections')
        .select('section_id, group_id, section_start, section_end, section_room')
        .inFilter('section_id', sectionIds)
        .not('group_id', 'is', null);

    // Fetch schedule days for each section
    final schedData = await _db
        .from('schedules')
        .select('section_id, day')
        .inFilter('section_id', sectionIds);
    final daysBySection = <int, List<String>>{};
    for (final s in schedData as List) {
      final id  = s['section_id'] as int?;
      final day = s['day']        as String?;
      if (id != null && day != null) {
        daysBySection.putIfAbsent(id, () => []).add(day);
      }
    }

    final rgsList = rgsData as List;
    if (rgsList.isEmpty) return [];

    final groupIds = rgsList
        .map((r) => r['group_id'] as int?)
        .whereType<int>()
        .toSet()
        .toList();

    // 3. Group labels
    final groupsData = await _db
        .from('registration_groups')
        .select('id, label')
        .inFilter('id', groupIds);
    final labelMap = {
      for (final g in groupsData as List)
        g['id'] as int: g['label'] as String? ?? ''
    };

    // 4. Student registrations
    final regData = await _db
        .from('student_registrations')
        .select('student_id, group_id')
        .inFilter('group_id', groupIds);
    final studentsByGroup = <int, List<int>>{};
    for (final r in regData as List) {
      studentsByGroup
          .putIfAbsent(r['group_id'] as int, () => [])
          .add(r['student_id'] as int);
    }

    // 5. Student profiles
    final allIds = studentsByGroup.values.expand((e) => e).toSet().toList();
    final stuData = await _db
        .from('students')
        .select('id, profiles(full_name, fname, lname, uni_id)')
        .inFilter('id', allIds);
    final stuMap = <int, AttendanceStudentInfo>{};
    for (final s in stuData as List) {
      final p    = s['profiles'] as Map?;
      final full = p?['full_name'] as String?;
      final fn   = p?['fname']    as String? ?? '';
      final ln   = p?['lname']    as String? ?? '';
      final name = (full != null && full.trim().isNotEmpty)
          ? full.trim()
          : '$fn $ln'.trim();
      stuMap[s['id'] as int] = AttendanceStudentInfo(
        studentId: s['id'] as int,
        name:      name,
        uniId:     p?['uni_id'] as String? ?? '',
      );
    }

    // 6. Build result — one entry per rgs row (section×group pair)
    final seen = <int>{};
    final result = <AttendanceGroupInfo>[];
    for (final rgs in rgsList) {
      final gId = rgs['group_id'] as int;
      if (seen.contains(gId)) continue;
      seen.add(gId);

      final sId    = rgs['section_id'] as int;
      final start  = rgs['section_start'] as String? ?? '';
      final end    = rgs['section_end']   as String? ?? '';
      final room   = (rgs['section_room'] as String?)?.isNotEmpty == true
          ? rgs['section_room'] as String
          : roomBySection[sId] ?? '';
      final time   = start.isNotEmpty && end.isNotEmpty
          ? '$start – $end'
          : '';

      final students = (studentsByGroup[gId] ?? [])
          .map((id) => stuMap[id])
          .whereType<AttendanceStudentInfo>()
          .toList();

      result.add(AttendanceGroupInfo(
        groupId:      gId,
        sectionId:    sId,
        label:        labelMap[gId] ?? '',
        timeRange:    time,
        room:         room,
        scheduleDays: daysBySection[sId] ?? [],
        students:     students,
      ));
    }
    return result;
  }

  Future<List<AttendanceSessionSummary>> getAttendanceSessions(
      int professorId, int courseId, {bool isTA = false}) async {
    // 1. Section IDs + types
    final sectionsData = await _db
        .from('sections')
        .select('id, type')
        .eq(isTA ? 'ta_id' : 'professor_id', professorId)
        .eq('course_id', courseId);
    final sections = sectionsData as List;
    if (sections.isEmpty) return [];

    final sectionIds = sections.map((s) => s['id'] as int).toList();
    final typeMap = {
      for (final s in sections)
        s['id'] as int: (s['type'] as String? ?? 'Lecture')
    };

    // 2. Sessions ordered newest first
    final sessionsData = await _db
        .from('attendance_sessions')
        .select('id, session_num, session_date, section_id, group_id')
        .inFilter('section_id', sectionIds)
        .order('session_date', ascending: false);
    final sessionsList = sessionsData as List;
    if (sessionsList.isEmpty) return [];

    final sessionIds = sessionsList.map((s) => s['id'] as int).toList();

    // 3. Attendance counts
    final recordsData = await _db
        .from('attendance_records')
        .select('session_id, is_present')
        .inFilter('session_id', sessionIds);
    final countsBySession = <int, List<bool>>{};
    for (final r in recordsData as List) {
      countsBySession
          .putIfAbsent(r['session_id'] as int, () => [])
          .add(r['is_present'] as bool? ?? false);
    }

    // 4. Group labels
    final groupIds = sessionsList
        .map((s) => s['group_id'] as int?)
        .whereType<int>()
        .toSet()
        .toList();
    final groupLabelMap = <int, String>{};
    if (groupIds.isNotEmpty) {
      final gData = await _db
          .from('registration_groups')
          .select('id, label')
          .inFilter('id', groupIds);
      for (final g in gData as List) {
        groupLabelMap[g['id'] as int] = g['label'] as String? ?? '';
      }
    }

    return sessionsList.map((s) {
      final sid      = s['id']         as int;
      final records  = countsBySession[sid] ?? [];
      final gId      = s['group_id']   as int?;
      final sType    = typeMap[s['section_id'] as int] ?? 'Lecture';
      final typeShort = sType.toLowerCase().startsWith('lec') ? 'LEC' : 'SEC';
      final groupLabel = gId != null ? groupLabelMap[gId] ?? '' : '';

      return AttendanceSessionSummary(
        sessionId:    sid,
        sessionNum:   s['session_num']  as int? ?? 0,
        date:         DateTime.parse(s['session_date'] as String),
        sectionType:  typeShort,
        groups:       groupLabel.isNotEmpty ? [groupLabel] : [],
        presentCount: records.where((p) => p).length,
        totalCount:   records.length,
      );
    }).toList();
  }

  Future<List<SessionStudentRecord>> getSessionDetail(int sessionId) async {
    // 1. Attendance records for this session
    final recordsData = await _db
        .from('attendance_records')
        .select('student_id, is_present')
        .eq('session_id', sessionId);
    final records = recordsData as List;
    if (records.isEmpty) return [];

    final studentIds = records.map((r) => r['student_id'] as int).toList();

    // 2. Student profiles
    final studentsData = await _db
        .from('students')
        .select('id, profiles(full_name, fname, lname)')
        .inFilter('id', studentIds);

    final nameMap = <int, String>{};
    for (final s in studentsData as List) {
      final p    = s['profiles'] as Map?;
      final full = p?['full_name'] as String?;
      final fn   = p?['fname']    as String? ?? '';
      final ln   = p?['lname']    as String? ?? '';
      nameMap[s['id'] as int] =
          (full != null && full.trim().isNotEmpty) ? full.trim() : '$fn $ln'.trim();
    }

    // 3. Group labels via student_registrations (for filter chips)
    final regData = await _db
        .from('student_registrations')
        .select('student_id, group_id')
        .inFilter('student_id', studentIds);

    // Get group_ids then labels
    final groupIds = (regData as List)
        .map((r) => r['group_id'] as int?)
        .whereType<int>()
        .toSet()
        .toList();
    final groupLabelMap = <int, String>{};
    if (groupIds.isNotEmpty) {
      final gData = await _db
          .from('registration_groups')
          .select('id, label')
          .inFilter('id', groupIds);
      for (final g in gData as List) {
        groupLabelMap[g['id'] as int] = g['label'] as String? ?? '';
      }
    }
    final studentGroupMap = <int, String>{};
    for (final r in regData) {
      final sId = r['student_id'] as int;
      final gId = r['group_id']  as int?;
      if (gId != null) {
        studentGroupMap[sId] = groupLabelMap[gId] ?? '';
      }
    }

    return records.map((r) {
      final sId = r['student_id'] as int;
      return SessionStudentRecord(
        studentId:  sId,
        name:       nameMap[sId] ?? '',
        groupLabel: studentGroupMap[sId] ?? '',
        isPresent:  r['is_present'] as bool? ?? false,
      );
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<List<AtRiskCourse>> getStudentsAtRisk(
      int professorId, {bool isTA = false}) async {
    // 1. Find course IDs this person teaches (as professor OR TA)
    final myKey = isTA ? 'ta_id' : 'professor_id';
    final mySectionsData = await _db
        .from('sections')
        .select('course_id')
        .eq(myKey, professorId);
    final myCourseIds = (mySectionsData as List)
        .map((s) => s['course_id'] as int?)
        .whereType<int>()
        .toSet()
        .toList();
    if (myCourseIds.isEmpty) return [];

    // 2. Get ALL sections for those courses (lecture + tutorial combined)
    final sectionsData = await _db
        .from('sections')
        .select('id, course_id, courses(name)')
        .inFilter('course_id', myCourseIds);
    final sections = sectionsData as List;
    if (sections.isEmpty) return [];

    final sectionIds = sections.map((s) => s['id'] as int).toList();
    final courseNameBySection = {
      for (final s in sections)
        s['id'] as int:
            (s['courses'] as Map?)?['name'] as String? ?? ''
    };

    // 2. All recorded sessions per section
    final sessionsData = await _db
        .from('attendance_sessions')
        .select('id, section_id')
        .inFilter('section_id', sectionIds);
    final sessionsList = sessionsData as List;
    if (sessionsList.isEmpty) return [];

    final sessionIds   = sessionsList.map((s) => s['id'] as int).toList();
    final sectionBySession = {
      for (final s in sessionsList) s['id'] as int: s['section_id'] as int
    };

    // Count sessions per section
    final sessionCountBySection = <int, int>{};
    for (final s in sessionsList) {
      final sid = s['section_id'] as int;
      sessionCountBySection[sid] = (sessionCountBySection[sid] ?? 0) + 1;
    }

    // 3. All attendance records for those sessions
    final recordsData = await _db
        .from('attendance_records')
        .select('session_id, student_id, is_present')
        .inFilter('session_id', sessionIds);

    // Aggregate per (student, section): attended count
    final attended = <String, int>{}; // key = "$studentId_$sectionId"
    for (final r in recordsData as List) {
      final sessId  = r['session_id'] as int;
      final stuId   = r['student_id'] as int;
      final present = r['is_present'] as bool? ?? false;
      final secId   = sectionBySession[sessId]!;
      final key     = '${stuId}_$secId';
      attended[key] = (attended[key] ?? 0) + (present ? 1 : 0);
    }

    // 4. Student profiles
    final studentIds = (recordsData as List)
        .map((r) => r['student_id'] as int)
        .toSet()
        .toList();
    final stuData = await _db
        .from('students')
        .select('id, profiles(full_name, fname, lname)')
        .inFilter('id', studentIds);
    final nameMap = <int, String>{};
    for (final s in stuData as List) {
      final p    = s['profiles'] as Map?;
      final full = p?['full_name'] as String?;
      final fn   = p?['fname']    as String? ?? '';
      final ln   = p?['lname']    as String? ?? '';
      nameMap[s['id'] as int] =
          (full != null && full.trim().isNotEmpty) ? full.trim() : '$fn $ln'.trim();
    }

    // 5. Build AtRiskCourse list (only students with ≥2 absences)
    final courseMap = <String, List<AtRiskStudent>>{};
    for (final sId in sectionIds) {
      final total      = sessionCountBySection[sId] ?? 0;
      if (total == 0) continue;
      final courseName = courseNameBySection[sId] ?? '';

      // Collect unique students who appeared in sessions of this section
      final stuForSection = (recordsData as List)
          .where((r) => sectionBySession[r['session_id'] as int] == sId)
          .map((r) => r['student_id'] as int)
          .toSet();

      for (final stuId in stuForSection) {
        final att    = attended['${stuId}_$sId'] ?? 0;
        final absent = total - att;
        if (absent < 2) continue; // only at-risk students

        courseMap.putIfAbsent(courseName, () => []).add(AtRiskStudent(
          studentId:     stuId,
          name:          nameMap[stuId] ?? '',
          attended:      att,
          totalSessions: total,
        ));
      }
    }

    return courseMap.entries
        .map((e) => AtRiskCourse(
              courseName: e.key,
              students:   e.value
                ..sort((a, b) => a.absent.compareTo(b.absent) * -1),
            ))
        .toList()
      ..sort((a, b) => a.courseName.compareTo(b.courseName));
  }

  Future<void> deleteAttendanceSession(int sessionId) async {
    await _db.from('attendance_records').delete().eq('session_id', sessionId);
    await _db.from('attendance_sessions').delete().eq('id', sessionId);
  }

  Future<int> getNextSessionNumber(int sectionId, int groupId) async {
    try {
      final data = await _db
          .from('attendance_sessions')
          .select('id')
          .eq('section_id', sectionId)
          .eq('group_id',   groupId);
      return (data as List).length + 1;
    } catch (_) {
      return 1;
    }
  }

  Future<void> saveAttendance({
    required int sectionId,
    required int groupId,
    required int professorId,
    required int sessionNum,
    required List<AttendanceStudentInfo> students,
    DateTime? date,
  }) async {
    final d = date ?? DateTime.now();
    final session = await _db.from('attendance_sessions').insert({
      'section_id':    sectionId,
      'group_id':      groupId,
      'professor_id':  professorId,
      'session_num':   sessionNum,
      'session_date':  d.toIso8601String().substring(0, 10),
    }).select('id').single();

    final sessionId = session['id'] as int;

    final records = students.map((s) => {
      'session_id': sessionId,
      'student_id': s.studentId,
      'is_present': s.isPresent,
    }).toList();

    await _db.from('attendance_records').insert(records);
  }

  // ── Submissions ───────────────────────────────────────────────────────────

  Future<List<AssignmentSubmissionInfo>> getCourseAssignments({
    required int professorId,
    required int courseId,
    bool isTA = false,
  }) async {
    // 1. Get assignments from course_materials that have a due_date
    final mData = await _db
        .from('course_materials')
        .select('id, name, due_date, material_type')
        .eq('course_id', courseId)
        .not('due_date', 'is', null)
        .order('due_date', ascending: false);

    final materials = mData as List;
    if (materials.isEmpty) return [];

    // 2. Get total enrolled students across this professor's sections
    final sectionsData = await _db
        .from('sections')
        .select('id')
        .eq(isTA ? 'ta_id' : 'professor_id', professorId)
        .eq('course_id', courseId);

    final sectionIds = (sectionsData as List).map((s) => s['id'] as int).toList();
    int totalStudents = 0;
    if (sectionIds.isNotEmpty) {
      final enrollData = await _db
          .from('enrollments')
          .select('student_id')
          .inFilter('section_id', sectionIds);
      // Distinct students — a student may be enrolled in multiple sections
      totalStudents = (enrollData as List)
          .map((e) => e['student_id'])
          .toSet()
          .length;
    }

    // 3. Get submission counts per material from assignment_submissions table
    final countByMaterial = <int, Map<String, int>>{};
    try {
      final materialIds = materials.map((m) => m['id'] as int).toList();
      final subData = await _db
          .from('assignment_submissions')
          .select('assignment_id, submitted_at')
          .inFilter('assignment_id', materialIds);

      for (final m in materials) {
        final mid     = m['id']        as int;
        final dueRaw  = m['due_date']  as String?;
        final due     = dueRaw != null ? DateTime.tryParse(dueRaw) : null;
        int onTime = 0, late = 0;

        for (final s in subData as List) {
          if (s['assignment_id'] != mid) continue;
          final submittedAt = DateTime.tryParse(s['submitted_at'] as String? ?? '');
          if (submittedAt == null) continue;
          if (due == null || submittedAt.isBefore(due)) {
            onTime++;
          } else {
            late++;
          }
        }
        countByMaterial[mid] = {'onTime': onTime, 'late': late};
      }
    } catch (_) {}

    return materials.map((m) {
      final mid      = m['id']           as int;
      final dueRaw   = m['due_date']     as String?;
      final due      = dueRaw != null ? DateTime.tryParse(dueRaw) : null;
      final counts   = countByMaterial[mid] ?? {'onTime': 0, 'late': 0};
      final onTime   = counts['onTime']!;
      final late     = counts['late']!;
      final total    = onTime + late;
      final pending  = (totalStudents - total).clamp(0, totalStudents);
      final isOpen   = due == null || due.isAfter(DateTime.now());

      return AssignmentSubmissionInfo(
        materialId:  mid,
        name:        m['name']          as String? ?? '',
        materialType: m['material_type'] as String? ?? 'Assignment',
        dueDate:     due,
        isOpen:      isOpen,
        onTime:      onTime,
        late:        late,
        pending:     pending,
      );
    }).toList();
  }

  // ── Group labels for a course ─────────────────────────────────────────────

  Future<List<String>> getGroupLabelsForCourse({
    required int  professorId,
    required int  courseId,
    bool          isTA = false,
  }) async {
    try {
      final sectionsData = await _db
          .from('sections')
          .select('id')
          .eq(isTA ? 'ta_id' : 'professor_id', professorId)
          .eq('course_id', courseId);
      final sectionIds =
          (sectionsData as List).map((s) => s['id'] as int).toList();
      if (sectionIds.isEmpty) return [];

      final groupsBySection = await _fetchGroupsBySection(sectionIds);
      final labels = groupsBySection.values
          .expand((l) => l)
          .toSet()
          .toList()
        ..sort();
      return labels;
    } catch (_) {
      return [];
    }
  }

  // ── Student submissions per assignment ────────────────────────────────────

  Future<List<StudentSubmissionRecord>> getStudentSubmissionsForAssignment({
    required int    professorId,
    required int    courseId,
    required int    materialId,
    required DateTime? dueDate,
    required String materialType,
    bool isTA = false,
  }) async {
    // 1. Section IDs
    final sectionsData = await _db
        .from('sections')
        .select('id')
        .eq(isTA ? 'ta_id' : 'professor_id', professorId)
        .eq('course_id', courseId);
    final sectionIds = (sectionsData as List).map((s) => s['id'] as int).toList();
    if (sectionIds.isEmpty) return [];

    // 2. Enrollments — deduplicate by student_id
    final enrollData = await _db
        .from('enrollments')
        .select('id, student_id')
        .inFilter('section_id', sectionIds);

    final seenEnrollments = <int, int>{}; // student_id → enrollment_id
    for (final e in enrollData as List) {
      final sid = e['student_id'] as int?;
      final eid = e['id']         as int?;
      if (sid != null && eid != null && !seenEnrollments.containsKey(sid)) {
        seenEnrollments[sid] = eid;
      }
    }
    if (seenEnrollments.isEmpty) return [];

    // 3. Student profiles (two-step, no FK join)
    final studentIds = seenEnrollments.keys.toList();
    final stuData = await _db
        .from('students')
        .select('id, profile_id')
        .inFilter('id', studentIds);

    final profileIds = (stuData as List)
        .map((s) => s['profile_id'] as String?)
        .whereType<String>()
        .toList();
    final studentToProfile = <int, String>{
      for (final s in stuData) s['id'] as int: s['profile_id'] as String? ?? '',
    };

    final profileData = profileIds.isEmpty ? <dynamic>[] : await _db
        .from('profiles')
        .select('id, full_name, uni_id')
        .inFilter('id', profileIds);

    final profileMap = <String, Map<String, dynamic>>{
      for (final p in profileData as List)
        p['id'] as String: Map<String, dynamic>.from(p),
    };

    // 3. Submission records from assignment_submissions table
    final submissionByStudent = <int, Map<String, dynamic>>{};
    try {
      final subData = await _db
          .from('assignment_submissions')
          .select('student_id, submitted_at, file_url, grade')
          .eq('assignment_id', materialId);
      for (final s in subData as List) {
        final sid = s['student_id'] as int;
        submissionByStudent[sid] = s;
      }
    } catch (_) {}

    // 4. Existing grades for grade column display
    final gradeCol    = _gradeCol(materialType);
    final enrollIds   = seenEnrollments.values.toList();
    final gradeByEnrollment = <int, double>{};
    if (enrollIds.isNotEmpty) {
      try {
        final gData = await _db
            .from('grades')
            .select('enrollment_id, $gradeCol')
            .inFilter('enrollment_id', enrollIds);
        for (final g in gData as List) {
          final eid   = g['enrollment_id'] as int;
          final score = (g[gradeCol] as num?)?.toDouble();
          if (score != null) gradeByEnrollment[eid] = score;
        }
      } catch (_) {}
    }

    // 5. Build records
    return seenEnrollments.entries.map<StudentSubmissionRecord>((entry) {
      final sid = entry.key;
      final eid = entry.value;
      final profileId = studentToProfile[sid] ?? '';
      final profile   = profileMap[profileId] ?? {};
      final name      = profile['full_name'] as String? ?? '';
      final uniId     = profile['uni_id']    as String? ?? '';
      final sub       = submissionByStudent[sid];
      final submittedAt = sub != null
          ? DateTime.tryParse(sub['submitted_at'] as String? ?? '')
          : null;

      SubmissionStatus status;
      if (sub == null) {
        status = SubmissionStatus.missing;
      } else if (dueDate == null || submittedAt == null || submittedAt.isBefore(dueDate)) {
        status = SubmissionStatus.onTime;
      } else {
        status = SubmissionStatus.late;
      }

      return StudentSubmissionRecord(
        studentId:    sid,
        enrollmentId: eid,
        name:         name,
        uniId:        uniId,
        status:       status,
        submittedAt:  submittedAt,
        fileUrl:      sub?['file_url']  as String?,
        fileName:     null,
        currentGrade: gradeByEnrollment[eid],
        maxGrade:     _defaultTotal(materialType),
      );
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> saveStudentGrade({
    required int    enrollmentId,
    required String materialType,
    required double score,
    int? studentId,
    int? assignmentId,
  }) async {
    final col      = _gradeCol(materialType);
    final totalCol = '${col}_total';
    await _db.from('grades').upsert(
      {
        'enrollment_id': enrollmentId,
        col:             score,
        totalCol:        _defaultTotal(materialType),
      },
      onConflict: 'enrollment_id',
    );

    // Mirror the grade to assignment_submissions so the student can see it
    if (studentId != null && assignmentId != null) {
      try {
        await _db
            .from('assignment_submissions')
            .update({'grade': score})
            .eq('assignment_id', assignmentId)
            .eq('student_id', studentId);
      } catch (_) {}
    }
  }

  // ── Material management ───────────────────────────────────────────────────

  Future<void> renameCourseMaterial(int materialId, String newName) async {
    await _db
        .from('course_materials')
        .update({'name': newName})
        .eq('id', materialId);
  }

  Future<void> deleteCourseMaterial(int materialId, String? fileUrl) async {
    // Delete from storage if we have a path
    if (fileUrl != null && fileUrl.isNotEmpty) {
      try {
        final uri  = Uri.parse(fileUrl);
        final segs = uri.pathSegments;
        // Storage path is everything after 'course-materials/'
        final idx  = segs.indexOf('course-materials');
        if (idx != -1 && idx + 1 < segs.length) {
          final path = segs.sublist(idx + 1).join('/');
          await _db.storage.from('course-materials').remove([path]);
        }
      } catch (_) {}
    }
    await _db.from('course_materials').delete().eq('id', materialId);
  }

  // ── Grade upload ──────────────────────────────────────────────────────────

  Future<void> uploadGradesFromCsv({
    required int                 professorId,
    required int                 courseId,
    required String              gradeType,
    required Map<String, double> scores,
    bool                         isTA = false,
  }) async {
    // 1. Section IDs for this professor + course
    final sectionsData = await _db
        .from('sections')
        .select('id')
        .eq(isTA ? 'ta_id' : 'professor_id', professorId)
        .eq('course_id', courseId);
    final sectionIds =
        (sectionsData as List).map((s) => s['id'] as int).toList();
    if (sectionIds.isEmpty) return;

    // 2. Enrollments with student uni_ids
    final enrollData = await _db
        .from('enrollments')
        .select('id, students!inner(profiles!inner(uni_id))')
        .inFilter('section_id', sectionIds);

    // 3. Build uni_id → enrollment_id map
    final enrollMap = <String, int>{};
    for (final e in enrollData as List) {
      final student = e['students'] as Map?;
      final profile = student?['profiles'] as Map?;
      final uniId   = profile?['uni_id'] as String?;
      final eId     = e['id'] as int?;
      if (uniId != null && eId != null) enrollMap[uniId] = eId;
    }

    // 4. Build upsert records
    final col      = _gradeCol(gradeType);
    final totalCol = '${col}_total';
    final defTotal = _defaultTotal(gradeType);

    final records = <Map<String, dynamic>>[];
    for (final entry in scores.entries) {
      final eId = enrollMap[entry.key];
      if (eId == null) continue;
      records.add({
        'enrollment_id': eId,
        col:             entry.value,
        totalCol:        defTotal,
      });
    }

    if (records.isEmpty) return;

    await _db.from('grades').upsert(
      records,
      onConflict: 'enrollment_id',
    );
  }

  static String _gradeCol(String type) {
    switch (type.toLowerCase()) {
      case 'midterm':       return 'midterm';
      case 'participation': return 'participation';
      case 'classwork':     return 'participation';
      case 'quiz':          return 'quiz';
      case 'assignment':    return 'quiz';
      case 'lab':           return 'quiz';
      case 'final':         return 'final';
      default:              return 'quiz';
    }
  }

  static double _defaultTotal(String type) {
    switch (type.toLowerCase()) {
      case 'midterm':       return 15;
      case 'participation': return 25;
      case 'classwork':     return 25;
      case 'quiz':          return 10;
      case 'assignment':    return 10;
      case 'lab':           return 10;
      case 'final':         return 60;
      default:              return 10;
    }
  }

  // ── Professor exam schedule ──────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchProfessorExamSchedule(
      int professorId, {bool isTA = false}) async {
    // 1. Professor's section IDs + course names
    final sectionsData = await _db
        .from('sections')
        .select('id, courses(name)')
        .eq(isTA ? 'ta_id' : 'professor_id', professorId);
    final sections = sectionsData as List;
    if (sections.isEmpty) return [];

    final sectionIds = sections.map((s) => s['id'] as int).toList();
    final courseNameBySection = {
      for (final s in sections)
        s['id'] as int:
            (s['courses'] as Map?)?['name'] as String? ?? ''
    };

    // 2. Section-level exam records (student_id IS NULL = professor view)
    final examData = await _db
        .from('exam_schedules')
        .select('id, section_id, course_name, exam_date, start_time, end_time, room, exam_type, level')
        .inFilter('section_id', sectionIds)
        .isFilter('student_id', null)
        .order('exam_date');
    if ((examData as List).isEmpty) return [];

    // 3. Groups per section
    final rgsData = await _db
        .from('registration_group_sections')
        .select('section_id, group_id')
        .inFilter('section_id', sectionIds);
    final groupIdsBySection = <int, List<int>>{};
    for (final r in rgsData as List) {
      final sid = r['section_id'] as int;
      final gid = r['group_id']  as int?;
      if (gid != null) {
        groupIdsBySection.putIfAbsent(sid, () => []).add(gid);
      }
    }

    final allGroupIds = groupIdsBySection.values.expand((g) => g).toSet().toList();
    final labelByGroupId = <int, String>{};
    if (allGroupIds.isNotEmpty) {
      final groupData = await _db
          .from('registration_groups')
          .select('id, label')
          .inFilter('id', allGroupIds);
      for (final g in groupData as List) {
        labelByGroupId[g['id'] as int] = g['label'] as String? ?? '';
      }
    }

    // 4. Build result list, grouping by (course_name, exam_date) to avoid
    //    one card per section when the professor teaches multiple sections
    //    of the same course on the same day.
    final merged = <String, Map<String, dynamic>>{};

    for (final row in examData) {
      final sectionId  = row['section_id'] as int;
      final courseName = courseNameBySection[sectionId]?.isNotEmpty == true
          ? courseNameBySection[sectionId]!
          : (row['course_name'] as String? ?? '');
      final examDate   = row['exam_date'] as String;
      final key        = '$courseName|$examDate';

      final groupIds = groupIdsBySection[sectionId] ?? [];
      final groups   = groupIds
          .map((gid) => labelByGroupId[gid] ?? '')
          .where((l) => l.isNotEmpty)
          .toList();

      if (merged.containsKey(key)) {
        final existing = merged[key]!['groups'] as List<String>;
        for (final g in groups) {
          if (!existing.contains(g)) existing.add(g);
        }
      } else {
        merged[key] = {
          'id':          row['id'],
          'course_name': courseName,
          'exam_date':   examDate,
          'start_time':  row['start_time'],
          'end_time':    row['end_time'],
          'room':        row['room'],
          'exam_type':   row['exam_type'],
          'level':       row['level'],
          'groups':      List<String>.from(groups),
        };
      }
    }

    for (final entry in merged.values) {
      (entry['groups'] as List<String>).sort();
    }

    return merged.values.toList();
  }
}
