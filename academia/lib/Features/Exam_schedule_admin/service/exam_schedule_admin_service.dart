import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/exam_schedule_admin_model.dart';

class ExamScheduleAdminService {
  final _db = Supabase.instance.client;

  Future<List<Map<String, String>>> fetchFaculties() async {
    final data = await _db.from('faculties').select('code, name').order('name');
    return (data as List)
        .map((r) => {'code': r['code'] as String, 'name': r['name'] as String})
        .toList();
  }

  Future<List<Map<String, String>>> fetchMajors() async {
    final data = await _db
        .from('majors')
        .select('code, name, faculty_code')
        .order('name');
    return (data as List)
        .map((r) => {
              'code':         r['code']         as String,
              'name':         r['name']         as String,
              'faculty_code': r['faculty_code'] as String,
            })
        .toList();
  }

  Future<List<ExamScheduleUpload>> fetchUploads() async {
    final data = await _db
        .from('exam_schedule_uploads')
        .select('*')
        .order('created_at', ascending: false);
    return (data as List)
        .map((r) => ExamScheduleUpload.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> publishUpload({
    required String facultyCode,
    required String facultyName,
    required String examType,
    String? level,
    String? majorCode,
    String? majorName,
    String? semester,
    String? academicYear,
    String? periodFrom,
    String? periodTo,
    PlatformFile? file,
  }) async {
    String? fileUrl;
    String? fileName;
    List<int>? csvBytes;

    if (file != null) {
      final bytes = file.bytes ?? await File(file.path!).readAsBytes();
      final date  = periodFrom ?? DateTime.now().toIso8601String().substring(0, 10);
      final storagePath = '$facultyCode/${examType}_$date${_ext(file.name)}';
      try {
        await _db.storage.from('exam-schedules').uploadBinary(
          storagePath,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
        fileUrl = _db.storage.from('exam-schedules').getPublicUrl(storagePath);
      } catch (_) {
        // Storage bucket may not exist; proceed without storing the file URL
      }
      fileName = file.name;

      // If CSV, parse and insert into exam_schedules
      if (file.name.toLowerCase().endsWith('.csv')) {
        csvBytes = bytes;
      }
    }

    final examDate = periodFrom ?? DateTime.now().toIso8601String().substring(0, 10);

    await _db.from('exam_schedule_uploads').insert({
      'faculty_code':  facultyCode,
      'faculty_name':  facultyName,
      'exam_type':     examType,
      'exam_date':     examDate,
      'level':         level,
      'major_code':    majorCode,
      'major_name':    majorName,
      'semester':      semester,
      'academic_year': academicYear,
      'period_from':   periodFrom,
      'period_to':     periodTo,
      'file_url':      fileUrl,
      'file_name':     fileName,
    });

    if (csvBytes != null) {
      await _parseAndInsertExams(
        csvBytes:    csvBytes,
        facultyCode: facultyCode,
        level:       level,
      );
    }
  }

  Future<void> deleteUpload(ExamScheduleUpload upload) async {
    // Remove the upload record
    await _db.from('exam_schedule_uploads').delete().eq('id', upload.id);

    // Remove related exam_schedules rows that fall in the upload's period
    final from = upload.periodFrom ?? upload.examDate;
    final to   = upload.periodTo   ?? upload.examDate;
    await _db
        .from('exam_schedules')
        .delete()
        .eq('exam_type', upload.examType)
        .gte('exam_date', from)
        .lte('exam_date', to);
  }

  // ── CSV parsing ──────────────────────────────────────────────────────────────

  Future<void> _parseAndInsertExams({
    required List<int> csvBytes,
    required String facultyCode,
    String? level,
  }) async {
    final raw   = utf8.decode(csvBytes);
    final lines = raw
        .split('\n')
        .map((l) => l.trim().replaceAll('\r', ''))
        .where((l) => l.isNotEmpty)
        .toList();
    if (lines.length < 2) return;

    // Parse header
    final headers = lines[0].split(',').map((h) => h.trim().toLowerCase()).toList();
    int col(String name) => headers.indexOf(name);

    final cName  = col('course_name');
    final cDate  = col('exam_date');
    final cStart = col('start_time');
    final cEnd   = col('end_time');
    final cRoom  = col('room');
    final cType  = col('exam_type');
    if (cName < 0 || cDate < 0) return; // required columns missing

    for (int i = 1; i < lines.length; i++) {
      final cols = lines[i].split(',').map((c) => c.trim()).toList();
      if (cols.length <= cName) continue;

      final courseName = cols[cName];
      final examDate   = cDate  >= 0 && cDate  < cols.length ? cols[cDate]  : null;
      final startTime  = cStart >= 0 && cStart < cols.length ? cols[cStart] : null;
      final endTime    = cEnd   >= 0 && cEnd   < cols.length ? cols[cEnd]   : null;
      final room       = cRoom  >= 0 && cRoom  < cols.length ? cols[cRoom]  : null;
      final examType   = cType  >= 0 && cType  < cols.length ? cols[cType]  : 'Midterm';

      if (courseName.isEmpty || examDate == null) continue;

      // Find section IDs for this course
      final courseRows = await _db
          .from('courses')
          .select('id')
          .eq('name', courseName);
      final courseIds = (courseRows as List).map((r) => r['id'] as int).toList();
      if (courseIds.isEmpty) continue;

      final sectionRows = await _db
          .from('sections')
          .select('id')
          .inFilter('course_id', courseIds);
      final sectionIds = (sectionRows as List).map((r) => r['id'] as int).toList();
      if (sectionIds.isEmpty) continue;

      for (final sectionId in sectionIds) {
        // Delete any existing section-level exam for same course+date to avoid dupes
        await _db
            .from('exam_schedules')
            .delete()
            .eq('section_id', sectionId)
            .eq('exam_date', examDate)
            .isFilter('student_id', null);

        // Insert section-level record (professor view)
        await _db.from('exam_schedules').insert({
          'section_id':   sectionId,
          'course_name':  courseName,
          'exam_date':    examDate,
          'start_time':   startTime,
          'end_time':     endTime,
          'room':         room,
          'exam_type':    examType,
          'level':        level,
          'student_id':   null,
        });

        // Find enrolled students and insert per-student records (student view)
        final rgsRows = await _db
            .from('registration_group_sections')
            .select('group_id')
            .eq('section_id', sectionId);
        final groupIds =
            (rgsRows as List).map((r) => r['group_id'] as int).toList();
        if (groupIds.isEmpty) continue;

        final srRows = await _db
            .from('student_registrations')
            .select('student_id')
            .inFilter('group_id', groupIds);
        final studentIds =
            (srRows as List).map((r) => r['student_id'] as int).toSet();

        for (final studentId in studentIds) {
          // Avoid inserting duplicate per-student record
          final existing = await _db
              .from('exam_schedules')
              .select('id')
              .eq('section_id', sectionId)
              .eq('exam_date', examDate)
              .eq('student_id', studentId)
              .maybeSingle();
          if (existing != null) continue;

          await _db.from('exam_schedules').insert({
            'section_id':  sectionId,
            'course_name': courseName,
            'exam_date':   examDate,
            'start_time':  startTime,
            'end_time':    endTime,
            'room':        room,
            'exam_type':   examType,
            'level':       level,
            'student_id':  studentId,
          });
        }
      }
    }
  }

  static String _ext(String name) {
    final dot = name.lastIndexOf('.');
    return dot >= 0 ? name.substring(dot) : '';
  }
}
