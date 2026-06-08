// SPDX-License-Identifier: GPL-3.0-only
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
  Stream<List<ent.Shift>> watchShiftsInMonth(int year, int month, {required int planId}) {
    return _dao
        .watchShiftsInMonth(year, month, planId: planId)
        .map((rows) => rows.map((r) => r.toEntity()).toList());
  }

  @override
  Stream<List<ent.Shift>> watchShiftsOnDate(DateTime date, {required int planId}) {
    return _dao
        .watchShiftsOnDate(date, planId: planId)
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
    required int planId,
  }) async {
    final row = await _dao.create(
      jobId: jobId,
      startAt: startAt,
      endAt: endAt,
      breakMinutes: breakMinutes,
      breakStartAt: breakStartAt,
      memo: memo,
      planId: planId,
      now: _clock(),
    );
    return row.toEntity();
  }

  @override
  Future<List<ent.Shift>> createBulk({
    required int jobId,
    required List<BulkShiftDraft> drafts,
    required int planId,
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
      planId: planId,
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
  Future<int> deleteShiftsInMonth(int year, int month, {required int planId}) =>
      _dao.deleteByMonth(year, month, planId: planId);

  @override
  Future<int> deleteShiftsOfJob(int jobId) => _dao.deleteByJob(jobId);

  @override
  Future<int> deleteShiftsOfPlan(int planId) => _dao.deleteByPlan(planId);

  @override
  Future<void> replaceShiftsInMonth(
    int year,
    int month, {
    required int planId,
    required List<ent.Shift> shifts,
  }) {
    return _dao.replaceMonth(
      year,
      month,
      planId: planId,
      rows: [
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

  @override
  Future<int> copyMonthBetweenPlans({
    required int sourcePlanId,
    required int targetPlanId,
    required int year,
    required int month,
  }) {
    return _dao.copyMonth(
      sourcePlanId: sourcePlanId,
      targetPlanId: targetPlanId,
      year: year,
      month: month,
      now: _clock(),
    );
  }
}
