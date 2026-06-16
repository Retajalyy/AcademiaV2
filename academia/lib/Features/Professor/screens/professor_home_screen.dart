import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../../../Core/widgets/link_arrow.dart';
import '../controllers/professor_home_controller.dart';
import '../controllers/professor_nav_controller.dart';
import '../models/professor_schedule_item.dart';

class ProfessorHomeScreen extends StatelessWidget {
  const ProfessorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ProfessorHomeController());

    return Scaffold(
      backgroundColor: AppColors.babyblue,
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator(
              color: AppColors.primaryBlue));
        }
        return RefreshIndicator(
          onRefresh: c.refresh,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(c)),
              const SliverToBoxAdapter(child: SizedBox(height: 22)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                    child: _TodayScheduleSection(c: c)),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 22)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                    child: _AcademicOverviewSection(c: c)),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
            ],
          ),
        );
      }),
    );
  }

  // ── Header (greeting + next class embedded) ──────────────────────────────────

  Widget _buildHeader(ProfessorHomeController c) {
    return Container(
      color: AppColors.primaryBlue,
      padding: const EdgeInsets.fromLTRB(20, 54, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.greeting,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${c.professorTitle.value}. ${c.professorName.value}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                )),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Next class card — embedded in header
          Obx(() {
            final item = c.nextClass.value;
            if (item == null) {
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: Colors.white60, size: 20),
                    SizedBox(width: 10),
                    Text('No more classes today',
                        style: TextStyle(
                            color: Colors.white60, fontSize: 16)),
                  ],
                ),
              );
            }
            return _NextClassCard(item: item);
          }),
        ],
      ),
    );
  }
}

// ── Next Class Card ───────────────────────────────────────────────────────────

class _NextClassCard extends StatelessWidget {
  final ProfessorScheduleItem item;
  const _NextClassCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // NEXT CLASS label + time badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'NEXT CLASS',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
              _TimeBadge(item: item),
            ],
          ),
          const SizedBox(height: 10),

          // Course name
          Text(
            item.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          // Time · Room · Group
          Row(
            children: [
              const Icon(Icons.access_time_outlined,
                  color: Colors.white70, size: 15),
              const SizedBox(width: 5),
              Text('${item.startTime} - ${item.endTime}',
                  style: const TextStyle(color: Colors.white70, fontSize: 15)),
              if (item.location.isNotEmpty) ...[
                const SizedBox(width: 14),
                const Icon(Icons.location_on_outlined,
                    color: Colors.white70, size: 15),
                const SizedBox(width: 5),
                Text(item.location,
                    style: const TextStyle(color: Colors.white70, fontSize: 15)),
              ],
              if (item.groups.isNotEmpty) ...[
                const SizedBox(width: 14),
                const Icon(Icons.people_outlined,
                    color: Colors.white70, size: 15),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    item.groups.first,
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeBadge extends StatelessWidget {
  final ProfessorScheduleItem item;
  const _TimeBadge({required this.item});

  String get _label {
    final parts = item.startTime.split(':');
    if (parts.length < 2) return item.startTime;
    final now = TimeOfDay.now();
    final classMins = int.parse(parts[0]) * 60 + int.parse(parts[1]);
    final nowMins = now.hour * 60 + now.minute;
    final diff = classMins - nowMins;
    if (diff <= 0) return 'Starting now';
    if (diff < 60) return 'In $diff min';
    return 'In ${diff ~/ 60}h ${diff % 60}m';
  }

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.accentAI,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          _label,
          style: const TextStyle(
            color: AppColors.primaryBlue,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}

// ── Today's Schedule ──────────────────────────────────────────────────────────

class _TodayScheduleSection extends StatelessWidget {
  final ProfessorHomeController c;
  const _TodayScheduleSection({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = c.todaySchedule;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Schedule",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A2A4A)),
              ),
              GestureDetector(
                onTap: () =>
                    Get.find<ProfessorNavController>().goTo(1),
                child: const LinkArrow(
                  label: 'Full Schedule',
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text('No classes scheduled for today',
                    style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            Column(
              children: items
                  .map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ScheduleItem(item: item),
                      ))
                  .toList(),
            ),
        ],
      );
    });
  }
}

class _ScheduleItem extends StatelessWidget {
  final ProfessorScheduleItem item;
  const _ScheduleItem({required this.item});

  Color get _barColor {
    switch (item.type.toLowerCase()) {
      case 'lecture':  return AppColors.primaryBlue;
      case 'section':  return AppColors.accentAI;
      default:         return AppColors.primaryBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Time column
          SizedBox(
            width: 42,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.startTime,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A2A4A))),
                const SizedBox(height: 3),
                Text(item.endTime,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF))),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Colored left bar
          Container(
            width: 3,
            height: 46,
            decoration: BoxDecoration(
              color: _barColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          const SizedBox(width: 12),

          // Course info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryBlue),
                      ),
                    ),
                    _TypeBadge(type: item.type),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    if (item.location.isNotEmpty) item.location,
                    if (item.groups.isNotEmpty) item.groups.join(' · '),
                  ].join(' . '),
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final isLecture = type.toLowerCase() == 'lecture';
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isLecture
            ? const Color(0xFFE8F0FE)
            : const Color(0xFFFFF3DF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        type,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isLecture
              ? AppColors.primaryBlue
              : AppColors.assignmentColor,
        ),
      ),
    );
  }
}

// ── Academic Overview ─────────────────────────────────────────────────────────

class _AcademicOverviewSection extends StatelessWidget {
  final ProfessorHomeController c;
  const _AcademicOverviewSection({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Academic Overview',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2A4A)),
                ),
                GestureDetector(
                  onTap: () => Get.toNamed('/academicOverview'),
                  child: const LinkArrow(
                    label: 'See All',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Assignment card
            if (c.latestAssignment.value != null)
              GestureDetector(
                onTap: () => Get.toNamed('/assignmentOverview',
                    arguments: c.latestAssignment.value),
                child: _OverviewCard(
                  iconData: Icons.assignment_outlined,
                  iconBg: const Color(0xFFE8F0FE),
                  iconColor: AppColors.primaryBlue,
                  title: c.latestAssignment.value!['title'] as String,
                  subtitle: c.latestAssignment.value!['course'] as String,
                  badge: c.latestAssignment.value!['badge'] as String,
                  badgeColor: const Color(0xFFE6F4EA),
                  badgeTextColor: const Color(0xFF137333),
                  showArrow: true,
                ),
              ),

            if (c.latestAssignment.value != null)
              const SizedBox(height: 10),

            // Students at risk card
            GestureDetector(
              onTap: () => Get.toNamed('/studentsAtRisk', arguments: {
                'professorId': c.professorId,
                'isTA':        c.isTA.value,
              }),
              child: _OverviewCard(
                iconData: Icons.person_off_outlined,
                iconBg: const Color(0xFFFFEEEE),
                iconColor: AppColors.fail,
                title: 'Students at risk',
                subtitle: 'Approaching absence limit',
                badge: '${c.studentsAtRisk.value} student${c.studentsAtRisk.value == 1 ? '' : 's'}',
                badgeColor: const Color(0xFFFFEEEE),
                badgeTextColor: AppColors.fail,
                showArrow: true,
              ),
            ),

            if (c.nextExamInfo.value != null) ...[
              const SizedBox(height: 10),
              // Next exam card
              GestureDetector(
                onTap: () => Get.toNamed('/professorExamSchedule', arguments: {
                  'professorId': c.professorId,
                  'isTA':        c.isTA.value,
                }),
                child: _OverviewCard(
                  iconData: Icons.calendar_today_outlined,
                  iconBg: const Color(0xFFFFF3DF),
                  iconColor: AppColors.assignmentColor,
                  title: 'Next exam',
                  subtitle: c.nextExamInfo.value!['subtitle'] as String,
                  badge: c.nextExamInfo.value!['badge'] as String,
                  badgeColor: const Color(0xFFFFF3DF),
                  badgeTextColor: AppColors.assignmentColor,
                  showArrow: true,
                ),
              ),
            ],
          ],
        ));
  }
}

class _OverviewCard extends StatelessWidget {
  final IconData iconData;
  final Color    iconBg;
  final Color    iconColor;
  final String   title;
  final String   subtitle;
  final String   badge;
  final Color    badgeColor;
  final Color    badgeTextColor;
  final bool     showArrow;

  const _OverviewCard({
    required this.iconData,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.badgeTextColor,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),

          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A2A4A))),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF))),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Badge
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(badge,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: badgeTextColor)),
          ),

          if (showArrow) ...[
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey.shade400, size: 20),
          ],
        ],
      ),
    );
  }
}
