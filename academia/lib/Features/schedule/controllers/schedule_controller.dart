import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:academia/Features/Home/services/home_service.dart';
import 'package:academia/Features/Home/models/schedule_item_model.dart';

class ScheduleController extends GetxController {
  final HomeService _service = HomeService();

  var classes = <ScheduleItem>[].obs;
  var isLoading = true.obs;
  final RxnString errorMessage = RxnString();

  int _studentId = 0;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    _studentId = await _service.getStudentId(userId);
    await loadSchedule(DateTime.now());
  }

  Future<void> loadSchedule(DateTime date) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      classes.value = await _service.getScheduleForDay(_studentId, _dayName(date));
    } catch (e) {
      errorMessage.value = 'Failed to load schedule. Please try again.';
      classes.clear();
    } finally {
      isLoading.value = false;
    }
  }

  String _dayName(DateTime date) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday',
      'Thursday', 'Friday', 'Saturday', 'Sunday',
    ];
    return days[date.weekday - 1];
  }
}
