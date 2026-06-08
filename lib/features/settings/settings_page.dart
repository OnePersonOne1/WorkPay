// SPDX-License-Identifier: GPL-3.0-only
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../domain/entity/app_settings.dart';
import '../../l10n/generated/app_localizations.dart';
import '../backup/backup_page.dart';
import 'advanced_settings_page.dart';
import 'settings_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final asyncSettings = ref.watch(appSettingsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: asyncSettings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (settings) => ListView(
          children: [
            _SectionHeader(l.settingsSectionLanguage),
            _LocaleTile(current: settings.locale),
            _SectionHeader(l.settingsSectionTheme),
            _ThemeModeTile(current: settings.themeMode),
            _SectionHeader(l.settingsSectionTimeFormat),
            _TimeFormatTile(use24: settings.use24HourFormat),
            _SectionHeader(l.settingsSectionPayroll),
            _LaborLawTile(value: settings.koreanLaborLawCompliance),
            if (settings.koreanLaborLawCompliance) const _AdvancedTile(),
            _SectionHeader(l.settingsSectionBackup),
            const _BackupTile(),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _LocaleTile extends ConsumerWidget {
  const _LocaleTile({required this.current});
  final String current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final isKo = current == 'ko';
    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(l.settingsSectionLanguage),
      subtitle: Text(isKo ? l.settingsLanguageKo : l.settingsLanguageEn),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final picked = await showModalBottomSheet<String>(
          context: context,
          showDragHandle: true,
          builder: (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(l.settingsLanguageKo),
                  trailing: isKo ? const Icon(Icons.check) : null,
                  onTap: () => Navigator.of(ctx).pop('ko'),
                ),
                ListTile(
                  title: Text(l.settingsLanguageEn),
                  trailing: !isKo ? const Icon(Icons.check) : null,
                  onTap: () => Navigator.of(ctx).pop('en'),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
        if (picked != null && picked != current) {
          final repo = ref.read(appSettingsRepositoryProvider);
          final settings = await repo.read();
          // 영어로 전환 시 노동법 모드도 OFF (사용자가 다시 켤 수 있음).
          // 한국어로 전환 시 그대로 둠 (다국적 사용자 가능).
          await repo.update(
            settings.copyWith(
              locale: picked,
              koreanLaborLawCompliance: picked == 'en'
                  ? false
                  : settings.koreanLaborLawCompliance,
              updatedAt: DateTime.now().toUtc(),
            ),
          );
        }
      },
    );
  }
}

class _ThemeModeTile extends ConsumerWidget {
  const _ThemeModeTile({required this.current});
  final ThemeModeSetting current;

  String _label(AppLocalizations l, ThemeModeSetting m) => switch (m) {
        ThemeModeSetting.system => l.settingsThemeSystem,
        ThemeModeSetting.light => l.settingsThemeLight,
        ThemeModeSetting.dark => l.settingsThemeDark,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return ListTile(
      leading: const Icon(Icons.brightness_6_outlined),
      title: Text(l.settingsSectionTheme),
      subtitle: Text(_label(l, current)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final selected = await showModalBottomSheet<ThemeModeSetting>(
          context: context,
          showDragHandle: true,
          builder: (ctx) {
            final lc = AppLocalizations.of(ctx);
            return SafeArea(
              child: RadioGroup<ThemeModeSetting>(
                groupValue: current,
                onChanged: (m) => Navigator.of(ctx).pop(m),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Text(
                        lc.settingsSectionTheme,
                        style: Theme.of(ctx).textTheme.titleMedium,
                      ),
                    ),
                    for (final mode in ThemeModeSetting.values)
                      RadioListTile<ThemeModeSetting>(
                        value: mode,
                        title: Text(_label(lc, mode)),
                      ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
        if (selected != null && selected != current) {
          final repo = ref.read(appSettingsRepositoryProvider);
          final settings = await repo.read();
          await repo.update(
            settings.copyWith(
              themeMode: selected,
              updatedAt: DateTime.now().toUtc(),
            ),
          );
        }
      },
    );
  }
}

class _TimeFormatTile extends ConsumerWidget {
  const _TimeFormatTile({required this.use24});
  final bool use24;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return SwitchListTile(
      secondary: const Icon(Icons.access_time),
      title: Text(l.settingsUse24Hour),
      subtitle: Text(
        use24 ? '18:30' : l.settingsUse12Hour,
        style: const TextStyle(fontSize: 12),
      ),
      value: use24,
      onChanged: (v) async {
        final repo = ref.read(appSettingsRepositoryProvider);
        final settings = await repo.read();
        await repo.update(
          settings.copyWith(
            use24HourFormat: v,
            updatedAt: DateTime.now().toUtc(),
          ),
        );
      },
    );
  }
}

class _LaborLawTile extends ConsumerWidget {
  const _LaborLawTile({required this.value});
  final bool value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return SwitchListTile(
      secondary: const Icon(Icons.gavel_outlined),
      title: Text(l.settingsLaborLaw),
      subtitle: Text(
        l.settingsLaborLawHint,
        style: const TextStyle(fontSize: 12),
      ),
      isThreeLine: true,
      value: value,
      onChanged: (v) async {
        final repo = ref.read(appSettingsRepositoryProvider);
        final settings = await repo.read();
        await repo.update(
          settings.copyWith(
            koreanLaborLawCompliance: v,
            updatedAt: DateTime.now().toUtc(),
          ),
        );
      },
    );
  }
}

class _BackupTile extends StatelessWidget {
  const _BackupTile();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListTile(
      leading: const Icon(Icons.cloud_off_outlined),
      title: Text(l.settingsBackupAndRestore),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const BackupPage()),
        );
      },
    );
  }
}

class _AdvancedTile extends StatelessWidget {
  const _AdvancedTile();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListTile(
      leading: const Icon(Icons.tune),
      title: Text(l.settingsAdvancedConstants),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const AdvancedSettingsPage(),
          ),
        );
      },
    );
  }
}
