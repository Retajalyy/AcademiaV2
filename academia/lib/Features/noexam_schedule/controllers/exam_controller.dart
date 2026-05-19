import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/exam_model.dart';
import '../services/exam_service.dart';

class ExamController extends GetxController {
  final ExamService _service = ExamService();

  var exams      = <ExamModel>[].obs;
  var period     = Rxn<ExamPeriodModel>();
  var isLoading  = true.obs;

  List<ExamModel> get completedExams =>
      exams.where((e) => e.isCompleted).toList();

  List<ExamModel> get futureExams =>
      exams.where((e) => !e.isCompleted).toList();

  ExamModel? get nextExam => futureExams.isNotEmpty ? futureExams.first : null;

  List<ExamModel> get upcomingExams =>
      futureExams.length > 1 ? futureExams.sublist(1) : [];

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    try {
      final userId    = Supabase.instance.client.auth.currentUser!.id;
      final studentId = await _service.getStudentId(userId);
      final results   = await Future.wait([
        _service.getActivePeriod(),
        _service.getExams(studentId),
      ]);
      period.value = results[0] as ExamPeriodModel?;
      exams.value  = results[1] as List<ExamModel>;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load exam schedule: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
