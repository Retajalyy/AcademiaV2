import '../model/account_settings_model.dart';

class AccountSettingsService {
  Future<AccountSettingsModel> fetchAccountSettings() async {
    await Future.delayed(const Duration(milliseconds: 600));

    return AccountSettingsModel(
      fullName: 'Ahmed Mohamed Ahmed',
      employeeId: '2029003',
      department: 'Student Affairs',
      universityEmail: 'Ahmed.Mohamed@university.edu',
      phone: '+20 100 123 4567',
      personalEmail: 'Ahmed.muhamed@gmail.com',
    );
  }

  Future<bool> saveAccountSettings({
    required String phone,
    required String personalEmail,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // TODO: replace with real API call
    return true;
  }
}