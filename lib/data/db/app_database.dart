import 'package:drift/drift.dart';

import '../dao/app_settings_dao.dart';
import '../dao/job_dao.dart';
import '../dao/shift_dao.dart';
import 'tables.dart';

part 'app_database.g.dart';

const int kCurrentSchemaVersion = 2;

@DriftDatabase(
  tables: [Jobs, JobPayrollOptionsTable, Shifts, AppSettingsTable],
  daos: [JobDao, ShiftDao, AppSettingsDao],
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
