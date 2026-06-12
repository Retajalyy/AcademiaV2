import 'package:get/get.dart';
import '../model/course_detail_model.dart';
import '../services/course_detail_service.dart';

class CourseDetailsController extends GetxController {
  final CourseDetailsService _service = CourseDetailsService();

  var course       = Rx<CourseDetailsModel?>(null);
  var isLoading    = false.obs;
  var errorMessage = ''.obs;
  var doctorName   = ''.obs;
  var courseName   = ''.obs;
  var sectionId    = 0.obs;
  var courseId     = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final args       = Get.arguments as Map<String, dynamic>?;
    courseId.value   = args?['courseId']   as int?    ?? 0;
    sectionId.value  = args?['sectionId']  as int?    ?? 0;
    courseName.value = args?['courseName'] as String? ?? '';
    doctorName.value = args?['doctorName'] as String? ?? '';
    fetchDetails(courseId.value);
  }

  Future<void> fetchDetails(int courseId) async {
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
