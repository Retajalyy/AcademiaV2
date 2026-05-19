import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../controller/account_settings_controller.dart';
import 'package:academia/Features/Dashboard_admin/screens/Dashboard_screen.dart';
class AccountHeader extends StatelessWidget {
  final AccountSettingsController controller;
  const AccountHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 14,
        left: 16,
        right: 16,
        bottom: 18,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          /// TOP BAR
                 Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white,size: 28),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DashboardScreen(),
                    ),
                  );
                },
              ),
              const Spacer(),
              const Text(
                'Account Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),

              /// SAVE BUTTON
              Obx(() => GestureDetector(
                    onTap: controller.saveChanges,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2468A0),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.31),
                          width: 1,
                        ),
                      ),
                      child: controller.isSaving.value
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Save',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  )),
            ],
          ),

          const SizedBox(height: 24),

          /// PROFILE IMAGE
          Obx(() {
            final acc = controller.account.value;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  onTap: controller.onChangePhoto,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accentAI,
                      border: Border.all(
                        color: const Color(0xFF2468A0),
                        width: 4,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        acc?.initials ?? '??',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 35,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: -2,
                  child: GestureDetector(
                    onTap: controller.onChangePhoto,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryBlue,
                          width: 2.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: AppColors.primaryBlue,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),

          const SizedBox(height: 10),

          const Text(
            'Tap to change photo',
            style: TextStyle(
              color: Color(0xFFD9D9D9),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}