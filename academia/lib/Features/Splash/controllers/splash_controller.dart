import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashController extends GetxController {

  @override
  void onInit() {
    super.onInit();
    navigate();
  }

  void navigate() async {
    await Future.delayed(const Duration(seconds: 3));

    final session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      Get.offAllNamed('/login');
      return;
    }

    // Session exists — fetch role and route accordingly
    try {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', session.user.id)
          .single();

      final role = (profile['role'] as String? ?? 'student').toLowerCase().trim();

      switch (role) {
        case 'admin':
          Get.offAllNamed('/Dashboard');
          break;
        case 'professor':
          Get.offAllNamed('/professorApp');
          break;
        default:
          Get.offAllNamed('/app');
      }
    } catch (_) {
      // If profile fetch fails, fall back to login
      Get.offAllNamed('/login');
    }
  }
}
