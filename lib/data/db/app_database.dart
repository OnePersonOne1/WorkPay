// SPDX-License-Identifier: GPL-3.0-only
import 'package:drift/drift.dart';

import '../dao/app_settings_dao.dart';
import '../dao/job_dao.dart';
import '../dao/plan_dao.dart';
import '../dao/shift_dao.dart';
import 'tables.dart';

part 'app_database.g.dart';

const int kCurrentSchemaVersion = 6;

@DriftDatabase(
  tables: [Jobs, JobPayrollOptionsTable, Shifts, AppSettingsTable, Plans],
  daos: [JobDao, ShiftDao, AppSettingsDao, PlanDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => kCurrentSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // v2: app_settings에 payrollConstantsJson 컬럼 추가
            await m.addColumn(
              appSettingsTable,
              appSettingsTable.payrollConstantsJson,
            );
          }
          if (from < 3) {
            // v3: app_settings에 use24HourFormat 컬럼 추가
            await m.addColumn(
              appSettingsTable,
              appSettingsTable.use24HourFormat,
            );
          }
          if (from < 4) {
            // v4: app_settings에 undoStackJson 컬럼 추가
            await m.addColumn(
              appSettingsTable,
              appSettingsTable.undoStackJson,
            );
          }
          if (from < 5) {
            // v5: plans 테이블 + shifts.planId + app_settings.activePlanId
            await m.createTable(plans);
            await m.addColumn(shifts, shifts.planId);
            await m.addColumn(
              appSettingsTable,
              appSettingsTable.activePlanId,
            );
          }
          if (from < 6) {
            // v6: app_settings에 koreanLaborLawCompliance 컬럼 추가
            // 기존 사용자는 한국인 가정 → 기본 true (현재 동작 그대로)
            await m.addColumn(
              appSettingsTable,
              appSettingsTable.koreanLaborLawCompliance,
            );
          }
        },
        onCreate: (m) async {
          await m.createAll();
          // 인덱스: 월간 시프트 조회 최적화
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_shifts_start_at ON shifts (start_at)',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_shifts_job_id_start_at ON shifts (job_id, start_at)',
          );
          // AppSettings seed (id=1 강제). 기본 테마는 라이트.
          final now = DateTime.now().toUtc();
          await into(appSettingsTable).insert(
            AppSettingsTableCompanion.insert(
              id: const Value(1),
              schemaVersion: kCurrentSchemaVersion,
              themeMode: const Value('light'),
              updatedAt: now,
            ),
          );
        },
        beforeOpen: (details) async {
          // FK 강제 활성화 (drift 기본은 OFF)
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
