import 'package:supabase_flutter/supabase_flutter.dart';

class AddUserService {
  final _db = Supabase.instance.client;

  // ── Professor ─────────────────────────────────────────────────────────────
  Future<void> createProfessor({
    required String fname,
    required String lname,
    required String uniId,
    required String email,
    required String password,
    String? phone,
    String? department,
    bool isTA = false,
  }) async {
    await _db.rpc('create_professor_user', params: {
      'p_fname':      fname,
      'p_lname':      lname,
      'p_uni_id':     uniId,
      'p_email':      email,
      'p_password':   password,
      'p_phone':      phone,
      'p_department': department,
      'p_is_ta':      isTA,
    });
  }

  // ── Admin ─────────────────────────────────────────────────────────────────
  Future<void> createAdmin({
    required String fname,
    required String lname,
    required String uniId,
    required String email,
    required String password,
    String? phone,
    String? jobTitle,
  }) async {
    await _db.rpc('create_admin_user', params: {
      'p_fname':     fname,
      'p_lname':     lname,
      'p_uni_id':    uniId,
      'p_email':     email,
      'p_password':  password,
      'p_phone':     phone,
      'p_job_title': jobTitle,
    });
  }

  // ── Students from CSV ─────────────────────────────────────────────────────
  // Expected CSV columns (header row required):
  // first_name,last_name,email,uni_id,faculty,major,level,phone
  Future<Map<String, int>> createStudentsFromCsv(String csvContent) async {
    // Strip BOM and normalise line endings
    var content = csvContent;
    if (content.startsWith('﻿')) content = content.substring(1);
    final lines = content
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .trim()
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (lines.length < 2) throw Exception('CSV must have a header and at least one data row.');

    // Parse header
    final headers = lines[0].split(',').map((h) => h.trim().toLowerCase()).toList();
    int col(String name) {
      final i = headers.indexOf(name);
      if (i == -1) throw Exception('Missing column: $name');
      return i;
    }

    final fi  = col('first_name');
    final li  = col('last_name');
    final ei  = col('email');
    final ui  = col('uni_id');
    final pwi = col('password');
    // Optional columns — default to -1 if missing
    final faci = headers.indexOf('faculty');
    final maji = headers.indexOf('major');
    final levi = headers.indexOf('level');
    final phi  = headers.indexOf('phone');

    int success = 0, failed = 0;

    for (int i = 1; i < lines.length; i++) {
      final cols = lines[i].split(',').map((c) => c.trim()).toList();
      try {
        await _db.rpc('create_student_user', params: {
          'p_fname':    cols[fi],
          'p_lname':    cols[li],
          'p_uni_id':   cols[ui],
          'p_email':    cols[ei],
          'p_password': cols[pwi],
          'p_faculty':  faci >= 0 && faci < cols.length ? cols[faci] : null,
          'p_major':    maji >= 0 && maji < cols.length ? cols[maji] : null,
          'p_level':    levi >= 0 && levi < cols.length ? int.tryParse(cols[levi]) ?? 1 : 1,
          'p_phone':    phi  >= 0 && phi  < cols.length ? cols[phi] : null,
        });
        success++;
      } catch (_) {
        failed++;
      }
    }
    return {'success': success, 'failed': failed};
  }

  // ── Fetch faculties for dropdown ──────────────────────────────────────────
  Future<List<Map<String, String>>> fetchFaculties() async {
    try {
      final data = await _db
          .from('faculties')
          .select('code, name')
          .order('name');
      return (data as List)
          .map((r) => {'code': r['code'] as String, 'name': r['name'] as String})
          .toList();
    } catch (_) {
      return [];
    }
  }
}
