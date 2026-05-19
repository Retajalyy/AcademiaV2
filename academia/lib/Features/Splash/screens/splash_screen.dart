import 'package:academia/Core/utilities/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/splash_controller.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
      init: SplashController(),   // ✅ safer than Get.put inside build()
      builder: (_) => Scaffold(
        backgroundColor: AppColors.lightblue,
        body: Center(
          child: SizedBox(
            width: 300,
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [

                // background image
                Image.asset(
                  'lib/assets/Images/partA.png',
                  width: 400,
                ),

                // animated foreground
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 2000),
                  curve: Curves.easeOutCubic,
                  tween: Tween(begin: 200, end: 0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, value),
                      child: child,
                    );
                  },
                  child: Image.asset(
                    'lib/assets/Images/partB.png',
                    width: 300,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}