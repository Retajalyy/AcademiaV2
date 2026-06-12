import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../Core/utilities/colors.dart';
import '../controller/registiration_controller.dart';

class CreatePlanSheet extends StatefulWidget {
  final VoidCallback? onCreated;
  const CreatePlanSheet({super.key, this.onCreated});

  @override
  State<CreatePlanSheet> createState() => _CreatePlanSheetState();
}

class _CreatePlanSheetState extends State<CreatePlanSheet> {
  final _db = Supabase.instance.client;

  // ── Dropdown selections ───────────────────────────────────────────────────
  String? _semLabel;
  String? _yearLabel;
  int?    _semNumber;
  String? _facultyCode;
  String? _majorCode;
  int     _level      = 1;
  int     _weekCount  = 16;

  DateTime? _regOpen;
  DateTime? _regClose;
  DateTime? _semStart;

  // ── DB-loaded lists ───────────────────────────────────────────────────────
  List<Map<String, String>> _faculties = [];
  List<Map<String, String>> _majors    = [];
  bool _loadingFaculties = true;
  bool _loadingMajors    = false;

  // ── Static options ────────────────────────────────────────────────────────
  static const _semLabels = ['1st Semester', '2nd Semester', 'Summer Semester'];

  static List<String> get _academicYears {
    final y = DateTime.now().year;
    return List.generate(4, (i) => '${y + i - 1}-${y + i}');
  }

  static const _semNumbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  static const _levels     = [1, 2, 3, 4];
  static const _weeks      = [12, 14, 16, 18, 20];

  @override
  void initState() {
    super.initState();
    _loadFaculties();
  }

  Future<void> _loadFaculties() async {
    try {
      final data = await _db
          .from('faculties')
          .select('code, name')
          .order('name');
      setState(() {
        _faculties = (data as List)
            .map((r) => {'code': r['code'] as String, 'name': r['name'] as String})
            .toList();
        _loadingFaculties = false;
      });
    } catch (_) {
      // Fallback
      setState(() {
        _faculties = [
          {'code': 'FCI', 'name': 'Computers and Information'},
          {'code': 'FBA', 'name': 'Business Administration'},
          {'code': 'FLT', 'name': 'Languages and Translation'},
        ];
        _loadingFaculties = false;
      });
    }
  }

  Future<void> _loadMajors(String facultyCode) async {
    setState(() { _loadingMajors = true; _majorCode = null; _majors = []; });
    try {
      final data = await _db
          .from('majors')
          .select('code, name')
          .eq('faculty_code', facultyCode)
          .order('name');
      setState(() {
        _majors = (data as List)
            .map((r) => {'code': r['code'] as String, 'name': r['name'] as String})
            .toList();
        _loadingMajors = false;
      });
    } catch (_) {
      setState(() { _loadingMajors = false; });
    }
  }

  Future<void> _pickDate({required void Function(DateTime) onPicked}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
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
    const m = ['','Jan','Feb','Mar','Apr','May','Jun',
                   'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[d.month]} ${d.day}, ${d.year}';
  }

  bool get _generalLevel => _level == 1 || _level == 2;

  bool get _isValid =>
      _semLabel != null &&
      _yearLabel != null &&
      _semNumber != null &&
      _facultyCode != null &&
      (_generalLevel || _majorCode != null) &&
      _regOpen != null &&
      _regClose != null &&
      _semStart != null;

  void _submit() {
    if (!_isValid) {
      Get.snackbar('Incomplete', 'Please fill in all fields.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    Navigator.pop(context);
    Get.find<RegistrationController>().createNewPlan({
      'semesterLabel':     _semLabel,
      'yearLabel':         _yearLabel,
      'semesterNumber':    _semNumber,
      'faculty':           _facultyCode,
      'major':             _generalLevel ? 'general' : _majorCode,
      'level':             _level,
      'registrationOpen':  _regOpen!.toIso8601String().substring(0, 10),
      'registrationClose': _regClose!.toIso8601String().substring(0, 10),
      'semesterStart':     _semStart!.toIso8601String().substring(0, 10),
      'weekCount':         _weekCount,
    }).then((_) => widget.onCreated?.call());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F8),
      body: Column(
        children: [
          // ── Blue header ────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 16, 20, 22),
            decoration: const BoxDecoration(
              color: AppColors.primaryBlue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 14),
                const Text('Create Registration Plan',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text('Set up a new semester registration window',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),

          // ── Scrollable form ────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                  16, 20, 16,
                  MediaQuery.of(context).viewInsets.bottom + 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Semester info ────────────────────────────────────
                  _SectionLabel('SEMESTER INFO'),
                  const SizedBox(height: 10),
                  _Card(children: [
                    _DropRow(
                      label: 'Semester',
                      value: _semLabel,
                      hint: 'Select semester',
                      items: _semLabels
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setState(() => _semLabel = v),
                      isFirst: true,
                    ),
                    _divider(),
                    _DropRow(
                      label: 'Academic Year',
                      value: _yearLabel,
                      hint: 'Select year',
                      items: _academicYears
                          .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                          .toList(),
                      onChanged: (v) => setState(() => _yearLabel = v),
                    ),
                    _divider(),
                    _DropRow(
                      label: 'Semester No.',
                      value: _semNumber,
                      hint: 'Select number',
                      items: _semNumbers
                          .map((n) => DropdownMenuItem(value: n, child: Text('Semester $n')))
                          .toList(),
                      onChanged: (v) => setState(() => _semNumber = v),
                    ),
                    _divider(),
                    _DropRow(
                      label: 'Total Weeks',
                      value: _weekCount,
                      hint: 'Weeks',
                      items: _weeks
                          .map((w) => DropdownMenuItem(value: w, child: Text('$w weeks')))
                          .toList(),
                      onChanged: (v) => setState(() => _weekCount = v ?? 16),
                      isLast: true,
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // ── Target audience ──────────────────────────────────
                  _SectionLabel('TARGET AUDIENCE'),
                  const SizedBox(height: 10),
                  _Card(children: [
                    _loadingFaculties
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
                        : _DropRow(
                            label: 'Faculty',
                            value: _facultyCode,
                            hint: 'Select faculty',
                            items: _faculties
                                .map((f) => DropdownMenuItem(
                                      value: f['code'],
                                      child: Text(f['name']!),
                                    ))
                                .toList(),
                            onChanged: (v) {
                              if (v == null) return;
                              setState(() {
                                _facultyCode = v;
                              });
                              _loadMajors(v);
                            },
                            isFirst: true,
                          ),
                    _divider(),
                    _DropRow(
                      label: 'Level',
                      value: _level,
                      hint: 'Level',
                      items: _levels
                          .map((l) => DropdownMenuItem(value: l, child: Text('Level $l')))
                          .toList(),
                      onChanged: (v) {
                        final newLevel = v ?? 1;
                        setState(() {
                          _level = newLevel;
                          if (newLevel == 1 || newLevel == 2) {
                            _majorCode = 'general';
                            _majors = [];
                          } else {
                            _majorCode = null;
                            if (_facultyCode != null) _loadMajors(_facultyCode!);
                          }
                        });
                      },
                      isLast: _generalLevel,
                    ),
                    if (!_generalLevel) ...[
                      _divider(),
                      _loadingMajors
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
                          : _DropRow(
                              label: 'Major',
                              value: _majorCode,
                              hint: _facultyCode == null
                                  ? 'Select faculty first'
                                  : (_majors.isEmpty ? 'No majors found' : 'Select major'),
                              items: _majors
                                  .map((m) => DropdownMenuItem(
                                        value: m['code'],
                                        child: Text(m['name']!),
                                      ))
                                  .toList(),
                              onChanged: _majors.isEmpty
                                  ? null
                                  : (v) => setState(() => _majorCode = v as String?),
                              isLast: true,
                            ),
                    ],
                  ]),

                  const SizedBox(height: 20),

                  // ── Dates ────────────────────────────────────────────
                  _SectionLabel('DATES'),
                  const SizedBox(height: 10),
                  _Card(children: [
                    _DateRow(
                      label: 'Reg. Open',
                      value: _fmtDate(_regOpen),
                      onTap: () => _pickDate(
                          onPicked: (d) => setState(() => _regOpen = d)),
                      isFirst: true,
                    ),
                    _divider(),
                    _DateRow(
                      label: 'Reg. Close',
                      value: _fmtDate(_regClose),
                      onTap: () => _pickDate(
                          onPicked: (d) => setState(() => _regClose = d)),
                    ),
                    _divider(),
                    _DateRow(
                      label: 'Sem. Start',
                      value: _fmtDate(_semStart),
                      onTap: () => _pickDate(
                          onPicked: (d) => setState(() => _semStart = d)),
                      isLast: true,
                    ),
                  ]),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isValid ? _submit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        disabledBackgroundColor:
                            AppColors.primaryBlue.withValues(alpha: 0.4),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
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
        ],
      ),
    );
  }

  Widget _divider() => const Divider(
      height: 1, color: Color(0xFFF3F4F6), indent: 14, endIndent: 14);
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Text(text,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 0.8)),
          const SizedBox(width: 8),
          const Expanded(
              child: Divider(color: Color(0xFFD1D5DB), thickness: 1)),
        ],
      );
}

// ── White card ────────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8, offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(children: children),
      );
}

// ── Dropdown row ──────────────────────────────────────────────────────────────

class _DropRow<T> extends StatelessWidget {
  final String                    label;
  final T?                        value;
  final String                    hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>?         onChanged;
  final bool                      isFirst;
  final bool                      isLast;

  const _DropRow({
    required this.label,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.isFirst = false,
    this.isLast  = false,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(
            14, isFirst ? 12 : 8, 14, isLast ? 12 : 8),
        child: Row(
          children: [
            SizedBox(
              width: 110,
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A2B4A))),
            ),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<T>(
                  value: value,
                  isExpanded: true,
                  hint: Text(hint,
                      style: const TextStyle(
                          color: Color(0xFFBDBDBD), fontSize: 14)),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF9CA3AF), size: 20),
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF1A2B4A)),
                  items: items,
                  onChanged: onChanged,
                ),
              ),
            ),
          ],
        ),
      );
}

// ── Date row ──────────────────────────────────────────────────────────────────

class _DateRow extends StatelessWidget {
  final String       label;
  final String       value;
  final VoidCallback onTap;
  final bool         isFirst;
  final bool         isLast;

  const _DateRow({
    required this.label,
    required this.value,
    required this.onTap,
    this.isFirst = false,
    this.isLast  = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              14, isFirst ? 14 : 10, 14, isLast ? 14 : 10),
          child: Row(
            children: [
              SizedBox(
                width: 110,
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1A2B4A))),
              ),
              const Icon(Icons.calendar_today_outlined,
                  size: 15, color: Color(0xFF9CA3AF)),
              const SizedBox(width: 8),
              Text(value,
                  style: TextStyle(
                      fontSize: 14,
                      color: value == 'Select date'
                          ? const Color(0xFFBDBDBD)
                          : const Color(0xFF1A2B4A))),
            ],
          ),
        ),
      );
}
