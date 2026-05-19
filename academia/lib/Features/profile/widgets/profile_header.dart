import 'package:academia/Core/utilities/colors.dart';
import 'package:academia/Features/profile/controllers/profile_controller.dart';
import 'package:academia/Features/profile/screens/profile_edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../models/student_model.dart';

class ProfileHeader extends StatelessWidget {
  final StudentModel student;

  const ProfileHeader({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final initials = student.name
        .split(' ')
        .take(2)
        .map((e) => e[0])
        .join()
        .toUpperCase();

    const double avatarRadius = 46.0; // total avatar size = 92
    const double bannerExtraHeight = 120.0; // extra space in banner above avatar

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ── Dark blue banner ──────────────────────────────────────────────
        Container(
          width: double.infinity,
          // Extra bottom padding = avatarRadius so the banner ends at avatar center
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            bottom: avatarRadius + bannerExtraHeight,
          ),
          decoration: const BoxDecoration(
            color:AppColors.primaryBlue,
          ),
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: SvgPicture.asset(
                      'lib/assets/Icons/notification.svg',
                      width: 26,
                      height: 26,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: SvgPicture.asset(
                      'lib/assets/Icons/profileedit.svg',
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    onPressed: () {
                      Get.to(() => const ProfileEditScreen());
                    },
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── White section below the banner ───────────────────────────────
        Padding(
          // Push white area down to where banner ends (minus avatarRadius overlap)
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8 + bannerExtraHeight + avatarRadius,
          ),
          child: Container(
            width: double.infinity,
            color: const Color(0xFFF5F6FA),
            padding: EdgeInsets.only(
              top: avatarRadius + 12, // space for the overlapping avatar
              bottom: 20,
            ),
            child: Column(
              children: [
                // Name
                Text(
                  student.name,
                  style: const TextStyle(
                    color: Color(0xFF1A1A2E),
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                // Tags row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _InfoTag(label: 'ID: ${student.id}'),
                    const SizedBox(width: 8),
                    _InfoTag(label: student.level),
                    const SizedBox(width: 8),
                    _InfoTag(label: student.faculty),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ── Avatar — centered, overlapping the boundary ───────────────────
        Positioned(
          left: 0,
          right: 0,
          // Place avatar center exactly at the banner/white boundary
          top: MediaQuery.of(context).padding.top + 8 + bannerExtraHeight,
          child: Center(
            child: Container(
              width: avatarRadius * 2,
              height: avatarRadius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryBlue,
                border: Border.all(
                  color: const Color(0xFFE8B400),
                  width: 3.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Obx(() {
                  final url = Get.find<ProfileController>().avatarUrl.value;
                  return CircleAvatar(
                    radius: avatarRadius - 3.5,
                    backgroundColor: AppColors.primaryBlue,
                    backgroundImage: url != null ? NetworkImage(url) : null,
                    child: url == null
                        ? Text(
                            initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          )
                        : null,
                  );
                }),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoTag extends StatelessWidget {
  final String label;
  const _InfoTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightblue,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDDDDDD)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}