import 'package:flutter/material.dart';
import '../../../Core/utilities/colors.dart';

class ArchitectureProgress extends StatelessWidget {
  final int currentStep;
  final double circleSize;
  final double fontSize;

  const ArchitectureProgress({
    super.key,
    required this.currentStep,
    this.circleSize = 22,
    this.fontSize = 11,
  });

  bool _isCompleted(int step) => currentStep > step;
  bool _isCurrent(int step)   => currentStep == step;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStep(1),
        _buildLine(1),
        _buildStep(2),
        _buildLine(2),
        _buildStep(3),
      ],
    );
  }

  Widget _buildLine(int stepBefore) {
    final isActive = currentStep > stepBefore;
    return Expanded(
      child: Container(
        height: 3,
        color: isActive
            ? AppColors.secondaryYellow
            : const Color(0xFFDEDEDE),
      ),
    );
  }

  Widget _buildStep(int number) {
    final isCompleted = _isCompleted(number);
    final isCurrent   = _isCurrent(number);
    final isFuture    = number > currentStep;

    return Container(
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: (isCompleted || isCurrent)
            ? AppColors.secondaryYellow
            : const Color(0xFFDEDEDE),
      ),
      child: Center(
        child: isCompleted
            ? Icon(
                Icons.check_rounded,
                color: AppColors.primaryBlue,
                size: circleSize * 0.59,
              )
            : Text(
                number.toString(),
                style: TextStyle(
                  color: isFuture
                      ? const Color(0xFF848282)
                      : AppColors.primaryBlue,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}