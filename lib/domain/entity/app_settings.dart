// SPDX-License-Identifier: GPL-3.0-only
/// 앱 전역 설정 (single-row 테이블, id 항상 1).
/// label 텍스트는 UI에서 AppLocalizations로 조회. enum 자체엔 표시 문자열 없음.
enum ThemeModeSetting { system, light, dark }

class AppSettings {
  const AppSettings({
    required this.schemaVersion,
    required this.themeMode,
    required this.locale,
    required this.lastBackupAt,
    required this.payrollConstantsJson,
    required this.use24HourFormat,
    required this.undoStackJson,
    required this.activePlanId,
    required this.koreanLaborLawCompliance,
    required this.currencyUnit,
    required this.holidayCountry,
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

  /// 현재 활성 plan id. 0=메인, >0=모의안.
  final int activePlanId;

  /// 한국 노동법 준수 모드. ON이면 야간/연장/주휴/공제 등 고급 옵션 노출 + 계산 적용.
  /// OFF면 단순 시급×시간만, 고급 옵션 UI 숨김.
  final bool koreanLaborLawCompliance;

  /// 표시용 통화 단위 (예: '원', '$', 'USD'). 계산엔 영향 없음. 기본 '원'.
  final String currencyUnit;

  /// 공휴일 기준 국가. 'KR'=대한민국(기본), 'none'=표시 안 함.
  final String holidayCountry;

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
    int? activePlanId,
    bool? koreanLaborLawCompliance,
    String? currencyUnit,
    String? holidayCountry,
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
      activePlanId: activePlanId ?? this.activePlanId,
      koreanLaborLawCompliance:
          koreanLaborLawCompliance ?? this.koreanLaborLawCompliance,
      currencyUnit: currencyUnit ?? this.currencyUnit,
      holidayCountry: holidayCountry ?? this.holidayCountry,
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
      other.activePlanId == activePlanId &&
      other.koreanLaborLawCompliance == koreanLaborLawCompliance &&
      other.currencyUnit == currencyUnit &&
      other.holidayCountry == holidayCountry &&
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
        activePlanId,
        koreanLaborLawCompliance,
        currencyUnit,
        holidayCountry,
        updatedAt,
      ]);
}
