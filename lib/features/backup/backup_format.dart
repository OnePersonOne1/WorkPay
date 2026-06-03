/// salary_app 백업 JSON 포맷.
///
/// 포맷 버전 정책:
/// - [BackupData.schemaVersion]은 DB 스키마 버전과 동일. import 시 일치 안 하면 거부.
/// - 향후 마이그레이션 변환기를 만들 수도 있지만 v1에선 단순 거부.
library;

import '../../domain/entity/app_settings.dart' show ThemeModeSetting;
import '../../domain/entity/business_size.dart';
import '../../domain/entity/deduction_mode.dart';
import '../../domain/entity/income_type.dart';

class BackupData {
  const BackupData({
    required this.schemaVersion,
    required this.appVersion,
    required this.exportedAt,
    required this.jobs,
    required this.jobPayrollOptions,
    required this.shifts,
    required this.appSettings,
  });

  final int schemaVersion;
  final String appVersion;
  final DateTime exportedAt;
  final List<JobJson> jobs;
  final List<JobPayrollOptionsJson> jobPayrollOptions;
  final List<ShiftJson> shifts;
  final AppSettingsJson appSettings;

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'appVersion': appVersion,
        'exportedAt': exportedAt.toUtc().toIso8601String(),
        'jobs': jobs.map((j) => j.toJson()).toList(),
        'jobPayrollOptions':
            jobPayrollOptions.map((o) => o.toJson()).toList(),
        'shifts': shifts.map((s) => s.toJson()).toList(),
        'appSettings': appSettings.toJson(),
      };

  factory BackupData.fromJson(Map<String, dynamic> json) {
    return BackupData(
      schemaVersion: json['schemaVersion'] as int,
      appVersion: json['appVersion'] as String,
      exportedAt: DateTime.parse(json['exportedAt'] as String),
      jobs: (json['jobs'] as List)
          .map((e) => JobJson.fromJson(e as Map<String, dynamic>))
          .toList(),
      jobPayrollOptions: (json['jobPayrollOptions'] as List)
          .map((e) =>
              JobPayrollOptionsJson.fromJson(e as Map<String, dynamic>))
          .toList(),
      shifts: (json['shifts'] as List)
          .map((e) => ShiftJson.fromJson(e as Map<String, dynamic>))
          .toList(),
      appSettings:
          AppSettingsJson.fromJson(json['appSettings'] as Map<String, dynamic>),
    );
  }
}

class JobJson {
  const JobJson({
    required this.id,
    required this.name,
    required this.hourlyWage,
    required this.incomeType,
    required this.businessSize,
    required this.colorArgb,
    required this.archived,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String name;
  final int hourlyWage;
  final IncomeType incomeType;
  final BusinessSize businessSize;
  final int colorArgb;
  final bool archived;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'hourlyWage': hourlyWage,
        'incomeType': incomeType.name,
        'businessSize': businessSize.name,
        'colorArgb': colorArgb,
        'archived': archived,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  factory JobJson.fromJson(Map<String, dynamic> json) => JobJson(
        id: json['id'] as int,
        name: json['name'] as String,
        hourlyWage: json['hourlyWage'] as int,
        incomeType: IncomeType.values.byName(json['incomeType'] as String),
        businessSize:
            BusinessSize.values.byName(json['businessSize'] as String),
        colorArgb: json['colorArgb'] as int,
        archived: json['archived'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}

class JobPayrollOptionsJson {
  const JobPayrollOptionsJson({
    required this.jobId,
    required this.weeklyHolidayAllowance,
    required this.nightPremium,
    required this.dailyOvertime,
    required this.weeklyOvertime,
    required this.holidayPremium,
    required this.preciseBreakInput,
    required this.deductionMode,
    required this.fourInsuranceRate,
    required this.updatedAt,
  });

  final int jobId;
  final bool weeklyHolidayAllowance;
  final bool nightPremium;
  final bool dailyOvertime;
  final bool weeklyOvertime;
  final bool holidayPremium;
  final bool preciseBreakInput;
  final DeductionMode deductionMode;
  final int fourInsuranceRate;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
        'jobId': jobId,
        'weeklyHolidayAllowance': weeklyHolidayAllowance,
        'nightPremium': nightPremium,
        'dailyOvertime': dailyOvertime,
        'weeklyOvertime': weeklyOvertime,
        'holidayPremium': holidayPremium,
        'preciseBreakInput': preciseBreakInput,
        'deductionMode': deductionMode.name,
        'fourInsuranceRate': fourInsuranceRate,
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  factory JobPayrollOptionsJson.fromJson(Map<String, dynamic> json) =>
      JobPayrollOptionsJson(
        jobId: json['jobId'] as int,
        weeklyHolidayAllowance: json['weeklyHolidayAllowance'] as bool,
        nightPremium: json['nightPremium'] as bool,
        dailyOvertime: json['dailyOvertime'] as bool,
        weeklyOvertime: json['weeklyOvertime'] as bool,
        holidayPremium: json['holidayPremium'] as bool,
        preciseBreakInput: json['preciseBreakInput'] as bool,
        deductionMode:
            DeductionMode.values.byName(json['deductionMode'] as String),
        fourInsuranceRate: json['fourInsuranceRate'] as int,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}

class ShiftJson {
  const ShiftJson({
    required this.id,
    required this.jobId,
    required this.startAt,
    required this.endAt,
    required this.breakMinutes,
    required this.breakStartAt,
    required this.hourlyWageSnapshot,
    required this.memo,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int jobId;
  final DateTime startAt;
  final DateTime endAt;
  final int breakMinutes;
  final DateTime? breakStartAt;
  final int hourlyWageSnapshot;
  final String? memo;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'jobId': jobId,
        'startAt': startAt.toUtc().toIso8601String(),
        'endAt': endAt.toUtc().toIso8601String(),
        'breakMinutes': breakMinutes,
        if (breakStartAt != null)
          'breakStartAt': breakStartAt!.toUtc().toIso8601String(),
        'hourlyWageSnapshot': hourlyWageSnapshot,
        if (memo != null) 'memo': memo,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  factory ShiftJson.fromJson(Map<String, dynamic> json) => ShiftJson(
        id: json['id'] as int,
        jobId: json['jobId'] as int,
        startAt: DateTime.parse(json['startAt'] as String),
        endAt: DateTime.parse(json['endAt'] as String),
        breakMinutes: json['breakMinutes'] as int,
        breakStartAt: json['breakStartAt'] == null
            ? null
            : DateTime.parse(json['breakStartAt'] as String),
        hourlyWageSnapshot: json['hourlyWageSnapshot'] as int,
        memo: json['memo'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}

class AppSettingsJson {
  const AppSettingsJson({
    required this.schemaVersion,
    required this.themeMode,
    required this.locale,
    required this.lastBackupAt,
    required this.updatedAt,
  });

  final int schemaVersion;
  final ThemeModeSetting themeMode;
  final String locale;
  final DateTime? lastBackupAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'themeMode': themeMode.name,
        'locale': locale,
        if (lastBackupAt != null)
          'lastBackupAt': lastBackupAt!.toUtc().toIso8601String(),
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  factory AppSettingsJson.fromJson(Map<String, dynamic> json) =>
      AppSettingsJson(
        schemaVersion: json['schemaVersion'] as int,
        themeMode:
            ThemeModeSetting.values.byName(json['themeMode'] as String),
        locale: json['locale'] as String,
        lastBackupAt: json['lastBackupAt'] == null
            ? null
            : DateTime.parse(json['lastBackupAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}
