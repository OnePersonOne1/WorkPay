// SPDX-License-Identifier: GPL-3.0-only
class Shift {
  Shift({
    required this.id,
    required this.jobId,
    required this.startAt,
    required this.endAt,
    required this.breakMinutes,
    required this.breakStartAt,
    required this.hourlyWageSnapshot,
    required this.memo,
    required this.createdAt,
    required this.updatedAt,
  }) {
    if (!endAt.isAfter(startAt)) {
      throw ArgumentError('endAt($endAt)은 startAt($startAt) 이후여야 합니다.');
    }
    if (breakMinutes < 0) {
      throw ArgumentError.value(breakMinutes, 'breakMinutes', 'must be >= 0');
    }
    if (hourlyWageSnapshot < 0) {
      throw ArgumentError.value(
        hourlyWageSnapshot,
        'hourlyWageSnapshot',
        'must be >= 0',
      );
    }
  }

  final int id;
  final int jobId;
  final DateTime startAt;
  final DateTime endAt;
  final int breakMinutes;

  /// 고급 모드에서 사용자가 휴게 시작 시각을 명시한 경우. 미입력이면 null.
  final DateTime? breakStartAt;

  /// 시프트 생성 시점 Job.hourlyWage 스냅샷. 이후 Job의 시급을 바꿔도 과거 시프트는 불변.
  final int hourlyWageSnapshot;

  final String? memo;
  final DateTime createdAt;
  final DateTime updatedAt;

  Duration get totalDuration => endAt.difference(startAt);
  Duration get workDuration => totalDuration - Duration(minutes: breakMinutes);

  /// 캘린더에 표시될 기준 날짜(자정 넘김 시 시작일에 귀속).
  DateTime get displayDate =>
      DateTime(startAt.year, startAt.month, startAt.day);

  Shift copyWith({
    int? jobId,
    DateTime? startAt,
    DateTime? endAt,
    int? breakMinutes,
    DateTime? breakStartAt,
    bool clearBreakStartAt = false,
    int? hourlyWageSnapshot,
    String? memo,
    bool clearMemo = false,
    DateTime? updatedAt,
  }) {
    return Shift(
      id: id,
      jobId: jobId ?? this.jobId,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      breakMinutes: breakMinutes ?? this.breakMinutes,
      breakStartAt: clearBreakStartAt ? null : (breakStartAt ?? this.breakStartAt),
      hourlyWageSnapshot: hourlyWageSnapshot ?? this.hourlyWageSnapshot,
      memo: clearMemo ? null : (memo ?? this.memo),
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Shift &&
      other.id == id &&
      other.jobId == jobId &&
      other.startAt == startAt &&
      other.endAt == endAt &&
      other.breakMinutes == breakMinutes &&
      other.breakStartAt == breakStartAt &&
      other.hourlyWageSnapshot == hourlyWageSnapshot &&
      other.memo == memo &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
        id,
        jobId,
        startAt,
        endAt,
        breakMinutes,
        breakStartAt,
        hourlyWageSnapshot,
        memo,
        createdAt,
        updatedAt,
      );
}
