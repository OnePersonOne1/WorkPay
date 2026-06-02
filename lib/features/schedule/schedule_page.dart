import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../domain/entity/shift.dart';
import 'schedule_providers.dart';

class SchedulePage extends ConsumerWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('일정표'),
      ),
      body: Column(
        children: const [
          _MonthlyCalendar(),
          Divider(height: 1),
          Expanded(child: _SelectedDayPanel()),
        ],
      ),
    );
  }
}

class _MonthlyCalendar extends ConsumerWidget {
  const _MonthlyCalendar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final selected = ref.watch(selectedDateProvider);
    final asyncShifts = ref.watch(shiftsInSelectedMonthProvider);

    // 날짜별 시프트 dot 개수 계산
    final Map<DateTime, List<Shift>> byDate = {};
    asyncShifts.whenData((shifts) {
      for (final s in shifts) {
        final local = s.startAt.toLocal();
        final key = DateTime(local.year, local.month, local.day);
        byDate.putIfAbsent(key, () => []).add(s);
      }
    });

    return TableCalendar<Shift>(
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
      eventLoader: (day) {
        final key = DateTime(day.year, day.month, day.day);
        return byDate[key] ?? const [];
      },
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {CalendarFormat.month: '월'},
      startingDayOfWeek: StartingDayOfWeek.monday,
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      calendarStyle: CalendarStyle(
        markerSize: 5,
        markersMaxCount: 3,
        outsideDaysVisible: false,
        todayDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        todayTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _SelectedDayPanel extends ConsumerWidget {
  const _SelectedDayPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(selectedDateProvider);
    final shifts = ref.watch(shiftsOnSelectedDateProvider);
    final asyncJobs = ref.watch(activeJobsProvider);

    final dateLabel = '${date.year}년 ${date.month}월 ${date.day}일 '
        '(${_weekdayKo(date.weekday)})';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            dateLabel,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: asyncJobs.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('근무처 로드 오류: $e')),
            data: (jobs) {
              if (jobs.isEmpty) return const _NoJobsHint();
              if (shifts.isEmpty) return const _NoShiftsHint();
              return _ShiftList(shifts: shifts);
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

class _NoJobsHint extends StatelessWidget {
  const _NoJobsHint();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.work_outline, size: 48),
            const SizedBox(height: 12),
            const Text(
              '근무처가 없습니다',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text(
              '시프트를 추가하려면 먼저 근무처를 등록하세요.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('근무처 추가'),
              onPressed: () {
                // Phase 4b에서 연결
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('근무처 추가 UI는 Phase 4b에서 추가됩니다.')),
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
  const _ShiftList({required this.shifts});
  final List<Shift> shifts;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: shifts.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final s = shifts[i];
        final start = s.startAt.toLocal();
        final end = s.endAt.toLocal();
        final timeText =
            '${_fmtHM(start)} ~ ${_fmtHM(end)}'
            '${s.breakMinutes > 0 ? ' (휴게 ${s.breakMinutes}분)' : ''}';
        return ListTile(
          leading: const Icon(Icons.access_time),
          title: Text(timeText),
          subtitle: s.memo == null ? null : Text(s.memo!),
        );
      },
    );
  }

  String _fmtHM(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
