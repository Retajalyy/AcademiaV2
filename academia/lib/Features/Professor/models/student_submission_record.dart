enum SubmissionStatus { onTime, late, missing }

class StudentSubmissionRecord {
  final int              studentId;
  final int              enrollmentId;
  final String           name;
  final String           uniId;
  final SubmissionStatus status;
  final DateTime?        submittedAt;
  final String?          fileUrl;
  final String?          fileName;
  final double?          currentGrade;
  final double           maxGrade;

  const StudentSubmissionRecord({
    required this.studentId,
    required this.enrollmentId,
    required this.name,
    required this.uniId,
    required this.status,
    this.submittedAt,
    this.fileUrl,
    this.fileName,
    this.currentGrade,
    required this.maxGrade,
  });

  String get statusLabel {
    switch (status) {
      case SubmissionStatus.onTime:  return 'On Time';
      case SubmissionStatus.late:    return 'Late';
      case SubmissionStatus.missing: return 'Missing';
    }
  }
}
