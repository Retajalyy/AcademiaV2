import 'package:academia/Features/Auth/models/auth_user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../utils/auth_navigation.dart';

class LoginController extends GetxController {
  final AuthService _authService = AuthService();

  var isLoading    = false.obs;
  var obscurePassword = true.obs;
  var rememberMe   = false.obs;
  var errorMessage = ''.obs;

  void togglePassword() => obscurePassword.toggle();
  void toggleRememberMe(bool? val) => rememberMe.value = val ?? false;

  Future<void> login(String uniId, String password) async {
    if (uniId.trim().isEmpty || password.trim().isEmpty) {
      _showError('Error', 'Please fill in all fields.');
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final AuthUserModel user = await _authService.login(
        uniId.trim(),
        password.trim(),
      );
      _navigateByRole(user);
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      errorMessage.value = msg;
      _showError('Login Failed', msg);
    } finally {
      isLoading.value = false;
    }
  }

  void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade900,
      margin: const EdgeInsets.all(15),
    );
  }

  void _navigateByRole(AuthUserModel user) {
    if (user.mustChangePassword) {
      Get.offAllNamed('/changePassword', arguments: user);
      return;
    }

    navigateToRoleHome(user);
  }
}