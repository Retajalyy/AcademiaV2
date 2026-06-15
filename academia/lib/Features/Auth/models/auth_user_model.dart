class AuthUserModel {
  final String id;
  final String uniId;
  final String fname;
  final String lname;
  final String role;
  final String email;
  final String? avatarUrl;
  final bool mustChangePassword;

  // Convenience getter so the rest of your UI doesn't break
  String get fullName => '$fname $lname';

  AuthUserModel({
    required this.id,
    required this.uniId,
    required this.fname,
    required this.lname,
    required this.role,
    required this.email,
    this.avatarUrl,
    this.mustChangePassword = false,
  });

  factory AuthUserModel.fromMap(Map<String, dynamic> map) {
    return AuthUserModel(
      id:        map['id']?.toString() ?? '',
      uniId:     map['uni_id']?.toString() ?? '',
      fname:     map['fname']?.toString() ?? '',
      lname:     map['lname']?.toString() ?? '',
      role:      map['role']?.toString() ?? 'student',
      email:     map['email']?.toString() ?? '',
      avatarUrl: map['avatar_url']?.toString(),
      mustChangePassword: map['must_change_password'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'uni_id': uniId,
    'fname': fname,
    'lname': lname,
    'role': role,
    'email': email,
    'avatar_url': avatarUrl,
    'must_change_password': mustChangePassword,
  };

  AuthUserModel copyWith({bool? mustChangePassword}) {
    return AuthUserModel(
      id: id,
      uniId: uniId,
      fname: fname,
      lname: lname,
      role: role,
      email: email,
      avatarUrl: avatarUrl,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
    );
  }
}