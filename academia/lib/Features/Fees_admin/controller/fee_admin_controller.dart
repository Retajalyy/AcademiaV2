// lib/Features/fees_admin/controller/fee_admin_controller.dart

import 'package:get/get.dart';
import '../model/fee_admin_model.dart';
import '../service/fee_admin_service.dart';

class FeesAdminController extends GetxController {
  final FeesAdminService _service;

  FeesAdminController({FeesAdminService? service})
      : _service = service ?? FeesAdminService();

  // ─── Main screen ──────────────────────────────────────────────────────────
  final Rx<FeesSummaryModel?> summary = Rx<FeesSummaryModel?>(null);
  final RxList<ActiveFeeModel> activeFees = <ActiveFeeModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  // ─── Live preview (updates as user types) ────────────────────────────────
  double _baseCollected = 0;
  double _baseTotal = 0;
  final RxDouble liveCollected = 0.0.obs;
  final RxDouble liveTotal = 0.0.obs;

  // ─── Form state ───────────────────────────────────────────────────────────
  final Rx<FeeType?> selectedFeeType = Rx<FeeType?>(null);
  final RxString amount = ''.obs;
  final RxString selectedFaculty = ''.obs;
  final RxString selectedLevel = ''.obs;
  final Rx<DateTime?> selectedDueDate = Rx<DateTime?>(null);
  final RxBool isSubmitting = false.obs;
  final RxBool isReminding = false.obs;

  final List<String> faculties = [
    'All Faculties',
    'Computers & Information',
    'Languages & Translation',
    'Business Administration',
  ];

  final List<String> levels = ['All', '1', '2', '3', '4'];

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
        _service.fetchSummary(),
        _service.fetchActiveFees(),
      ]);
      summary.value = results[0] as FeesSummaryModel;
      activeFees.assignAll(results[1] as List<ActiveFeeModel>);

      // Set base values for live calculation
      _baseCollected = summary.value!.collectedRaw;
      _baseTotal = summary.value!.totalRaw;
      liveCollected.value = _baseCollected;
      liveTotal.value = _baseTotal;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Live formatted getters ───────────────────────────────────────────────

  String get liveTotalCollectedFormatted =>
      "${_fmt(liveCollected.value)} EGP";

  String get liveCollectedDetailFormatted =>
      "${_fmt(liveCollected.value)} of ${_fmt(liveTotal.value)} EGP collected";

  double get liveProgress =>
      liveTotal.value == 0 ? 0 : liveCollected.value / liveTotal.value;

  String _fmt(double value) => value
      .toStringAsFixed(0)
      .replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );

  // ─── Form actions ─────────────────────────────────────────────────────────

  void selectFeeType(FeeType type) {
    selectedFeeType.value = type;
    selectedFaculty.value = '';
    selectedLevel.value = '';
  }

  void selectFaculty(String faculty) => selectedFaculty.value = faculty;

  void selectLevel(String level) => selectedLevel.value = level;

  // ✅ Updates live total as user types
  void setAmount(String value) {
    amount.value = value;
    final typed = double.tryParse(value) ?? 0;
    liveCollected.value = _baseCollected + typed;
    liveTotal.value = _baseTotal + typed;
  }

  void setDueDate(DateTime date) => selectedDueDate.value = date;

  bool get isFormValid =>
      selectedFeeType.value != null &&
      amount.value.isNotEmpty &&
      selectedFaculty.value.isNotEmpty &&
      selectedLevel.value.isNotEmpty &&
      selectedDueDate.value != null;

  Future<void> submitFee() async {
    if (!isFormValid) {
      Get.snackbar(
        'Incomplete',
        'Please fill all fields',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSubmitting.value = true;
    try {
      final form = AddFeeFormModel(
        feeType: selectedFeeType.value,
        amount: amount.value,
        faculty: selectedFaculty.value,
        level: selectedLevel.value,
        dueDate: selectedDueDate.value,
      );

      final success = await _service.submitFee(form);

      if (success) {
        _resetForm();
        await loadData();
        Get.back();
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> remindUnpaid() async {
    isReminding.value = true;
    try {
      await _service.remindUnpaid();
      Get.snackbar(
        'Reminders Sent',
        'Unpaid students have been notified',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isReminding.value = false;
    }
  }

  void _resetForm() {
    selectedFeeType.value = null;
    amount.value = '';
    selectedFaculty.value = '';
    selectedLevel.value = '';
    selectedDueDate.value = null;
    liveCollected.value = _baseCollected;
    liveTotal.value = _baseTotal;
  }

  String get formattedDueDate {
    if (selectedDueDate.value == null) return '';
    final d = selectedDueDate.value!;
    return "${d.day}/${d.month}/${d.year}";
  }
}