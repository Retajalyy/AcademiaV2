import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:academia/Core/utilities/colors.dart';
import 'package:academia/Features/Professor/controllers/professor_nav_controller.dart';
import 'package:academia/Features/Professor/screens/professor_home_screen.dart';
import 'package:academia/Features/Professor/screens/professor_schedule_screen.dart';
import 'package:academia/Features/Professor/screens/professor_courses_screen.dart';
import 'package:academia/Features/Professor/screens/professor_profile_screen.dart';

class ProfessorBottomBar extends StatelessWidget {
  const ProfessorBottomBar({super.key});

  static const _pages = [
    ProfessorHomeScreen(),
    ProfessorScheduleScreen(),
    ProfessorCoursesScreen(),
    ProfessorProfileScreen(),
  ];

  Widget _svgIcon(String path, {bool isActive = false}) {
    return SvgPicture.asset(
      path,
      width: 31,
      height: 31,
      colorFilter: ColorFilter.mode(
        isActive ? const Color(0xFF2468A0) : Colors.black,
        BlendMode.srcIn,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nav = Get.put(ProfessorNavController());

    return Obx(() {
      final index = nav.currentIndex.value;
      return Scaffold(
        body: IndexedStack(index: index, children: _pages),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: index,
          onTap: nav.goTo,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primaryBlue,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(
              icon: _svgIcon('lib/assets/Icons/home.svg'),
              activeIcon:
                  _svgIcon('lib/assets/Icons/home.svg', isActive: true),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: _svgIcon('lib/assets/Icons/schedule.svg'),
              activeIcon:
                  _svgIcon('lib/assets/Icons/schedule.svg', isActive: true),
              label: 'Schedule',
            ),
            BottomNavigationBarItem(
              icon: _svgIcon('lib/assets/Icons/courses.svg'),
              activeIcon:
                  _svgIcon('lib/assets/Icons/courses.svg', isActive: true),
              label: 'Courses',
            ),
            BottomNavigationBarItem(
              icon: _svgIcon('lib/assets/Icons/profile.svg'),
              activeIcon:
                  _svgIcon('lib/assets/Icons/profile.svg', isActive: true),
              label: 'Profile',
            ),
          ],
        ),
      );
    });
  }
}
