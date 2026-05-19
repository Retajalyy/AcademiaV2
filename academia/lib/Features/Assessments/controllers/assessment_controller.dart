import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/assessment_model.dart';
import '../services/assessment_service.dart';

class AssessmentController extends GetxController {
  final AssessmentService _service = AssessmentService();

  var assessments   = <AssessmentModel>[].obs;
  var isLoading     = true.obs;
  var searchQuery   = ''.obs;

  List<AssessmentModel> get filtered => searchQuery.value.isEmpty
      ? assessments
      : assessments.where((a) =>
            a.courseName.toLowerCase().contains(searchQuery.value.toLowerCase()))
          .toList();

  double get avgMidterm {
    if (assessments.isEmpty) return 0;
    final sum = assessments.fold(0.0, (acc, a) =>
        acc + (a.midtermTotal > 0 ? (a.midterm / a.midtermTotal) * 100 : 0));
    return sum / assessments.length;
  }

  double get avgParticipation {
    if (assessments.isEmpty) return 0;
    final sum = assessments.fold(0.0, (acc, a) =>
        acc + (a.participationTotal > 0 ? (a.participation / a.participationTotal) * 100 : 0));
    return sum / assessments.length;
  }

  double get avgAttendance {
    if (assessments.isEmpty) return 0;
    return assessments.fold(0.0, (acc, a) => acc + a.attendance) / assessments.length;
  }

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
      assessments.value = await _service.getAssessments(studentId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load assessments: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
