// lib/features/exam/presentation/controllers/exam_controller.dart

import 'package:get/get.dart';
import '../model/exam_model.dart';
import '../service/exam_service.dart';

class ExamController extends GetxController {
  final ExamService _service = ExamService();

  // ── Observables ──────────────────────────────────────────
  final RxList<ExamModel>       exams       = <ExamModel>[].obs;
  final Rx<ExamPeriodModel?>    examPeriod  = Rx<ExamPeriodModel?>(null);
  final RxBool                  isLoading   = true.obs;
  final RxString                errorMessage = ''.obs;

  // ── Derived getters (no extra Rx needed) ─────────────────
  ExamModel? get nextExam =>
      exams.firstWhereOrNull((e) => e.status == ExamStatus.next);

  List<ExamModel> get upcomingExams =>
      exams.where((e) => e.status == ExamStatus.upcoming).toList();

  List<ExamModel> get completedExams =>
      exams.where((e) => e.status == ExamStatus.completed).toList();

  bool get hasExams => exams.isNotEmpty;

  // ── Lifecycle ────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  // ── Methods ──────────────────────────────────────────────
  Future<void> loadData() async {
    isLoading.value   = true;
    errorMessage.value = '';

    try {
      final results = await Future.wait([
        _service.fetchExams(),
        _service.fetchExamPeriod(),
      ]);

      exams.assignAll(results[0] as List<ExamModel>);
      examPeriod.value = results[1] as ExamPeriodModel?;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() => loadData();
}