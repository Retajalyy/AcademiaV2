import 'package:get/get.dart';
import '../models/course_schedule_admin_model.dart';
import '../service/course_schedule_admin_service.dart';

const _dayOrder = [
  'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
];

class CourseScheduleAdminController extends GetxController {
  final _service = CourseScheduleAdminService();

  // ── List state ────────────────────────────────────────────────────────────
  final RxBool   isLoading = true.obs;
  final RxString errorMsg  = ''.obs;

  final RxList<CourseScheduleGroupModel> groups = <CourseScheduleGroupModel>[].obs;
  final RxString searchQuery     = ''.obs;
  final RxString selectedFaculty = ''.obs;

  List<CourseScheduleGroupModel> get filtered {
    var list = groups.toList();
    final fac = selectedFaculty.value;
    final q   = searchQuery.value.toLowerCase().trim();
    if (fac.isNotEmpty) list = list.where((g) => g.facultyCode == fac).toList();
    if (q.isNotEmpty) {
      list = list.where((g) =>
        g.label.toLowerCase().contains(q)      ||
        g.majorName.toLowerCase().contains(q)  ||
        g.facultyName.toLowerCase().contains(q),
      ).toList();
    }
    return list;
  }

  Map<String, List<CourseScheduleGroupModel>> get groupedByFaculty {
    final map = <String, List<CourseScheduleGroupModel>>{};
    for (final g in filtered) {
      map.putIfAbsent(g.facultyName, () => []).add(g);
    }
    return map;
  }

  // ── Detail state ──────────────────────────────────────────────────────────
  final RxBool   detailLoading = false.obs;
  final RxString selectedDay   = ''.obs;
  final Rx<Map<String, List<CourseSessionModel>>?> groupSchedule = Rx(null);

  // Always show all 7 days once the schedule is loaded; empty days show a message.
  List<String> get scheduledDays =>
      groupSchedule.value == null ? [] : _dayOrder;

  List<CourseSessionModel> get sessionsForSelectedDay =>
      groupSchedule.value?[selectedDay.value] ?? [];

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  // ── Public methods ────────────────────────────────────────────────────────
  Future<void> loadData() async {
    isLoading.value = true;
    errorMsg.value  = '';
    try {
      groups.assignAll(await _service.fetchGroups());
    } catch (e) {
      errorMsg.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadGroupSchedule(int groupId) async {
    detailLoading.value = true;
    groupSchedule.value = null;
    selectedDay.value   = '';
    try {
      final schedule = await _service.fetchGroupSchedule(groupId);
      groupSchedule.value = schedule;
      // Default to the first day that has sessions; fall back to Sunday.
      final firstWithSessions = _dayOrder.firstWhereOrNull(
          (d) => schedule.containsKey(d) && schedule[d]!.isNotEmpty);
      selectedDay.value = firstWithSessions ?? _dayOrder.first;
    } catch (_) {
      groupSchedule.value = {};
    } finally {
      detailLoading.value = false;
    }
  }
}
