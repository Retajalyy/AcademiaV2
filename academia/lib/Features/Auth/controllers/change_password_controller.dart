import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/auth_user_model.dart';
import '../services/auth_service.dart';
import '../utils/auth_navigation.dart';

class ChangePasswordController extends GetxController {
  final AuthService _authService = AuthService();

  final newPasswordCtrl     = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();
  final formKey             = GlobalKey<FormState>();

  final obscureNewPassword     = true.obs;
  final obscureConfirmPassword = true.obs;
  final isLoading               = false.obs;
  final errorMessage            = ''.obs;

  late AuthUserModel _user;

  @override
  void onInit() {
    super.onInit();
    _user = Get.arguments as AuthUserModel;
  }

  void toggleNewPasswordVisibility() => obscureNewPassword.toggle();
  void toggleConfirmPasswordVisibility() => obscureConfirmPassword.toggle();

  String? validateNewPassword(String? value) {
    if (value == null || value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value != newPasswordCtrl.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _authService.changePassword(newPasswordCtrl.text.trim());
      navigateToRoleHome(_user.copyWith(mustChangePassword: false));
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      errorMessage.value = msg;
      Get.snackbar(
        'Error',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        margin: const EdgeInsets.all(15),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    newPasswordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.onClose();
  }
}
