/// 앱 전역 설정 (single-row 테이블, id 항상 1).
enum ThemeModeSetting {
  system('시스템'),
  light('라이트'),
  dark('다크');

  const ThemeModeSetting(this.label);
  final String label;
}

class AppSettings {
  const AppSettings({
    required this.schemaVersion,
    required this.themeMode,
    required this.locale,
    required this.lastBackupAt,
    required this.payrollConstantsJson,
    required this.use24HourFormat,
    required this.undoStackJson,
    required this.updatedAt,
  });

  /// 백업 import 호환성에 사용. 코드 schemaVersion과 일치하지 않으면 import 거부.
  final int schemaVersion;
  final ThemeModeSetting themeMode;
  final String locale;
  final DateTime? lastBackupAt;

  /// 사용자가 '고고급 설정'에서 override한 PayrollConstants JSON. null이면 default.
  final String? payrollConstantsJson;

  /// 시간 표시를 24시간 형식으로 할지. 기본 false (오전/오후).
  final bool use24HourFormat;

  /// Undo 스택 직렬화. NULL이면 빈 스택. 앱 종료 후에도 유지.
  final String? undoStackJson;

  final DateTime updatedAt;

  AppSettings copyWith({
    int? schemaVersion,
    ThemeModeSetting? themeMode,
    String? locale,
    DateTime? lastBackupAt,
    bool clearLastBackupAt = false,
    String? payrollConstantsJson,
    bool clearPayrollConstantsJson = false,
    bool? use24HourFormat,
    String? undoStackJson,
    bool clearUndoStackJson = false,
    DateTime? updatedAt,
  }) {
    return AppSettings(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      lastBackupAt: clearLastBackupAt ? null : (lastBackupAt ?? this.lastBackupAt),
      payrollConstantsJson: clearPayrollConstantsJson
          ? null
          : (payrollConstantsJson ?? this.payrollConstantsJson),
      use24HourFormat: use24HourFormat ?? this.use24HourFormat,
      undoStackJson: clearUndoStackJson
          ? null
          : (undoStackJson ?? this.undoStackJson),
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.schemaVersion == schemaVersion &&
      other.themeMode == themeMode &&
      other.locale == locale &&
      other.lastBackupAt == lastBackupAt &&
      other.payrollConstantsJson == payrollConstantsJson &&
      other.use24HourFormat == use24HourFormat &&
      other.undoStackJson == undoStackJson &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hashAll([
        schemaVersion,
        themeMode,
        locale,
        lastBackupAt,
        payrollConstantsJson,
        use24HourFormat,
        undoStackJson,
        updatedAt,
      ]);
}
