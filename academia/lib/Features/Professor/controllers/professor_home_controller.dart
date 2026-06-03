import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/professor_schedule_item.dart';
import '../services/professor_service.dart';

class ProfessorHomeController extends GetxController {
  final ProfessorService _service = ProfessorService();

  final professorName    = ''.obs;
  final professorTitle   = 'Dr'.obs;
  final isTA             = false.obs;
  int   professorId      = 0;
  final todaySchedule    = <ProfessorScheduleItem>[].obs;
  final nextClass        = Rxn<ProfessorScheduleItem>();
  final overviewStats    = <String, int>{}.obs;
  final isLoading        = true.obs;

  final studentsAtRisk   = 0.obs;
  final latestAssignment = Rxn<Map<String, dynamic>>();
  final nextExamInfo     = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    isLoading.value = true;
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;

      final results = await Future.wait([
        _service.getProfessorName(userId),
        _service.getProfessorInfo(userId),
      ]);

      final name = results[0] as String;
      final info = results[1] as ({int id, bool isTA, String title});

      professorName.value  = name;
      isTA.value           = info.isTA;
      professorTitle.value = info.title;
      professorId          = info.id;

      final data = await Future.wait([
        _service.getTodaySchedule(info.id, isTA: info.isTA),
        _service.getNextClass(info.id, isTA: info.isTA),
        _service.getOverviewStats(info.id, isTA: info.isTA),
        _service.getStudentsAtRiskCount(info.id, isTA: info.isTA),
        _service.getLatestAssignmentInfo(info.id, isTA: info.isTA),
        _service.getNextExamInfo(info.id, isTA: info.isTA),
      ]);

      todaySchedule.value    = data[0] as List<ProfessorScheduleItem>;
      nextClass.value        = data[1] as ProfessorScheduleItem?;
      overviewStats.value    = data[2] as Map<String, int>;
      studentsAtRisk.value   = data[3] as int;
      latestAssignment.value = data[4] as Map<String, dynamic>?;
      nextExamInfo.value     = data[5] as Map<String, dynamic>?;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> refresh() => loadHomeData();

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  String get avatarInitials {
    final parts = professorName.value.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
