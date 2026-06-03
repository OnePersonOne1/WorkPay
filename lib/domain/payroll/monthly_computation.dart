import '../entity/monthly_report.dart';

/// 월 단위 계산 결과의 풍부한 표현. UI에서 일/주별 표시에 사용.
///
/// - [report]: 기존 MonthlyReport (모든 합계). UI에서 월 단위 표시 시 사용.
/// - [dailyWorkMinutes]: 일별 실 근무 분 (target month에 속하는 날짜만).
/// - [dailyPayWon]: 일급(원). 기본급 + 야간 + 일 OT + 휴일 가산. (주 OT / 주휴 / 공제는 미포함)
/// - [weeklyWorkMinutes]: 주별 실 근무 분 (주 시작이 target month에 속하는 주만).
/// - [weeklyPayWon]: 주급(원). 해당 주의 모든 일급 + 주 OT + 주휴수당. (공제는 미포함)
class MonthlyComputation {
  const MonthlyComputation({
    required this.report,
    required this.dailyWorkMinutes,
    required this.dailyPayWon,
    required this.weeklyWorkMinutes,
    required this.weeklyPayWon,
  });

  final MonthlyReport report;
  final Map<DateTime, int> dailyWorkMinutes;
  final Map<DateTime, int> dailyPayWon;
  final Map<DateTime, int> weeklyWorkMinutes;
  final Map<DateTime, int> weeklyPayWon;

  /// 다른 [MonthlyComputation]과 합산한다 (다중 근무처 집계용).
  /// 같은 year/month 가정. report.netPay 등도 항목별 합산.
  MonthlyComputation merge(MonthlyComputation other) {
    assert(report.year == other.report.year, 'year mismatch');
    assert(report.month == other.report.month, 'month mismatch');
    return MonthlyComputation(
      report: _mergeReports(report, other.report),
      dailyWorkMinutes: _mergeMaps(dailyWorkMinutes, other.dailyWorkMinutes),
      dailyPayWon: _mergeMaps(dailyPayWon, other.dailyPayWon),
      weeklyWorkMinutes: _mergeMaps(weeklyWorkMinutes, other.weeklyWorkMinutes),
      weeklyPayWon: _mergeMaps(weeklyPayWon, other.weeklyPayWon),
    );
  }

  factory MonthlyComputation.empty(int year, int month) => MonthlyComputation(
        report: MonthlyReport.zero(year, month),
        dailyWorkMinutes: const {},
        dailyPayWon: const {},
        weeklyWorkMinutes: const {},
        weeklyPayWon: const {},
      );
}

Map<DateTime, int> _mergeMaps(Map<DateTime, int> a, Map<DateTime, int> b) {
  final out = <DateTime, int>{...a};
  b.forEach((k, v) => out[k] = (out[k] ?? 0) + v);
  return out;
}

MonthlyReport _mergeReports(MonthlyReport a, MonthlyReport b) {
  return MonthlyReport(
    year: a.year,
    month: a.month,
    totalWorkMinutes: a.totalWorkMinutes + b.totalWorkMinutes,
    basePay: a.basePay + b.basePay,
    nightPremium: a.nightPremium + b.nightPremium,
    dailyOvertimePremium: a.dailyOvertimePremium + b.dailyOvertimePremium,
    weeklyOvertimePremium: a.weeklyOvertimePremium + b.weeklyOvertimePremium,
    holidayPremiumWithinThreshold:
        a.holidayPremiumWithinThreshold + b.holidayPremiumWithinThreshold,
    holidayPremiumOverThreshold:
        a.holidayPremiumOverThreshold + b.holidayPremiumOverThreshold,
    weeklyHolidayAllowance: a.weeklyHolidayAllowance + b.weeklyHolidayAllowance,
    businessIncomeWithholding:
        a.businessIncomeWithholding + b.businessIncomeWithholding,
    fourInsuranceDeduction: a.fourInsuranceDeduction + b.fourInsuranceDeduction,
  );
}
