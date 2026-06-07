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
    required this.allowShiftOverlap,
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
        allowShiftOverlap: false, // 기본: 시간 겹치는 시프트 입력 차단
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

  /// 시프트 시간 겹침 입력 허용 여부. 기본 false (입력 시 차단).
  /// 입력 검증에만 사용되며 계산엔 영향 없음. UI에서 watch.
  final bool allowShiftOverlap;

  Map<String, dynamic> toJson() => {
        'nightStartMinuteOfDay': nightStartMinuteOfDay,
        'nightEndMinuteOfDay': nightEndMinuteOfDay,
        'dailyOvertimeThresholdMinutes': dailyOvertimeThresholdMinutes,
        'weeklyOvertimeThresholdMinutes': weeklyOvertimeThresholdMinutes,
        'weeklyHolidayThresholdMinutes': weeklyHolidayThresholdMinutes,
        'nightPremiumRateBp': nightPremiumRateBp,
        'dailyOvertimePremiumRateBp': dailyOvertimePremiumRateBp,
        'weeklyOvertimePremiumRateBp': weeklyOvertimePremiumRateBp,
        'holidayPremiumWithinDailyThresholdRateBp':
            holidayPremiumWithinDailyThresholdRateBp,
        'holidayPremiumOverDailyThresholdRateBp':
            holidayPremiumOverDailyThresholdRateBp,
        'businessIncomeWithholdingRateBp': businessIncomeWithholdingRateBp,
        'weekStartsOn': weekStartsOn,
        'sundayIsHoliday': sundayIsHoliday,
        'allowShiftOverlap': allowShiftOverlap,
      };

  /// 누락된 필드는 koreanDefault 값을 그대로 사용 — 향후 새 필드 추가 시 호환.
  factory PayrollConstants.fromJson(Map<String, dynamic> json) {
    final d = PayrollConstants.koreanDefault();
    return PayrollConstants(
      nightStartMinuteOfDay:
          json['nightStartMinuteOfDay'] as int? ?? d.nightStartMinuteOfDay,
      nightEndMinuteOfDay:
          json['nightEndMinuteOfDay'] as int? ?? d.nightEndMinuteOfDay,
      dailyOvertimeThresholdMinutes:
          json['dailyOvertimeThresholdMinutes'] as int? ??
              d.dailyOvertimeThresholdMinutes,
      weeklyOvertimeThresholdMinutes:
          json['weeklyOvertimeThresholdMinutes'] as int? ??
              d.weeklyOvertimeThresholdMinutes,
      weeklyHolidayThresholdMinutes:
          json['weeklyHolidayThresholdMinutes'] as int? ??
              d.weeklyHolidayThresholdMinutes,
      nightPremiumRateBp:
          json['nightPremiumRateBp'] as int? ?? d.nightPremiumRateBp,
      dailyOvertimePremiumRateBp:
          json['dailyOvertimePremiumRateBp'] as int? ??
              d.dailyOvertimePremiumRateBp,
      weeklyOvertimePremiumRateBp:
          json['weeklyOvertimePremiumRateBp'] as int? ??
              d.weeklyOvertimePremiumRateBp,
      holidayPremiumWithinDailyThresholdRateBp:
          json['holidayPremiumWithinDailyThresholdRateBp'] as int? ??
              d.holidayPremiumWithinDailyThresholdRateBp,
      holidayPremiumOverDailyThresholdRateBp:
          json['holidayPremiumOverDailyThresholdRateBp'] as int? ??
              d.holidayPremiumOverDailyThresholdRateBp,
      businessIncomeWithholdingRateBp:
          json['businessIncomeWithholdingRateBp'] as int? ??
              d.businessIncomeWithholdingRateBp,
      weekStartsOn: json['weekStartsOn'] as int? ?? d.weekStartsOn,
      sundayIsHoliday: json['sundayIsHoliday'] as bool? ?? d.sundayIsHoliday,
      allowShiftOverlap:
          json['allowShiftOverlap'] as bool? ?? d.allowShiftOverlap,
    );
  }

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
    bool? allowShiftOverlap,
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
      allowShiftOverlap: allowShiftOverlap ?? this.allowShiftOverlap,
    );
  }
}
