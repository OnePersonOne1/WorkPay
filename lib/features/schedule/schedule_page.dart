import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/palette/job_colors.dart';
import '../../core/time/time_format.dart';
import '../../domain/entity/job.dart';
import '../../domain/entity/shift.dart';
import '../settings/settings_providers.dart';
import '../job/job_providers.dart';
import '../job/jobs_page.dart';
import 'monthly_report_detail_page.dart';
import 'payroll_providers.dart';
import 'recurring_shift_sheet.dart';
import 'schedule_providers.dart';
import 'shift_edit_sheet.dart';
import 'year_month_picker.dart';

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
            TextButton.icon(
              icon: const Icon(Icons.event_repeat),
              label: const Text('반복 추가'),
              onPressed: () => showRecurringShiftSheet(context),
            ),
          TextButton.icon(
            icon: const Icon(Icons.receipt_long_outlined),
            label: const Text('급여 명세'),
            onPressed: () => pushMonthlyReportDetail(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        // 좁은 화면에서도 전체 콘텐츠를 스크롤로 볼 수 있게.
        children: const [
          _JobsBar(),
          _VisibilityToggles(),
          Divider(height: 1),
          _CalendarHeader(),
          _MonthlyCalendar(),
          _WeeklySummariesUnderCalendar(),
          _MonthlySummaryBar(),
          Divider(height: 1),
          _SelectedDayPanel(),
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
    final selectedId = ref.watch(selectedJobProvider);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 4),
      color: scheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              TextButton.icon(
                icon: const Icon(Icons.tune, size: 18),
                label: const Text('관리'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const JobsPage()),
                  );
                },
              ),
            ],
          ),
          // 현재 기본 근무지 안내 — 시프트 추가 시 자동 선택될 근무처를 명시
          asyncJobs.maybeWhen(
            data: (jobs) {
              if (jobs.isEmpty) return const SizedBox.shrink();
              final selected = selectedId == null
                  ? null
                  : jobs.firstWhere(
                      (j) => j.id == selectedId,
                      orElse: () => jobs.first,
                    );
              final label = selected == null
                  ? '기본 근무지 미선택 — 시프트 추가 시 첫째 근무처가 자동 선택돼요'
                  : '기본 근무지: ${selected.name} (시프트 추가 시 자동 선택, 변경 가능)';
              return Padding(
                padding: const EdgeInsets.fromLTRB(2, 4, 8, 0),
                child: Text(
                  label,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _JobChip extends ConsumerWidget {
  const _JobChip({required this.job});
  final Job job;

  static const _kSelectedYellow = Color(0xFFFFE082);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedJobProvider);
    final isSelected = selected == job.id;
    final isFaded = selected != null && !isSelected;
    return AnimatedOpacity(
      opacity: isFaded ? 0.4 : 1.0,
      duration: const Duration(milliseconds: 120),
      child: FilterChip(
        avatar: CircleAvatar(
          backgroundColor: JobColors.fromArgb(job.colorArgb),
          radius: 8,
        ),
        label: Text(job.name),
        selected: isSelected,
        selectedColor: _kSelectedYellow,
        checkmarkColor: Colors.black87,
        onSelected: (_) =>
            ref.read(selectedJobProvider.notifier).toggle(job.id),
        padding: const EdgeInsets.symmetric(horizontal: 6),
      ),
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
// 캘린더 헤더 — 월 이동 + 오늘 + 년/월 선택
// ────────────────────────────────────────────────────────────

class _CalendarHeader extends ConsumerWidget {
  const _CalendarHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    void shift(int delta) {
      final next = DateTime(month.year, month.month + delta);
      ref.read(selectedMonthProvider.notifier).set(next);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: '이전 달',
            onPressed: () => shift(-1),
          ),
          Expanded(
            child: InkWell(
              onTap: () async {
                final picked = await pickYearMonth(context, initial: month);
                if (picked != null) {
                  ref.read(selectedMonthProvider.notifier).set(picked);
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${month.year}년 ${month.month}월',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, size: 22),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: '다음 달',
            onPressed: () => shift(1),
          ),
          TextButton.icon(
            icon: const Icon(Icons.today, size: 18),
            label: const Text('오늘로 돌아가기'),
            onPressed: () {
              final now = DateTime.now();
              ref.read(selectedMonthProvider.notifier).set(now);
              ref.read(selectedDateProvider.notifier).set(now);
            },
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
    final dayColors = ref.watch(dayJobColorsProvider);
    final dayShifts = ref.watch(dayShiftsListProvider);
    final calendar = ref.watch(holidayCalendarProvider);
    final use24 = ref.watch(use24HourFormatProvider);

    List<int> colorsFor(DateTime day) =>
        dayColors[DateTime(day.year, day.month, day.day)] ?? const [];
    List<Shift> shiftsFor(DateTime day) =>
        dayShifts[DateTime(day.year, day.month, day.day)] ?? const [];

    bool isHolidayFor(DateTime day) => calendar.isPublicHoliday(day);

    _DayCell makeCell(DateTime day, {bool isToday = false, bool isSelected = false}) {
      final key = DateTime(day.year, day.month, day.day);
      return _DayCell(
        day: day,
        minutes: dailyMinutes[key],
        payWon: dailyPay[key],
        jobColors: colorsFor(day),
        shifts: shiftsFor(day),
        isHoliday: isHolidayFor(day),
        showDailyPay: vis.daily,
        use24Hour: use24,
        isToday: isToday,
        isSelected: isSelected,
      );
    }

    final lineColor = Theme.of(context).colorScheme.outlineVariant;
    return Container(
      // outer frame — 셀의 right/bottom과 합쳐져 사방 완전한 격자
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: lineColor, width: 1),
          left: BorderSide(color: lineColor, width: 1),
        ),
      ),
      child: TableCalendar<int>(
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
      // 기본 헤더는 숨기고 _CalendarHeader를 위에 별도 배치
      headerVisible: false,
      // 셀이 전체를 채우도록 — _DayCell이 자체 경계선을 그린다.
      daysOfWeekHeight: 28,
      // 좌상단 날짜 + 좌측 정렬 컨텐츠. 시간 라인 2개 + 총 + 일급까지 들어가도록.
      rowHeight: vis.daily ? 94 : 78,
      calendarStyle: const CalendarStyle(
        outsideDaysVisible: false,
        cellMargin: EdgeInsets.zero,
        cellPadding: EdgeInsets.zero,
      ),
      // 요일 헤더 — 토/일 색 + 아래 라인 (셀 line과 동일 톤)
      daysOfWeekStyle: DaysOfWeekStyle(
        weekendStyle: TextStyle(
          color: Theme.of(context).colorScheme.error,
        ),
        weekdayStyle: const TextStyle(),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: lineColor, width: 1),
          ),
        ),
      ),
      calendarBuilders: CalendarBuilders<int>(
        defaultBuilder: (ctx, day, _) => makeCell(day),
        todayBuilder: (ctx, day, _) => makeCell(day, isToday: true),
        selectedBuilder: (ctx, day, _) => makeCell(day, isSelected: true),
        // 요일 헤더 커스텀 — 일요일 빨강, 토요일 파랑
        dowBuilder: (ctx, day) {
          const labels = ['월', '화', '수', '목', '금', '토', '일'];
          final label = labels[day.weekday - 1];
          final Color color;
          if (day.weekday == DateTime.sunday) {
            color = const Color(0xFFEF4444);
          } else if (day.weekday == DateTime.saturday) {
            color = const Color(0xFF3B82F6);
          } else {
            color = Theme.of(context).colorScheme.onSurface;
          }
          return Center(
            child: Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          );
        },
      ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.showDailyPay,
    required this.jobColors,
    required this.isHoliday,
    required this.shifts,
    required this.use24Hour,
    this.minutes,
    this.payWon,
    this.isToday = false,
    this.isSelected = false,
  });
  final DateTime day;
  final int? minutes;
  final int? payWon;
  final List<int> jobColors;
  final List<Shift> shifts;
  final bool isHoliday;
  final bool showDailyPay;
  final bool use24Hour;
  final bool isToday;
  final bool isSelected;

  static const _kSundayRed = Color(0xFFEF4444);
  static const _kSaturdayBlue = Color(0xFF3B82F6);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // 셀 배경: 선택 시만 채움. 오늘은 날짜 숫자에만 작은 배지 (보편적 달력 스타일).
    final Color? bg = isSelected ? scheme.primary : null;

    // 텍스트 색 — 선택 셀은 onPrimary, 외엔 토/일/공휴일 색 또는 onSurface
    final Color fg;
    if (isSelected) {
      fg = scheme.onPrimary;
    } else if (isHoliday || day.weekday == DateTime.sunday) {
      fg = _kSundayRed;
    } else if (day.weekday == DateTime.saturday) {
      fg = _kSaturdayBlue;
    } else {
      fg = scheme.onSurface;
    }

    final hours = minutes == null ? null : (minutes! / 60);
    final lineColor = scheme.outlineVariant;

    // 날짜 숫자 위젯 — 오늘이면 작은 원형 배지로 강조
    Widget dateWidget = Text(
      '${day.day}',
      style: TextStyle(
        color: fg,
        fontSize: 13,
        fontWeight: (isToday || isSelected) ? FontWeight.bold : FontWeight.normal,
      ),
    );
    if (isToday && !isSelected) {
      dateWidget = Container(
        width: 22,
        height: 22,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: scheme.primary,
          shape: BoxShape.circle,
        ),
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: scheme.onPrimary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          right: BorderSide(color: lineColor, width: 1),
          bottom: BorderSide(color: lineColor, width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5, 3, 4, 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 날짜 — 좌상단 (보편적 달력 컨벤션)
            Align(alignment: Alignment.topLeft, child: dateWidget),
            if (jobColors.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: _JobDots(colors: jobColors),
              ),
            if (shifts.isNotEmpty) ..._buildShiftLines(fg),
            if (hours != null && hours > 0)
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Text(
                  '${_fmtHours(hours)}h',
                  style: TextStyle(
                    color: fg.withValues(alpha: 0.85),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
      ),
    );
  }

  static String _fmtHours(double h) {
    if (h == h.toInt()) return h.toInt().toString();
    return h.toStringAsFixed(1);
  }

  /// 시프트 시간 줄들. 1개면 시간만, 2개+면 "HH:MM~HH:MM Xh" 형식. 3개+는 "..." 생략.
  List<Widget> _buildShiftLines(Color fg) {
    final lines = <Widget>[];
    String fmt(DateTime dt) => formatHMCompact(dt, use24Hour: use24Hour);
    if (shifts.length == 1) {
      final s = shifts[0];
      lines.add(
        Text(
          '${fmt(s.startAt.toLocal())}~${fmt(s.endAt.toLocal())}',
          style: TextStyle(
            color: fg.withValues(alpha: 0.85),
            fontSize: 9,
            height: 1.2,
          ),
        ),
      );
      return lines;
    }
    final hasOverflow = shifts.length > 2;
    final visibleCount = hasOverflow ? 1 : shifts.length;
    for (var i = 0; i < visibleCount; i++) {
      final s = shifts[i];
      final start = s.startAt.toLocal();
      final end = s.endAt.toLocal();
      final workMin = end.difference(start).inMinutes - s.breakMinutes;
      final workH = workMin / 60;
      final hStr = workH == workH.toInt()
          ? workH.toInt().toString()
          : workH.toStringAsFixed(1);
      lines.add(
        Text(
          '${fmt(start)}~${fmt(end)} ${hStr}h',
          style: TextStyle(
            color: fg.withValues(alpha: 0.85),
            fontSize: 9,
            height: 1.2,
          ),
        ),
      );
    }
    if (hasOverflow) {
      lines.add(
        Text(
          '...',
          style: TextStyle(
            color: fg.withValues(alpha: 0.7),
            fontSize: 11,
            height: 1.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }
    return lines;
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

/// 셀에 표시되는 근무처 색 dot row. 최대 3개, 그 이상은 '+' 추가.
class _JobDots extends StatelessWidget {
  const _JobDots({required this.colors});
  final List<int> colors;

  @override
  Widget build(BuildContext context) {
    const maxDots = 3;
    const dotSize = 5.0;
    const gap = 2.0;
    final visible = colors.length > maxDots ? colors.take(maxDots).toList() : colors;
    final hasMore = colors.length > maxDots;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < visible.length; i++) ...[
          if (i > 0) const SizedBox(width: gap),
          Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              color: Color(visible[i]),
              shape: BoxShape.circle,
            ),
          ),
        ],
        if (hasMore) ...[
          const SizedBox(width: gap),
          Text(
            '+',
            style: TextStyle(
              fontSize: 9,
              height: 1,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
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

    final dateLabel =
        '${date.year}년 ${date.month}월 ${date.day}일 (${_weekdayKo(date.weekday)})';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            dateLabel,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        asyncJobs.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text('근무처 로드 오류: $e'),
          ),
          data: (jobs) {
            if (jobs.isEmpty) return const _NoJobsHint();
            if (shifts.isEmpty) return const _NoShiftsHint();
            return _ShiftList(shifts: shifts, jobs: jobs);
          },
        ),
      ],
    );
  }

  String _weekdayKo(int weekday) {
    const labels = ['월', '화', '수', '목', '금', '토', '일'];
    return labels[(weekday - 1) % 7];
  }
}

/// 캘린더 아래에 주별 요약 리스트. vis.weekly가 ON일 때만 표시.
/// 주 시작이 현재 표시 월에 속하는 주만 노출.
class _WeeklySummariesUnderCalendar extends ConsumerWidget {
  const _WeeklySummariesUnderCalendar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vis = ref.watch(payrollVisibilityProvider);
    if (!vis.weekly) return const SizedBox.shrink();

    final asyncComp = ref.watch(monthlyComputationProvider);
    return asyncComp.maybeWhen(
      data: (c) {
        // 주 시작 순으로 정렬
        final entries = c.weeklyWorkMinutes.entries
            .where((e) => e.value > 0)
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key));
        if (entries.isEmpty) return const SizedBox.shrink();
        final scheme = Theme.of(context).colorScheme;
        final f = NumberFormat.decimalPattern('ko_KR');
        return Container(
          color: scheme.surfaceContainerLowest,
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 4),
                child: Text(
                  '주별 요약',
                  style: TextStyle(
                    fontSize: 11,
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              for (var i = 0; i < entries.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        '${i + 1}주차',
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _fmtHours(entries[i].value),
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${f.format(c.weeklyPayWon[entries[i].key] ?? 0)}원',
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontSize: 13,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  static String _fmtHours(int minutes) {
    final h = minutes / 60;
    final text = h == h.toInt() ? h.toInt().toString() : h.toStringAsFixed(1);
    return '${text}h';
  }
}

/// 월 합계 바 — 선택일 패널 위에 노출. vis.monthly가 ON일 때만.
/// 탭하면 월별 상세 명세 페이지 진입.
class _MonthlySummaryBar extends ConsumerWidget {
  const _MonthlySummaryBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vis = ref.watch(payrollVisibilityProvider);
    if (!vis.monthly) return const SizedBox.shrink();
    final asyncComp = ref.watch(monthlyComputationProvider);
    return _MonthlySummary(asyncComp: asyncComp);
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
        return Material(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          child: InkWell(
            onTap: () => pushMonthlyReportDetail(context),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '이 달 ${_h(minutes)}h · ${f.format(net.won)}원',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        if (gross.won != net.won)
                          Text(
                            '공제 전 ${f.format(gross.won)}원',
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
                  Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
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

class _ShiftList extends ConsumerWidget {
  const _ShiftList({required this.shifts, required this.jobs});
  final List<Shift> shifts;
  final List<Job> jobs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final use24 = ref.watch(use24HourFormatProvider);
    final jobsById = {for (final j in jobs) j.id: j};
    return ListView.separated(
      // 외부 ListView가 스크롤 담당
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: shifts.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final s = shifts[i];
        final job = jobsById[s.jobId];
        final start = s.startAt.toLocal();
        final end = s.endAt.toLocal();
        final timeText =
            '${formatHM(start, use24Hour: use24)} ~ ${formatHM(end, use24Hour: use24)}'
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
}
