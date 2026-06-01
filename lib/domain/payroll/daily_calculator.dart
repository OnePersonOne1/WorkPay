import '../../core/time/work_segment.dart';
import '../entity/job_payroll_options.dart';
import 'payroll_constants.dart';

/// 한 날짜의 (이 잡에 대한) 누적 근무 통계. 분 단위 정수만 보관.
/// hourlyWage는 첫 segment 추가 시점의 wage로 고정 (드물게 같은 날 같은 잡의 시급이 바뀌면 부정확).
class DailyTotal {
  DailyTotal(this.dayLocal);

  final DateTime dayLocal;

  /// 첫 segment의 wage. 같은 날 같은 잡의 wage가 일정함을 가정.
  int hourlyWage = 0;

  int nonHolidayMinutes = 0;
  int nonHolidayNightMinutes = 0;

  int holidayMinutes = 0;
  int holidayNightMinutes = 0;

  bool _wageInitialized = false;

  void add(WorkSegment seg, int wage) {
    if (!_wageInitialized) {
      hourlyWage = wage;
      _wageInitialized = true;
    }
    if (seg.isHoliday) {
      holidayMinutes += seg.minutes;
      if (seg.isNight) holidayNightMinutes += seg.minutes;
    } else {
      nonHolidayMinutes += seg.minutes;
      if (seg.isNight) nonHolidayNightMinutes += seg.minutes;
    }
  }

  int get totalMinutes => nonHolidayMinutes + holidayMinutes;
  int get totalNightMinutes => nonHolidayNightMinutes + holidayNightMinutes;
}

/// 1분 단위 원 계산: minutes × hourlyWage / 60 (반올림).
int _wagePerMinutes(int minutes, int hourlyWage) {
  return _roundDiv(minutes * hourlyWage, 60);
}

/// 가산수당: minutes × hourlyWage × premiumRateBp / (60 × 10000) (반올림).
int _premiumWon(int minutes, int hourlyWage, int rateBp) {
  return _roundDiv(minutes * hourlyWage * rateBp, 60 * 10000);
}

int _roundDiv(int numerator, int denominator) {
  final q = numerator ~/ denominator;
  final r = numerator.remainder(denominator);
  if (r == 0) return q;
  final doubled = r.abs() * 2;
  final cmp = doubled.compareTo(denominator.abs());
  if (cmp < 0) return q;
  // half-away-from-zero
  return q + (numerator.sign * denominator.sign);
}

/// 일 단위 계산 결과를 누산할 항목별 분 단위 합. PayrollEngine이 사용.
class DailyComputeResult {
  const DailyComputeResult({
    required this.basePayWon,
    required this.nightPremiumWon,
    required this.dailyOvertimePremiumWon,
    required this.holidayPremiumWithinWon,
    required this.holidayPremiumOverWon,
    required this.dailyOvertimeMinutes,
  });

  final int basePayWon;
  final int nightPremiumWon;
  final int dailyOvertimePremiumWon;
  final int holidayPremiumWithinWon;
  final int holidayPremiumOverWon;

  /// 주 연장 이중 카운트 방지에 사용 (일 연장으로 잡힌 분).
  final int dailyOvertimeMinutes;
}

DailyComputeResult computeDaily(
  DailyTotal total,
  JobPayrollOptions options,
  PayrollConstants constants,
) {
  final wage = total.hourlyWage;
  final dailyThreshold = constants.dailyOvertimeThresholdMinutes;

  // 휴일 가산 토글 ON일 때만 holiday 분리. OFF면 holiday 분을 non-holiday로 합쳐 OT 대상이 됨.
  final effectiveHolidayMinutes = options.holidayPremium ? total.holidayMinutes : 0;
  final effectiveNonHolidayMinutes = options.holidayPremium
      ? total.nonHolidayMinutes
      : total.nonHolidayMinutes + total.holidayMinutes;

  // 기본급: 모든 근무 시간
  final basePayWon = _wagePerMinutes(total.totalMinutes, wage);

  // 야간 가산: 전체 야간 시간 (휴일 야간 포함, 토글과 무관하게 분리하지 않음)
  final nightPremiumWon = options.nightPremium
      ? _premiumWon(total.totalNightMinutes, wage, constants.nightPremiumRateBp)
      : 0;

  // 일 연장 가산: non-holiday 분이 dailyThreshold 초과 시
  int dailyOvertimePremiumWon = 0;
  int dailyOvertimeMinutes = 0;
  if (options.dailyOvertime) {
    final excess = effectiveNonHolidayMinutes - dailyThreshold;
    if (excess > 0) {
      dailyOvertimeMinutes = excess;
      dailyOvertimePremiumWon =
          _premiumWon(excess, wage, constants.dailyOvertimePremiumRateBp);
    }
  }

  // 휴일 가산: 토글 ON일 때
  int holidayWithinWon = 0;
  int holidayOverWon = 0;
  if (options.holidayPremium && effectiveHolidayMinutes > 0) {
    final within =
        effectiveHolidayMinutes <= dailyThreshold ? effectiveHolidayMinutes : dailyThreshold;
    final over =
        effectiveHolidayMinutes > dailyThreshold ? effectiveHolidayMinutes - dailyThreshold : 0;
    holidayWithinWon = _premiumWon(
      within,
      wage,
      constants.holidayPremiumWithinDailyThresholdRateBp,
    );
    holidayOverWon = _premiumWon(
      over,
      wage,
      constants.holidayPremiumOverDailyThresholdRateBp,
    );
  }

  return DailyComputeResult(
    basePayWon: basePayWon,
    nightPremiumWon: nightPremiumWon,
    dailyOvertimePremiumWon: dailyOvertimePremiumWon,
    holidayPremiumWithinWon: holidayWithinWon,
    holidayPremiumOverWon: holidayOverWon,
    dailyOvertimeMinutes: dailyOvertimeMinutes,
  );
}
