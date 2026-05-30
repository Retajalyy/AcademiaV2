// Requires the following Supabase table:
//
// CREATE TABLE exam_result_uploads (
//   id            BIGSERIAL PRIMARY KEY,
//   title         TEXT NOT NULL,
//   faculty       TEXT,
//   year_level    INTEGER,
//   major         TEXT,
//   semester_id   INTEGER REFERENCES semesters(id),
//   semester_label TEXT,
//   academic_year TEXT,
//   file_name     TEXT,
//   students_count INTEGER DEFAULT 0,
//   pass_rate     NUMERIC(5,2) DEFAULT 0,
//   avg_gpa       NUMERIC(4,2) DEFAULT 0,
//   uploaded_at   TIMESTAMPTZ DEFAULT NOW()
// );
//
// Expected file format (CSV or XLSX, first row is header):
//   student_number, course_name, grade
//   20240001, Mathematics, 85
//   20240001, Physics, 72
//   20240002, Mathematics, 91

import 'package:excel/excel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/exam_result_model.dart';
import '../model/upload_form_model.dart';

class ExamResultsService {
  final _db = Supabase.instance.client;

  // ── Reference data ────────────────────────────────────────────────────────

  Future<List<String>> getFaculties() async {
    final data = await _db.from('faculties').select('name').order('name');
    return (data as List).map((r) => r['name'] as String).toList();
  }

  Future<Map<String, String>> getFacultyCodeMap() async {
    final data = await _db.from('faculties').select('code, name').order('name');
    return {for (final r in data as List) r['name'] as String: r['code'] as String};
  }

  Future<List<String>> getLevels() async =>
      ['Level 1', 'Level 2', 'Level 3', 'Level 4'];

  Future<List<String>> getMajors(String facultyCode) async {
    final data = await _db
        .from('majors')
        .select('name')
        .eq('faculty_code', facultyCode)
        .order('name');
    return (data as List).map((r) => r['name'] as String).toList();
  }

  Future<Map<String, String>> getMajorCodeMap(String facultyCode) async {
    final data = await _db
        .from('majors')
        .select('code, name')
        .eq('faculty_code', facultyCode)
        .order('name');
    return {for (final r in data as List) r['name'] as String: r['code'] as String};
  }

  /// Returns semester options as display strings.
  /// Internally also populates the id/year map (call [getSemesterMeta] for that).
  Future<List<Map<String, dynamic>>> getSemestersMeta() async {
    final data = await _db
        .from('semesters')
        .select('id, label, year_label')
        .order('id', ascending: false);
    return (data as List).cast<Map<String, dynamic>>();
  }

  // ── Stats ─────────────────────────────────────────────────────────────────

  Future<Map<String, int>> fetchStats() async {
    // Each stat is fetched independently so one failure doesn't zero the others.

    int allUploads = 0;
    try {
      final d = await _db.from('exam_result_uploads').select('id');
      allUploads = (d as List).length;
    } catch (_) {}

    int totalStudents = 0;
    try {
      final d = await _db.from('students').select('id');
      totalStudents = (d as List).length;
    } catch (_) {}

    int thisSem = 0;
    try {
      final window = await _db
          .from('registration_windows')
          .select('semester_id, next_semester_label')
          .order('id', ascending: false)
          .limit(1)
          .maybeSingle();
      if (window != null) {
        final semId = window['semester_id'];
        if (semId != null) {
          final d = await _db
              .from('exam_result_uploads')
              .select('id')
              .eq('semester_id', semId as int);
          thisSem = (d as List).length;
        } else {
          final label = window['next_semester_label'] as String?;
          if (label != null) {
            final d = await _db
                .from('exam_result_uploads')
                .select('id')
                .eq('semester_label', label);
            thisSem = (d as List).length;
          }
        }
      }
    } catch (_) {}

    return {
      'totalUploads':  allUploads,
      'thisSemester':  thisSem,
      'totalStudents': totalStudents,
    };
  }

  // ── List ──────────────────────────────────────────────────────────────────

  Future<List<ExamResultModel>> fetchResults({
    String? query,
    String? faculty,
  }) async {
    try {
      final data = await _db
          .from('exam_result_uploads')
          .select('*')
          .order('uploaded_at', ascending: false);
      var list = (data as List)
          .map((r) => ExamResultModel.fromDb(r))
          .toList();

      if (faculty != null && faculty != 'All') {
        list = list.where((r) => r.faculty == faculty).toList();
      }
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        list = list
            .where((r) =>
                r.title.toLowerCase().contains(q) ||
                r.major.toLowerCase().contains(q) ||
                r.faculty.toLowerCase().contains(q))
            .toList();
      }
      return list;
    } catch (_) {
      return [];
    }
  }

  // ── Detail view ───────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchUploadDetail(int semesterId) async {
    final data = await _db
        .from('semester_results')
        .select(
          'id, gpa, status, '
          'students!inner(faculty, level, major, profiles!inner(uni_id, fname, lname)), '
          'course_results(course_name, grade, letter, gpa_points)',
        )
        .eq('semester_id', semesterId)
        .order('id');
    return (data as List).cast<Map<String, dynamic>>();
  }

  List<int> generateExcel(List<Map<String, dynamic>> detail, String title) {
    final wb    = Excel.createExcel();
    final sheet = wb['Results'];
    wb.delete('Sheet1');

    // Header
    sheet.appendRow([
      TextCellValue('Student ID'),
      TextCellValue('Student Name'),
      TextCellValue('Course'),
      TextCellValue('Grade'),
      TextCellValue('Letter'),
      TextCellValue('GPA Points'),
    ]);

    for (final row in detail) {
      final student = row['students']  as Map<String, dynamic>? ?? {};
      final profile = student['profiles'] as Map<String, dynamic>? ?? {};
      final uniId   = profile['uni_id'] as String? ?? '';
      final name    = '${profile['fname'] ?? ''} ${profile['lname'] ?? ''}'.trim();
      final courses = (row['course_results'] as List?) ?? [];
      for (final c in courses) {
        sheet.appendRow([
          TextCellValue(uniId),
          TextCellValue(name),
          TextCellValue(c['course_name'] as String? ?? ''),
          IntCellValue(c['grade']        as int?    ?? 0),
          TextCellValue(c['letter']      as String? ?? ''),
          DoubleCellValue((c['gpa_points'] as num?)?.toDouble() ?? 0.0),
        ]);
      }
    }

    return wb.encode()!;
  }

  // ── Publish ───────────────────────────────────────────────────────────────

  Future<void> publishResults(UploadFormModel form) async {
    final semesterId  = form.semesterId!;
    final yearLevel   = _levelToInt(form.level ?? '');
    final fileBytes   = form.fileBytes!;
    final fileName    = form.fileName ?? '';

    // 1. Parse file
    final rows = _parseFile(fileBytes, fileName);
    if (rows.isEmpty) throw Exception('File is empty or has no valid data rows.');

    // 2. Collect unique student numbers (these are uni_id values the admin types)
    final studentNumbers =
        rows.map((r) => r['student_number'] as String).toSet().toList();

    // 3. Bulk fetch student IDs via profiles.uni_id (students.student_number is nullable)
    final profileData = await _db
        .from('profiles')
        .select('uni_id, students(id)')
        .inFilter('uni_id', studentNumbers)
        .eq('role', 'student');

    final studentMap = <String, int>{};
    for (final p in profileData as List) {
      final uniId = p['uni_id'] as String;
      final s = p['students'];
      final studentId = s is List && s.isNotEmpty
          ? (s.first as Map)['id'] as int?
          : s is Map
              ? s['id'] as int?
              : null;
      if (studentId != null) studentMap[uniId] = studentId;
    }

    // 4. Find existing semester_results for these students in this semester
    final studentIds = studentMap.values.toList();
    List<Map<String, dynamic>> existingSemResults = [];
    if (studentIds.isNotEmpty) {
      final data = await _db
          .from('semester_results')
          .select('id, student_id')
          .eq('semester_id', semesterId)
          .inFilter('student_id', studentIds);
      existingSemResults = (data as List).cast<Map<String, dynamic>>();
    }
    final semResultMap = {
      for (final sr in existingSemResults)
        sr['student_id'] as int: sr['id'] as int
    };

    // 5. Create semester_results for students that don't have one yet
    for (final studentId in studentIds) {
      if (!semResultMap.containsKey(studentId)) {
        final newSr = await _db
            .from('semester_results')
            .insert({'student_id': studentId, 'semester_id': semesterId, 'status': 'pending'})
            .select('id')
            .single();
        semResultMap[studentId] = newSr['id'] as int;
      }
    }

    // 6. Group rows by student
    final Map<String, List<Map<String, dynamic>>> byStudent = {};
    for (final row in rows) {
      final sn = row['student_number'] as String;
      byStudent.putIfAbsent(sn, () => []).add(row);
    }

    int successStudents = 0;
    double gpaSum = 0;
    int passCount = 0;

    // 7. For each student: delete old course_results, insert new ones, update GPA
    for (final entry in byStudent.entries) {
      final sn        = entry.key;
      final studentId = studentMap[sn];
      if (studentId == null) continue;

      final srId = semResultMap[studentId];
      if (srId == null) continue;

      // Delete old course_results for this semester_result
      await _db.from('course_results').delete().eq('semester_result_id', srId);

      // Insert new course_results
      final courseInserts = entry.value.map((row) {
        final grade  = (row['grade'] as int).clamp(0, 100);
        final letter = _toLetter(grade);
        final gpa    = _toGpaPoints(letter);
        return {
          'semester_result_id': srId,
          'course_name':        row['course_name'] as String,
          'grade':              grade,
          'letter':             letter,
          'gpa_points':         gpa,
          'credits':            3,
        };
      }).toList();

      await _db.from('course_results').insert(courseInserts);

      // Compute student GPA (simple avg of gpa_points)
      final gpaPoints = courseInserts
          .map((c) => c['gpa_points'] as double)
          .toList();
      final studentGpa = gpaPoints.isEmpty
          ? 0.0
          : gpaPoints.reduce((a, b) => a + b) / gpaPoints.length;

      // Update semester_result
      await _db
          .from('semester_results')
          .update({'gpa': studentGpa, 'status': 'published'})
          .eq('id', srId);

      successStudents++;
      gpaSum += studentGpa;
      if (studentGpa >= 1.0) passCount++;
    }

    final avgGpa   = successStudents > 0 ? gpaSum / successStudents : 0.0;
    final passRate = successStudents > 0 ? (passCount / successStudents) * 100 : 0.0;

    // 8. Get semester label for storage
    final semRow = await _db
        .from('semesters')
        .select('label')
        .eq('id', semesterId)
        .maybeSingle();
    final semLabel = semRow?['label'] as String? ?? '';

    // 9. Save upload metadata
    await _db.from('exam_result_uploads').insert({
      'title':          form.resultsTitle,
      'faculty':        form.faculty,
      'year_level':     yearLevel,
      'major':          form.major,
      'semester_id':    semesterId,
      'semester_label': semLabel,
      'academic_year':  form.academicYear,
      'file_name':      fileName,
      'students_count': successStudents,
      'pass_rate':      double.parse(passRate.toStringAsFixed(2)),
      'avg_gpa':        double.parse(avgGpa.toStringAsFixed(2)),
    });
  }

  // ── File parsing ──────────────────────────────────────────────────────────

  List<Map<String, dynamic>> _parseFile(List<int> bytes, String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    if (ext == 'xlsx' || ext == 'xls') return _parseXlsx(bytes);
    return _parseCsv(bytes);
  }

  List<Map<String, dynamic>> _parseCsv(List<int> bytes) {
    var text = String.fromCharCodes(bytes);
    if (text.startsWith('﻿')) text = text.substring(1);
    final lines = text
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .trim()
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();

    if (lines.length < 2) return [];
    final headers =
        lines[0].split(',').map((h) => h.trim().toLowerCase()).toList();
    final snIdx = headers.indexOf('student_number');
    final cnIdx = headers.indexOf('course_name');
    final gIdx  = headers.indexOf('grade');
    if (snIdx < 0 || cnIdx < 0 || gIdx < 0) {
      throw Exception(
          'File must have columns: student_number, course_name, grade');
    }

    return lines.skip(1).map((line) {
      final cols = line.split(',').map((c) => c.trim()).toList();
      return {
        'student_number': cols.length > snIdx ? cols[snIdx] : '',
        'course_name':    cols.length > cnIdx ? cols[cnIdx] : '',
        'grade':          cols.length > gIdx  ? (int.tryParse(cols[gIdx]) ?? 0) : 0,
      };
    }).where((r) => (r['student_number'] as String).isNotEmpty).toList();
  }

  List<Map<String, dynamic>> _parseXlsx(List<int> bytes) {
    final excel     = Excel.decodeBytes(bytes);
    final sheetName = excel.tables.keys.first;
    final rows      = excel.tables[sheetName]!.rows;
    if (rows.isEmpty) return [];

    final headerRow = rows[0]
        .map((c) => c?.value?.toString().trim().toLowerCase() ?? '')
        .toList();
    final snIdx = headerRow.indexOf('student_number');
    final cnIdx = headerRow.indexOf('course_name');
    final gIdx  = headerRow.indexOf('grade');
    if (snIdx < 0 || cnIdx < 0 || gIdx < 0) {
      throw Exception(
          'File must have columns: student_number, course_name, grade');
    }

    return rows.skip(1).map((row) {
      String cell(int i) =>
          i < row.length ? (row[i]?.value?.toString().trim() ?? '') : '';
      return {
        'student_number': cell(snIdx),
        'course_name':    cell(cnIdx),
        'grade':          int.tryParse(cell(gIdx)) ?? 0,
      };
    }).where((r) => (r['student_number'] as String).isNotEmpty).toList();
  }

  // ── Grade helpers ─────────────────────────────────────────────────────────

  String _toLetter(int grade) {
    if (grade >= 97) return 'A+';
    if (grade >= 93) return 'A';
    if (grade >= 90) return 'A-';
    if (grade >= 87) return 'B+';
    if (grade >= 83) return 'B';
    if (grade >= 80) return 'B-';
    if (grade >= 77) return 'C+';
    if (grade >= 73) return 'C';
    if (grade >= 70) return 'C-';
    if (grade >= 67) return 'D+';
    if (grade >= 63) return 'D';
    if (grade >= 60) return 'D-';
    return 'F';
  }

  double _toGpaPoints(String letter) {
    switch (letter) {
      case 'A+': case 'A': return 4.0;
      case 'A-': return 3.7;
      case 'B+': return 3.3;
      case 'B':  return 3.0;
      case 'B-': return 2.7;
      case 'C+': return 2.3;
      case 'C':  return 2.0;
      case 'C-': return 1.7;
      case 'D+': return 1.3;
      case 'D':  return 1.0;
      case 'D-': return 0.7;
      default:   return 0.0;
    }
  }

  int _levelToInt(String level) {
    final match = RegExp(r'\d').firstMatch(level);
    return match != null ? int.parse(match.group(0)!) : 1;
  }
}
