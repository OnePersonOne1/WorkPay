import 'package:drift/drift.dart' show Value;

import '../../domain/entity/app_settings.dart' as ent;
import '../../domain/entity/business_size.dart';
import '../../domain/entity/deduction_mode.dart';
import '../../domain/entity/income_type.dart';
import '../../domain/entity/job.dart' as ent;
import '../../domain/entity/job_payroll_options.dart' as ent;
import '../../domain/entity/shift.dart' as ent;
import '../db/app_database.dart' as db;

/// drift row → domain entity 매핑.
extension JobRowToEntity on db.Job {
  ent.Job toEntity() => ent.Job(
        id: id,
        name: name,
        hourlyWage: hourlyWage,
        incomeType: _decodeIncomeType(incomeType),
        businessSize: _decodeBusinessSize(businessSize),
        colorArgb: colorArgb,
        archived: archived,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

extension JobPayrollOptionsRowToEntity on db.JobPayrollOptionsTableData {
  ent.JobPayrollOptions toEntity() => ent.JobPayrollOptions(
        jobId: jobId,
        weeklyHolidayAllowance: weeklyHolidayAllowance,
        nightPremium: nightPremium,
        dailyOvertime: dailyOvertime,
        weeklyOvertime: weeklyOvertime,
        holidayPremium: holidayPremium,
        preciseBreakInput: preciseBreakInput,
        deductionMode: _decodeDeductionMode(deductionMode),
        fourInsuranceRate: fourInsuranceRate,
        updatedAt: updatedAt,
      );
}

extension ShiftRowToEntity on db.Shift {
  ent.Shift toEntity() => ent.Shift(
        id: id,
        jobId: jobId,
        startAt: startAt,
        endAt: endAt,
        breakMinutes: breakMinutes,
        breakStartAt: breakStartAt,
        hourlyWageSnapshot: hourlyWageSnapshot,
        memo: memo,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

extension AppSettingsRowToEntity on db.AppSettingsTableData {
  ent.AppSettings toEntity() => ent.AppSettings(
        schemaVersion: schemaVersion,
        themeMode: _decodeThemeMode(themeMode),
        locale: locale,
        lastBackupAt: lastBackupAt,
        updatedAt: updatedAt,
      );
}

extension AppSettingsEntityToCompanion on ent.AppSettings {
  db.AppSettingsTableCompanion toCompanion() => db.AppSettingsTableCompanion(
        id: const Value(1),
        schemaVersion: Value(schemaVersion),
        themeMode: Value(themeMode.name),
        locale: Value(locale),
        lastBackupAt: Value(lastBackupAt),
        updatedAt: Value(updatedAt),
      );
}

extension JobPayrollOptionsEntityToCompanion on ent.JobPayrollOptions {
  db.JobPayrollOptionsTableCompanion toCompanion() =>
      db.JobPayrollOptionsTableCompanion(
        jobId: Value(jobId),
        weeklyHolidayAllowance: Value(weeklyHolidayAllowance),
        nightPremium: Value(nightPremium),
        dailyOvertime: Value(dailyOvertime),
        weeklyOvertime: Value(weeklyOvertime),
        holidayPremium: Value(holidayPremium),
        preciseBreakInput: Value(preciseBreakInput),
        deductionMode: Value(deductionMode.name),
        fourInsuranceRate: Value(fourInsuranceRate),
        updatedAt: Value(updatedAt),
      );
}

// 문자열 ↔ enum 변환. 모르는 값이 들어오면 (예: 마이그레이션 손상) StateError로 빠르게 실패.

IncomeType _decodeIncomeType(String raw) =>
    IncomeType.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => throw StateError('Unknown IncomeType: $raw'),
    );

BusinessSize _decodeBusinessSize(String raw) =>
    BusinessSize.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => throw StateError('Unknown BusinessSize: $raw'),
    );

DeductionMode _decodeDeductionMode(String raw) =>
    DeductionMode.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => throw StateError('Unknown DeductionMode: $raw'),
    );

ent.ThemeModeSetting _decodeThemeMode(String raw) =>
    ent.ThemeModeSetting.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => throw StateError('Unknown ThemeModeSetting: $raw'),
    );
