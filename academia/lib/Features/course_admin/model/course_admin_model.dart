class CourseAdminModel {
  final String id;
  final String name;
  final String faculty;
  final String level;
  final String major;
  final int credits;
  final String type; // "Core" | "Elective"
  final String prerequisite;

  const CourseAdminModel({
    required this.id,
    required this.name,
    required this.faculty,
    required this.level,
    required this.major,
    required this.credits,
    required this.type,
    this.prerequisite = '—',
  });

  CourseAdminModel copyWith({
    String? name,
    String? faculty,
    String? level,
    String? major,
    int? credits,
    String? type,
    String? prerequisite,
  }) {
    return CourseAdminModel(
      id: id,
      name: name ?? this.name,
      faculty: faculty ?? this.faculty,
      level: level ?? this.level,
      major: major ?? this.major,
      credits: credits ?? this.credits,
      type: type ?? this.type,
      prerequisite: prerequisite ?? this.prerequisite,
    );
  }
}

class CourseStatsModel {
  final int totalCourses;
  final int professors;
  final int faculties;

  const CourseStatsModel({
    required this.totalCourses,
    required this.professors,
    required this.faculties,
  });
}

class CourseFormModel {
  final String name;
  final String faculty;
  final String level;
  final String major;
  final String credits;
  final String type;
  final String prerequisite;

  const CourseFormModel({
    this.name = '',
    this.faculty = '',
    this.level = '',
    this.major = '',
    this.credits = '',
    this.type = '',
    this.prerequisite = '',
  });

  CourseFormModel copyWith({
    String? name,
    String? faculty,
    String? level,
    String? major,
    String? credits,
    String? type,
    String? prerequisite,
  }) {
    return CourseFormModel(
      name: name ?? this.name,
      faculty: faculty ?? this.faculty,
      level: level ?? this.level,
      major: major ?? this.major,
      credits: credits ?? this.credits,
      type: type ?? this.type,
      prerequisite: prerequisite ?? this.prerequisite,
    );
  }

  bool get isValid =>
      name.isNotEmpty &&
      faculty.isNotEmpty &&
      level.isNotEmpty &&
      major.isNotEmpty &&
      credits.isNotEmpty &&
      type.isNotEmpty;
}