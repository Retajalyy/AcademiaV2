import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:academia/Core/utilities/colors.dart';

class CourseCard extends StatelessWidget {
  final int courseId;
  final int sectionId;
  final String title;
  final String doctor;
  final String type;
  final String credits;
  final String day;
  final String time;
  final String location;

  const CourseCard({
    super.key,
    this.courseId  = 0,
    this.sectionId = 0,
    required this.title,
    required this.doctor,
    required this.type,
    required this.credits,
    required this.day,
    required this.time,
    required this.location,
  });

  bool get _isCore => type.toLowerCase() == 'core';

  Color get _accentBg =>
      _isCore ? AppColors.lightblue : AppColors.LightYellow;

  Color get _accentText =>
      _isCore ? AppColors.primaryBlue : const Color(0xFFB7791F);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed('/coursedetails', arguments: {
        'courseId':   courseId,
        'sectionId':  sectionId,
        'courseName': title,
        'doctorName': doctor,
      }),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: name + badges ─────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course name + doctor
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlue,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doctor,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Type + Credits badges stacked
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _Pill(label: type,    bg: _accentBg, fg: _accentText),
                    const SizedBox(height: 6),
                    _Pill(label: credits, bg: _accentBg, fg: _accentText),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ── Bottom row: time + room ────────────────────────────────
            Row(
              children: [
                const Icon(Icons.access_time_rounded,
                    size: 14, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '$day · $time',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF6B7280)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.location_on_outlined,
                    size: 14, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 4),
                Text(
                  location,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const _Pill({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
