// lib/Features/plan_admin/widgets/major_selection.dart

import 'package:academia/Core/utilities/colors.dart';
import 'package:flutter/material.dart';

class MajorSelectorWidget extends StatefulWidget {
  final Function(String major) onMajorSelected;

  const MajorSelectorWidget({
    super.key,
    required this.onMajorSelected,
  });

  @override
  State<MajorSelectorWidget> createState() => _MajorSelectorWidgetState();
}

class _MajorSelectorWidgetState extends State<MajorSelectorWidget> {
  String selectedMajor = "";

  final List<String> majors = [
    "Software Engineering",
    "Cyber Security",
    "Artificial Intelligence",
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "SELECT MAJOR",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.smalltext,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 10),

        Column(
          children: majors.map((major) {
            final isSelected = selectedMajor == major;

            return InkWell(
              onTap: () {
                setState(() {
                  selectedMajor = major;
                });
                widget.onMajorSelected(major);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      major,
                      style: const TextStyle(
                        color: AppColors.accentProgramming1,
                        fontSize: 17,
                      ),
                    ),

                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? AppColors.accentProgramming1
                            : Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.accentProgramming1
                              : Colors.grey,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              size: 21,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}