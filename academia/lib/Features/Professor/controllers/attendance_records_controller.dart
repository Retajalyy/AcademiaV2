import 'package:get/get.dart';
import '../models/attendance_models.dart';
import '../services/professor_service.dart';

class AttendanceRecordsController extends GetxController {
  final _service = ProfessorService();

  late final int    courseId;
  late final String courseName;
  late final int    professorId;
  late final bool   isTA;

  final sessions  = <AttendanceSessionSummary>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    final args  = Get.arguments as Map<String, dynamic>;
    courseId    = args['courseId']    as int;
    courseName  = args['courseName']  as String;
    professorId = args['professorId'] as int;
    isTA        = args['isTA']        as bool? ?? false;
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    try {
      sessions.value = await _service.getAttendanceSessions(
          professorId, courseId, isTA: isTA);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load records: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteSession(int sessionId) async {
    try {
      await _service.deleteAttendanceSession(sessionId);
      sessions.removeWhere((s) => s.sessionId == sessionId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete: $e',
          snackPosition: SnackPosition.BOTTOM);
      await _load(); // re-fetch to restore if delete failed
    }
  }

  @override
  Future<void> refresh() => _load();
}
