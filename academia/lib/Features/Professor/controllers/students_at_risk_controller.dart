import 'package:get/get.dart';
import '../models/attendance_models.dart';
import '../services/professor_service.dart';

class StudentsAtRiskController extends GetxController {
  final _service = ProfessorService();

  int  professorId = 0;
  bool isTA        = false;

  final courses   = <AtRiskCourse>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      professorId = args['professorId'] as int?  ?? 0;
      isTA        = args['isTA']        as bool? ?? false;
    }
    _load();
  }

  Future<void> _load() async {
    if (professorId == 0) {
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    try {
      courses.value = await _service.getStudentsAtRisk(
          professorId, isTA: isTA);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> refresh() => _load();
}
