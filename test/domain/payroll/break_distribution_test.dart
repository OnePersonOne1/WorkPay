// SPDX-License-Identifier: GPL-3.0-only
import 'package:flutter_test/flutter_test.dart';
import 'package:salary_app/core/time/work_segment.dart';
import 'package:salary_app/domain/payroll/break_distribution.dart';

WorkSegment seg(int minutes, {bool night = false, bool holiday = false}) =>
    WorkSegment(
      dayLocal: DateTime(2026, 6, 1),
      isNight: night,
      isHoliday: holiday,
      minutes: minutes,
    );

int sumMinutes(List<WorkSegment> segs) =>
    segs.fold(0, (s, x) => s + x.minutes);

void main() {
  group('distributeBreak', () {
    test('휴게 0이면 그대로', () {
      final input = [seg(240), seg(120)];
      expect(distributeBreak(input, breakMinutes: 0), input);
    });

    test('단일 segment에서 단순 차감', () {
      final result = distributeBreak([seg(540)], breakMinutes: 60);
      expect(sumMinutes(result), 480);
    });

    test('두 segment에 비례 분배', () {
      // 주간 4h + 야간 4h, 휴게 60분 → 30/30 분배
      final result = distributeBreak(
        [seg(240), seg(240, night: true)],
        breakMinutes: 60,
      );
      expect(sumMinutes(result), 8 * 60 - 60);
      expect(result[0].minutes, 240 - 30);
      expect(result[1].minutes, 240 - 30);
    });

    test('비례 분배에서 잔여 분이 마지막에 정산되어 합 보존', () {
      // 100분 + 200분, 휴게 7분
      // 첫 segment: round(100*7/300)=2, 둘째 segment에 남은 5 (=7-2)
      final result = distributeBreak(
        [seg(100), seg(200)],
        breakMinutes: 7,
      );
      expect(sumMinutes(result), 300 - 7);
    });

    test('휴게가 근무시간보다 크면 모두 0', () {
      final result = distributeBreak(
        [seg(60), seg(60)],
        breakMinutes: 999,
      );
      expect(sumMinutes(result), 0);
    });

    test('휴게가 정확히 근무시간과 같으면 모두 0', () {
      final result = distributeBreak(
        [seg(60), seg(60)],
        breakMinutes: 120,
      );
      expect(sumMinutes(result), 0);
    });

    test('3개 segment 비례 분배 후 합 보존', () {
      final result = distributeBreak(
        [seg(50), seg(73), seg(127)],
        breakMinutes: 30,
      );
      expect(sumMinutes(result), 250 - 30);
      expect(result.every((s) => s.minutes >= 0), true);
    });
  });
}
