class UserHomeModel {
  final String fullName;

  UserHomeModel({required this.fullName});

  factory UserHomeModel.fromJson(Map<String, dynamic> json) {
    return UserHomeModel(
      fullName: json['full_name'],
    );
  }
}