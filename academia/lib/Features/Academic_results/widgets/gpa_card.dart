import 'package:flutter/material.dart';
import '../../../Core/utilities/colors.dart';

class GpaCard extends StatelessWidget {
  final double cumulativeGpa;
  final List<double?> semesterGpas;

  const GpaCard({
    super.key,
    required this.cumulativeGpa,
    required this.semesterGpas,
  });

  Widget _semesterBox(String label, double? gpa) {
    final display = gpa != null ? gpa.toStringAsFixed(1) : '-';
    return Container(
      width: 64,
      height: 51,
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            display,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressBar(double value) {
    return Container(
      height: 7,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFD3D4D4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: (value / 4.0).clamp(0.0, 1.0),
            child: Container(color: AppColors.secondaryYellow),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = semesterGpas.where((g) => g != null).length;
    final semLabel = completedCount > 0
        ? 'Semesters 1-$completedCount'
        : 'No semesters yet';

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Cumulative GPA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Text(
                      semLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: cumulativeGpa.toStringAsFixed(2),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 40,
                        color: Colors.white,
                      ),
                    ),
                    const TextSpan(
                      text: '/4.0',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 22,
                        color: Color(0xFFD3D4D4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              _progressBar(cumulativeGpa),
              const SizedBox(height: 9),
              Wrap(
                spacing: 21,
                runSpacing: 10,
                children: List.generate(8, (i) =>
                    _semesterBox('Sem ${i + 1}', semesterGpas.length > i ? semesterGpas[i] : null)),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        const SizedBox(height: 6),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 0),
          child: Row(
            children: [
              Expanded(child: Divider(thickness: 0.8, color: Color(0xFFD3D4D4))),
              SizedBox(width: 8),
              Text(
                'Year 4 • 2025-2026 (current)',
                style: TextStyle(
                  color: Color(0xFF979696),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 8),
              Expanded(child: Divider(thickness: 1, color: Color(0xFFD3D4D4))),
            ],
          ),
        ),
      ],
    );
  }
}
