// lib/Features/Registiration_admin/controllers/registration_controller.dart

import 'package:get/get.dart';
import '../model/registiration_model.dart';
import '../service/registration_service.dart';

/// Possible states for the registration screen
enum RegistrationStatus { initial, loading, hasPlans, noPlans, error }

class RegistrationController extends GetxController {
  final RegistrationService _service;

  RegistrationController({RegistrationService? service})
      : _service = service ?? RegistrationService();

  // ─── Observables ──────────────────────────────────────────────────────────

  final Rx<RegistrationStatus> status =
      RegistrationStatus.initial.obs;

  final Rx<RegistrationStatusModel?> registrationStatus =
      Rx<RegistrationStatusModel?>(null);

  final RxList<RegistrationPlanModel> activePlans =
      <RegistrationPlanModel>[].obs;

  final RxString errorMessage = ''.obs;

  final RxBool isActionLoading = false.obs;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  // ─── Load ─────────────────────────────────────────────────────────────────

  Future<void> loadData() async {
    status.value = RegistrationStatus.loading;
    errorMessage.value = '';

    try {
      final hasPlans = await _service.fetchHasActivePlans();

      if (!hasPlans) {
        status.value = RegistrationStatus.noPlans;
        return;
      }

      // Load status + plans in parallel
      final results = await Future.wait([
        _service.fetchRegistrationStatus(),
        _service.fetchActivePlans(),
      ]);

      registrationStatus.value = results[0] as RegistrationStatusModel;
      activePlans.assignAll(results[1] as List<RegistrationPlanModel>);

      status.value = RegistrationStatus.hasPlans;
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = RegistrationStatus.error;
    }
  }

  Future<void> refresh() => loadData();

  // ─── Actions ──────────────────────────────────────────────────────────────

  Future<void> createNewPlan(Map<String, dynamic> data) async {
    isActionLoading.value = true;
    try {
      final newPlan = await _service.createPlan(data);
      activePlans.add(newPlan);
      status.value = RegistrationStatus.hasPlans;
      Get.snackbar(
        'Success',
        'New plan created successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create plan: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> deletePlan(String planId) async {
    isActionLoading.value = true;
    try {
      final success = await _service.deletePlan(planId);
      if (success) {
        activePlans.removeWhere((p) => p.id == planId);
        if (activePlans.isEmpty) {
          status.value = RegistrationStatus.noPlans;
        }
        Get.snackbar(
          'Success',
          'Plan removed successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete plan: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isActionLoading.value = false;
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  bool get isLoading => status.value == RegistrationStatus.loading;
  bool get hasError => status.value == RegistrationStatus.error;
  bool get hasActivePlans => status.value == RegistrationStatus.hasPlans;
  bool get noActivePlans => status.value == RegistrationStatus.noPlans;
}