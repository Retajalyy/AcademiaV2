import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utilities/colors.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final String description;
  final bool showBackButton;
  final VoidCallback? onBack;

  const CustomHeader({
    super.key,
    required this.title,
    required this.description,
    this.showBackButton = true,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primaryBlue,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Top row ───────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (showBackButton)
                    GestureDetector(
                      onTap: onBack ?? () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  SvgPicture.asset(
                    'lib/assets/Icons/notification.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                        Colors.white, BlendMode.srcIn),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Title ─────────────────────────────────────────────────
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),

              const SizedBox(height: 4),

              // ── Subtitle ──────────────────────────────────────────────
              Text(
                description,
                style: const TextStyle(
                  color: Color(0xFFDEDEDE),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
