import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../controllers/registration_controller.dart';
import '../models/registration_model.dart';

class RegistrationOpenWidget extends StatelessWidget {
  const RegistrationOpenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<RegistrationController>();
    final w = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GroupCard(ctrl: ctrl),
        SizedBox(height: w * 0.05),
        _ScheduleSection(ctrl: ctrl),
        SizedBox(height: w * 0.05),
        _ConfirmButton(ctrl: ctrl),
        SizedBox(height: w * 0.06),
      ],
    );
  }
}

// ── Group Card ────────────────────────────────────────────────────────────────

class _GroupCard extends StatelessWidget {
  final RegistrationController ctrl;
  const _GroupCard({required this.ctrl});

  String _abbr(String label) {
    final parts = label.trim().split(' ');
    return parts.length > 1 ? parts.last : label.substring(0, 2).toUpperCase();
  }

  void _showGroupPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Obx(() {
        final groups = ctrl.availableGroups;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select a Group',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),
              ...groups.asMap().entries.map((entry) {
                final i = entry.key;
                final g = entry.value;
                final isSelected = ctrl.selectedTabIndex.value == i;
                return GestureDetector(
                  onTap: () {
                    ctrl.onTabChanged(i);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.lightblue
                          : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryBlue
                            : const Color(0xFFE5E7EB),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryBlue
                                : const Color(0xFF0F1B3D),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _abbr(g.label),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                g.label,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? AppColors.primaryBlue
                                      : const Color(0xFF111827),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${g.lectures.length} Courses · ${g.creditHours} Credits',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.primaryBlue, size: 20),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final group = ctrl.selectedGroup;
      if (group == null) return const SizedBox.shrink();
      final abbr = _abbr(group.label);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFF0F1B3D),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  abbr,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${group.lectures.length} Courses · ${group.creditHours} Credits',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _showGroupPicker(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Select',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── Schedule Section ──────────────────────────────────────────────────────────

class _ScheduleSection extends StatelessWidget {
  final RegistrationController ctrl;
  const _ScheduleSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          ),
        );
      }

      final courses = ctrl.scheduledCourses;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'LECTURES SCHEDULE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 0.8,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.lightblue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${ctrl.totalCreditHours} Credits',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...courses.map((cw) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CourseCard(courseWithWarning: cw),
              )),
        ],
      );
    });
  }
}

// ── Course Card ───────────────────────────────────────────────────────────────

class _CourseCard extends StatelessWidget {
  final CourseWithWarning courseWithWarning;
  const _CourseCard({required this.courseWithWarning});

  void _showAddDialog(BuildContext context, CourseLecture lec) {
    final ctrl = Get.find<RegistrationController>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 22),
            SizedBox(width: 8),
            Text('Add Anyway?', style: TextStyle(fontSize: 17)),
          ],
        ),
        content: Text(
          '${lec.courseName} has an unmet prerequisite.\n\n'
          '${courseWithWarning.warningMessage ?? ''}\n\n'
          'Do you want to add it anyway? Your advisor may need to approve this.',
          style: const TextStyle(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            onPressed: () {
              ctrl.addLockedCourse(lec.courseCode);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Add Anyway'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lec        = courseWithWarning.lecture;
    final hasWarning = courseWithWarning.warningMessage != null;
    final isLocked   = courseWithWarning.isLocked;

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
            // ── Colored left border ───────────────────────────────────
            Container(
              width: 4,
              color: hasWarning
                  ? const Color(0xFFEF4444)
                  : AppColors.primaryBlue,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Course name + credits + lock ──────────────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                lec.courseName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.lightblue,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${lec.creditHours} Cr',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                            if (isLocked) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.lock_outline_rounded,
                                size: 13,
                                color: Color(0xFFEF4444),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 10),

                        // ── LECTURE chip ──────────────────────────────
                        _InfoChip(
                          icon: Icons.menu_book_rounded,
                          label: 'LECTURE · ${lec.day}',
                          color: AppColors.primaryBlue,
                          bgColor: AppColors.lightblue,
                        ),
                        const SizedBox(height: 8),
                        _IconRow(
                          icon: Icons.access_time_rounded,
                          text: '${lec.timeFrom} - ${lec.timeTo}',
                        ),
                        const SizedBox(height: 4),
                        _IconRow(
                          icon: Icons.person_outline_rounded,
                          text: lec.instructor,
                        ),
                        if (lec.room != null) ...[
                          const SizedBox(height: 4),
                          _IconRow(
                            icon: Icons.location_on_outlined,
                            text: lec.room!,
                          ),
                        ],

                        // ── SECTION chip ──────────────────────────────
                        if (lec.sectionDay != null) ...[
                          const SizedBox(height: 10),
                          _InfoChip(
                            icon: Icons.edit_note_rounded,
                            label: 'SECTION · ${lec.sectionDay}',
                            color: AppColors.secondaryYellow,
                            bgColor: AppColors.LightYellow,
                          ),
                          if (lec.sectionInstructor != null) ...[
                            const SizedBox(height: 8),
                            _IconRow(
                              icon: Icons.person_outline_rounded,
                              text: lec.sectionInstructor!,
                            ),
                          ],
                          if (lec.sectionTime != null) ...[
                            const SizedBox(height: 4),
                            _IconRow(
                              icon: Icons.access_time_rounded,
                              text: lec.sectionTime!,
                            ),
                          ],
                          if (lec.sectionRoom != null) ...[
                            const SizedBox(height: 4),
                            _IconRow(
                              icon: Icons.location_on_outlined,
                              text: lec.sectionRoom!,
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),

                  // ── Warning footer ────────────────────────────────────
                  if (hasWarning)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF1F1),
                        border: Border(
                          top: BorderSide(color: Color(0xFFFFCDD2)),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              size: 13, color: Color(0xFFEF4444)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              courseWithWarning.warningMessage!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFFB91C1C),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // ── "+ Add" button — only on locked/warning cards ─────
                  if (hasWarning || isLocked)
                    Obx(() {
                      final ctrl = Get.find<RegistrationController>();
                      final added = ctrl.isCourseForceAdded(lec.courseCode);
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(0, 4, 12, 10),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: added
                                ? null
                                : () => _showAddDialog(context, lec),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: added
                                    ? const Color(0xFFE8F5E9)
                                    : AppColors.lightblue,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    added
                                        ? Icons.check_rounded
                                        : Icons.add_rounded,
                                    size: 14,
                                    color: added
                                        ? Colors.green
                                        : AppColors.primaryBlue,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    added ? 'Added' : '+ Add',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: added
                                          ? Colors.green
                                          : AppColors.primaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared small widgets ──────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 0.3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _IconRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

// ── Confirm Button ────────────────────────────────────────────────────────────

class _ConfirmButton extends StatelessWidget {
  final RegistrationController ctrl;
  const _ConfirmButton({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Obx(() => SizedBox(
          width: double.infinity,
          height: h * 0.065,
          child: ElevatedButton(
            onPressed:
                ctrl.isSubmitting.value ? null : ctrl.confirmRegistration,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.lightblue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: ctrl.isSubmitting.value
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Confirm Registration',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
          ),
        ));
  }
}
