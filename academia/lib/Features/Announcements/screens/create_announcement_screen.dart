import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../Core/utilities/colors.dart';

// ── Controller ────────────────────────────────────────────────────────────────

class CreateAnnouncementController extends GetxController {
  final _db = Supabase.instance.client;

  final step           = 0.obs;   // 0=type+content, 1=audience, 2=review
  final selectedType   = 'general'.obs;
  final titleCtrl      = TextEditingController();
  final messageCtrl    = TextEditingController();
  final targetAudience = 'all'.obs;   // 'all' or a faculty code
  final targetLabel    = 'All Students'.obs;
  final faculties      = <Map<String, String>>[].obs;
  final isLoadingFac   = true.obs;
  final isSending      = false.obs;
  final formKey        = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    _loadFaculties();
  }

  Future<void> _loadFaculties() async {
    isLoadingFac.value = true;
    try {
      final data = await _db
          .from('faculties')
          .select('code, name')
          .order('name');
      faculties.value = (data as List)
          .map((f) => {
                'code': f['code'] as String,
                'name': f['name'] as String,
              })
          .toList();
    } catch (_) {
      faculties.value = [];
    } finally {
      isLoadingFac.value = false;
    }
  }

  void selectType(String t) => selectedType.value = t;

  void selectAudience(String code, String label) {
    targetAudience.value = code;
    targetLabel.value    = label;
  }

  bool validateStep0() {
    if (titleCtrl.text.trim().isEmpty) {
      Get.snackbar('Required', 'Please enter a title',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    if (messageCtrl.text.trim().isEmpty) {
      Get.snackbar('Required', 'Please enter a message',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    return true;
  }

  void next() {
    if (step.value == 0 && !validateStep0()) return;
    if (step.value < 2) step.value++;
  }

  void back() {
    if (step.value > 0) {
      step.value--;
    } else {
      Get.back();
    }
  }

  Future<void> send() async {
    isSending.value = true;
    try {
      await _db.from('announcements').insert({
        'title':       titleCtrl.text.trim(),
        'body':        messageCtrl.text.trim(),
        'type':        selectedType.value,
        'target_role': targetAudience.value,
        'created_by':  _db.auth.currentUser?.id,
      });
      Get.until((r) => r.settings.name == '/adminAnnouncements');
      Get.snackbar('Sent!', 'Announcement published successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade700,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to send: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white);
    } finally {
      isSending.value = false;
    }
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    messageCtrl.dispose();
    super.onClose();
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────

class CreateAnnouncementScreen extends StatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  State<CreateAnnouncementScreen> createState() =>
      _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  late final CreateAnnouncementController c;

  @override
  void initState() {
    super.initState();
    Get.delete<CreateAnnouncementController>(force: true);
    c = Get.put(CreateAnnouncementController());
  }

  @override
  void dispose() {
    Get.delete<CreateAnnouncementController>(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      body: SafeArea(
        child: Column(
          children: [
            _WizardHeader(c: c),
            Expanded(
              child: Obx(() {
                switch (c.step.value) {
                  case 1:  return _StepAudience(c: c);
                  case 2:  return _StepReview(c: c);
                  default: return _StepContent(c: c);
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Wizard Header (step indicator) ────────────────────────────────────────────

class _WizardHeader extends StatelessWidget {
  final CreateAnnouncementController c;
  const _WizardHeader({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: c.back,
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 20, color: Color(0xFF1A2B4A)),
              ),
              const SizedBox(width: 12),
              const Text('New Announcement',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A2B4A),
                  )),
            ],
          ),
          const SizedBox(height: 16),

          // Step dots
          Obx(() => Row(
                children: List.generate(3, (i) {
                  final done   = i < c.step.value;
                  final active = i == c.step.value;
                  return Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 4,
                            decoration: BoxDecoration(
                              color: done || active
                                  ? AppColors.primaryBlue
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        if (i < 2) const SizedBox(width: 6),
                      ],
                    ),
                  );
                }),
              )),
        ],
      ),
    );
  }
}

// ── Step 0: Type + Content ────────────────────────────────────────────────────

class _StepContent extends StatelessWidget {
  final CreateAnnouncementController c;
  const _StepContent({required this.c});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('Type'),
          const SizedBox(height: 12),

          // Type grid — Obx reads selectedType here so GetX registers the subscription
          Obx(() {
            final sel = c.selectedType.value;
            return GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.8,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _TypeChip(label: 'General', icon: Icons.campaign_outlined,
                    color: const Color(0xFF6B7280),
                    isActive: sel == 'general',
                    onTap: () => c.selectType('general')),
                _TypeChip(label: 'Urgent', icon: Icons.warning_amber_rounded,
                    color: const Color(0xFFEF4444),
                    isActive: sel == 'urgent',
                    onTap: () => c.selectType('urgent')),
                _TypeChip(label: 'Warning', icon: Icons.error_outline_rounded,
                    color: const Color(0xFFF59E0B),
                    isActive: sel == 'warning',
                    onTap: () => c.selectType('warning')),
                _TypeChip(label: 'Info', icon: Icons.info_outline_rounded,
                    color: const Color(0xFF3B82F6),
                    isActive: sel == 'info',
                    onTap: () => c.selectType('info')),
              ],
            );
          }),

          const SizedBox(height: 24),
          const _SectionLabel('Title'),
          const SizedBox(height: 8),
          _InputField(
            controller: c.titleCtrl,
            hint: "What's this about?",
            maxLines: 1,
          ),

          const SizedBox(height: 18),
          const _SectionLabel('Message'),
          const SizedBox(height: 8),
          _InputField(
            controller: c.messageCtrl,
            hint: 'Write your message here...',
            maxLines: 5,
          ),

          const SizedBox(height: 32),
          _WizardButton(label: 'Next', onTap: c.next),
          const SizedBox(height: 10),
          _WizardButton(
            label: 'Cancel',
            onTap: Get.back,
            outlined: true,
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? color : Colors.grey.shade200,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isActive ? color : Colors.grey.shade400, size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                  color: isActive ? color : const Color(0xFF6B7280),
                  fontSize: 13,
                  fontWeight:
                      isActive ? FontWeight.w700 : FontWeight.w500,
                )),
          ],
        ),
      ),
    );
  }
}

// ── Step 1: Target Audience ───────────────────────────────────────────────────

class _StepAudience extends StatelessWidget {
  final CreateAnnouncementController c;
  const _StepAudience({required this.c});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('Target Audience'),
          const SizedBox(height: 12),

          // All Students option
          Obx(() => GestureDetector(
                onTap: () => c.selectAudience('all', 'All Students'),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: c.targetAudience.value == 'all'
                          ? AppColors.primaryBlue
                          : Colors.grey.shade200,
                      width: c.targetAudience.value == 'all' ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F0FE),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.groups_outlined,
                            color: AppColors.primaryBlue, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('All Students',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A2B4A))),
                            Text('All Students from All Faculties',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      if (c.targetAudience.value == 'all')
                        const Icon(Icons.check_circle_rounded,
                            color: AppColors.primaryBlue, size: 20),
                    ],
                  ),
                ),
              )),

          const SizedBox(height: 20),

          // Faculty divider
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade300)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('Or Select Target Group',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500)),
              ),
              Expanded(child: Divider(color: Colors.grey.shade300)),
            ],
          ),

          const SizedBox(height: 16),

          // Faculty list
          Obx(() {
            if (c.isLoadingFac.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (c.faculties.isEmpty) {
              return Center(
                child: Text('No faculties found',
                    style:
                        TextStyle(color: Colors.grey.shade400, fontSize: 13)),
              );
            }
            return Column(
              children: c.faculties.map((f) {
                final code  = f['code']!;
                final name  = f['name']!;
                final active = c.targetAudience.value == code;
                return GestureDetector(
                  onTap: () => c.selectAudience(code, name),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: active
                            ? AppColors.primaryBlue
                            : Colors.grey.shade200,
                        width: active ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F4F8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              code.length > 2
                                  ? code.substring(0, 2)
                                  : code,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: AppColors.primaryBlue),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(name,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A2B4A))),
                        ),
                        if (active)
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.primaryBlue, size: 20),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }),

          const SizedBox(height: 24),
          _WizardButton(label: 'Next', onTap: c.next),
          const SizedBox(height: 10),
          _WizardButton(label: 'Back', onTap: c.back, outlined: true),
        ],
      ),
    );
  }
}

// ── Step 2: Review & Confirm ──────────────────────────────────────────────────

class _StepReview extends StatelessWidget {
  final CreateAnnouncementController c;
  const _StepReview({required this.c});

  Color _typeColor(String t) {
    switch (t) {
      case 'urgent':  return const Color(0xFFEF4444);
      case 'warning': return const Color(0xFFF59E0B);
      case 'info':    return const Color(0xFF3B82F6);
      default:        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionLabel('Review & Confirm'),
              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ReviewRow(
                      label: 'Type',
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _typeColor(c.selectedType.value)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          c.selectedType.value[0].toUpperCase() +
                              c.selectedType.value.substring(1),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _typeColor(c.selectedType.value),
                          ),
                        ),
                      ),
                    ),
                    const _ReviewDivider(),
                    _ReviewRow(
                      label: 'Title',
                      child: Flexible(
                        child: Text(
                          c.titleCtrl.text,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A2B4A)),
                        ),
                      ),
                    ),
                    const _ReviewDivider(),
                    _ReviewRow(
                      label: 'Message',
                      child: Flexible(
                        child: Text(
                          c.messageCtrl.text,
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade600),
                        ),
                      ),
                    ),
                    const _ReviewDivider(),
                    _ReviewRow(
                      label: 'Sending to',
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F0FE),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          c.targetLabel.value,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlue),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Obx(() => _WizardButton(
                    label: c.isSending.value ? 'Sending...' : 'Send',
                    onTap: c.isSending.value ? null : c.send,
                    loading: c.isSending.value,
                  )),
              const SizedBox(height: 10),
              _WizardButton(label: 'Back', onTap: c.back, outlined: true),
            ],
          )),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final Widget child;
  const _ReviewRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500)),
          ),
          child,
        ],
      ),
    );
  }
}

class _ReviewDivider extends StatelessWidget {
  const _ReviewDivider();

  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, color: Colors.grey.shade100);
}

// ── Shared Widgets ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A2B4A),
        ),
      );
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  const _InputField(
      {required this.controller,
      required this.hint,
      required this.maxLines});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A2B4A)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlue),
        ),
      ),
    );
  }
}

class _WizardButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool outlined;
  final bool loading;
  const _WizardButton(
      {required this.label,
      required this.onTap,
      this.outlined = false,
      this.loading = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: outlined
          ? OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(label,
                  style: const TextStyle(
                      color: Color(0xFF1A2B4A),
                      fontWeight: FontWeight.w600)),
            )
          : ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                disabledBackgroundColor:
                    AppColors.primaryBlue.withValues(alpha: 0.5),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
            ),
    );
  }
}
