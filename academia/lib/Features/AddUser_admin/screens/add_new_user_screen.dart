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
        top: false,
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
                    const Text('SELECT TYPE',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6B7280),
                            letterSpacing: 0.5)),
                    const SizedBox(height: 12),
                    Obx(() => Row(
                      children: [
                        _TypeCard(
                            type:     UserType.student,
                            label:    'Student',
                            icon:     Icons.school_outlined,
                            selected: c.selectedType.value == UserType.student,
                            onTap:    () => c.selectType(UserType.student)),
                        const SizedBox(width: 10),
                        _TypeCard(
                            type:     UserType.professor,
                            label:    'Professor',
                            icon:     Icons.cast_for_education_outlined,
                            selected: c.selectedType.value == UserType.professor,
                            onTap:    () => c.selectType(UserType.professor)),
                        const SizedBox(width: 10),
                        _TypeCard(
                            type:     UserType.admin,
                            label:    'Admin',
                            icon:     Icons.admin_panel_settings_outlined,
                            selected: c.selectedType.value == UserType.admin,
                            onTap:    () => c.selectType(UserType.admin)),
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
      padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 14, 16, 20),
      color: AppColors.primaryBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chevron_left_rounded,
                    color: Colors.white70, size: 22),
                Text('Dashboard',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text('Add New User',
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
          const SizedBox(height: 4),
          const Text('Create accounts for all user types',
              style: TextStyle(
                  fontSize: 17,
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
  final bool         selected;
  final VoidCallback onTap;
  const _TypeCard(
      {required this.type, required this.label,
       required this.icon, required this.selected, required this.onTap});

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
              color: selected
                  ? AppColors.secondaryYellow
                  : const Color(0xFFE5E7EB),
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [BoxShadow(
                    color: AppColors.secondaryYellow.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2))]
                : [],
          ),
          child: Column(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primaryBlue
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon,
                    color: selected ? Colors.white : const Color(0xFF9CA3AF),
                    size: 24),
              ),
              const SizedBox(height: 8),
              Text(label,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? AppColors.primaryBlue
                          : const Color(0xFF6B7280))),
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
                fontSize: 15,
                color: AppColors.primaryBlue,
                height: 1.6),
          ),
        ),

        const SizedBox(height: 20),

        // File picker button
        GestureDetector(
          onTap: c.pickCsvFile,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFD1D5DB),
                width: 1.5,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.lightblue,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.upload_file_rounded,
                    color: AppColors.primaryBlue,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Tap to select CSV file',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue)),
                const SizedBox(height: 4),
                const Text('Supports .csv files',
                    style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF9CA3AF))),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Selected file name
        Obx(() {
          if (c.csvFileName.value.isEmpty) return const SizedBox.shrink();
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded,
                    color: Colors.green, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(c.csvFileName.value,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF065F46)),
                      overflow: TextOverflow.ellipsis),
                ),
                GestureDetector(
                  onTap: () {
                    c.csvFileName.value = '';
                    c.csvContent.value = '';
                    c.csvResultMsg.value = '';
                  },
                  child: const Icon(Icons.close_rounded,
                      color: Colors.green, size: 18),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 12),

        // Result message
        Obx(() {
          if (c.csvResultMsg.value.isEmpty) return const SizedBox.shrink();
          final isSuccess = c.csvResultMsg.value.startsWith('✅');
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSuccess ? Colors.green.shade200 : Colors.red.shade200,
              ),
            ),
            child: Text(c.csvResultMsg.value,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isSuccess
                        ? Colors.green.shade800
                        : Colors.red.shade800)),
          );
        }),

        Obx(() => _SubmitButton(
          label: 'Create Students from CSV',
          isLoading: c.isLoading.value,
          onTap: c.submitStudentCsv,
        )),
      ],
    );
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
          Expanded(child: _Field(ctrl: c.fname, hint: 'First Name')),
          const SizedBox(width: 10),
          Expanded(child: _Field(ctrl: c.lname, hint: 'Last Name')),
        ]),
        const SizedBox(height: 10),
        _Field(ctrl: c.uniId, hint: 'User ID'),
        const SizedBox(height: 10),
        _Field(ctrl: c.email, hint: 'Email Address',
            keyboard: TextInputType.emailAddress),
        const SizedBox(height: 10),
        _Field(ctrl: c.phone, hint: 'Phone Number',
            keyboard: TextInputType.phone),
        const SizedBox(height: 10),
        _PasswordField(ctrl: c.password, c: c),

        const SizedBox(height: 20),
        const _SectionLabel('ACADEMIC INFORMATION'),
        const SizedBox(height: 12),

        // Faculty dropdown
        Obx(() => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFD1D5DB)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: c.faculties.any((f) => f['code'] == c.selectedFaculty.value)
                  ? c.selectedFaculty.value
                  : null,
              isExpanded: true,
              hint: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Text('Select faculty...',
                    style: TextStyle(
                        color: Color(0xFF9CA3AF), fontSize: 16)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              items: c.faculties
                  .map((f) => DropdownMenuItem(
                        value: f['code'],
                        child: Text(f['name']!,
                            style: const TextStyle(fontSize: 16)),
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
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151))),
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
        Obx(() => _SubmitButton(
          label: c.isTA.value ? 'Add Teaching Assistant' : 'Add Professor',
          isLoading: c.isLoading.value,
          onTap: c.submitProfessor,
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
          Expanded(child: _Field(ctrl: c.fname, hint: 'First Name')),
          const SizedBox(width: 10),
          Expanded(child: _Field(ctrl: c.lname, hint: 'Last Name')),
        ]),
        const SizedBox(height: 10),
        _Field(ctrl: c.uniId, hint: 'User ID'),
        const SizedBox(height: 10),
        _Field(ctrl: c.email, hint: 'Email Address',
            keyboard: TextInputType.emailAddress),
        const SizedBox(height: 10),
        _Field(ctrl: c.phone, hint: 'Phone Number',
            keyboard: TextInputType.phone),
        const SizedBox(height: 10),
        _Field(ctrl: c.jobTitle, hint: 'Job Title'),
        const SizedBox(height: 10),
        _PasswordField(ctrl: c.password, c: c),
        const SizedBox(height: 24),
        Obx(() => _SubmitButton(
          label: 'Add Admin',
          isLoading: c.isLoading.value,
          onTap: c.submitAdmin,
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
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Color(0xFF6B7280),
          letterSpacing: 0.5));
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
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText:     hint,
          hintStyle:    const TextStyle(
              color: Color(0xFF9CA3AF), fontSize: 16),
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
          style:        const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText:  'Password',
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 16),
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
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? AppColors.primaryBlue
                  : const Color(0xFFD1D5DB),
            ),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color:
                      selected ? Colors.white : const Color(0xFF374151))),
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
                      fontSize: 17, fontWeight: FontWeight.w700)),
        ),
      );
}
