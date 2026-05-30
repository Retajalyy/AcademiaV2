import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../Core/utilities/colors.dart';
import '../../../Core/utilities/text_style.dart';
import '../controllers/course_details_controller.dart';

class CourseMaterialList extends StatelessWidget {
  const CourseMaterialList({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CourseDetailsController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'COURSE MATERIAL',
            style: TextStyles.button.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: const Color(0xFF908C8C),
            ),
          ),
          const SizedBox(height: 10),
          Obx(() {
            final materials = ctrl.course.value?.materials ?? [];

            if (materials.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'No materials uploaded yet',
                    style: TextStyle(color: Color(0xFF908C8C), fontSize: 13),
                  ),
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
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
                children: materials.asMap().entries.map((entry) {
                  final idx      = entry.key;
                  final material = entry.value;
                  return MaterialItem(
                    title:        material.title,
                    subtitle:     material.subtitle,
                    fileType:     material.type,
                    fileUrl:      material.fileUrl,
                    isAssignment: material.isAssignment,
                    isLast:       idx == materials.length - 1,
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class MaterialItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String fileType;
  final String? fileUrl;
  final bool isAssignment;
  final bool isLast;

  const MaterialItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.fileType,
    this.fileUrl,
    required this.isAssignment,
    required this.isLast,
  });

  Color get _iconColor {
    switch (fileType.toLowerCase()) {
      case 'pdf':  return const Color(0xFFEF4444);
      case 'pptx':
      case 'ppt':  return const Color(0xFFF97316);
      case 'docx':
      case 'doc':  return const Color(0xFF2563EB);
      default:     return AppColors.primaryBlue;
    }
  }

  IconData get _icon {
    switch (fileType.toLowerCase()) {
      case 'pdf':  return Icons.picture_as_pdf_outlined;
      case 'pptx':
      case 'ppt':  return Icons.slideshow_outlined;
      default:     return Icons.insert_drive_file_outlined;
    }
  }

  Future<void> _open() async {
    if (fileUrl == null || fileUrl!.isEmpty) {
      Get.snackbar('Unavailable', 'No file URL available',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final uri = Uri.parse(fileUrl!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Could not open file',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_icon, color: _iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyles.caption.copyWith(
                        color: const Color(0xFF908C8C),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: fileUrl != null ? _open : null,
                icon: const Icon(Icons.download),
                color: fileUrl != null
                    ? AppColors.primaryBlue
                    : Colors.grey.shade300,
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 1,
            indent: 14,
            endIndent: 14,
            color: Colors.grey.shade100,
          ),
      ],
    );
  }
}
