import 'package:flutter_test/flutter_test.dart';
import 'package:salary_app/core/money/money.dart';
import 'package:salary_app/domain/entity/deduction_mode.dart';
import 'package:salary_app/domain/entity/job_payroll_options.dart';
import 'package:salary_app/domain/entity/shift.dart';
import 'package:salary_app/domain/payroll/holiday_calendar.dart';
import 'package:salary_app/domain/payroll/payroll_constants.dart';
import 'package:salary_app/domain/payroll/payroll_engine.dart';

/// 테스트 편의: 로컬 시각으로 Shift 생성 (UTC 변환은 Shift 생성 시 처리됨).
Shift mkShift({
  required int id,
  required int year,
  required int month,
  required int day,
  required int startHour,
  required int endHour,
  int startMinute = 0,
  int endMinute = 0,
  int breakMinutes = 0,
  required int wage,
  int extraDays = 0,
}) {
  final start = DateTime(year, month, day, startHour, startMinute);
  final end = DateTime(year, month, day + extraDays, endHour, endMinute);
  final now = DateTime.utc(2026, 1, 1);
  return Shift(
    id: id,
    jobId: 1,
    startAt: start.toUtc(),
    endAt: end.toUtc(),
    breakMinutes: breakMinutes,
    breakStartAt: null,
    hourlyWageSnapshot: wage,
    memo: null,
    createdAt: now,
    updatedAt: now,
  );
}

JobPayrollOptions allOff({int jobId = 1}) => JobPayrollOptions(
      jobId: jobId,
      weeklyHolidayAllowance: false,
      nightPremium: false,
      dailyOvertime: false,
      weeklyOvertime: false,
      holidayPremium: false,
      preciseBreakInput: false,
      deductionMode: DeductionMode.none,
      fourInsuranceRate: 940,
      updatedAt: DateTime.utc(2026, 1, 1),
    );

void main() {
  final calendar = FixedHolidayCalendar.korea2025to2027();
  final constants = PayrollConstants.koreanDefault();
  final engine = PayrollEngine(constants: constants, holidayCalendar: calendar);

  group('PayrollEngine — 모든 옵션 OFF', () {
    test('단순 시급×시간만 계산, 가산·공제 모두 0', () {
      // 2026-06-01 (월) 09:00~18:00 = 9h, 휴게 1h → 8h
      final shifts = [
        mkShift(
          id: 1, year: 2026, month: 6, day: 1,
          startHour: 9, endHour: 18, breakMinutes: 60, wage: 10000,
        ),
      ];
      final report = engine.compute(
        year: 2026, month: 6, shifts: shifts, options: allOff(),
      );
      // 8h × 10000 = 80000
      expect(report.basePay, const Money(80000));
      expect(report.totalPremiums, Money.zero());
      expect(report.totalDeduction, Money.zero());
      expect(report.netPay, const Money(80000));
      expect(report.totalWorkMinutes, 480);
    });
  });

  group('PayrollEngine — 일 연장만 ON', () {
    test('일 8h 초과분에 +50% 가산', () {
      // 월 09:00~22:00 = 13h, 휴게 1h → 12h. OT = 4h.
      final shifts = [
        mkShift(
          id: 1, year: 2026, month: 6, day: 1,
          startHour: 9, endHour: 22, breakMinutes: 60, wage: 10000,
        ),
      ];
      final opts = allOff().copyWith(dailyOvertime: true);
      final report = engine.compute(
        year: 2026, month: 6, shifts: shifts, options: opts,
      );
      // base = 12h × 10000 = 120000
      // OT premium = 4h × 10000 × 0.5 = 20000
      expect(report.basePay, const Money(120000));
      expect(report.dailyOvertimePremium, const Money(20000));
      expect(report.grossPay, const Money(140000));
    });
  });

  group('PayrollEngine — 야간 + 일연장 stack', () {
    test('월 18:00~02:00(다음날) = 8h, 야간 4h, OT 0h', () {
      // 8h 정확, OT 없음. 야간(22~02) = 4h.
      final shifts = [
        mkShift(
          id: 1, year: 2026, month: 6, day: 1,
          startHour: 18, endHour: 2, breakMinutes: 0, wage: 10000,
          extraDays: 1,
        ),
      ];
      final opts = allOff().copyWith(
        nightPremium: true,
        dailyOvertime: true,
      );
      final report = engine.compute(
        year: 2026, month: 6, shifts: shifts, options: opts,
      );
      // base = 8h × 10000 = 80000
      // night = 4h × 10000 × 0.5 = 20000
      // OT = 0 (정확히 8h)
      expect(report.basePay, const Money(80000));
      expect(report.nightPremium, const Money(20000));
      expect(report.dailyOvertimePremium, Money.zero());
    });

    test('월 18:00~04:00(다음날) = 10h, 야간 6h, OT 2h', () {
      // 10h. 야간(22~04) = 6h. OT = 2h.
      final shifts = [
        mkShift(
          id: 1, year: 2026, month: 6, day: 1,
          startHour: 18, endHour: 4, breakMinutes: 0, wage: 10000,
          extraDays: 1,
        ),
      ];
      final opts = allOff().copyWith(
        nightPremium: true,
        dailyOvertime: true,
      );
      final report = engine.compute(
        year: 2026, month: 6, shifts: shifts, options: opts,
      );
      // base = 10h × 10000 = 100000
      // night = 6h × 10000 × 0.5 = 30000
      // OT = 2h × 10000 × 0.5 = 10000 (시작일 6/1 기준)
      expect(report.basePay, const Money(100000));
      expect(report.nightPremium, const Money(30000));
      expect(report.dailyOvertimePremium, const Money(10000));
    });
  });

  group('PayrollEngine — 휴일근로', () {
    test('일요일 9h 근무, holidayPremium ON: ≤8h +50%, >8h +100%', () {
      // 2026-06-07 = 일요일
      final shifts = [
        mkShift(
          id: 1, year: 2026, month: 6, day: 7,
          startHour: 9, endHour: 18, breakMinutes: 0, wage: 10000,
        ),
      ];
      final opts = allOff().copyWith(holidayPremium: true);
      final report = engine.compute(
        year: 2026, month: 6, shifts: shifts, options: opts,
      );
      // base = 9h × 10000 = 90000
      // holiday within = 8h × 10000 × 0.5 = 40000
      // holiday over = 1h × 10000 × 1.0 = 10000
      expect(report.basePay, const Money(90000));
      expect(report.holidayPremiumWithinThreshold, const Money(40000));
      expect(report.holidayPremiumOverThreshold, const Money(10000));
      expect(report.dailyOvertimePremium, Money.zero()); // OT는 휴일에 미적용
    });

    test('공휴일 (현충일 2026-06-06 토) 4h 근무, +50%', () {
      final shifts = [
        mkShift(
          id: 1, year: 2026, month: 6, day: 6,
          startHour: 10, endHour: 14, breakMinutes: 0, wage: 10000,
        ),
      ];
      final opts = allOff().copyWith(holidayPremium: true);
      final report = engine.compute(
        year: 2026, month: 6, shifts: shifts, options: opts,
      );
      expect(report.basePay, const Money(40000));
      expect(report.holidayPremiumWithinThreshold, const Money(20000));
    });
  });

  group('PayrollEngine — 주 연장', () {
    test('주 5일 8h 정확 + 1일 추가 4h → 주 44h, 주OT 4h', () {
      // 2026-06-01(월)~6-05(금) 각 8h, 6-06(토) 4h
      // 일 OT는 없음. 주 44h, 초과 4h가 주 OT.
      final shifts = [
        for (var d = 1; d <= 5; d++)
          mkShift(
            id: d, year: 2026, month: 6, day: d,
            startHour: 9, endHour: 17, breakMinutes: 0, wage: 10000,
          ),
        mkShift(
          id: 6, year: 2026, month: 6, day: 6,
          startHour: 9, endHour: 13, breakMinutes: 0, wage: 10000,
        ),
      ];
      // 6/6은 공휴일(현충일)이라 holidayPremium 없이 평일 취급해야 비교 단순.
      // 다만 6/6 토는 sundayIsHoliday=false 이므로 휴일 아님.
      // 단, FixedHolidayCalendar.korea2025to2027()에 6/6 들어있음 → holiday 토글 OFF면 영향 X.
      final opts = allOff().copyWith(weeklyOvertime: true);
      final report = engine.compute(
        year: 2026, month: 6, shifts: shifts, options: opts,
      );
      // base = 44h × 10000 = 440000
      // weekly OT = 4h × 10000 × 0.5 = 20000
      expect(report.basePay, const Money(440000));
      expect(report.weeklyOvertimePremium, const Money(20000));
    });

    test('일 OT + 주 OT 같이 ON이면 이중 카운트 방지', () {
      // 주 5일, 매일 9h (1h OT). 일 OT 5h, 주 OT = 주 45h - 40h - 일OT 5h = 0.
      final shifts = [
        for (var d = 1; d <= 5; d++)
          mkShift(
            id: d, year: 2026, month: 6, day: d,
            startHour: 9, endHour: 18, breakMinutes: 0, wage: 10000,
          ),
      ];
      final opts = allOff().copyWith(dailyOvertime: true, weeklyOvertime: true);
      final report = engine.compute(
        year: 2026, month: 6, shifts: shifts, options: opts,
      );
      // 일 OT = 5h × 10000 × 0.5 = 25000
      // 주 OT = 0 (45-40=5, 5-5=0)
      expect(report.dailyOvertimePremium, const Money(25000));
      expect(report.weeklyOvertimePremium, Money.zero());
    });
  });

  group('PayrollEngine — 주휴수당', () {
    test('주 15h+ 충족 시 1일분 통상시급 (8h cap)', () {
      // 주 20h (월~금 매일 4h)
      final shifts = [
        for (var d = 1; d <= 5; d++)
          mkShift(
            id: d, year: 2026, month: 6, day: d,
            startHour: 9, endHour: 13, breakMinutes: 0, wage: 10000,
          ),
      ];
      final opts = allOff().copyWith(weeklyHolidayAllowance: true);
      final report = engine.compute(
        year: 2026, month: 6, shifts: shifts, options: opts,
      );
      // 주근로 20h / 5 = 4h × 10000 = 40000
      expect(report.weeklyHolidayAllowance, const Money(40000));
    });

    test('주 40h+이면 8h cap 적용', () {
      // 주 5일 9h씩 = 45h. 45/5=9h, cap 8h.
      final shifts = [
        for (var d = 1; d <= 5; d++)
          mkShift(
            id: d, year: 2026, month: 6, day: d,
            startHour: 9, endHour: 18, breakMinutes: 0, wage: 10000,
          ),
      ];
      final opts = allOff().copyWith(weeklyHolidayAllowance: true);
      final report = engine.compute(
        year: 2026, month: 6, shifts: shifts, options: opts,
      );
      // 8h × 10000 = 80000
      expect(report.weeklyHolidayAllowance, const Money(80000));
    });

    test('주 15h 미만이면 미지급', () {
      // 주 2일 5h = 10h
      final shifts = [
        mkShift(id: 1, year: 2026, month: 6, day: 1, startHour: 9, endHour: 14, breakMinutes: 0, wage: 10000),
        mkShift(id: 2, year: 2026, month: 6, day: 2, startHour: 9, endHour: 14, breakMinutes: 0, wage: 10000),
      ];
      final opts = allOff().copyWith(weeklyHolidayAllowance: true);
      final report = engine.compute(
        year: 2026, month: 6, shifts: shifts, options: opts,
      );
      expect(report.weeklyHolidayAllowance, Money.zero());
    });
  });

  group('PayrollEngine — 공제', () {
    test('3.3% 사업소득 원천징수', () {
      final shifts = [
        mkShift(id: 1, year: 2026, month: 6, day: 1, startHour: 9, endHour: 18, breakMinutes: 60, wage: 10000),
      ];
      final opts = allOff().copyWith(deductionMode: DeductionMode.businessIncome3_3);
      final report = engine.compute(
        year: 2026, month: 6, shifts: shifts, options: opts,
      );
      // gross = 80000, 3.3% = 2640
      expect(report.basePay, const Money(80000));
      expect(report.businessIncomeWithholding, const Money(2640));
      expect(report.netPay, const Money(80000 - 2640));
    });

    test('4대보험 9.40% 기본 요율', () {
      final shifts = [
        mkShift(id: 1, year: 2026, month: 6, day: 1, startHour: 9, endHour: 18, breakMinutes: 60, wage: 10000),
      ];
      final opts = allOff().copyWith(deductionMode: DeductionMode.fourInsurance);
      final report = engine.compute(
        year: 2026, month: 6, shifts: shifts, options: opts,
      );
      // gross = 80000, 9.40% = 7520
      expect(report.fourInsuranceDeduction, const Money(7520));
      expect(report.netPay, const Money(80000 - 7520));
    });
  });

  group('PayrollEngine — 월 경계 및 주 귀속', () {
    test('주 시작이 5월인 주의 주휴수당은 5월에 귀속', () {
      // 2026-05-25(월)~5-29(금) 각 8h. 주 시작=5-25, 5월 귀속.
      final shifts = [
        for (var d = 25; d <= 29; d++)
          mkShift(
            id: d, year: 2026, month: 5, day: d,
            startHour: 9, endHour: 17, breakMinutes: 0, wage: 10000,
          ),
      ];
      final opts = allOff().copyWith(weeklyHolidayAllowance: true);
      final mayReport = engine.compute(
        year: 2026, month: 5, shifts: shifts, options: opts,
      );
      final junReport = engine.compute(
        year: 2026, month: 6, shifts: shifts, options: opts,
      );
      expect(mayReport.weeklyHolidayAllowance.won > 0, true);
      expect(junReport.weeklyHolidayAllowance, Money.zero());
    });
  });

  group('PayrollEngine — 항목 합 == net', () {
    test('grossPay - totalDeduction == netPay 불변식', () {
      final shifts = [
        for (var d = 1; d <= 5; d++)
          mkShift(
            id: d, year: 2026, month: 6, day: d,
            startHour: 9, endHour: 18, breakMinutes: 60, wage: 11000,
          ),
      ];
      final opts = allOff().copyWith(
        nightPremium: true,
        dailyOvertime: true,
        weeklyOvertime: true,
        weeklyHolidayAllowance: true,
        deductionMode: DeductionMode.fourInsurance,
      );
      final r = engine.compute(year: 2026, month: 6, shifts: shifts, options: opts);
      expect(r.grossPay - r.totalDeduction, r.netPay);
    });
  });
}
