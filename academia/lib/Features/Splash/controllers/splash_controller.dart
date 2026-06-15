import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:academia/Features/Auth/models/auth_user_model.dart';
import 'package:academia/Features/Auth/utils/auth_navigation.dart';

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

    // Session exists — fetch profile and route accordingly
    try {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('id, uni_id, fname, lname, role, email, avatar_url, must_change_password')
          .eq('id', session.user.id)
          .single();

      final user = AuthUserModel.fromMap(profile);

      if (user.mustChangePassword) {
        Get.offAllNamed('/changePassword', arguments: user);
        return;
      }

      navigateToRoleHome(user);
    } catch (_) {
      // If profile fetch fails, fall back to login
      Get.offAllNamed('/login');
    }
  }
}
