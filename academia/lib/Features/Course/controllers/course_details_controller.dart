import 'package:get/get.dart';
import '../model/course_detail_model.dart';
import '../services/course_detail_service.dart';

class CourseDetailsController extends GetxController {
  final CourseDetailsService _service = CourseDetailsService();

  var course       = Rx<CourseDetailsModel?>(null);
  var isLoading    = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args     = Get.arguments as Map<String, dynamic>?;
    final courseId = args?['courseId'] as String? ?? 'default-id';
    fetchDetails(courseId);
  }

  Future<void> fetchDetails(String courseId) async {
    isLoading.value    = true;
    errorMessage.value = '';
    try {
      course.value = await _service.fetchCourseDetails(courseId);
    } catch (e) {
      errorMessage.value = 'Failed to load course details: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
