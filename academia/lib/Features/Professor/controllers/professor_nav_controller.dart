import 'package:get/get.dart';

class ProfessorNavController extends GetxController {
  var currentIndex = 0.obs;

  void goTo(int index) => currentIndex.value = index;
}
