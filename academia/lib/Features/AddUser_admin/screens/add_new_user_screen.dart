import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../controllers/add_user_controller.dart';

class AddNewUserScreen extends StatefulWidget {
  const AddNewUserScreen({super.key});

  @override
  State<AddNewUserScreen> createState() => _AddNewUserScreenState();
}

class _AddNewUserScreenState extends State<AddNewUserScreen> {
  late final AddUserController c;

  @override
  void initState() {
    super.initState();
    c = Get.put(AddUserController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────
            _buildHeader(),

            // ── Scrollable body ───────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SELECT TYPE
                    const _SectionLabel('SELECT TYPE'),
                    const SizedBox(height: 12),
                    Obx(() => Row(
                      children: [
                        _TypeCard(
                            type:      UserType.student,
                            label:     'Student',
                            icon:      Icons.school_outlined,
                            iconColor: AppColors.primaryBlue,
                            iconBg:    const Color(0xFFDDEDFA),
                            selected:  c.selectedType.value == UserType.student,
                            onTap:     () => c.selectType(UserType.student)),
                        const SizedBox(width: 10),
                        _TypeCard(
                            type:      UserType.professor,
                            label:     'Professor',
                            icon:      Icons.cast_for_education_outlined,
                            iconColor: AppColors.assignmentColor,
                            iconBg:    const Color(0xFFFFF3E0),
                            selected:  c.selectedType.value == UserType.professor,
                            onTap:     () => c.selectType(UserType.professor)),
                        const SizedBox(width: 10),
                        _TypeCard(
                            type:      UserType.admin,
                            label:     'Admin',
                            icon:      Icons.admin_panel_settings_outlined,
                            iconColor: AppColors.darkGreen,
                            iconBg:    AppColors.lightGreen,
                            selected:  c.selectedType.value == UserType.admin,
                            onTap:     () => c.selectType(UserType.admin)),
                      ],
                    )),

                    const SizedBox(height: 24),

                    // Body based on type
                    Obx(() {
                      switch (c.selectedType.value) {
                        case UserType.student:
                          return _StudentUpload(c: c);
                        case UserType.professor:
                          return _ProfessorForm(c: c);
                        case UserType.admin:
                          return _AdminForm(c: c);
                      }
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chevron_left_rounded,
                    color: Colors.white70, size: 30),
                Text('Dashboard',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text('Add New User',
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
          const SizedBox(height: 4),
          const Text('Create accounts for all user types',
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }
}

// ── Type selector card ────────────────────────────────────────────────────────

class _TypeCard extends StatelessWidget {
  final UserType     type;
  final String       label;
  final IconData     icon;
  final Color        iconColor;
  final Color        iconBg;
  final bool         selected;
  final VoidCallback onTap;
  const _TypeCard(
      {required this.type, required this.label,
       required this.icon, required this.iconColor, required this.iconBg,
       required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? Colors.black : const Color(0xFFE5E7EB),
              width: selected ? 2 : 1,
            ),
            
          ),
          child: Column(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(height: 8),
              Text(label,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Student CSV upload ────────────────────────────────────────────────────────

class _StudentUpload extends StatelessWidget {
  final AddUserController c;
  const _StudentUpload({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasFile = c.csvFileName.value.isNotEmpty;
      final lines   = c.csvContent.value.trim().split('\n');
      final count   = hasFile ? (lines.length - 1).clamp(0, 999999) : 0;
      final sizeKb  = hasFile ? (c.csvContent.value.length / 1024).round() : 0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Format hint
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.lightblue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Upload a CSV file with the following columns:\n'
              'first_name, last_name, email, uni_id, password, faculty, major, level, phone',
              style: TextStyle(
                  fontSize: 11, color: AppColors.primaryBlue, height: 1.6),
            ),
          ),

          const SizedBox(height: 20),
          const _SectionLabel('UPLOAD FILE'),
          const SizedBox(height: 12),

          if (!hasFile)
            // ── No file: upload area with Choose File button ───────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFFD1D5DB), width: 1.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: c.pickCsvFile,
                    child: Column(
                      children: [
                        Container(
                          width: 56, height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.lightblue,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.upload_file_rounded,
                              color: AppColors.primaryBlue, size: 30),
                        ),
                        const SizedBox(height: 12),
                        const Text('Upload CSV File',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryBlue)),
                        const SizedBox(height: 4),
                        const Text('Upload a file containing student records.',
                            style: TextStyle(
                                fontSize: 11, color: Color(0xFF9CA3AF))),
                        const Text('Supported formats: .csv · .xlsx',
                            style: TextStyle(
                                fontSize: 11, color: Color(0xFF9CA3AF))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: c.pickCsvFile,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Choose File',
                          style: TextStyle(
                              color: Color(0xFF374151),
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            // ── File selected: card + import button ────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Top: icon + info + close
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    child: Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.insert_drive_file_outlined,
                              color: AppColors.primaryBlue, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.csvFileName.value,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1A2B4A)),
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              Text('$count records · $sizeKb KB',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF9CA3AF))),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            c.csvFileName.value = '';
                            c.csvContent.value  = '';
                            c.csvResultMsg.value = '';
                          },
                          child: Container(
                            width: 30, height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEEEE),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.close_rounded,
                                color: Colors.red, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Bottom blue banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 11),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(13),
                        bottomRight: Radius.circular(13),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline_rounded,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text('$count records ready to import',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Result message
            if (c.csvResultMsg.value.isNotEmpty) ...[
              const SizedBox(height: 12),
              Builder(builder: (_) {
                final isSuccess = c.csvResultMsg.value.startsWith('✅');
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSuccess
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSuccess
                          ? Colors.green.shade200
                          : Colors.red.shade200,
                    ),
                  ),
                  child: Text(c.csvResultMsg.value,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSuccess
                              ? Colors.green.shade800
                              : Colors.red.shade800)),
                );
              }),
            ],

            const SizedBox(height: 12),

            // Import button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: c.isLoading.value ? null : c.submitStudentCsv,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                icon: c.isLoading.value
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : const Icon(Icons.person_add_outlined, size: 20),
                label: const Text('Import Students',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ],
      );
    });
  }
}

// ── Professor form ────────────────────────────────────────────────────────────

class _ProfessorForm extends StatelessWidget {
  final AddUserController c;
  const _ProfessorForm({required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('PERSONAL INFORMATION'),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _LabeledField(ctrl: c.fname, label: 'First Name')),
          const SizedBox(width: 10),
          Expanded(child: _LabeledField(ctrl: c.lname, label: 'Last Name')),
        ]),
        const SizedBox(height: 12),
        _LabeledField(ctrl: c.uniId, label: 'User ID'),
        const SizedBox(height: 12),
        _LabeledField(ctrl: c.email, label: 'Email Address',
            keyboard: TextInputType.emailAddress),
        const SizedBox(height: 12),
        _LabeledField(ctrl: c.phone, label: 'Phone Number',
            keyboard: TextInputType.phone),

        const SizedBox(height: 20),
        const _SectionLabel('ACADEMIC INFORMATION'),
        const SizedBox(height: 12),

        // Faculty label + dropdown
        const Text('Faculty',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF908C8C))),
        const SizedBox(height: 8),
        Obx(() => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: const Color(0xFFD1D5DB)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: c.faculties.any((f) => f['code'] == c.selectedFaculty.value)
                  ? c.selectedFaculty.value
                  : null,
              isExpanded: true,
              hint: const Text('Select faculty...',
                  style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              items: c.faculties
                  .map((f) => DropdownMenuItem(
                        value: f['code'],
                        child: Text(f['name']!,
                            style: const TextStyle(fontSize: 14)),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) c.selectedFaculty.value = v;
              },
            ),
          ),
        )),

        const SizedBox(height: 14),

        // Role toggle
        const Text('Role',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF908C8C))),
        const SizedBox(height: 8),
        Obx(() => Row(
          children: [
            _RoleChip(
                label: 'Professor',
                selected: !c.isTA.value,
                onTap: () => c.isTA.value = false),
            const SizedBox(width: 10),
            _RoleChip(
                label: 'Teaching Assistant',
                selected: c.isTA.value,
                onTap: () => c.isTA.value = true),
          ],
        )),

        const SizedBox(height: 24),
        Obx(() => SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: c.isLoading.value ? null : c.submitProfessor,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFD1D5DB), width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: c.isLoading.value
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                        color: AppColors.primaryBlue, strokeWidth: 2.5))
                : Text(
                    c.isTA.value ? 'Add Teaching Assistant' : 'Add Professor',
                    style: const TextStyle(
                        color: AppColors.accentProgramming1,
                        fontSize: 17,
                        fontWeight: FontWeight.w700)),
          ),
        )),
      ],
    );
  }
}

// ── Admin form ────────────────────────────────────────────────────────────────

class _AdminForm extends StatelessWidget {
  final AddUserController c;
  const _AdminForm({required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('PERSONAL INFORMATION'),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _LabeledField(ctrl: c.fname, label: 'First Name')),
          const SizedBox(width: 10),
          Expanded(child: _LabeledField(ctrl: c.lname, label: 'Last Name')),
        ]),
        const SizedBox(height: 12),
        _LabeledField(ctrl: c.uniId, label: 'User ID'),
        const SizedBox(height: 12),
        _LabeledField(ctrl: c.email, label: 'Email Address',
            keyboard: TextInputType.emailAddress),
        const SizedBox(height: 12),
        _LabeledField(ctrl: c.phone, label: 'Phone Number',
            keyboard: TextInputType.phone),
        const SizedBox(height: 12),
        _LabeledField(ctrl: c.jobTitle, label: 'Job Title'),
        const SizedBox(height: 24),
        Obx(() => SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: c.isLoading.value ? null : c.submitAdmin,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFD1D5DB), width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: c.isLoading.value
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                        color: AppColors.primaryBlue, strokeWidth: 2.5))
                : const Text('Add Admin',
                    style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 17,
                        fontWeight: FontWeight.w700)),
          ),
        )),
      ],
    );
  }
}

// ── Shared small widgets ──────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Text(text,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.smalltext,
                  letterSpacing: 0.5)),
          const SizedBox(width: 10),
          const Expanded(
            child: Divider(color: Color(0xFFD1D5DB), thickness: 1),
          ),
        ],
      );
}

class _LabeledField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final TextInputType keyboard;
  const _LabeledField({
    required this.ctrl,
    required this.label,
    this.keyboard = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF908C8C))),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            keyboardType: keyboard,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1A2B4A)),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: AppColors.primaryBlue, width: 1.5),
              ),
            ),
          ),
        ],
      );
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String                hint;
  final TextInputType         keyboard;
  const _Field(
      {required this.ctrl,
       required this.hint,
       this.keyboard = TextInputType.text});

  @override
  Widget build(BuildContext context) => TextField(
        controller:  ctrl,
        keyboardType: keyboard,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText:     hint,
          hintStyle:    const TextStyle(
              color: Color(0xFF9CA3AF), fontSize: 14),
          filled:       true,
          fillColor:    Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
                color: AppColors.primaryBlue, width: 1.5),
          ),
        ),
      );
}

class _PasswordField extends StatelessWidget {
  final TextEditingController ctrl;
  final AddUserController      c;
  const _PasswordField({required this.ctrl, required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() => TextField(
          controller:   ctrl,
          obscureText:  c.obscurePassword.value,
          style:        const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText:  'Password',
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            filled:    true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                  color: AppColors.primaryBlue, width: 1.5),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                c.obscurePassword.value
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF9CA3AF),
                size: 20,
              ),
              onPressed: () => c.obscurePassword.toggle(),
            ),
          ),
        ));
  }
}

class _RoleChip extends StatelessWidget {
  final String   label;
  final bool     selected;
  final VoidCallback onTap;
  const _RoleChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryBlue : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? AppColors.primaryBlue
                  : const Color(0xFFD1D5DB),
            ),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color:
                      selected ? Colors.white : AppColors.accentProgramming1)),
        ),
      );
}

class _SubmitButton extends StatelessWidget {
  final String       label;
  final bool         isLoading;
  final VoidCallback onTap;
  const _SubmitButton(
      {required this.label, required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: isLoading ? null : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
              : Text(label,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
        ),
      );
}
