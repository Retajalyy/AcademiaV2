// lib/Features/plan_admin/controllers/plan_admin_controller.dart

import 'package:get/get.dart';
import '../model/plan_admin_model.dart';
import '../service/plan_admin_service.dart';

class PlanAdminController extends GetxController {
  final PlanAdminService _service;

  PlanAdminController({PlanAdminService? service})
      : _service = service ?? PlanAdminService();

  // ─── Step 1 visibility flags ──────────────────────────────────────────────
  final RxBool showLevel = false.obs;
  final RxBool showMajor = false.obs;
  final RxBool showCourses = false.obs;
  final RxBool showAssignButton = false.obs;

  // ─── Step 1 selections ────────────────────────────────────────────────────
  final RxString selectedFaculty = ''.obs;
  final RxInt selectedLevel = 0.obs;
  final RxString selectedMajor = ''.obs;

  // ─── Step 2 ───────────────────────────────────────────────────────────────
  final RxBool isLecture = true.obs;
  final RxInt groupCapacity = 30.obs;
  final RxList<GroupModel> groups = <GroupModel>[].obs;

  // ─── Step 3 ───────────────────────────────────────────────────────────────
  final RxString activeGroupTab = 'SE1'.obs;
  final RxList<LectureScheduleModel> scheduleCards =
      <LectureScheduleModel>[].obs;

  // ─── Shared ───────────────────────────────────────────────────────────────
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // ─── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _loadSchedule('SE1');
  }

  // ─── Step 2 actions ───────────────────────────────────────────────────────
  void setScheduleType(bool lecture) => isLecture.value = lecture;
  void incrementCapacity() => groupCapacity.value++;
  void decrementCapacity() {
    if (groupCapacity.value > 1) groupCapacity.value--;
  }

  // ─── Step 3 actions ───────────────────────────────────────────────────────
  void selectGroupTab(String tab) {
    activeGroupTab.value = tab;
    _loadSchedule(tab);
  }

  void _loadSchedule(String groupName) {
    scheduleCards.assignAll(_service.getScheduleForGroup(groupName));
  }

  // ─── Save & Publish ───────────────────────────────────────────────────────
  Future<void> savePlan() async {
    isLoading.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> publishPlan() async {
    isLoading.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      Get.snackbar(
        'Published',
        'Semester plan published successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}