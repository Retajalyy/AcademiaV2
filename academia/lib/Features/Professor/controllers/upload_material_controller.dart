import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/professor_course_model.dart';
import '../services/professor_service.dart';

class UploadMaterialController extends GetxController {
  final _service = ProfessorService();

  late final ProfessorCourseModel course;

  final titleController = TextEditingController();
  final selectedType    = ''.obs;
  final dueDate         = Rxn<DateTime>();
  final fileName        = ''.obs;
  final isUploading     = false.obs;

  Uint8List? _fileBytes;
  String     _fileExt = 'pdf';

  static const types = ['Lecture', 'Assignment', 'Quiz', 'Lab'];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    course = args['course'] as ProfessorCourseModel;
  }

  @override
  void onClose() {
    titleController.dispose();
    super.onClose();
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'pptx', 'docx'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;

    _fileBytes = file.bytes;
    _fileExt   = (file.extension ?? 'pdf').toLowerCase();
    fileName.value = file.name;
  }

  Future<void> upload() async {
    if (_fileBytes == null) {
      Get.snackbar('No file', 'Please select a file first',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (titleController.text.trim().isEmpty) {
      Get.snackbar('Missing title', 'Please enter a title',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (selectedType.value.isEmpty) {
      Get.snackbar('Missing type', 'Please select a type',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isUploading.value = true;
    try {
      await _service.uploadCourseMaterial(
        courseId:     course.courseId,
        fileName:     titleController.text.trim(),
        fileExtension: _fileExt,
        bytes:        _fileBytes!,
        materialType: selectedType.value,
        dueDate:      dueDate.value,
      );
      Get.back(result: true);
      Get.snackbar('Uploaded', 'File uploaded successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Upload failed', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isUploading.value = false;
    }
  }

  String get dueDateLabel {
    if (dueDate.value == null) return '';
    final d = dueDate.value!;
    const m = ['','Jan','Feb','Mar','Apr','May','Jun',
                   'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[d.month]} ${d.day}, ${d.year}';
  }

  bool get showDueDate =>
      selectedType.value == 'Assignment' || selectedType.value == 'Quiz';
}
