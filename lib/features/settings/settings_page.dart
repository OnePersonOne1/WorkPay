import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../domain/entity/app_settings.dart';
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
            // 근무처 관리는 일정표 상단으로 이동.
            // 추후: 고급 옵션 (Phase 6), 백업 (Phase 6)
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
