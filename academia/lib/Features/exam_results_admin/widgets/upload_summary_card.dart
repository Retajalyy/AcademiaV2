import 'package:flutter/material.dart';
import '../../../core/utilities/colors.dart';
import '../model/upload_form_model.dart';

class UploadSummaryCard extends StatelessWidget {
  final UploadFormModel form;
  const UploadSummaryCard({super.key, required this.form});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: Text(
              'UPLOAD SUMMARY',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _Row(label: 'Faculty', content: form.faculty ?? '—'),
          _Row(
              label: 'Year · Major',
              content: '${form.level ?? ''} · ${form.major ?? ''}'),
          _Row(label: 'Semester', content: form.semester ?? '—'),
          _Row(
              label: 'Academic Year',
              content: form.academicYear ?? '—'),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String content;
  const _Row({required this.label, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              content,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}