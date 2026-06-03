import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/palette/job_colors.dart';
import '../../core/time/week_resolver.dart';
import '../../domain/entity/job.dart';
import '../../domain/entity/shift.dart';
import '../job/job_edit_sheet.dart';
import '../job/job_providers.dart';
import '../job/jobs_page.dart';
import 'payroll_providers.dart';
import 'recurring_shift_sheet.dart';
import 'schedule_providers.dart';
import 'shift_edit_sheet.dart';

class SchedulePage extends ConsumerWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncJobs = ref.watch(activeJobsProvider);
    final hasJobs = asyncJobs.maybeWhen(
      data: (jobs) => jobs.isNotEmpty,
      orElse: () => false,
    );
    final selectedDate = ref.watch(selectedDateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('일정표'),
        actions: [
          if (hasJobs)
            IconButton(
              tooltip: '반복 시프트 일괄 추가',
              icon: const Icon(Icons.event_repeat),
              onPressed: () => showRecurringShiftSheet(context),
            ),
        ],
      ),
      body: const Column(
        children: [
          _JobsBar(),
          _VisibilityToggles(),
          Divider(height: 1),
          _MonthlyCalendar(),
          Divider(height: 1),
          Expanded(child: _SelectedDayPanel()),
        ],
      ),
      floatingActionButton: hasJobs
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('시프트 추가'),
              onPressed: () => showShiftEditSheet(
                context,
                defaultDate: selectedDate,
              ),
            )
          : null,
    );
  }
}

// ────────────────────────────────────────────────────────────
// 근무처 바 (chips + 관리 버튼)
// ────────────────────────────────────────────────────────────

class _JobsBar extends ConsumerWidget {
  const _JobsBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncJobs = ref.watch(activeJobsProvider);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Expanded(
            child: asyncJobs.when(
              loading: () => const SizedBox(
                height: 32,
                child: Center(child: LinearProgressIndicator()),
              ),
              error: (e, _) => Text('근무처 로드 오류: $e'),
              data: (jobs) {
                if (jobs.isEmpty) {
                  return const Text(
                    '등록된 근무처가 없어요',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  );
                }
                return SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: jobs.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 6),
                    itemBuilder: (context, i) => _JobChip(job: jobs[i]),
                  ),
                );
              },
            ),
          ),
          IconButton(
            tooltip: '근무처 관리',
            icon: const Icon(Icons.tune),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const JobsPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _JobChip extends StatelessWidget {
  const _JobChip({required this.job});
  final Job job;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: CircleAvatar(
        backgroundColor: JobColors.fromArgb(job.colorArgb),
        radius: 8,
      ),
      label: Text(job.name),
      onPressed: () => showJobEditSheet(context, job: job),
      padding: const EdgeInsets.symmetric(horizontal: 6),
    );
  }
}

// ────────────────────────────────────────────────────────────
// 표시 옵션 체크박스
// ────────────────────────────────────────────────────────────

class _VisibilityToggles extends ConsumerWidget {
  const _VisibilityToggles();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vis = ref.watch(payrollVisibilityProvider);
    final notifier = ref.read(payrollVisibilityProvider.notifier);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Wrap(
        spacing: 4,
        children: [
          FilterChip(
            label: const Text('일급'),
            selected: vis.daily,
            onSelected: (_) => notifier.toggleDaily(),
            showCheckmark: true,
          ),
          FilterChip(
            label: const Text('주급'),
            selected: vis.weekly,
            onSelected: (_) => notifier.toggleWeekly(),
            showCheckmark: true,
          ),
          FilterChip(
            label: const Text('월급'),
            selected: vis.monthly,
            onSelected: (_) => notifier.toggleMonthly(),
            showCheckmark: true,
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
// 월간 캘린더 (커스텀 셀: 시간 + 일급)
// ────────────────────────────────────────────────────────────

class _MonthlyCalendar extends ConsumerWidget {
  const _MonthlyCalendar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final selected = ref.watch(selectedDateProvider);
    final asyncComp = ref.watch(monthlyComputationProvider);
    final vis = ref.watch(payrollVisibilityProvider);

    final dailyMinutes = asyncComp.maybeWhen(
      data: (c) => c.dailyWorkMinutes,
      orElse: () => const <DateTime, int>{},
    );
    final dailyPay = asyncComp.maybeWhen(
      data: (c) => c.dailyPayWon,
      orElse: () => const <DateTime, int>{},
    );

    return TableCalendar<int>(
      firstDay: DateTime.utc(2020),
      lastDay: DateTime.utc(2099, 12, 31),
      focusedDay: month,
      selectedDayPredicate: (d) => isSameDay(d, selected),
      onDaySelected: (selectedDay, focusedDay) {
        ref.read(selectedDateProvider.notifier).set(selectedDay);
      },
      onPageChanged: (focusedDay) {
        ref.read(selectedMonthProvider.notifier).set(focusedDay);
      },
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {CalendarFormat.month: '월'},
      startingDayOfWeek: StartingDayOfWeek.monday,
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      rowHeight: vis.daily ? 64 : 48,
      calendarStyle: const CalendarStyle(
        outsideDaysVisible: false,
      ),
      calendarBuilders: CalendarBuilders<int>(
        defaultBuilder: (ctx, day, focusedDay) => _DayCell(
          day: day,
          minutes: dailyMinutes[DateTime(day.year, day.month, day.day)],
          payWon: dailyPay[DateTime(day.year, day.month, day.day)],
          showDailyPay: vis.daily,
        ),
        todayBuilder: (ctx, day, focusedDay) => _DayCell(
          day: day,
          isToday: true,
          minutes: dailyMinutes[DateTime(day.year, day.month, day.day)],
          payWon: dailyPay[DateTime(day.year, day.month, day.day)],
          showDailyPay: vis.daily,
        ),
        selectedBuilder: (ctx, day, focusedDay) => _DayCell(
          day: day,
          isSelected: true,
          minutes: dailyMinutes[DateTime(day.year, day.month, day.day)],
          payWon: dailyPay[DateTime(day.year, day.month, day.day)],
          showDailyPay: vis.daily,
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.showDailyPay,
    this.minutes,
    this.payWon,
    this.isToday = false,
    this.isSelected = false,
  });
  final DateTime day;
  final int? minutes;
  final int? payWon;
  final bool showDailyPay;
  final bool isToday;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final Color? bg = isSelected
        ? scheme.primary
        : isToday
            ? scheme.primaryContainer
            : null;
    final Color fg = isSelected
        ? scheme.onPrimary
        : isToday
            ? scheme.onPrimaryContainer
            : scheme.onSurface;
    final hours = minutes == null ? null : (minutes! / 60);
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: bg == null
          ? null
          : BoxDecoration(color: bg, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(6)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${day.day}',
            style: TextStyle(
              color: fg,
              fontSize: 14,
              fontWeight: (isToday || isSelected) ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (hours != null && hours > 0)
            Text(
              '${_fmtHours(hours)}h',
              style: TextStyle(color: fg, fontSize: 10),
            ),
          if (showDailyPay && payWon != null && payWon! > 0)
            Text(
              _fmtPayShort(payWon!),
              style: TextStyle(
                color: fg.withValues(alpha: 0.9),
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  static String _fmtHours(double h) {
    if (h == h.toInt()) return h.toInt().toString();
    return h.toStringAsFixed(1);
  }

  static String _fmtPayShort(int won) {
    if (won >= 10000) {
      final man = won / 10000;
      if (man == man.toInt()) return '${man.toInt()}만';
      return '${man.toStringAsFixed(1)}만';
    }
    return '$won';
  }
}

// ────────────────────────────────────────────────────────────
// 하단 패널: 선택일 시프트 + 주/월 요약
// ────────────────────────────────────────────────────────────

class _SelectedDayPanel extends ConsumerWidget {
  const _SelectedDayPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(selectedDateProvider);
    final shifts = ref.watch(shiftsOnSelectedDateProvider);
    final asyncJobs = ref.watch(activeJobsProvider);
    final asyncComp = ref.watch(monthlyComputationProvider);
    final vis = ref.watch(payrollVisibilityProvider);

    final dateLabel =
        '${date.year}년 ${date.month}월 ${date.day}일 (${_weekdayKo(date.weekday)})';
    final wr = WeekResolver();
    final weekStart = wr.weekStartOf(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Text(dateLabel, style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              if (vis.weekly)
                _WeeklySummary(weekStart: weekStart, asyncComp: asyncComp),
            ],
          ),
        ),
        if (vis.monthly)
          _MonthlySummary(asyncComp: asyncComp),
        const Divider(height: 1),
        Expanded(
          child: asyncJobs.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('근무처 로드 오류: $e')),
            data: (jobs) {
              if (jobs.isEmpty) return const _NoJobsHint();
              if (shifts.isEmpty) return const _NoShiftsHint();
              return _ShiftList(shifts: shifts, jobs: jobs);
            },
          ),
        ),
      ],
    );
  }

  String _weekdayKo(int weekday) {
    const labels = ['월', '화', '수', '목', '금', '토', '일'];
    return labels[(weekday - 1) % 7];
  }
}

class _WeeklySummary extends StatelessWidget {
  const _WeeklySummary({required this.weekStart, required this.asyncComp});
  final DateTime weekStart;
  final AsyncValue<dynamic> asyncComp;

  @override
  Widget build(BuildContext context) {
    return asyncComp.maybeWhen(
      data: (c) {
        final minutes = c.weeklyWorkMinutes[weekStart] as int? ?? 0;
        final pay = c.weeklyPayWon[weekStart] as int? ?? 0;
        return _Pill(
          label: '이 주 ${_h(minutes)}h · ${_won(pay)}',
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  static String _h(int m) {
    final h = m / 60;
    if (h == h.toInt()) return h.toInt().toString();
    return h.toStringAsFixed(1);
  }

  static String _won(int won) {
    final f = NumberFormat.decimalPattern('ko_KR');
    return '${f.format(won)}원';
  }
}

class _MonthlySummary extends ConsumerWidget {
  const _MonthlySummary({required this.asyncComp});
  final AsyncValue<dynamic> asyncComp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return asyncComp.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(8),
        child: Text('월 합계 계산 오류: $e'),
      ),
      data: (c) {
        final minutes = c.report.totalWorkMinutes as int;
        final net = c.report.netPay;
        final gross = c.report.grossPay;
        final f = NumberFormat.decimalPattern('ko_KR');
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '이 달 ${_h(minutes)}h · ${f.format(net.won)}원',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
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
      },
    );
  }

  static String _h(int m) {
    final h = m / 60;
    if (h == h.toInt()) return h.toInt().toString();
    return h.toStringAsFixed(1);
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: scheme.onSecondaryContainer, fontSize: 12),
      ),
    );
  }
}

class _NoJobsHint extends StatelessWidget {
  const _NoJobsHint();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.work_outline, size: 40),
            const SizedBox(height: 8),
            const Text(
              '근무처가 없습니다',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text(
              '시프트를 추가하려면 먼저 근무처를 등록하세요.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('근무처 추가'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const JobsPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NoShiftsHint extends StatelessWidget {
  const _NoShiftsHint();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text('이 날의 시프트가 없습니다.'),
      ),
    );
  }
}

class _ShiftList extends StatelessWidget {
  const _ShiftList({required this.shifts, required this.jobs});
  final List<Shift> shifts;
  final List<Job> jobs;

  @override
  Widget build(BuildContext context) {
    final jobsById = {for (final j in jobs) j.id: j};
    return ListView.separated(
      itemCount: shifts.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final s = shifts[i];
        final job = jobsById[s.jobId];
        final start = s.startAt.toLocal();
        final end = s.endAt.toLocal();
        final timeText =
            '${_fmtHM(start)} ~ ${_fmtHM(end)}'
            '${s.breakMinutes > 0 ? ' (휴게 ${s.breakMinutes}분)' : ''}';
        return ListTile(
          leading: CircleAvatar(
            radius: 10,
            backgroundColor: job == null
                ? Colors.grey
                : JobColors.fromArgb(job.colorArgb),
          ),
          title: Text(timeText),
          subtitle: Text(
            [
              if (job != null) job.name,
              if (s.memo != null) s.memo!,
            ].join(' · '),
          ),
          onTap: () => showShiftEditSheet(context, shift: s),
        );
      },
    );
  }

  String _fmtHM(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
