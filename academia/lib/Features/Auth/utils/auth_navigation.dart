import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:academia/Features/Auth/models/auth_user_model.dart';

/// Routes a logged-in user to their role's home screen.
void navigateToRoleHome(AuthUserModel user) {
  switch (user.role.toLowerCase().trim()) {
    case 'student':
      Get.offAllNamed('/app', arguments: user);
      break;
    case 'professor':
      Get.offAllNamed('/professorApp', arguments: user);
      break;
    case 'admin':
      Get.offAllNamed('/Dashboard', arguments: user);
      break;
    default:
      Get.snackbar(
        'Role Error',
        'Unauthorized role: ${user.role}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        margin: const EdgeInsets.all(15),
      );
      Get.offAllNamed('/login');
  }
}
