import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../controllers/professor_profile_controller.dart';
import '../../Auth/utils/sign_out.dart';

class ProfessorProfileScreen extends StatelessWidget {
  const ProfessorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ProfessorProfileController());

    return Scaffold(
      backgroundColor: AppColors.babyblue,
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AvatarHeader(c: c),
              const SizedBox(height: 16),
              _InfoNotice(),
              const SizedBox(height: 16),
              _UniversityInfoSection(c: c),
              const SizedBox(height: 16),
              _PersonalInfoSection(c: c),
              const SizedBox(height: 28),
              _SaveButton(c: c),
              const SizedBox(height: 12),
              const _LogoutButton(),
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }
}

// ── Avatar Header ─────────────────────────────────────────────────────────────

class _AvatarHeader extends StatelessWidget {
  final ProfessorProfileController c;
  const _AvatarHeader({required this.c});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(16, top + 16, 16, 28),
      color: AppColors.primaryBlue,
      child: Column(
        children: [
          // Avatar with camera overlay
          Obx(() => Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryYellow,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: ClipOval(
                      child: c.avatarUrl.value != null
                          ? Image.network(
                              c.avatarUrl.value!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Center(
                                child: Text(
                                  c.avatarInitials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                c.avatarInitials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.primaryBlue, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        size: 14,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              )),
          const SizedBox(height: 10),
          const Text(
            'Tap to change photo',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ── Info Notice ───────────────────────────────────────────────────────────────

class _InfoNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F0FE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline_rounded,
                color: Color(0xFF2468A0), size: 18),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Name, Instructor ID, Department, Academic Role, and University email are set by the university and cannot be edited.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF2468A0),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── University Info Section ───────────────────────────────────────────────────

class _UniversityInfoSection extends StatelessWidget {
  final ProfessorProfileController c;
  const _UniversityInfoSection({required this.c});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('UNIVERSITY INFO'),
          const SizedBox(height: 10),
          Container(
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
            child: Obx(() => Column(
                  children: [
                    _ReadOnlyField(
                      label: 'Full name',
                      value: c.fullName.value,
                      icon: Icons.person_outline,
                      isFirst: true,
                    ),
                    _divider(),
                    _ReadOnlyField(
                      label: 'Instructor ID',
                      value: c.instructorId.value,
                      icon: Icons.badge_outlined,
                    ),
                    _divider(),
                    _ReadOnlyField(
                      label: 'Department',
                      value: c.department.value.isNotEmpty
                          ? c.department.value
                          : '—',
                      icon: Icons.school_outlined,
                    ),
                    _divider(),
                    _ReadOnlyField(
                      label: 'Academic Role',
                      value: c.academicRole.value.isNotEmpty
                          ? c.academicRole.value
                          : '—',
                      icon: Icons.work_outline_rounded,
                    ),
                    _divider(),
                    _ReadOnlyField(
                      label: 'University email',
                      value: c.universityEmail.value,
                      icon: Icons.email_outlined,
                      isLast: true,
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}

// ── Personal Info Section ─────────────────────────────────────────────────────

class _PersonalInfoSection extends StatelessWidget {
  final ProfessorProfileController c;
  const _PersonalInfoSection({required this.c});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('PERSONAL INFO'),
          const SizedBox(height: 10),
          Container(
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
            child: Column(
              children: [
                _EditableField(
                  label: 'Phone number',
                  controller: c.phoneCtrl,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  isFirst: true,
                ),
                _divider(),
                _EditableField(
                  label: 'Personal email',
                  controller: c.personalEmailCtrl,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Save Button ───────────────────────────────────────────────────────────────

class _SaveButton extends StatelessWidget {
  final ProfessorProfileController c;
  const _SaveButton({required this.c});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() => SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: c.isSaving.value ? null : c.save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primaryBlue.withValues(alpha: 0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: c.isSaving.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          )),
    );
  }
}

// ── Logout Button ─────────────────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton.icon(
          onPressed: confirmSignOut,
          icon: const Icon(Icons.logout, color: Colors.red),
          label: const Text(
            'Sign Out',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Shared Widgets ────────────────────────────────────────────────────────────

Widget _sectionLabel(String label) => Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade500,
        letterSpacing: 0.8,
      ),
    );

Widget _divider() => const Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: Color(0xFFF0F0F0),
    );

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isFirst;
  final bool isLast;

  const _ReadOnlyField({
    required this.label,
    required this.value,
    required this.icon,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        isFirst ? 14 : 10,
        16,
        isLast ? 14 : 10,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : '—',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1A2A4A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.lock_outline_rounded,
              size: 16, color: Colors.grey.shade400),
        ],
      ),
    );
  }
}

class _EditableField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType keyboardType;
  final bool isFirst;
  final bool isLast;

  const _EditableField({
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        isFirst ? 10 : 6,
        16,
        isLast ? 10 : 6,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1A2A4A),
              ),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
