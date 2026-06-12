import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/assignment_model.dart';

class AssignmentsService {
  final _db = Supabase.instance.client;

  Future<int> getStudentId(String userId) async {
    final data = await _db
        .from('students')
        .select('id')
        .eq('profile_id', userId)
        .single();
    return data['id'] as int;
  }

  Future<List<AssignmentModel>> getAssignments(
      int sectionId, int studentId, {int courseId = 0}) async {
    final now     = DateTime.now();
    final results = <AssignmentModel>[];

    // ── 1. assignments table (professor-created rows with due_date) ───────────
    final raw = await _db
        .from('assignments')
        .select('id, title, type, due_date, max_grade')
        .eq('section_id', sectionId)
        .order('due_date', ascending: false);

    final rows = raw as List;
    if (rows.isNotEmpty) {
      final ids = rows.map((a) => a['id'] as int).toList();
      final subsMap = <int, Map<String, dynamic>>{};
      try {
        final subs = await _db
            .from('assignment_submissions')
            .select('assignment_id, submitted_at, file_url, grade')
            .eq('student_id', studentId)
            .inFilter('assignment_id', ids);
        for (final s in subs as List) {
          subsMap[s['assignment_id'] as int] = s;
        }
      } catch (_) {}

      for (final a in rows) {
        final id  = a['id'] as int;
        final due = DateTime.parse(a['due_date'] as String);
        final sub = subsMap[id];
        results.add(AssignmentModel(
          id:         id,
          title:      a['title']     as String? ?? '',
          type:       a['type']      as String? ?? 'Assignment',
          dueDate:    due,
          maxGrade:   (a['max_grade'] as num?)?.toDouble() ?? 20.0,
          status:     sub != null
              ? 'handed'
              : due.isBefore(now)
                  ? 'missed'
                  : 'pending',
          submittedAt: sub != null
              ? DateTime.tryParse(sub['submitted_at'] as String? ?? '')
              : null,
          grade:      (sub?['grade'] as num?)?.toDouble(),
          fileUrl:    sub?['file_url'] as String?,
          isMaterial: false,
        ));
      }
    }

    // ── 2. course_materials with a due_date ──────────────────────────────────
    try {
      // Resolve courseId: use the one passed in, or fall back to a DB lookup
      int? resolvedCourseId = courseId > 0 ? courseId : null;
      if (resolvedCourseId == null) {
        final secRow = await _db
            .from('sections')
            .select('course_id')
            .eq('id', sectionId)
            .maybeSingle();
        resolvedCourseId = secRow?['course_id'] as int?;
      }

      if (resolvedCourseId != null && resolvedCourseId > 0) {
        final courseId = resolvedCourseId;
        final mats = await _db
            .from('course_materials')
            .select('id, name, material_type, due_date, file_url')
            .eq('course_id', courseId)
            .not('due_date', 'is', null)
            .order('due_date', ascending: false);

        final matList = mats as List;
        if (matList.isNotEmpty) {
          final matIds = matList.map((m) => m['id'] as int).toList();
          final subMap = <int, Map<String, dynamic>>{};
          try {
            final subs = await _db
                .from('submissions')
                .select('material_id, submitted_at, file_url, grade')
                .eq('student_id', studentId)
                .inFilter('material_id', matIds);
            for (final s in subs as List) {
              subMap[s['material_id'] as int] = s;
            }
          } catch (_) {}

          for (final m in matList) {
            final id  = m['id'] as int;
            final due = DateTime.parse(m['due_date'] as String);
            final sub = subMap[id];
            final gradeVal = (sub?['grade'] as num?)?.toDouble();
            results.add(AssignmentModel(
              id:              id,
              title:           m['name']          as String? ?? 'Untitled',
              type:            m['material_type'] as String? ?? 'Assignment',
              dueDate:         due,
              maxGrade:        gradeVal ?? 0,
              status:          sub != null
                  ? 'handed'
                  : due.isBefore(now)
                      ? 'missed'
                      : 'pending',
              submittedAt:     sub != null
                  ? DateTime.tryParse(sub['submitted_at'] as String? ?? '')
                  : null,
              grade:           gradeVal,
              fileUrl:         sub?['file_url'] as String?,
              isMaterial:      true,
              materialFileUrl: m['file_url'] as String?,
            ));
          }
        }
      }
    } catch (_) {}

    results.sort((a, b) => b.dueDate.compareTo(a.dueDate));
    return results;
  }

  Future<void> submitAssignment({
    required int    assignmentId,
    required int    studentId,
    required String filePath,
    required String fileName,
    bool            isMaterial = false,
  }) async {
    final bytes       = await File(filePath).readAsBytes();
    final storagePath = 'submissions/$studentId/$assignmentId/$fileName';

    await _db.storage
        .from('assignment-submissions')
        .uploadBinary(storagePath, bytes,
            fileOptions: const FileOptions(upsert: true));

    final fileUrl = _db.storage
        .from('assignment-submissions')
        .getPublicUrl(storagePath);

    if (isMaterial) {
      await _db.from('submissions').upsert({
        'material_id':  assignmentId,
        'student_id':   studentId,
        'submitted_at': DateTime.now().toIso8601String(),
        'file_url':     fileUrl,
        'file_name':    fileName,
      });
    } else {
      await _db.from('assignment_submissions').upsert({
        'assignment_id': assignmentId,
        'student_id':    studentId,
        'submitted_at':  DateTime.now().toIso8601String(),
        'file_url':      fileUrl,
      });
    }
  }
}
