import 'deduction_mode.dart';

/// 근무처별 급여 계산 옵션. 모든 토글은 기본 false (단순 시급×시간만 계산).
class JobPayrollOptions {
  const JobPayrollOptions({
    required this.jobId,
    required this.weeklyHolidayAllowance,
    required this.nightPremium,
    required this.dailyOvertime,
    required this.weeklyOvertime,
    required this.holidayPremium,
    required this.preciseBreakInput,
    required this.deductionMode,
    required this.fourInsuranceRate,
    required this.updatedAt,
  });

  factory JobPayrollOptions.defaultsFor(int jobId, DateTime now) {
    return JobPayrollOptions(
      jobId: jobId,
      weeklyHolidayAllowance: false,
      nightPremium: false,
      dailyOvertime: false,
      weeklyOvertime: false,
      holidayPremium: false,
      preciseBreakInput: false,
      deductionMode: DeductionMode.none,
      fourInsuranceRate: 940, // 9.40% — 사용자가 fourInsurance 모드 선택 시에만 의미 있음
      updatedAt: now,
    );
  }

  final int jobId;
  final bool weeklyHolidayAllowance;
  final bool nightPremium;
  final bool dailyOvertime;
  final bool weeklyOvertime;
  final bool holidayPremium;
  final bool preciseBreakInput;
  final DeductionMode deductionMode;

  /// 4대보험 합산 요율 (만분율, 940 = 9.40%). 정수 산술 유지를 위해 int.
  final int fourInsuranceRate;

  final DateTime updatedAt;

  JobPayrollOptions copyWith({
    bool? weeklyHolidayAllowance,
    bool? nightPremium,
    bool? dailyOvertime,
    bool? weeklyOvertime,
    bool? holidayPremium,
    bool? preciseBreakInput,
    DeductionMode? deductionMode,
    int? fourInsuranceRate,
    DateTime? updatedAt,
  }) {
    return JobPayrollOptions(
      jobId: jobId,
      weeklyHolidayAllowance: weeklyHolidayAllowance ?? this.weeklyHolidayAllowance,
      nightPremium: nightPremium ?? this.nightPremium,
      dailyOvertime: dailyOvertime ?? this.dailyOvertime,
      weeklyOvertime: weeklyOvertime ?? this.weeklyOvertime,
      holidayPremium: holidayPremium ?? this.holidayPremium,
      preciseBreakInput: preciseBreakInput ?? this.preciseBreakInput,
      deductionMode: deductionMode ?? this.deductionMode,
      fourInsuranceRate: fourInsuranceRate ?? this.fourInsuranceRate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is JobPayrollOptions &&
      other.jobId == jobId &&
      other.weeklyHolidayAllowance == weeklyHolidayAllowance &&
      other.nightPremium == nightPremium &&
      other.dailyOvertime == dailyOvertime &&
      other.weeklyOvertime == weeklyOvertime &&
      other.holidayPremium == holidayPremium &&
      other.preciseBreakInput == preciseBreakInput &&
      other.deductionMode == deductionMode &&
      other.fourInsuranceRate == fourInsuranceRate &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
        jobId,
        weeklyHolidayAllowance,
        nightPremium,
        dailyOvertime,
        weeklyOvertime,
        holidayPremium,
        preciseBreakInput,
        deductionMode,
        fourInsuranceRate,
        updatedAt,
      );
}
