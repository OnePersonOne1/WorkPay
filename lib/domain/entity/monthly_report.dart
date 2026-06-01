import '../../core/money/money.dart';

/// 월별 급여 집계 결과. 항목별 분리 — UI에서 항목별 카드로 표시.
///
/// **불변식**: basePay + 모든 premium - totalDeduction == netPay
class MonthlyReport {
  const MonthlyReport({
    required this.year,
    required this.month,
    required this.totalWorkMinutes,
    required this.basePay,
    required this.nightPremium,
    required this.dailyOvertimePremium,
    required this.weeklyOvertimePremium,
    required this.holidayPremiumWithinThreshold,
    required this.holidayPremiumOverThreshold,
    required this.weeklyHolidayAllowance,
    required this.businessIncomeWithholding,
    required this.fourInsuranceDeduction,
  });

  factory MonthlyReport.zero(int year, int month) => MonthlyReport(
        year: year,
        month: month,
        totalWorkMinutes: 0,
        basePay: Money.zero(),
        nightPremium: Money.zero(),
        dailyOvertimePremium: Money.zero(),
        weeklyOvertimePremium: Money.zero(),
        holidayPremiumWithinThreshold: Money.zero(),
        holidayPremiumOverThreshold: Money.zero(),
        weeklyHolidayAllowance: Money.zero(),
        businessIncomeWithholding: Money.zero(),
        fourInsuranceDeduction: Money.zero(),
      );

  final int year;
  final int month;

  /// 휴게시간을 차감한 실 근무 분.
  final int totalWorkMinutes;

  // ─── 지급 항목 ───
  final Money basePay;
  final Money nightPremium;
  final Money dailyOvertimePremium;
  final Money weeklyOvertimePremium;
  final Money holidayPremiumWithinThreshold; // 휴일 8h 이내
  final Money holidayPremiumOverThreshold; // 휴일 8h 초과
  final Money weeklyHolidayAllowance; // 주휴수당

  // ─── 공제 항목 ───
  final Money businessIncomeWithholding; // 3.3%
  final Money fourInsuranceDeduction; // 4대보험

  Money get totalPremiums =>
      nightPremium +
      dailyOvertimePremium +
      weeklyOvertimePremium +
      holidayPremiumWithinThreshold +
      holidayPremiumOverThreshold +
      weeklyHolidayAllowance;

  Money get grossPay => basePay + totalPremiums;

  Money get totalDeduction =>
      businessIncomeWithholding + fourInsuranceDeduction;

  Money get netPay => grossPay - totalDeduction;

  @override
  bool operator ==(Object other) =>
      other is MonthlyReport &&
      other.year == year &&
      other.month == month &&
      other.totalWorkMinutes == totalWorkMinutes &&
      other.basePay == basePay &&
      other.nightPremium == nightPremium &&
      other.dailyOvertimePremium == dailyOvertimePremium &&
      other.weeklyOvertimePremium == weeklyOvertimePremium &&
      other.holidayPremiumWithinThreshold == holidayPremiumWithinThreshold &&
      other.holidayPremiumOverThreshold == holidayPremiumOverThreshold &&
      other.weeklyHolidayAllowance == weeklyHolidayAllowance &&
      other.businessIncomeWithholding == businessIncomeWithholding &&
      other.fourInsuranceDeduction == fourInsuranceDeduction;

  @override
  int get hashCode => Object.hashAll([
        year,
        month,
        totalWorkMinutes,
        basePay,
        nightPremium,
        dailyOvertimePremium,
        weeklyOvertimePremium,
        holidayPremiumWithinThreshold,
        holidayPremiumOverThreshold,
        weeklyHolidayAllowance,
        businessIncomeWithholding,
        fourInsuranceDeduction,
      ]);
}

/// MonthlyReport 누산용 가변 객체 (분 단위 정수로 누산 후 마지막에 Money로 변환).
class MonthlyReportBuilder {
  MonthlyReportBuilder({required this.year, required this.month});

  final int year;
  final int month;

  int totalWorkMinutes = 0;

  // 모든 누산은 "원 단위 정수"로 진행 (반올림 손실 방지).
  int basePayWon = 0;
  int nightPremiumWon = 0;
  int dailyOvertimePremiumWon = 0;
  int weeklyOvertimePremiumWon = 0;
  int holidayPremiumWithinThresholdWon = 0;
  int holidayPremiumOverThresholdWon = 0;
  int weeklyHolidayAllowanceWon = 0;
  int businessIncomeWithholdingWon = 0;
  int fourInsuranceDeductionWon = 0;

  MonthlyReport build() => MonthlyReport(
        year: year,
        month: month,
        totalWorkMinutes: totalWorkMinutes,
        basePay: Money(basePayWon),
        nightPremium: Money(nightPremiumWon),
        dailyOvertimePremium: Money(dailyOvertimePremiumWon),
        weeklyOvertimePremium: Money(weeklyOvertimePremiumWon),
        holidayPremiumWithinThreshold: Money(holidayPremiumWithinThresholdWon),
        holidayPremiumOverThreshold: Money(holidayPremiumOverThresholdWon),
        weeklyHolidayAllowance: Money(weeklyHolidayAllowanceWon),
        businessIncomeWithholding: Money(businessIncomeWithholdingWon),
        fourInsuranceDeduction: Money(fourInsuranceDeductionWon),
      );
}
