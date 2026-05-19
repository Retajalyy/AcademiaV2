import 'package:flutter/material.dart';
import '../../../Core/utilities/colors.dart';

class SearchBarWidget extends StatelessWidget {
  final Function(String)? onChanged;

  const SearchBarWidget({
    super.key,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: const InputDecoration(
          icon: Icon(
            Icons.search,
            color: AppColors.disabledText,
          ),
          hintText: "Search Courses",
          border: InputBorder.none,
        ),
      ),
    );
  }
}