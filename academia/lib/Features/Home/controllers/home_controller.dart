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

      final results = await Future.wait([
        _service.getStudentName(userId),
        _service.getStudentId(userId),
      ]);

      final name      = results[0] as String;
      final studentId = results[1] as int;
      userName.value  = name;

      // Schedule & next class — critical path, run together
      final scheduleData = await Future.wait([
        _service.getTodaySchedule(studentId),
        _service.getNextClass(studentId),
      ]);
      dailySchedule.value = scheduleData[0] as List<ScheduleItem>;
      nextClass.value     = scheduleData[1] as ScheduleItem?;

      // Assignments — optional; failure must not wipe the schedule
      try {
        assignments.value = await _service.getUpcomingAssignments(studentId);
      } catch (_) {
        assignments.value = [];
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load home data: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> refresh() => loadHomeData();
}