import 'package:get/get.dart';
import '../models/professor_course_model.dart';
import '../models/assignment_submission_info.dart';
import '../services/professor_service.dart';

class ProfessorSubmissionsController extends GetxController {
  final _service = ProfessorService();

  late final ProfessorCourseModel course;
  late final int  professorId;
  late final bool isTA;

  final assignments = <AssignmentSubmissionInfo>[].obs;
  final isLoading   = true.obs;

  @override
  void onInit() {
    super.onInit();
    final args  = Get.arguments as Map<String, dynamic>;
    course      = args['course']      as ProfessorCourseModel;
    professorId = args['professorId'] as int;
    isTA        = args['isTA']        as bool? ?? false;
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    try {
      assignments.value = await _service.getCourseAssignments(
        professorId: professorId,
        courseId:    course.courseId,
        isTA:        isTA,
      );
    } catch (_) {
      assignments.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> refresh() => _load();
}
