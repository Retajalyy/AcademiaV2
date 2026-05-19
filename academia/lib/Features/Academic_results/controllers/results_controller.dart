import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/semester_result_model.dart';
import '../services/results_service.dart';

class ResultsController extends GetxController {
  final ResultsService _service = ResultsService();

  var semesters = <SemesterResultModel>[].obs;
  var isLoading = true.obs;

  double get cumulativeGpa {
    final published = semesters.where((s) => s.gpa != null).toList();
    if (published.isEmpty) return 0;
    return published.fold(0.0, (acc, s) => acc + s.gpa!) / published.length;
  }

  // Index 0 = Semester 1, index 7 = Semester 8
  List<double?> get semesterGpas => List.generate(8, (i) {
        try {
          return semesters.firstWhere((s) => s.number == i + 1).gpa;
        } catch (_) {
          return null;
        }
      });

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
      semesters.value = await _service.getSemesterResults(studentId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load results: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
