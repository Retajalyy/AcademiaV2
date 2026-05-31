import 'package:flutter/material.dart';
import '../../../Core/utilities/colors.dart';

class RegistrationSteps extends StatelessWidget {
  const RegistrationSteps({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Steps to create a new plan",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryBlue,
            ),
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: StepCard(
                    icon: Icons.calendar_month,
                    title: "Create Plan",
                    subtitle:
                        "Set up a new semester plan and basic details",
                  ),
                ),

                /// ARROW
                const Padding(
                  padding: EdgeInsets.only(top: 9),
                  child: Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),

                const Expanded(
                  child: StepCard(
                    icon: Icons.people_outline,
                    title: "Assign Groups",
                    subtitle:
                        "Create groups  with selected professors",
                  ),
                ),

                /// ARROW
                const Padding(
                  padding: EdgeInsets.only(top: 9),
                  child: Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),

                const Expanded(
                  child: StepCard(
                    icon: Icons.check_circle,
                    title: "Open Registration",
                    subtitle:
                        "Review and open registration for students",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StepCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const StepCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// ICON CONTAINER
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: icon == Icons.calendar_month
                ? const Color(0XFFDDEDFA)
                : icon == Icons.people_outline
                    ? const Color(0XFFFFF3DF)
                    : AppColors.lightGreen,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Icon(
            icon,
            color: icon == Icons.calendar_month
                ? AppColors.accentProgramming1
                : icon == Icons.people_outline
                    ? AppColors.assignmentColor
                    : AppColors.darkGreen,
            size: 25,
          ),
        ),

        const SizedBox(height: 10),

        /// TITLE
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),

        const SizedBox(height: 6),

        /// SUBTITLE
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 9,
            height: 1.3,
            color: AppColors.smalltext,
          ),
        ),
      ],
    );
  }
}