// lib/Features/course_admin/widgets/course_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../controller/course_admin_controller.dart';
import '../model/course_admin_model.dart';
import 'add_course_admin.dart';

class CourseCard extends StatelessWidget {
  final CourseAdminModel course;
  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<CourseAdminController>();
    final isCore = course.type == 'Core';

    final Color leftBorderColor =
        isCore ? AppColors.accentProgramming1 : AppColors.assignmentColor;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: leftBorderColor, width: 5),
        ),
      
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── TOP ROW ───────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isCore
                        ? AppColors.bluegroundicon
                        : const Color(0xFFFFF3DF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isCore
                        ? Icons.grid_view_rounded
                        : Icons.trending_up_rounded,
                    size: 22,
                    color: isCore
                        ? AppColors.accentProgramming1
                        : AppColors.assignmentColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    course.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentProgramming1,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _Badge(text: course.type, isCore: isCore),
                    const SizedBox(height: 4),
                    _Badge(text: "${course.credits} credits", isCore: isCore),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── DETAILS ───────────────────────────────────────────────
            Row(children: [
              Expanded(
                  child: _DetailBox(label: "Faculty", value: course.faculty)),
              const SizedBox(width: 8),
              Expanded(
                  child: _DetailBox(label: "Level", value: course.level)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                  child: _DetailBox(label: "Major", value: course.major)),
              const SizedBox(width: 8),
              Expanded(
                  child: _DetailBox(
                      label: "Prerequisite", value: course.prerequisite)),
            ]),

            const SizedBox(height: 14),

            // ── BUTTONS ───────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Edit button
                GestureDetector(
                  onTap: () {
                    c.loadEditForm(course);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => EditCourseSheet(course: course),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 36, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "Edit course",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),

                // Delete button
                GestureDetector(
                  onTap: () {
                    c.deletingCourse.value = course;
                    showDialog(
                      context: context,
                      barrierColor: Colors.black.withOpacity(0.5),
                      builder: (_) => const DeleteCourseDialog(),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 36, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Color(0x14000000),
                        width: 1.2,
                      ),
                    ),
                    child: Row(children: [
                      Icon(Icons.delete_outline,
                          color: AppColors.fail, size: 22),
                      const SizedBox(width: 4),
                      Text(
                        "Delete",
                        style: TextStyle(
                          color: AppColors.fail,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Detail Box ────────────────────────────────────────────────────────────────

class _DetailBox extends StatelessWidget {
  final String label, value;
  const _DetailBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF4FC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 11, color: AppColors.smalltext)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentProgramming1)),
        ],
      ),
    );
  }
}

// ── Badge ─────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String text;
  final bool isCore;
  const _Badge({required this.text, required this.isCore});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isCore ? AppColors.bluegroundicon : const Color(0xFFFFF3DF),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isCore
                ? AppColors.accentProgramming1
                : AppColors.assignmentColor,
          )),
    );
  }
}

// ── Edit Course Sheet ─────────────────────────────────────────────────────────

class EditCourseSheet extends StatelessWidget {
  final CourseAdminModel course;
  const EditCourseSheet({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<CourseAdminController>();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(16, 12, 16, 24 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const CourseDragHandle(),
            const SizedBox(height: 16),

            const Text(
              "Edit Course",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),

            const SizedBox(height: 12),

            // Warning banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.LightYellow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.info_outline,
                      color: AppColors.assignmentColor, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Changes will apply to this course across all semester plans it has been added to.",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.assignmentColor,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              "Course name",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.smalltext,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                course.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentProgramming1,
                ),
              ),
            ),

            const SizedBox(height: 16),

            const CourseFormFields(),

            const SizedBox(height: 24),

            Obx(() => CoursePrimaryButton(
                  label: "Save Changes",
                  loading: c.isSubmitting.value,
                  textSize: 17,
                  onTap: c.saveEdit,
                )),

            const SizedBox(height: 10),

            const CourseCancelButton(),
          ],
        ),
      ),
    );
  }
}

// ── Delete Dialog ─────────────────────────────────────────────────────────────

class DeleteCourseDialog extends StatelessWidget {
  const DeleteCourseDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<CourseAdminController>();

    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Trash icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFF8EBEC),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.delete_outline,
                  color: AppColors.fail, size: 32),
            ),

            const SizedBox(height: 16),

            const Text(
              "Delete this course?",
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),

            const SizedBox(height: 12),

            // Warning box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8EBEC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline,
                      color: AppColors.fail, size: 16),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "This action is permanent and cannot be undone. The course will be removed from all semester plans it was included in",
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.fail,
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ← FIXED: color: → backgroundColor:
            Obx(() => CoursePrimaryButton(
                  label: "Delete",
                  loading: c.isSubmitting.value,
                  onTap: c.confirmDelete,
                  backgroundColor: AppColors.primaryBlue,
                )),

            const SizedBox(height: 10),

            const CourseCancelButton(),
          ],
        ),
      ),
    );
  }
}