/// 휴일 판정 인터페이스. 향후 한국 공휴일 패키지로 교체 가능.
///
/// '휴일'은 법정공휴일 + (옵션) 일요일을 포함한다. 일요일 처리는 [PayrollConstants]의
/// `sundayIsHoliday`로 결정하므로, 이 구현체는 **공휴일만** 판단하면 된다.
abstract interface class HolidayCalendar {
  bool isPublicHoliday(DateTime date);
}

/// 매년 수동으로 갱신하는 in-memory 구현. 패키지로 대체할 때까지 사용.
class FixedHolidayCalendar implements HolidayCalendar {
  FixedHolidayCalendar(Iterable<DateTime> publicHolidays)
      : _set = publicHolidays
            .map((d) => DateTime(d.year, d.month, d.day))
            .toSet();

  /// 한국 법정공휴일 + 대체공휴일 2025~2027. 출처: 행정안전부 관보.
  /// 매년 1월에 다음해 일정을 추가하면 된다.
  factory FixedHolidayCalendar.korea2025to2027() {
    return FixedHolidayCalendar([
      // ─── 2025 ───
      DateTime(2025, 1, 1), // 신정
      DateTime(2025, 1, 28), // 설날 연휴
      DateTime(2025, 1, 29), // 설날
      DateTime(2025, 1, 30), // 설날 연휴
      DateTime(2025, 3, 1), // 삼일절
      DateTime(2025, 3, 3), // 대체공휴일(3.1 토)
      DateTime(2025, 5, 5), // 어린이날·부처님오신날
      DateTime(2025, 5, 6), // 대체공휴일(5.5 어린이날)
      DateTime(2025, 6, 6), // 현충일
      DateTime(2025, 8, 15), // 광복절
      DateTime(2025, 10, 3), // 개천절
      DateTime(2025, 10, 5), // 추석 연휴
      DateTime(2025, 10, 6), // 추석
      DateTime(2025, 10, 7), // 추석 연휴
      DateTime(2025, 10, 8), // 대체공휴일(10.5 일)
      DateTime(2025, 10, 9), // 한글날
      DateTime(2025, 12, 25), // 성탄절

      // ─── 2026 ───
      DateTime(2026, 1, 1), // 신정
      DateTime(2026, 2, 16), // 설날 연휴
      DateTime(2026, 2, 17), // 설날
      DateTime(2026, 2, 18), // 설날 연휴
      DateTime(2026, 3, 1), // 삼일절 (일) — 대체공휴일 3.2
      DateTime(2026, 3, 2),
      DateTime(2026, 5, 5), // 어린이날
      DateTime(2026, 5, 24), // 부처님오신날 (일) — 대체공휴일 5.25
      DateTime(2026, 5, 25),
      DateTime(2026, 6, 6), // 현충일 (토)
      DateTime(2026, 8, 15), // 광복절 (토)
      DateTime(2026, 9, 24), // 추석 연휴
      DateTime(2026, 9, 25), // 추석
      DateTime(2026, 9, 26), // 추석 연휴
      DateTime(2026, 10, 3), // 개천절 (토)
      DateTime(2026, 10, 9), // 한글날
      DateTime(2026, 12, 25), // 성탄절

      // ─── 2027 ───
      DateTime(2027, 1, 1), // 신정
      DateTime(2027, 2, 6), // 설날 연휴
      DateTime(2027, 2, 7), // 설날 (일) — 대체공휴일 2.8
      DateTime(2027, 2, 8),
      DateTime(2027, 2, 9), // (설 다음날 평일이지만 연휴 마지막)
      DateTime(2027, 3, 1), // 삼일절
      DateTime(2027, 5, 5), // 어린이날
      DateTime(2027, 5, 13), // 부처님오신날
      DateTime(2027, 6, 6), // 현충일 (일) — 대체공휴일 6.7
      DateTime(2027, 6, 7),
      DateTime(2027, 8, 15), // 광복절 (일) — 대체공휴일 8.16
      DateTime(2027, 8, 16),
      DateTime(2027, 9, 14), // 추석 연휴
      DateTime(2027, 9, 15), // 추석
      DateTime(2027, 9, 16), // 추석 연휴
      DateTime(2027, 10, 3), // 개천절 (일) — 대체공휴일 10.4
      DateTime(2027, 10, 4),
      DateTime(2027, 10, 9), // 한글날 (토)
      DateTime(2027, 12, 25), // 성탄절 (토)
    ]);
  }

  final Set<DateTime> _set;

  @override
  bool isPublicHoliday(DateTime date) {
    return _set.contains(DateTime(date.year, date.month, date.day));
  }
}
