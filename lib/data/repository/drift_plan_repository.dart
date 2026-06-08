// SPDX-License-Identifier: GPL-3.0-only
import '../../domain/entity/plan.dart' as ent;
import '../../domain/repository/plan_repository.dart';
import '../dao/plan_dao.dart';
import '../dao/shift_dao.dart';
import 'mappers.dart';

class DriftPlanRepository implements PlanRepository {
  DriftPlanRepository(
    this._dao,
    this._shiftDao, {
    DateTime Function()? clock,
  }) : _clock = clock ?? (() => DateTime.now().toUtc());

  final PlanDao _dao;
  final ShiftDao _shiftDao;
  final DateTime Function() _clock;

  @override
  Stream<List<ent.Plan>> watchAll() =>
      _dao.watchAll().map((rows) => rows.map((r) => r.toEntity()).toList());

  @override
  Stream<List<ent.Plan>> watchForMonth(int year, int month) =>
      _dao
          .watchForMonth(year, month)
          .map((rows) => rows.map((r) => r.toEntity()).toList());

  @override
  Future<ent.Plan?> findById(int id) async {
    final row = await _dao.findById(id);
    return row?.toEntity();
  }

  @override
  Future<ent.Plan> create({
    required int year,
    required int month,
    required String name,
  }) async {
    final row = await _dao.create(
      year: year,
      month: month,
      name: name,
      now: _clock(),
    );
    return row.toEntity();
  }

  @override
  Future<void> rename(int id, String name) =>
      _dao.rename(id, name, _clock());

  @override
  Future<void> delete(int id) async {
    // 해당 plan의 모든 시프트 먼저 제거
    await _shiftDao.deleteByPlan(id);
    await _dao.deleteById(id);
  }

  @override
  Future<void> restore(ent.Plan plan) {
    return _dao.insertWithId(
      id: plan.id,
      year: plan.year,
      month: plan.month,
      name: plan.name,
      createdAt: plan.createdAt,
      updatedAt: plan.updatedAt,
    );
  }
}
