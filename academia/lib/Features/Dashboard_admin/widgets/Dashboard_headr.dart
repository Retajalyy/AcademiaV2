import 'package:academia/Features/Dashboard_admin/controller/dashboard_controller.dart';
import 'package:academia/Features/Dashboard_admin/screens/profile_menuScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import 'stat_card.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 18, left: 16, right: 16, bottom: 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          /// TOP BAR
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Builder(
                builder: (context) => GestureDetector(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: const Icon(Icons.menu, color: Colors.white, size: 30),
                ),
              ),
              const Text(
                'Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileMenuScreen(),
                  ),
                ),
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryYellow,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF2468A0),
                      width: 4,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'AM',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          /// 2x2 STATS GRID — driven by controller
          Obx(() => GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.6,
            children: [
              StatCard(
                icon: Icons.people_outline,
                title: 'Total\nStudents',
                value: controller.totalStudents,
                subtitle: '${controller.semester} · Active',
                height: 80,
              ),
              StatCard(
                icon: Icons.account_balance_outlined,
                title: 'Faculties',
                value: controller.faculties,
                subtitle: '${controller.majors} Majors total',
                height: 80,
              ),
              StatCard(
                icon: Icons.person_outline,
                title: 'Instructors',
                value: controller.instructors,
                subtitle: '${controller.totalCourses} Courses total',
                height: 80,
              ),
              StatCard(
                icon: Icons.access_time,
                title: 'Academic\nProgress',
                value: controller.academicWeek,
                subtitle: '${controller.totalWeeks} Weeks total',
                height: 80,
              ),
            ],
          )),
        ],
      ),
    );
  }
}