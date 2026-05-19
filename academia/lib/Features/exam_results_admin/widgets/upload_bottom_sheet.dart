import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utilities/colors.dart';
import '../../../core/widgets/architecture_progress.dart';
import '../controller/exam_results_controller.dart';
import 'app_dropdown_field.dart';
import 'upload_file_picker.dart';
import 'upload_summary_card.dart';

class UploadBottomSheet extends StatelessWidget {
  const UploadBottomSheet({super.key});

  static void show() {
    Get.find<ExamResultsController>().resetUploadForm();
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (_) => const UploadBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Resolve controller once at root — passed down as param, never inside Obx
    final c = Get.find<ExamResultsController>();
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.72,
        minChildSize: 0.50,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const _Handle(),
              _SheetHeader(c: c),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  child: _StepBody(c: c),
                ),
              ),
              _BottomButtons(c: c),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Handle ───────────────────────────────────────────────────────────────────

class _Handle extends StatelessWidget {
  const _Handle();
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 4),
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _SheetHeader extends StatelessWidget {
  final ExamResultsController c;
  const _SheetHeader({required this.c});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload exam results',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 3),
          Text(
            'Select the target group and upload the results file.\n'
            'Students will be notified once published.',
            style:
                TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 16),
          // c is a param — safe to use inside Obx (no Get.find here)
          Obx(() => ArchitectureProgress(currentStep: c.uploadStep.value)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── Step body switcher ───────────────────────────────────────────────────────

class _StepBody extends StatelessWidget {
  final ExamResultsController c;
  const _StepBody({required this.c});

  @override
  Widget build(BuildContext context) {
    // c is a constructor param — no Get.find inside Obx
    return Obx(() => switch (c.uploadStep.value) {
          1 => _Step1(c: c),
          2 => _Step2(c: c),
          3 => _Step3(c: c),
          _ => const SizedBox.shrink(),
        });
  }
}

// ─── Step 1 ───────────────────────────────────────────────────────────────────

class _Step1 extends StatelessWidget {
  final ExamResultsController c;
  const _Step1({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final form = c.uploadForm.value;
      return Column(
        children: [
          AppDropdownField(
            label: 'Faculty',
            hint: 'Select faculty...',
            items: c.faculties,
            value: form.faculty,
            onChanged: c.setFaculty,
          ),
          const SizedBox(height: 14),
          AppDropdownField(
            label: 'Level',
            hint: 'Select year...',
            items: c.levels,
            value: form.level,
            onChanged: c.setLevel,
          ),
          const SizedBox(height: 14),
          AppDropdownField(
            label: 'Major',
            hint: c.majors.isEmpty
                ? 'Select a faculty & level first'
                : 'Select major...',
            items: c.majors,
            value: form.major,
            enabled: c.majors.isNotEmpty,
            onChanged: c.setMajor,
          ),
        ],
      );
    });
  }
}

// ─── Step 2 ───────────────────────────────────────────────────────────────────

class _Step2 extends StatelessWidget {
  final ExamResultsController c;
  const _Step2({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final form = c.uploadForm.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Results Title',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            onChanged: c.setResultsTitle,
            decoration: InputDecoration(
              hintText: 'e.g. FCI · Year 4 · Software Engineering',
              hintStyle: TextStyle(
                  color: Colors.grey.shade400, fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                    color: AppColors.primaryBlue, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 14),
          AppDropdownField(
            label: 'Semester',
            hint: 'Select semester...',
            items: c.semesters,
            value: form.semester,
            onChanged: c.setSemester,
          ),
          const SizedBox(height: 14),
          AppDropdownField(
            label: 'Academic Year',
            hint: 'Select year...',
            items: c.academicYears,
            value: form.academicYear,
            onChanged: c.setAcademicYear,
          ),
        ],
      );
    });
  }
}

// ─── Step 3 ───────────────────────────────────────────────────────────────────

class _Step3 extends StatelessWidget {
  final ExamResultsController c;
  const _Step3({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final form = c.uploadForm.value;
      return Column(
        children: [
          UploadFilePicker(
            form: form,
            onPickFile: () => _pickFile(c),
            onRemoveFile: c.removeFile,
          ),
          if (form.file != null) UploadSummaryCard(form: form),
          if (c.uploadStatus.value == UploadStatus.error)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                c.uploadError.value,
                style:
                    const TextStyle(color: Colors.red, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      );
    });
  }

  void _pickFile(ExamResultsController c) {
    // TODO: real FilePicker integration:
    // final result = await FilePicker.platform.pickFiles(
    //   type: FileType.custom,
    //   allowedExtensions: ['xlsx', 'xls', 'csv'],
    // );
    // if (result != null) {
    //   c.setPickedFile(
    //     file: File(result.files.single.path!),
    //     fileName: result.files.single.name,
    //     rows: 246,
    //     sizeMb: result.files.single.size / 1024 / 1024,
    //   );
    // }
    c.setPickedFile(
      file: Object(),
      fileName: 'final_results_sem8.xlsx',
      rows: 246,
      sizeMb: 2.4,
    );
  }
}

// ─── Bottom buttons ───────────────────────────────────────────────────────────

class _BottomButtons extends StatelessWidget {
  final ExamResultsController c;
  const _BottomButtons({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final step      = c.uploadStep.value;
      final isLoading = c.uploadStatus.value == UploadStatus.loading;
      final isLast    = step == 3;
      final form      = c.uploadForm.value;

      final canProceed = switch (step) {
        1 => form.isStep1Valid,
        2 => form.isStep2Valid,
        3 => form.isStep3Valid,
        _ => false,
      };

      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (canProceed && !isLoading)
                    ? (isLast ? c.publish : c.goNextStep)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(
                        isLast ? 'Publish' : 'Next',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: step > 1
                  ? c.goPrevStep
                  : Get.back,
              child: Text(
                step > 1 ? 'Back' : 'Cancel',
                style: const TextStyle(
                    color: AppColors.primaryBlue, fontSize: 15),
              ),
            ),
          ],
        ),
      );
    });
  }
}