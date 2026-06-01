import 'package:flutter/material.dart';
import '../../../core/utilities/colors.dart';

class AppDropdownField extends StatelessWidget {
  final String label;
  final String hint;
  final List<String> items;
  final String? value;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  const AppDropdownField({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: enabled
                  ? Colors.grey.shade300
                  : Colors.grey.shade200,
            ),
            borderRadius: BorderRadius.circular(10),
            color:
                enabled ? Colors.grey.shade50 : Colors.grey.shade100,
          ),
          child: IgnorePointer(
            ignoring: !enabled,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                borderRadius: BorderRadius.circular(10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 2),
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: enabled
                      ? AppColors.primaryBlue
                      : Colors.grey.shade400,
                ),
                hint: Text(
                  hint,
                  style: TextStyle(
                      color: Colors.grey.shade400, fontSize: 17),
                ),
                items: items
                    .map((item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item,
                              style: const TextStyle(fontSize: 17)),
                        ))
                    .toList(),
                onChanged: enabled ? onChanged : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}