// SPDX-License-Identifier: GPL-3.0-only
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
import 'monthly_computation.dart';
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

  /// 기존 호환: MonthlyReport만 반환. 내부에서 computeWithBreakdown 호출.
  MonthlyReport compute({
    required int year,
    required int month,
    required Iterable<Shift> shifts,
    required JobPayrollOptions options,
  }) {
    return computeWithBreakdown(
      year: year,
      month: month,
      shifts: shifts,
      options: options,
    ).report;
  }

  /// 일/주 슬라이스까지 포함한 풍부한 결과 반환.
  MonthlyComputation computeWithBreakdown({
    required int year,
    required int month,
    required Iterable<Shift> shifts,
    required JobPayrollOptions options,
  }) {
    final builder = MonthlyReportBuilder(year: year, month: month);
    final weeklyTotals = <DateTime, WeeklyTotal>{};

    // 슬라이스 누산
    final dailyWorkMinutes = <DateTime, int>{};
    final dailyPayWon = <DateTime, int>{};
    final weeklyWorkMinutes = <DateTime, int>{};
    final weeklyPayWon = <DateTime, int>{};

    for (final shift in shifts) {
      final displayLocal = shift.startAt.toLocal();
      final displayDate =
          DateTime(displayLocal.year, displayLocal.month, displayLocal.day);
      final segments = _segmentAndBreak(shift);

      final shiftTotal =
          _buildShiftTotal(displayDate, segments, shift.hourlyWageSnapshot);
      final daily = computeDaily(shiftTotal, options, constants);

      final dayLevelPayWon = daily.basePayWon +
          daily.nightPremiumWon +
          daily.dailyOvertimePremiumWon +
          daily.holidayPremiumWithinWon +
          daily.holidayPremiumOverWon;

      // 일 슬라이스 누적 (target 월 한정)
      if (displayDate.year == year && displayDate.month == month) {
        dailyWorkMinutes[displayDate] =
            (dailyWorkMinutes[displayDate] ?? 0) + shiftTotal.totalMinutes;
        dailyPayWon[displayDate] =
            (dailyPayWon[displayDate] ?? 0) + dayLevelPayWon;

        builder.totalWorkMinutes += shiftTotal.totalMinutes;
        builder.basePayWon += daily.basePayWon;
        builder.nightPremiumWon += daily.nightPremiumWon;
        builder.dailyOvertimePremiumWon += daily.dailyOvertimePremiumWon;
        builder.holidayPremiumWithinThresholdWon += daily.holidayPremiumWithinWon;
        builder.holidayPremiumOverThresholdWon += daily.holidayPremiumOverWon;
      }

      // 주 단위 누적 — 모든 시프트의 주(target month 외 시프트도)에 누산
      final ws = _weekResolver.weekStartOf(displayDate);
      final week = weeklyTotals.putIfAbsent(ws, () => WeeklyTotal(ws));
      if (week.wageReference == 0) week.wageReference = shift.hourlyWageSnapshot;
      week.totalMinutes += shiftTotal.totalMinutes;
      week.dailyOvertimeMinutesUsed += daily.dailyOvertimeMinutes;

      // 주 슬라이스: 주 시작이 target 월에 속하는 경우만
      if (_weekResolver.weekBelongsToMonth(ws, year, month)) {
        weeklyWorkMinutes[ws] =
            (weeklyWorkMinutes[ws] ?? 0) + shiftTotal.totalMinutes;
        weeklyPayWon[ws] = (weeklyPayWon[ws] ?? 0) + dayLevelPayWon;
      }
    }

    // 주 단위 가산 계산 + 주 슬라이스에 추가
    for (final week in weeklyTotals.values) {
      if (!_weekResolver.weekBelongsToMonth(week.weekStart, year, month)) continue;
      final weekly = computeWeekly(week, options, constants);
      builder.weeklyOvertimePremiumWon += weekly.weeklyOvertimePremiumWon;
      builder.weeklyHolidayAllowanceWon += weekly.weeklyHolidayAllowanceWon;

      weeklyPayWon[week.weekStart] = (weeklyPayWon[week.weekStart] ?? 0) +
          weekly.weeklyOvertimePremiumWon +
          weekly.weeklyHolidayAllowanceWon;
    }

    // 공제
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

    return MonthlyComputation(
      report: builder.build(),
      dailyWorkMinutes: dailyWorkMinutes,
      dailyPayWon: dailyPayWon,
      weeklyWorkMinutes: weeklyWorkMinutes,
      weeklyPayWon: weeklyPayWon,
    );
  }

  List<WorkSegment> _segmentAndBreak(Shift shift) {
    final startLocal = shift.startAt.toLocal();
    final endLocal = shift.endAt.toLocal();
    final raw = _segmenter.segment(startLocal, endLocal);
    return distributeBreak(raw, breakMinutes: shift.breakMinutes);
  }

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
