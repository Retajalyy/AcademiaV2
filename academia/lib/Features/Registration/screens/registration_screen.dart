import 'package:academia/Core/utilities/colors.dart';
import 'package:academia/Core/widgets/shared_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/registration_controller.dart';
import '../models/registration_model.dart';
import '../widgets/registration_app_bar.dart';
import '../widgets/registration_open.dart';
import '../widgets/registration_closed.dart';
import '../widgets/registration_not_opened.dart';
import '../widgets/registration_done.dart';
import '../widgets/registration_fees_required.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(RegistrationController());

    return Obx(() {
      if (ctrl.isLoading.value) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFF1A6EFF)),
          ),
        );
      }

      if (ctrl.registrationState.value == RegistrationState.done) {
        return Scaffold(
          backgroundColor: const Color(0xFFF1F4FC),
          body: RegistrationDoneWidget(
            groupLabel:    ctrl.selectedGroup?.label ?? '',
            semesterLabel: ctrl.semesterInfo.value?.semester ?? '',
          ),
        );
      }

      return Scaffold(
        backgroundColor: AppColors.babyblue,
        appBar: const RegistrationAppBar(),
        bottomNavigationBar: const SharedBottomNav(),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: _buildBody(ctrl.registrationState.value),
        ),
      );
    });
  }

  Widget _buildBody(RegistrationState state) {
    switch (state) {
      case RegistrationState.open:
        return const RegistrationOpenWidget();
      case RegistrationState.closed:
        return const RegistrationClosedWidget();
      case RegistrationState.notOpenedYet:
        return const RegistrationNotOpenedWidget();
      case RegistrationState.done:
        return const SizedBox.shrink();
      case RegistrationState.feesRequired:
        return const RegistrationFeesRequiredWidget();
    }
  }
}
