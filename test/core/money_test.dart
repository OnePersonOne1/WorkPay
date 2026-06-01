import 'package:flutter_test/flutter_test.dart';
import 'package:salary_app/core/money/money.dart';

void main() {
  group('Money 기본 산술', () {
    test('덧셈/뺄셈/정수 곱', () {
      expect(const Money(1000) + const Money(500), const Money(1500));
      expect(const Money(1000) - const Money(300), const Money(700));
      expect(const Money(1000) * 3, const Money(3000));
    });

    test('zero/isZero/isNegative', () {
      expect(Money.zero(), const Money(0));
      expect(Money.zero().isZero, true);
      expect(const Money(-100).isNegative, true);
      expect(const Money(100).isNegative, false);
    });

    test('비교 연산자', () {
      expect(const Money(100) < const Money(200), true);
      expect(const Money(200) > const Money(100), true);
      expect(const Money(100) <= const Money(100), true);
      expect(const Money(100) >= const Money(100), true);
      expect(const Money(100).compareTo(const Money(200)), lessThan(0));
    });

    test('equality와 hashCode', () {
      expect(const Money(1000) == const Money(1000), true);
      expect(const Money(1000) == const Money(999), false);
      expect(const Money(1000).hashCode, const Money(1000).hashCode);
    });
  });

  group('Money.scale (반올림)', () {
    test('정수 배수는 그대로', () {
      expect(const Money(10000).scale(3, 2), const Money(15000)); // 1.5배
      expect(const Money(1000).scale(15, 100), const Money(150)); // 15%
    });

    test('1원 미만은 반올림 (half-away-from-zero)', () {
      // 1000 * 1 / 3 = 333.333... → 333
      expect(const Money(1000).scale(1, 3), const Money(333));
      // 1000 * 2 / 3 = 666.666... → 667
      expect(const Money(1000).scale(2, 3), const Money(667));
      // 1 * 1 / 2 = 0.5 → half-away-from-zero → 1
      expect(const Money(1).scale(1, 2), const Money(1));
      // 3 * 1 / 2 = 1.5 → 2
      expect(const Money(3).scale(1, 2), const Money(2));
    });

    test('음수에서도 일관된 반올림', () {
      expect(const Money(-3).scale(1, 2), const Money(-2));
      expect(const Money(-1000).scale(1, 3), const Money(-333));
    });

    test('denominator 0이면 ArgumentError', () {
      expect(() => const Money(1000).scale(1, 0), throwsArgumentError);
    });
  });

  group('Money.format', () {
    test('ko_KR 통화 포매팅', () {
      expect(const Money(1234567).format(), '1,234,567원');
      expect(const Money(0).format(), '0원');
      expect(const Money(-500).format(), '-500원');
    });
  });
}
