import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/exam_schedule_admin_model.dart';
import '../service/exam_schedule_admin_service.dart';

class ExamScheduleAdminController extends GetxController {
  final _service = ExamScheduleAdminService();

  final RxBool isLoading     = true.obs;
  final RxBool isSubmitting  = false.obs;
  final RxString errorMsg    = ''.obs;

  final RxList<SectionOption>      sections     = <SectionOption>[].obs;
  final RxList<ExamScheduleEntry>  published    = <ExamScheduleEntry>[].obs;

  // Form state
  final Rx<SectionOption?>  selectedSection = Rx<SectionOption?>(null);
  final Rx<DateTime?>       examDate        = Rx<DateTime?>(null);
  final Rx<TimeOfDay?>      startTime       = Rx<TimeOfDay?>(null);
  final Rx<TimeOfDay?>      endTime         = Rx<TimeOfDay?>(null);
  final RxString            room            = ''.obs;
  final RxString            examType        = 'Midterm'.obs;

  final List<String> examTypes = ['Midterm', 'Final', 'Quiz'];

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    errorMsg.value  = '';
    try {
      final results = await Future.wait([
        _service.fetchSections(),
        _service.fetchPublishedExams(),
      ]);
      sections.assignAll(results[0] as List<SectionOption>);
      published.assignAll(results[1] as List<ExamScheduleEntry>);
    } catch (e) {
      errorMsg.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  String get formattedExamDate {
    if (examDate.value == null) return 'Select date';
    final d = examDate.value!;
    const m = ['','Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[d.month]} ${d.day}, ${d.year}';
  }

  String get formattedStartTime {
    final t = startTime.value;
    if (t == null) return 'Select';
    return _fmtTime(t);
  }

  String get formattedEndTime {
    final t = endTime.value;
    if (t == null) return 'Select';
    return _fmtTime(t);
  }

  String _fmtTime(TimeOfDay t) {
    final h   = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m   = t.minute.toString().padLeft(2, '0');
    final suf = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $suf';
  }

  bool get isFormValid =>
      selectedSection.value != null &&
      examDate.value != null &&
      startTime.value != null &&
      endTime.value != null &&
      room.value.trim().isNotEmpty;

  Future<void> submit() async {
    if (!isFormValid) {
      Get.snackbar('Incomplete', 'Please fill all fields',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isSubmitting.value = true;
    try {
      final section = selectedSection.value!;
      final date    = examDate.value!;
      final start   = startTime.value!;
      final end     = endTime.value!;

      final count = await _service.publishExamSchedule(
        sectionId:  section.sectionId,
        courseName: section.courseName,
        examDate:   date.toIso8601String().substring(0, 10),
        startTime:  '${start.hour.toString().padLeft(2,'0')}:${start.minute.toString().padLeft(2,'0')}',
        endTime:    '${end.hour.toString().padLeft(2,'0')}:${end.minute.toString().padLeft(2,'0')}',
        room:       room.value.trim(),
        examType:   examType.value,
      );

      _resetForm();
      await loadData();
      Get.back();
      Get.snackbar(
        'Published',
        'Exam schedule sent to $count student${count == 1 ? '' : 's'}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF22C55E),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSubmitting.value = false;
    }
  }

  void _resetForm() {
    selectedSection.value = null;
    examDate.value        = null;
    startTime.value       = null;
    endTime.value         = null;
    room.value            = '';
    examType.value        = 'Midterm';
  }
}
