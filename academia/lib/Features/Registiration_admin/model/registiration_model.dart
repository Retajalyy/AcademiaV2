// lib/Features/Registiration_admin/models/registration_model.dart

class RegistrationPlanModel {
  final String id;
  final String title;
  final String faculty;
  final double progress;
  final String progressText;
  final String courses;
  final String enrolled;
  final String groups;
  final String openDate;
  final String closeDate;
  final bool isActive;

  const RegistrationPlanModel({
    required this.id,
    required this.title,
    required this.faculty,
    required this.progress,
    required this.progressText,
    required this.courses,
    required this.enrolled,
    required this.groups,
    required this.openDate,
    required this.closeDate,
    this.isActive = true,
  });

  factory RegistrationPlanModel.fromJson(Map<String, dynamic> json) {
    return RegistrationPlanModel(
      id: json['id'] as String,
      title: json['title'] as String,
      faculty: json['faculty'] as String,
      progress: (json['progress'] as num).toDouble(),
      progressText: json['progressText'] as String,
      courses: json['courses'] as String,
      enrolled: json['enrolled'] as String,
      groups: json['groups'] as String,
      openDate: json['openDate'] as String,
      closeDate: json['closeDate'] as String,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'faculty': faculty,
        'progress': progress,
        'progressText': progressText,
        'courses': courses,
        'enrolled': enrolled,
        'groups': groups,
        'openDate': openDate,
        'closeDate': closeDate,
        'isActive': isActive,
      };

  RegistrationPlanModel copyWith({
    String? id,
    String? title,
    String? faculty,
    double? progress,
    String? progressText,
    String? courses,
    String? enrolled,
    String? groups,
    String? openDate,
    String? closeDate,
    bool? isActive,
  }) {
    return RegistrationPlanModel(
      id: id ?? this.id,
      title: title ?? this.title,
      faculty: faculty ?? this.faculty,
      progress: progress ?? this.progress,
      progressText: progressText ?? this.progressText,
      courses: courses ?? this.courses,
      enrolled: enrolled ?? this.enrolled,
      groups: groups ?? this.groups,
      openDate: openDate ?? this.openDate,
      closeDate: closeDate ?? this.closeDate,
      isActive: isActive ?? this.isActive,
    );
  }
}

class RegistrationStatusModel {
  final bool isOpen;
  final String message;
  final String closingDate;
  final String daysRemaining;

  const RegistrationStatusModel({
    required this.isOpen,
    required this.message,
    required this.closingDate,
    required this.daysRemaining,
  });

  factory RegistrationStatusModel.fromJson(Map<String, dynamic> json) {
    return RegistrationStatusModel(
      isOpen: json['isOpen'] as bool,
      message: json['message'] as String,
      closingDate: json['closingDate'] as String,
      daysRemaining: json['daysRemaining'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'isOpen': isOpen,
        'message': message,
        'closingDate': closingDate,
        'daysRemaining': daysRemaining,
      };
}