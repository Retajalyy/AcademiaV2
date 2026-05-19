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

  /// 🎯 GPA color rule:
  /// - If grade letter is C → yellow
  /// - Otherwise → blue
  Color getGpaColor(String letter) {
    if (letter == "C") {
      return const Color(0xFFB18334); // yellow/orange
    }
    return const Color(0xFF0C4D83); // blue
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
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
        children: [
          /// Subject
          Expanded(
            flex: 4,
            child: Text(
              subject,
              style: const TextStyle(
                fontSize: 18,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                color: Color(0xFF0C4D83),
              ),
            ),
          ),

          /// Grade
          Expanded(
            flex: 2,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: grade,
                    style: const TextStyle(
                      color: Color(0xFF0C4D83),
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      fontFamily: "Inter",
                    ),
                  ),
                  const TextSpan(
                    text: '/100',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Inter",
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// GPA with rule-based color
          Expanded(
            child: Text(
              gpa,
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                color: getGpaColor(letter), 
              ),
            ),
          ),

          /// Letter badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              letter,
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                color: letterColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

}
