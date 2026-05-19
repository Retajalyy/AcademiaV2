// lecture_schedule_card.dart
import '../../../Core/utilities/colors.dart';
import 'package:flutter/material.dart';

class LectureScheduleCard extends StatelessWidget {
  final String courseName;
  final String credits;

  // Lecture
  final String lectureDay;
  final String lectureDoctor;
  final String lectureTime;
  final String lectureRoom;

  // Section
  final String sectionDay;
  final String sectionDoctor;
  final String sectionTime;
  final String sectionRoom;

  // Colors
  final Color borderColor;
  final Color creditBackgroundColor;
  final Color creditsTextColor;

  const LectureScheduleCard({
    super.key,
    required this.courseName,
    required this.credits,

    required this.lectureDay,
    required this.lectureDoctor,
    required this.lectureTime,
    required this.lectureRoom,

    required this.sectionDay,
    required this.sectionDoctor,
    required this.sectionTime,
    required this.sectionRoom,

    required this.borderColor,
    required this.creditBackgroundColor,
    required this.creditsTextColor,
    
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffF7F7F7),
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: borderColor,
            width: 5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// TOP ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                courseName,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentProgramming1,
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: creditBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  credits,
                  style: TextStyle(
                    color: creditsTextColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// LECTURE
          ScheduleItem(
            title: "LECTURE",
            day: lectureDay,
            icon: Icons.menu_book_outlined,
            iconColor: AppColors.accentProgramming1,
            doctor: lectureDoctor,
            time: lectureTime,
            room: lectureRoom,
          ),

          const SizedBox(height: 14),

          /// SECTION
          ScheduleItem(
            title: "SECTION",
            day: sectionDay,
            icon: Icons.edit_note_outlined,
            iconColor: AppColors.assignmentColor,
            doctor: sectionDoctor,
            time: sectionTime,
            room: sectionRoom,
          ),
        ],
      ),
    );
  }
}

class ScheduleItem extends StatelessWidget {
  final String title;
  final String day;
  final IconData icon;
  final Color iconColor;
  final String doctor;
  final String time;
  final String room;

  const ScheduleItem({
    super.key,
    required this.title,
    required this.day,
    required this.icon,
    required this.iconColor,
    required this.doctor,
    required this.time,
    required this.room,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// TITLE ROW
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),

            const SizedBox(width: 8),

            Text(
              title,
              style: TextStyle(
                color: iconColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),

            const SizedBox(width: 10),

            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.LightYellow,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                day,
                style: TextStyle(
                  color: AppColors.assignmentColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        /// DETAILS
        DetailRow(
          icon: Icons.person_outline,
          text: doctor,
        ),

        const SizedBox(height: 6),

        DetailRow(
          icon: Icons.access_time,
          text: time,
        ),

        const SizedBox(height: 6),

        DetailRow(
          icon: Icons.location_on_outlined,
          text: room,
        ),
      ],
    );
  }
}

class DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const DetailRow({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.smalltext,
        ),

        const SizedBox(width: 8),

        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.smalltext,
          ),
        ),
      ],
    );
  }
}