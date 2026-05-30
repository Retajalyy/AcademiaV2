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

  factory CourseAdminModel.fromDb(
    Map<String, dynamic> row,
    Map<String, String> facMap,
    Map<String, String> majMap,
  ) {
    final yearLevel = row['year_level'] as int? ?? 1;
    final facCode   = row['faculty_code'] as String? ?? '';
    final majCode   = row['major_code']   as String?;
    return CourseAdminModel(
      id:           row['id'].toString(),
      name:         row['name']        as String? ?? '',
      faculty:      facMap[facCode]    ?? facCode,
      level:        'Year $yearLevel',
      major:        majCode != null ? (majMap[majCode] ?? majCode) : 'General',
      credits:      (row['credit_hours'] as int?) ?? 3,
      type:         row['type']        as String? ?? 'Core',
      prerequisite: '—',
    );
  }

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
  final String facultyCode;
  final String level;
  final String major;
  final String majorCode;
  final String credits;
  final String type;
  final String prerequisite;

  const CourseFormModel({
    this.name = '',
    this.faculty = '',
    this.facultyCode = '',
    this.level = '',
    this.major = '',
    this.majorCode = '',
    this.credits = '',
    this.type = '',
    this.prerequisite = '',
  });

  CourseFormModel copyWith({
    String? name,
    String? faculty,
    String? facultyCode,
    String? level,
    String? major,
    String? majorCode,
    String? credits,
    String? type,
    String? prerequisite,
  }) {
    return CourseFormModel(
      name:        name        ?? this.name,
      faculty:     faculty     ?? this.faculty,
      facultyCode: facultyCode ?? this.facultyCode,
      level:       level       ?? this.level,
      major:       major       ?? this.major,
      majorCode:   majorCode   ?? this.majorCode,
      credits:     credits     ?? this.credits,
      type:        type        ?? this.type,
      prerequisite: prerequisite ?? this.prerequisite,
    );
  }

  bool get isValid =>
      name.isNotEmpty &&
      facultyCode.isNotEmpty &&
      level.isNotEmpty &&
      credits.isNotEmpty &&
      type.isNotEmpty;
}