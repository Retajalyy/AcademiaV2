import 'package:get/get.dart';

class AppTabController extends GetxController {
  static AppTabController get to => Get.find();
  final currentIndex = 0.obs;
  void switchTo(int index) => currentIndex.value = index;
}
