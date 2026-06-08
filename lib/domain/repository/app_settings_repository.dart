// SPDX-License-Identifier: GPL-3.0-only
import '../entity/app_settings.dart';

abstract interface class AppSettingsRepository {
  Stream<AppSettings> watch();

  Future<AppSettings> read();

  Future<void> update(AppSettings settings);
}
