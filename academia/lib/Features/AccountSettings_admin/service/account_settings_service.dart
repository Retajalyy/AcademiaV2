import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/account_settings_model.dart';

class AccountSettingsService {
  final _db = Supabase.instance.client;

  Future<AccountSettingsModel> fetchAccountSettings() async {
    final userId = _db.auth.currentUser!.id;

    final profile = await _db
        .from('profiles')
        .select('full_name, fname, lname, uni_id, email')
        .eq('id', userId)
        .single();

    final admin = await _db
        .from('admins')
        .select('*')
        .eq('profile_id', userId)
        .maybeSingle();

    final fullName = profile['full_name'] as String? ??
        '${profile['fname'] ?? ''} ${profile['lname'] ?? ''}'.trim();

    return AccountSettingsModel(
      fullName: fullName,
      employeeId: profile['uni_id'] as String? ?? '',
      department: admin?['department'] as String? ?? '',
      universityEmail: profile['email'] as String? ?? '',
      phone: admin?['phone'] as String? ?? '',
      personalEmail: admin?['personal_email'] as String? ?? '',
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

    await _db
        .from('admins')
        .upsert(updates, onConflict: 'profile_id');

    return true;
  }
}
