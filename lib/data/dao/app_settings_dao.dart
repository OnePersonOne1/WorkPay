import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../db/tables.dart';

part 'app_settings_dao.g.dart';

@DriftAccessor(tables: [AppSettingsTable])
class AppSettingsDao extends DatabaseAccessor<AppDatabase>
    with _$AppSettingsDaoMixin {
  AppSettingsDao(super.db);

  Stream<AppSettingsTableData> watch() {
    return (select(appSettingsTable)..where((s) => s.id.equals(1)))
        .watchSingle();
  }

  Future<AppSettingsTableData> read() {
    return (select(appSettingsTable)..where((s) => s.id.equals(1))).getSingle();
  }

  Future<void> save(AppSettingsTableCompanion settings) {
    return (update(appSettingsTable)..where((s) => s.id.equals(1)))
        .write(settings);
  }
}
