// lib/Features/course_admin/widgets/add_course_admin.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../controller/course_admin_controller.dart';
import '../model/course_admin_model.dart';
class AddCourseSheet extends StatelessWidget {
  const AddCourseSheet({super.key});
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
              "Add new course",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "This course will be saved and can be added to any semester plan.",
              style: TextStyle(fontSize: 13, color: AppColors.smalltext),
            ),
            const SizedBox(height: 20),
            const CourseFormFields(),
            const SizedBox(height: 24),
            Obx(() => CoursePrimaryButton(
                  label: "Add Course",
                  loading: c.isSubmitting.value,
                  onTap: () async {
                    await c.previewAdd();
                    if (c.pendingCourse.value != null && context.mounted) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) =>
                            ConfirmCourseDialog(course: c.pendingCourse.value!),
                      );
                    }
                  },
                )),
            const SizedBox(height: 10),
            const CourseCancelButton(),
          ],
        ),
      ),
    );
  }
}
class ConfirmCourseDialog extends StatelessWidget {
  final CourseAdminModel course;
  const ConfirmCourseDialog({super.key, required this.course});
  @override
  Widget build(BuildContext context) {
    final c = Get.find<CourseAdminController>();
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.bluegroundicon,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.menu_book_outlined,
                color: AppColors.accentProgramming1,
                size: 30,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              "Confirm new course",
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Please review the course details below\nbefore saving it",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.smalltext,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F4FC),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  _ConfirmRow("Course name", course.name),
                  _ConfirmRow("Faculty", course.faculty),
                  _ConfirmRow("Level , Major", "${course.level} , ${course.major}"),
                  _ConfirmRow("Credits", "${course.credits} credits"),
                  _ConfirmRow("Type", course.type),
                  _ConfirmRow(
                    "Prerequisite",
                    course.prerequisite.isEmpty ? "None" : course.prerequisite,
                  ),
                  const SizedBox(height: 12),
                  Obx(() => CoursePrimaryButton(
                    label: "Save Course",
                    textSize: 17,
                    loading: c.isSubmitting.value,
                    onTap: c.confirmAdd,
                  )),
                  const SizedBox(height: 8),
                  CourseOutlinedButton(
                    label: "Edit",
                    backgroundColor: Colors.white,
                    textSize: 17,
                    onTap: () {
                      Get.back();
                      c.pendingCourse.value = null;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _ConfirmRow extends StatelessWidget {
  final String label;
  final String value;
  const _ConfirmRow(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.smalltext),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.accentProgramming1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class CourseFormFields extends StatelessWidget {
  const CourseFormFields({super.key});
  @override
  Widget build(BuildContext context) {
    final c = Get.find<CourseAdminController>();
    return Obx(() {
      final f = c.form.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FLabel("Course name"),
          const SizedBox(height: 6),
          _FTextField(
            value: f.name,
            onChanged: (v) => c.setField(name: v),
          ),
          const SizedBox(height: 14),
          _FRow(
            left: _FDropdownField(
              label: "Faculty",
              value: f.faculty,
              items: c.faculties,
              onChanged: c.onFacultySelected,
            ),
            right: _FDropdownField(
              label: "Level",
              value: f.level,
              items: c.levels,
              onChanged: (v) => c.setField(level: v),
            ),
          ),
          const SizedBox(height: 14),
          _FRow(
            left: _FDropdownField(
              label: "Major",
              value: f.major,
              items: c.majors,
              onChanged: c.onMajorSelected,
            ),
            right: _FDropdownField(
              label: "Credits",
              value: f.credits,
              items: c.creditsList,
              onChanged: (v) => c.setField(credits: v),
            ),
          ),
          const SizedBox(height: 14),
          _FRow(
            left: _FDropdownField(
              label: "Type",
              value: f.type,
              items: c.types,
              onChanged: (v) => c.setField(type: v),
            ),
            right: _FDropdownField(
              label: "Prerequisite",
              value: f.prerequisite,
              items: ['None', ...c.prerequisiteCourses],
              onChanged: (v) => c.setField(
                prerequisite: (v == null || v == 'None') ? '' : v,
              ),
            ),
          ),
        ],
      );
    });
  }
}
class _FRow extends StatelessWidget {
  final Widget left;
  final Widget right;
  const _FRow({required this.left, required this.right});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }
}
class _FDropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _FDropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FLabel(label),
        const SizedBox(height: 6),
        _FDropdown(
          value: value.isEmpty ? null : value,
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
class CourseDragHandle extends StatelessWidget {
  const CourseDragHandle({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
class CoursePrimaryButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final double? textSize;
  final FontWeight? fontWeight;
  final double? borderRadius;
  final double height;
  const CoursePrimaryButton({
    super.key,
    required this.label,
    required this.loading,
    required this.onTap,
    this.backgroundColor,
    this.textColor,
    this.textSize,
    this.fontWeight,
    this.borderRadius,
    this.height = 48,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primaryBlue,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 10),
          ),
        ),
        child: loading
            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
            : Text(
                label,
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontWeight: fontWeight ?? FontWeight.bold,
                  fontSize: textSize ?? 15,
                ),
              ),
      ),
    );
  }
}
class CourseOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? backgroundColor; // ← now actually applied
  final Color? textColor;
  final double? textSize;
  final FontWeight? fontWeight;
  final Color? borderColor;
  final double? borderRadius;
  final double? borderWidth;
  final double height;
  const CourseOutlinedButton({
    super.key,
    required this.label,
    required this.onTap,
    this.backgroundColor,
    this.textColor,
    this.textSize,
    this.fontWeight,
    this.borderColor,
    this.borderRadius,
    this.borderWidth,
    this.height = 46,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.transparent, // ← FIX
          side: BorderSide(
            color: borderColor ?? const Color(0x1A000000),
            width: borderWidth ?? 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 10),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor ?? AppColors.primaryBlue,
            fontWeight: fontWeight ?? FontWeight.w600,
            fontSize: textSize ?? 15,
          ),
        ),
      ),
    );
  }
}
class CourseCancelButton extends StatelessWidget {
  final String label;
  final Color? textColor;
  final double? textSize;
  final FontWeight? fontWeight;
  final Color? borderColor;
  final double? borderWidth;
  final double? borderRadius;
  final double height;
  const CourseCancelButton({
    super.key,
    this.label = "Cancel",
    this.textColor,
    this.textSize,
    this.fontWeight,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.height = 44,
  });
  @override
  Widget build(BuildContext context) {
    return CourseOutlinedButton(
      label: label,
      onTap: () => Get.back(),
      textColor: textColor ?? AppColors.primaryBlue,
      textSize: textSize ?? 15,
      fontWeight: fontWeight ?? FontWeight.w600,
      borderColor: borderColor ?? Colors.grey.shade300,
      borderWidth: borderWidth ?? 1.2,
      borderRadius: borderRadius ?? 10,
      height: height,
    );
  }
}
class _FLabel extends StatelessWidget {
  final String text;
  const _FLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.smalltext,
      ),
    );
  }
}
class _FTextField extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _FTextField({required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 13, color: AppColors.accentProgramming1),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

class _FDropdown extends StatelessWidget {
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _FDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(
            'Select...',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.accentProgramming1,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.smalltext,
            size: 18,
          ),
        ),
      ),
    );
  }
}