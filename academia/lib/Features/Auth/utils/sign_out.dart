import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';

/// Shows a confirmation dialog and, if confirmed, signs the user out and
/// returns them to the login screen.
Future<void> confirmSignOut() async {
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
}
