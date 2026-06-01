import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../controller/course_schedule_admin_controller.dart';
import '../models/course_schedule_admin_model.dart';

const _dayAbbr = {
  'Sunday':    'Sun',
  'Monday':    'Mon',
  'Tuesday':   'Tue',
  'Wednesday': 'Wed',
  'Thursday':  'Thu',
  'Friday':    'Fri',
  'Saturday':  'Sat',
};

class CourseScheduleGroupDetailScreen extends StatelessWidget {
  final CourseScheduleGroupModel group;
  const CourseScheduleGroupDetailScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final c     = Get.find<CourseScheduleAdminController>();
    final color = group.facultyColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _BlueSection(group: group, c: c, color: color),
            Expanded(child: _SessionsBody(c: c, color: color)),
          ],
        ),
      ),
    );
  }
}

// ── Blue top section (back + group info + day tabs) ───────────────────────────

class _BlueSection extends StatelessWidget {
  final CourseScheduleGroupModel group;
  final CourseScheduleAdminController c;
  final Color color;
  const _BlueSection(
      {required this.group, required this.c, required this.color});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.primaryBlue,
      padding: EdgeInsets.fromLTRB(0, top + 4, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back row
          InkWell(
            onTap: () => Get.back(),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chevron_left, color: Colors.white, size: 22),
                  SizedBox(width: 2),
                  Text(
                    'All Groups',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Group info
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    border: Border.all(
                        color: const Color(0xFFFFC258), width: 2.5),
                  ),
                  child: Center(
                    child: Text(
                      group.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Group ${group.label}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${group.majorName} · Level ${group.level}',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Day tabs
          Obx(() {
            final days      = c.scheduledDays;
            final activeDay = c.selectedDay.value; // read here so Obx tracks it
            if (days.isEmpty) return const SizedBox.shrink();
            return SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: days.length,
                itemBuilder: (_, i) {
                  final day      = days[i];
                  final isActive = activeDay == day;
                  return GestureDetector(
                    onTap: () => c.selectedDay.value = day,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isActive
                                ? const Color(0xFFFFC258)
                                : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                      ),
                      child: Text(
                        _dayAbbr[day] ?? day,
                        style: TextStyle(
                          color: isActive
                              ? const Color(0xFFFFC258)
                              : Colors.white54,
                          fontSize: 15,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Sessions body ─────────────────────────────────────────────────────────────

class _SessionsBody extends StatelessWidget {
  final CourseScheduleAdminController c;
  final Color color;
  const _SessionsBody({required this.c, required this.color});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.detailLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue),
        );
      }

      final sessions = c.sessionsForSelectedDay;
      final day      = c.selectedDay.value;

      if (c.groupSchedule.value != null && c.scheduledDays.isEmpty) {
        return Center(
          child: Text(
            'No schedule available for this group',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          ),
        );
      }

      if (sessions.isEmpty && day.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDEDFA),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.calendar_month_outlined,
                      size: 40,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No sessions on ${_dayAbbr[day] ?? day}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This group has no scheduled lectures\nor sections on this day.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (day.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                '${day.toUpperCase()} · ${sessions.length} SESSION${sessions.length == 1 ? '' : 'S'}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6B7280),
                  letterSpacing: 0.6,
                ),
              ),
            ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: sessions.length,
              separatorBuilder: (_, i) => const SizedBox(height: 10),
              itemBuilder: (_, i) =>
                  _SessionCard(session: sessions[i]),
            ),
          ),
        ],
      );
    });
  }
}

// ── Session Card ──────────────────────────────────────────────────────────────

class _SessionCard extends StatelessWidget {
  final CourseSessionModel session;
  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final isLecture = session.type == 'Lecture';
    final blockColor = isLecture
        ? AppColors.primaryBlue
        : const Color(0xFFFFC258);
    final badgeBg = isLecture
        ? const Color(0xFFDDEDFA)
        : const Color(0xFFFFF3DF);
    final badgeText = isLecture
        ? AppColors.primaryBlue
        : const Color(0xFFB18334);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Time block
            Container(
              width: 72,
              decoration: BoxDecoration(
                color: blockColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    session.startTime,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 28,
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    session.endTime,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      session.courseName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A2A4A),
                      ),
                    ),
                    if (session.instructor.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.person_outline,
                              size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              session.instructor,
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey.shade600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (session.room.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 5),
                          Text(
                            session.room,
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Type badge
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  session.type,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: badgeText,
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
