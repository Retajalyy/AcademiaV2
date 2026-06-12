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
    final barColor  = isCore ? const Color(0xFF0C4D83) : const Color(0xFFFFC258);
    final badgeBg   = isCore ? const Color(0xFFDDEDFA) : const Color(0xFFFFF3DF);
    final badgeText = isCore ? const Color(0xFF0C4D83) : const Color(0xFFB18334);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Left colored bar ─────────────────────────────────────
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),

            // ── Content ──────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course name + edit button
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            course.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A2B4A),
                            ),
                          ),
                        ),
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
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F4FA),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(Icons.edit_outlined,
                                color: Colors.grey.shade500, size: 16),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Faculty · Major · Level
                    Row(
                      children: [
                        Icon(Icons.person_outline_rounded,
                            size: 15, color: Colors.grey.shade400),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            '${course.faculty}  ·  ${course.major}',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey.shade500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Type + credits + level badges
                    Row(
                      children: [
                        Icon(Icons.people_alt_outlined,
                            size: 15, color: Colors.grey.shade400),
                        const SizedBox(width: 6),
                        _Badge(
                            text: course.type,
                            bg: badgeBg,
                            textColor: badgeText),
                        const SizedBox(width: 6),
                        _Badge(
                            text: '${course.credits} cr',
                            bg: badgeBg,
                            textColor: badgeText),
                        const SizedBox(width: 6),
                        _Badge(
                            text: course.level,
                            bg: badgeBg,
                            textColor: badgeText),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Semester status
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: course.isActive
                            ? const Color(0xFFE6F4EA)
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            course.isActive
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 13,
                            color: course.isActive
                                ? const Color(0xFF137333)
                                : AppColors.smalltext,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            course.isActive
                                ? 'Active · ${course.semesterLabel}'
                                : 'Not assigned this semester',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: course.isActive
                                  ? const Color(0xFF137333)
                                  : AppColors.smalltext,
                            ),
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Badge ─────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String text;
  final Color  bg;
  final Color  textColor;
  const _Badge(
      {required this.text, required this.bg, required this.textColor});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: textColor)),
      );
}

// ── Edit Course Sheet ─────────────────────────────────────────────────────────

class EditCourseSheet extends StatelessWidget {
  final CourseAdminModel course;
  const EditCourseSheet({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<CourseAdminController>();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final maxHeight = MediaQuery.of(context).size.height * 0.88;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
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