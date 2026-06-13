import 'package:academia/Core/controllers/tab_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class SharedBottomNav extends StatelessWidget {
  final int currentIndex;
  const SharedBottomNav({super.key, this.currentIndex = 2});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF2468A0),
      unselectedItemColor: Colors.grey,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      showUnselectedLabels: true,
      onTap: (index) {
        // If BottomBar is already in the stack, switch its tab without destroying it
        if (Get.isRegistered<AppTabController>()) {
          AppTabController.to.switchTo(index);
          Get.until((route) => route.isFirst);
        } else {
          Get.offAllNamed('/app');
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: _svg('lib/assets/Icons/home.svg', false),
          activeIcon: _svg('lib/assets/Icons/home.svg', true),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: _svg('lib/assets/Icons/schedule.svg', false),
          activeIcon: _svg('lib/assets/Icons/schedule.svg', true),
          label: 'Schedule',
        ),
        BottomNavigationBarItem(
          icon: _svg('lib/assets/Icons/services.svg', false),
          activeIcon: _svg('lib/assets/Icons/services.svg', true),
          label: 'Services',
        ),
        BottomNavigationBarItem(
          icon: _svg('lib/assets/Icons/profile.svg', false),
          activeIcon: _svg('lib/assets/Icons/profile.svg', true),
          label: 'Profile',
        ),
      ],
    );
  }

  Widget _svg(String path, bool active) => SvgPicture.asset(
        path,
        width: 31,
        height: 31,
        colorFilter: ColorFilter.mode(
          active ? const Color(0xFF2468A0) : Colors.black,
          BlendMode.srcIn,
        ),
      );
}
