// lib/Features/plan_admin/widgets/select_level.dart

import 'package:flutter/material.dart';
import 'package:academia/Core/utilities/colors.dart';

class LevelSelectorWidget extends StatefulWidget {
  final VoidCallback onLevelConfirmed;

  const LevelSelectorWidget({
    super.key,
    required this.onLevelConfirmed,
  });

  @override
  State<LevelSelectorWidget> createState() => _LevelSelectorWidgetState();
}

class _LevelSelectorWidgetState extends State<LevelSelectorWidget> {
  int? selectedLevel;

  void _onLevelTap(int level) {
    setState(() => selectedLevel = level);
    widget.onLevelConfirmed();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "SELECT LEVEL",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.smalltext,
          ),
        ),

        const SizedBox(height: 12),

        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: Colors.grey.shade300, width: 1.2),
          ),
          child: Row(
            children: List.generate(4, (index) {
              int level = index + 1;
              bool isSelected = selectedLevel == level;

              return Expanded(
                child: GestureDetector(
                  onTap: () => _onLevelTap(level),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.accentProgramming1
                          : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: index == 0
                            ? const Radius.circular(11)
                            : Radius.zero,
                        bottomLeft: index == 0
                            ? const Radius.circular(11)
                            : Radius.zero,
                        topRight: index == 3
                            ? const Radius.circular(9)
                            : Radius.zero,
                        bottomRight: index == 3
                            ? const Radius.circular(8)
                            : Radius.zero,
                      ),
                      border: index < 3
                          ? Border(
                              right:
                                  BorderSide(color: Colors.grey.shade300),
                            )
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "$level",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : const Color.fromRGBO(101, 137, 167, 0.76),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "YEAR $level",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : const Color.fromRGBO(101, 137, 167, 0.76),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, 8),
                          child: Container(
                            height: 4,
                            width: 55,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.accentAI
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}