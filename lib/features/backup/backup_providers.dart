// SPDX-License-Identifier: GPL-3.0-only
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import 'backup_service.dart';

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(ref.watch(appDatabaseProvider));
});
