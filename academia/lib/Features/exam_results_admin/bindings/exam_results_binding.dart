// ─────────────────────────────────────────────────────────────────────────────
// Binding: ExamResultsBinding
// Registers all dependencies for the exam_results_admin feature lazily.
// Attach to your GetPage so everything is injected before the screen mounts.
//
// Usage:
//   GetPage(
//     name: '/exam-results',
//     page: () => const ExamResultsScreen(),
//     binding: ExamResultsBinding(),
//   )
// ─────────────────────────────────────────────────────────────────────────────

import 'package:get/get.dart';
import '../controller/exam_results_controller.dart';
import '../service/exam_results_service.dart';

class ExamResultsBinding extends Bindings {
  @override
  void dependencies() {
    // Service is registered first so the controller can find it
    Get.lazyPut<ExamResultsService>(() => ExamResultsServiceImpl());

    Get.lazyPut<ExamResultsController>(
      () => ExamResultsController(service: Get.find<ExamResultsService>()),
    );
  }
}