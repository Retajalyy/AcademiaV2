import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/account_settings_model.dart';

class AccountSettingsService {
  final _db = Supabase.instance.client;

  Future<AccountSettingsModel> fetchAccountSettings() async {
    final userId = _db.auth.currentUser!.id;

    final profile = await _db
        .from('profiles')
        .select('full_name, fname, lname, uni_id, email, avatar_url')
        .eq('id', userId)
        .single();

    final admin = await _db
        .from('admins')
        .select('*')
        .eq('profile_id', userId)
        .maybeSingle();

    final fullName = profile['full_name'] as String? ??
        '${profile['fname'] ?? ''} ${profile['lname'] ?? ''}'.trim();

    final rawUrl = profile['avatar_url'] as String?;
    final avatarUrl = (rawUrl != null && rawUrl.isNotEmpty)
        ? '$rawUrl?t=${DateTime.now().millisecondsSinceEpoch}'
        : null;

    return AccountSettingsModel(
      fullName: fullName,
      employeeId: profile['uni_id'] as String? ?? '',
      department: admin?['department'] as String? ?? '',
      universityEmail: profile['email'] as String? ?? '',
      phone: admin?['phone'] as String? ?? '',
      personalEmail: admin?['personal_email'] as String? ?? '',
      photoPath: avatarUrl,
    );
  }

  Future<bool> saveAccountSettings({
    required String phone,
    required String personalEmail,
  }) async {
    final userId = _db.auth.currentUser!.id;

    final updates = <String, dynamic>{'phone': phone};
    if (personalEmail.isNotEmpty) {
      updates['personal_email'] = personalEmail;
    }
    updates['profile_id'] = userId;

    await _db.from('admins').upsert(updates, onConflict: 'profile_id');
    return true;
  }

  Future<String> uploadAvatar(Uint8List bytes, String ext) async {
    final userId = _db.auth.currentUser!.id;
    final path   = 'admins/$userId.$ext';

    await _db.storage.from('avatars').uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(contentType: 'image/$ext', upsert: true),
    );

    final baseUrl = _db.storage.from('avatars').getPublicUrl(path);
    await _db.from('profiles').update({'avatar_url': baseUrl}).eq('id', userId);
    return '$baseUrl?t=${DateTime.now().millisecondsSinceEpoch}';
  }
}
