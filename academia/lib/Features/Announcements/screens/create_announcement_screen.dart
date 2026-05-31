import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../Core/utilities/colors.dart';
import '../../../Core/widgets/Architecture_progress.dart';

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

  static void show(BuildContext context) {
    Get.delete<CreateAnnouncementController>(force: true);
    final c = Get.put(CreateAnnouncementController());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateAnnouncementSheet(c: c),
    ).whenComplete(() => Get.delete<CreateAnnouncementController>(force: true));
  }

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

// ── Bottom Sheet wrapper ──────────────────────────────────────────────────────

class _CreateAnnouncementSheet extends StatelessWidget {
  final CreateAnnouncementController c;
  const _CreateAnnouncementSheet({required this.c});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('New Announcement',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.accentProgramming1,
              )),
          const SizedBox(height: 20),

          Obx(() => ArchitectureProgress(currentStep: c.step.value + 1)),
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
                    color: AppColors.fail,
                    isActive: sel == 'urgent',
                    onTap: () => c.selectType('urgent')),
                _TypeChip(label: 'Warning', icon: Icons.error_outline_rounded,
                    color: const Color(0xFFB18334),
                    isActive: sel == 'warning',
                    onTap: () => c.selectType('warning')),
                _TypeChip(label: 'Info', icon: Icons.info_outline_rounded,
                    color: AppColors.accentProgramming1,
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
                color: isActive ? color : Colors.grey.shade400, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                  color: isActive ? color : const Color(0xFF6B7280),
                  fontSize: 15,
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

  IconData _facultyIcon(String code) {
    switch (code.toUpperCase()) {
      case 'FCI': return Icons.computer_outlined;
      case 'FBA': return Icons.bar_chart_outlined;
      case 'FLT': return Icons.chat_bubble_outline_rounded;
      default:    return Icons.school_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Target Audience',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.smalltext)),
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
                          color: AppColors.LightYellow,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.groups_outlined,
                            color: AppColors.accentAI, size: 25),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('All Students',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black)),
                            Text('All Students from All Faculties',
                                style: TextStyle(
                                    fontSize: 12, color: AppColors.smalltext)),
                          ],
                        ),
                      ),
                      c.targetAudience.value == 'all'
                          ? const Icon(Icons.check_circle_rounded,
                              color: AppColors.primaryBlue, size: 22)
                          : Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.grey.shade300, width: 1.5),
                              ),
                            ),
                    ],
                  ),
                ),
              )),

          const SizedBox(height: 20),

          Text('Or Select Target Group',
              style: TextStyle(
                  fontSize: 15,
                  color: AppColors.smalltext,
                  fontWeight: FontWeight.w500)),

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
                            color: const Color(0xFFE8F0FE),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Icon(
                            _facultyIcon(code),
                            color: AppColors.primaryBlue,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(name,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryBlue)),
                        ),
                        active
                            ? const Icon(Icons.check_circle_rounded,
                                color: AppColors.primaryBlue, size: 22)
                            : Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.grey.shade300, width: 1.5),
                                ),
                              ),
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Review & Confirm',
                        style: TextStyle(
                            color: AppColors.greytext,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 14),
                    _DarkReviewRow(
                        label: 'Type',
                        value: c.selectedType.value[0].toUpperCase() +
                            c.selectedType.value.substring(1)),
                     Divider(color: Colors.white.withOpacity(0.09), height: 20),
                    _DarkReviewRow(label: 'Title', value: c.titleCtrl.text),
                    Divider(color: Colors.white.withOpacity(0.09), height: 20),
                    _DarkReviewRow(label: 'Message', value: c.messageCtrl.text),
                   Divider(color: Colors.white.withOpacity(0.09), height: 20),
                    _DarkReviewRow(
                        label: 'Sending to', value: c.targetLabel.value),
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

class _DarkReviewRow extends StatelessWidget {
  final String label;
  final String value;
  const _DarkReviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14,
                color: AppColors.greytext,
                fontWeight: FontWeight.w500)),
        Flexible(
          child: Text(value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}

// ── Shared Widgets ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Color(0xFF908C8C),
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
      style: const TextStyle(fontSize: 14, color: Colors.black),
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
                      color: AppColors.primaryBlue,
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
