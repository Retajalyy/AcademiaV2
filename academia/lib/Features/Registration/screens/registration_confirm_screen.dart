import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../controllers/registration_controller.dart';
import '../models/registration_model.dart';
import '../widgets/registration_done.dart';

class RegistrationConfirmScreen extends StatelessWidget {
  const RegistrationConfirmScreen({super.key});

  String _abbr(String label) {
    final parts = label.trim().split(' ');
    return parts.length > 1 ? parts.last : label.substring(0, 2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<RegistrationController>();
    final group = ctrl.selectedGroup;
    if (group == null) {
      // Defer navigation — popping during build triggers
      // "setState()/markNeedsBuild() called during build" on the
      // previous route's Obx.
      WidgetsBinding.instance.addPostFrameCallback((_) => Get.back());
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: AppColors.babyblue,
      body: Column(
        children: [
          _Header(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              children: [
                _GroupCard(group: group, abbr: _abbr(group.label)),
                const SizedBox(height: 20),
                const _SectionLabel('COURSES INCLUDED'),
                const SizedBox(height: 12),
                ...group.lectures.map((lec) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ConfirmCourseCard(lec: lec),
                    )),
                const SizedBox(height: 8),
                _WarningBox(),
                const SizedBox(height: 24),
                _ConfirmButton(ctrl: ctrl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryBlue,
      padding: const EdgeInsets.fromLTRB(16, 52, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: Get.back,
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 22),
              ),
              const Icon(Icons.notifications_none_rounded,
                  color: Colors.white, size: 24),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Registration',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Enroll in and manage your courses',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

// ── Group Card ────────────────────────────────────────────────────────────────

class _GroupCard extends StatelessWidget {
  final CourseGroup group;
  final String abbr;
  const _GroupCard({required this.group, required this.abbr});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF0C4D83),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFDEDEDE), width: 2),
            ),
            child: Center(
              child: Text(
                abbr,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFFFC258),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                group.label,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${group.lectures.length} Courses · ${group.creditHours} Credits',
                style: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF9CA3AF),
          letterSpacing: 0.8,
        ),
      );
}

// ── Course Card ───────────────────────────────────────────────────────────────

class _ConfirmCourseCard extends StatelessWidget {
  final CourseLecture lec;
  const _ConfirmCourseCard({required this.lec});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: AppColors.primaryBlue),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lec.courseName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.lightblue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${lec.creditHours} credits',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _DetailRow(
                      icon: Icons.menu_book_rounded,
                      text: 'Lecture: ${lec.day} ${lec.timeFrom} - ${lec.timeTo}'
                          '${lec.room != null ? ' . ${lec.room}' : ''}',
                    ),
                    if (lec.sectionDay != null) ...[
                      const SizedBox(height: 6),
                      _DetailRow(
                        icon: Icons.edit_note_rounded,
                        text: 'Section: ${lec.sectionDay}'
                            '${lec.sectionTime != null ? ' ${lec.sectionTime}' : ''}'
                            '${lec.sectionRoom != null ? ' . ${lec.sectionRoom}' : ''}',
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _DetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF9CA3AF)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ),
        ],
      );
}

// ── Warning Box ───────────────────────────────────────────────────────────────

class _WarningBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber_rounded,
                size: 20, color: Color(0xFFD97706)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Once confirmed, registration cannot be changed without approval from your academic advisor.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF92400E),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
}

// ── Confirm Button ────────────────────────────────────────────────────────────

class _ConfirmButton extends StatelessWidget {
  final RegistrationController ctrl;
  const _ConfirmButton({required this.ctrl});

  Future<void> _submit() async {
    await ctrl.confirmRegistration();
    if (ctrl.registrationState.value == RegistrationState.done) {
      Get.off(() => Scaffold(
            backgroundColor: AppColors.babyblue,
            body: RegistrationDoneWidget(
              groupLabel:    ctrl.selectedGroup?.label ?? '',
              semesterLabel: ctrl.semesterInfo.value?.semester ?? '',
            ),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: ctrl.isSubmitting.value ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.lightblue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: ctrl.isSubmitting.value
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                : const Text(
                    'Confirm Registration',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
          ),
        ));
  }
}
