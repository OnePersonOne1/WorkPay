import 'package:drift/drift.dart';

import '../../domain/entity/shift.dart' as ent;
import '../../domain/repository/shift_repository.dart';
import '../dao/shift_dao.dart';
import '../db/app_database.dart' as db;
import 'mappers.dart';

class DriftShiftRepository implements ShiftRepository {
  DriftShiftRepository(this._dao, {DateTime Function()? clock})
      : _clock = clock ?? (() => DateTime.now().toUtc());

  final ShiftDao _dao;
  final DateTime Function() _clock;

  @override
  Stream<List<ent.Shift>> watchShiftsInMonth(int year, int month) {
    return _dao
        .watchShiftsInMonth(year, month)
        .map((rows) => rows.map((r) => r.toEntity()).toList());
  }

  @override
  Stream<List<ent.Shift>> watchShiftsOnDate(DateTime date) {
    return _dao
        .watchShiftsOnDate(date)
        .map((rows) => rows.map((r) => r.toEntity()).toList());
  }

  @override
  Future<ent.Shift?> findById(int id) async {
    final row = await _dao.findById(id);
    return row?.toEntity();
  }

  @override
  Future<ent.Shift> create({
    required int jobId,
    required DateTime startAt,
    required DateTime endAt,
    required int breakMinutes,
    DateTime? breakStartAt,
    String? memo,
  }) async {
    final row = await _dao.create(
      jobId: jobId,
      startAt: startAt,
      endAt: endAt,
      breakMinutes: breakMinutes,
      breakStartAt: breakStartAt,
      memo: memo,
      now: _clock(),
    );
    return row.toEntity();
  }

  @override
  Future<List<ent.Shift>> createBulk({
    required int jobId,
    required List<BulkShiftDraft> drafts,
  }) async {
    final rows = await _dao.createBulk(
      jobId: jobId,
      drafts: [
        for (final d in drafts)
          (
            startAt: d.startAt,
            endAt: d.endAt,
            breakMinutes: d.breakMinutes,
            breakStartAt: d.breakStartAt,
            memo: d.memo,
          ),
      ],
      now: _clock(),
    );
    return rows.map((r) => r.toEntity()).toList();
  }

  @override
  Future<void> update(ent.Shift shift) {
    return _dao.updateShift(
      shift.id,
      db.ShiftsCompanion(
        jobId: Value(shift.jobId),
        startAt: Value(shift.startAt.toUtc()),
        endAt: Value(shift.endAt.toUtc()),
        breakMinutes: Value(shift.breakMinutes),
        breakStartAt: Value(shift.breakStartAt?.toUtc()),
        memo: Value(shift.memo),
        updatedAt: Value(_clock()),
      ),
    );
  }

  @override
  Future<void> delete(int id) => _dao.deleteById(id);

  @override
  Future<int> deleteShiftsInMonth(int year, int month) =>
      _dao.deleteByMonth(year, month);

  @override
  Future<int> deleteShiftsOfJob(int jobId) => _dao.deleteByJob(jobId);

  @override
  Future<void> replaceShiftsInMonth(
      int year, int month, List<ent.Shift> shifts) {
    return _dao.replaceMonth(
      year,
      month,
      [
        for (final s in shifts)
          (
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
          ),
      ],
    );
  }
}
