// SPDX-License-Identifier: GPL-3.0-only
import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../db/tables.dart';

part 'shift_dao.g.dart';

@DriftAccessor(tables: [Shifts, Jobs])
class ShiftDao extends DatabaseAccessor<AppDatabase> with _$ShiftDaoMixin {
  ShiftDao(super.db);

  /// startAt이 해당 월에 속하는 시프트들 (displayDate=startAt 정책).
  /// planId 필터링 — 0=메인, >0=모의안.
  Stream<List<Shift>> watchShiftsInMonth(int year, int month, {required int planId}) {
    final startLocal = DateTime(year, month, 1);
    final endLocal = DateTime(year, month + 1, 1);
    return (select(shifts)
          ..where((s) =>
              s.planId.equals(planId) &
              s.startAt.isBiggerOrEqualValue(startLocal.toUtc()) &
              s.startAt.isSmallerThanValue(endLocal.toUtc()))
          ..orderBy([(s) => OrderingTerm(expression: s.startAt)]))
        .watch();
  }

  Stream<List<Shift>> watchShiftsOnDate(DateTime date, {required int planId}) {
    final startLocal = DateTime(date.year, date.month, date.day);
    final endLocal = startLocal.add(const Duration(days: 1));
    return (select(shifts)
          ..where((s) =>
              s.planId.equals(planId) &
              s.startAt.isBiggerOrEqualValue(startLocal.toUtc()) &
              s.startAt.isSmallerThanValue(endLocal.toUtc()))
          ..orderBy([(s) => OrderingTerm(expression: s.startAt)]))
        .watch();
  }

  Future<Shift?> findById(int id) {
    return (select(shifts)..where((s) => s.id.equals(id))).getSingleOrNull();
  }

  /// jobId의 현재 hourlyWage를 스냅샷으로 박제한 뒤 삽입한다.
  Future<Shift> create({
    required int jobId,
    required DateTime startAt,
    required DateTime endAt,
    required int breakMinutes,
    DateTime? breakStartAt,
    String? memo,
    required int planId,
    required DateTime now,
  }) {
    return transaction(() async {
      final job = await (select(jobs)..where((j) => j.id.equals(jobId)))
          .getSingleOrNull();
      if (job == null) {
        throw StateError('Job not found: $jobId');
      }
      return into(shifts).insertReturning(
        ShiftsCompanion.insert(
          jobId: jobId,
          startAt: startAt.toUtc(),
          endAt: endAt.toUtc(),
          breakMinutes: Value(breakMinutes),
          breakStartAt: Value(breakStartAt?.toUtc()),
          hourlyWageSnapshot: job.hourlyWage,
          memo: Value(memo),
          planId: Value(planId),
          createdAt: now,
          updatedAt: now,
        ),
      );
    });
  }

  /// N개 시프트를 한 트랜잭션으로 생성. 같은 jobId, 같은 wage snapshot.
  Future<List<Shift>> createBulk({
    required int jobId,
    required List<({DateTime startAt, DateTime endAt, int breakMinutes,
        DateTime? breakStartAt, String? memo})> drafts,
    required int planId,
    required DateTime now,
  }) {
    return transaction(() async {
      final job = await (select(jobs)..where((j) => j.id.equals(jobId)))
          .getSingleOrNull();
      if (job == null) {
        throw StateError('Job not found: $jobId');
      }
      final out = <Shift>[];
      for (final d in drafts) {
        final row = await into(shifts).insertReturning(
          ShiftsCompanion.insert(
            jobId: jobId,
            startAt: d.startAt.toUtc(),
            endAt: d.endAt.toUtc(),
            breakMinutes: Value(d.breakMinutes),
            breakStartAt: Value(d.breakStartAt?.toUtc()),
            hourlyWageSnapshot: job.hourlyWage,
            memo: Value(d.memo),
            planId: Value(planId),
            createdAt: now,
            updatedAt: now,
          ),
        );
        out.add(row);
      }
      return out;
    });
  }

  Future<void> updateShift(int id, ShiftsCompanion shift) {
    return (update(shifts)..where((s) => s.id.equals(id))).write(shift);
  }

  Future<void> deleteById(int id) {
    return (delete(shifts)..where((s) => s.id.equals(id))).go();
  }

  /// 지정 plan + 월의 모든 시프트 삭제.
  Future<int> deleteByMonth(int year, int month, {required int planId}) async {
    final startLocal = DateTime(year, month, 1);
    final endLocal = DateTime(year, month + 1, 1);
    return (delete(shifts)
          ..where((s) =>
              s.planId.equals(planId) &
              s.startAt.isBiggerOrEqualValue(startLocal.toUtc()) &
              s.startAt.isSmallerThanValue(endLocal.toUtc())))
        .go();
  }

  /// plan 전체 시프트 삭제 (plan 자체 삭제 전에 호출).
  Future<int> deleteByPlan(int planId) {
    return (delete(shifts)..where((s) => s.planId.equals(planId))).go();
  }

  /// 특정 근무처의 모든 시프트 삭제 (모든 plan 통틀어).
  Future<int> deleteByJob(int jobId) {
    return (delete(shifts)..where((s) => s.jobId.equals(jobId))).go();
  }

  /// 트랜잭션으로 plan 내 특정 월 시프트를 통째로 교체. ID 등 모든 필드 보존.
  /// Undo 복원, 메인↔모의안 교체 양쪽에 쓰임.
  Future<void> replaceMonth(
    int year,
    int month, {
    required int planId,
    required List<({
      int id,
      int jobId,
      DateTime startAt,
      DateTime endAt,
      int breakMinutes,
      DateTime? breakStartAt,
      int hourlyWageSnapshot,
      String? memo,
      DateTime createdAt,
      DateTime updatedAt,
    })> rows,
  }) async {
    await transaction(() async {
      await deleteByMonth(year, month, planId: planId);
      for (final r in rows) {
        await into(shifts).insert(
          ShiftsCompanion.insert(
            id: Value(r.id),
            jobId: r.jobId,
            startAt: r.startAt.toUtc(),
            endAt: r.endAt.toUtc(),
            breakMinutes: Value(r.breakMinutes),
            breakStartAt: Value(r.breakStartAt?.toUtc()),
            hourlyWageSnapshot: r.hourlyWageSnapshot,
            memo: Value(r.memo),
            planId: Value(planId),
            createdAt: r.createdAt,
            updatedAt: r.updatedAt,
          ),
        );
      }
    });
  }

  /// 한 plan의 한 달을 다른 plan으로 복제. 대상 plan의 그 달은 모두 삭제.
  /// ID는 새로 생성 (자동 증가). copy snapshot은 유지.
  Future<int> copyMonth({
    required int sourcePlanId,
    required int targetPlanId,
    required int year,
    required int month,
    required DateTime now,
  }) async {
    return transaction(() async {
      final startLocal = DateTime(year, month, 1);
      final endLocal = DateTime(year, month + 1, 1);
      // 대상 plan의 해당 월 시프트 모두 삭제
      await deleteByMonth(year, month, planId: targetPlanId);
      // 소스 plan의 해당 월 시프트 조회
      final src = await (select(shifts)
            ..where((s) =>
                s.planId.equals(sourcePlanId) &
                s.startAt.isBiggerOrEqualValue(startLocal.toUtc()) &
                s.startAt.isSmallerThanValue(endLocal.toUtc())))
          .get();
      // 대상 plan으로 복사 (새 ID, 같은 데이터)
      for (final s in src) {
        await into(shifts).insert(
          ShiftsCompanion.insert(
            jobId: s.jobId,
            startAt: s.startAt,
            endAt: s.endAt,
            breakMinutes: Value(s.breakMinutes),
            breakStartAt: Value(s.breakStartAt),
            hourlyWageSnapshot: s.hourlyWageSnapshot,
            memo: Value(s.memo),
            planId: Value(targetPlanId),
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
      return src.length;
    });
  }
}
