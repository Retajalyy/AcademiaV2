import 'package:flutter/material.dart';

/// A text label followed by a right-chevron arrow icon, used for
/// "View all" / "See all" / "Full schedule" style navigation links
/// that previously used a literal '>' character.
class LinkArrow extends StatelessWidget {
  final String label;
  final TextStyle style;
  final double? iconSize;

  const LinkArrow({
    super.key,
    required this.label,
    required this.style,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: style),
        Icon(
          Icons.chevron_right_rounded,
          size: iconSize ?? (style.fontSize ?? 14) + 6,
          color: style.color,
        ),
      ],
    );
  }
}
