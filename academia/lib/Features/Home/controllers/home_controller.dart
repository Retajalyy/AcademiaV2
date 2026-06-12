import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/schedule_item_model.dart';
import '../models/assignment_model.dart';
import '../services/home_service.dart';

class HomeController extends GetxController {
  final HomeService _service = HomeService();

  // — Observables your HomePage already binds to —
  var userName = ''.obs;
  var dailySchedule = <ScheduleItem>[].obs;
  var assignments = <Assignment>[].obs;
  var nextClass = Rxn<ScheduleItem>();
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

      final info = await _service.getStudentInfo(userId);
      userName.value = info.name;

      // Schedule + assignments in parallel
      final results = await Future.wait([
        _service.getTodaySchedule(info.id),
        _service.getUpcomingAssignments(info.id).catchError((_) => <Assignment>[]),
      ]);

      final schedule = results[0] as List<ScheduleItem>;
      dailySchedule.value = schedule;
      nextClass.value     = _service.getNextClass(schedule);
      assignments.value   = results[1] as List<Assignment>;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load home data: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> refresh() => loadHomeData();
}