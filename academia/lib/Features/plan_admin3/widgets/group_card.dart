import 'package:flutter/material.dart';
import '../../../Core/utilities/colors.dart';
import '../../../Core/utilities/text_style.dart';

class GroupSE1Card extends StatelessWidget {
  final String groupName;
  final String department;
  final String level;
  final int courseCount;

  const GroupSE1Card({
    super.key,
    required this.groupName,
    required this.department,
    required this.level,
    required this.courseCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryBlue,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: 12),
          _buildInfo(),
          _buildCourseCount(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          groupName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Group $groupName', style: TextStyles.title),
          const SizedBox(height: 2),
          Text('$department · $level', style: TextStyles.doctor),
        ],
      ),
    );
  }

  Widget _buildCourseCount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(courseCount.toString(), style: TextStyles.header2),
        const Text(
          'COURSES',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.darkgrey2,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}