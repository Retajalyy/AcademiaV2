import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course_schedule_admin_model.dart';

class CourseScheduleAdminService {
  final _db = Supabase.instance.client;

  Future<List<CourseScheduleGroupModel>> fetchGroups() async {
    final results = await Future.wait([
      _db
          .from('registration_groups')
          .select('id, label, level, faculty, major, registration_group_sections(course_name)')
          .order('faculty')
          .order('level')
          .order('label'),
      _db.from('faculties').select('code, name').order('name'),
      _db.from('majors').select('code, name'),
    ]);

    final rawGroups  = (results[0] as List).cast<Map<String, dynamic>>();
    final facultyMap = {
      for (final f in (results[1] as List).cast<Map<String, dynamic>>())
        f['code'] as String: f['name'] as String
    };
    final majorMap = {
      for (final m in (results[2] as List).cast<Map<String, dynamic>>())
        m['code'] as String: m['name'] as String
    };

    return rawGroups.map((g) {
      final fCode    = g['faculty'] as String? ?? '';
      final mCode    = g['major']   as String? ?? '';
      final sections = (g['registration_group_sections'] as List?) ?? [];
      return CourseScheduleGroupModel(
        id:          g['id']    as int,
        label:       g['label'] as String? ?? '',
        majorCode:   mCode,
        majorName:   majorMap[mCode]   ?? mCode,
        facultyCode: fCode,
        facultyName: facultyMap[fCode] ?? fCode,
        level:       (g['level'] as num?)?.toInt() ?? 0,
        courseCount: sections.length,
      );
    }).toList();
  }

  // Returns { 'Sunday': [session, ...], 'Monday': [...], ... }
  Future<Map<String, List<CourseSessionModel>>> fetchGroupSchedule(
      int groupId) async {
    final data = await _db
        .from('registration_groups')
        .select('''
          registration_group_sections(
            course_name,
            lecture_day, lecture_start, lecture_end, lecture_instructor, lecture_room,
            section_day, section_start, section_end, section_instructor, section_room
          )
        ''')
        .eq('id', groupId)
        .single();

    final rows = (data['registration_group_sections'] as List? ?? [])
        .cast<Map<String, dynamic>>();

    final Map<String, List<CourseSessionModel>> schedule = {};

    for (final r in rows) {
      final courseName = r['course_name'] as String? ?? '';

      final lecDay = r['lecture_day'] as String?;
      if (lecDay != null && lecDay.isNotEmpty) {
        schedule.putIfAbsent(lecDay, () => []).add(CourseSessionModel(
          courseName:  courseName,
          startTime:   CourseSessionModel.fmtTime(r['lecture_start'] as String?),
          endTime:     CourseSessionModel.fmtTime(r['lecture_end']   as String?),
          instructor:  r['lecture_instructor'] as String? ?? '',
          room:        r['lecture_room']       as String? ?? '',
          type:        'Lecture',
        ));
      }

      final secDay = r['section_day'] as String?;
      if (secDay != null && secDay.isNotEmpty) {
        schedule.putIfAbsent(secDay, () => []).add(CourseSessionModel(
          courseName:  courseName,
          startTime:   CourseSessionModel.fmtTime(r['section_start'] as String?),
          endTime:     CourseSessionModel.fmtTime(r['section_end']   as String?),
          instructor:  r['section_instructor'] as String? ?? '',
          room:        r['section_room']       as String? ?? '',
          type:        'Section',
        ));
      }
    }

    // Sort each day's sessions by start time
    for (final sessions in schedule.values) {
      sessions.sort((a, b) => a.startTime.compareTo(b.startTime));
    }

    return schedule;
  }
}
