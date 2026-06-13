class AssignmentModel {
  final int id;
  final String title;
  final String type;
  final DateTime? dueDate;   // null = no deadline set by professor
  final double maxGrade;
  final String status; // 'pending' | 'handed' | 'missed'
  final DateTime? submittedAt;
  final double? grade;
  final String? fileUrl;
  final bool isMaterial;
  final String? materialFileUrl;

  const AssignmentModel({
    required this.id,
    required this.title,
    required this.type,
    required this.dueDate,
    required this.maxGrade,
    required this.status,
    this.submittedAt,
    this.grade,
    this.fileUrl,
    this.isMaterial = false,
    this.materialFileUrl,
  });

  bool get isPending => status == 'pending';
  bool get isHanded  => status == 'handed';
  bool get isMissed  => status == 'missed';
  bool get hasDueDate => dueDate != null;

  int get daysLeft => dueDate != null
      ? dueDate!.difference(DateTime.now()).inDays
      : 999;

  double get gradePercent =>
      maxGrade > 0 ? ((grade ?? 0) / maxGrade).clamp(0.0, 1.0) : 0.0;

  String get formattedDueDate    => dueDate != null ? _fmt(dueDate!) : 'No deadline';
  String get formattedSubmitDate => submittedAt != null ? _fmt(submittedAt!) : '';

  static const _months = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec',
  ];

  static String _fmt(DateTime d) =>
      '${_months[d.month - 1]} ${d.day}, ${d.year}';
}
