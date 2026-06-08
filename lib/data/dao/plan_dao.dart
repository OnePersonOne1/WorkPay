// SPDX-License-Identifier: GPL-3.0-only
import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../db/tables.dart';

part 'plan_dao.g.dart';

@DriftAccessor(tables: [Plans])
class PlanDao extends DatabaseAccessor<AppDatabase> with _$PlanDaoMixin {
  PlanDao(super.db);

  Stream<List<Plan>> watchAll() {
    return (select(plans)
          ..orderBy([(p) => OrderingTerm(expression: p.createdAt)]))
        .watch();
  }

  Stream<List<Plan>> watchForMonth(int year, int month) {
    return (select(plans)
          ..where((p) => p.year.equals(year) & p.month.equals(month))
          ..orderBy([(p) => OrderingTerm(expression: p.createdAt)]))
        .watch();
  }

  Future<Plan?> findById(int id) {
    return (select(plans)..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  Future<Plan> create({
    required int year,
    required int month,
    required String name,
    required DateTime now,
  }) {
    return into(plans).insertReturning(
      PlansCompanion.insert(
        year: year,
        month: month,
        name: name,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> rename(int id, String name, DateTime now) {
    return (update(plans)..where((p) => p.id.equals(id))).write(
      PlansCompanion(
        name: Value(name),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> deleteById(int id) {
    return (delete(plans)..where((p) => p.id.equals(id))).go();
  }

  /// undo 복원용 — 명시적 id 포함 재삽입.
  Future<void> insertWithId({
    required int id,
    required int year,
    required int month,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    return into(plans).insert(
      PlansCompanion.insert(
        id: Value(id),
        year: year,
        month: month,
        name: name,
        createdAt: createdAt,
        updatedAt: updatedAt,
      ),
    );
  }
}
