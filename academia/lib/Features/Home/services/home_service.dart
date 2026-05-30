import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/schedule_item_model.dart';
import '../models/assignment_model.dart';

class HomeService {
  final _db = Supabase.instance.client;

  Future<int> getStudentId(String userId) async {
    final data = await _db
        .from('students')
        .select('id')
        .eq('profile_id', userId)
        .single();
    return data['id'] as int;
  }

  Future<String> getStudentName(String userId) async {
    final data = await _db
        .from('profiles')
        .select('full_name')
        .eq('id', userId)
        .single();
    return data['full_name'] ?? '';
  }

  Future<List<ScheduleItem>> getTodaySchedule(int studentId) =>
      getScheduleForDay(studentId, _todayName());

  Future<List<ScheduleItem>> getScheduleForDay(
      int studentId, String day) async {
    // 1. Enrolled section IDs
    final enrollments = await _db
        .from('enrollments')
        .select('section_id')
        .eq('student_id', studentId);

    final sectionIds = (enrollments as List)
        .map((e) => e['section_id'] as int?)
        .whereType<int>()
        .toList();

    if (sectionIds.isEmpty) return [];

    // 2. Pull from registration_group_sections (the source of schedule truth)
    final data = await _db
        .from('registration_group_sections')
        .select(
          'course_name, '
          'lecture_day, lecture_start, lecture_end, lecture_instructor, lecture_room, '
          'section_day, section_start, section_end, section_instructor, section_room',
        )
        .inFilter('section_id', sectionIds);

    final items = <ScheduleItem>[];
    for (final row in data as List) {
      if (row['lecture_day'] == day) {
        items.add(ScheduleItem(
          title:      row['course_name']        as String? ?? '',
          time:       '${_fmt(row['lecture_start'])} - ${_fmt(row['lecture_end'])}',
          location:   row['lecture_room']       as String? ?? '',
          instructor: row['lecture_instructor'] as String? ?? '',
          type:       'Lecture',
        ));
      }
      if (row['section_day'] != null && row['section_day'] == day) {
        items.add(ScheduleItem(
          title:      row['course_name']         as String? ?? '',
          time:       '${_fmt(row['section_start'])} - ${_fmt(row['section_end'])}',
          location:   row['section_room']        as String? ?? '',
          instructor: row['section_instructor']  as String? ?? '',
          type:       'Section',
        ));
      }
    }
    items.sort((a, b) => a.time.compareTo(b.time));
    return items;
  }

  Future<ScheduleItem?> getNextClass(int studentId) async {
    final schedule = await getTodaySchedule(studentId);
    final now = TimeOfDay.now();
    for (final item in schedule) {
      final parts     = item.time.split(' - ')[0].split(':');
      final classTime = TimeOfDay(
        hour:   int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
      if (_toMinutes(classTime) > _toMinutes(now)) return item;
    }
    return null;
  }

  Future<List<Assignment>> getUpcomingAssignments(int studentId) async {
    final now  = DateTime.now().toIso8601String().substring(0, 10);
    final soon = DateTime.now()
        .add(const Duration(days: 7))
        .toIso8601String()
        .substring(0, 10);

    final data = await _db
        .from('enrollments')
        .select('''
          sections!inner(
            courses(name),
            assignments(title, type, due_date)
          )
        ''')
        .eq('student_id', studentId);

    final rawItems = <Map<String, dynamic>>[];
    for (final row in data as List) {
      final section     = row['sections'] as Map<String, dynamic>;
      final assignments = section['assignments'] as List? ?? [];
      for (final a in assignments) {
        final due = a['due_date'] as String?;
        if (due != null &&
            due.compareTo(now) >= 0 &&
            due.compareTo(soon) <= 0) {
          rawItems.add({
            'due_date': due,
            'sections': {
              'courses':     section['courses'],
              'assignments': [a],
            },
          });
        }
      }
    }
    rawItems.sort((a, b) =>
        (a['due_date'] as String).compareTo(b['due_date'] as String));
    return rawItems.map((e) => Assignment.fromMap(e)).toList();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _todayName() {
    const days = [
      'Monday', 'Tuesday', 'Wednesday',
      'Thursday', 'Friday', 'Saturday', 'Sunday',
    ];
    return days[DateTime.now().weekday - 1];
  }

  String _fmt(dynamic raw) {
    if (raw == null) return '--:--';
    final s = raw.toString();
    return s.length >= 5 ? s.substring(0, 5) : s;
  }

  int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;
}
