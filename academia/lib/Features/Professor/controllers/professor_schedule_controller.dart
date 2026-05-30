import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/professor_schedule_item.dart';
import '../services/professor_service.dart';

class ProfessorScheduleController extends GetxController {
  final ProfessorService _service = ProfessorService();

  var classes = <ProfessorScheduleItem>[].obs;
  var isLoading = true.obs;
  var selectedDayIndex = 0.obs; // 0 = Sunday … 6 = Saturday

  int _professorId = 0;

  static const _fullDays = [
    'Sunday', 'Monday', 'Tuesday', 'Wednesday',
    'Thursday', 'Friday', 'Saturday',
  ];

  @override
  void onInit() {
    super.onInit();
    // Map DateTime.weekday (1=Mon…7=Sun) → our 0=Sun…6=Sat index
    selectedDayIndex.value = DateTime.now().weekday % 7;
    _init();
  }

  Future<void> _init() async {
    isLoading.value = true;
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      _professorId = await _service.getProfessorId(userId);
      await _loadForDay(selectedDayIndex.value);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load schedule: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectDay(int index) async {
    if (selectedDayIndex.value == index && classes.isNotEmpty) return;
    selectedDayIndex.value = index;
    isLoading.value = true;
    try {
      await _loadForDay(index);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadForDay(int index) async {
    classes.value =
        await _service.getScheduleForDay(_professorId, _fullDays[index]);
  }
}
