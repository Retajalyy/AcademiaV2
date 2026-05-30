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

class ExamResultsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExamResultsController>(() => ExamResultsController());
  }
}