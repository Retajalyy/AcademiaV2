import 'package:flutter/material.dart';
import '../../../core/utilities/colors.dart';
import '../model/upload_form_model.dart';

class UploadFilePicker extends StatelessWidget {
  final UploadFormModel form;
  final VoidCallback onPickFile;
  final VoidCallback onRemoveFile;

  const UploadFilePicker({
    super.key,
    required this.form,
    required this.onPickFile,
    required this.onRemoveFile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload File',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        form.fileBytes == null
            ? _PickArea(onTap: onPickFile)
            : _FilePreview(form: form, onRemove: onRemoveFile),
      ],
    );
  }
}

class _PickArea extends StatelessWidget {
  final VoidCallback onTap;
  const _PickArea({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 155,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
          color: Colors.grey.shade50,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.upload_outlined,
                size: 36, color: AppColors.primaryBlue),
            const SizedBox(height: 8),
            Text(
              'Tap to upload results file',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Supported formats below',
              style:
                  TextStyle(fontSize: 16, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Chip('XLSX'),
                const SizedBox(width: 6),
                _Chip('XLS'),
                const SizedBox(width: 6),
                _Chip('CSV'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
      );
}

class _FilePreview extends StatelessWidget {
  final UploadFormModel form;
  final VoidCallback onRemove;
  const _FilePreview({required this.form, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade50,
      ),
      child: Row(
        children: [
          Icon(Icons.description_outlined,
              color: AppColors.primaryBlue, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  form.fileName ?? '',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16,
                      color: AppColors.primaryBlue),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${form.fileRows ?? 0} rows · '
                  '${form.fileSizeMb?.toStringAsFixed(1) ?? '0'} MB',
                  style: TextStyle(
                      fontSize: 14, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onRemove,
            style: TextButton.styleFrom(
                foregroundColor: Colors.redAccent),
            child: const Text('Remove',
                style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}