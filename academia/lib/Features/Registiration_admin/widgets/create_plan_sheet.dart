import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../controller/registiration_controller.dart';

class CreatePlanSheet extends StatefulWidget {
  const CreatePlanSheet({super.key});

  @override
  State<CreatePlanSheet> createState() => _CreatePlanSheetState();
}

class _CreatePlanSheetState extends State<CreatePlanSheet> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _semLabelCtrl  = TextEditingController();
  final _yearLabelCtrl = TextEditingController();
  final _semNumberCtrl = TextEditingController();
  final _facultyCtrl   = TextEditingController();
  final _majorCtrl     = TextEditingController();
  final _weekCtrl      = TextEditingController(text: '16');

  int    _level       = 1;
  DateTime? _regOpen;
  DateTime? _regClose;
  DateTime? _semStart;

  @override
  void dispose() {
    _semLabelCtrl.dispose();
    _yearLabelCtrl.dispose();
    _semNumberCtrl.dispose();
    _facultyCtrl.dispose();
    _majorCtrl.dispose();
    _weekCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context,
      {required void Function(DateTime) onPicked}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primaryBlue),
        ),
        child: child!,
      ),
    );
    if (picked != null) onPicked(picked);
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return 'Select date';
    const m = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${m[d.month]} ${d.day}, ${d.year}';
  }

  String _toIso(DateTime d) => d.toIso8601String().substring(0, 10);

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_regOpen == null || _regClose == null || _semStart == null) {
      Get.snackbar('Missing dates', 'Please select all three dates.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900);
      return;
    }

    Navigator.pop(context);

    Get.find<RegistrationController>().createNewPlan({
      'semesterLabel':    _semLabelCtrl.text.trim(),
      'yearLabel':        _yearLabelCtrl.text.trim(),
      'semesterNumber':   int.tryParse(_semNumberCtrl.text.trim()) ?? 1,
      'faculty':          _facultyCtrl.text.trim().toUpperCase(),
      'major':            _majorCtrl.text.trim().toUpperCase(),
      'level':            _level,
      'registrationOpen': _toIso(_regOpen!),
      'registrationClose':_toIso(_regClose!),
      'semesterStart':    _toIso(_semStart!),
      'weekCount':        int.tryParse(_weekCtrl.text.trim()) ?? 16,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text('Create Registration Plan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 20),

              // ── Semester info ────────────────────────────────────────────
              const _Label('Semester Label'),
              _Field(_semLabelCtrl, 'e.g. 2nd Semester'),
              const SizedBox(height: 12),

              const _Label('Academic Year'),
              _Field(_yearLabelCtrl, 'e.g. 2025-2026'),
              const SizedBox(height: 12),

              const _Label('Semester Number'),
              _Field(_semNumberCtrl, 'e.g. 8',
                  keyboardType: TextInputType.number),
              const SizedBox(height: 12),

              // ── Target audience ──────────────────────────────────────────
              const _Label('Faculty'),
              _Field(_facultyCtrl, 'e.g. FCI'),
              const SizedBox(height: 12),

              const _Label('Major'),
              _Field(_majorCtrl, 'e.g. SE'),
              const SizedBox(height: 12),

              const _Label('Level'),
              DropdownButtonFormField<int>(
                initialValue: _level,
                decoration: _inputDecoration('Select level'),
                items: [1, 2, 3, 4]
                    .map((l) => DropdownMenuItem(
                        value: l, child: Text('Level $l')))
                    .toList(),
                onChanged: (v) => setState(() => _level = v ?? 1),
              ),
              const SizedBox(height: 12),

              // ── Dates ────────────────────────────────────────────────────
              const _Label('Registration Open'),
              _DateTile(
                label: _fmtDate(_regOpen),
                onTap: () => _pickDate(context,
                    onPicked: (d) => setState(() => _regOpen = d)),
              ),
              const SizedBox(height: 12),

              const _Label('Registration Close'),
              _DateTile(
                label: _fmtDate(_regClose),
                onTap: () => _pickDate(context,
                    onPicked: (d) => setState(() => _regClose = d)),
              ),
              const SizedBox(height: 12),

              const _Label('Semester Start'),
              _DateTile(
                label: _fmtDate(_semStart),
                onTap: () => _pickDate(context,
                    onPicked: (d) => setState(() => _semStart = d)),
              ),
              const SizedBox(height: 12),

              const _Label('Total Weeks'),
              _Field(_weekCtrl, '16', keyboardType: TextInputType.number),
              const SizedBox(height: 24),

              // ── Submit ───────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Create Plan',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151))),
      );
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  const _Field(this.controller, this.hint,
      {this.keyboardType = TextInputType.text});

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: _inputDecoration(hint),
        validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'Required' : null,
      );
}

class _DateTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _DateTile({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD1D5DB)),
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 16, color: Color(0xFF6B7280)),
              const SizedBox(width: 10),
              Text(label,
                  style: TextStyle(
                      fontSize: 14,
                      color: label == 'Select date'
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF111827))),
            ],
          ),
        ),
      );
}

InputDecoration _inputDecoration(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
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
        borderSide:
            const BorderSide(color: AppColors.primaryBlue, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white,
    );
