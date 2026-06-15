import 'package:academia/Core/controllers/tab_controller.dart';
import 'package:academia/Core/utilities/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:academia/Features/Home/controllers/home_controller.dart';
import 'package:academia/Features/Home/widgets/Due_soon_card.dart';
import 'package:academia/Features/Home/widgets/schedule_card.dart';
import 'package:academia/Core/widgets/notification_bell.dart';
import 'package:academia/Core/widgets/link_arrow.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.babyblue,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
        children: [
          // ── 1. Header ──────────────────────────────────────────────
          _Header(controller: controller, sw: sw, sh: sh),

          // ── 2. Scrollable body ─────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: sh * 0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Today's Schedule
                  _SectionHeader(
                    title: "Today's Schedule",
                    actionLabel: "Full schedule",
                    onTap: () => AppTabController.to.switchTo(1),
                    sw: sw,
                    sh: sh,
                  ),
                  ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: sw * 0.045),
                      itemCount: controller.dailySchedule.length,
                      itemBuilder: (context, index) {
                        return ScheduleCard(
                          item: controller.dailySchedule[index],
                          accentColor: index % 2 == 1
                              ? AppColors.secondaryYellow
                              : AppColors.primaryBlue,
                          isLast: index == controller.dailySchedule.length - 1,
                        );
                      },
                    ),

                  SizedBox(height: sh * 0.02),

                  // Due Soon
                  _SectionHeader(
                    title: "Due Soon",
                    actionLabel: "All courses",
                    onTap: () => Get.toNamed('/course'),
                    sw: sw,
                    sh: sh,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: sw * 0.045),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(sw * 0.04),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha:0.04),
                            blurRadius: sw * 0.04,
                            offset: Offset(0, sw * 0.01),
                          ),
                        ],
                      ),
                      child: Column(
                        children: List.generate(
                          controller.assignments.length,
                          (index) => Column(
                            children: [
                              DueSoonCard(assignment: controller.assignments[index]),
                              if (index != controller.assignments.length - 1)
                                Divider(
                                  height: 1,
                                  indent: sw * 0.04,
                                  endIndent: sw * 0.04,
                                  color: Colors.grey.shade100,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final HomeController controller;
  final double sw, sh;
  const _Header({required this.controller, required this.sw, required this.sh});

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning,';
    if (h < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  String _minutesLabel(String time) {
    final start = time.split(' - ')[0];
    final parts = start.split(':');
    final classMin = int.parse(parts[0]) * 60 + int.parse(parts[1]);
    final now = TimeOfDay.now();
    final diff = classMin - (now.hour * 60 + now.minute);
    if (diff <= 0) return 'Starting now';
    if (diff < 60) return 'In $diff min';
    return 'In ${diff ~/ 60}h ${diff % 60}m';
  }

  @override
  Widget build(BuildContext context) {
    final next = controller.nextClass.value;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: sh * 0.065,
        left: sw * 0.055,
        right: sw * 0.055,
        bottom: sh * 0.03,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greeting,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha:0.85),
                      fontSize: sw * 0.038,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: sh * 0.003),
                  Text(
                    controller.userName.value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: sw * 0.065,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
              // Notification bell
              GestureDetector(
                onTap: () async {
                  await Get.toNamed('/announcements');
                  Get.put(NotificationController(), permanent: true).fetchUnread();
                },
                child: Obx(() {
                  final hasUnread = Get.put(NotificationController(), permanent: true).unreadCount.value > 0;
                  return Stack(
                    children: [
                      Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: sw * 0.065,
                      ),
                      if (hasUnread)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: sw * 0.025,
                            height: sw * 0.025,
                            decoration: const BoxDecoration(
                              color: AppColors.secondaryYellow,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  );
                }),
              ),
            ],
          ),

          SizedBox(height: sh * 0.025),

          // ── Next Class card ────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: sw * 0.045,
              vertical: sh * 0.018,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.13),
              borderRadius: BorderRadius.circular(sw * 0.04),
              border: Border.all(
                color: Colors.white.withValues(alpha:0.18),
                width: 1,
              ),
            ),
            child: next == null
                ? Text(
                    'No more classes today',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: sw * 0.038,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'NEXT CLASS',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: sw * 0.028,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: sw * 0.03,
                              vertical: sh * 0.005,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryYellow,
                              borderRadius: BorderRadius.circular(sw * 0.05),
                            ),
                            child: Text(
                              _minutesLabel(next.time),
                              style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontSize: sw * 0.028,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: sh * 0.008),
                      Text(
                        next.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: sw * 0.052,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: sh * 0.008),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded,
                              color: Colors.white60, size: sw * 0.038),
                          SizedBox(width: sw * 0.015),
                          Text(
                            next.time,
                            style: TextStyle(
                                color: Colors.white70, fontSize: sw * 0.032),
                          ),
                          SizedBox(width: sw * 0.045),
                          Icon(Icons.location_on_outlined,
                              color: Colors.white60, size: sw * 0.038),
                          SizedBox(width: sw * 0.01),
                          Text(
                            next.location,
                            style: TextStyle(
                                color: Colors.white70, fontSize: sw * 0.032),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Header
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onTap;
  final double sw, sh;
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onTap,
    required this.sw,
    required this.sh,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: sw * 0.055,
        right: sw * 0.04,
        top: sh * 0.022,
        bottom: sh * 0.01,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: sw * 0.046,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: LinkArrow(
              label: actionLabel,
              style: TextStyle(
                fontSize: sw * 0.033,
                color:AppColors.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}