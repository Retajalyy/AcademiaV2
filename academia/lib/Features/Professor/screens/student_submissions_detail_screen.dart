import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/screens/file_preview_screen.dart';
import '../../../Core/utilities/colors.dart';
import '../controllers/student_submissions_detail_controller.dart';
import '../models/student_submission_record.dart';

class StudentSubmissionsDetailScreen extends StatelessWidget {
  const StudentSubmissionsDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(StudentSubmissionsDetailController());

    return Scaffold(
      backgroundColor: AppColors.babyblue,
      body: Column(
        children: [
          _Header(c: c),
          Expanded(
            child: Obx(() {
              if (c.isLoading.value) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryBlue));
              }
              if (c.students.isEmpty) {
                return const Center(
                  child: Text('No students enrolled.',
                      style: TextStyle(
                          color: Color(0xFF9CA3AF), fontSize: 14)),
                );
              }
              return ListView.separated(
                padding:
                    const EdgeInsets.fromLTRB(16, 20, 16, 32),
                itemCount: c.students.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (_, i) =>
                    _StudentCard(record: c.students[i], c: c),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final StudentSubmissionsDetailController c;
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
                Text('Submissions',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text('Student Submissions',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              _Badge(c.assignment.name),
              if (c.assignment.dueDateLabel.isNotEmpty)
                _Badge(c.assignment.dueDateLabel),
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

// ── Student Card ──────────────────────────────────────────────────────────────

class _StudentCard extends StatelessWidget {
  final StudentSubmissionRecord            record;
  final StudentSubmissionsDetailController c;
  const _StudentCard({required this.record, required this.c});

  Color get _statusColor {
    switch (record.status) {
      case SubmissionStatus.onTime:  return const Color(0xFF16A34A);
      case SubmissionStatus.late:    return const Color(0xFFD97706);
      case SubmissionStatus.missing: return const Color(0xFFDC2626);
    }
  }

  Color get _statusBg {
    switch (record.status) {
      case SubmissionStatus.onTime:  return const Color(0xFFDCFCE7);
      case SubmissionStatus.late:    return const Color(0xFFFFF3DF);
      case SubmissionStatus.missing: return const Color(0xFFFFEEEE);
    }
  }

  String _fmtDate(DateTime dt) {
    const m = ['','Jan','Feb','Mar','Apr','May','Jun',
                   'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[dt.month]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = c.gradeControllers[record.enrollmentId];

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
          // ── Student info + status ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.lightblue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      record.name.isNotEmpty
                          ? record.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(record.name,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A2B4A))),
                      Text(record.uniId,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9CA3AF))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(record.statusLabel,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _statusColor)),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF3F4F6)),

          // ── Submission file + date ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: record.fileUrl != null
                ? GestureDetector(
                    onTap: () => openFilePreview(
                      fileUrl:  record.fileUrl!,
                      fileName: record.fileName ?? 'File',
                      fileType: 'pdf',
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.insert_drive_file_outlined,
                            color: AppColors.primaryBlue, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            record.fileName ?? 'Submitted file',
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (record.submittedAt != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            _fmtDate(record.submittedAt!),
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9CA3AF)),
                          ),
                        ],
                      ],
                    ),
                  )
                : Row(
                    children: [
                      const Icon(Icons.folder_off_outlined,
                          color: Color(0xFF9CA3AF), size: 18),
                      const SizedBox(width: 8),
                      const Text('No submission',
                          style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF9CA3AF))),
                    ],
                  ),
          ),

          const Divider(height: 1, color: Color(0xFFF3F4F6)),

          // ── Grade assignment ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Row(
              children: [
                const Text('Grade:',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A2B4A))),
                const SizedBox(width: 10),
                SizedBox(
                  width: 70,
                  height: 36,
                  child: TextField(
                    controller: ctrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A2B4A)),
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: Color(0xFFD1D5DB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: AppColors.primaryBlue),
                      ),
                      hintText: '—',
                      hintStyle: const TextStyle(
                          color: Color(0xFFBDBDBD)),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text('/ ${record.maxGrade.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 14, color: Color(0xFF9CA3AF))),
                const Spacer(),
                Obx(() => GestureDetector(
                      onTap: c.isSaving.value
                          ? null
                          : () => c.saveGrade(record.enrollmentId),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: c.isSaving.value
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white))
                            : const Text('Save',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
