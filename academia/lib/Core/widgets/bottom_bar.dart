import 'package:academia/Core/controllers/tab_controller.dart';
import 'package:academia/Features/Chatbot/screens/chatbot_screen.dart';
import 'package:academia/Features/Home/screens/home_page.dart';
import 'package:academia/Features/Schedule/screens/schedule_screen.dart';
import 'package:academia/Features/Services/screens/services_main_screen.dart';
import 'package:academia/Features/profile/screens/profile_page.dart';
import 'package:academia/Core/utilities/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class BottomBar extends StatelessWidget {
  final int initialIndex;

  const BottomBar({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    final tabCtrl = Get.put(AppTabController(), permanent: true);
    // Only set the index if this is the first time or navigating from outside.
    // Deferred to after this frame so it doesn't mutate the Rx value while
    // the framework is still building this widget (which would trip
    // "setState called during build" on any still-mounted Obx listeners).
    if (tabCtrl.currentIndex.value != initialIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        tabCtrl.currentIndex.value = initialIndex;
      });
    }
    return const _BottomBarView();
  }
}

class _BottomBarView extends StatelessWidget {
  const _BottomBarView();

  static final List<Widget> _pages = [
    const HomePage(),
    const ScheduleScreen(),
    const ServicesScreen(),
    ProfilePage(),
  ];

  Widget _svg(String path, bool active) => SvgPicture.asset(
        path,
        width: 31,
        height: 31,
        colorFilter: ColorFilter.mode(
          active ? const Color(0xFF2468A0) : Colors.black,
          BlendMode.srcIn,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final tabCtrl = AppTabController.to;

    return Obx(() {
      final index = tabCtrl.currentIndex.value;
      return Scaffold(
        body: IndexedStack(
          index: index,
          children: _pages,
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primaryBlue,
          shape: const CircleBorder(),
          onPressed: () => Get.to(() => const ChatbotScreen()),
          child: SvgPicture.asset(
            'lib/assets/Icons/chatbot.svg',
            width: 26,
            height: 26,
            colorFilter:
                const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: index,
          onTap: tabCtrl.switchTo,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF2468A0),
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          showUnselectedLabels: true,
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
        ),
      );
    });
  }
}
