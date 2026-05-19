// lib/Features/course_admin/controller/course_admin_controller.dart

import 'package:get/get.dart';
import '../model/course_admin_model.dart';
import '../service/course_admin_service.dart';

class CourseAdminController extends GetxController {
  final CourseAdminService _service;

  CourseAdminController({CourseAdminService? service})
      : _service = service ?? CourseAdminService();

  // ─── State ────────────────────────────────────────────────────────────────
  final Rx<CourseStatsModel?> stats = Rx(null);
  final RxList<CourseAdminModel> allCourses = <CourseAdminModel>[].obs;
  final RxList<CourseAdminModel> filteredCourses = <CourseAdminModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  // ─── Filter ───────────────────────────────────────────────────────────────
  final RxString searchQuery = ''.obs;
  final RxString selectedTab = 'All'.obs;

  // ✅ FIXED TAB LABELS (consistent everywhere)
  final List<String> tabs = [
    'All',
    'Computers & Information',
    'Business Administration',
    'Languages & Translation',
  ];

  // ─── Form ─────────────────────────────────────────────────────────────────
  final Rx<CourseFormModel> form = const CourseFormModel().obs;
  final RxBool isSubmitting = false.obs;

  // ─── Dialog / sheet state ─────────────────────────────────────────────────
  final Rx<CourseAdminModel?> pendingCourse = Rx(null);
  final Rx<CourseAdminModel?> editingCourse = Rx(null);
  final Rx<CourseAdminModel?> deletingCourse = Rx(null);

  // ─── Dropdown options ─────────────────────────────────────────────────────
  final List<String> faculties = [
    'Computers & Information',
    'Business Administration',
    'Languages & Translation',
  ];

  final List<String> levels = ['Year 1', 'Year 2', 'Year 3', 'Year 4'];

  final List<String> majors = [
    'Software Engineering',
    'Cyber Security',
    'Artificial Intelligence',
    'Business Administration',
    'Finance & Investment',
    'Languages & Translation',
    'General',
  ];

  final List<String> creditsList = ['1', '2', '3', '4'];
  final List<String> types = ['Core', 'Elective'];

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final results = await Future.wait([
        _service.fetchStats(),
        _service.fetchCourses(),
      ]);

      stats.value = results[0] as CourseStatsModel;
      allCourses.assignAll(results[1] as List<CourseAdminModel>);

      _applyFilter();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void onSearch(String q) {
    searchQuery.value = q;
    _applyFilter();
  }

  void onTabSelected(String tab) {
    selectedTab.value = tab;
    _applyFilter();
  }

  // ─── FIXED FILTER LOGIC ───────────────────────────────────────────────────
  void _applyFilter() {
    var list = allCourses.toList();

    // Faculty filter
    if (selectedTab.value != 'All') {
      list = list.where((c) {
        final faculty = c.faculty.toLowerCase();

        switch (selectedTab.value) {
          case 'Computers & Information':
            return faculty.contains('computers');
          case 'Business Administration':
            return faculty.contains('business');
          case 'Languages & Translation':
            return faculty.contains('languages');
          default:
            return true;
        }
      }).toList();
    }

    // Search filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      list = list
          .where((c) => c.name.toLowerCase().contains(query))
          .toList();
    }

    filteredCourses.assignAll(list);
  }

  // ─── Form ─────────────────────────────────────────────────────────────────
  void setField({
    String? name,
    String? faculty,
    String? level,
    String? major,
    String? credits,
    String? type,
    String? prerequisite,
  }) {
    form.value = form.value.copyWith(
      name: name,
      faculty: faculty,
      level: level,
      major: major,
      credits: credits,
      type: type,
      prerequisite: prerequisite,
    );
  }

  void resetForm() {
    form.value = const CourseFormModel();
    pendingCourse.value = null;
    editingCourse.value = null;
  }

  void loadEditForm(CourseAdminModel course) {
    editingCourse.value = course;
    form.value = CourseFormModel(
      name: course.name,
      faculty: course.faculty,
      level: course.level,
      major: course.major,
      credits: course.credits.toString(),
      type: course.type,
      prerequisite: course.prerequisite == '—' ? '' : course.prerequisite,
    );
  }

  // ─── Add ──────────────────────────────────────────────────────────────────
  Future<void> previewAdd() async {
    if (!form.value.isValid) {
      Get.snackbar(
        'Incomplete',
        'Please fill all required fields',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSubmitting.value = true;
    try {
      final course = await _service.addCourse(form.value);
      pendingCourse.value = course;
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> confirmAdd() async {
    if (pendingCourse.value == null) return;

    allCourses.add(pendingCourse.value!);
    _applyFilter();
    resetForm();

    Get.back();
    Get.back();
  }

  // ─── Edit ─────────────────────────────────────────────────────────────────
  Future<void> saveEdit() async {
    if (editingCourse.value == null) return;

    isSubmitting.value = true;
    try {
      final updated = await _service.editCourse(
        editingCourse.value!.id,
        form.value,
      );

      final idx = allCourses.indexWhere((c) => c.id == updated.id);
      if (idx != -1) allCourses[idx] = updated;

      _applyFilter();
      resetForm();
      Get.back();
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
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
      _applyFilter();

      deletingCourse.value = null;
      Get.back();
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSubmitting.value = false;
    }
  }
}