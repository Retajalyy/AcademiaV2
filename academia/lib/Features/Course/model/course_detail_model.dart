class CourseMaterial {
  final int id;
  final String title;
  final String subtitle;
  final String type;
  final bool isAssignment;
  final String? fileUrl;

  const CourseMaterial({
    this.id = 0,
    required this.title,
    required this.subtitle,
    required this.type,
    this.isAssignment = false,
    this.fileUrl,
  });

  factory CourseMaterial.fromMap(Map<String, dynamic> m) {
    final fileType = (m['file_type'] as String? ?? 'FILE').toUpperCase();
    final sizeKb   = m['file_size_kb'] as int?;
    String sizeLabel = '';
    if (sizeKb != null) {
      sizeLabel = sizeKb >= 1024
          ? '${(sizeKb / 1024).toStringAsFixed(1)} MB'
          : '$sizeKb KB';
    }
    final subtitle = sizeLabel.isNotEmpty ? '$fileType · $sizeLabel' : fileType;
    return CourseMaterial(
      id:       m['id'] as int? ?? 0,
      title:    m['name'] as String? ?? 'Untitled',
      subtitle: subtitle,
      type:     fileType.toLowerCase(),
      fileUrl:  m['file_url'] as String?,
    );
  }
}

class CourseDetailsModel {
  final String id;
  final String courseName;
  final String doctorName;
  final int credits;
  final double progress;
  final double classworkPercent;
  final double assignmentsPercent;
  final double attendancePercent;
  final List<CourseMaterial> materials;

  const CourseDetailsModel({
    required this.id,
    required this.courseName,
    required this.doctorName,
    required this.credits,
    required this.progress,
    required this.classworkPercent,
    required this.assignmentsPercent,
    required this.attendancePercent,
    required this.materials,
  });
}
