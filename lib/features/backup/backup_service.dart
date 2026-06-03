import 'dart:convert';

import 'package:drift/drift.dart';

import '../../data/db/app_database.dart';
import '../../domain/entity/app_settings.dart' show ThemeModeSetting;
import '../../domain/entity/business_size.dart';
import '../../domain/entity/deduction_mode.dart';
import '../../domain/entity/income_type.dart';
import 'backup_format.dart';

const String _kAppVersion = '1.0.0';

class IncompatibleBackupException implements Exception {
  IncompatibleBackupException(this.backupVersion, this.appVersion);
  final int backupVersion;
  final int appVersion;

  @override
  String toString() =>
      '백업 파일의 스키마 버전($backupVersion)이 현재 앱($appVersion)과 달라 가져올 수 없어요.';
}

class BackupImportResult {
  const BackupImportResult({
    required this.jobs,
    required this.shifts,
  });
  final int jobs;
  final int shifts;
}

class BackupService {
  BackupService(this._db);
  final AppDatabase _db;

  /// 모든 테이블을 JSON 문자열로 직렬화. 들여쓰기 포함 (사람이 읽을 수 있게).
  Future<String> exportToJson() async {
    final jobs = await _db.select(_db.jobs).get();
    final options = await _db.select(_db.jobPayrollOptionsTable).get();
    final shifts = await _db.select(_db.shifts).get();
    final settings = await _db.appSettingsDao.read();

    final data = BackupData(
      schemaVersion: kCurrentSchemaVersion,
      appVersion: _kAppVersion,
      exportedAt: DateTime.now().toUtc(),
      jobs: [
        for (final j in jobs)
          JobJson(
            id: j.id,
            name: j.name,
            hourlyWage: j.hourlyWage,
            incomeType: IncomeType.values.byName(j.incomeType),
            businessSize: BusinessSize.values.byName(j.businessSize),
            colorArgb: j.colorArgb,
            archived: j.archived,
            createdAt: j.createdAt,
            updatedAt: j.updatedAt,
          ),
      ],
      jobPayrollOptions: [
        for (final o in options)
          JobPayrollOptionsJson(
            jobId: o.jobId,
            weeklyHolidayAllowance: o.weeklyHolidayAllowance,
            nightPremium: o.nightPremium,
            dailyOvertime: o.dailyOvertime,
            weeklyOvertime: o.weeklyOvertime,
            holidayPremium: o.holidayPremium,
            preciseBreakInput: o.preciseBreakInput,
            deductionMode: DeductionMode.values.byName(o.deductionMode),
            fourInsuranceRate: o.fourInsuranceRate,
            updatedAt: o.updatedAt,
          ),
      ],
      shifts: [
        for (final s in shifts)
          ShiftJson(
            id: s.id,
            jobId: s.jobId,
            startAt: s.startAt,
            endAt: s.endAt,
            breakMinutes: s.breakMinutes,
            breakStartAt: s.breakStartAt,
            hourlyWageSnapshot: s.hourlyWageSnapshot,
            memo: s.memo,
            createdAt: s.createdAt,
            updatedAt: s.updatedAt,
          ),
      ],
      appSettings: AppSettingsJson(
        schemaVersion: settings.schemaVersion,
        themeMode: ThemeModeSetting.values.byName(settings.themeMode),
        locale: settings.locale,
        lastBackupAt: settings.lastBackupAt,
        updatedAt: settings.updatedAt,
      ),
    );

    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(data.toJson());
  }

  /// JSON을 검증해 BackupData로 파싱. import 전에 실행해 무결성 검증 가능.
  BackupData parse(String jsonStr) {
    final Map<String, dynamic> raw =
        jsonDecode(jsonStr) as Map<String, dynamic>;
    final data = BackupData.fromJson(raw);
    if (data.schemaVersion != kCurrentSchemaVersion) {
      throw IncompatibleBackupException(
          data.schemaVersion, kCurrentSchemaVersion);
    }
    return data;
  }

  /// 백업 데이터를 DB로 복원. 기존 데이터는 모두 삭제 후 교체 (REPLACE).
  /// 트랜잭션 — 부분 실패 시 rollback.
  Future<BackupImportResult> import(BackupData data) async {
    if (data.schemaVersion != kCurrentSchemaVersion) {
      throw IncompatibleBackupException(
          data.schemaVersion, kCurrentSchemaVersion);
    }

    return _db.transaction(() async {
      // 종속성 역순으로 삭제 (FK 안전)
      await _db.delete(_db.shifts).go();
      await _db.delete(_db.jobPayrollOptionsTable).go();
      await _db.delete(_db.jobs).go();

      // jobs는 FK 부모 — 먼저 삽입
      for (final j in data.jobs) {
        await _db.into(_db.jobs).insert(
              JobsCompanion.insert(
                id: Value(j.id),
                name: j.name,
                hourlyWage: j.hourlyWage,
                incomeType: j.incomeType.name,
                businessSize: j.businessSize.name,
                colorArgb: j.colorArgb,
                archived: Value(j.archived),
                createdAt: j.createdAt,
                updatedAt: j.updatedAt,
              ),
            );
      }
      for (final o in data.jobPayrollOptions) {
        await _db.into(_db.jobPayrollOptionsTable).insert(
              JobPayrollOptionsTableCompanion.insert(
                jobId: Value(o.jobId),
                weeklyHolidayAllowance: Value(o.weeklyHolidayAllowance),
                nightPremium: Value(o.nightPremium),
                dailyOvertime: Value(o.dailyOvertime),
                weeklyOvertime: Value(o.weeklyOvertime),
                holidayPremium: Value(o.holidayPremium),
                preciseBreakInput: Value(o.preciseBreakInput),
                deductionMode: Value(o.deductionMode.name),
                fourInsuranceRate: Value(o.fourInsuranceRate),
                updatedAt: o.updatedAt,
              ),
            );
      }
      for (final s in data.shifts) {
        await _db.into(_db.shifts).insert(
              ShiftsCompanion.insert(
                id: Value(s.id),
                jobId: s.jobId,
                startAt: s.startAt,
                endAt: s.endAt,
                breakMinutes: Value(s.breakMinutes),
                breakStartAt: Value(s.breakStartAt),
                hourlyWageSnapshot: s.hourlyWageSnapshot,
                memo: Value(s.memo),
                createdAt: s.createdAt,
                updatedAt: s.updatedAt,
              ),
            );
      }
      // AppSettings는 single-row upsert (id=1)
      await _db.appSettingsDao.save(
        AppSettingsTableCompanion(
          id: const Value(1),
          schemaVersion: Value(data.appSettings.schemaVersion),
          themeMode: Value(data.appSettings.themeMode.name),
          locale: Value(data.appSettings.locale),
          lastBackupAt: Value(data.appSettings.lastBackupAt),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );

      return BackupImportResult(
        jobs: data.jobs.length,
        shifts: data.shifts.length,
      );
    });
  }

  /// AppSettings에 lastBackupAt 기록.
  Future<void> markBackedUp(DateTime at) async {
    final settings = await _db.appSettingsDao.read();
    await _db.appSettingsDao.save(
      AppSettingsTableCompanion(
        id: const Value(1),
        schemaVersion: Value(settings.schemaVersion),
        themeMode: Value(settings.themeMode),
        locale: Value(settings.locale),
        lastBackupAt: Value(at),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }
}
