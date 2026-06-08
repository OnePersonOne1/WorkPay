// SPDX-License-Identifier: GPL-3.0-only
import 'package:flutter_test/flutter_test.dart';
import 'package:salary_app/core/time/week_resolver.dart';

void main() {
  group('WeekResolver (월요일 시작)', () {
    final wr = WeekResolver();

    test('월요일은 자기 자신이 주 시작', () {
      // 2026-06-01 = 월요일
      expect(wr.weekStartOf(DateTime(2026, 6, 1)), DateTime(2026, 6, 1));
    });

    test('일요일은 같은 주의 월요일로 매핑', () {
      // 2026-06-07 = 일요일
      expect(wr.weekStartOf(DateTime(2026, 6, 7)), DateTime(2026, 6, 1));
    });

    test('시각이 포함되어도 자정으로 정규화', () {
      expect(
        wr.weekStartOf(DateTime(2026, 6, 7, 23, 59)),
        DateTime(2026, 6, 1),
      );
    });

    test('월 경계 — 5/31(일)은 5/25 시작 주에 속함', () {
      // 2026-05-31 = 일요일, 그 주의 월요일은 5-25
      expect(wr.weekStartOf(DateTime(2026, 5, 31)), DateTime(2026, 5, 25));
    });

    test('weekBelongsToMonth — 5월 시작 주는 5월에 귀속', () {
      final ws = wr.weekStartOf(DateTime(2026, 5, 31));
      expect(wr.weekBelongsToMonth(ws, 2026, 5), true);
      expect(wr.weekBelongsToMonth(ws, 2026, 6), false);
    });

    test('주 종료 = 시작 + 7일', () {
      expect(wr.weekEndOf(DateTime(2026, 6, 1)), DateTime(2026, 6, 8));
    });
  });

  group('WeekResolver (일요일 시작)', () {
    final wr = WeekResolver(weekStartsOn: DateTime.sunday);

    test('일요일은 자기 자신', () {
      expect(wr.weekStartOf(DateTime(2026, 6, 7)), DateTime(2026, 6, 7));
    });

    test('월요일은 전날(일요일)로 매핑', () {
      expect(wr.weekStartOf(DateTime(2026, 6, 1)), DateTime(2026, 5, 31));
    });
  });
}
