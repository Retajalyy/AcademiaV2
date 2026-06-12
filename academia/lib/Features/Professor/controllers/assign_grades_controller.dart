import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import '../models/professor_course_model.dart';
import '../services/professor_service.dart';

class GradeFileState {
  final String    fileName;
  final Uint8List bytes;
  final int       studentCount;
  final int       fileSizeKb;

  const GradeFileState({
    required this.fileName,
    required this.bytes,
    required this.studentCount,
    required this.fileSizeKb,
  });

  String get sizeLabel => fileSizeKb >= 1024
      ? '${(fileSizeKb / 1024).toStringAsFixed(1)} MB'
      : '$fileSizeKb KB';
}

class AssignGradesController extends GetxController {
  final _service = ProfessorService();

  late final ProfessorCourseModel course;
  late final int  professorId;
  late final bool isTA;

  final files        = <String, GradeFileState>{}.obs;
  final isSubmitting = false.obs;
  final error        = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args  = Get.arguments as Map<String, dynamic>;
    course      = args['course']      as ProfessorCourseModel;
    professorId = args['professorId'] as int;
    isTA        = args['isTA']        as bool? ?? false;
  }

  Future<void> pickFile(String gradeType) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;

    final content = String.fromCharCodes(file.bytes!);
    final studentCount = _parseCsv(content).length;

    files[gradeType] = GradeFileState(
      fileName:     file.name,
      bytes:        file.bytes!,
      studentCount: studentCount,
      fileSizeKb:   (file.bytes!.length / 1024).ceil(),
    );
  }

  void clearFile(String gradeType) => files.remove(gradeType);

  Future<void> submit() async {
    if (files.isEmpty) {
      error.value = 'Please upload at least one grade file.';
      return;
    }
    isSubmitting.value = true;
    error.value = '';
    try {
      for (final entry in files.entries) {
        final content = String.fromCharCodes(entry.value.bytes);
        final scores  = _parseCsv(content);
        await _service.uploadGradesFromCsv(
          professorId: professorId,
          courseId:    course.courseId,
          gradeType:   entry.key,
          scores:      scores,
          isTA:        isTA,
        );
      }
      Get.back(result: true);
      Get.snackbar('Success', 'Grades uploaded successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      error.value = 'Upload failed: $e';
    } finally {
      isSubmitting.value = false;
    }
  }

  Map<String, double> _parseCsv(String content) {
    final scores = <String, double>{};
    for (final line in content.trim().split('\n')) {
      final parts = line.split(',');
      if (parts.length < 2) continue;
      final id    = parts[0].trim();
      final score = double.tryParse(parts[1].trim());
      if (id.isEmpty || score == null) continue;
      scores[id] = score;
    }
    return scores;
  }
}
