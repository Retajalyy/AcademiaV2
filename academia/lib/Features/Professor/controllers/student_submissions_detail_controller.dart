import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../models/assignment_submission_info.dart';
import '../models/professor_course_model.dart';
import '../models/student_submission_record.dart';
import '../services/professor_service.dart';

class StudentSubmissionsDetailController extends GetxController {
  final _service = ProfessorService();

  late final ProfessorCourseModel      course;
  late final AssignmentSubmissionInfo  assignment;
  late final int  professorId;
  late final bool isTA;

  final students     = <StudentSubmissionRecord>[].obs;
  final isLoading    = true.obs;
  final isSaving     = false.obs;

  // grade inputs: enrollmentId → TextEditingController
  final gradeControllers = <int, TextEditingController>{};

  @override
  void onInit() {
    super.onInit();
    final args  = Get.arguments as Map<String, dynamic>;
    course      = args['course']      as ProfessorCourseModel;
    assignment  = args['assignment']  as AssignmentSubmissionInfo;
    professorId = args['professorId'] as int;
    isTA        = args['isTA']        as bool? ?? false;
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    try {
      final list = await _service.getStudentSubmissionsForAssignment(
        professorId:  professorId,
        courseId:     course.courseId,
        materialId:   assignment.materialId,
        dueDate:      assignment.dueDate,
        materialType: assignment.materialType,
        isTA:         isTA,
      );
      students.value = list;

      // Build grade input controllers
      for (final s in list) {
        gradeControllers[s.enrollmentId] = TextEditingController(
          text: s.currentGrade != null
              ? s.currentGrade!.toStringAsFixed(0)
              : '',
        );
      }
    } catch (_) {
      students.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveGrade(int enrollmentId) async {
    final ctrl  = gradeControllers[enrollmentId];
    if (ctrl == null) return;
    final score = double.tryParse(ctrl.text.trim());
    if (score == null) return;

    final student = students.firstWhereOrNull((s) => s.enrollmentId == enrollmentId);

    isSaving.value = true;
    try {
      await _service.saveStudentGrade(
        enrollmentId: enrollmentId,
        materialType: assignment.materialType,
        score:        score,
        studentId:    student?.studentId,
        assignmentId: assignment.materialId,
      );
      Get.snackbar('Saved', 'Grade saved successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save grade: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    for (final c in gradeControllers.values) { c.dispose(); }
    super.onClose();
  }
}
