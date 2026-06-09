// SPDX-License-Identifier: GPL-3.0-only
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../domain/entity/plan.dart';
import '../../l10n/generated/app_localizations.dart';
import 'plan_providers.dart';
import 'schedule_providers.dart';
import 'undo_controller.dart';

/// 캘린더 위 plan 선택자 + 액션 row.
class PlanSelectorBar extends ConsumerWidget {
  const PlanSelectorBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePlanAsync = ref.watch(activePlanProvider);
    final mocksAsync = ref.watch(mockPlansForSelectedMonthProvider);
    final scheme = Theme.of(context).colorScheme;
    final month = ref.watch(selectedMonthProvider);

    return Container(
      color: scheme.surfaceContainerLow,
      padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
      child: activePlanAsync.maybeWhen(
        data: (active) => mocksAsync.maybeWhen(
          data: (mocks) => _Row(active: active, mocks: mocks, month: month),
          orElse: () => _Row(active: active, mocks: const [], month: month),
        ),
        orElse: () => const SizedBox(
          height: 36,
          child: Center(child: LinearProgressIndicator()),
        ),
      ),
    );
  }
}

class _Row extends ConsumerWidget {
  const _Row({required this.active, required this.mocks, required this.month});
  final Plan active;
  final List<Plan> mocks;
  final DateTime month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Row(
      children: [
        const Icon(Icons.layers_outlined, size: 18),
        const SizedBox(width: 8),
        ChoiceChip(
          label: Text(l.planMain),
          selected: active.isMain,
          onSelected: (_) => _setActivePlan(ref, 0),
          visualDensity: VisualDensity.compact,
        ),
        const SizedBox(width: 6),
        _MocksMenu(active: active, mocks: mocks, month: month),
        const Spacer(),
        if (!active.isMain) ...[
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: l.planLoadFromMain,
            onPressed: () => _loadFromMain(context, ref, active),
          ),
          IconButton(
            icon: const Icon(Icons.publish),
            tooltip: l.planReplaceMain(active.name),
            onPressed: () => _replaceMain(context, ref, active),
          ),
        ],
      ],
    );
  }

  Future<void> _loadFromMain(
    BuildContext context,
    WidgetRef ref,
    Plan active,
  ) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final lc = AppLocalizations.of(ctx);
        return AlertDialog(
          title: Text(lc.planLoadConfirmTitle),
          content: Text(lc.planLoadConfirmBody(
              active.year, active.month, active.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(lc.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(lc.actionLoad),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;
    await ref.read(undoControllerProvider.notifier).snapshotBefore(
          year: active.year,
          month: active.month,
          planId: active.id,
          description: l.planLoadSnap(active.name),
        );
    final count = await ref.read(shiftRepositoryProvider).copyMonthBetweenPlans(
          sourcePlanId: 0,
          targetPlanId: active.id,
          year: active.year,
          month: active.month,
        );
    messenger.showSnackBar(SnackBar(content: Text(l.planLoadDone(count))));
  }

  Future<void> _replaceMain(
    BuildContext context,
    WidgetRef ref,
    Plan active,
  ) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final lc = AppLocalizations.of(ctx);
        return AlertDialog(
          title: Text(lc.planReplaceConfirmTitle(active.name)),
          content: Text(lc.planReplaceConfirmBody(
              active.year, active.month, active.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(lc.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(lc.actionReplace),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;
    await ref.read(undoControllerProvider.notifier).snapshotBefore(
          year: active.year,
          month: active.month,
          planId: 0,
          description: l.planReplaceSnap(active.year, active.month, active.name),
        );
    final count = await ref.read(shiftRepositoryProvider).copyMonthBetweenPlans(
          sourcePlanId: active.id,
          targetPlanId: 0,
          year: active.year,
          month: active.month,
        );
    messenger.showSnackBar(
      SnackBar(content: Text(l.planReplaceDone(active.name, count))),
    );
  }
}

class _MocksMenu extends ConsumerWidget {
  const _MocksMenu({
    required this.active,
    required this.mocks,
    required this.month,
  });
  final Plan active;
  final List<Plan> mocks;
  final DateTime month;

  static const _kAddSentinel = -1;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final label = active.isMain ? l.planSelectMock : active.name;
    return PopupMenuButton<int>(
      tooltip: l.planSelectTooltip,
      onSelected: (v) async {
        if (v == _kAddSentinel) {
          await _createNewMock(context, ref);
        } else {
          await _setActivePlan(ref, v);
        }
      },
      itemBuilder: (ctx) {
        final lc = AppLocalizations.of(ctx);
        return <PopupMenuEntry<int>>[
          if (mocks.isEmpty)
            PopupMenuItem<int>(
              enabled: false,
              child: Text(lc.planNoneThisMonth),
            )
          else
            for (final m in mocks)
              PopupMenuItem<int>(
                value: m.id,
                padding: const EdgeInsets.only(left: 16, right: 4),
                child: Row(
                  children: [
                    if (m.id == active.id)
                      const Icon(Icons.check, size: 16)
                    else
                      const SizedBox(width: 16),
                    const SizedBox(width: 6),
                    Expanded(child: Text(m.name)),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      tooltip: lc.planMockDeleteTooltip,
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _confirmDelete(context, ref, m);
                      },
                    ),
                  ],
                ),
              ),
          const PopupMenuDivider(),
          PopupMenuItem<int>(
            value: _kAddSentinel,
            child: Row(
              children: [
                const Icon(Icons.add, size: 18),
                const SizedBox(width: 6),
                Text(lc.planNewMock(month.month)),
              ],
            ),
          ),
        ];
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active.isMain
              ? scheme.surfaceContainerHighest
              : scheme.secondaryContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: active.isMain
                    ? scheme.onSurfaceVariant
                    : scheme.onSecondaryContainer,
                fontWeight: active.isMain ? FontWeight.normal : FontWeight.w600,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: active.isMain
                  ? scheme.onSurfaceVariant
                  : scheme.onSecondaryContainer,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createNewMock(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final mocksList = await ref
        .read(planRepositoryProvider)
        .watchForMonth(month.year, month.month)
        .first;
    final n = nextMockNumber(mocksList, l);
    final name = l.planAutoName(month.month, n);
    final planRepo = ref.read(planRepositoryProvider);
    final newPlan = await planRepo.create(
      year: month.year,
      month: month.month,
      name: name,
    );
    final shiftRepo = ref.read(shiftRepositoryProvider);
    final copied = await shiftRepo.copyMonthBetweenPlans(
      sourcePlanId: 0,
      targetPlanId: newPlan.id,
      year: month.year,
      month: month.month,
    );
    await _setActivePlan(ref, newPlan.id);
    messenger.showSnackBar(
      SnackBar(content: Text(l.planMockCreated(name, copied))),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Plan mock,
  ) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final lc = AppLocalizations.of(ctx);
        return AlertDialog(
          title: Text(lc.planMockDeleteTitle),
          content: Text(lc.planMockDeleteBody(mock.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(lc.actionCancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(lc.actionDelete),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;

    await ref.read(undoControllerProvider.notifier).snapshotBeforePlanDeletion(
          plan: mock,
          description: l.planMockDeleteSnap(mock.name),
        );
    final settings =
        await ref.read(appSettingsRepositoryProvider).read();
    if (settings.activePlanId == mock.id) {
      await ref.read(appSettingsRepositoryProvider).update(
            settings.copyWith(
              activePlanId: 0,
              updatedAt: DateTime.now().toUtc(),
            ),
          );
    }
    await ref.read(planRepositoryProvider).delete(mock.id);
    messenger.showSnackBar(
      SnackBar(content: Text(l.planMockDeleted(mock.name))),
    );
  }
}

Future<void> _setActivePlan(WidgetRef ref, int id) async {
  final repo = ref.read(appSettingsRepositoryProvider);
  final settings = await repo.read();
  if (settings.activePlanId == id) return;
  await repo.update(
    settings.copyWith(
      activePlanId: id,
      updatedAt: DateTime.now().toUtc(),
    ),
  );
}

/// 다음 모의안 번호 — 같은 locale의 planAutoName 패턴에서 N을 추출해 max+1.
int nextMockNumber(List<Plan> existing, AppLocalizations l) {
  var maxN = 0;
  // 패턴 끝의 숫자 추출 (단순 정규식)
  final re = RegExp(r'(\d+)\s*$');
  for (final p in existing) {
    final m = re.firstMatch(p.name);
    if (m != null) {
      final n = int.tryParse(m.group(1)!);
      if (n != null && n > maxN) maxN = n;
    }
  }
  return maxN + 1;
}
