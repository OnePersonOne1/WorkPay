/// 급여 계산에 사용되는 모든 상수. 한국 노동법 기본값을 [PayrollConstants.koreanDefault]로 제공.
/// 향후 '고고급 설정'에서 사용자가 override할 수 있다.
///
/// 모든 rate는 정수(basis points, 10000분율). 예: 50% = 5000, 3.3% = 330.
/// 모든 threshold·time-of-day는 정수(분).
class PayrollConstants {
  const PayrollConstants({
    required this.nightStartMinuteOfDay,
    required this.nightEndMinuteOfDay,
    required this.dailyOvertimeThresholdMinutes,
    required this.weeklyOvertimeThresholdMinutes,
    required this.weeklyHolidayThresholdMinutes,
    required this.nightPremiumRateBp,
    required this.dailyOvertimePremiumRateBp,
    required this.weeklyOvertimePremiumRateBp,
    required this.holidayPremiumWithinDailyThresholdRateBp,
    required this.holidayPremiumOverDailyThresholdRateBp,
    required this.businessIncomeWithholdingRateBp,
    required this.weekStartsOn,
    required this.sundayIsHoliday,
  });

  /// 한국 근로기준법 기준 기본값 (2025).
  /// 사용자 override 없이 그대로 쓰면 표준 계산이 된다.
  factory PayrollConstants.koreanDefault() => const PayrollConstants(
        nightStartMinuteOfDay: 22 * 60, // 22:00
        nightEndMinuteOfDay: 6 * 60, // 06:00 (다음 날)
        dailyOvertimeThresholdMinutes: 8 * 60, // 일 8시간
        weeklyOvertimeThresholdMinutes: 40 * 60, // 주 40시간
        weeklyHolidayThresholdMinutes: 15 * 60, // 주휴수당 15시간
        nightPremiumRateBp: 5000, // 50%
        dailyOvertimePremiumRateBp: 5000, // 50%
        weeklyOvertimePremiumRateBp: 5000, // 50%
        holidayPremiumWithinDailyThresholdRateBp: 5000, // 8h 이내 +50%
        holidayPremiumOverDailyThresholdRateBp: 10000, // 8h 초과 +100%
        businessIncomeWithholdingRateBp: 330, // 3.3%
        weekStartsOn: DateTime.monday,
        sundayIsHoliday: true,
      );

  /// 야간 시간대 시작 (분 of day). 기본 22:00.
  final int nightStartMinuteOfDay;

  /// 야간 시간대 종료 (분 of day, 다음 날의 시각). 기본 06:00.
  /// 0 <= nightEnd < nightStart 라면 자정을 넘는 구간으로 해석한다.
  final int nightEndMinuteOfDay;

  /// 일 연장근로 기준 (분). 이 시간을 초과한 근무에 가산.
  final int dailyOvertimeThresholdMinutes;

  /// 주 연장근로 기준 (분).
  final int weeklyOvertimeThresholdMinutes;

  /// 주휴수당 자격 최저 근로시간 (분). 이상 + 결근 없음이면 지급.
  final int weeklyHolidayThresholdMinutes;

  final int nightPremiumRateBp;
  final int dailyOvertimePremiumRateBp;
  final int weeklyOvertimePremiumRateBp;

  /// 휴일근로 가산: 일 연장기준(8h) 이내 분에 적용.
  final int holidayPremiumWithinDailyThresholdRateBp;

  /// 휴일근로 가산: 일 연장기준 초과 분에 적용.
  final int holidayPremiumOverDailyThresholdRateBp;

  /// 사업소득 원천징수율. 소득세 3% + 지방소득세 0.3%.
  final int businessIncomeWithholdingRateBp;

  /// 주 시작 요일 (DateTime.monday=1 ~ DateTime.sunday=7). 기본 월요일.
  final int weekStartsOn;

  /// 일요일을 휴일로 취급할지. 기본 true (주휴일 관례).
  final bool sundayIsHoliday;

  PayrollConstants copyWith({
    int? nightStartMinuteOfDay,
    int? nightEndMinuteOfDay,
    int? dailyOvertimeThresholdMinutes,
    int? weeklyOvertimeThresholdMinutes,
    int? weeklyHolidayThresholdMinutes,
    int? nightPremiumRateBp,
    int? dailyOvertimePremiumRateBp,
    int? weeklyOvertimePremiumRateBp,
    int? holidayPremiumWithinDailyThresholdRateBp,
    int? holidayPremiumOverDailyThresholdRateBp,
    int? businessIncomeWithholdingRateBp,
    int? weekStartsOn,
    bool? sundayIsHoliday,
  }) {
    return PayrollConstants(
      nightStartMinuteOfDay: nightStartMinuteOfDay ?? this.nightStartMinuteOfDay,
      nightEndMinuteOfDay: nightEndMinuteOfDay ?? this.nightEndMinuteOfDay,
      dailyOvertimeThresholdMinutes:
          dailyOvertimeThresholdMinutes ?? this.dailyOvertimeThresholdMinutes,
      weeklyOvertimeThresholdMinutes:
          weeklyOvertimeThresholdMinutes ?? this.weeklyOvertimeThresholdMinutes,
      weeklyHolidayThresholdMinutes:
          weeklyHolidayThresholdMinutes ?? this.weeklyHolidayThresholdMinutes,
      nightPremiumRateBp: nightPremiumRateBp ?? this.nightPremiumRateBp,
      dailyOvertimePremiumRateBp:
          dailyOvertimePremiumRateBp ?? this.dailyOvertimePremiumRateBp,
      weeklyOvertimePremiumRateBp:
          weeklyOvertimePremiumRateBp ?? this.weeklyOvertimePremiumRateBp,
      holidayPremiumWithinDailyThresholdRateBp:
          holidayPremiumWithinDailyThresholdRateBp ??
              this.holidayPremiumWithinDailyThresholdRateBp,
      holidayPremiumOverDailyThresholdRateBp:
          holidayPremiumOverDailyThresholdRateBp ??
              this.holidayPremiumOverDailyThresholdRateBp,
      businessIncomeWithholdingRateBp:
          businessIncomeWithholdingRateBp ?? this.businessIncomeWithholdingRateBp,
      weekStartsOn: weekStartsOn ?? this.weekStartsOn,
      sundayIsHoliday: sundayIsHoliday ?? this.sundayIsHoliday,
    );
  }
}
