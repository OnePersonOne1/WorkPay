// SPDX-License-Identifier: GPL-3.0-only
import 'package:drift/drift.dart';

class Jobs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  IntColumn get hourlyWage => integer()();
  TextColumn get incomeType => text()(); // IncomeType.name
  TextColumn get businessSize => text()(); // BusinessSize.name
  IntColumn get colorArgb => integer()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

class JobPayrollOptionsTable extends Table {
  @override
  String get tableName => 'job_payroll_options';

  IntColumn get jobId => integer().references(Jobs, #id, onDelete: KeyAction.cascade)();
  BoolColumn get weeklyHolidayAllowance => boolean().withDefault(const Constant(false))();
  BoolColumn get nightPremium => boolean().withDefault(const Constant(false))();
  BoolColumn get dailyOvertime => boolean().withDefault(const Constant(false))();
  BoolColumn get weeklyOvertime => boolean().withDefault(const Constant(false))();
  BoolColumn get holidayPremium => boolean().withDefault(const Constant(false))();
  BoolColumn get preciseBreakInput => boolean().withDefault(const Constant(false))();
  TextColumn get deductionMode => text().withDefault(const Constant('none'))();

  /// 만분율. 940 = 9.40%.
  IntColumn get fourInsuranceRate => integer().withDefault(const Constant(940))();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {jobId};
}

class Shifts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get jobId => integer().references(Jobs, #id, onDelete: KeyAction.restrict)();
  DateTimeColumn get startAt => dateTime()();
  DateTimeColumn get endAt => dateTime()();
  IntColumn get breakMinutes => integer().withDefault(const Constant(0))();
  DateTimeColumn get breakStartAt => dateTime().nullable()();
  IntColumn get hourlyWageSnapshot => integer()();
  TextColumn get memo => text().nullable()();
  /// 시프트가 속한 plan. 0 = 메인(영구), >0 = 모의안(plans.id 참조).
  IntColumn get planId => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

/// 모의안. 메인(planId=0)은 이 테이블에 row 없음 — sentinel로 처리.
class Plans extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get year => integer()();
  IntColumn get month => integer()();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

class AppSettingsTable extends Table {
  @override
  String get tableName => 'app_settings';

  /// 항상 1. Single-row 불변식은 DAO 레벨에서 강제 (id=1 고정 upsert).
  IntColumn get id => integer()();
  IntColumn get schemaVersion => integer()();
  TextColumn get themeMode => text().withDefault(const Constant('system'))();
  TextColumn get locale => text().withDefault(const Constant('ko'))();
  DateTimeColumn get lastBackupAt => dateTime().nullable()();

  /// '고고급 설정'에서 사용자가 override한 PayrollConstants 직렬화 JSON.
  /// NULL이면 koreanDefault() 사용.
  TextColumn get payrollConstantsJson => text().nullable()();

  /// 24시간 형식 표시 여부. 기본 true (24h). false면 오전/오후 표시.
  BoolColumn get use24HourFormat => boolean().withDefault(const Constant(true))();

  /// Undo 스택 JSON. 시프트 변경 시 직전 월 시프트 list snapshot을 누적.
  /// NULL이면 빈 스택. 최대 5개 entry.
  TextColumn get undoStackJson => text().nullable()();

  /// 현재 활성 plan id. 0 = 메인, >0 = 모의안. 기본값 0.
  IntColumn get activePlanId => integer().withDefault(const Constant(0))();

  /// 한국 노동법 준수 모드. 활성화 시 야간/연장/주휴/공제 등 모든 고급 옵션 노출 +
  /// Job별 옵션이 실제 계산에 반영. 비활성화 시 단순 시급×시간만, 고급 옵션 UI 숨김.
  /// 기본값 true (한국어 locale 가정). 영어 locale 신규 설치 시 onCreate에서 false로 세팅 가능.
  BoolColumn get koreanLaborLawCompliance =>
      boolean().withDefault(const Constant(true))();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
