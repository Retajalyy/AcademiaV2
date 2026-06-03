import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/professor_course_model.dart';
import '../services/professor_service.dart';

class ProfessorCoursesController extends GetxController {
  final ProfessorService _service = ProfessorService();

  var courses     = <ProfessorCourseModel>[].obs;
  var isLoading   = true.obs;
  var isTA        = false.obs;
  int professorId = 0;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final info   = await _service.getProfessorInfo(userId);
      professorId  = info.id;
      isTA.value   = info.isTA;
      courses.value =
          await _service.getCourses(professorId, isTA: info.isTA);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load courses: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> refresh() => _load();
}
