// ─────────────────────────────────────────────────────────────────────────────
// Widget: StatsCard
// Displays a single numeric stat (value + label) inside the header.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class StatsCard extends StatelessWidget {
  final String value;
  final String label;

  const StatsCard({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}