// SPDX-License-Identifier: GPL-3.0-only
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/money/money.dart';
import '../../core/palette/job_colors.dart';
import '../../domain/payroll/monthly_computation.dart';
import '../../l10n/generated/app_localizations.dart';
import 'monthly_report_bundle.dart';
import 'payroll_providers.dart';
import 'plan_providers.dart';
import 'schedule_providers.dart';
import 'year_month_picker.dart';

/// 선택된 월의 급여 명세 상세 페이지.
/// 전체 합산 + 근무처별 탭.
class MonthlyReportDetailPage extends ConsumerWidget {
  const MonthlyReportDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    // 보기용 plan: 페이지가 autoDispose이므로 진입 시 항상 0(메인)으로 리셋됨.
    final asyncBundle = ref.watch(reportBundleProvider);

    final l = AppLocalizations.of(context);
    return asyncBundle.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(l.reportTitle)),
        body: Center(child: Text(l.reportCalcError(e.toString()))),
      ),
      data: (bundle) => _DetailScaffold(month: month, bundle: bundle),
    );
  }
}

class _DetailScaffold extends ConsumerWidget {
  const _DetailScaffold({required this.month, required this.bundle});
  final DateTime month;
  final MonthlyReportBundle bundle;

  void _shift(WidgetRef ref, int delta) {
    final next = DateTime(month.year, month.month + delta);
    ref.read(selectedMonthProvider.notifier).set(next);
  }

  Future<void> _pickMonth(BuildContext context, WidgetRef ref) async {
    final picked = await pickYearMonth(context, initial: month);
    if (picked != null) {
      ref.read(selectedMonthProvider.notifier).set(picked);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final tabs = <Widget>[
      Tab(text: l.reportTabAll),
      for (final entry in bundle.perJob)
        Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 6,
                backgroundColor: JobColors.fromArgb(entry.job.colorArgb),
              ),
              const SizedBox(width: 6),
              Text(entry.job.name),
            ],
          ),
        ),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.reportTitle),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(140),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _ReportPlanSelector(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
                  child: Row(
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.chevron_left, size: 18),
                        label: Text(l.schedulePrevMonth),
                        onPressed: () => _shift(ref, -1),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => _pickMonth(context, ref),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat.yMMMM(l.localeName).format(month),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_drop_down, size: 22),
                                const SizedBox(width: 4),
                                Text(
                                  l.scheduleYearMonthMove,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.chevron_right, size: 18),
                        label: Text(l.scheduleNextMonth),
                        onPressed: () => _shift(ref, 1),
                      ),
                    ],
                  ),
                ),
                TabBar(
                  tabs: tabs,
                  isScrollable: bundle.perJob.isNotEmpty,
                  tabAlignment: bundle.perJob.isNotEmpty
                      ? TabAlignment.start
                      : TabAlignment.fill,
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _BreakdownView(
              computation: bundle.combined,
              jobLabel: bundle.perJob.isEmpty ? null : l.reportAllJobsCombined,
            ),
            for (final entry in bundle.perJob)
              _BreakdownView(
                computation: entry.computation,
                jobLabel: entry.job.name,
              ),
          ],
        ),
      ),
    );
  }
}

class _BreakdownView extends StatelessWidget {
  const _BreakdownView({required this.computation, this.jobLabel});
  final MonthlyComputation computation;
  final String? jobLabel;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final r = computation.report;
    final f = NumberFormat.decimalPattern(l.localeName);
    if (r.totalWorkMinutes == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            jobLabel == null
                ? l.reportNoRecords
                : l.reportNoRecordsJob(jobLabel!),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }
    final premiums = <_Item>[
      _Item(l.reportItemBasePay, l.reportItemBasePayHint, r.basePay),
      _Item(l.reportItemNight, l.reportItemNightHint, r.nightPremium),
      _Item(l.reportItemDailyOT, l.reportItemDailyOTHint, r.dailyOvertimePremium),
      _Item(l.reportItemWeeklyOT, l.reportItemWeeklyOTHint, r.weeklyOvertimePremium),
      _Item(l.reportItemHolidayWithin, l.reportItemHolidayWithinHint,
          r.holidayPremiumWithinThreshold),
      _Item(l.reportItemHolidayOver, l.reportItemHolidayOverHint,
          r.holidayPremiumOverThreshold),
      _Item(l.reportItemWeeklyHoliday, l.reportItemWeeklyHolidayHint,
          r.weeklyHolidayAllowance),
    ];
    final deductions = <_Item>[
      _Item(l.reportItemBusinessIncome, l.reportItemBusinessIncomeHint,
          r.businessIncomeWithholding),
      _Item(l.reportItemFourInsurance, l.reportItemFourInsuranceHint,
          r.fourInsuranceDeduction),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _NetCard(net: r.netPay, gross: r.grossPay, totalMinutes: r.totalWorkMinutes),
        const SizedBox(height: 16),
        _SectionTitle(l.reportPaymentItems),
        for (final item in premiums) _ItemRow(item: item),
        const Divider(height: 32),
        _RowKV(label: l.reportGrossLabel,
            value: l.reportTotalAmount(f.format(r.grossPay.won)),
            emphasize: true),
        if (r.totalDeduction.won > 0) ...[
          const SizedBox(height: 16),
          _SectionTitle(l.reportDeductionItems),
          for (final item in deductions)
            if (item.amount.won > 0) _ItemRow(item: item),
          const Divider(height: 32),
          _RowKV(
              label: l.reportTotalDeductionLabel,
              value: l.reportNegativeAmount(f.format(r.totalDeduction.won)),
              emphasize: true),
        ],
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(
                l.reportNetLabel,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              Text(
                l.reportTotalAmount(f.format(r.netPay.won)),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l.reportFootnote,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _Item {
  const _Item(this.title, this.hint, this.amount);
  final String title;
  final String hint;
  final Money amount;
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});
  final _Item item;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final f = NumberFormat.decimalPattern(l.localeName);
    final isZero = item.amount.won == 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    color: isZero ? scheme.onSurfaceVariant : null,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  item.hint,
                  style: TextStyle(
                    fontSize: 11,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            l.reportTotalAmount(f.format(item.amount.won)),
            style: TextStyle(
              color: isZero ? scheme.onSurfaceVariant : null,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _RowKV extends StatelessWidget {
  const _RowKV({
    required this.label,
    required this.value,
    this.emphasize = false,
  });
  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final style = emphasize
        ? Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            )
        : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: style),
          const Spacer(),
          Text(
            value,
            style: style?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _NetCard extends StatelessWidget {
  const _NetCard({
    required this.net,
    required this.gross,
    required this.totalMinutes,
  });
  final Money net;
  final Money gross;
  final int totalMinutes;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final f = NumberFormat.decimalPattern(l.localeName);
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.reportWorkTimeLabel(h, m == 0 ? '' : l.reportWorkMinutesSuffix(m)),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l.reportTotalAmount(f.format(net.won)),
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
          ),
          if (gross.won != net.won)
            Text(
              l.scheduleGrossBefore(f.format(gross.won)),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}

/// 진입 헬퍼.
void pushMonthlyReportDetail(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const MonthlyReportDetailPage()),
  );
}

/// 급여 명세서 상단의 보기 plan 선택자.
/// 기본값 메인. 활성 plan과 독립 — 페이지 닫으면 리셋.
class _ReportPlanSelector extends ConsumerWidget {
  const _ReportPlanSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final selected = ref.watch(reportPlanIdProvider);
    final mocksAsync = ref.watch(mockPlansForSelectedMonthProvider);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.surfaceContainerLow,
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Row(
        children: [
          const Icon(Icons.layers_outlined, size: 16),
          const SizedBox(width: 8),
          Text(l.reportViewPrefix, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 8),
          ChoiceChip(
            label: Text(l.planMain),
            selected: selected == 0,
            onSelected: (_) =>
                ref.read(reportPlanIdProvider.notifier).set(0),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: mocksAsync.maybeWhen(
              data: (mocks) {
                if (mocks.isEmpty) {
                  return Text(
                    l.reportNoMockThisMonth,
                    style: TextStyle(
                      fontSize: 11,
                      color: scheme.onSurfaceVariant,
                    ),
                  );
                }
                return SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: mocks.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 6),
                    itemBuilder: (ctx, i) {
                      final m = mocks[i];
                      return ChoiceChip(
                        label: Text(m.name),
                        selected: selected == m.id,
                        onSelected: (_) => ref
                            .read(reportPlanIdProvider.notifier)
                            .set(m.id),
                        visualDensity: VisualDensity.compact,
                      );
                    },
                  ),
                );
              },
              orElse: () => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
