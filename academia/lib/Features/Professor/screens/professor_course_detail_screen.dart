import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/screens/file_preview_screen.dart';
import '../../../Core/utilities/colors.dart';
import '../controllers/professor_course_detail_controller.dart';
import '../models/professor_course_detail_model.dart';

class ProfessorCourseDetailScreen extends StatelessWidget {
  const ProfessorCourseDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ProfessorCourseDetailController());

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4FC),
      body: Obx(() => Column(
            children: [
              _Header(c: c),
              Expanded(
                child: c.isLoading.value
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primaryBlue))
                    : RefreshIndicator(
                        onRefresh: c.refresh,
                        child: _Body(c: c),
                      ),
              ),
            ],
          )),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final ProfessorCourseDetailController c;
  const _Header({required this.c});

  @override
  Widget build(BuildContext context) {
    final detail = c.detail.value;
    return Container(
      color: AppColors.primaryBlue,
      padding: const EdgeInsets.fromLTRB(16, 54, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          GestureDetector(
            onTap: Get.back,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chevron_left_rounded,
                    color: Colors.white70, size: 28),
                Text('Courses',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Course icon + name + badges
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.calculate_outlined,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.course.courseName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.2),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        if (detail != null && detail.level > 0)
                          _HeaderBadge('Year ${detail.level}'),
                        if (detail != null && detail.major.isNotEmpty)
                          _HeaderBadge(detail.major),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Stats row inside header
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.2)),
              ),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  _HeaderStat(
                    value: detail != null
                        ? '${detail.totalStudents}'
                        : '—',
                    label: 'Students',
                  ),
                  _VerticalDivider(),
                  _HeaderStat(
                    value: detail != null
                        ? '${detail.groupCount}'
                        : '—',
                    label: 'Groups',
                  ),
                  _VerticalDivider(),
                  _HeaderStat(
                    value: detail != null && detail.major.isNotEmpty
                        ? detail.major
                        : '—',
                    label: 'Major',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  final String label;
  const _HeaderBadge(this.label);

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      );
}

class _HeaderStat extends StatelessWidget {
  final String value;
  final String label;
  const _HeaderStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
      );
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        margin: const EdgeInsets.symmetric(vertical: 12),
        color: Colors.white.withValues(alpha: 0.2),
      );
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  final ProfessorCourseDetailController c;
  const _Body({required this.c});

  @override
  Widget build(BuildContext context) {
    final detail = c.detail.value;
    if (detail == null) return const SizedBox.shrink();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      children: [
        _SectionLabel('COURSE MATERIAL'),
        const SizedBox(height: 12),
        _MaterialsSection(
            detail: detail, courseId: c.course.courseId, ctrl: c),
        const SizedBox(height: 24),
        _SectionLabel('ACTIONS'),
        const SizedBox(height: 8),
        _ActionsGrid(c: c),
      ],
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Text(text,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 0.8)),
          const SizedBox(width: 10),
          const Expanded(
              child: Divider(color: Color(0xFFD1D5DB), thickness: 1)),
        ],
      );
}

// ── Materials Section ─────────────────────────────────────────────────────────

class _MaterialsSection extends StatelessWidget {
  final ProfessorCourseDetailModel detail;
  final int courseId;
  final ProfessorCourseDetailController ctrl;
  const _MaterialsSection(
      {required this.detail,
       required this.courseId,
       required this.ctrl});

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
        children: [
          // Top bar: file count + upload button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                Text(
                  '${detail.materials.length} file${detail.materials.length == 1 ? '' : 's'} uploaded',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A2B4A)),
                ),
                const Spacer(),
                Obx(() => GestureDetector(
                      onTap: ctrl.isUploading.value
                          ? null
                          : () async {
                              final uploaded = await Get.toNamed(
                                '/uploadMaterial',
                                arguments: {'course': ctrl.course},
                              );
                              if (uploaded == true) ctrl.refresh();
                            },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ctrl.isUploading.value
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white))
                            : const Text('+ New File',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700)),
                      ),
                    )),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF3F4F6)),

          // File list
          if (detail.materials.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text('No materials uploaded yet',
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade400)),
              ),
            )
          else
            Column(
              children: detail.materials
                  .asMap()
                  .entries
                  .map((e) => _MaterialRow(
                        material: e.value,
                        isLast: e.key == detail.materials.length - 1,
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _MaterialRow extends StatelessWidget {
  final CourseMaterialModel material;
  final bool isLast;
  const _MaterialRow(
      {required this.material, required this.isLast});

  void _showRenameDialog(ProfessorCourseDetailController ctrl) {
    final nameCtrl = TextEditingController(text: material.name);
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Rename File',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter new name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              Get.back();
              ctrl.renameMaterial(material.id, name);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(ProfessorCourseDetailController ctrl) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete File',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        content: Text(
            'Are you sure you want to delete "${material.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              ctrl.deleteMaterial(material.id, material.fileUrl);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  bool get _isAssignment =>
      material.fileType == 'DOCX' ||
      material.fileType == 'DOC' ||
      material.materialType == 'Assignment' ||
      material.materialType == 'Quiz';

  Color get _iconBg => _isAssignment
      ? const Color(0xFFFFF3DF)
      : const Color(0xFFDDEDFA);

  Color get _iconColor =>
      _isAssignment ? AppColors.assignmentColor : AppColors.primaryBlue;

  IconData get _icon => _isAssignment
      ? Icons.edit_document
      : Icons.insert_drive_file_outlined;

  String get _subtitle {
    final parts = <String>[material.fileType];
    if (material.sizeLabel.isNotEmpty) parts.add(material.sizeLabel);
    return parts.join(' . ');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // File icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_icon, color: _iconColor, size: 22),
              ),
              const SizedBox(width: 12),

              // Name + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(material.name,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A2B4A))),
                    const SizedBox(height: 2),
                    Text(_subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF9CA3AF))),
                  ],
                ),
              ),

              // Eye icon
              GestureDetector(
                onTap: () {
                  final url = material.fileUrl;
                  if (url == null || url.isEmpty) return;
                  openFilePreview(
                    fileUrl:  url,
                    fileName: material.name,
                    fileType: material.fileType,
                  );
                },
                child: Icon(Icons.visibility_outlined,
                    size: 20, color: Colors.grey.shade400),
              ),
              const SizedBox(width: 12),

              // Three dots
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded,
                    size: 20, color: Colors.grey.shade400),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                onSelected: (value) {
                  final ctrl = Get.find<ProfessorCourseDetailController>();
                  if (value == 'rename') {
                    _showRenameDialog(ctrl);
                  } else if (value == 'delete') {
                    _showDeleteDialog(ctrl);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'rename',
                    child: Row(
                      children: [
                        Icon(Icons.drive_file_rename_outline_rounded,
                            size: 18, color: Color(0xFF1A2B4A)),
                        SizedBox(width: 10),
                        Text('Rename'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded,
                            size: 18, color: Colors.red),
                        SizedBox(width: 10),
                        Text('Delete',
                            style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, color: Color(0xFFF3F4F6), indent: 14, endIndent: 14),
      ],
    );
  }
}

// ── Actions Grid ──────────────────────────────────────────────────────────────

class _ActionsGrid extends StatelessWidget {
  final ProfessorCourseDetailController c;
  const _ActionsGrid({required this.c});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionItem(
        icon: Icons.fact_check_outlined,
        label: 'Take\nAttendance',
        iconColor: AppColors.primaryBlue,
        iconBg: AppColors.lightblue,
        onTap: () => Get.toNamed('/takeAttendance', arguments: {
          'courseId':    c.course.courseId,
          'courseName':  c.course.courseName,
          'professorId': c.professorId,
          'isTA':        c.isTA,
        }),
      ),
      _ActionItem(
        icon: Icons.edit_note_outlined,
        label: c.isTA
            ? 'Grade Quizzes\n& Assignments'
            : 'Assign\nGrades',
        iconColor: AppColors.primaryBlue,
        iconBg: AppColors.lightblue,
        onTap: () => Get.toNamed('/assignGrades', arguments: {
          'course':      c.course,
          'professorId': c.professorId,
          'isTA':        c.isTA,
        }),
      ),
      _ActionItem(
        icon: Icons.file_copy_outlined,
        label: 'View\nSubmissions',
        iconColor: AppColors.assignmentColor,
        iconBg: AppColors.LightYellow,
        onTap: () => Get.toNamed('/submissions', arguments: {
          'course':      c.course,
          'professorId': c.professorId,
          'isTA':        c.isTA,
        }),
      ),
      _ActionItem(
        icon: Icons.calendar_month_outlined,
        label: 'Attendance\nRecords',
        iconColor: AppColors.assignmentColor,
        iconBg: AppColors.LightYellow,
        onTap: () => Get.toNamed('/attendanceRecords', arguments: {
          'courseId':    c.course.courseId,
          'courseName':  c.course.courseName,
          'professorId': c.professorId,
          'isTA':        c.isTA,
        }),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: actions.map((a) => _ActionCard(item: a)).toList(),
    );
  }
}

class _ActionItem {
  final IconData     icon;
  final String       label;
  final Color        iconColor;
  final Color        iconBg;
  final VoidCallback onTap;
  const _ActionItem({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.iconBg,
    required this.onTap,
  });
}

class _ActionCard extends StatelessWidget {
  final _ActionItem item;
  const _ActionCard({required this.item});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: item.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: item.iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, color: item.iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.label,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A2B4A),
                      height: 1.3),
                ),
              ),
            ],
          ),
        ),
      );
}
