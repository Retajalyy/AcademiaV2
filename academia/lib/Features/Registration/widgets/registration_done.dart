import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../../Home/controllers/home_controller.dart';
import '../../Course/controllers/course_controller.dart';
import '../../Schedule/controllers/schedule_controller.dart';

class RegistrationDoneWidget extends StatelessWidget {
  final String groupLabel;
  final String semesterLabel;

  const RegistrationDoneWidget({
    super.key,
    this.groupLabel = '',
    this.semesterLabel = '',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Blue header ────────────────────────────────────────────────────
        Container(
          color: AppColors.primaryBlue,
          padding: const EdgeInsets.fromLTRB(16, 52, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      _clearStaleControllers();
                      Get.offAllNamed('/app', arguments: 2);
                    },
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const Icon(Icons.notifications_none_rounded,
                      color: Colors.white, size: 24),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Registration',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Enroll in and manage your courses',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),

        // ── Success content ────────────────────────────────────────────────
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 0, 32, 80),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Green checkmark
                Container(
                  width: 110,
                  height: 110,
                  decoration: const BoxDecoration(
                    color: Color(0x80D2FECB),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: Color(0xFF07704F),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded,
                          size: 40, color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'Registration Active',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 14),

                if (groupLabel.isNotEmpty)
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        height: 1.6,
                      ),
                      children: [
                        const TextSpan(text: 'You are currently registered in '),
                        TextSpan(
                          text: groupLabel,
                          style: const TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (semesterLabel.isNotEmpty)
                          TextSpan(text: ' for $semesterLabel.'),
                        if (semesterLabel.isEmpty) const TextSpan(text: '.'),
                      ],
                    ),
                  ),

                const SizedBox(height: 40),

                // Go to Home Page
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _clearStaleControllers();
                      Get.offAllNamed('/app');
                    },
                    icon: const Icon(Icons.home_rounded, size: 20),
                    label: const Text(
                      'Go to Home Page',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // View Schedule
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _clearStaleControllers();
                      Get.offAllNamed('/app', arguments: 1);
                    },
                    icon: const Icon(Icons.calendar_today_rounded, size: 18),
                    label: const Text(
                      'View Schedule',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      side: const BorderSide(color: AppColors.primaryBlue),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

void _clearStaleControllers() {
  if (Get.isRegistered<HomeController>())     Get.delete<HomeController>(force: true);
  if (Get.isRegistered<CourseController>())   Get.delete<CourseController>(force: true);
  if (Get.isRegistered<ScheduleController>()) Get.delete<ScheduleController>(force: true);
}
