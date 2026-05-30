import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/student_model.dart';

class StudentService {
  final _db = Supabase.instance.client;

  Future<StudentModel> fetchStudentProfile() async {
    final user = _db.auth.currentUser!;

    // 1. Student row
    final sRow = await _db
        .from('students')
        .select('id, student_number, major, total_credits, phone, avatar_url')
        .eq('profile_id', user.id)
        .single();

    final studentId = sRow['id'] as int;
    final studentNumber = sRow['student_number'] as String? ?? studentId.toString();
    final major = sRow['major'] as String? ?? 'N/A';
    final totalCredits = (sRow['total_credits'] as int?) ?? 140;
    final phone = sRow['phone'] as String? ?? '';
    final rawAvatar = sRow['avatar_url'] as String?;
    // Add timestamp so NetworkImage always fetches fresh after a new upload
    final avatarUrl = rawAvatar != null
        ? '$rawAvatar?t=${DateTime.now().millisecondsSinceEpoch}'
        : null;

    // 2. Profile name
    final profileRow = await _db
        .from('profiles')
        .select('full_name')
        .eq('id', user.id)
        .single();
    final name = profileRow['full_name'] as String? ?? user.email ?? 'Student';
    final email = user.email ?? '';

    // 3. Semester results — number lives in the joined semesters table
    final semResults = await _db
        .from('semester_results')
        .select('id, status, gpa, semesters(number)')
        .eq('student_id', studentId);

    final semList = semResults as List;
    final completedSems = semList
        .where((s) => s['status']?.toString().toLowerCase() == 'completed')
        .toList();
    final semestersCompleted = completedSems.length;
    final level = _levelFromSemesters(semestersCompleted);

    final publishedGpas = semList
        .where((s) => s['gpa'] != null)
        .map((s) => (s['gpa'] as num).toDouble())
        .toList();
    final cumulativeGpa = publishedGpas.isNotEmpty
        ? publishedGpas.reduce((a, b) => a + b) / publishedGpas.length
        : 0.0;

    // 4. Completed credits from course_results (requires credits column)
    int completedCredits = 0;
    if (completedSems.isNotEmpty) {
      final semIds = completedSems.map((s) => s['id'] as int).toList();
      final courseRes = await _db
          .from('course_results')
          .select('credits')
          .inFilter('semester_result_id', semIds);
      completedCredits = (courseRes as List)
          .fold(0, (acc, r) => acc + ((r['credits'] as num?)?.toInt() ?? 3));
    }

    // 5. Courses enrolled
    final enrollments = await _db
        .from('enrollments')
        .select('id')
        .eq('student_id', studentId);
    final coursesEnrolled = (enrollments as List).length;

    // 6. Attendance average — grades are linked through enrollments
    final enrollmentGrades = await _db
        .from('enrollments')
        .select('grades(attendance)')
        .eq('student_id', studentId);
    int attendancePercent = 0;
    final attendanceValues = (enrollmentGrades as List)
        .map((e) {
          final g = e['grades'];
          if (g is Map) return (g['attendance'] as num?)?.toInt();
          if (g is List && g.isNotEmpty) return (g.first['attendance'] as num?)?.toInt();
          return null;
        })
        .whereType<int>()
        .toList();
    if (attendanceValues.isNotEmpty) {
      final sum = attendanceValues.fold(0, (acc, v) => acc + v);
      attendancePercent = (sum / attendanceValues.length).round();
    }

    return StudentModel(
      name: name,
      id: studentNumber,
      level: level,
      faculty: major,
      email: email,
      phone: phone,
      avatarUrl: avatarUrl,
      gpa: double.parse(cumulativeGpa.toStringAsFixed(2)),
      attendancePercent: attendancePercent,
      coursesEnrolled: coursesEnrolled,
      semesterCompleted: semestersCompleted,
      completedCredits: completedCredits,
      totalCredits: totalCredits,
      remainingCredits: totalCredits - completedCredits,
    );
  }

  String _levelFromSemesters(int completed) {
    if (completed >= 7) return 'Level 4';
    if (completed >= 5) return 'Level 3';
    if (completed >= 3) return 'Level 2';
    return 'Level 1';
  }

  /// Returns {currentWeek, totalWeeks, semesterLabel} from the active semester.
  Future<Map<String, dynamic>> fetchSemesterProgress() async {
    final row = await _db
        .from('registration_windows')
        .select('semester_start, week_count, next_semester_label')
        .order('id', ascending: false)
        .limit(1)
        .maybeSingle();

    final totalWeeks = (row?['week_count'] as int?) ?? 16;
    final label = (row?['next_semester_label'] as String?) ?? '';

    int currentWeek = 0;
    if (row?['semester_start'] != null) {
      final start = DateTime.parse(row!['semester_start'] as String);
      final now = DateTime.now();
      if (now.isAfter(start)) {
        currentWeek = ((now.difference(start).inDays ~/ 7) + 1).clamp(1, totalWeeks);
      }
    }

    return {
      'currentWeek': currentWeek,
      'totalWeeks': totalWeeks,
      'semesterLabel': label,
    };
  }

  Future<bool> updateStudentPhone(String studentId, String phone) async {
    await _db
        .from('students')
        .update({'phone': phone})
        .eq('student_number', studentId);
    return true;
  }

  Future<String> uploadAvatarByStudentNumber(
      String _, Uint8List bytes, String ext) async {
    // Always resolve via profile_id — reliable regardless of student_number value
    final userId = _db.auth.currentUser!.id;
    final row = await _db
        .from('students')
        .select('id')
        .eq('profile_id', userId)
        .single();
    final studentId = row['id'] as int;

    final path = 'students/$studentId.$ext';
    await _db.storage
        .from('avatars')
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: 'image/$ext', upsert: true),
        );
    final baseUrl = _db.storage.from('avatars').getPublicUrl(path);
    await _db
        .from('students')
        .update({'avatar_url': baseUrl})
        .eq('profile_id', userId);
    // Return with cache-buster so NetworkImage reloads immediately
    return '$baseUrl?t=${DateTime.now().millisecondsSinceEpoch}';
  }
}
