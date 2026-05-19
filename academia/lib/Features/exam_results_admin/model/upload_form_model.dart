// ─────────────────────────────────────────────────────────────────────────────
// Model: UploadFormModel
// Immutable value object that holds the 3-step upload form state.
// Use copyWith() to produce updated instances; never mutate directly.
// ─────────────────────────────────────────────────────────────────────────────

class UploadFormModel {
  final String? faculty;
  final String? level;
  final String? major;
  final String? resultsTitle;
  final String? semester;
  final String? academicYear;

  /// The picked file object (dart:io File or XFile from file_picker).
  final Object? file;
  final String? fileName;
  final int? fileRows;
  final double? fileSizeMb;

  const UploadFormModel({
    this.faculty,
    this.level,
    this.major,
    this.resultsTitle,
    this.semester,
    this.academicYear,
    this.file,
    this.fileName,
    this.fileRows,
    this.fileSizeMb,
  });

  // ── Helpers ───────────────────────────────────────────────────────────────

  UploadFormModel copyWith({
    String? faculty,
    String? level,
    String? major,
    String? resultsTitle,
    String? semester,
    String? academicYear,
    Object? file,
    String? fileName,
    int? fileRows,
    double? fileSizeMb,
  }) =>
      UploadFormModel(
        faculty: faculty ?? this.faculty,
        level: level ?? this.level,
        major: major ?? this.major,
        resultsTitle: resultsTitle ?? this.resultsTitle,
        semester: semester ?? this.semester,
        academicYear: academicYear ?? this.academicYear,
        file: file ?? this.file,
        fileName: fileName ?? this.fileName,
        fileRows: fileRows ?? this.fileRows,
        fileSizeMb: fileSizeMb ?? this.fileSizeMb,
      );

  // ── Per-step validators ───────────────────────────────────────────────────

  bool get isStep1Valid =>
      (faculty?.isNotEmpty ?? false) &&
      (level?.isNotEmpty ?? false) &&
      (major?.isNotEmpty ?? false);

  bool get isStep2Valid =>
      (resultsTitle?.isNotEmpty ?? false) &&
      (semester?.isNotEmpty ?? false) &&
      (academicYear?.isNotEmpty ?? false);

  bool get isStep3Valid => file != null;
}