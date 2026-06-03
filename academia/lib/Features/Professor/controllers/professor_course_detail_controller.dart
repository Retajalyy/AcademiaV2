import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import '../models/professor_course_model.dart';
import '../models/professor_course_detail_model.dart';
import '../services/professor_service.dart';

class ProfessorCourseDetailController extends GetxController {
  final _service = ProfessorService();

  late final ProfessorCourseModel course;
  late final int  professorId;
  late final bool isTA;

  final isLoading   = true.obs;
  final isUploading = false.obs;
  final detail      = Rxn<ProfessorCourseDetailModel>();

  @override
  void onInit() {
    super.onInit();
    final args  = Get.arguments as Map<String, dynamic>;
    course      = args['course']      as ProfessorCourseModel;
    professorId = args['professorId'] as int;
    isTA        = args['isTA']        as bool? ?? false;
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    try {
      detail.value = await _service.getCourseDetail(
          professorId, course.courseId,
          isTA: isTA);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load course details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> uploadFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'pptx'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.bytes == null) return;

    final ext = (file.extension ?? 'pdf').toLowerCase();

    isUploading.value = true;
    try {
      await _service.uploadCourseMaterial(
        courseId: course.courseId,
        fileName: file.name,
        fileExtension: ext,
        bytes: file.bytes!,
      );
      await _load();
      Get.snackbar('Uploaded', '${file.name} uploaded successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Upload failed', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isUploading.value = false;
    }
  }

  @override
  Future<void> refresh() => _load();
}
