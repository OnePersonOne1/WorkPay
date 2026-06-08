// SPDX-License-Identifier: GPL-3.0-only
/// 주(week) 경계 계산. 주는 `weekStartsOn` 요일부터 시작하는 7일.
/// 주 식별자는 "주 시작일(자정 로컬)" — Map 키로 안전하다.
class WeekResolver {
  WeekResolver({this.weekStartsOn = DateTime.monday});

  /// DateTime.monday=1 ~ DateTime.sunday=7
  final int weekStartsOn;

  /// 주어진 날짜가 속한 주의 시작일(로컬, 00:00).
  DateTime weekStartOf(DateTime dateLocal) {
    final day = DateTime(dateLocal.year, dateLocal.month, dateLocal.day);
    // weekday: 1(월)~7(일). weekStartsOn=1이면 월요일에 0 offset.
    final diff = (day.weekday - weekStartsOn + 7) % 7;
    return day.subtract(Duration(days: diff));
  }

  /// 주의 종료 시각(다음 주 시작 직전, 즉 주 시작 + 7일).
  DateTime weekEndOf(DateTime dateLocal) {
    return weekStartOf(dateLocal).add(const Duration(days: 7));
  }

  /// 주 시작일이 해당 (year, month)에 속하면 true.
  /// 월별 리포트의 주 단위 항목(주휴수당·주연장)을 어느 달에 귀속할지 판단.
  bool weekBelongsToMonth(DateTime weekStart, int year, int month) {
    return weekStart.year == year && weekStart.month == month;
  }
}
