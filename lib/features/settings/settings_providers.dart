import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../domain/entity/app_settings.dart';

/// AppSettings stream — UI에서 watch.
final appSettingsProvider = StreamProvider<AppSettings>((ref) {
  final repo = ref.watch(appSettingsRepositoryProvider);
  return repo.watch();
});

/// AppSettings.themeMode를 Flutter의 ThemeMode로 매핑. seed 전(loading 등)에는 light.
final themeModeProvider = Provider<ThemeMode>((ref) {
  final async = ref.watch(appSettingsProvider);
  return async.maybeWhen(
    data: (s) => switch (s.themeMode) {
      ThemeModeSetting.system => ThemeMode.system,
      ThemeModeSetting.light => ThemeMode.light,
      ThemeModeSetting.dark => ThemeMode.dark,
    },
    orElse: () => ThemeMode.light,
  );
});

/// 24시간 형식 표시 여부. 기본 false (오전/오후).
final use24HourFormatProvider = Provider<bool>((ref) {
  final async = ref.watch(appSettingsProvider);
  return async.maybeWhen(data: (s) => s.use24HourFormat, orElse: () => false);
});
