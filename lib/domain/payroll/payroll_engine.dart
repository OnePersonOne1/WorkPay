import '../../core/time/time_segmenter.dart';
import '../../core/time/week_resolver.dart';
import '../../core/time/work_segment.dart';
import '../entity/job_payroll_options.dart';
import '../entity/monthly_report.dart';
import '../entity/shift.dart';
import 'break_distribution.dart';
import 'daily_calculator.dart';
import 'deduction_calculator.dart';
import 'holiday_calendar.dart';
import 'payroll_constants.dart';
import 'weekly_calculator.dart';

/// 한 근무처의 월별 급여 계산기.
///
/// "1일"의 정의: 시프트 자체 (자정 넘김 시프트는 startAt의 날짜로 귀속).
/// 같은 displayDate에 시프트가 여러 개면 각각 독립 "1일"로 계산 (간단·일반적 케이스).
class PayrollEngine {
  PayrollEngine({
    required this.constants,
    required this.holidayCalendar,
  }) : _segmenter = TimeSegmenter(constants, holidayCalendar),
       _weekResolver = WeekResolver(weekStartsOn: constants.weekStartsOn);

  final PayrollConstants constants;
  final HolidayCalendar holidayCalendar;
  final TimeSegmenter _segmenter;
  final WeekResolver _weekResolver;

  MonthlyReport compute({
    required int year,
    required int month,
    required Iterable<Shift> shifts,
    required JobPayrollOptions options,
  }) {
    final builder = MonthlyReportBuilder(year: year, month: month);
    final weeklyTotals = <DateTime, WeeklyTotal>{};

    for (final shift in shifts) {
      final displayLocal = shift.startAt.toLocal();
      final displayDate =
          DateTime(displayLocal.year, displayLocal.month, displayLocal.day);
      final segments = _segmentAndBreak(shift);

      // 1) 시프트 단위로 DailyTotal 구성 (segment의 dayLocal과 무관, "이 시프트의 1일")
      final shiftTotal = _buildShiftTotal(displayDate, segments, shift.hourlyWageSnapshot);

      // 2) 시프트의 일 단위 가산을 계산
      final daily = computeDaily(shiftTotal, options, constants);

      // 3) 시프트가 target 월에 귀속되면 builder에 누적
      if (displayDate.year == year && displayDate.month == month) {
        builder.totalWorkMinutes += shiftTotal.totalMinutes;
        builder.basePayWon += daily.basePayWon;
        builder.nightPremiumWon += daily.nightPremiumWon;
        builder.dailyOvertimePremiumWon += daily.dailyOvertimePremiumWon;
        builder.holidayPremiumWithinThresholdWon += daily.holidayPremiumWithinWon;
        builder.holidayPremiumOverThresholdWon += daily.holidayPremiumOverWon;
      }

      // 4) 주 단위 누적 (target 월 외 주도 일단 누적 — weekBelongsToMonth로 마지막에 필터)
      final ws = _weekResolver.weekStartOf(displayDate);
      final week = weeklyTotals.putIfAbsent(ws, () => WeeklyTotal(ws));
      if (week.wageReference == 0) week.wageReference = shift.hourlyWageSnapshot;
      week.totalMinutes += shiftTotal.totalMinutes;
      week.dailyOvertimeMinutesUsed += daily.dailyOvertimeMinutes;
    }

    // 5) 주 단위 계산 — 주 시작이 target 월에 속하는 주만 합산
    for (final week in weeklyTotals.values) {
      if (!_weekResolver.weekBelongsToMonth(week.weekStart, year, month)) continue;
      final weekly = computeWeekly(week, options, constants);
      builder.weeklyOvertimePremiumWon += weekly.weeklyOvertimePremiumWon;
      builder.weeklyHolidayAllowanceWon += weekly.weeklyHolidayAllowanceWon;
    }

    // 6) 공제
    final gross = builder.basePayWon +
        builder.nightPremiumWon +
        builder.dailyOvertimePremiumWon +
        builder.weeklyOvertimePremiumWon +
        builder.holidayPremiumWithinThresholdWon +
        builder.holidayPremiumOverThresholdWon +
        builder.weeklyHolidayAllowanceWon;
    final ded = computeDeduction(gross, options, constants);
    builder.businessIncomeWithholdingWon = ded.businessIncomeWithholdingWon;
    builder.fourInsuranceDeductionWon = ded.fourInsuranceDeductionWon;

    return builder.build();
  }

  List<WorkSegment> _segmentAndBreak(Shift shift) {
    final startLocal = shift.startAt.toLocal();
    final endLocal = shift.endAt.toLocal();
    final raw = _segmenter.segment(startLocal, endLocal);
    return distributeBreak(raw, breakMinutes: shift.breakMinutes);
  }

  /// 시프트의 모든 segment를 단일 DailyTotal에 합산 (자정 넘김도 같은 "1일"로 본다).
  /// 휴일 여부는 startAt의 날짜 기준으로 판단해야 자연스럽지만, 시프트가 휴일과 평일에 걸치는 경우
  /// 각 segment의 isHoliday 그대로 따른다 (segment 분리 시점에서 이미 처리됨).
  DailyTotal _buildShiftTotal(
    DateTime displayDate,
    List<WorkSegment> segments,
    int wage,
  ) {
    final total = DailyTotal(displayDate);
    for (final seg in segments) {
      if (seg.minutes > 0) total.add(seg, wage);
    }
    return total;
  }
}
