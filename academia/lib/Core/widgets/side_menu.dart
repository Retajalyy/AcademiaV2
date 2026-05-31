import 'package:academia/Features/Auth/services/auth_service.dart';
import 'package:academia/Features/Registiration_admin/screens/NoRegistirationScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utilities/colors.dart';
import 'package:academia/Features/Dashboard_admin/screens/Dashboard_screen.dart';
import 'package:academia/Features/Fees_admin/screens/FeesAdminScreen.dart';
import 'package:academia/Features/course_admin/screens/course_admin_screen.dart';
import 'package:academia/Features/exam_results_admin/screens/exam_results_screen.dart';
import 'package:academia/Features/Exam_schedule_admin/screens/exam_schedule_admin_screen.dart';
import 'package:academia/Features/Announcements/screens/admin_announcements_screen.dart';
class SideMenu extends StatefulWidget {
  final String activeItem;

  const SideMenu({super.key, this.activeItem = 'Dashboard'});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  bool _academicExpanded = false;
  bool _schedulesExpanded = false;

  void _navigate(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 300,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0B3F6B),
              Color(0xFF0C4D83),
              Color(0xFF2C84C6),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              /// HEADER
              Padding(
                padding: const EdgeInsets.only(
                  left: 12,
                  right: 12,
                  top: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// CLOSE BUTTON
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        height: 24,
                        width: 24,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.18),
                          shape: BoxShape.circle,
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// PROFILE IMAGE
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryYellow,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF2468A0),
                          width: 3,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          "AM",
                          style: TextStyle(
                            color: AppColors.accentProgramming1,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// NAME
                    const Text(
                      "Ahmed Mohamed",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 1),

                    const Text(
                      "University Staff . Admin",
                      style: TextStyle(
                        color: Color(0xFFDEDEDE),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              /// MENU ITEMS
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      MenuItem(
                        icon: Icons.home_outlined,
                        title: "Dashboard",
                        active: widget.activeItem == "Dashboard",
                        onTap: () => _navigate(context, const DashboardScreen()),
                      ),

                      MenuItem(
                        icon: Icons.edit_square,
                        title: "Registration",
                        active: widget.activeItem == "Registration",
                        onTap: () => _navigate(context, const NoRegistrationAdminScreen()),
                      ),

                      /// ACADEMIC WITH EXPAND
                      MenuItem(
                        icon: Icons.trending_up_rounded,
                        title: "Academic",
                        active: widget.activeItem == "Academic" ||
                            widget.activeItem == "Courses" ||
                            widget.activeItem == "Exam Results",
                        trailing: _academicExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        onTap: () {
                          setState(() {
                            _academicExpanded = !_academicExpanded;
                          });
                        },
                      ),

                      /// ACADEMIC SUB ITEMS
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 200),
                        crossFadeState: _academicExpanded
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        firstChild: Column(
                          children: [
                            SubMenuItem(
                              title: "Courses",
                              active: widget.activeItem == "Courses",
                              onTap: () => _navigate(context, const CourseAdminScreen()),
                            ),
                            SubMenuItem(
                              title: "Exam Results",
                              active: widget.activeItem == "Exam Results",
                             onTap: () => _navigate(context, const ExamResultsAdminScreen()),
                            ),
                          ],
                        ),
                        secondChild: const SizedBox.shrink(),
                      ),

                      MenuItem(
                        icon: Icons.credit_card_outlined,
                        title: "Fees & Payments",
                        active: widget.activeItem == "Fees & Payments",
                        onTap: () => _navigate(context, const FeesAdminScreen()),
                      ),

                      /// SCHEDULES WITH EXPAND
                      MenuItem(
                        icon: Icons.calendar_month_outlined,
                        title: "Schedules",
                        active: widget.activeItem == 'Schedules' ||
                            widget.activeItem == 'Lecture Schedule' ||
                            widget.activeItem == 'Exam Schedule',
                        trailing: _schedulesExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        onTap: () {
                          setState(() {
                            _schedulesExpanded = !_schedulesExpanded;
                          });
                        },
                      ),

                      /// SCHEDULES SUB ITEMS
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 200),
                        crossFadeState: _schedulesExpanded
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        firstChild: Column(
                          children: [
                            SubMenuItem(
                              title: "Lecture Schedule",
                              active: widget.activeItem == "Lecture Schedule",
                              onTap: () {
                                // _navigate(context, const CourseScheduleScreen());
                              },
                            ),
                            SubMenuItem(
                              title: "Exam Schedule",
                              active: widget.activeItem == "Exam Schedule",
                              onTap: () => _navigate(
                                  context, const ExamScheduleAdminScreen()),
                            ),
                          ],
                        ),
                        secondChild: const SizedBox.shrink(),
                      ),

                      MenuItem(
                        icon: Icons.notifications,
                        title: "Announcements",
                        active: widget.activeItem == "Announcements",
                       onTap: () => _navigate(context, const AdminAnnouncementsScreen()),
                      ),

                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Divider(
                          color: Colors.white.withOpacity(.08),
                          thickness: 1,
                        ),
                      ),

                      MenuItem(
                        icon: Icons.logout_rounded,
                        title: "Sign Out",
                        onTap: () async {
                          Navigator.pop(context);
                          await AuthService().logout();
                          Get.offAllNamed('/login');
                        },
                      ),

                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool active;
  final VoidCallback onTap;
  final IconData? trailing;

  const MenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.active = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: active ? Colors.white.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: active
                ? Border(
                    left: BorderSide(
                      color: AppColors.secondaryYellow,
                      width: 4,
                    ),
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),

                if (trailing != null)
                  Icon(
                    trailing,
                    color: Colors.white,
                    size: 18,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SubMenuItem extends StatelessWidget {
  final String title;
  final bool active;
  final VoidCallback onTap;

  const SubMenuItem({
    super.key,
    required this.title,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 1, bottom: 1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: active ? Colors.white.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: active
                ? Border(
                    left: BorderSide(
                      color: AppColors.secondaryYellow,
                      width: 3,
                    ),
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 68,
              right: 16,
              top: 10,
              bottom: 10,
            ),
            child: Text(
              title,
              textAlign: TextAlign.start,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ),
      ),
    );
  }
}