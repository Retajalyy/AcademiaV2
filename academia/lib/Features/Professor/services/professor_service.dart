import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/professor_course_model.dart';
import '../models/professor_course_detail_model.dart';
import '../models/professor_schedule_item.dart';

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

  Future<List<ProfessorScheduleItem>> getTodaySchedule(int professorId) =>
      getScheduleForDay(professorId, _todayName());

  Future<List<ProfessorScheduleItem>> getScheduleForDay(
    int professorId,
    String day,
  ) async {
    // Step 1 — sections + courses + schedules for this professor
    final sectionsData = await _db
        .from('sections')
        .select('id, room, type, courses(name, code), schedules(day, start_time, end_time)')
        .eq('professor_id', professorId);

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

    // Step 3 — build items
    final items = todaySections
        .map((row) => ProfessorScheduleItem.fromMap(
              row,
              groups: groupsBySection[row['id'] as int] ?? [],
            ))
        .toList();

    items.sort((a, b) => a.time.compareTo(b.time));
    return items;
  }

  Future<ProfessorScheduleItem?> getNextClass(int professorId) async {
    final schedule = await getTodaySchedule(professorId);
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

  Future<List<ProfessorCourseModel>> getCourses(int professorId) async {
    // Step 1 — sections + courses for this professor
    final data = await _db
        .from('sections')
        .select('id, course_id, courses(id, name, code)')
        .eq('professor_id', professorId);

    final list = data as List;
    if (list.isEmpty) return [];

    // Step 2 — fetch groups for all section IDs
    final sectionIds = list.map((r) => r['id'] as int).toList();
    final groupsBySection = await _fetchGroupsBySection(sectionIds);

    // Step 3 — group sections by course and collect unique group labels
    final courseMap = <int, Map<String, dynamic>>{};
    final groupsByCourse = <int, Set<String>>{};

    for (final row in list) {
      final course = row['courses'] as Map<String, dynamic>;
      final courseId = course['id'] as int;
      final sId = row['id'] as int;

      courseMap[courseId] = course;
      groupsByCourse.putIfAbsent(courseId, () => {});
      for (final g in groupsBySection[sId] ?? <String>[]) {
        groupsByCourse[courseId]!.add(g);
      }
    }

    final result = courseMap.entries.map((e) {
      final labels = (groupsByCourse[e.key] ?? {}).toList()..sort();
      return ProfessorCourseModel(
        courseId: e.key,
        courseName: e.value['name'] as String? ?? '',
        courseCode: e.value['code'] as String? ?? '',
        taName: '',
        sectionLabels: labels,
      );
    }).toList();

    result.sort((a, b) => a.courseName.compareTo(b.courseName));
    return result;
  }

  // ── Overview stats ────────────────────────────────────────────────────────────

  Future<Map<String, int>> getOverviewStats(int professorId) async {
    final sections = await _db
        .from('sections')
        .select('id, course_id')
        .eq('professor_id', professorId);

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
    int courseId,
  ) async {
    // 1. Section IDs taught by this professor for this course
    final sectionsData = await _db
        .from('sections')
        .select('id')
        .eq('professor_id', professorId)
        .eq('course_id', courseId);
    final sectionIds =
        (sectionsData as List).map((s) => s['id'] as int).toList();

    List<CourseGroupInfo> groups = [];
    String major = '';
    int level = 0;

    if (sectionIds.isNotEmpty) {
      // 2. Groups via registration_group_sections
      final rgsData = await _db
          .from('registration_group_sections')
          .select('registration_groups(id, label, major, level)')
          .inFilter('section_id', sectionIds);

      final groupMap = <int, Map<String, dynamic>>{};
      for (final row in rgsData as List) {
        final grp = row['registration_groups'];
        if (grp is! Map) continue;
        final gId = grp['id'] as int?;
        if (gId == null) continue;
        groupMap[gId] = Map<String, dynamic>.from(grp);
        if (major.isEmpty) major = grp['major'] as String? ?? '';
        if (level == 0) level = grp['level'] as int? ?? 0;
      }

      if (groupMap.isNotEmpty) {
        // 3. Student counts for all groups in one query
        final groupIds = groupMap.keys.toList();
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
          .select('id, name, file_type, file_size_kb, uploaded_at, file_url')
          .eq('course_id', courseId)
          .order('uploaded_at', ascending: true);
      materials = (mData as List)
          .map((m) => CourseMaterialModel(
                id: m['id'] as int,
                name: m['name'] as String? ?? 'Untitled',
                fileType:
                    (m['file_type'] as String? ?? 'FILE').toUpperCase(),
                fileSizeKb: m['file_size_kb'] as int?,
                uploadedAt: DateTime.parse(m['uploaded_at'] as String),
                fileUrl: m['file_url'] as String?,
              ))
          .toList();
    } catch (_) {}

    return ProfessorCourseDetailModel(
      totalStudents: groups.fold(0, (sum, g) => sum + g.studentCount),
      groupCount: groups.length,
      major: major,
      level: level,
      groups: groups,
      materials: materials,
    );
  }

  // ── Material upload ───────────────────────────────────────────────────────────

  Future<CourseMaterialModel> uploadCourseMaterial({
    required int courseId,
    required String fileName,
    required String fileExtension,
    required Uint8List bytes,
  }) async {
    final fileSizeKb = bytes.length ~/ 1024;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    // Sanitize: replace spaces and special chars with underscores
    final safeFileName = fileName
        .replaceAll(RegExp(r'[^\w.\-]'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    final storagePath = '$courseId/${timestamp}_$safeFileName';
    final contentType = fileExtension == 'pdf'
        ? 'application/pdf'
        : 'application/vnd.openxmlformats-officedocument.presentationml.presentation';

    await _db.storage.from('course-materials').uploadBinary(
          storagePath,
          bytes,
          fileOptions: FileOptions(contentType: contentType, upsert: false),
        );

    final fileUrl =
        _db.storage.from('course-materials').getPublicUrl(storagePath);

    final result = await _db.from('course_materials').insert({
      'course_id': courseId,
      'name': fileName,
      'file_type': fileExtension.toUpperCase(),
      'file_size_kb': fileSizeKb,
      'file_url': fileUrl,
      'uploaded_at': DateTime.now().toIso8601String(),
    }).select().single();

    return CourseMaterialModel(
      id: result['id'] as int,
      name: result['name'] as String,
      fileType: result['file_type'] as String,
      fileSizeKb: result['file_size_kb'] as int?,
      uploadedAt: DateTime.parse(result['uploaded_at'] as String),
      fileUrl: result['file_url'] as String?,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  /// Fetches registration group labels for a list of section IDs.
  /// Returns a map: sectionId → [groupLabel, ...]
  Future<Map<int, List<String>>> _fetchGroupsBySection(
      List<int> sectionIds) async {
    if (sectionIds.isEmpty) return {};

    final data = await _db
        .from('registration_group_sections')
        .select('section_id, registration_groups(label, major, level)')
        .inFilter('section_id', sectionIds);

    final result = <int, List<String>>{};
    for (final row in data as List) {
      final sId = row['section_id'] as int?;
      if (sId == null) continue;
      final grp = row['registration_groups'];
      if (grp is! Map) continue;

      final label = grp['label']?.toString() ?? '';
      final major = grp['major']?.toString() ?? '';
      final level = grp['level']?.toString() ?? '';

      // Use label directly if meaningful, otherwise build from major+level
      String display;
      if (label.isNotEmpty) {
        display = label;
      } else {
        final suffix = label.isNotEmpty ? label[label.length - 1] : '';
        display = '$major$level$suffix';
      }

      if (display.isNotEmpty) {
        result.putIfAbsent(sId, () => []).add(display);
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
}
