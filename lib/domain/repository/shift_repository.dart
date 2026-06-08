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
  /// 지정된 연·월에 displayDate(=startAt 날짜)가 속하는 시프트들.
  /// archived job의 시프트도 포함 (과거 기록 보존을 위해).
  Stream<List<Shift>> watchShiftsInMonth(int year, int month);

  /// 특정 날짜의 시프트만.
  Stream<List<Shift>> watchShiftsOnDate(DateTime date);

  Future<Shift?> findById(int id);

  /// hourlyWageSnapshot은 호출자가 제공하지 않는다 — 구현체가 Job에서 복사한다.
  Future<Shift> create({
    required int jobId,
    required DateTime startAt,
    required DateTime endAt,
    required int breakMinutes,
    DateTime? breakStartAt,
    String? memo,
  });

  /// N개 시프트를 한 트랜잭션으로 생성. 같은 jobId, 같은 wage snapshot 사용.
  /// 부분 실패 없음 — 하나라도 실패하면 전체 rollback.
  Future<List<Shift>> createBulk({
    required int jobId,
    required List<BulkShiftDraft> drafts,
  });

  Future<void> update(Shift shift);

  Future<void> delete(int id);

  /// 특정 월의 모든 시프트 삭제. 반환: 삭제된 개수.
  Future<int> deleteShiftsInMonth(int year, int month);

  /// 특정 근무처의 모든 시프트 삭제. 반환: 삭제된 개수.
  Future<int> deleteShiftsOfJob(int jobId);

  /// 특정 월의 시프트를 [shifts]로 통째로 교체. Undo 복원용.
  /// id, hourlyWageSnapshot, createdAt 등 모든 필드 그대로 복원.
  Future<void> replaceShiftsInMonth(int year, int month, List<Shift> shifts);
}
