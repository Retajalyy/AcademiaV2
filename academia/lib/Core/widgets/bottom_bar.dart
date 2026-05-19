import 'package:academia/Features/Chatbot/screens/chatbot_screen.dart';
import 'package:academia/Features/Home/screens/home_page.dart';
import 'package:academia/Features/Schedule/screens/schedule_screen.dart';
import 'package:academia/Features/Services/screens/services_main_screen.dart';
import 'package:academia/Features/profile/screens/profile_page.dart';
import 'package:academia/Core/utilities/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class BottomBar extends StatefulWidget {
  final int initialIndex;

  const BottomBar({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  final List<Widget> pages = [
    const HomePage(),
    const ScheduleScreen(),
    const ServicesScreen(),
    ProfilePage(),
  ];

  void onTabChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  Widget buildSvgIcon(
    String path, {
    bool isActive = false,
  }) {
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
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBlue,
        shape: const CircleBorder(),
        onPressed: () => Get.to(() => const ChatbotScreen()),
        child: SvgPicture.asset(
          'lib/assets/Icons/chatbot.svg',
          width: 26,
          height: 26,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTabChanged,
        type: BottomNavigationBarType.fixed,

        selectedItemColor: const Color(0xFF2468A0),
        unselectedItemColor: Colors.grey,

        selectedFontSize: 12,
        unselectedFontSize: 12,

        showUnselectedLabels: true,

        items: [
          BottomNavigationBarItem(
            icon: buildSvgIcon(
              "lib/assets/Icons/home.svg",
            ),
            activeIcon: buildSvgIcon(
              "lib/assets/Icons/home.svg",
              isActive: true,
            ),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: buildSvgIcon(
              "lib/assets/Icons/schedule.svg",
            ),
            activeIcon: buildSvgIcon(
              "lib/assets/Icons/schedule.svg",
              isActive: true,
            ),
            label: "Schedule",
          ),

          BottomNavigationBarItem(
            icon: buildSvgIcon(
              "lib/assets/Icons/services.svg",
            ),
            activeIcon: buildSvgIcon(
              "lib/assets/Icons/services.svg",
              isActive: true,
            ),
            label: "Services",
          ),

          BottomNavigationBarItem(
            icon: buildSvgIcon(
              "lib/assets/Icons/profile.svg",
            ),
            activeIcon: buildSvgIcon(
              "lib/assets/Icons/profile.svg",
              isActive: true,
            ),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}