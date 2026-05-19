// lib/Features/plan_admin/widgets/Faculty_selection.dart

import 'package:flutter/material.dart';
import 'package:academia/Core/utilities/colors.dart';

class FacultySelectionWidget extends StatefulWidget {
  final VoidCallback onFacultySelected;

  const FacultySelectionWidget({
    super.key,
    required this.onFacultySelected,
  });

  @override
  State<FacultySelectionWidget> createState() =>
      _FacultySelectionWidgetState();
}

class _FacultySelectionWidgetState extends State<FacultySelectionWidget> {
  int? _selectedIndex;

  final List<String> _faculties = [
    'Computers & Information',
    'Business Administration',
    'Languages & Translation',
  ];

  final List<IconData> _icons = [
    Icons.computer,
    Icons.analytics_outlined,
    Icons.language_outlined,
  ];

  void _onFacultyTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.onFacultySelected();
  }

  Widget _buildSelectionCircle(bool isSelected) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.accentAI : Colors.grey.shade300,
          width: isSelected ? 4 : 1,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentProgramming1,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildIconContainer(IconData icon) {
    return Container(
      width: 39,
      height: 39,
      decoration: BoxDecoration(
        color: const Color(0XFFDDEDFA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: AppColors.accentProgramming1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            "SELECT FACULTY",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.smalltext,
            ),
          ),
        ),

        Column(
          children: List.generate(_faculties.length, (index) {
            final isSelected = _selectedIndex == index;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: InkWell(
                onTap: () => _onFacultyTap(index),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildIconContainer(_icons[index]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _faculties[index],
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.accentProgramming1,
                          ),
                        ),
                      ),
                      _buildSelectionCircle(isSelected),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}