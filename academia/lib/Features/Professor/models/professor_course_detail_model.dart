class ProfessorCourseDetailModel {
  final int    totalStudents;
  final int    groupCount;
  final String major;
  final int    level;
  final List<CourseGroupInfo>      groups;
  final List<CourseMaterialModel>  materials;

  const ProfessorCourseDetailModel({
    required this.totalStudents,
    required this.groupCount,
    required this.major,
    required this.level,
    required this.groups,
    required this.materials,
  });
}

class CourseGroupInfo {
  final int    groupId;
  final String label;
  final int    studentCount;

  const CourseGroupInfo({
    required this.groupId,
    required this.label,
    required this.studentCount,
  });
}

class CourseMaterialModel {
  final int     id;
  final String  name;
  final String  fileType;
  final int?    fileSizeKb;
  final DateTime uploadedAt;
  final String? fileUrl;

  const CourseMaterialModel({
    required this.id,
    required this.name,
    required this.fileType,
    this.fileSizeKb,
    required this.uploadedAt,
    this.fileUrl,
  });

  String get sizeLabel {
    if (fileSizeKb == null) return '';
    if (fileSizeKb! >= 1024) {
      return '${(fileSizeKb! / 1024).toStringAsFixed(1)} MB';
    }
    return '$fileSizeKb KB';
  }
}
