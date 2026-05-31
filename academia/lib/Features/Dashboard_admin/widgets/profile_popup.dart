import 'package:academia/Features/AccountSettings_admin/screens/AccountSettingScreen.dart';
import 'package:academia/Features/Auth/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';

class ProfilePopup extends StatelessWidget {
  const ProfilePopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 290,

      padding: const EdgeInsets.symmetric(vertical: 10),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

       
      ),

      child: Column(
        children: [

          ListTile(
            onTap: () => Get.to(() => const AccountSettingsScreen()),
            leading: Container(
              padding: const EdgeInsets.all(8),

              decoration: BoxDecoration(
                color: AppColors.lightblue,
                borderRadius: BorderRadius.circular(10),
              ),

              child: const Icon(
                Icons.settings_outlined,
                color: AppColors.primaryBlue,
                size: 25,
              ),
            ),

            title: const Text(
              'Account Settings',
              style: TextStyle(
                fontSize: 17,
                color: AppColors.accentProgramming1,
                fontWeight: FontWeight.bold,
              ),
            ),

            subtitle: const Text(
              'Manage your preferences',
              style: TextStyle(
               fontSize: 15,
                color: AppColors.smalltext,
                fontWeight: FontWeight.w500,
                ),
            ),

            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 14,
            ),
          ),

          const Divider(),

          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),

              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),

              child: const Icon(
                Icons.logout,
                color: AppColors.fail,
                size: 25,
              ),
            ),

            title: const Text(
              'Sign Out',
              style: TextStyle(
                fontSize: 17,
                color: AppColors.accentProgramming1,
                fontWeight: FontWeight.bold,
              ),
            ),

            subtitle: const Text(
              'Log out of your account',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.smalltext,
                fontWeight: FontWeight.w500,
              ),
            ),

            onTap: () async {
              final confirmed = await Get.dialog<bool>(
                AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Get.back(result: true),
                      child: Text(
                        'Sign Out',
                        style: TextStyle(color: Colors.red.shade600),
                      ),
                    ),
                  ],
                ),
              );
              if (confirmed != true) return;
              try {
                await AuthService().logout();
              } catch (_) {}
              Get.offAllNamed('/login');
            },
          ),

        ],
      ),
    );
  }
}