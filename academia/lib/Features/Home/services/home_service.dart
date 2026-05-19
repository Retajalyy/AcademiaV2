import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/schedule_item_model.dart';
import '../models/assignment_model.dart';

class HomeService {
  final _db = Supabase.instance.client;

  /// Fetch student's row id from their auth uuid
  Future<int> getStudentId(String userId) async {
    final data = await _db
        .from('students')
        .select('id')
        .eq('profile_id', userId)
        .single();
    return data['id'] as int;
  }

  /// Fetch student's display name
  Future<String> getStudentName(String userId) async {
    final data = await _db
        .from('profiles')
        .select('full_name')
        .eq('id', userId)
        .single();
    return data['full_name'] ?? '';
  }

  /// Today's schedule for this student
  Future<List<ScheduleItem>> getTodaySchedule(int studentId) =>
      getScheduleForDay(studentId, _todayName());

  /// Schedule for any given day name (e.g. 'Monday')
  Future<List<ScheduleItem>> getScheduleForDay(int studentId, String day) async {
    final data = await _db
        .from('enrollments')
        .select('''
          sections!inner(
            room,
            type,
            courses(name, code),
            professors(
              profiles(full_name)
            ),
            schedules(day, start_time, end_time)
          )
        ''')
        .eq('student_id', studentId);

    final items = <ScheduleItem>[];
    for (final row in data as List) {
      final section = row['sections'] as Map<String, dynamic>;
      final schedules = (section['schedules'] as List? ?? [])
          .where((s) => s['day'] == day)
          .toList();
      if (schedules.isEmpty) continue;
      final modified = Map<String, dynamic>.from(section);
      modified['schedules'] = schedules;
      items.add(ScheduleItem.fromMap({'sections': modified}));
    }
    items.sort((a, b) => a.time.compareTo(b.time));
    return items;
  }

  /// Next upcoming class today (first class after current time)
  Future<ScheduleItem?> getNextClass(int studentId) async {
    final schedule = await getTodaySchedule(studentId);
    final now = TimeOfDay.now();

    for (final item in schedule) {
     final parts = item.time.split(' - ')[0].split(':');
final classTime = TimeOfDay(
  hour: int.parse(parts[0]),
  minute: int.parse(parts[1]),
);
      if (_timeToMinutes(classTime) > _timeToMinutes(now)) {
        return item;
      }
    }
    return null; // no more classes today
  }

  /// Assignments due within the next 7 days
  Future<List<Assignment>> getUpcomingAssignments(int studentId) async {
    final now = DateTime.now().toIso8601String().substring(0, 10);
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
      final section = row['sections'] as Map<String, dynamic>;
      final assignments = section['assignments'] as List? ?? [];
      for (final a in assignments) {
        final due = a['due_date'] as String?;
        if (due != null && due.compareTo(now) >= 0 && due.compareTo(soon) <= 0) {
          rawItems.add({
            'due_date': due,
            'sections': {
              'courses': section['courses'],
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
      'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return days[DateTime.now().weekday - 1];
  }

  int _timeToMinutes(TimeOfDay t) => t.hour * 60 + t.minute;
}