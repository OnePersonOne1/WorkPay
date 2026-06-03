import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../domain/entity/shift.dart';

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

/// 선택된 월에 속하는 시프트 스트림.
final shiftsInSelectedMonthProvider = StreamProvider<List<Shift>>((ref) {
  final month = ref.watch(selectedMonthProvider);
  final repo = ref.watch(shiftRepositoryProvider);
  return repo.watchShiftsInMonth(month.year, month.month);
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

