import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../../../Core/utilities/text_style.dart';
import '../controllers/course_details_controller.dart';

class CourseHeaderDetails extends StatelessWidget {
  const CourseHeaderDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CourseDetailsController>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      color: AppColors.primaryBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                onPressed: Get.back,
              ),
              const Icon(Icons.notifications, color: Colors.white, size: 28),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            "Course Details",
            style: TextStyles.header2.copyWith(
              color: Colors.white,
              fontSize: 30,
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Obx(() {
            final c       = ctrl.course.value;
            final name    = c?.courseName    ?? '';
            final credits = c?.credits       ?? 0;
            final progress = c?.progress     ?? 0.0;
            final doctor  = ctrl.doctorName.value;

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF2468A0),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name.isEmpty ? '—' : name,
                          style: TextStyles.title.copyWith(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentAI,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$credits credits',
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'Instrument Sans',
                            fontWeight: FontWeight.bold,
                            color: AppColors.accentProgramming1,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (doctor.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      doctor,
                      style: TextStyles.doctor2.copyWith(color: Colors.white70),
                    ),
                  ],

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Course Progress",
                        style: TextStyles.doctor2.copyWith(
                            color: AppColors.accentAI),
                      ),
                      Text(
                        "${(progress * 100).toStringAsFixed(0)}% completed",
                        style: TextStyles.percenatge
                            .copyWith(color: AppColors.accentAI),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: const AlwaysStoppedAnimation(
                          AppColors.primaryBlue),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
