import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/professor_schedule_item.dart';
import '../services/professor_service.dart';

class ProfessorHomeController extends GetxController {
  final ProfessorService _service = ProfessorService();

  var professorName = ''.obs;
  var todaySchedule = <ProfessorScheduleItem>[].obs;
  var nextClass = Rxn<ProfessorScheduleItem>();
  var overviewStats = <String, int>{}.obs;
  var isLoading = true.obs;

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
        _service.getProfessorId(userId),
      ]);

      final name = results[0] as String;
      final professorId = results[1] as int;

      professorName.value = name;

      final data = await Future.wait([
        _service.getTodaySchedule(professorId),
        _service.getNextClass(professorId),
        _service.getOverviewStats(professorId),
      ]);

      todaySchedule.value = data[0] as List<ProfessorScheduleItem>;
      nextClass.value = data[1] as ProfessorScheduleItem?;
      overviewStats.value = data[2] as Map<String, int>;
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
