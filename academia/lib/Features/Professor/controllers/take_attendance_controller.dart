import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/attendance_models.dart';
import '../services/professor_service.dart';

class TakeAttendanceController extends GetxController {
  final _service = ProfessorService();

  late final int    courseId;
  late final String courseName;
  late final int    professorId;
  late final bool   isTA;

  final groups         = <AttendanceGroupInfo>[].obs;
  final selectedGroup  = Rxn<AttendanceGroupInfo>();
  final isLoading      = true.obs;
  final isProcessing   = false.obs;
  final isSaving       = false.obs;
  final sessionNum     = 1.obs;
  final capturedImage  = Rxn<File>();
  final showResults    = false.obs;
  final selectedDate   = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    courseId    = args['courseId']    as int;
    courseName  = args['courseName']  as String;
    professorId = args['professorId'] as int;
    isTA        = args['isTA']        as bool? ?? false;
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    try {
      groups.value = await _service.loadAttendanceGroups(
          professorId, courseId, isTA: isTA);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load groups: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void selectGroup(AttendanceGroupInfo group) async {
    selectedGroup.value  = group;
    showResults.value    = false;
    capturedImage.value  = null;
    selectedDate.value   = group.mostRecentScheduleDate;
    for (final s in group.students) { s.isPresent = false; }
    sessionNum.value = await _service.getNextSessionNumber(
        group.sectionId, group.groupId);
  }

  Future<void> captureSheet() async {
    if (selectedGroup.value == null) {
      Get.snackbar('Select a group', 'Please select a group first',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    XFile? picked;
    try {
      picked = await ImagePicker().pickImage(
          source: ImageSource.camera, imageQuality: 90);
    } catch (e) {
      Get.snackbar('Camera Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 6));
      return;
    }
    if (picked == null) return;

    capturedImage.value = File(picked.path);
    isProcessing.value  = true;

    try {
      await _processOcr(capturedImage.value!);
    } catch (e) {
      Get.snackbar('OCR Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 6));
    } finally {
      isProcessing.value = false;
      showResults.value  = true;
    }
  }

  Future<void> _processOcr(File imageFile) async {
    final inputImage     = InputImage.fromFile(imageFile);
    final recognizer     = TextRecognizer(script: TextRecognitionScript.latin);
    final recognizedText = await recognizer.processImage(inputImage);
    await recognizer.close();

    final students = selectedGroup.value!.students;
    for (final s in students) { s.isPresent = false; }

    // Debug: show what OCR actually read
    final rawText = recognizedText.text.trim();
    Get.snackbar(
      'OCR Debug (${students.length} students)',
      rawText.isEmpty ? '[No text detected]' : rawText.substring(0, rawText.length.clamp(0, 300)),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 10),
      backgroundColor: const Color(0xFF1A2B4A),
      colorText: Colors.white,
    );

    if (rawText.isEmpty) return;

    // Clean and filter empty lines
    final lines = rawText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    // ── Primary: order-based matching ────────────────────────────────
    // OCR outputs each status as a standalone "P" or "A" line in order.
    final statusValues = <bool>[];
    for (final line in lines) {
      final t = line.trim().toLowerCase();
      if (t == 'p') {
        statusValues.add(true);
      } else if (t == 'a') {
        statusValues.add(false);
      }
    }

    if (statusValues.length == students.length) {
      // Perfect match — assign by order
      for (int i = 0; i < students.length; i++) {
        students[i].isPresent = statusValues[i];
      }
    } else {
      // ── Fallback: proximity matching by name/ID ───────────────────
      for (final student in students) {
        final parts = student.name.toLowerCase().split(' ');
        final first = parts.isNotEmpty ? parts.first : '';
        final last  = parts.length > 1 ? parts.last  : '';

        for (int i = 0; i < lines.length; i++) {
          final low = lines[i].toLowerCase();
          final idMatch   = student.uniId.isNotEmpty &&
              low.contains(student.uniId.toLowerCase());
          final nameMatch = (first.length >= 3 && low.contains(first)) ||
                            (last.length  >= 3 && low.contains(last));
          if (!idMatch && !nameMatch) continue;

          final window = lines
              .sublist(i, (i + 5).clamp(0, lines.length))
              .join(' ')
              .toLowerCase();
          if (RegExp(r'\bp\b|present').hasMatch(window)) {
            student.isPresent = true;
          }
          break;
        }
      }
    }

    selectedGroup.refresh();
  }

  void toggleStudent(AttendanceStudentInfo student) {
    student.isPresent = !student.isPresent;
    selectedGroup.refresh();
  }

  Future<void> saveAttendance() async {
    final group = selectedGroup.value;
    if (group == null) return;

    isSaving.value = true;
    try {
      await _service.saveAttendance(
        sectionId:   group.sectionId,
        groupId:     group.groupId,
        professorId: professorId,
        sessionNum:  sessionNum.value,
        students:    group.students,
        date:        selectedDate.value,
      );
      Get.back();
      Get.snackbar('Saved', 'Attendance saved for Session ${sessionNum.value}',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSaving.value = false;
    }
  }

  String get dateLabel {
    final d = selectedDate.value;
    const m = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${m[d.month]} ${d.day}, ${d.year}';
  }

  int get presentCount =>
      selectedGroup.value?.students.where((s) => s.isPresent).length ?? 0;
  int get absentCount  =>
      selectedGroup.value?.students.where((s) => !s.isPresent).length ?? 0;
}
