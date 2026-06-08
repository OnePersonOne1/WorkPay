import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../domain/entity/shift.dart';
import '../backup/backup_format.dart' show ShiftJson;

/// 시프트 변경에 대한 Undo 스택 (최대 5개).
///
/// 영구 저장: AppSettings.undoStackJson에 JSON으로 직렬화. 앱 재시작 후에도 유지.
/// 백업 파일에는 포함되지 않음 (사용자 액션 이력).
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

  Map<String, dynamic> toJson() => {
        'description': description,
        'year': year,
        'month': month,
        'shifts': shifts.map((s) => _shiftToJson(s)).toList(),
      };

  factory UndoEntry.fromJson(Map<String, dynamic> json) {
    return UndoEntry(
      description: json['description'] as String,
      year: json['year'] as int,
      month: json['month'] as int,
      shifts: (json['shifts'] as List)
          .map((e) => _shiftFromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static Map<String, dynamic> _shiftToJson(Shift s) {
    // backup_format의 ShiftJson 재사용 (같은 필드)
    return ShiftJson(
      id: s.id,
      jobId: s.jobId,
      startAt: s.startAt,
      endAt: s.endAt,
      breakMinutes: s.breakMinutes,
      breakStartAt: s.breakStartAt,
      hourlyWageSnapshot: s.hourlyWageSnapshot,
      memo: s.memo,
      createdAt: s.createdAt,
      updatedAt: s.updatedAt,
    ).toJson();
  }

  static Shift _shiftFromJson(Map<String, dynamic> json) {
    final j = ShiftJson.fromJson(json);
    return Shift(
      id: j.id,
      jobId: j.jobId,
      startAt: j.startAt,
      endAt: j.endAt,
      breakMinutes: j.breakMinutes,
      breakStartAt: j.breakStartAt,
      hourlyWageSnapshot: j.hourlyWageSnapshot,
      memo: j.memo,
      createdAt: j.createdAt,
      updatedAt: j.updatedAt,
    );
  }
}

class UndoController extends Notifier<List<UndoEntry>> {
  static const int maxSize = 5;

  @override
  List<UndoEntry> build() {
    // build는 동기 — 빈 list로 시작, 비동기로 DB에서 로드
    _loadFromDb();
    return const [];
  }

  Future<void> _loadFromDb() async {
    try {
      final settings = await ref.read(appSettingsRepositoryProvider).read();
      final raw = settings.undoStackJson;
      if (raw == null || raw.isEmpty) return;
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final entries = (data['entries'] as List)
          .map((e) => UndoEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      state = entries;
    } catch (_) {
      // 손상된 JSON 무시
    }
  }

  Future<void> _persistToDb() async {
    try {
      final repo = ref.read(appSettingsRepositoryProvider);
      final settings = await repo.read();
      final json = state.isEmpty
          ? null
          : jsonEncode({'entries': state.map((e) => e.toJson()).toList()});
      await repo.update(
        settings.copyWith(
          undoStackJson: json,
          clearUndoStackJson: json == null,
          updatedAt: DateTime.now().toUtc(),
        ),
      );
    } catch (_) {
      // 저장 실패해도 메모리 state는 살아 있음
    }
  }

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
    unawaited(_persistToDb());
  }

  Future<UndoEntry?> undo() async {
    if (state.isEmpty) return null;
    final entry = state.last;
    final repo = ref.read(shiftRepositoryProvider);
    await repo.replaceShiftsInMonth(entry.year, entry.month, entry.shifts);
    state = state.sublist(0, state.length - 1);
    unawaited(_persistToDb());
    return entry;
  }

  void clear() {
    state = const [];
    unawaited(_persistToDb());
  }
}

final undoControllerProvider =
    NotifierProvider<UndoController, List<UndoEntry>>(UndoController.new);
