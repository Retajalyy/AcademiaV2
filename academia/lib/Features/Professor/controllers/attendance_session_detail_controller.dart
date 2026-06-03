import 'package:get/get.dart';
import '../models/attendance_models.dart';
import '../services/professor_service.dart';

class AttendanceSessionDetailController extends GetxController {
  final _service = ProfessorService();

  late final int    sessionId;
  late final String sessionLabel; // e.g. "Lecture 11"

  final records        = <SessionStudentRecord>[].obs;
  final isLoading      = true.obs;
  final selectedGroup  = 'All'.obs;

  List<String> get groups {
    final labels = records.map((r) => r.groupLabel).where((l) => l.isNotEmpty).toSet().toList()..sort();
    return ['All', ...labels];
  }

  List<SessionStudentRecord> get filtered {
    if (selectedGroup.value == 'All') return records;
    return records.where((r) => r.groupLabel == selectedGroup.value).toList();
  }

  @override
  void onInit() {
    super.onInit();
    final args    = Get.arguments as Map<String, dynamic>;
    sessionId     = args['sessionId']    as int;
    sessionLabel  = args['sessionLabel'] as String;
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    try {
      records.value = await _service.getSessionDetail(sessionId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load session: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
