// SPDX-License-Identifier: GPL-3.0-only
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/repository/app_settings_repository.dart';
import '../domain/repository/job_repository.dart';
import '../domain/repository/plan_repository.dart';
import '../domain/repository/shift_repository.dart';
import 'db/app_database.dart';
import 'repository/drift_app_settings_repository.dart';
import 'repository/drift_job_repository.dart';
import 'repository/drift_plan_repository.dart';
import 'repository/drift_shift_repository.dart';

/// 앱 시작 시 main.dart에서 실제 DB 인스턴스로 override한다.
/// 테스트에서는 in-memory DB로 override.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError(
    'appDatabaseProvider must be overridden in ProviderScope',
  );
});

final jobRepositoryProvider = Provider<JobRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DriftJobRepository(db.jobDao);
});

final shiftRepositoryProvider = Provider<ShiftRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DriftShiftRepository(db.shiftDao);
});

final appSettingsRepositoryProvider = Provider<AppSettingsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DriftAppSettingsRepository(db.appSettingsDao);
});

final planRepositoryProvider = Provider<PlanRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DriftPlanRepository(db.planDao, db.shiftDao);
});
