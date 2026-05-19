// lib/Features/Course/controllers/course_details_controller.dart

import 'package:get/get.dart';
import '../model/course_detail_model.dart';
import '../service/course_detail_service.dart';

class CourseDetailsController extends GetxController {
  final CourseDetailsService _service = CourseDetailsService();

  final Rx<CourseDetailsModel?> course = Rx<CourseDetailsModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final String courseId =
        (Get.arguments as Map<String, dynamic>?)?['courseId'] as String? ??
            'default-id';
    fetchDetails(courseId);
  }

  Future<void> fetchDetails(String courseId) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      course.value = await _service.fetchCourseDetails(courseId);
    } catch (e) {
      errorMessage.value = 'Failed to load course details. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  String get courseName => course.value?.courseName ?? '';
  String get doctorName => course.value?.doctorName ?? '';
  int get credits => course.value?.credits ?? 0;
  double get progress => course.value?.progress ?? 0.0;
  String get progressLabel => course.value?.progressLabel ?? '0% completed';
  double get classworkPercent => course.value?.classworkPercent ?? 0.0;
  double get assignmentsPercent => course.value?.assignmentsPercent ?? 0.0;
  double get attendancePercent => course.value?.attendancePercent ?? 0.0;
  List<CourseMaterial> get materials => course.value?.materials ?? [];
}