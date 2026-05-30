import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/course_admin_model.dart';
import '../service/course_admin_service.dart';

class CourseAdminController extends GetxController {
  final CourseAdminService _service;

  CourseAdminController({CourseAdminService? service})
      : _service = service ?? CourseAdminService();

  // ─── State ────────────────────────────────────────────────────────────────
  final Rx<CourseStatsModel?> stats = Rx(null);
  final RxList<CourseAdminModel> allCourses      = <CourseAdminModel>[].obs;
  final RxList<CourseAdminModel> filteredCourses = <CourseAdminModel>[].obs;
  final RxBool   isLoading      = true.obs;
  final RxBool   isSubmitting   = false.obs;
  final RxString errorMessage   = ''.obs;

  // ─── Filter ───────────────────────────────────────────────────────────────
  final RxString searchQuery = ''.obs;
  final RxString selectedTab = 'All'.obs;
  final RxList<String> tabs  = <String>['All'].obs;

  // ─── Form ─────────────────────────────────────────────────────────────────
  final Rx<CourseFormModel>     form           = const CourseFormModel().obs;
  final Rx<CourseAdminModel?>   pendingCourse  = Rx(null);
  final Rx<CourseAdminModel?>   editingCourse  = Rx(null);
  final Rx<CourseAdminModel?>   deletingCourse = Rx(null);

  // ─── Reference data (loaded from DB) ─────────────────────────────────────
  // Each entry: {code, name} for faculties; {code, name, faculty_code} for majors
  final List<Map<String, String>> _facultyOptions = [];
  final List<Map<String, String>> _majorOptions   = [];

  // Name→code lookup maps (used by service when inserting/updating)
  Map<String, String> _facMap = {}; // code → name
  Map<String, String> _majMap = {}; // code → name

  // ─── Dropdown item lists (names only) ────────────────────────────────────
  List<String> get faculties => _facultyOptions.map((f) => f['name']!).toList();

  List<String> get majors {
    final code = form.value.facultyCode;
    if (code.isEmpty) return _majorOptions.map((m) => m['name']!).toList();
    return _majorOptions
        .where((m) => m['faculty_code'] == code)
        .map((m) => m['name']!)
        .toList();
  }

  final List<String> levels      = ['Year 1', 'Year 2', 'Year 3', 'Year 4'];
  final List<String> creditsList = ['1', '2', '3', '4'];
  final List<String> types       = ['Core', 'Elective'];

  /// Course names for the selected faculty, excluding the course being edited.
  /// Empty faculty → all courses shown.
  List<String> get prerequisiteCourses {
    final faculty     = form.value.faculty;
    final editingId   = editingCourse.value?.id;
    return allCourses
        .where((c) => faculty.isEmpty || c.faculty == faculty)
        .where((c) => c.id != editingId)
        .map((c) => c.name)
        .toList()
      ..sort();
  }

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value   = true;
    errorMessage.value = '';
    try {
      // Load reference data first so the maps are ready for courses
      final refResults = await Future.wait([
        _service.fetchFaculties(),
        _service.fetchMajors(),
        _service.fetchStats(),
      ]);

      _facultyOptions
        ..clear()
        ..addAll(refResults[0] as List<Map<String, String>>);
      _majorOptions
        ..clear()
        ..addAll(refResults[1] as List<Map<String, String>>);
      stats.value = refResults[2] as CourseStatsModel;

      _facMap = {for (final f in _facultyOptions) f['code']!: f['name']!};
      _majMap = {for (final m in _majorOptions)   m['code']!: m['name']!};

      tabs.assignAll(['All', ..._facultyOptions.map((f) => f['name']!)]);

      final courses = await _service.fetchCourses(_facMap, _majMap);
      allCourses.assignAll(courses);
      _applyFilter();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Filter ───────────────────────────────────────────────────────────────
  void onSearch(String q) {
    searchQuery.value = q;
    _applyFilter();
  }

  void onTabSelected(String tab) {
    selectedTab.value = tab;
    _applyFilter();
  }

  void _applyFilter() {
    var list = allCourses.toList();
    if (selectedTab.value != 'All') {
      list = list.where((c) => c.faculty == selectedTab.value).toList();
    }
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list.where((c) => c.name.toLowerCase().contains(q)).toList();
    }
    filteredCourses.assignAll(list);
  }

  // ─── Form helpers ─────────────────────────────────────────────────────────
  void setField({
    String? name,
    String? level,
    String? credits,
    String? type,
    String? prerequisite,
  }) {
    form.value = form.value.copyWith(
      name:         name,
      level:        level,
      credits:      credits,
      type:         type,
      prerequisite: prerequisite,
    );
  }

  void onFacultySelected(String? facultyName) {
    if (facultyName == null) return;
    final opt  = _facultyOptions.firstWhereOrNull((f) => f['name'] == facultyName);
    form.value = form.value.copyWith(
      faculty:     facultyName,
      facultyCode: opt?['code'] ?? '',
      major:       '',
      majorCode:   '',
    );
  }

  void onMajorSelected(String? majorName) {
    if (majorName == null) return;
    final opt  = _majorOptions.firstWhereOrNull((m) => m['name'] == majorName);
    form.value = form.value.copyWith(
      major:     majorName,
      majorCode: opt?['code'] ?? '',
    );
  }

  void resetForm() {
    form.value          = const CourseFormModel();
    pendingCourse.value  = null;
    editingCourse.value  = null;
  }

  void loadEditForm(CourseAdminModel course) {
    editingCourse.value = course;
    final facOpt = _facultyOptions.firstWhereOrNull((f) => f['name'] == course.faculty);
    final majOpt = _majorOptions.firstWhereOrNull((m) => m['name'] == course.major);
    form.value = CourseFormModel(
      name:        course.name,
      faculty:     course.faculty,
      facultyCode: facOpt?['code'] ?? '',
      level:       course.level,
      major:       course.major,
      majorCode:   majOpt?['code'] ?? '',
      credits:     course.credits.toString(),
      type:        course.type,
      prerequisite: course.prerequisite == '—' ? '' : course.prerequisite,
    );
  }

  // ─── Add ──────────────────────────────────────────────────────────────────
  Future<void> previewAdd() async {
    if (!form.value.isValid) {
      Get.snackbar('Incomplete', 'Please fill all required fields',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    // Build a local preview — DB insert happens only on confirmAdd
    pendingCourse.value = CourseAdminModel(
      id:          '',
      name:        form.value.name,
      faculty:     form.value.faculty,
      level:       form.value.level,
      major:       form.value.major.isEmpty ? 'General' : form.value.major,
      credits:     int.tryParse(form.value.credits) ?? 3,
      type:        form.value.type,
      prerequisite: form.value.prerequisite.isEmpty ? '—' : form.value.prerequisite,
    );
  }

  Future<void> confirmAdd() async {
    if (pendingCourse.value == null) return;
    isSubmitting.value = true;
    try {
      final created = await _service.addCourse(form.value, _facMap, _majMap);
      allCourses.add(created);
      // Update stats count
      if (stats.value != null) {
        stats.value = CourseStatsModel(
          totalCourses: stats.value!.totalCourses + 1,
          professors:   stats.value!.professors,
          faculties:    stats.value!.faculties,
        );
      }
      _applyFilter();
      resetForm();
      Get.back(); // close confirm dialog
      Get.back(); // close add sheet
      Get.snackbar('Success', 'Course added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900);
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900);
    } finally {
      isSubmitting.value = false;
    }
  }

  // ─── Edit ─────────────────────────────────────────────────────────────────
  Future<void> saveEdit() async {
    if (editingCourse.value == null) return;
    isSubmitting.value = true;
    try {
      final updated = await _service.editCourse(
          editingCourse.value!.id, form.value, _facMap, _majMap);
      final idx = allCourses.indexWhere((c) => c.id == updated.id);
      if (idx != -1) allCourses[idx] = updated;
      _applyFilter();
      resetForm();
      Get.back();
      Get.snackbar('Success', 'Course updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900);
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900);
    } finally {
      isSubmitting.value = false;
    }
  }

  // ─── Delete ───────────────────────────────────────────────────────────────
  Future<void> confirmDelete() async {
    if (deletingCourse.value == null) return;
    isSubmitting.value = true;
    try {
      await _service.deleteCourse(deletingCourse.value!.id);
      allCourses.removeWhere((c) => c.id == deletingCourse.value!.id);
      if (stats.value != null) {
        stats.value = CourseStatsModel(
          totalCourses: (stats.value!.totalCourses - 1).clamp(0, 99999),
          professors:   stats.value!.professors,
          faculties:    stats.value!.faculties,
        );
      }
      _applyFilter();
      deletingCourse.value = null;
      Get.back();
      Get.snackbar('Deleted', 'Course removed successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900);
    } finally {
      isSubmitting.value = false;
    }
  }
}
