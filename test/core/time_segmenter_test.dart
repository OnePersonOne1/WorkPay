import 'package:flutter_test/flutter_test.dart';
import 'package:salary_app/core/time/time_segmenter.dart';
import 'package:salary_app/domain/payroll/holiday_calendar.dart';
import 'package:salary_app/domain/payroll/payroll_constants.dart';

void main() {
  final calendar = FixedHolidayCalendar([DateTime(2026, 6, 6)]);
  final constants = PayrollConstants.koreanDefault();
  final segmenter = TimeSegmenter(constants, calendar);

  group('TimeSegmenter', () {
    test('단순 주간 근무 (월요일 09:00~18:00)', () {
      // 2026-06-01 = 월요일, 평일
      final segs = segmenter.segment(
        DateTime(2026, 6, 1, 9),
        DateTime(2026, 6, 1, 18),
      );
      expect(segs, hasLength(1));
      expect(segs.first.dayLocal, DateTime(2026, 6, 1));
      expect(segs.first.isNight, false);
      expect(segs.first.isHoliday, false);
      expect(segs.first.minutes, 9 * 60);
    });

    test('야간 진입 (월 20:00~24:00 → 주간 2h + 야간 2h)', () {
      final segs = segmenter.segment(
        DateTime(2026, 6, 1, 20),
        DateTime(2026, 6, 2),
      );
      expect(segs, hasLength(2));
      expect(segs[0].isNight, false);
      expect(segs[0].minutes, 2 * 60); // 20:00~22:00
      expect(segs[1].isNight, true);
      expect(segs[1].minutes, 2 * 60); // 22:00~24:00
    });

    test('자정 넘김 야간 (월 22:00 ~ 화 02:00)', () {
      final segs = segmenter.segment(
        DateTime(2026, 6, 1, 22),
        DateTime(2026, 6, 2, 2),
      );
      expect(segs, hasLength(2));
      expect(segs[0].dayLocal, DateTime(2026, 6, 1));
      expect(segs[0].isNight, true);
      expect(segs[0].minutes, 120);
      expect(segs[1].dayLocal, DateTime(2026, 6, 2));
      expect(segs[1].isNight, true);
      expect(segs[1].minutes, 120);
    });

    test('일요일은 휴일로 판정 (기본)', () {
      // 2026-06-07 = 일요일
      final segs = segmenter.segment(
        DateTime(2026, 6, 7, 10),
        DateTime(2026, 6, 7, 14),
      );
      expect(segs, hasLength(1));
      expect(segs.first.isHoliday, true);
      expect(segs.first.isNight, false);
    });

    test('공휴일 판정 (현충일 2026-06-06 토)', () {
      final segs = segmenter.segment(
        DateTime(2026, 6, 6, 10),
        DateTime(2026, 6, 6, 14),
      );
      expect(segs.first.isHoliday, true);
    });

    test('일요일 처리 끄면 평일 취급', () {
      final off = PayrollConstants.koreanDefault().copyWith(sundayIsHoliday: false);
      final segmenter2 = TimeSegmenter(off, calendar);
      final segs = segmenter2.segment(
        DateTime(2026, 6, 7, 10),
        DateTime(2026, 6, 7, 14),
      );
      expect(segs.first.isHoliday, false);
    });

    test('주간/야간/주간 (06:00~08:00) — 야간 종료 경계 검증', () {
      final segs = segmenter.segment(
        DateTime(2026, 6, 1, 4),
        DateTime(2026, 6, 1, 8),
      );
      expect(segs, hasLength(2));
      expect(segs[0].isNight, true);
      expect(segs[0].minutes, 2 * 60); // 04:00~06:00
      expect(segs[1].isNight, false);
      expect(segs[1].minutes, 2 * 60); // 06:00~08:00
    });

    test('end <= start면 ArgumentError', () {
      expect(
        () => segmenter.segment(
          DateTime(2026, 6, 1, 10),
          DateTime(2026, 6, 1, 10),
        ),
        throwsArgumentError,
      );
    });

    test('총 분 합은 입력 길이와 같다 (경계 손실 없음)', () {
      // 평일→일요일 자정 넘어가는 케이스
      final start = DateTime(2026, 6, 6, 18); // 토(공휴일=현충일)
      final end = DateTime(2026, 6, 7, 10); // 일
      final segs = segmenter.segment(start, end);
      final total = segs.fold<int>(0, (sum, s) => sum + s.minutes);
      expect(total, end.difference(start).inMinutes);
    });
  });
}
