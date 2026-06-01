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
    required this.updatedAt,
  });

  /// 백업 import 호환성에 사용. 코드 schemaVersion과 일치하지 않으면 import 거부.
  final int schemaVersion;
  final ThemeModeSetting themeMode;
  final String locale;
  final DateTime? lastBackupAt;
  final DateTime updatedAt;

  AppSettings copyWith({
    int? schemaVersion,
    ThemeModeSetting? themeMode,
    String? locale,
    DateTime? lastBackupAt,
    bool clearLastBackupAt = false,
    DateTime? updatedAt,
  }) {
    return AppSettings(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      lastBackupAt: clearLastBackupAt ? null : (lastBackupAt ?? this.lastBackupAt),
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
      other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      Object.hash(schemaVersion, themeMode, locale, lastBackupAt, updatedAt);
}
