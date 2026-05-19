import 'package:get/get.dart';
import '../model/exam_result_model.dart';
import '../model/upload_form_model.dart';
import '../service/exam_results_service.dart';

enum ListStatus { initial, loading, success, error }
enum UploadStatus { idle, loading, success, error }

class ExamResultsController extends GetxController {
  final ExamResultsService _service;

  ExamResultsController({ExamResultsService? service})
      : _service = service ?? ExamResultsServiceImpl();

  // ── List screen ────────────────────────────────────────────────────────────
  final listStatus      = ListStatus.initial.obs;
  final filteredResults = <ExamResultModel>[].obs;
  final activeFilter    = 'All'.obs;
  final searchQuery     = ''.obs;
  final totalUploads    = 48.obs;
  final thisSemester    = 5.obs;
  final totalStudents   = 2846.obs;

  // internal full list — not exposed to UI directly
  final _results = <ExamResultModel>[].obs;

  // ── Upload sheet ───────────────────────────────────────────────────────────
  final uploadStep   = 1.obs;
  final uploadForm   = const UploadFormModel().obs;
  final uploadStatus = UploadStatus.idle.obs;
  final uploadError  = ''.obs;

  final faculties     = <String>[].obs;
  final levels        = <String>[].obs;
  final majors        = <String>[].obs;
  final semesters     = <String>[].obs;
  final academicYears = <String>[].obs;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _loadDropdownOptions();
    loadResults();

    // Re-filter whenever search or active filter changes
    ever(activeFilter, (_) => _applyFilters());
    debounce(searchQuery, (_) => _applyFilters(),
        time: const Duration(milliseconds: 300));
  }

  // ── List actions ───────────────────────────────────────────────────────────

  Future<void> loadResults() async {
    listStatus.value = ListStatus.loading;
    try {
      final data = await _service.fetchResults();
      _results.assignAll(data);
      _applyFilters();
      listStatus.value = ListStatus.success;
    } catch (_) {
      listStatus.value = ListStatus.error;
    }
  }

  void onSearchChanged(String value) => searchQuery.value = value;

  void onFilterChanged(String faculty) => activeFilter.value = faculty;

  void _applyFilters() {
    var list = _results.toList();
    if (activeFilter.value != 'All') {
      list = list
          .where((r) => r.faculty == activeFilter.value)
          .toList();
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
  }

  void goNextStep() { if (uploadStep.value < 3) uploadStep.value++; }
  void goPrevStep() { if (uploadStep.value > 1) uploadStep.value--; }

  void setFaculty(String? v) {
    uploadForm.value = uploadForm.value.copyWith(faculty: v, major: null);
    if (v != null && uploadForm.value.level != null) _loadMajors();
  }

  void setLevel(String? v) {
    uploadForm.value = uploadForm.value.copyWith(level: v, major: null);
    if (v != null && uploadForm.value.faculty != null) _loadMajors();
  }

  void setMajor(String? v) =>
      uploadForm.value = uploadForm.value.copyWith(major: v);

  void setResultsTitle(String v) =>
      uploadForm.value = uploadForm.value.copyWith(resultsTitle: v);

  void setSemester(String? v) =>
      uploadForm.value = uploadForm.value.copyWith(semester: v);

  void setAcademicYear(String? v) =>
      uploadForm.value = uploadForm.value.copyWith(academicYear: v);

  void setPickedFile({
    required Object file,
    required String fileName,
    required int rows,
    required double sizeMb,
  }) {
    uploadForm.value = uploadForm.value.copyWith(
      file: file,
      fileName: fileName,
      fileRows: rows,
      fileSizeMb: sizeMb,
    );
  }

  void removeFile() {
    uploadForm.value = UploadFormModel(
      faculty:      uploadForm.value.faculty,
      level:        uploadForm.value.level,
      major:        uploadForm.value.major,
      resultsTitle: uploadForm.value.resultsTitle,
      semester:     uploadForm.value.semester,
      academicYear: uploadForm.value.academicYear,
    );
  }

  Future<void> publish() async {
    if (!uploadForm.value.isStep3Valid) return;
    uploadStatus.value = UploadStatus.loading;
    try {
      final ok = await _service.publishResults(uploadForm.value);
      if (ok) {
        uploadStatus.value = UploadStatus.success;
        Get.back();
        await loadResults();
        Get.snackbar(
          'Published!',
          'Results published — students have been notified.',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        uploadStatus.value = UploadStatus.error;
        uploadError.value  = 'Upload failed. Please try again.';
      }
    } catch (e) {
      uploadStatus.value = UploadStatus.error;
      uploadError.value  = e.toString();
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<void> _loadDropdownOptions() async {
    faculties.assignAll(await _service.getFaculties());
    levels.assignAll(await _service.getLevels());
    semesters.assignAll(await _service.getSemesters());
    academicYears.assignAll(await _service.getAcademicYears());
  }

  Future<void> _loadMajors() async {
    final f = uploadForm.value.faculty;
    final l = uploadForm.value.level;
    if (f == null || l == null) return;
    majors.assignAll(await _service.getMajors(f, l));
  }
}