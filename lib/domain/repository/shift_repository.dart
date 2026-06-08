// SPDX-License-Identifier: GPL-3.0-only
import '../entity/shift.dart';

/// 일괄 생성용 입력. memo만 공통이고 시각은 항목별.
class BulkShiftDraft {
  const BulkShiftDraft({
    required this.startAt,
    required this.endAt,
    required this.breakMinutes,
    this.breakStartAt,
    this.memo,
  });

  final DateTime startAt;
  final DateTime endAt;
  final int breakMinutes;
  final DateTime? breakStartAt;
  final String? memo;
}

abstract interface class ShiftRepository {
  /// 지정 plan + 월의 시프트들.
  Stream<List<Shift>> watchShiftsInMonth(int year, int month, {required int planId});

  Stream<List<Shift>> watchShiftsOnDate(DateTime date, {required int planId});

  Future<Shift?> findById(int id);

  /// hourlyWageSnapshot은 호출자가 제공하지 않는다 — 구현체가 Job에서 복사한다.
  Future<Shift> create({
    required int jobId,
    required DateTime startAt,
    required DateTime endAt,
    required int breakMinutes,
    DateTime? breakStartAt,
    String? memo,
    required int planId,
  });

  Future<List<Shift>> createBulk({
    required int jobId,
    required List<BulkShiftDraft> drafts,
    required int planId,
  });

  Future<void> update(Shift shift);

  Future<void> delete(int id);

  /// 지정 plan + 월의 모든 시프트 삭제.
  Future<int> deleteShiftsInMonth(int year, int month, {required int planId});

  /// 특정 근무처의 모든 시프트 삭제 (모든 plan 통틀어).
  Future<int> deleteShiftsOfJob(int jobId);

  /// 지정 plan의 모든 시프트 삭제 (plan 자체 삭제 직전 호출).
  Future<int> deleteShiftsOfPlan(int planId);

  /// plan + 월의 시프트를 [shifts]로 통째로 교체. Undo 복원용.
  Future<void> replaceShiftsInMonth(
    int year,
    int month, {
    required int planId,
    required List<Shift> shifts,
  });

  /// 한 plan의 한 달을 다른 plan으로 복제. 대상 plan의 그 달은 모두 삭제 후 복사.
  /// 반환: 복사된 시프트 수.
  Future<int> copyMonthBetweenPlans({
    required int sourcePlanId,
    required int targetPlanId,
    required int year,
    required int month,
  });
}
