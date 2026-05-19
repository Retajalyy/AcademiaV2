import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:academia/Core/widgets/bottom_bar.dart';

class SharedBottomNav extends StatelessWidget {
  /// The tab that should appear selected (0=Home,1=Schedule,2=Services,3=Profile)
  final int currentIndex;

  const SharedBottomNav({super.key, this.currentIndex = 2});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF2468A0),
      unselectedItemColor: Colors.grey,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      showUnselectedLabels: true,
      onTap: (index) {
        if (index == currentIndex) return;
        Get.offAll(() => BottomBar(initialIndex: index));
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

  Widget _svg(String path, bool active) {
    return SvgPicture.asset(
      path,
      width: 31,
      height: 31,
      colorFilter: ColorFilter.mode(
        active ? const Color(0xFF2468A0) : Colors.black,
        BlendMode.srcIn,
      ),
    );
  }
}
