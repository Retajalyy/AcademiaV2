import 'package:flutter/material.dart';
import '../../../Core/utilities/text_style.dart';

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(), // ✅ converts all letters to CAPITAL
      style: TextStyles.bodySecondary,
    );
  }
}