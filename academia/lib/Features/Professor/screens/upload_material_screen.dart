import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../controllers/upload_material_controller.dart';

class UploadMaterialScreen extends StatelessWidget {
  const UploadMaterialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(UploadMaterialController());

    return Scaffold(
      backgroundColor: AppColors.babyblue,
      body: Column(
        children: [
          _buildHeader(c),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel('UPLOAD FILE'),
                  const SizedBox(height: 12),
                  _UploadArea(c: c),
                  const SizedBox(height: 24),
                  _SectionLabel('DETAILS'),
                  const SizedBox(height: 12),
                  _DetailsCard(c: c),
                  const SizedBox(height: 28),
                  _UploadButton(c: c),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(UploadMaterialController c) {
    return Container(
      width: double.infinity,
      color: AppColors.primaryBlue,
      padding: const EdgeInsets.fromLTRB(20, 54, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: Get.back,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chevron_left_rounded,
                    color: Colors.white70, size: 28),
                Text('Course Details',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text('New File',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            'Upload material for ${c.course.courseName}',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
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

// ── Upload Area ───────────────────────────────────────────────────────────────

class _UploadArea extends StatelessWidget {
  final UploadMaterialController c;
  const _UploadArea({required this.c});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: c.pickFile,
      child: Obx(() => Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: c.fileName.value.isNotEmpty
                    ? AppColors.primaryBlue
                    : const Color(0xFFD1D5DB),
                width: 1.5,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
            child: c.fileName.value.isEmpty
                ? _emptyState()
                : _fileSelectedState(c.fileName.value),
          )),
    );
  }

  Widget _emptyState() => Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.lightblue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.upload_rounded,
                color: AppColors.primaryBlue, size: 28),
          ),
          const SizedBox(height: 14),
          const Text('Tap to upload a new file',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A2B4A))),
          const SizedBox(height: 4),
          const Text('Supported formats below',
              style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _FormatBadge('PPT',  const Color(0xFFFFF3DF), const Color(0xFFB18334)),
              const SizedBox(width: 8),
              _FormatBadge('DOCX', const Color(0xFFE6F4EA), const Color(0xFF137333)),
              const SizedBox(width: 8),
              _FormatBadge('PDF',  const Color(0xFFE8F0FE), AppColors.primaryBlue),
            ],
          ),
        ],
      );

  Widget _fileSelectedState(String name) => Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.lightblue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.insert_drive_file_outlined,
                color: AppColors.primaryBlue, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(name,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A2B4A)),
                overflow: TextOverflow.ellipsis),
          ),
          GestureDetector(
            onTap: c.pickFile,
            child: const Text('Change',
                style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      );
}

class _FormatBadge extends StatelessWidget {
  final String label;
  final Color  bg;
  final Color  text;
  const _FormatBadge(this.label, this.bg, this.text);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(label,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: text)),
      );
}

// ── Details Card ──────────────────────────────────────────────────────────────

class _DetailsCard extends StatelessWidget {
  final UploadMaterialController c;
  const _DetailsCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Title
          _FieldRow(
            label: 'Title',
            child: TextField(
              controller: c.titleController,
              style: const TextStyle(fontSize: 14, color: Color(0xFF1A2B4A)),
              decoration: const InputDecoration(
                hintText: 'e.g Lecture 4',
                hintStyle: TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF3F4F6)),

          // Type dropdown
          Obx(() => _FieldRow(
                label: 'Type',
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: c.selectedType.value.isEmpty
                        ? null
                        : c.selectedType.value,
                    hint: const Text('',
                        style: TextStyle(
                            color: Color(0xFFBDBDBD), fontSize: 14)),
                    isDense: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF9CA3AF)),
                    style: const TextStyle(
                        fontSize: 14, color: Color(0xFF1A2B4A)),
                    onChanged: (v) {
                      if (v != null) c.selectedType.value = v;
                    },
                    items: UploadMaterialController.types
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(t),
                            ))
                        .toList(),
                  ),
                ),
              )),

          // Due date (only for Assignment / Quiz)
          Obx(() {
            if (!c.showDueDate) return const SizedBox.shrink();
            return Column(
              children: [
                const Divider(height: 1, color: Color(0xFFF3F4F6)),
                _FieldRow(
                  label: 'Due date',
                  child: GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate:
                            c.dueDate.value ?? DateTime.now().add(
                                const Duration(days: 7)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now()
                            .add(const Duration(days: 365)),
                      );
                      if (picked != null) c.dueDate.value = picked;
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            c.dueDateLabel.isEmpty
                                ? ''
                                : c.dueDateLabel,
                            style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF1A2B4A)),
                          ),
                        ),
                        const Icon(Icons.calendar_today_outlined,
                            size: 18, color: Color(0xFF9CA3AF)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  final String label;
  final Widget child;
  const _FieldRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) => Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A2B4A))),
            ),
            Expanded(child: child),
          ],
        ),
      );
}

// ── Upload Button ─────────────────────────────────────────────────────────────

class _UploadButton extends StatelessWidget {
  final UploadMaterialController c;
  const _UploadButton({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() => GestureDetector(
          onTap: c.isUploading.value ? null : c.upload,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: c.isUploading.value
                ? const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.primaryBlue),
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.upload_rounded,
                          color: Color(0xFF1A2B4A), size: 22),
                      SizedBox(width: 10),
                      Text('Upload File',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A2B4A))),
                    ],
                  ),
          ),
        ));
  }
}
