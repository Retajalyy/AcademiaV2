import 'package:flutter/material.dart';
import '../../../Core/utilities/colors.dart';
import '../../../Core/utilities/text_style.dart';

class CourseMaterialList extends StatelessWidget {
  const CourseMaterialList({super.key});

  @override
  Widget build(BuildContext context) {
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

          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),

            // ❗ FIX: removed const here
            child: Column(
              children: const [
                MaterialItem(
                  title: 'Lecture 1',
                  subtitle: 'PDF . 2.4 MB',
                  icon: Icons.insert_drive_file_outlined,
                  isAssignment: false,
                  isLast: false,
                ),
                MaterialItem(
                  title: 'Lecture 2',
                  subtitle: 'PDF . 3.1 MB',
                  icon: Icons.insert_drive_file_outlined,
                  isAssignment: false,
                  isLast: false,
                ),
                MaterialItem(
                  title: 'Lecture 3',
                  subtitle: 'PDF . 2.8 MB',
                  icon: Icons.insert_drive_file_outlined,
                  isAssignment: false,
                  isLast: false,
                ),
                MaterialItem(
                  title: 'Assignment 1',
                  subtitle: 'DOCX . Due May 5',
                  icon: Icons.edit_document,
                  isAssignment: true,
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MaterialItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isAssignment;
  final bool isLast;

  const MaterialItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isAssignment,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor = isAssignment
        ? AppColors.assignmentColor
        : AppColors.primaryBlue;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Title + subtitle
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

              // Actions
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.remove_red_eye_outlined),
                    color: AppColors.primaryBlue,
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 14),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.download),
                    color: AppColors.primaryBlue,
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
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