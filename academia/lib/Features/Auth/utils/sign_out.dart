import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';

/// Shows a confirmation dialog and, if confirmed, signs the user out and
/// returns them to the login screen.
Future<void> confirmSignOut() async {
  final confirmed = await showCupertinoDialog<bool>(
    context: Get.context!,
    barrierDismissible: true,
    builder: (ctx) => CupertinoAlertDialog(
      title: const Text('Sign Out'),
      content: const Text('Are you sure you want to sign out?'),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Sign Out'),
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
