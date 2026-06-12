class AssignmentSubmissionInfo {
  final int      materialId;
  final String   name;
  final String   materialType;
  final DateTime? dueDate;
  final bool     isOpen;
  final int      onTime;
  final int      late;
  final int      pending;

  const AssignmentSubmissionInfo({
    required this.materialId,
    required this.name,
    required this.materialType,
    required this.dueDate,
    required this.isOpen,
    required this.onTime,
    required this.late,
    required this.pending,
  });

  String get dueDateLabel {
    if (dueDate == null) return '';
    const m = ['','Jan','Feb','Mar','Apr','May','Jun',
                   'Jul','Aug','Sep','Oct','Nov','Dec'];
    return 'Due ${m[dueDate!.month]} ${dueDate!.day}';
  }
}
