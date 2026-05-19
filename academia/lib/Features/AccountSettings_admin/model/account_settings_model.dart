class AccountSettingsModel {
  final String fullName;
  final String employeeId;
  final String department;
  final String universityEmail;
  String phone;
  String personalEmail;
  String? photoPath;

  AccountSettingsModel({
    required this.fullName,
    required this.employeeId,
    required this.department,
    required this.universityEmail,
    required this.phone,
    required this.personalEmail,
    this.photoPath,
  });

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first.substring(0, 2).toUpperCase();
  }

  AccountSettingsModel copyWith({
    String? phone,
    String? personalEmail,
    String? photoPath,
  }) {
    return AccountSettingsModel(
      fullName: fullName,
      employeeId: employeeId,
      department: department,
      universityEmail: universityEmail,
      phone: phone ?? this.phone,
      personalEmail: personalEmail ?? this.personalEmail,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}