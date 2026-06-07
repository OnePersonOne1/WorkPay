import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/money/money.dart';
import '../../core/palette/job_colors.dart';
import '../../domain/payroll/monthly_computation.dart';
import 'monthly_report_bundle.dart';
import 'payroll_providers.dart';
import 'schedule_providers.dart';
import 'year_month_picker.dart';

/// 선택된 월의 급여 명세 상세 페이지.
/// 전체 합산 + 근무처별 탭.
class MonthlyReportDetailPage extends ConsumerWidget {
  const MonthlyReportDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final asyncBundle = ref.watch(monthlyReportBundleProvider);

    return asyncBundle.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('급여 명세')),
        body: Center(child: Text('계산 오류: $e')),
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
    final tabs = <Widget>[
      const Tab(text: '전체'),
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
          title: InkWell(
            onTap: () => _pickMonth(context, ref),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${month.year}년 ${month.month}월 급여 명세'),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, size: 22),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              tooltip: '이전 달',
              onPressed: () => _shift(ref, -1),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              tooltip: '다음 달',
              onPressed: () => _shift(ref, 1),
            ),
            const SizedBox(width: 4),
          ],
          bottom: TabBar(
            tabs: tabs,
            isScrollable: bundle.perJob.isNotEmpty,
            tabAlignment: bundle.perJob.isNotEmpty
                ? TabAlignment.start
                : TabAlignment.fill,
          ),
        ),
        body: TabBarView(
          children: [
            _BreakdownView(
              computation: bundle.combined,
              jobLabel: bundle.perJob.isEmpty ? null : '모든 근무처 합산',
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
    final r = computation.report;
    final f = NumberFormat.decimalPattern('ko_KR');
    if (r.totalWorkMinutes == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            jobLabel == null
                ? '이 달에 근무 기록이 없어요'
                : '$jobLabel — 이 달에 근무 기록이 없어요',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }
    final premiums = <_Item>[
      _Item('기본급', '근무 시간 × 시급', r.basePay),
      _Item('야간 가산수당', '22:00~06:00 근무에 +50%', r.nightPremium),
      _Item('일 연장 가산수당', '하루 8h 초과분에 +50%', r.dailyOvertimePremium),
      _Item('주 연장 가산수당', '주 40h 초과분에 +50% (일 OT와 중복 안 됨)',
          r.weeklyOvertimePremium),
      _Item('휴일근로 가산수당 (≤8h)', '휴일 근무 8시간 이내 +50%',
          r.holidayPremiumWithinThreshold),
      _Item('휴일근로 가산수당 (>8h)', '휴일 근무 8시간 초과분 +100%',
          r.holidayPremiumOverThreshold),
      _Item('주휴수당', '주 15h+ 결근 없을 때 1일분', r.weeklyHolidayAllowance),
    ];
    final deductions = <_Item>[
      _Item('사업소득 원천징수', '3.3% (소득세 + 지방소득세)', r.businessIncomeWithholding),
      _Item('4대보험', '국민연금 + 건강 + 고용 + 장기요양', r.fourInsuranceDeduction),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _NetCard(net: r.netPay, gross: r.grossPay, totalMinutes: r.totalWorkMinutes),
        const SizedBox(height: 16),
        _SectionTitle('지급 항목'),
        for (final item in premiums) _ItemRow(item: item),
        const Divider(height: 32),
        _RowKV(label: '총 지급 (gross)', value: '${f.format(r.grossPay.won)}원',
            emphasize: true),
        if (r.totalDeduction.won > 0) ...[
          const SizedBox(height: 16),
          _SectionTitle('공제 항목'),
          for (final item in deductions)
            if (item.amount.won > 0) _ItemRow(item: item),
          const Divider(height: 32),
          _RowKV(label: '총 공제', value: '-${f.format(r.totalDeduction.won)}원',
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
                '실수령',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              Text(
                '${f.format(r.netPay.won)}원',
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
          '* 일급 표시는 기본급+야간+일OT+휴일 가산만 합산되며, 주OT·주휴·공제는 월 단위로만 적용됩니다.',
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
    final scheme = Theme.of(context).colorScheme;
    final f = NumberFormat.decimalPattern('ko_KR');
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
            '${f.format(item.amount.won)}원',
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
    final f = NumberFormat.decimalPattern('ko_KR');
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
            '실 근무 $h시간${m == 0 ? '' : ' $m분'}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${f.format(net.won)}원',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
          ),
          if (gross.won != net.won)
            Text(
              '공제 전 ${f.format(gross.won)}원',
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
