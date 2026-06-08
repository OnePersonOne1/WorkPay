// SPDX-License-Identifier: GPL-3.0-only
import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../domain/entity/plan.dart' as ent;
import '../../domain/entity/shift.dart';
import '../backup/backup_format.dart' show ShiftJson;

/// 시프트/플랜 변경에 대한 Undo + Redo 스택 (각각 최대 5개).
///
/// 영구 저장: AppSettings.undoStackJson에 `{undo: [...], redo: [...]}`.
/// 백업 파일에는 포함되지 않음 (사용자 액션 이력).
class UndoEntry {
  const UndoEntry({
    required this.description,
    required this.year,
    required this.month,
    required this.planId,
    required this.shifts,
    this.planToRestore,
    this.planToDelete,
    this.activePlanIdToRestore,
  });

  final String description;
  final int year;
  final int month;
  final int planId;
  final List<Shift> shifts;

  /// 적용 시 plan 행을 먼저 재삽입 (모의안 삭제 undo용).
  final ent.Plan? planToRestore;

  /// 적용 시 shifts 교체 후 plan을 삭제 (모의안 삭제의 redo용).
  final ent.Plan? planToDelete;

  /// 적용 시 활성 plan id를 이 값으로 복원.
  final int? activePlanIdToRestore;

  Map<String, dynamic> toJson() => {
        'description': description,
        'year': year,
        'month': month,
        'planId': planId,
        'shifts': shifts.map(_shiftToJson).toList(),
        if (planToRestore != null) 'planToRestore': _planToJson(planToRestore!),
        if (planToDelete != null) 'planToDelete': _planToJson(planToDelete!),
        if (activePlanIdToRestore != null)
          'activePlanIdToRestore': activePlanIdToRestore,
      };

  factory UndoEntry.fromJson(Map<String, dynamic> json) {
    return UndoEntry(
      description: json['description'] as String,
      year: json['year'] as int,
      month: json['month'] as int,
      planId: json['planId'] as int? ?? 0,
      shifts: (json['shifts'] as List)
          .map((e) => _shiftFromJson(e as Map<String, dynamic>))
          .toList(),
      planToRestore: json['planToRestore'] == null
          ? null
          : _planFromJson(json['planToRestore'] as Map<String, dynamic>),
      planToDelete: json['planToDelete'] == null
          ? null
          : _planFromJson(json['planToDelete'] as Map<String, dynamic>),
      activePlanIdToRestore: json['activePlanIdToRestore'] as int?,
    );
  }

  static Map<String, dynamic> _planToJson(ent.Plan p) => {
        'id': p.id,
        'year': p.year,
        'month': p.month,
        'name': p.name,
        'createdAt': p.createdAt.toUtc().toIso8601String(),
        'updatedAt': p.updatedAt.toUtc().toIso8601String(),
      };

  static ent.Plan _planFromJson(Map<String, dynamic> json) => ent.Plan(
        id: json['id'] as int,
        year: json['year'] as int,
        month: json['month'] as int,
        name: json['name'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  static Map<String, dynamic> _shiftToJson(Shift s) {
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

/// Undo + Redo 스택 묶음.
class UndoState {
  const UndoState({this.undoStack = const [], this.redoStack = const []});

  final List<UndoEntry> undoStack;
  final List<UndoEntry> redoStack;

  bool get canUndo => undoStack.isNotEmpty;
  bool get canRedo => redoStack.isNotEmpty;

  UndoState copyWith({
    List<UndoEntry>? undoStack,
    List<UndoEntry>? redoStack,
  }) =>
      UndoState(
        undoStack: undoStack ?? this.undoStack,
        redoStack: redoStack ?? this.redoStack,
      );
}

class UndoController extends Notifier<UndoState> {
  static const int maxSize = 5;

  @override
  UndoState build() {
    _loadFromDb();
    return const UndoState();
  }

  Future<void> _loadFromDb() async {
    try {
      final settings = await ref.read(appSettingsRepositoryProvider).read();
      final raw = settings.undoStackJson;
      if (raw == null || raw.isEmpty) return;
      final data = jsonDecode(raw) as Map<String, dynamic>;
      // 새 포맷: {undo: [...], redo: [...]}
      // 구 포맷 (v6 이전): {entries: [...]} — undo만 있던 시절
      final undoRaw = (data['undo'] ?? data['entries']) as List?;
      final redoRaw = data['redo'] as List?;
      final undoList = undoRaw == null
          ? const <UndoEntry>[]
          : undoRaw
              .map((e) => UndoEntry.fromJson(e as Map<String, dynamic>))
              .toList();
      final redoList = redoRaw == null
          ? const <UndoEntry>[]
          : redoRaw
              .map((e) => UndoEntry.fromJson(e as Map<String, dynamic>))
              .toList();
      state = UndoState(undoStack: undoList, redoStack: redoList);
    } catch (_) {}
  }

  Future<void> _persistToDb() async {
    try {
      final repo = ref.read(appSettingsRepositoryProvider);
      final settings = await repo.read();
      final json = (state.undoStack.isEmpty && state.redoStack.isEmpty)
          ? null
          : jsonEncode({
              'undo': state.undoStack.map((e) => e.toJson()).toList(),
              'redo': state.redoStack.map((e) => e.toJson()).toList(),
            });
      await repo.update(
        settings.copyWith(
          undoStackJson: json,
          clearUndoStackJson: json == null,
          updatedAt: DateTime.now().toUtc(),
        ),
      );
    } catch (_) {}
  }

  /// 액션 직전 스냅샷 — undo 스택에 push, redo 스택은 clear (분기 발생).
  Future<void> snapshotBefore({
    required int year,
    required int month,
    required int planId,
    required String description,
  }) async {
    final repo = ref.read(shiftRepositoryProvider);
    final shifts = await repo.watchShiftsInMonth(year, month, planId: planId).first;
    final entry = UndoEntry(
      description: description,
      year: year,
      month: month,
      planId: planId,
      shifts: shifts,
    );
    _pushUndo(entry, clearRedo: true);
  }

  /// 모의안 삭제 전 스냅샷 — plan 메타 + 시프트 + 활성 planId 캡처.
  Future<void> snapshotBeforePlanDeletion({
    required ent.Plan plan,
    required String description,
  }) async {
    final shiftRepo = ref.read(shiftRepositoryProvider);
    final shifts = await shiftRepo
        .watchShiftsInMonth(plan.year, plan.month, planId: plan.id)
        .first;
    final settings = await ref.read(appSettingsRepositoryProvider).read();
    final entry = UndoEntry(
      description: description,
      year: plan.year,
      month: plan.month,
      planId: plan.id,
      shifts: shifts,
      planToRestore: plan,
      activePlanIdToRestore: settings.activePlanId,
    );
    _pushUndo(entry, clearRedo: true);
  }

  void _pushUndo(UndoEntry entry, {required bool clearRedo}) {
    final nextUndo = [...state.undoStack, entry];
    if (nextUndo.length > maxSize) nextUndo.removeAt(0);
    state = state.copyWith(
      undoStack: nextUndo,
      redoStack: clearRedo ? const [] : state.redoStack,
    );
    unawaited(_persistToDb());
  }

  /// 되돌리기. 현재 상태의 inverse를 redo 스택에 push.
  Future<UndoEntry?> undo() async {
    if (state.undoStack.isEmpty) return null;
    final entry = state.undoStack.last;
    final inverse = await _captureCurrentAsInverse(entry);
    await _applyEntry(entry);
    state = state.copyWith(
      undoStack: state.undoStack.sublist(0, state.undoStack.length - 1),
      redoStack: _appendCapped(state.redoStack, inverse),
    );
    unawaited(_persistToDb());
    return entry;
  }

  /// 다시 실행. 현재 상태의 inverse를 undo 스택에 push.
  Future<UndoEntry?> redo() async {
    if (state.redoStack.isEmpty) return null;
    final entry = state.redoStack.last;
    final inverse = await _captureCurrentAsInverse(entry);
    await _applyEntry(entry);
    state = state.copyWith(
      undoStack: _appendCapped(state.undoStack, inverse),
      redoStack: state.redoStack.sublist(0, state.redoStack.length - 1),
    );
    unawaited(_persistToDb());
    return entry;
  }

  List<UndoEntry> _appendCapped(List<UndoEntry> list, UndoEntry e) {
    final next = [...list, e];
    if (next.length > maxSize) next.removeAt(0);
    return next;
  }

  /// 적용 직전의 현재 상태를 반대방향 entry로 캡처.
  /// (year, month, planId) 단위의 현재 시프트 + plan 존재 여부 + 활성 planId.
  Future<UndoEntry> _captureCurrentAsInverse(UndoEntry entry) async {
    final shiftRepo = ref.read(shiftRepositoryProvider);
    final currentShifts = await shiftRepo
        .watchShiftsInMonth(entry.year, entry.month, planId: entry.planId)
        .first;

    // plan-row의 반대 방향:
    // entry가 plan을 복원하면 inverse는 그 plan을 삭제.
    // entry가 plan을 삭제하면 inverse는 그 plan을 복원.
    ent.Plan? planToRestore;
    ent.Plan? planToDelete;
    if (entry.planToRestore != null) {
      planToDelete = entry.planToRestore;
    } else if (entry.planToDelete != null) {
      planToRestore = entry.planToDelete;
    }

    int? activePlanIdToRestore;
    if (entry.activePlanIdToRestore != null) {
      final cur = await ref.read(appSettingsRepositoryProvider).read();
      activePlanIdToRestore = cur.activePlanId;
    }

    return UndoEntry(
      description: entry.description,
      year: entry.year,
      month: entry.month,
      planId: entry.planId,
      shifts: currentShifts,
      planToRestore: planToRestore,
      planToDelete: planToDelete,
      activePlanIdToRestore: activePlanIdToRestore,
    );
  }

  /// entry를 DB에 적용. planToRestore → shifts replace → planToDelete → activePlanId 순.
  Future<void> _applyEntry(UndoEntry entry) async {
    if (entry.planToRestore != null) {
      final planRepo = ref.read(planRepositoryProvider);
      final existing = await planRepo.findById(entry.planToRestore!.id);
      if (existing == null) {
        await planRepo.restore(entry.planToRestore!);
      }
    }
    final shiftRepo = ref.read(shiftRepositoryProvider);
    await shiftRepo.replaceShiftsInMonth(
      entry.year,
      entry.month,
      planId: entry.planId,
      shifts: entry.shifts,
    );
    if (entry.planToDelete != null) {
      final planRepo = ref.read(planRepositoryProvider);
      final existing = await planRepo.findById(entry.planToDelete!.id);
      if (existing != null) {
        await planRepo.delete(entry.planToDelete!.id);
      }
    }
    if (entry.activePlanIdToRestore != null) {
      final settingsRepo = ref.read(appSettingsRepositoryProvider);
      final cur = await settingsRepo.read();
      if (cur.activePlanId != entry.activePlanIdToRestore) {
        await settingsRepo.update(
          cur.copyWith(
            activePlanId: entry.activePlanIdToRestore!,
            updatedAt: DateTime.now().toUtc(),
          ),
        );
      }
    }
  }

  void clear() {
    state = const UndoState();
    unawaited(_persistToDb());
  }
}

final undoControllerProvider =
    NotifierProvider<UndoController, UndoState>(UndoController.new);
