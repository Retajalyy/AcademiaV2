import 'package:academia/Core/utilities/colors.dart';
import 'package:academia/Features/AddUser_admin/screens/add_new_user_screen.dart';
import 'package:academia/Features/Exam_schedule_admin/screens/exam_schedule_admin_screen.dart';
import 'package:academia/Features/exam_results_admin/screens/exam_results_screen.dart';
import 'package:academia/Features/exam_results_admin/widgets/upload_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/text_style.dart';
import 'quick_action_item.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyles.title.copyWith(
              color: Colors.black,
              fontSize: 26,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [

              Expanded(
                child: GestureDetector(
                  onTap: () => Get.to(() => const ExamScheduleAdminScreen(openUpload: true)),
                  child: const QuickActionItem(
                    icon: Icons.file_upload_outlined,
                    title: 'Upload Schedule',
                    borderColor: Color(0xFFDDEDFA),
                    iconColor: AppColors.accentProgramming1,
                    backgroundColor: Color(0xFFDDEDFA),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Get.to(() => const ExamResultsAdminScreen());
                    Future.delayed(const Duration(milliseconds: 400),
                        UploadBottomSheet.show);
                  },
                  child: const QuickActionItem(
                    icon: Icons.trending_up_rounded,
                    title: 'Upload Results',
                    borderColor: Color(0xFFDDEDFA),
                    iconColor: AppColors.accentProgramming1,
                    backgroundColor: Color(0xFFDDEDFA),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: GestureDetector(
                  onTap: () => Get.to(() => const AddNewUserScreen()),
                  child: const QuickActionItem(
                    icon: Icons.person_add_outlined,
                    title: 'Add New User',
                    borderColor: Color(0xFFFFF3DF),
                    iconColor: Color(0xFFB18334),
                    backgroundColor: Color(0xFFFFF3DF),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: GestureDetector(
                  onTap: () => Get.toNamed('/adminAnnouncements'),
                  child: const QuickActionItem(
                    icon: Icons.notifications,
                    title: 'Send Notification',
                    borderColor: Color(0xFFFFF3DF),
                    iconColor: Color(0xFFB18334),
                    backgroundColor: Color(0xFFFFF3DF),
                  ),
                ),
              ),

            ],
          ),
        ],
      ),
    );
  }
}