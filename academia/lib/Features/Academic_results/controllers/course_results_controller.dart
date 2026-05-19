import 'package:get/get.dart';
import '../models/course_result_model.dart';
import '../services/results_service.dart';

class CourseResultsController extends GetxController {
  final ResultsService _service = ResultsService();
  final int semesterResultId;
  final String semesterLabel;

  CourseResultsController({
    required this.semesterResultId,
    required this.semesterLabel,
  });

  var courseResults = <CourseResultModel>[].obs;
  var gpa           = 0.0.obs;
  var isLoading     = true.obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    try {
      courseResults.value = await _service.getCourseResults(semesterResultId);
      if (courseResults.isNotEmpty) {
        gpa.value = courseResults.fold(0.0, (acc, c) => acc + c.gpaPoints) /
            courseResults.length;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load course results: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
