import 'package:academia/Core/utilities/colors.dart';
import 'package:academia/Features/Auth/utils/sign_out.dart';
import 'package:academia/Features/profile/widgets/degree_progress.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../models/student_model.dart';
import '../widgets/profile_header.dart';
import '../widgets/stat_card.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  // ProfilePage is one of the permanent BottomBar tabs (kept alive in an
  // IndexedStack), so its controller must be permanent too — otherwise
  // GetX's smart management can delete it on route transitions while
  // ProfileHeader's Obx is still subscribed to it.
  final ProfileController controller =
      Get.put(ProfileController(), permanent: true);
  final RxInt selectedIndex = 3.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.babyblue,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          );
        }

        if (controller.error.value.isNotEmpty) {
          return _ErrorView(
            message: controller.error.value,
            onRetry: controller.loadProfile,
          );
        }

        if (controller.student.value == null) return const SizedBox();

        return _ProfileBody(student: controller.student.value!);
      }),

    );
  }
}

// ── Body ────────────────────────────────────────────────────────────────────

class _ProfileBody extends StatelessWidget {
  final StudentModel student;
  const _ProfileBody({required this.student});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileHeader(student: student),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Academic Statistics ──────────────────────────────────
                const _SectionTitle(title: 'ACADEMIC STATISTICS'),
                const SizedBox(height: 8),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.3,
                  children: [
                    StatCard(
                      iconAsset: 'lib/assets/Icons/Gpaicon.svg',
                      iconColor: AppColors.primaryBlue,
                      iconBgColor: const Color(0xFFE8EFFE),
                      value: student.gpa.toStringAsFixed(2),
                      label: 'Current GPA',
                    ),
                    StatCard(
                      iconAsset: 'lib/assets/Icons/attendanceicon.svg',
                      iconColor: const Color(0xFF4CAF50),
                      iconBgColor: const Color(0xFFE8F5E9),
                      value: '${student.attendancePercent}%',
                      label: 'Attendance',
                    ),
                    StatCard(
                      iconAsset: 'lib/assets/Icons/coursesicon.svg',
                      iconColor: const Color(0xFF92620A),
                      iconBgColor: const Color(0xFFFFF8E1),
                      value: '${student.coursesEnrolled}',
                      label: 'Courses enrolled',
                    ),
                    StatCard(
                      iconAsset: 'lib/assets/Icons/semestericon.svg',
                      iconColor: AppColors.primaryBlue,
                      iconBgColor: const Color(0xFFE8EFFE),
                      value: 'Sem ${student.semesterCompleted}',
                      label: 'Completed',
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // ── Degree Progress ──────────────────────────────────────
                const _SectionTitle(title: 'DEGREE PROGRESS'),
                const SizedBox(height: 14),
                DegreeProgressCard(
                  completedCredits: student.completedCredits,
                  totalCredits: student.totalCredits,
                  remainingCredits: student.remainingCredits,
                ),
                const SizedBox(height: 30),

                // ── Sign Out ─────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: confirmSignOut,
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Sign Out',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared sub-widgets ──────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 52, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A2E),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}