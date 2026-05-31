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

    if (file != null) {
      final bytes = file.bytes ?? await File(file.path!).readAsBytes();
      final date  = periodFrom ?? DateTime.now().toIso8601String().substring(0, 10);
      final storagePath = '$facultyCode/${examType}_$date${_ext(file.name)}';
      await _db.storage.from('exam-schedules').uploadBinary(
        storagePath,
        bytes,
        fileOptions: const FileOptions(upsert: true),
      );
      fileUrl  = _db.storage.from('exam-schedules').getPublicUrl(storagePath);
      fileName = file.name;
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
  }

  static String _ext(String name) {
    final dot = name.lastIndexOf('.');
    return dot >= 0 ? name.substring(dot) : '';
  }
}
