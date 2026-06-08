// SPDX-License-Identifier: GPL-3.0-only
import '../entity/job_payroll_options.dart';
import 'payroll_constants.dart';

/// 한 주(WeekStart로 식별)의 누적. PayrollEngine 내부에서 사용.
class WeeklyTotal {
  WeeklyTotal(this.weekStart);

  final DateTime weekStart;

  /// 이 주의 모든 근무 분 (휴일 포함).
  int totalMinutes = 0;

  /// 이 주에서 "일 연장"으로 이미 잡힌 분. 주 연장과의 이중 카운트 방지에 사용.
  int dailyOvertimeMinutesUsed = 0;

  /// 이 주에 결근(missed scheduled work)이 있었는지. 현재 v1: 시프트 입력만 받으므로 항상 false.
  /// 추후 "예정 시프트 vs 실제 시프트" 개념을 도입하면 갱신.
  bool hadAbsence = false;

  int wageReference = 0; // 주휴수당 계산 기준 시급 (첫 segment의 wage)
}

class WeeklyComputeResult {
  const WeeklyComputeResult({
    required this.weeklyOvertimePremiumWon,
    required this.weeklyHolidayAllowanceWon,
  });

  final int weeklyOvertimePremiumWon;
  final int weeklyHolidayAllowanceWon;
}

WeeklyComputeResult computeWeekly(
  WeeklyTotal total,
  JobPayrollOptions options,
  PayrollConstants constants,
) {
  int weeklyOTWon = 0;
  if (options.weeklyOvertime) {
    final weeklyExcess = total.totalMinutes - constants.weeklyOvertimeThresholdMinutes;
    if (weeklyExcess > 0) {
      // 일 연장으로 이미 잡힌 부분은 제외
      final newOTMinutes = weeklyExcess - total.dailyOvertimeMinutesUsed;
      if (newOTMinutes > 0) {
        weeklyOTWon = _premiumWon(
          newOTMinutes,
          total.wageReference,
          constants.weeklyOvertimePremiumRateBp,
        );
      }
    }
  }

  int weeklyAllowanceWon = 0;
  if (options.weeklyHolidayAllowance &&
      !total.hadAbsence &&
      total.totalMinutes >= constants.weeklyHolidayThresholdMinutes) {
    // 주휴수당 금액 = min(주근로시간/5, 8h) × 통상시급
    final perDayMinutes = total.totalMinutes ~/ 5;
    final cappedMinutes =
        perDayMinutes > constants.dailyOvertimeThresholdMinutes
            ? constants.dailyOvertimeThresholdMinutes
            : perDayMinutes;
    weeklyAllowanceWon = _wagePerMinutes(cappedMinutes, total.wageReference);
  }

  return WeeklyComputeResult(
    weeklyOvertimePremiumWon: weeklyOTWon,
    weeklyHolidayAllowanceWon: weeklyAllowanceWon,
  );
}

// daily_calculator와 동일 로직이지만 internal 헬퍼만 노출 안 되게 복제.
int _wagePerMinutes(int minutes, int hourlyWage) =>
    _roundDiv(minutes * hourlyWage, 60);

int _premiumWon(int minutes, int hourlyWage, int rateBp) =>
    _roundDiv(minutes * hourlyWage * rateBp, 60 * 10000);

int _roundDiv(int numerator, int denominator) {
  final q = numerator ~/ denominator;
  final r = numerator.remainder(denominator);
  if (r == 0) return q;
  final doubled = r.abs() * 2;
  if (doubled.compareTo(denominator.abs()) < 0) return q;
  return q + (numerator.sign * denominator.sign);
}
