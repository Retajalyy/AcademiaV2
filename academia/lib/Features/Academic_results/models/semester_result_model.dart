class SemesterResultModel {
  final int id;
  final int number;
  final String label;
  final String yearLabel;
  final String status;
  final double? gpa;

  SemesterResultModel({
    required this.id,
    required this.number,
    required this.label,
    required this.yearLabel,
    required this.status,
    this.gpa,
  });

  bool get isPublished => status.toLowerCase() != 'not published yet';

  factory SemesterResultModel.fromMap(Map<String, dynamic> row) {
    final sem = row['semesters'] as Map<String, dynamic>;
    return SemesterResultModel(
      id:        row['id']         as int,
      number:    sem['number']     as int,
      label:     sem['label']      as String,
      yearLabel: sem['year_label'] as String,
      status:    row['status']     as String,
      gpa:       (row['gpa'] as num?)?.toDouble(),
    );
  }
}
