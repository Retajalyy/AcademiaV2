// ─────────────────────────────────────────────────────────────────────────────
// Service: ExamResultsService
// Abstract contract + mock implementation.
// Swap ExamResultsServiceImpl for a real Dio/http impl without touching the
// controller or the rest of the feature.
// ─────────────────────────────────────────────────────────────────────────────

import '../model/exam_result_model.dart';
import '../model/upload_form_model.dart';

// ── Abstract contract ─────────────────────────────────────────────────────────

abstract class ExamResultsService {
  Future<List<ExamResultModel>> fetchResults({String? query, String? faculty});
  Future<bool> publishResults(UploadFormModel form);
  Future<List<String>> getFaculties();
  Future<List<String>> getLevels();
  Future<List<String>> getMajors(String faculty, String level);
  Future<List<String>> getSemesters();
  Future<List<String>> getAcademicYears();
}

// ── Mock implementation ───────────────────────────────────────────────────────

class ExamResultsServiceImpl implements ExamResultsService {
  @override
  Future<List<ExamResultModel>> fetchResults({
    String? query,
    String? faculty,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    var list = _mockResults;
    if (faculty != null && faculty != 'All') {
      list = list.where((r) => r.faculty == faculty).toList();
    }
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      list = list
          .where((r) =>
              r.title.toLowerCase().contains(q) ||
              r.major.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  @override
  Future<bool> publishResults(UploadFormModel form) async {
    // TODO: replace with real multipart POST
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  @override
  Future<List<String>> getFaculties() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      'Computers and Information',
      'Business Administration',
      'Languages and Translation',
    ];
  }

  @override
  Future<List<String>> getLevels() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return ['Level 1', 'Level 2', 'Level 3', 'Level 4'];
  }

  @override
  Future<List<String>> getMajors(String faculty, String level) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return [
      'Software Engineering',
      'Information Systems',
      'Computer Science',
      'Networks & Communications',
    ];
  }

  @override
  Future<List<String>> getSemesters() async => [
        'Semester 1 · Fall',
        'Semester 2 · Spring',
        'Semester 3 · Summer',
        'Semester 4 · Fall',
        'Semester 5 · Spring',
        'Semester 6 · Fall',
        'Semester 7 · Spring',
        'Semester 8 · Spring',
      ];

  @override
  Future<List<String>> getAcademicYears() async {
    final year = DateTime.now().year;
    return List.generate(5, (i) => '${year - i} – ${year - i + 1}');
  }

  // ── Mock data ──────────────────────────────────────────────────────────────

  static final _mockResults = <ExamResultModel>[
    ExamResultModel(
      id: '1',
      title: 'FCI · Year 4 · Software Engineering',
      faculty: 'Computers and Information',
      level: 'Level 4',
      major: 'Software Engineering',
      semester: 'Semester 8 · Spring 2026',
      academicYear: '2025 – 2026',
      studentsCount: 110,
      passRate: 80,
      avgGpa: 2.9,
      fileName: 'results_sem8_cs_year4_se.xlsx',
      uploadedAt: DateTime(2026, 4, 10),
    ),
    ExamResultModel(
      id: '2',
      title: 'FCI · Year 3 · Information Systems',
      faculty: 'Computers and Information',
      level: 'Level 3',
      major: 'Information Systems',
      semester: 'Semester 6 · Spring 2026',
      academicYear: '2025 – 2026',
      studentsCount: 95,
      passRate: 76,
      avgGpa: 3.1,
      fileName: 'results_sem6_cs_year3_is.xlsx',
      uploadedAt: DateTime(2026, 4, 8),
    ),
    ExamResultModel(
      id: '3',
      title: 'Business Admin · Year 2 · Accounting',
      faculty: 'Business Administration',
      level: 'Level 2',
      major: 'Accounting',
      semester: 'Semester 4 · Fall 2025',
      academicYear: '2024 – 2025',
      studentsCount: 130,
      passRate: 71,
      avgGpa: 2.7,
      fileName: 'results_sem4_bus_year2.xlsx',
      uploadedAt: DateTime(2025, 12, 5),
    ),
    ExamResultModel(
      id: '4',
      title: 'Languages · Year 1 · English',
      faculty: 'Languages and Translation',
      level: 'Level 1',
      major: 'English',
      semester: 'Semester 2 · Spring 2026',
      academicYear: '2025 – 2026',
      studentsCount: 88,
      passRate: 84,
      avgGpa: 3.3,
      fileName: 'results_sem2_lang_year1_en.xlsx',
      uploadedAt: DateTime(2026, 3, 20),
    ),
  ];
}