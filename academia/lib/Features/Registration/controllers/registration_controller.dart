import 'package:get/get.dart';
import '../models/registration_model.dart';
import '../services/registration_service.dart';

class RegistrationController extends GetxController {
  final RegistrationService _service;

  RegistrationController({RegistrationService? service})
      : _service = service ?? RegistrationService();

  final Rx<RegistrationState> registrationState = RegistrationState.open.obs;
  final RxBool isLoading    = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;

  final RxInt selectedTabIndex = 0.obs;
  final RxString selectedGroupId = ''.obs;
  final RxList<CourseGroup> availableGroups = <CourseGroup>[].obs;
  final RxList<CourseWithWarning> scheduledCourses = <CourseWithWarning>[].obs;

  // Tracks course codes the student chose to add despite a locked prerequisite
  final RxSet<String> forceAddedCodes = <String>{}.obs;

  final Rx<SemesterInfo?> semesterInfo = Rx<SemesterInfo?>(null);
  final Rx<BalanceInfo?> balanceInfo   = Rx<BalanceInfo?>(null);

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    isLoading.value = true;
    try {
      final state = await _service.fetchRegistrationState();
      registrationState.value = state;
      switch (state) {
        case RegistrationState.open:          await _loadGroups();       break;
        case RegistrationState.closed:        await _loadSemesterInfo(); break;
        case RegistrationState.notOpenedYet:  await _loadBalanceInfo();  break;
        case RegistrationState.feesRequired:  await _loadBalanceInfo();  break;
        case RegistrationState.done:          break;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load registration data. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadGroups() async {
    final groups = await _service.fetchGroups('');
    availableGroups.assignAll(groups);
    if (groups.isNotEmpty) {
      selectedTabIndex.value  = 0;
      selectedGroupId.value   = groups.first.id;
      _populateSchedule(groups.first);
    }
  }

  void onTabChanged(int index) {
    if (selectedTabIndex.value == index) return;
    if (index >= availableGroups.length) return;
    selectedTabIndex.value = index;
    final group = availableGroups[index];
    selectedGroupId.value = group.id;
    forceAddedCodes.clear();
    _populateSchedule(group);
  }

  void _populateSchedule(CourseGroup group) {
    scheduledCourses.assignAll(
      group.lectures.map((l) => CourseWithWarning(
        lecture:        l,
        warningMessage: l.prerequisiteWarning,
        isLocked:       l.isLocked,
      )).toList(),
    );
  }

  // Called when the student taps "+ Add" on a locked course
  void addLockedCourse(String courseCode) {
    forceAddedCodes.add(courseCode);
    // Rebuild the list so the card reacts
    scheduledCourses.refresh();
  }

  bool isCourseForceAdded(String courseCode) =>
      forceAddedCodes.contains(courseCode);

  Future<void> _loadSemesterInfo() async {
    semesterInfo.value = await _service.fetchSemesterInfo();
  }

  Future<void> _loadBalanceInfo() async {
    balanceInfo.value = await _service.fetchBalanceInfo();
  }

  Future<void> confirmRegistration() async {
    errorMessage.value = '';

    // Check for unresolved locked courses (not force-added)
    final unresolvedLocked = scheduledCourses.where(
      (c) => c.isLocked && !forceAddedCodes.contains(c.lecture.courseCode),
    ).toList();

    if (unresolvedLocked.isNotEmpty) {
      errorMessage.value =
          'Some courses have unmet prerequisites. Tap "+ Add" to include them anyway, or remove them.';
      return;
    }

    isSubmitting.value = true;
    try {
      await _service.submitRegistration(
        groupId:          selectedGroupId.value,
        forceAddedCodes:  forceAddedCodes.toList(),
      );
      registrationState.value = RegistrationState.done;
    } catch (e) {
      errorMessage.value = 'Submission failed: $e';
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> payNow() async {
    isSubmitting.value = true;
    try {
      await _service.initiatePayment(
          amount: balanceInfo.value?.outstandingAmount ?? 0);
      Get.snackbar('Redirecting', 'Opening payment portal...',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage.value = 'Payment initiation failed.';
    } finally {
      isSubmitting.value = false;
    }
  }

  void clearError() => errorMessage.value = '';

  int get totalCreditHours =>
      availableGroups
          .firstWhereOrNull((g) => g.id == selectedGroupId.value)
          ?.creditHours ?? 0;

  CourseGroup? get selectedGroup =>
      availableGroups.firstWhereOrNull((g) => g.id == selectedGroupId.value);
}
