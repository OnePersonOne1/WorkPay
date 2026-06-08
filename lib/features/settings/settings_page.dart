import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../domain/entity/app_settings.dart';
import '../backup/backup_page.dart';
import 'advanced_settings_page.dart';
import 'settings_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSettings = ref.watch(appSettingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: asyncSettings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('설정 로드 오류: $e')),
        data: (settings) => ListView(
          children: [
            const _SectionHeader('화면'),
            _ThemeModeTile(current: settings.themeMode),
            _TimeFormatTile(use24: settings.use24HourFormat),
            const _SectionHeader('데이터'),
            const _BackupTile(),
            const _SectionHeader('고급'),
            const _AdvancedTile(),
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

class _ThemeModeTile extends ConsumerWidget {
  const _ThemeModeTile({required this.current});
  final ThemeModeSetting current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.brightness_6_outlined),
      title: const Text('테마'),
      subtitle: Text(current.label),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final selected = await showModalBottomSheet<ThemeModeSetting>(
          context: context,
          showDragHandle: true,
          builder: (ctx) => SafeArea(
            child: RadioGroup<ThemeModeSetting>(
              groupValue: current,
              onChanged: (m) => Navigator.of(ctx).pop(m),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      '테마 선택',
                      style: Theme.of(ctx).textTheme.titleMedium,
                    ),
                  ),
                  for (final mode in ThemeModeSetting.values)
                    RadioListTile<ThemeModeSetting>(
                      value: mode,
                      title: Text(mode.label),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
        if (selected != null && selected != current) {
          final repo = ref.read(appSettingsRepositoryProvider);
          final settings = await repo.read();
          await repo.update(
            settings.copyWith(themeMode: selected, updatedAt: DateTime.now().toUtc()),
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
    return SwitchListTile(
      secondary: const Icon(Icons.access_time),
      title: const Text('24시간 형식'),
      subtitle: Text(
        use24 ? '예: 18:30 (기본)' : '예: 오후 6:30',
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

class _BackupTile extends StatelessWidget {
  const _BackupTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.cloud_off_outlined),
      title: const Text('백업 및 복원'),
      subtitle: const Text('JSON 파일로 내보내기 / 가져오기'),
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
    return ListTile(
      leading: const Icon(Icons.tune),
      title: const Text('고급 설정'),
      subtitle: const Text('야간 시간대, 가산율, 세율 등 글로벌 상수'),
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
