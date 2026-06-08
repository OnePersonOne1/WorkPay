import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../domain/entity/shift.dart';

/// 시프트 변경에 대한 메모리 Undo 스택 (최대 5개, 앱 종료 시 소멸).
///
/// 각 mutation 직전 snapshotBefore를 호출하면 그 시점의 월 시프트 상태가 저장된다.
/// undo() 호출 시 가장 최근 snapshot으로 복원 + 스택에서 pop.
class UndoEntry {
  const UndoEntry({
    required this.description,
    required this.year,
    required this.month,
    required this.shifts,
  });

  final String description;
  final int year;
  final int month;
  final List<Shift> shifts;
}

class UndoController extends Notifier<List<UndoEntry>> {
  static const int maxSize = 5;

  @override
  List<UndoEntry> build() => const [];

  /// mutation 직전 현재 월의 시프트 snapshot을 push.
  Future<void> snapshotBefore({
    required int year,
    required int month,
    required String description,
  }) async {
    final repo = ref.read(shiftRepositoryProvider);
    final shifts = await repo.watchShiftsInMonth(year, month).first;
    final entry = UndoEntry(
      description: description,
      year: year,
      month: month,
      shifts: shifts,
    );
    final next = [...state, entry];
    if (next.length > maxSize) {
      next.removeAt(0);
    }
    state = next;
  }

  /// 가장 최근 entry를 pop하고 그 snapshot으로 복원.
  /// 반환: 복원한 entry (없으면 null).
  Future<UndoEntry?> undo() async {
    if (state.isEmpty) return null;
    final entry = state.last;
    final repo = ref.read(shiftRepositoryProvider);
    await repo.replaceShiftsInMonth(entry.year, entry.month, entry.shifts);
    state = state.sublist(0, state.length - 1);
    return entry;
  }

  void clear() {
    state = const [];
  }
}

final undoControllerProvider =
    NotifierProvider<UndoController, List<UndoEntry>>(UndoController.new);
