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
}
