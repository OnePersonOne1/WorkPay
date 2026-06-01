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
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
