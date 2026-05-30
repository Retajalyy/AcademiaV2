import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../../Home/controllers/home_controller.dart';
import '../../Course/controllers/course_controller.dart';
import '../../Schedule/controllers/schedule_controller.dart';

class RegistrationDoneWidget extends StatelessWidget {
  const RegistrationDoneWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Success icon ───────────────────────────────────────────────
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF4CAF50), width: 2.5),
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 52,
                color: Color(0xFF4CAF50),
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Registration Confirmed!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            const Text(
              'Your courses have been enrolled successfully.\nYour schedule is now ready.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 36),

            // ── Go to home ─────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  _clearStaleControllers();
                  Get.offAllNamed('/app');
                },
                icon: const Icon(Icons.home_rounded, size: 20),
                label: const Text(
                  'Go to Home',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── View schedule ──────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  _clearStaleControllers();
                  Get.offAllNamed('/app', arguments: 1);
                },
                icon: const Icon(Icons.calendar_today_rounded, size: 18),
                label: const Text(
                  'View Schedule',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  side: const BorderSide(color: AppColors.primaryBlue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _clearStaleControllers() {
  if (Get.isRegistered<HomeController>())     Get.delete<HomeController>(force: true);
  if (Get.isRegistered<CourseController>())   Get.delete<CourseController>(force: true);
  if (Get.isRegistered<ScheduleController>()) Get.delete<ScheduleController>(force: true);
}
