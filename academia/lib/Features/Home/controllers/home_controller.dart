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

      // Run name + studentId fetch in parallel
      final results = await Future.wait([
        _service.getStudentName(userId),
        _service.getStudentId(userId),
      ]);

      final name = results[0] as String;
      final studentId = results[1] as int;

      userName.value = name;

      // Run schedule + assignments in parallel
      final data = await Future.wait([
        _service.getTodaySchedule(studentId),
        _service.getUpcomingAssignments(studentId),
        _service.getNextClass(studentId),
      ]);

      dailySchedule.value = data[0] as List<ScheduleItem>;
      assignments.value   = data[1] as List<Assignment>;
      nextClass.value     = data[2] as ScheduleItem?;

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load home data: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Pull-to-refresh
  Future<void> refresh() => loadHomeData();
}