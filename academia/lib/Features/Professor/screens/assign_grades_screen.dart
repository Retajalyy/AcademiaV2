import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../controllers/assign_grades_controller.dart';

// ── Grade type configuration ──────────────────────────────────────────────────

class _GradeTypeConfig {
  final String   key;
  final String   label;
  final String   description;
  final int      total;
  final IconData icon;
  final Color    iconColor;
  final Color    iconBg;

  const _GradeTypeConfig({
    required this.key,
    required this.label,
    required this.description,
    required this.total,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });
}

const _gradeTypes = [
  _GradeTypeConfig(
    key:         'midterm',
    label:       'Midterm Exam',
    description: 'Upload scores for all groups',
    total:       15,
    icon:        Icons.assignment_outlined,
    iconColor:   AppColors.primaryBlue,
    iconBg:      AppColors.lightblue,
  ),
  _GradeTypeConfig(
    key:         'participation',
    label:       'Classwork',
    description: 'Participation & assignments',
    total:       25,
    icon:        Icons.checklist_rounded,
    iconColor:   Color(0xFFD97706),
    iconBg:      Color(0xFFFFF3DF),
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class AssignGradesScreen extends StatelessWidget {
  const AssignGradesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(AssignGradesController());

    return Scaffold(
      backgroundColor: AppColors.babyblue,
      body: Column(
        children: [
          _Header(c: c),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              children: [
                ..._gradeTypes.map((type) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _GradeCard(type: type, c: c),
                    )),
                const SizedBox(height: 8),
                Obx(() {
                  if (c.error.value.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(c.error.value,
                        style: const TextStyle(
                            color: Colors.red, fontSize: 13)),
                  );
                }),
                _SubmitButton(c: c),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final AssignGradesController c;
  const _Header({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primaryBlue,
      padding: EdgeInsets.fromLTRB(
          16, MediaQuery.of(context).padding.top + 12, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: Get.back,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chevron_left_rounded,
                    color: Colors.white70, size: 26),
                Text('Course Details',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text('Assign Grades',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              _Badge(c.course.courseName),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge(this.text);

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      );
}

// ── Grade Card ────────────────────────────────────────────────────────────────

class _GradeCard extends StatelessWidget {
  final _GradeTypeConfig       type;
  final AssignGradesController c;
  const _GradeCard({required this.type, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card header ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: type.iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(type.icon, color: type.iconColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(type.label,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A2B4A))),
                      const SizedBox(height: 2),
                      Text(type.description,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9CA3AF))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: type.iconBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${type.total} pts',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: type.iconColor)),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF3F4F6)),

          // ── File area ────────────────────────────────────────────────
          Obx(() {
            final file = c.files[type.key];
            if (file != null) {
              return _FileUploaded(file: file, onRemove: () => c.clearFile(type.key));
            }
            return _UploadArea(onTap: () => c.pickFile(type.key));
          }),
        ],
      ),
    );
  }
}

// ── Uploaded file row ─────────────────────────────────────────────────────────

class _FileUploaded extends StatelessWidget {
  final GradeFileState file;
  final VoidCallback   onRemove;
  const _FileUploaded({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFBBF7D0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.insert_drive_file_outlined,
                color: Color(0xFF16A34A), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(file.fileName,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A2B4A)),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    '${file.studentCount} students · ${file.sizeLabel}',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF16A34A)),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(Icons.close_rounded,
                  color: Color(0xFF9CA3AF), size: 20),
            ),
          ],
        ),
      );
}

// ── Empty upload area ─────────────────────────────────────────────────────────

class _UploadArea extends StatelessWidget {
  final VoidCallback onTap;
  const _UploadArea({required this.onTap});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: const Color(0xFFD1D5DB),
                style: BorderStyle.solid,
                width: 1.5),
          ),
          child: Column(
            children: [
              const Icon(Icons.upload_outlined,
                  size: 32, color: Color(0xFF9CA3AF)),
              const SizedBox(height: 10),
              const Text('Upload CSV File',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlue)),
              const SizedBox(height: 4),
              const Text(
                'Upload a file containing student grades.\nSupported formats: .csv',
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                  ),
                  child: const Text('Choose File',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A2B4A))),
                ),
              ),
            ],
          ),
        ),
      );
}

// ── Submit button ─────────────────────────────────────────────────────────────

class _SubmitButton extends StatelessWidget {
  final AssignGradesController c;
  const _SubmitButton({required this.c});

  @override
  Widget build(BuildContext context) => Obx(() => GestureDetector(
        onTap: c.isSubmitting.value ? null : c.submit,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
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
          child: c.isSubmitting.value
              ? const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.primaryBlue),
                  ),
                )
              : const Center(
                  child: Text('Submit Grades',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A2B4A))),
                ),
        ),
      ));
}
