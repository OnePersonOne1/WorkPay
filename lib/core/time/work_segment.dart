// SPDX-License-Identifier: GPL-3.0-only
/// 하나의 시프트 안에서 동일한 (날짜, 야간여부, 휴일여부)를 갖는 연속 구간.
///
/// 예: 2026-05-31 22:00 ~ 2026-06-01 02:00 시프트는 다음 segment로 분해된다.
///  - 2026-05-31, night=true, 시작 22:00, 끝 24:00 (120분)
///  - 2026-06-01, night=true, 시작 00:00, 끝 02:00 (120분)
class WorkSegment {
  const WorkSegment({
    required this.dayLocal,
    required this.isNight,
    required this.isHoliday,
    required this.minutes,
  });

  /// 이 segment가 속하는 달력 날짜(로컬, 시간부 00:00).
  /// "어느 날의 근무"인지 판정하는 기준.
  final DateTime dayLocal;
  final bool isNight;
  final bool isHoliday;
  final int minutes;

  WorkSegment copyWith({int? minutes}) => WorkSegment(
        dayLocal: dayLocal,
        isNight: isNight,
        isHoliday: isHoliday,
        minutes: minutes ?? this.minutes,
      );

  @override
  String toString() =>
      'WorkSegment(${dayLocal.toIso8601String().substring(0, 10)}, '
      'night=$isNight, holiday=$isHoliday, ${minutes}m)';
}
