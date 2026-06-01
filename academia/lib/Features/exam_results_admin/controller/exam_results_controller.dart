import 'dart:io';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../model/exam_result_model.dart';
import '../model/upload_form_model.dart';
import '../service/exam_results_service.dart';
import '../widgets/result_detail_sheet.dart';

enum ListStatus { initial, loading, success, error }
enum UploadStatus { idle, loading, success, error }

class ExamResultsController extends GetxController {
  final ExamResultsService _service;

  ExamResultsController({ExamResultsService? service})
      : _service = service ?? ExamResultsService();

  // ── List screen ────────────────────────────────────────────────────────────
  final listStatus      = ListStatus.initial.obs;
  final filteredResults = <ExamResultModel>[].obs;
  final filterTabs      = <String>['All'].obs;
  final activeFilter    = 'All'.obs;
  final searchQuery     = ''.obs;
  final totalUploads    = 0.obs;
  final thisSemester    = 0.obs;
  final totalStudents   = 0.obs;

  final _results = <ExamResultModel>[].obs;

  // ── Upload sheet ───────────────────────────────────────────────────────────
  final uploadStep   = 1.obs;
  final uploadForm   = const UploadFormModel().obs;
  final uploadStatus = UploadStatus.idle.obs;
  final uploadError  = ''.obs;

  final faculties  = <String>[].obs;
  final levels     = <String>[].obs;
  final majors     = <String>[].obs;
  final semesters  = <String>[].obs;

  // semester label → {id, year_label}
  final _semesterMeta = <Map<String, dynamic>>[].obs;

  // faculty name → code
  Map<String, String> _facultyCodeMap = {};
  // major name → code
  Map<String, String> _majorCodeMap   = {};

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _loadDropdownOptions();
    loadResults();

    ever(activeFilter, (_) => _applyFilters());
    debounce(searchQuery, (_) => _applyFilters(),
        time: const Duration(milliseconds: 300));
  }

  // ── List actions ───────────────────────────────────────────────────────────

  Future<void> loadResults() async {
    listStatus.value = ListStatus.loading;
    try {
      _results.assignAll(await _service.fetchResults());
      _rebuildFilterTabs();
      _applyFilters();
      listStatus.value = ListStatus.success;
    } catch (_) {
      listStatus.value = ListStatus.error;
    }
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _service.fetchStats();
      totalUploads.value  = stats['totalUploads']  ?? 0;
      thisSemester.value  = stats['thisSemester']  ?? 0;
      totalStudents.value = stats['totalStudents'] ?? 0;
    } catch (_) {}
  }

  void onSearchChanged(String value) => searchQuery.value = value;
  void onFilterChanged(String faculty) => activeFilter.value = faculty;

  void _rebuildFilterTabs() {
    final unique = _results
        .map((r) => r.faculty)
        .where((f) => f.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    filterTabs.assignAll(['All', ...unique]);
    if (!filterTabs.contains(activeFilter.value)) {
      activeFilter.value = 'All';
    }
  }

  void _applyFilters() {
    var list = _results.toList();
    if (activeFilter.value != 'All') {
      list = list.where((r) => r.faculty == activeFilter.value).toList();
    }
    final q = searchQuery.value.toLowerCase().trim();
    if (q.isNotEmpty) {
      list = list
          .where((r) =>
              r.title.toLowerCase().contains(q) ||
              r.major.toLowerCase().contains(q) ||
              r.faculty.toLowerCase().contains(q))
          .toList();
    }
    filteredResults.assignAll(list);
  }

  // ── Upload actions ─────────────────────────────────────────────────────────

  void resetUploadForm() {
    uploadStep.value   = 1;
    uploadForm.value   = const UploadFormModel();
    uploadStatus.value = UploadStatus.idle;
    uploadError.value  = '';
    majors.clear();
  }

  void goNextStep() { if (uploadStep.value < 3) uploadStep.value++; }
  void goPrevStep() { if (uploadStep.value > 1) uploadStep.value--; }

  void setFaculty(String? v) {
    if (v == null) return;
    final code = _facultyCodeMap[v] ?? '';
    uploadForm.value = uploadForm.value.copyWith(
      faculty:     v,
      facultyCode: code,
      major:       null,
      majorCode:   null,
    );
    _loadMajors(code);
  }

  void setLevel(String? v) {
    uploadForm.value = uploadForm.value.copyWith(level: v, major: null, majorCode: null);
  }

  void setMajor(String? v) {
    if (v == null) return;
    final code = _majorCodeMap[v] ?? '';
    uploadForm.value = uploadForm.value.copyWith(major: v, majorCode: code);
  }

  void setResultsTitle(String v) =>
      uploadForm.value = uploadForm.value.copyWith(resultsTitle: v);

  void setSemester(String? v) {
    if (v == null) return;
    final meta = _semesterMeta.firstWhereOrNull((m) => m['label'] == v);
    uploadForm.value = uploadForm.value.copyWith(
      semester:     v,
      semesterId:   meta?['id'] as int?,
      academicYear: meta?['year_label'] as String?,
    );
  }

  void setPickedFile({
    required List<int> fileBytes,
    required String fileName,
    required int rows,
    required double sizeMb,
  }) {
    uploadForm.value = uploadForm.value.copyWith(
      fileBytes:  fileBytes,
      fileName:   fileName,
      fileRows:   rows,
      fileSizeMb: sizeMb,
    );
  }

  void removeFile() {
    uploadForm.value = UploadFormModel(
      faculty:      uploadForm.value.faculty,
      facultyCode:  uploadForm.value.facultyCode,
      level:        uploadForm.value.level,
      major:        uploadForm.value.major,
      majorCode:    uploadForm.value.majorCode,
      resultsTitle: uploadForm.value.resultsTitle,
      semester:     uploadForm.value.semester,
      semesterId:   uploadForm.value.semesterId,
      academicYear: uploadForm.value.academicYear,
    );
  }

  Future<void> publish() async {
    if (!uploadForm.value.isStep3Valid) return;
    uploadStatus.value = UploadStatus.loading;
    try {
      await _service.publishResults(uploadForm.value);
      uploadStatus.value = UploadStatus.success;
      Get.back();
      await loadResults();
      Get.snackbar(
        'Published!',
        'Results published — students have been notified.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      uploadStatus.value = UploadStatus.error;
      uploadError.value  = e.toString();
    }
  }

  // ── View / Download ───────────────────────────────────────────────────────

  void viewResult(ExamResultModel result) {
    ResultDetailSheet.show(result);
  }

  Future<void> downloadResult(ExamResultModel result) async {
    try {
      final detail  = await _service.fetchUploadDetail(result.semesterId);
      final bytes   = _service.generateExcel(detail, result.title);
      final dir     = await getTemporaryDirectory();
      final safe    = result.title.replaceAll(RegExp(r'[^\w\s]'), '').trim().replaceAll(' ', '_');
      final file    = File('${dir.path}/$safe.xlsx');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')],
        subject: result.title,
      );
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<void> _loadDropdownOptions() async {
    final results = await Future.wait([
      _service.getFaculties(),
      _service.getLevels(),
      _service.getSemestersMeta(),
      _service.getFacultyCodeMap(),
    ]);
    faculties.assignAll(results[0] as List<String>);
    levels.assignAll(results[1] as List<String>);

    final meta = results[2] as List<Map<String, dynamic>>;
    final filteredMeta = meta
        .where((m) => m['label'] == 'Semester 1' || m['label'] == 'Semester 2')
        .toList();
    _semesterMeta.assignAll(filteredMeta);
    semesters.assignAll(filteredMeta.map((m) => m['label'] as String).toList());

    _facultyCodeMap = results[3] as Map<String, String>;
  }

  Future<void> _loadMajors(String facultyCode) async {
    if (facultyCode.isEmpty) {
      majors.clear();
      return;
    }
    _majorCodeMap = await _service.getMajorCodeMap(facultyCode);
    majors.assignAll(_majorCodeMap.keys.toList());
  }
}
