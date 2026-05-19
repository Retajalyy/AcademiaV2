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

   // if (session != null) {
    //  Get.offAllNamed('/app');      // Already logged in → go to BottomBar
   // } else {
      Get.offAllNamed('/login');    // Not logged in → go to Login
   // }
  }
}