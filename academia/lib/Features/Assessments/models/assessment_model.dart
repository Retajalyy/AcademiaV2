class AssessmentModel {
  final String courseName;
  final String courseType;
  final double midterm;
  final double midtermTotal;
  final double participation;
  final double participationTotal;
  final double attendance;

  AssessmentModel({
    required this.courseName,
    required this.courseType,
    required this.midterm,
    required this.midtermTotal,
    required this.participation,
    required this.participationTotal,
    required this.attendance,
  });

  factory AssessmentModel.fromMap(Map<String, dynamic> row) {
    final section = row['sections'] as Map<String, dynamic>;
    final course  = section['courses'] as Map<String, dynamic>;
    final gradesRaw = row['grades'];
    final grades = gradesRaw is Map<String, dynamic>
        ? gradesRaw
        : (gradesRaw is List && gradesRaw.isNotEmpty)
            ? gradesRaw.first as Map<String, dynamic>
            : <String, dynamic>{};

    return AssessmentModel(
      courseName:          course['name']                          ?? '',
      courseType:          course['type']                          ?? 'Core',
      midterm:             (grades['midterm']          as num?)?.toDouble() ?? 0,
      midtermTotal:        (grades['midterm_total']    as num?)?.toDouble() ?? 15,
      participation:       (grades['participation']    as num?)?.toDouble() ?? 0,
      participationTotal:  (grades['participation_total'] as num?)?.toDouble() ?? 25,
      attendance:          (grades['attendance']       as num?)?.toDouble() ?? 0,
    );
  }

  String get midtermStr      => '${midterm.toStringAsFixed(0)}/${midtermTotal.toStringAsFixed(0)}';
  String get participationStr => '${participation.toStringAsFixed(0)}/${participationTotal.toStringAsFixed(0)}';
  String get attendanceStr   => '${attendance.toStringAsFixed(0)}%';

  String get midtermStatus      => _status(midterm, midtermTotal);
  String get participationStatus => _status(participation, participationTotal);
  String get attendanceStatus   => _status(attendance, 100);

  double get progress => midtermTotal > 0
      ? (midterm / midtermTotal).clamp(0.0, 1.0)
      : 0.0;

  static String _status(double score, double total) {
    if (total == 0) return '';
    final pct = (score / total) * 100;
    if (pct >= 90) return 'Excellent';
    if (pct >= 75) return 'Very Good';
    if (pct >= 60) return 'Average';
    if (pct >= 50) return 'Fair';
    return 'Below avg';
  }
}
