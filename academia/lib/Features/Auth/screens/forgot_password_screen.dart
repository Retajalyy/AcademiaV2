import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Controller ────────────────────────────────────────────────────────────────

class ForgotPasswordController extends GetxController {
  final _db = Supabase.instance.client;

  final nameCtrl      = TextEditingController();
  final studentIdCtrl = TextEditingController();
  final formKey       = GlobalKey<FormState>();
  final isLoading     = false.obs;
  final submitted     = false.obs;

  Future<void> sendRequest() async {
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;
    try {
      await _db.from('password_reset_requests').insert({
        'full_name':  nameCtrl.text.trim(),
        'student_id': studentIdCtrl.text.trim(),
        'status':     'pending',
      });
      submitted.value = true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send request. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    studentIdCtrl.dispose();
    super.onClose();
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ForgotPasswordController());

    return Scaffold(
      backgroundColor: const Color(0xFF1A2B6B),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back to Login
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
              child: TextButton.icon(
                onPressed: Get.back,
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white70, size: 16),
                label: const Text(
                  'Back to Login',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                child: Obx(() => c.submitted.value
                    ? _SuccessView()
                    : _FormView(c: c)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Form View ─────────────────────────────────────────────────────────────────

class _FormView extends StatelessWidget {
  final ForgotPasswordController c;
  const _FormView({required this.c});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: c.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lock icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white38, width: 2),
                color: Colors.white.withValues(alpha: 0.08),
              ),
              child: const Icon(Icons.lock_outline_rounded,
                  color: Colors.white70, size: 38),
            ),
          ),

          const SizedBox(height: 24),

          // Title
          const Center(
            child: Text(
              'Forgot Password?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Center(
            child: Text(
              'Password resets are handled by the\nuniversity\'s IT office.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Instructions card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF444444),
                    height: 1.6),
                children: [
                  TextSpan(
                      text:
                          'To reset your account password, fill in your '),
                  TextSpan(
                    text: 'full name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' and '),
                  TextSpan(
                    text: 'student ID',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                      text:
                          ' below. Your new password will be sent to your registered university email.'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Full Name field
          _FieldLabel('Full Name'),
          const SizedBox(height: 6),
          _InputField(
            controller: c.nameCtrl,
            hint: 'Enter your full name',
            icon: Icons.person_outline_rounded,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Full name is required' : null,
          ),

          const SizedBox(height: 16),

          // Student ID field
          _FieldLabel('Student ID'),
          const SizedBox(height: 6),
          _InputField(
            controller: c.studentIdCtrl,
            hint: 'Enter your student ID',
            icon: Icons.badge_outlined,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Student ID is required' : null,
          ),

          const SizedBox(height: 32),

          // Send button
          Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      c.isLoading.value ? null : c.sendRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    disabledBackgroundColor:
                        Colors.white.withValues(alpha: 0.4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: c.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Color(0xFF1A2B6B),
                          ),
                        )
                      : const Text(
                          'Send Reset Request',
                          style: TextStyle(
                            color: Color(0xFF1A2B6B),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              )),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.8),
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final String? Function(String?) validator;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
        prefixIcon: Icon(icon, color: Colors.white54, size: 20),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white54),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
    );
  }
}

// ── Success View ──────────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 60),

        Center(
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.1),
              border: Border.all(color: Colors.greenAccent, width: 2),
            ),
            child: const Icon(Icons.check_rounded,
                color: Colors.greenAccent, size: 44),
          ),
        ),

        const SizedBox(height: 28),

        const Text(
          'Request Sent!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          'Your password reset request has been\nforwarded to the admin.\nYou will receive your new password\nvia your university email.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.65),
            fontSize: 14,
            height: 1.6,
          ),
        ),

        const SizedBox(height: 48),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: Get.back,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text(
              'Back to Login',
              style: TextStyle(
                color: Color(0xFF1A2B6B),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
