import 'package:flutter/material.dart';
import 'package:academia/Core/utilities/colors.dart';
import 'package:get/get.dart';

import '../controllers/change_password_controller.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class ChangePasswordScreen extends StatelessWidget {
  ChangePasswordScreen({super.key});

  final ChangePasswordController controller =
      Get.put(ChangePasswordController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.primaryBlue,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Center(
                  child: Container(
                    width: width * 0.3,
                    height: width * 0.3,
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
                    child: Icon(
                      Icons.lock_reset_rounded,
                      size: width * 0.15,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 6,
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
                      key: controller.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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

                          Text(
                            "Set a new password",
                            style: TextStyle(
                              fontSize: width * 0.055,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),

                          SizedBox(height: height * 0.008),

                          Text(
                            "For your security, you must set a new password before continuing.",
                            style: TextStyle(
                              fontSize: width * 0.04,
                              color: Colors.grey.shade600,
                            ),
                          ),

                          Obx(() {
                            if (controller.errorMessage.value.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Text(
                                controller.errorMessage.value,
                                style: const TextStyle(
                                    color: Colors.red, fontSize: 13),
                              ),
                            );
                          }),

                          SizedBox(height: height * 0.02),

                          Obx(() {
                            return CustomTextField(
                              controller: controller.newPasswordCtrl,
                              hint: "New password",
                              label: "New Password",
                              iconPath: "lib/assets/Icons/password.svg",
                              isPassword: controller.obscureNewPassword.value,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.obscureNewPassword.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppColors.primaryBlue,
                                ),
                                onPressed:
                                    controller.toggleNewPasswordVisibility,
                              ),
                              validator: controller.validateNewPassword,
                            );
                          }),

                          SizedBox(height: height * 0.02),

                          Obx(() {
                            return CustomTextField(
                              controller: controller.confirmPasswordCtrl,
                              hint: "Confirm new password",
                              label: "Confirm Password",
                              iconPath: "lib/assets/Icons/password.svg",
                              isPassword:
                                  controller.obscureConfirmPassword.value,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.obscureConfirmPassword.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppColors.primaryBlue,
                                ),
                                onPressed: controller
                                    .toggleConfirmPasswordVisibility,
                              ),
                              validator: controller.validateConfirmPassword,
                            );
                          }),

                          SizedBox(height: height * 0.03),

                          Obx(() {
                            return SizedBox(
                              width: double.infinity,
                              child: PrimaryButton(
                                text: controller.isLoading.value
                                    ? "Updating..."
                                    : "Update Password",
                                onPressed: controller.isLoading.value
                                    ? null
                                    : controller.submit,
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
      ),
    );
  }
}
