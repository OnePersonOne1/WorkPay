import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../domain/entity/shift.dart';
import '../job/job_providers.dart';

/// 캘린더에 표시 중인 월(첫째 날, 자정 로컬). 기본값: 오늘이 속한 월.
class SelectedMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void set(DateTime month) {
    state = DateTime(month.year, month.month);
  }
}

final selectedMonthProvider =
    NotifierProvider<SelectedMonthNotifier, DateTime>(SelectedMonthNotifier.new);

/// 사용자가 캘린더에서 탭한 날짜(자정 로컬). 기본값: 오늘.
class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void set(DateTime date) {
    state = DateTime(date.year, date.month, date.day);
  }
}

final selectedDateProvider =
    NotifierProvider<SelectedDateNotifier, DateTime>(SelectedDateNotifier.new);

/// 사용자가 일정표 상단 칩에서 현재 "활성"으로 선택한 근무처 id. 시프트 추가 시 기본값.
/// 세션 ephemeral — 앱 재시작 시 초기화. null이면 미선택.
class SelectedJobNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void select(int? jobId) {
    state = jobId;
  }

  void toggle(int jobId) {
    state = state == jobId ? null : jobId;
  }
}

final selectedJobProvider =
    NotifierProvider<SelectedJobNotifier, int?>(SelectedJobNotifier.new);

/// 선택된 월에 속하는 시프트 스트림.
final shiftsInSelectedMonthProvider = StreamProvider<List<Shift>>((ref) {
  final month = ref.watch(selectedMonthProvider);
  final repo = ref.watch(shiftRepositoryProvider);
  return repo.watchShiftsInMonth(month.year, month.month);
});

/// 선택된 월의 각 날짜에 시프트가 존재하는 근무처들의 색(ARGB) 리스트.
/// key: displayDate (자정 로컬). value: 그 날 시프트가 있는 활성 근무처들의 colorArgb (중복 제거).
/// archived job은 매핑에서 빠져 표시되지 않음.
final dayJobColorsProvider = Provider<Map<DateTime, List<int>>>((ref) {
  final shiftsAsync = ref.watch(shiftsInSelectedMonthProvider);
  final jobsAsync = ref.watch(activeJobsProvider);
  final shifts = shiftsAsync.asData?.value ?? const [];
  final jobsList = jobsAsync.asData?.value ?? const [];
  final colorById = <int, int>{
    for (final j in jobsList) j.id: j.colorArgb,
  };
  final result = <DateTime, List<int>>{};
  for (final s in shifts) {
    final local = s.startAt.toLocal();
    final day = DateTime(local.year, local.month, local.day);
    final argb = colorById[s.jobId];
    if (argb == null) continue;
    final list = result.putIfAbsent(day, () => <int>[]);
    if (!list.contains(argb)) list.add(argb);
  }
  return result;
});

/// 선택된 날짜에 속하는 시프트 (client-side 필터).
final shiftsOnSelectedDateProvider = Provider<List<Shift>>((ref) {
  final date = ref.watch(selectedDateProvider);
  final asyncShifts = ref.watch(shiftsInSelectedMonthProvider);
  return asyncShifts.maybeWhen(
    data: (all) => all.where((s) {
      final local = s.startAt.toLocal();
      return local.year == date.year &&
          local.month == date.month &&
          local.day == date.day;
    }).toList(),
    orElse: () => const <Shift>[],
  );
});

/// 캘린더에 어떤 급여를 표시할지 토글. 모두 OFF도 가능.
/// 기본값: 월급만 ON.
class PayrollVisibility {
  const PayrollVisibility({
    required this.daily,
    required this.weekly,
    required this.monthly,
  });

  factory PayrollVisibility.defaults() =>
      const PayrollVisibility(daily: false, weekly: false, monthly: true);

  final bool daily;
  final bool weekly;
  final bool monthly;

  PayrollVisibility copyWith({bool? daily, bool? weekly, bool? monthly}) {
    return PayrollVisibility(
      daily: daily ?? this.daily,
      weekly: weekly ?? this.weekly,
      monthly: monthly ?? this.monthly,
    );
  }
}

class PayrollVisibilityNotifier extends Notifier<PayrollVisibility> {
  @override
  PayrollVisibility build() => PayrollVisibility.defaults();

  void toggleDaily() => state = state.copyWith(daily: !state.daily);
  void toggleWeekly() => state = state.copyWith(weekly: !state.weekly);
  void toggleMonthly() => state = state.copyWith(monthly: !state.monthly);
}

final payrollVisibilityProvider =
    NotifierProvider<PayrollVisibilityNotifier, PayrollVisibility>(
  PayrollVisibilityNotifier.new,
);

