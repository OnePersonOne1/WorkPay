import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../db/tables.dart';

part 'shift_dao.g.dart';

@DriftAccessor(tables: [Shifts, Jobs])
class ShiftDao extends DatabaseAccessor<AppDatabase> with _$ShiftDaoMixin {
  ShiftDao(super.db);

  /// startAt이 해당 월에 속하는 시프트들 (displayDate=startAt 정책).
  /// UTC 저장이지만 monthRange도 같은 기준(로컬 자정 기준의 UTC 변환)으로 비교.
  Stream<List<Shift>> watchShiftsInMonth(int year, int month) {
    final startLocal = DateTime(year, month, 1);
    final endLocal = DateTime(year, month + 1, 1);
    return (select(shifts)
          ..where((s) => s.startAt.isBiggerOrEqualValue(startLocal.toUtc()) &
              s.startAt.isSmallerThanValue(endLocal.toUtc()))
          ..orderBy([(s) => OrderingTerm(expression: s.startAt)]))
        .watch();
  }

  Stream<List<Shift>> watchShiftsOnDate(DateTime date) {
    final startLocal = DateTime(date.year, date.month, date.day);
    final endLocal = startLocal.add(const Duration(days: 1));
    return (select(shifts)
          ..where((s) => s.startAt.isBiggerOrEqualValue(startLocal.toUtc()) &
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
}
