import 'package:flutter/material.dart';

class SubjectRow extends StatelessWidget {
  final String subject;
  final String grade;
  final String gpa;
  final String letter;
  final Color badgeColor;
  final Color letterColor;
  final bool isLast;

  const SubjectRow({
    super.key,
    required this.subject,
    required this.grade,
    required this.gpa,
    required this.letter,
    required this.badgeColor,
    required this.letterColor,
    this.isLast = false,
  });

  /// GPA color logic
  Color getGpaColor(String letter) {
    if (letter.contains("C")) {
      return const Color(0xFFB18334);
    }

    if (letter.contains("D") || letter.contains("F")) {
      return Colors.red;
    }

    return const Color(0xFF0C4D83);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 14,
      ),

      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// SUBJECT NAME
          Expanded(
            flex: 4,
            child: Text(
              subject,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                color: Color(0xFF0C4D83),
              ),
            ),
          ),

          const SizedBox(width: 8),

          /// GRADE
          Expanded(
            flex: 2,
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: grade,
                    style: const TextStyle(
                      color: Color(0xFF0C4D83),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      fontFamily: 'Inter',
                    ),
                  ),

                  const TextSpan(
                    text: '/100',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          /// GPA
          Expanded(
            child: Text(
              gpa,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                color: getGpaColor(letter),
              ),
            ),
          ),

          const SizedBox(width: 8),

          /// LETTER BADGE
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),

            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(6),
            ),

            child: Text(
              letter,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                color: letterColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}