import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/exam_schedule_admin_model.dart';
import '../service/exam_schedule_admin_service.dart';

class ExamScheduleAdminController extends GetxController {
  final _service = ExamScheduleAdminService();

  final RxBool   isLoading    = true.obs;
  final RxBool   isSubmitting = false.obs;
  final RxString errorMsg     = ''.obs;

  final RxList<ExamScheduleUpload>  uploads   = <ExamScheduleUpload>[].obs;
  final RxList<Map<String, String>> faculties = <Map<String, String>>[].obs;
  final RxList<Map<String, String>> allMajors = <Map<String, String>>[].obs;

  List<Map<String, String>> get filteredMajors =>
      allMajors.where((m) => m['faculty_code'] == formFacultyCode.value).toList();

  final RxInt    selectedTab     = 0.obs;
  final RxString searchQuery     = ''.obs;
  final RxString selectedFaculty = ''.obs;

  List<ExamScheduleUpload> get filteredUploads {
    final type = selectedTab.value == 0 ? 'Midterm' : 'Final';
    final q    = searchQuery.value.toLowerCase();
    final fac  = selectedFaculty.value;
    return uploads.where((u) {
      return u.examType == type &&
          (q.isEmpty   || u.facultyName.toLowerCase().contains(q)) &&
          (fac.isEmpty || u.facultyCode == fac);
    }).toList();
  }

  // Form state
  final RxInt             formStep         = 1.obs;
  final RxString          formFacultyCode  = ''.obs;
  final RxString          formFacultyName  = ''.obs;
  final RxString          formLevel        = ''.obs;
  final RxString          formMajorCode    = ''.obs;
  final RxString          formMajorName    = ''.obs;
  final RxString          formExamType     = 'Midterm'.obs;
  final RxString          formSemester     = ''.obs;
  final RxString          formAcademicYear = ''.obs;
  final Rx<DateTime?>     formPeriodFrom   = Rx(null);
  final Rx<DateTime?>     formPeriodTo     = Rx(null);
  final Rx<DateTime?>     formExamDate     = Rx(null);

  final Rx<TimeOfDay?> y1Start = Rx(null);
  final Rx<TimeOfDay?> y1End   = Rx(null);
  final Rx<TimeOfDay?> y2Start = Rx(null);
  final Rx<TimeOfDay?> y2End   = Rx(null);
  final Rx<TimeOfDay?> y3Start = Rx(null);
  final Rx<TimeOfDay?> y3End   = Rx(null);
  final Rx<TimeOfDay?> y4Start = Rx(null);
  final Rx<TimeOfDay?> y4End   = Rx(null);

  PlatformFile?  pickedFile;
  final RxString pickedFileName = ''.obs;

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
        _service.fetchFaculties(),
        _service.fetchUploads(),
        _service.fetchMajors(),
      ]);
      faculties.assignAll(results[0] as List<Map<String, String>>);
      uploads.assignAll(results[1] as List<ExamScheduleUpload>);
      allMajors.assignAll(results[2] as List<Map<String, String>>);
    } catch (e) {
      errorMsg.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  String get formattedExamDate {
    if (formExamDate.value == null) return 'Select date';
    final d = formExamDate.value!;
    const m = ['','Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[d.month]} ${d.day}, ${d.year}';
  }

  String fmtTime(TimeOfDay? t) {
    if (t == null) return 'Select';
    final h   = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final min = t.minute.toString().padLeft(2, '0');
    final suf = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$min $suf';
  }



  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx', 'pdf'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      pickedFile = result.files.first;
      pickedFileName.value = pickedFile!.name;
    }
  }

  bool get isStep1Valid => formFacultyCode.value.isNotEmpty;
  bool get isStep2Valid => formExamType.value.isNotEmpty;
  bool get isStep3Valid => pickedFileName.value.isNotEmpty;
  bool get isFormValid  => isStep1Valid;

  Future<void> deleteUpload(ExamScheduleUpload upload) async {
    uploads.remove(upload);
    try {
      await _service.deleteUpload(upload);
    } catch (e) {
      uploads.add(upload);
      Get.snackbar('Error', 'Could not delete schedule: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> submit() async {
    if (!isFormValid) {
      Get.snackbar('Incomplete', 'Please select a faculty',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isSubmitting.value = true;
    try {
      await _service.publishUpload(
        facultyCode:  formFacultyCode.value,
        facultyName:  formFacultyName.value,
        examType:     formExamType.value,
        level:        formLevel.value.isEmpty       ? null : formLevel.value,
        majorCode:    formMajorCode.value.isEmpty   ? null : formMajorCode.value,
        majorName:    formMajorName.value.isEmpty   ? null : formMajorName.value,
        semester:     formSemester.value.isEmpty    ? null : formSemester.value,
        academicYear: formAcademicYear.value.isEmpty? null : formAcademicYear.value,
        periodFrom:   formPeriodFrom.value?.toIso8601String().substring(0, 10),
        periodTo:     formPeriodTo.value?.toIso8601String().substring(0, 10),
        file:         pickedFile,
      );
      resetForm();
      await loadData();
      Get.back();
      Get.snackbar(
        'Published',
        'Exam schedule uploaded successfully',
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

  String _fmtDate(DateTime? d) {
    if (d == null) return '';
    const m = ['','Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[d.month]} ${d.day}, ${d.year}';
  }

  String get formattedPeriodFrom => _fmtDate(formPeriodFrom.value);
  String get formattedPeriodTo   => _fmtDate(formPeriodTo.value);

  String get formExamTypeLabel {
    switch (formExamType.value) {
      case 'Midterm': return 'Midterm Exam';
      case 'Final':   return 'Final Exams';
      default:        return formExamType.value;
    }
  }

  String get formattedSemester {
    final sem  = formSemester.value;
    final year = formAcademicYear.value.split('/').lastOrNull ?? '';
    if (sem.isEmpty) return '';
    return year.isNotEmpty ? '$sem $year' : sem;
  }

  String get formattedAcademicYear =>
      formAcademicYear.value.replaceAll('/', ' - ');

  String get formattedExamPeriod {
    final from = formattedPeriodFrom;
    final to   = formattedPeriodTo;
    if (from.isEmpty && to.isEmpty) return '—';
    if (from.isEmpty) return to;
    if (to.isEmpty)   return from;
    return '$from – $to';
  }

  String get formattedFileSize {
    final bytes = pickedFile?.size ?? 0;
    if (bytes == 0) return '';
    final mb  = bytes / 1048576;
    final ext = (pickedFile?.extension ?? '').toUpperCase();
    return '${mb.toStringAsFixed(1)} MB${ext.isNotEmpty ? ' · $ext' : ''}';
  }

  void removeFile() {
    pickedFile           = null;
    pickedFileName.value = '';
  }

  void resetForm() {
    formStep.value         = 1;
    formFacultyCode.value  = '';
    formFacultyName.value  = '';
    formLevel.value        = '';
    formMajorCode.value    = '';
    formMajorName.value    = '';
    formExamType.value     = 'Midterm';
    formSemester.value     = '';
    formAcademicYear.value = '';
    formPeriodFrom.value   = null;
    formPeriodTo.value     = null;
    formExamDate.value     = null;
    y1Start.value = y1End.value = null;
    y2Start.value = y2End.value = null;
    y3Start.value = y3End.value = null;
    y4Start.value = y4End.value = null;
    pickedFile           = null;
    pickedFileName.value = '';
  }
}
