class AssessmentModel {
  final int    sectionId;
  final String courseName;
  final String courseType;
  final double midterm;
  final double midtermTotal;
  final double finalExam;
  final double finalExamTotal;
  final double quiz;
  final double quizTotal;
  final double participation;
  final double participationTotal;
  final double attendance;

  AssessmentModel({
    required this.sectionId,
    required this.courseName,
    required this.courseType,
    required this.midterm,
    required this.midtermTotal,
    required this.finalExam,
    required this.finalExamTotal,
    required this.quiz,
    required this.quizTotal,
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
      sectionId:          row['section_id']                  as int? ?? 0,
      courseName:         course['name']                              ?? '',
      courseType:         course['type']                              ?? 'Core',
      midterm:            (grades['midterm']           as num?)?.toDouble() ?? 0,
      midtermTotal:       (grades['midterm_total']     as num?)?.toDouble() ?? 15,
      finalExam:          (grades['final']             as num?)?.toDouble() ?? 0,
      finalExamTotal:     (grades['final_total']       as num?)?.toDouble() ?? 60,
      quiz:               (grades['quiz']              as num?)?.toDouble() ?? 0,
      quizTotal:          (grades['quiz_total']        as num?)?.toDouble() ?? 10,
      participation:      (grades['participation']     as num?)?.toDouble() ?? 0,
      participationTotal: (grades['participation_total'] as num?)?.toDouble() ?? 25,
      attendance:         (grades['attendance']        as num?)?.toDouble() ?? 0,
    );
  }

  // ── Display strings ────────────────────────────────────────────────────────
  String get midtermStr       => '${midterm.toStringAsFixed(0)}/${midtermTotal.toStringAsFixed(0)}';
  String get finalExamStr     => '${finalExam.toStringAsFixed(0)}/${finalExamTotal.toStringAsFixed(0)}';
  String get quizStr          => '${quiz.toStringAsFixed(0)}/${quizTotal.toStringAsFixed(0)}';
  String get participationStr => '${participation.toStringAsFixed(0)}/${participationTotal.toStringAsFixed(0)}';
  String get attendanceStr    => '${attendance.toStringAsFixed(0)}%';

  // ── Total score out of total possible ─────────────────────────────────────
  double get totalScore   => midterm + finalExam + quiz + participation;
  double get totalPossible => midtermTotal + finalExamTotal + quizTotal + participationTotal;
  String get totalStr     => '${totalScore.toStringAsFixed(0)}/${totalPossible.toStringAsFixed(0)}';

  // ── Status labels ──────────────────────────────────────────────────────────
  String get midtermStatus       => _status(midterm, midtermTotal);
  String get finalExamStatus     => _status(finalExam, finalExamTotal);
  String get quizStatus          => _status(quiz, quizTotal);
  String get participationStatus => _status(participation, participationTotal);
  String get attendanceStatus    => _status(attendance, 100);

  double get progress => totalPossible > 0
      ? (totalScore / totalPossible).clamp(0.0, 1.0)
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
