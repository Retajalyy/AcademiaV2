import 'package:get/get.dart';
import '../model/dashboard_model.dart';
import '../service/dashboard_service.dart';

class DashboardController extends GetxController {
  final DashboardService _service = DashboardService();

  // ── State ──
  final Rx<DashboardModel?> dashboardData = Rx<DashboardModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // ── Computed helpers (used directly in widgets) ──
  String get totalStudents => dashboardData.value?.totalStudents ?? '--';
  String get faculties     => dashboardData.value?.faculties     ?? '--';
  String get majors        => dashboardData.value?.majors        ?? '--';
  String get instructors   => dashboardData.value?.instructors   ?? '--';
  String get totalCourses  => dashboardData.value?.totalCourses  ?? '--';
  String get academicWeek  => dashboardData.value?.academicWeek  ?? '--';
  String get totalWeeks    => dashboardData.value?.totalWeeks    ?? '--';
  String get semester      => dashboardData.value?.semester      ?? '--';

  List<PendingTaskModel> get pendingTasks =>
      dashboardData.value?.pendingTasks ?? [];

  @override
  void onInit() {
    super.onInit();
    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await _service.fetchDashboardData();
      dashboardData.value = data;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void refresh() => fetchDashboard();
}