import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../Core/utilities/colors.dart';
import '../../../Core/widgets/side_menu.dart';
import '../controller/exam_schedule_admin_controller.dart';
import '../model/exam_schedule_admin_model.dart';

class ExamScheduleAdminScreen extends StatelessWidget {
  final bool openUpload;
  const ExamScheduleAdminScreen({super.key, this.openUpload = false});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ExamScheduleAdminController>()) {
      Get.put(ExamScheduleAdminController(), permanent: true);
    }
    final c = Get.find<ExamScheduleAdminController>();

    if (openUpload) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _UploadDialog.show(context);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      drawer: const SideMenu(activeItem: 'Exam Schedule'),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(c: c),
            Expanded(
              child: Container(
                color: const Color(0xFFF0F4FA),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                      child: TextField(
                        onChanged: (v) => c.searchQuery.value = v,
                        style: const TextStyle(fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Search schedules...',
                          hintStyle: const TextStyle(
                              color: Color(0xFF9CA3AF), fontSize: 14),
                          prefixIcon: const Icon(Icons.search,
                              color: Color(0xFF9CA3AF), size: 20),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    _FacultyChips(c: c),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
                      child: Text(
                        'SCHEDULES',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6B7280),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Obx(() {
                        if (c.isLoading.value) {
                          return const Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.primaryBlue));
                        }
                        if (c.errorMsg.value.isNotEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(c.errorMsg.value,
                                    textAlign: TextAlign.center,
                                    style:
                                        const TextStyle(color: Colors.red)),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                    onPressed: c.loadData,
                                    child: const Text('Retry')),
                              ],
                            ),
                          );
                        }
                        final list = c.filteredUploads;
                        if (list.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.event_note_outlined,
                                    size: 56,
                                    color: Colors.grey.shade300),
                                const SizedBox(height: 12),
                                Text('No schedules found',
                                    style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 15)),
                              ],
                            ),
                          );
                        }
                        return ListView.builder(
                          padding:
                              const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          itemCount: list.length,
                          itemBuilder: (_, i) =>
                              _UploadCard(upload: list[i]),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _UploadDialog.show(context),
        backgroundColor: AppColors.primaryBlue,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final ExamScheduleAdminController c;
  const _Header({required this.c});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (ctx) => Container(
        color: AppColors.primaryBlue,
        padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
                const SizedBox(width: 4),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Exams Schedules',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Upload and browse exams schedules',
                      style:
                          TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() => Row(
                  children: [
                    _Tab(
                      label: 'Midterms',
                      selected: c.selectedTab.value == 0,
                      onTap: () => c.selectedTab.value = 0,
                    ),
                    _Tab(
                      label: 'Finals',
                      selected: c.selectedTab.value == 1,
                      onTap: () => c.selectedTab.value = 1,
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Tab(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected
                  ? const Color(0xFFFFC258)
                  : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color:
                selected ? const Color(0xFFFFC258) : Colors.white54,
            fontSize: 15,
            fontWeight:
                selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ── Faculty Chips ─────────────────────────────────────────────────────────────

class _FacultyChips extends StatelessWidget {
  final ExamScheduleAdminController c;
  const _FacultyChips({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() => SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              GestureDetector(
                onTap: () => c.selectedFaculty.value = '',
                child: _Chip(
                    label: 'All',
                    selected: c.selectedFaculty.value.isEmpty),
              ),
              ...c.faculties.map((f) {
                final code = f['code'] ?? '';
                final name = f['name'] ?? '';
                return GestureDetector(
                  onTap: () => c.selectedFaculty.value = code,
                  child: _Chip(
                      label: name,
                      selected: c.selectedFaculty.value == code),
                );
              }),
            ],
          ),
        ));
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  const _Chip({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppColors.primaryBlue : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected
              ? AppColors.primaryBlue
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color:
              selected ? Colors.white : const Color(0xFF6B7280),
        ),
      ),
    );
  }
}

// ── Upload Card ───────────────────────────────────────────────────────────────

class _UploadCard extends StatelessWidget {
  final ExamScheduleUpload upload;
  const _UploadCard({required this.upload});

  @override
  Widget build(BuildContext context) {
    final isMidterm = upload.examType == 'Midterm';
    final dateStr   = _fmtDate(upload.examDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dark navy top
          Container(
            decoration: const BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.only(
                topLeft:  Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        upload.facultyName.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: isMidterm
                            ? const Color(0xFFFFC258)
                            : const Color(0xFFF97316),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        upload.examType,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isMidterm
                              ? const Color(0xFF78350F)
                              : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        color: Colors.white60, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Exam date  $dateStr',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // White bottom
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DETAILS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF9CA3AF),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),
                if (upload.semester != null || upload.academicYear != null)
                  _cardDetailRow(
                    icon: Icons.school_outlined,
                    label: [
                      if (upload.semester != null) upload.semester!,
                      if (upload.academicYear != null)
                        upload.academicYear!.replaceAll('/', ' - '),
                    ].join('  ·  '),
                  ),
                if (upload.periodFrom != null || upload.periodTo != null) ...[
                  const SizedBox(height: 6),
                  _cardDetailRow(
                    icon: Icons.date_range_outlined,
                    label: _fmtPeriod(upload.periodFrom, upload.periodTo),
                  ),
                ],
                if (upload.majorName != null) ...[
                  const SizedBox(height: 6),
                  _cardDetailRow(
                    icon: Icons.menu_book_outlined,
                    label: upload.majorName!,
                  ),
                ],
                if (upload.fileUrl != null) ...[
                  const SizedBox(height: 14),
                  Divider(height: 1, color: Colors.grey.shade100),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _openUrl(upload.fileUrl!),
                          icon: const Icon(Icons.download_outlined,
                              size: 16),
                          label: const Text('Download',
                              style: TextStyle(fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryBlue,
                            side: const BorderSide(
                                color: AppColors.primaryBlue),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _openUrl(upload.fileUrl!),
                          icon: const Icon(Icons.visibility_outlined,
                              size: 16),
                          label: const Text('View File',
                              style: TextStyle(fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _fmtPeriod(String? from, String? to) {
    String fmt(String raw) {
      try {
        final d = DateTime.parse(raw);
        const m = ['','Jan','Feb','Mar','Apr','May','Jun',
                        'Jul','Aug','Sep','Oct','Nov','Dec'];
        return '${m[d.month]} ${d.day}, ${d.year}';
      } catch (_) { return raw; }
    }
    if (from != null && to != null) return '${fmt(from)} – ${fmt(to)}';
    if (from != null) return fmt(from);
    if (to   != null) return fmt(to);
    return '';
  }

  static Widget _cardDetailRow({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
        ),
      ],
    );
  }

  static Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Could not open file',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  static String _fmtDate(String raw) {
    try {
      final d = DateTime.parse(raw);
      const m = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${m[d.month]} ${d.day}, ${d.year}';
    } catch (_) {
      return raw;
    }
  }
}


// ── Unified Upload Dialog ─────────────────────────────────────────────────────

class _UploadDialog extends StatelessWidget {
  const _UploadDialog();

  static void show(BuildContext context) {
    final c = Get.find<ExamScheduleAdminController>();
    c.resetForm();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _UploadDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ExamScheduleAdminController>();
    final maxHeight = MediaQuery.of(context).size.height * 0.88;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Drag handle ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        // ── Content ─────────────────────────────────────────────────
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              24, 4, 24,
              MediaQuery.of(context).viewInsets.bottom + 32,
            ),
            child: Obx(() {
              if (c.formStep.value == 1) return _Step1Content(c: c);
              if (c.formStep.value == 2) return _Step2Content(c: c);
              return _Step3Content(c: c);
            }),
          ),
        ),
      ],
    );
  }
}

// ── Step 1 Content ────────────────────────────────────────────────────────────

class _Step1Content extends StatelessWidget {
  final ExamScheduleAdminController c;
  const _Step1Content({required this.c});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DialogHeader(
            subtitle:
                'Select the target group and upload the schedule file. Students will be notified once published.',
          ),
          const SizedBox(height: 22),
          Obx(() => _StepIndicator(currentStep: c.formStep.value)),
          const SizedBox(height: 24),

          _FieldLabel('Faculty'),
          const SizedBox(height: 6),
          Obx(() => _DropdownField<String>(
                hint: 'Select faculty...',
                value: c.formFacultyCode.value.isEmpty
                    ? null
                    : c.formFacultyCode.value,
                items: c.faculties
                    .map((f) => DropdownMenuItem(
                          value: f['code'],
                          child: Text(f['name']!,
                              style: const TextStyle(fontSize: 17)),
                        ))
                    .toList(),
                onChanged: (code) {
                  if (code == null) return;
                  c.formFacultyCode.value = code;
                  c.formFacultyName.value = c.faculties
                          .firstWhere((f) => f['code'] == code,
                              orElse: () => {})['name'] ??
                      '';
                  c.formMajorCode.value = '';
                  c.formMajorName.value = '';
                },
              )),
          const SizedBox(height: 16),

          _FieldLabel('Level'),
          const SizedBox(height: 6),
          Obx(() => _DropdownField<String>(
                hint: 'Select year...',
                value: c.formLevel.value.isEmpty
                    ? null
                    : c.formLevel.value,
                items: ['Year 1', 'Year 2', 'Year 3', 'Year 4']
                    .map((y) => DropdownMenuItem(
                          value: y,
                          child: Text(y,
                              style: const TextStyle(fontSize: 17)),
                        ))
                    .toList(),
                onChanged: (v) => c.formLevel.value = v ?? '',
              )),
          const SizedBox(height: 16),

          _FieldLabel('Major'),
          const SizedBox(height: 6),
          Obx(() => _DropdownField<String>(
                hint: 'Select major...',
                value: c.formMajorCode.value.isEmpty
                    ? null
                    : c.formMajorCode.value,
                items: c.filteredMajors
                    .map((m) => DropdownMenuItem(
                          value: m['code'],
                          child: Text(m['name']!,
                              style: const TextStyle(fontSize: 17)),
                        ))
                    .toList(),
                onChanged: (code) {
                  if (code == null) return;
                  c.formMajorCode.value = code;
                  c.formMajorName.value = c.filteredMajors
                          .firstWhere((m) => m['code'] == code,
                              orElse: () => {})['name'] ??
                      '';
                },
              )),
          const SizedBox(height: 28),

          Obx(() => _NavButton(
            label: 'Next',
            onPressed: c.isStep1Valid ? () => c.formStep.value = 2 : null,
          )),
          const SizedBox(height: 10),
          _CancelButton(c: c),
        ],
      ),
    );
  }
}

// ── Step 2 Content ────────────────────────────────────────────────────────────

class _Step2Content extends StatelessWidget {
  final ExamScheduleAdminController c;
  const _Step2Content({required this.c});

  static const _examTypes = {
    'Midterm': 'Midterm Exam',
    'Final':   'Final Exam',
    'Quiz':    'Quiz',
  };

  static List<String> get _academicYears {
    final now = DateTime.now().year;
    return List.generate(5, (i) {
      final y = now - 1 + i;
      return '$y/${y + 1}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DialogHeader(
            subtitle:
                'Select the target group and upload the results file. Students will be notified once published.',
          ),
          const SizedBox(height: 22),
          Obx(() => _StepIndicator(currentStep: c.formStep.value)),
          const SizedBox(height: 24),

          // Exam Type
          _FieldLabel('Exam Type'),
          const SizedBox(height: 6),
          Obx(() => _DropdownField<String>(
                hint: 'Select exam type...',
                value: c.formExamType.value.isEmpty
                    ? null
                    : c.formExamType.value,
                items: _examTypes.entries
                    .map((e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value,
                              style: const TextStyle(fontSize: 15)),
                        ))
                    .toList(),
                onChanged: (v) =>
                    c.formExamType.value = v ?? 'Midterm',
              )),
          const SizedBox(height: 16),

          // Semester + Academic Year
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel('Semester'),
                    const SizedBox(height: 6),
                    Obx(() => _DropdownField<String>(
                          hint: 'Select semester...',
                          value: c.formSemester.value.isEmpty
                              ? null
                              : c.formSemester.value,
                          items: ['Fall', 'Spring', 'Summer']
                              .map((s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s,
                                        style: const TextStyle(
                                            fontSize: 16)),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              c.formSemester.value = v ?? '',
                        )),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel('Academic Year'),
                    const SizedBox(height: 6),
                    Obx(() => _DropdownField<String>(
                          hint: 'Select year...',
                          value: c.formAcademicYear.value.isEmpty
                              ? null
                              : c.formAcademicYear.value,
                          items: _academicYears
                              .map((y) => DropdownMenuItem(
                                    value: y,
                                    child: Text(y,
                                        style: const TextStyle(
                                            fontSize: 15)),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              c.formAcademicYear.value = v ?? '',
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Exam Period
          _FieldLabel('Exam Period'),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('From',
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500)),
                    const SizedBox(height: 4),
                    Obx(() => _DatePickerField(
                          label: c.formattedPeriodFrom,
                          onTap: () async {
                            final d = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2035),
                            );
                            if (d != null) {
                              c.formPeriodFrom.value = d;
                            }
                          },
                        )),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('To',
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500)),
                    const SizedBox(height: 4),
                    Obx(() => _DatePickerField(
                          label: c.formattedPeriodTo,
                          onTap: () async {
                            final d = await showDatePicker(
                              context: context,
                              initialDate: c.formPeriodFrom.value ??
                                  DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2035),
                            );
                            if (d != null) {
                              c.formPeriodTo.value = d;
                            }
                          },
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          Obx(() => _NavButton(
            label: 'Next',
            onPressed: c.isStep2Valid ? () => c.formStep.value = 3 : null,
          )),
          const SizedBox(height: 10),
          _BackButton(c: c),
        ],
      ),
    );
  }
}

// ── Step 3 Content ────────────────────────────────────────────────────────────

class _Step3Content extends StatelessWidget {
  final ExamScheduleAdminController c;
  const _Step3Content({required this.c});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DialogHeader(
            subtitle:
                'Select the target group and upload the schedule file. Students will be notified once published.',
          ),
          const SizedBox(height: 22),
          Obx(() => _StepIndicator(currentStep: c.formStep.value)),
          const SizedBox(height: 24),

          _FieldLabel('Upload File'),
          const SizedBox(height: 10),

          // File area: dashed when empty, file card when picked
          Obx(() => c.pickedFileName.value.isEmpty
              ? GestureDetector(
                  onTap: c.pickFile,
                  child: _DashedBorderBox(
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 32),
                        child: Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEFF6FF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.upload_outlined,
                                  color: AppColors.primaryBlue,
                                  size: 28),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Tap to upload schedule file',
                              style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Supported formats below',
                              style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 16),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: ['XLSX', 'XLS', 'PDF']
                                  .map((fmt) => Container(
                                        margin: const EdgeInsets.only(
                                            right: 8),
                                        padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                              color: Colors.grey
                                                  .shade300),
                                        ),
                                        child: Text(fmt,
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors
                                                    .grey.shade600,
                                                fontWeight:
                                                    FontWeight.w500)),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              // ── File attached card ──
              : Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                            Icons.insert_drive_file_outlined,
                            color: AppColors.primaryBlue,
                            size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.pickedFileName.value,
                              style: const TextStyle(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(c.formattedFileSize,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: c.removeFile,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          side: BorderSide(
                              color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(8)),
                          minimumSize: Size.zero,
                          tapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Remove',
                            style: TextStyle(fontSize: 15)),
                      ),
                    ],
                  ),
                )),

          const SizedBox(height: 16),

          // ── Upload summary card ──
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'UPLOAD SUMMARY',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 12),
                Obx(() => Column(
                      children: [
                        _SummaryRow('Faculty',
                            c.formFacultyName.value.isEmpty
                                ? '—'
                                : c.formFacultyName.value),
                        _SummaryRow(
                            'Exam Type', c.formExamTypeLabel),
                        _SummaryRow(
                            'Semester', c.formattedSemester.isEmpty ? '—' : c.formattedSemester),
                        _SummaryRow('Academic Year',
                            c.formattedAcademicYear.isEmpty ? '—' : c.formattedAcademicYear),
                        _SummaryRow(
                            'Exam Period', c.formattedExamPeriod,
                            isLast: true),
                      ],
                    )),
              ],
            ),
          ),

          const SizedBox(height: 24),
          _PublishButton(c: c),
          const SizedBox(height: 10),
          _BackButton(c: c),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  const _SummaryRow(this.label, this.value, {this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 16)),
              const SizedBox(width: 16),
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
              height: 1,
              color: Colors.white.withValues(alpha: 0.15)),
      ],
    );
  }
}

// ── Dashed border ─────────────────────────────────────────────────────────────

class _DashedBorderBox extends StatelessWidget {
  final Widget child;
  const _DashedBorderBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRectPainter(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: child,
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashW  = 8.0;
    const gapW   = 5.0;
    const radius = Radius.circular(12.0);

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height), radius));

    final dash = Path();
    var dist = 0.0;
    var drawing = true;

    for (final m in path.computeMetrics()) {
      while (dist < m.length) {
        final step = drawing ? dashW : gapW;
        final next = (dist + step).clamp(0.0, m.length);
        if (drawing) {
          dash.addPath(m.extractPath(dist, next), Offset.zero);
        }
        dist   = dist + step;
        drawing = !drawing;
      }
    }
    canvas.drawPath(dash, paint);
  }

  @override
  bool shouldRepaint(_DashedRectPainter _) => false;
}

// ── Publish button (with loading state) ──────────────────────────────────────

class _PublishButton extends StatelessWidget {
  final ExamScheduleAdminController c;
  const _PublishButton({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: (c.isStep3Valid && !c.isSubmitting.value) ? c.submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                disabledBackgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: c.isSubmitting.value
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Publish',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ));
  }
}

// ── Shared dialog widgets ─────────────────────────────────────────────────────

class _DialogHeader extends StatelessWidget {
  final String subtitle;
  const _DialogHeader({required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload exam schedule',
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(subtitle,
            style:
                TextStyle(color: Colors.grey.shade600, fontSize: 17)),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const _NavButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            disabledBackgroundColor: Colors.grey.shade300,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(label,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  final ExamScheduleAdminController c;
  const _CancelButton({required this.c});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton(
          onPressed: () {
            c.resetForm();
            Navigator.of(context).pop();
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryBlue,
            side: BorderSide(color: Colors.black.withValues(alpha: 0.11)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text('Cancel',
              style:
                  TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final ExamScheduleAdminController c;
  const _BackButton({required this.c});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton(
          onPressed: () => c.formStep.value--,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryBlue,
            side: BorderSide(color: Colors.black.withValues(alpha: 0.11)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text('Back',
              style:
                  TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

// ── Step Indicator ────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepCircle(step: 1, current: currentStep),
        Expanded(
          child: Container(
            height: 3,
            color: currentStep > 1
                ? const Color(0xFFFFC258)
                : const Color(0xFFDEDEDE),
          ),
        ),
        _StepCircle(step: 2, current: currentStep),
        Expanded(
          child: Container(
            height: 3,
            color: currentStep > 2
                ? const Color(0xFFFFC258)
                : const Color(0xFFDEDEDE),
          ),
        ),
        _StepCircle(step: 3, current: currentStep),
      ],
    );
  }
}

class _StepCircle extends StatelessWidget {
  final int step;
  final int current;
  const _StepCircle({required this.step, required this.current});

  @override
  Widget build(BuildContext context) {
    final isActive = step == current;
    final isDone   = step < current;
    final isFuture = step > current;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDone || isActive
            ? const Color(0xFFFFC258)
            : const Color(0xFFDEDEDE),
      ),
      child: Center(
        child: isDone
            ? const Icon(Icons.check_rounded, color: Color(0xFF0C4D83), size: 22, weight: 700)
            : Text(
                '$step',
                style: TextStyle(
                  color: isFuture
                      ? const Color(0xFF848282)
                      : const Color(0xFF0C4D83),
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
      ),
    );
  }
}

// ── Reusable form widgets ─────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
            fontSize: 17,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500));
  }
}

class _DropdownField<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  const _DropdownField({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(hint,
                style: TextStyle(
                    color: Colors.grey.shade400, fontSize: 17)),
          ),
          items: items,
          onChanged: onChanged,
          padding: const EdgeInsets.symmetric(horizontal: 4),
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _DatePickerField({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.isEmpty ? '—' : label,
              style: TextStyle(
                fontSize: 15,
                color: label.isEmpty ? Colors.grey.shade400 : Colors.black87,
              ),
            ),
            Icon(Icons.keyboard_arrow_down,
                color: Colors.grey.shade500, size: 20),
          ],
        ),
      ),
    );
  }
}
