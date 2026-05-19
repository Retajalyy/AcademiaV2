import 'package:flutter/material.dart';
import '../../../Core/utilities/colors.dart';

class ArchitectureProgress extends StatelessWidget {
  final int currentStep;

  const ArchitectureProgress({
    super.key,
    required this.currentStep,
  });

  bool _isCompleted(int step) {
    return currentStep > step; // strictly greater = fully done
  }

  bool _isCurrent(int step) {
    return currentStep == step; // currently on this step
  }

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
    final isActive = _isCompleted(stepBefore + 1) || currentStep > stepBefore;

    return Expanded(
      child: Container(
        height: 3,
        color: isActive
            ? AppColors.secondaryYellow
            : Colors.grey.shade400,
      ),
    );
  }

  Widget _buildStep(int number) {
    final isCompleted = _isCompleted(number);
    final isCurrent = _isCurrent(number);

    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: (isCompleted || isCurrent)
            ? AppColors.secondaryYellow
            : Colors.grey.shade400,
      ),
      child: Center(
        child: isCompleted
            ? Icon(
                Icons.check,
                color: AppColors.primaryBlue,
                size: 13,
              )
            : Text(
                number.toString(),
                style: TextStyle(
                  color: isCurrent ? AppColors.primaryBlue : Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}