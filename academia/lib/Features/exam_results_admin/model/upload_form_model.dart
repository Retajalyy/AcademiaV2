class UploadFormModel {
  final String? faculty;
  final String? facultyCode;
  final String? level;
  final String? major;
  final String? majorCode;
  final String? resultsTitle;
  final String? semester;
  final int?    semesterId;
  final String? academicYear;

  final List<int>? fileBytes;
  final String?    fileName;
  final int?       fileRows;
  final double?    fileSizeMb;

  const UploadFormModel({
    this.faculty,
    this.facultyCode,
    this.level,
    this.major,
    this.majorCode,
    this.resultsTitle,
    this.semester,
    this.semesterId,
    this.academicYear,
    this.fileBytes,
    this.fileName,
    this.fileRows,
    this.fileSizeMb,
  });

  UploadFormModel copyWith({
    String?   faculty,
    String?   facultyCode,
    String?   level,
    String?   major,
    String?   majorCode,
    String?   resultsTitle,
    String?   semester,
    int?      semesterId,
    String?   academicYear,
    List<int>? fileBytes,
    String?   fileName,
    int?      fileRows,
    double?   fileSizeMb,
  }) =>
      UploadFormModel(
        faculty:      faculty      ?? this.faculty,
        facultyCode:  facultyCode  ?? this.facultyCode,
        level:        level        ?? this.level,
        major:        major        ?? this.major,
        majorCode:    majorCode    ?? this.majorCode,
        resultsTitle: resultsTitle ?? this.resultsTitle,
        semester:     semester     ?? this.semester,
        semesterId:   semesterId   ?? this.semesterId,
        academicYear: academicYear ?? this.academicYear,
        fileBytes:    fileBytes    ?? this.fileBytes,
        fileName:     fileName     ?? this.fileName,
        fileRows:     fileRows     ?? this.fileRows,
        fileSizeMb:   fileSizeMb   ?? this.fileSizeMb,
      );

  bool get isStep1Valid =>
      (faculty?.isNotEmpty ?? false) &&
      (level?.isNotEmpty ?? false) &&
      (major?.isNotEmpty ?? false);

  bool get isStep2Valid =>
      (resultsTitle?.isNotEmpty ?? false) &&
      (semesterId != null) &&
      (academicYear?.isNotEmpty ?? false);

  bool get isStep3Valid => fileBytes != null;
}
