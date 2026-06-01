import '../entity/shift.dart';

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

  Future<void> update(Shift shift);

  Future<void> delete(int id);
}
