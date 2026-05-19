import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course_model.dart';
import '../services/course_service.dart';

class CourseController extends GetxController {
  final CourseService _service = CourseService();

  var courses   = <CourseModel>[].obs;
  var isLoading = true.obs;

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
      courses.value   = await _service.getEnrolledCourses(studentId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load courses: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
