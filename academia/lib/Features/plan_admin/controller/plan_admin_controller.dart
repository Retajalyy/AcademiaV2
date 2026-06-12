import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../model/plan_admin_model.dart';
import '../service/plan_admin_service.dart';
import '../../Registiration_admin/controller/registiration_controller.dart';

class PlanAdminController extends GetxController {
  final PlanAdminService _service;

  PlanAdminController({PlanAdminService? service})
      : _service = service ?? PlanAdminService();

  // ── Screen 1 visibility flags ─────────────────────────────────────────────
  final RxBool showLevel        = false.obs;
  final RxBool showMajor        = false.obs;
  final RxBool showCourses      = false.obs;
  final RxBool showAssignButton = false.obs;

  // ── Screen 1: DB-driven lists ─────────────────────────────────────────────
  // Each entry: {'code': 'FCI', 'name': 'Computer Science'}
  final RxList<Map<String, String>> faculties = <Map<String, String>>[].obs;
  // Each entry: {'code': 'EN_TRANS', 'name': 'English Translation'}
  final RxList<Map<String, String>> majors = <Map<String, String>>[].obs;
  final RxList<CourseModel> availableCourses = <CourseModel>[].obs;

  final RxBool facultiesLoading = false.obs;
  final RxBool majorsLoading    = false.obs;
  final RxBool coursesLoading   = false.obs;

  // ── Screen 1: current selections ─────────────────────────────────────────
  final RxString selectedFaculty    = ''.obs;
  final RxInt    selectedLevel      = 0.obs;
  final RxString selectedMajor     = ''.obs;
  final RxString selectedMajorName = ''.obs; // full display name

  // ── Screen 2: professors ──────────────────────────────────────────────────
  final RxList<ProfessorOption> professors      = <ProfessorOption>[].obs;
  final RxBool                  professorsLoading = false.obs;

  // ── Screen 2: selected course names ──────────────────────────────────────
  final RxList<String> selectedCourseNames = <String>[].obs;

  // ── Screen 2: multi-group support ────────────────────────────────────────
  // Each element = one group's assignments; index = group number
  final groupAssignments  = <Map<String, CourseAssignment>>[{}].obs;
  final groupCapacities   = <int>[30].obs;
  final activeGroupIndex  = 0.obs;

  // Active group convenience getters
  Map<String, CourseAssignment> get assignments =>
      groupAssignments[activeGroupIndex.value];

  int get groupCapacity => groupCapacities[activeGroupIndex.value];

  String groupLabel(int i) {
    final m = selectedMajor.value;
    final prefix = m.length >= 2 ? m.substring(0, 2).toUpperCase() : m.toUpperCase();
    return '$prefix${selectedLevel.value > 0 ? selectedLevel.value : ''}${i + 1}';
  }

  void addGroup() {
    // Refresh current group state (already kept in sync by setters)
    final newGroup = <String, CourseAssignment>{
      for (final c in selectedCourseNames) c: CourseAssignment(),
    };
    groupAssignments.add(newGroup);
    groupCapacities.add(30);
    activeGroupIndex.value = groupAssignments.length - 1;
    groupAssignments.refresh();
  }

  void switchGroup(int index) {
    activeGroupIndex.value = index;
    groupAssignments.refresh();
  }

  // ── Screen 3: saved group IDs + schedule ─────────────────────────────────
  final savedGroupIds    = <int>[];
  int?  savedGroupId; // last saved (kept for compat)
  final RxList<LectureScheduleModel> scheduleCards =
      <LectureScheduleModel>[].obs;

  // ── Shared ────────────────────────────────────────────────────────────────
  final RxBool   isLoading    = false.obs;
  final RxString errorMessage = ''.obs;

  // ── Screen 3 tab ──────────────────────────────────────────────────────────
  final RxString       activeGroupTab   = ''.obs;
  final RxList<String> savedGroupLabels = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadFaculties();
    loadProfessors();
  }

  // ── Load faculties from DB ────────────────────────────────────────────────
  Future<void> loadFaculties() async {
    facultiesLoading.value = true;
    errorMessage.value     = '';
    try {
      final list = await _service.fetchFaculties();
      faculties.assignAll(list);
    } catch (e) {
      errorMessage.value = 'Failed to load faculties: $e';
    } finally {
      facultiesLoading.value = false;
    }
  }

  // ── Called when admin selects a faculty (pass the CODE, e.g. 'FCI') ──────
  Future<void> selectFaculty(String facultyCode) async {
    selectedFaculty.value    = facultyCode;
    selectedLevel.value      = 0;
    selectedMajor.value      = '';
    selectedMajorName.value  = '';
    majors.clear();
    availableCourses.clear();
    selectedCourseNames.clear();
    assignments.clear();
    showLevel.value        = true;
    showMajor.value        = false;
    showCourses.value      = false;
    showAssignButton.value = false;

    majorsLoading.value = true;
    try {
      final list = await _service.fetchMajors(facultyCode);
      majors.assignAll(list);
    } catch (e) {
      errorMessage.value = 'Failed to load majors: $e';
    } finally {
      majorsLoading.value = false;
    }
  }

  // ── Called when admin selects a level ────────────────────────────────────
  void selectLevel(int level) {
    selectedLevel.value    = level;
    // Reset everything downstream so courses reload with the new year
    selectedMajor.value    = '';
    availableCourses.clear();
    selectedCourseNames.clear();
    assignments.clear();
    showCourses.value      = false;
    showAssignButton.value = false;
    showMajor.value        = true;
  }

  // ── Called when admin selects a major (pass the CODE e.g. 'EN_TRANS') ────
  Future<void> selectMajor(String majorCode) async {
    selectedMajor.value = majorCode;
    // Store the display name for use in Screen 3
    final match = majors.firstWhereOrNull((m) => m['code'] == majorCode);
    selectedMajorName.value = match?['name'] ?? majorCode;
    showCourses.value   = true;
    showAssignButton.value = false;
    availableCourses.clear();
    selectedCourseNames.clear();
    assignments.clear();

    coursesLoading.value = true;
    try {
      final raw = await _service.fetchCoursesRaw(
        facultyCode: selectedFaculty.value.isNotEmpty ? selectedFaculty.value : null,
        yearLevel:   selectedLevel.value > 0            ? selectedLevel.value   : null,
        majorCode:   majorCode.isNotEmpty               ? majorCode             : null,
      );
      availableCourses.assignAll(raw.map(_mapCourse));
    } catch (e) {
      errorMessage.value = 'Failed to load courses: $e';
    } finally {
      coursesLoading.value = false;
    }
  }

  CourseModel _mapCourse(Map<String, dynamic> row) {
    final isCore = (row['type'] as String? ?? 'Core') == 'Core';
    return CourseModel(
      id:         row['id'].toString(),
      name:       row['name'] as String,
      type:       row['type'] as String? ?? 'Core',
      credits:    (row['credit_hours'] as int?) ?? 3,
      icon:       isCore ? Icons.storage_rounded : Icons.trending_up_rounded,
      themeColor: isCore
          ? const Color(0xFFDDEDFA)
          : const Color(0xFFFFF3DF),
    );
  }

  // ── Load professors from DB ───────────────────────────────────────────────
  Future<void> loadProfessors() async {
    professorsLoading.value = true;
    try {
      final list = await _service.fetchProfessors();
      professors.assignAll(list);
    } catch (_) {
    } finally {
      professorsLoading.value = false;
    }
  }

  // ── Course selection (called from AddCoursesWidget) ───────────────────────
  void toggleCourse(String courseName, bool selected) {
    if (selected) {
      selectedCourseNames.add(courseName);
      assignments.putIfAbsent(courseName, () => CourseAssignment());
    } else {
      selectedCourseNames.remove(courseName);
      assignments.remove(courseName);
    }
    showAssignButton.value = selectedCourseNames.isNotEmpty;
  }

  bool isCourseSelected(String courseName) =>
      selectedCourseNames.contains(courseName);

  // ── Per-course assignment setters ─────────────────────────────────────────
  void setLectureProfessor(String c, int? id)    { _a(c).lectureProfessorId = id; groupAssignments.refresh(); }
  void setLectureDay(String c, String? v)        { _a(c).lectureDay  = v; groupAssignments.refresh(); }
  void setLectureHall(String c, String? v)       { _a(c).lectureHall = v; groupAssignments.refresh(); }
  void setLectureFrom(String c, String? v)       { _a(c).lectureFrom = v; groupAssignments.refresh(); }
  void setLectureTo(String c, String? v)         { _a(c).lectureTo   = v; groupAssignments.refresh(); }
  void toggleSection(String c, bool has)         { _a(c).hasSection  = has; groupAssignments.refresh(); }
  void setSectionProfessor(String c, int? id)    { _a(c).sectionProfessorId = id; groupAssignments.refresh(); }
  void setSectionDay(String c, String? v)        { _a(c).sectionDay  = v; groupAssignments.refresh(); }
  void setSectionHall(String c, String? v)       { _a(c).sectionHall = v; groupAssignments.refresh(); }
  void setSectionFrom(String c, String? v)       { _a(c).sectionFrom = v; groupAssignments.refresh(); }
  void setSectionTo(String c, String? v)         { _a(c).sectionTo   = v; groupAssignments.refresh(); }

  CourseAssignment _a(String course) =>
      assignments.putIfAbsent(course, () => CourseAssignment());

  // ── Capacity ──────────────────────────────────────────────────────────────
  void incrementCapacity() {
    groupCapacities[activeGroupIndex.value]++;
    groupCapacities.refresh();
  }
  void decrementCapacity() {
    if (groupCapacities[activeGroupIndex.value] > 1) {
      groupCapacities[activeGroupIndex.value]--;
      groupCapacities.refresh();
    }
  }

  // ── Save to DB — saves ALL groups ────────────────────────────────────────
  Future<void> saveAssignments() async {
    isLoading.value    = true;
    errorMessage.value = '';
    try {
      final profNames = { for (final p in professors) p.id: p.name };
      savedGroupIds.clear();
      final labels = <String>[];

      for (int i = 0; i < groupAssignments.length; i++) {
        final label = groupLabel(i);
        final groupId = await _service.saveGroupAssignments(
          faculty:        selectedFaculty.value,
          major:          selectedMajor.value,
          level:          selectedLevel.value,
          groupCapacity:  groupCapacities[i],
          assignments:    groupAssignments[i],
          professorNames: profNames,
          groupLabel:     label,
        );
        savedGroupIds.add(groupId);
        labels.add(label);
      }

      savedGroupId = savedGroupIds.isNotEmpty ? savedGroupIds.last : null;
      savedGroupLabels.assignAll(labels);
      activeGroupTab.value = labels.isNotEmpty ? labels.first : '';
      if (savedGroupIds.isNotEmpty) await _loadSchedule(savedGroupIds.first);
      Get.snackbar('Saved', 'Group assignments saved successfully.',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to save: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Load schedule for Screen 3 ────────────────────────────────────────────
  Future<void> _loadSchedule(int groupId) async {
    final raw = await _service.fetchGroupSchedule(groupId);
    scheduleCards.assignAll(raw.map(_mapSchedule));
  }

  LectureScheduleModel _mapSchedule(Map<String, dynamic> row) {
    final credits = (row['credit_hours'] as int?) ?? 3;
    return LectureScheduleModel(
      courseName:           row['course_name']        as String? ?? '',
      credits:              '$credits Credits',
      lectureDay:           row['lecture_day']         as String? ?? '-',
      lectureDoctor:        row['lecture_instructor']  as String? ?? '-',
      lectureTime:          '${row['lecture_start'] ?? '-'} - ${row['lecture_end'] ?? '-'}',
      lectureRoom:          row['lecture_room']        as String? ?? '-',
      sectionDay:           row['section_day']         as String? ?? '-',
      sectionDoctor:        row['section_instructor']  as String? ?? '-',
      sectionTime:          '${row['section_start'] ?? '-'} - ${row['section_end'] ?? '-'}',
      sectionRoom:          row['section_room']        as String? ?? '-',
      borderColor:          AppColors.accentProgramming1,
      creditBackgroundColor: AppColors.bluegroundicon,
      creditsTextColor:     AppColors.accentProgramming1,
    );
  }

  // ── Screen 3 tab ──────────────────────────────────────────────────────────
  void selectGroupTab(String tab) => activeGroupTab.value = tab;

  Future<void> publishPlan() async {
    isLoading.value = true;
    try {
      // Data already persisted by saveAssignments().
      // Delete both controllers so fresh state is guaranteed on return.
      Get.delete<PlanAdminController>(force: true);
      Get.delete<RegistrationController>(force: true);

      // Navigate — RegistrationAdminScreen will create a fresh
      // RegistrationController that loads plans from DB on init.
      Get.offAllNamed('/registirationAdmin');

      Get.snackbar(
        'Published',
        'Semester plan published successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF22C55E),
        colorText: Colors.white,
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to publish: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
