import 'package:flutter/material.dart';
import 'package:academia/Core/utilities/colors.dart';
import 'package:get/get.dart';

import '../controllers/login_controller.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/remember_me_row.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final LoginController controller = Get.put(LoginController());

  // Renamed to uniIdController to stay consistent with your AuthService logic
  final TextEditingController uniIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void handleLogin() {
    if (_formKey.currentState!.validate()) {
      controller.login(
        uniIdController.text.trim(),
        passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: SafeArea(
        child: Column(
          children: [
            /// 🔵 TOP LOGO
            Expanded(
              flex: 3,
              child: Center(
                child: Container(
                  width: width * 0.4,
                  height: width * 0.4,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 15,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Image.asset(
                      "lib/assets/Images/logoo.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),

            /// ⚪ FORM CONTAINER
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.06,
                  vertical: height * 0.02,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// DASH
                        Center(
                          child: Container(
                            width: width * 0.12,
                            height: 5,
                            margin: EdgeInsets.only(bottom: height * 0.02),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        /// TITLE
                        Text(
                          "Welcome back",
                          style: TextStyle(
                            fontSize: width * 0.055,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),

                        SizedBox(height: height * 0.008),

                        /// SUBTEXT
                        Text(
                          "Sign in with your University ID",
                          style: TextStyle(
                            fontSize: width * 0.04,
                            color: Colors.grey.shade600,
                          ),
                        ),

                        /// 🚨 ERROR MESSAGE DISPLAY
                        Obx(() {
                          if (controller.errorMessage.value.isEmpty) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Text(
                              controller.errorMessage.value,
                              style: const TextStyle(color: Colors.red, fontSize: 13),
                            ),
                          );
                        }),

                        SizedBox(height: height * 0.02),

                        /// UNIVERSITY ID
                        CustomTextField(
                          controller: uniIdController,
                          hint: "Enter University ID",
                          label: "University ID",
                          iconPath: "lib/assets/Icons/userlogin.svg",
                          validator: (v) =>
                              v == null || v.isEmpty ? "Please enter your University ID" : null,
                        ),

                        SizedBox(height: height * 0.02),

                        /// PASSWORD
                        Obx(() {
                          return CustomTextField(
                            controller: passwordController,
                            hint: "Password",
                            label: "Password",
                            iconPath: "lib/assets/Icons/password.svg",
                            isPassword: controller.obscurePassword.value,
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.obscurePassword.value
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.primaryBlue,
                              ),
                              onPressed: controller.togglePassword,
                            ),
                            validator: (v) => v == null || v.length < 6
                                ? "Password must be at least 6 characters"
                                : null,
                          );
                        }),

                        SizedBox(height: height * 0.01),

                        /// REMEMBER ME ROW
                        Obx(() {
                          return RememberMeRow(
                            value: controller.rememberMe.value,
                            onChanged: controller.toggleRememberMe,
                            onForgotPassword: () =>
                                Get.toNamed('/forgotPassword'),
                          );
                        }),

                        SizedBox(height: height * 0.03),

                        /// LOGIN BUTTON
                        Obx(() {
                          return SizedBox(
                            width: double.infinity,
                            child: PrimaryButton(
                              text: controller.isLoading.value
                                  ? "Verifying..."
                                  : "Sign in",
                              onPressed: controller.isLoading.value
                                  ? null
                                  : handleLogin,
                            ),
                          );
                        }),

                        SizedBox(height: height * 0.02),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}