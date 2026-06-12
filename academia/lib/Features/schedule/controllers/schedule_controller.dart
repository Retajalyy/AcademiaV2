import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:academia/Features/Home/services/home_service.dart';
import 'package:academia/Features/Home/models/schedule_item_model.dart';

class ScheduleController extends GetxController {
  final HomeService _service = HomeService();
  final _db = Supabase.instance.client;

  final classes        = <ScheduleItem>[].obs;
  final isLoading      = true.obs;
  final RxnString errorMessage = RxnString();

  // Group info
  final groupLabel = ''.obs;
  final groupDept  = ''.obs;
  final groupLevel = ''.obs;

  // 0 = Sun, 1 = Mon, …, 6 = Sat
  final selectedDayIndex = 0.obs;

  int _studentId = 0;

  static const _dbDayNames = [
    'Sunday', 'Monday', 'Tuesday', 'Wednesday',
    'Thursday', 'Friday', 'Saturday',
  ];

  @override
  void onInit() {
    super.onInit();
    selectedDayIndex.value = DateTime.now().weekday % 7;
    _init();
  }

  Future<void> _init() async {
    final userId = _db.auth.currentUser!.id;
    _studentId = (await _service.getStudentInfo(userId)).id;
    await Future.wait([
      _fetchGroupInfo(),
      loadScheduleForDay(selectedDayIndex.value),
    ]);
  }

  Future<void> _fetchGroupInfo() async {
    try {
      final userId = _db.auth.currentUser!.id;
      final sRow = await _db
          .from('students')
          .select('faculty, major, level')
          .eq('profile_id', userId)
          .single();

      final faculty = sRow['faculty'] as String? ?? '';
      final major   = sRow['major']   as String? ?? '';
      final level   = (sRow['level']  as int?)   ?? 0;

      groupDept.value  = faculty.isNotEmpty ? faculty : major;
      groupLevel.value = level > 0 ? level.toString() : '';

      // Try to get the real group label from registration_groups
      try {
        final enrollment = await _db
            .from('enrollments')
            .select('section_id')
            .eq('student_id', _studentId)
            .limit(1)
            .maybeSingle();

        if (enrollment != null) {
          final sectionId = enrollment['section_id'] as int;
          final rgs = await _db
              .from('registration_group_sections')
              .select('group_id')
              .eq('section_id', sectionId)
              .limit(1)
              .maybeSingle();

          if (rgs != null) {
            final groupId = rgs['group_id'] as int;
            final group   = await _db
                .from('registration_groups')
                .select('label')
                .eq('id', groupId)
                .single();
            groupLabel.value = group['label'] as String? ?? _abbreviate(major) + level.toString();
          } else {
            groupLabel.value = _abbreviate(major) + level.toString();
          }
        } else {
          groupLabel.value = _abbreviate(major) + level.toString();
        }
      } catch (_) {
        groupLabel.value = _abbreviate(major) + level.toString();
      }
    } catch (_) {
      // Leave empty on failure
    }
  }

  String _abbreviate(String text) {
    if (text.isEmpty) return '';
    return text.trim().split(RegExp(r'\s+')).map((w) => w.isEmpty ? '' : w[0].toUpperCase()).join();
  }

  Future<void> loadScheduleForDay(int dayIndex) async {
    selectedDayIndex.value = dayIndex;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      classes.value = await _service.getScheduleForDay(_studentId, _dbDayNames[dayIndex]);
    } catch (_) {
      errorMessage.value = 'Failed to load schedule. Please try again.';
      classes.clear();
    } finally {
      isLoading.value = false;
    }
  }

  bool get isToday => selectedDayIndex.value == DateTime.now().weekday % 7;

  ScheduleItem? get upcomingClass {
    if (!isToday || classes.isEmpty) return null;
    final nowMins = _nowMinutes();
    for (final item in classes) {
      if (_endMins(item) > nowMins) return item;
    }
    return null;
  }

  List<ScheduleItem> get laterClasses {
    final upcoming = upcomingClass;
    if (upcoming == null) return classes.toList();
    return classes.where((c) => c != upcoming).toList();
  }

  int minutesUntilClass(ScheduleItem item) {
    return _startMins(item) - _nowMinutes();
  }

  int _nowMinutes() {
    final now = DateTime.now();
    return now.hour * 60 + now.minute;
  }

  int _startMins(ScheduleItem item) =>
      _parseMins(item.time.split(' - ').first.trim());

  int _endMins(ScheduleItem item) =>
      _parseMins(item.time.split(' - ').last.trim());

  int _parseMins(String t) {
    final p = t.split(':');
    if (p.length < 2) return 0;
    return (int.tryParse(p[0]) ?? 0) * 60 + (int.tryParse(p[1]) ?? 0);
  }
}
