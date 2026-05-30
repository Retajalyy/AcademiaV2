import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../Core/utilities/colors.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

class PasswordResetRequest {
  final int    id;
  final String fullName;
  final String studentId;
  final String requestedAt;

  const PasswordResetRequest({
    required this.id,
    required this.fullName,
    required this.studentId,
    required this.requestedAt,
  });

  factory PasswordResetRequest.fromMap(Map<String, dynamic> m) {
    final raw = m['requested_at'] as String? ?? '';
    String formatted = raw;
    try {
      final dt = DateTime.parse(raw).toLocal();
      const months = ['','Jan','Feb','Mar','Apr','May','Jun',
                         'Jul','Aug','Sep','Oct','Nov','Dec'];
      formatted = '${months[dt.month]} ${dt.day}, ${dt.year}  ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
    } catch (_) {}
    return PasswordResetRequest(
      id:          m['id'] as int,
      fullName:    m['full_name']  as String? ?? '',
      studentId:   m['student_id'] as String? ?? '',
      requestedAt: formatted,
    );
  }
}

// ── Controller ────────────────────────────────────────────────────────────────

class PasswordResetController extends GetxController {
  final _db = Supabase.instance.client;

  final requests   = <PasswordResetRequest>[].obs;
  final isLoading  = true.obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    try {
      final data = await _db
          .from('password_reset_requests')
          .select('id, full_name, student_id, requested_at')
          .eq('status', 'pending')
          .order('requested_at', ascending: false);
      requests.value = (data as List)
          .map((m) => PasswordResetRequest.fromMap(m))
          .toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load requests: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> refresh() => _load();

  Future<String?> fetchStudentEmail(String uniId) async {
    try {
      final result = await _db.rpc(
        'get_student_email_by_uni_id',
        params: {'p_uni_id': uniId},
      );
      return result as String?;
    } catch (_) {
      return null;
    }
  }

  Future<bool> resetPassword(String uniId, String newPassword) async {
    try {
      await _db.rpc('admin_reset_student_password', params: {
        'p_uni_id':       uniId,
        'p_new_password': newPassword,
      });
      await _load();
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to reset password: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white);
      return false;
    }
  }

  String generatePassword() {
    const chars =
        'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789!@#';
    final rng = Random.secure();
    return List.generate(10, (_) => chars[rng.nextInt(chars.length)]).join();
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────

class PasswordResetScreen extends StatelessWidget {
  const PasswordResetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(PasswordResetController());

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            Expanded(
              child: Obx(() {
                if (c.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (c.requests.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_outline,
                            size: 56, color: Colors.green.shade300),
                        const SizedBox(height: 12),
                        const Text('No pending reset requests',
                            style: TextStyle(
                                fontSize: 15, color: Colors.grey)),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: c.refresh,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: c.requests.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (_, i) =>
                        _RequestCard(request: c.requests[i], c: c),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: Get.back,
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Password Reset Requests',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Text('Pending student requests',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Request Card ──────────────────────────────────────────────────────────────

class _RequestCard extends StatelessWidget {
  final PasswordResetRequest request;
  final PasswordResetController c;
  const _RequestCard({required this.request, required this.c});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.lock_reset_outlined,
                  color: AppColors.primaryBlue, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.fullName,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A2B4A)),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'ID: ${request.studentId}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.primaryBlue),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    request.requestedAt,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3DF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Pending',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFB18334))),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ResetBottomSheet(request: request, c: c),
    );
  }
}

// ── Reset Bottom Sheet ────────────────────────────────────────────────────────

class _ResetBottomSheet extends StatefulWidget {
  final PasswordResetRequest request;
  final PasswordResetController c;
  const _ResetBottomSheet({required this.request, required this.c});

  @override
  State<_ResetBottomSheet> createState() => _ResetBottomSheetState();
}

class _ResetBottomSheetState extends State<_ResetBottomSheet> {
  final _passCtrl = TextEditingController();
  String? _email;
  bool _loadingEmail = true;
  bool _resetting = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _fetchEmail();
    _passCtrl.text = widget.c.generatePassword();
  }

  Future<void> _fetchEmail() async {
    final email =
        await widget.c.fetchStudentEmail(widget.request.studentId);
    if (mounted) setState(() { _email = email; _loadingEmail = false; });
  }

  Future<void> _reset() async {
    if (_passCtrl.text.trim().isEmpty) return;
    setState(() => _resetting = true);
    final ok = await widget.c
        .resetPassword(widget.request.studentId, _passCtrl.text.trim());
    if (mounted) {
      setState(() => _resetting = false);
      if (ok) Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text('Reset Password',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A2B4A))),
            const SizedBox(height: 16),

            // Student info card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _InfoRow(Icons.person_outline, 'Name',
                      widget.request.fullName),
                  const SizedBox(height: 10),
                  _InfoRow(Icons.badge_outlined, 'Student ID',
                      widget.request.studentId),
                  const SizedBox(height: 10),
                  _loadingEmail
                      ? const Row(children: [
                          Icon(Icons.email_outlined,
                              size: 18, color: Colors.grey),
                          SizedBox(width: 10),
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ])
                      : Row(
                          children: [
                            const Icon(Icons.email_outlined,
                                size: 18, color: Colors.grey),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _email ?? 'Email not found',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _email != null
                                      ? AppColors.primaryBlue
                                      : Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (_email != null)
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(
                                      ClipboardData(text: _email!));
                                  Get.snackbar('Copied',
                                      'Email copied to clipboard',
                                      snackPosition: SnackPosition.BOTTOM);
                                },
                                child: const Icon(Icons.copy_outlined,
                                    size: 16,
                                    color: AppColors.primaryBlue),
                              ),
                          ],
                        ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // New password field
            const Text('New Password',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A2B4A))),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passCtrl,
              obscureText: _obscure,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF2F4F8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(_obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                      color: Colors.grey,
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_outlined),
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: _passCtrl.text));
                        Get.snackbar('Copied',
                            'Password copied to clipboard',
                            snackPosition: SnackPosition.BOTTOM);
                      },
                      color: AppColors.primaryBlue,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Regenerate button
            GestureDetector(
              onTap: () =>
                  setState(() => _passCtrl.text = widget.c.generatePassword()),
              child: const Row(
                children: [
                  Icon(Icons.refresh_rounded,
                      size: 16, color: AppColors.primaryBlue),
                  SizedBox(width: 4),
                  Text('Generate new password',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Reset button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _resetting ? null : _reset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _resetting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Reset Password',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 10),
        Text('$label: ',
            style: const TextStyle(fontSize: 13, color: Colors.grey)),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A2B4A))),
        ),
      ],
    );
  }
}
