import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/text_style.dart';
import '../../../Core/utilities/colors.dart';
import 'package:academia/Features/Attendance/screens/student_attendance_screen.dart';

class CourseCard extends StatelessWidget {
  final int    sectionId;
  final String title;
  final String type;

  final String midterm;
  final String midtermStatus;

  final String participation;
  final String participationStatus;

  final String attendance;
  final String attendanceStatus;

  final double progress;
  final Color progressColor;

  const CourseCard({
    super.key,
    required this.sectionId,
    required this.title,
    required this.type,
    required this.midterm,
    required this.midtermStatus,
    required this.participation,
    required this.participationStatus,
    required this.attendance,
    required this.attendanceStatus,
    required this.progress,
    required this.progressColor,
  });

  /// 🎯 Type colors
  Color get _typeTextColor {
    switch (type.toLowerCase()) {
      case "core":
        return const Color(0xFF0C4D83);
      case "elective":
        return const Color(0xFFB18334);
      default:
        return Colors.grey;
    }
  }

  Color get _typeBgColor {
    switch (type.toLowerCase()) {
      case "core":
        return const Color(0xFFDDEDFA);
      case "elective":
        return const Color(0xFFFFF3DF);
      default:
        return Colors.grey.shade200;
    }
  }

  /// 🎨 Grade color logic
  Color _getGradeColor(String value) {
    final cleaned = value.replaceAll(' ', '').trim();

    double grade = 0;
    double percent = 0;

    if (cleaned.contains('/')) {
      final parts = cleaned.split('/');
      grade = double.tryParse(parts[0]) ?? 0;
      final total = double.tryParse(parts[1]) ?? 100;
      if (total != 0) percent = (grade / total) * 100;
    } else if (cleaned.contains('%')) {
      percent = double.tryParse(cleaned.replaceAll('%', '')) ?? 0;
      grade = percent;
    } else {
      grade = double.tryParse(cleaned) ?? 0;
      percent = grade;
    }

    if (grade >= 8 && grade <= 15) return Colors.amber;
    if (grade >= 0 && grade <= 5) return Colors.red;

    return percent > 50 ? AppColors.primaryBlue : Colors.red;
  }

  /// 📌 Label + status helper
  Widget _label(String label, String status) {
    return Text(
      status,
      style: TextStyles.caption.copyWith(
        fontSize: 11,
        color: Colors.grey,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }

  /// 🔥 STAT WIDGET
  Widget _stat(String label, String value, String status) {
    final cleaned = value.replaceAll(' ', '');

    Widget buildLabelValue(Widget valueWidget) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyles.caption.copyWith(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 4),
          valueWidget,
          const SizedBox(height: 2),
          _label(label, status),
        ],
      );
    }

    /// % case
    if (cleaned.contains('%')) {
      final number = cleaned.replaceAll('%', '');

      return buildLabelValue(
        RichText(
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            children: [
              TextSpan(
                text: number,
                style: TextStyles.body.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: _getGradeColor(value),
                ),
              ),
              TextSpan(
                text: '%',
                style: TextStyles.body.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      );
    }

    /// fraction case
    final parts = cleaned.contains('/') ? cleaned.split('/') : [cleaned];

    return buildLabelValue(
      RichText(
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          children: [
            TextSpan(
              text: parts[0],
              style: TextStyles.body.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: _getGradeColor(value),
              ),
            ),
            if (parts.length > 1)
              TextSpan(
                text: '/${parts[1]}',
                style: TextStyles.body.copyWith(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 📊 Progress bar
  Widget _progressBar() {
    return Container(
      height: 8,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: progressColor,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// title + badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: TextStyles.body.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: _typeBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  type,
                  style: TextStyles.caption.copyWith(
                    color: _typeTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// stats — each in Expanded so they share width equally
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _stat("Midterm",  midterm,  midtermStatus)),
              const SizedBox(width: 8),
              Expanded(child: _stat("Classwork", participation, participationStatus)),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.to(
                    () => const StudentAttendanceScreen(),
                    arguments: {
                      'sectionId':  sectionId,
                      'courseName': title,
                      'doctorName': '',
                    },
                  ),
                  child: _stat("Attendance", attendance, attendanceStatus),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// progress
          _progressBar(),
        ],
      ),
    );
  }
}