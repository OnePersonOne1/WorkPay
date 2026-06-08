// SPDX-License-Identifier: GPL-3.0-only
import '../entity/plan.dart';

abstract interface class PlanRepository {
  /// 모든 모의안 stream (메인 제외).
  Stream<List<Plan>> watchAll();

  /// 특정 (year, month)의 모의안들.
  Stream<List<Plan>> watchForMonth(int year, int month);

  Future<Plan?> findById(int id);

  /// 새 모의안 생성. 이름은 호출자가 자동으로 만들어 전달 (예: "6월 모의안 1").
  Future<Plan> create({
    required int year,
    required int month,
    required String name,
  });

  Future<void> rename(int id, String name);

  /// 모의안 삭제. 해당 plan의 모든 시프트도 자동 삭제 (DAO 책임).
  Future<void> delete(int id);

  /// undo 복원용 — 원본 id/메타 그대로 재삽입.
  Future<void> restore(Plan plan);
}
