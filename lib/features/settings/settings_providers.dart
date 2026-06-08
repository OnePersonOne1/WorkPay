// SPDX-License-Identifier: GPL-3.0-only
import 'package:flutter/material.dart' show Locale, ThemeMode;
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

/// MaterialApp에 전달할 locale. AppSettings.locale 기반.
final localeProvider = Provider<Locale>((ref) {
  final async = ref.watch(appSettingsProvider);
  return async.maybeWhen(
    data: (s) => Locale(s.locale),
    orElse: () => const Locale('ko'),
  );
});

/// 한국 노동법 준수 모드. ON이면 야간/연장/주휴/공제 등 노출 + 계산 반영.
/// 기본 true (DB column default). 로드 전엔 true.
final koreanLaborLawComplianceProvider = Provider<bool>((ref) {
  final async = ref.watch(appSettingsProvider);
  return async.maybeWhen(
    data: (s) => s.koreanLaborLawCompliance,
    orElse: () => true,
  );
});
