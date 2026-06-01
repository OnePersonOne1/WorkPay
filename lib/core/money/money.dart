import 'package:intl/intl.dart';

/// 원(KRW) 정수 금액. 부동소수점 누적오차를 막기 위해 항상 [int]로 보관한다.
///
/// 산술은 정수 연산만 노출하고, 비율 곱셈 등 분수가 필요한 연산은
/// 분자·분모를 받아 정수로 내부 처리한 뒤 [반올림]한다.
class Money implements Comparable<Money> {
  const Money(this.won);

  factory Money.zero() => const Money(0);

  final int won;

  Money operator +(Money other) => Money(won + other.won);
  Money operator -(Money other) => Money(won - other.won);
  Money operator *(int factor) => Money(won * factor);

  /// 분수 곱셈을 반올림하여 정수 원으로 환원한다.
  /// 예: Money(10000).scale(3, 2) = Money(15000)  (1.5배)
  ///     Money(10000).scale(15, 100) = Money(1500) (15%)
  Money scale(int numerator, int denominator) {
    if (denominator == 0) {
      throw ArgumentError.value(denominator, 'denominator', 'must not be 0');
    }
    final product = won * numerator;
    return Money(_roundDiv(product, denominator));
  }

  bool get isZero => won == 0;
  bool get isNegative => won < 0;

  @override
  int compareTo(Money other) => won.compareTo(other.won);

  bool operator <(Money other) => won < other.won;
  bool operator <=(Money other) => won <= other.won;
  bool operator >(Money other) => won > other.won;
  bool operator >=(Money other) => won >= other.won;

  @override
  bool operator ==(Object other) => other is Money && other.won == won;

  @override
  int get hashCode => won.hashCode;

  @override
  String toString() => 'Money($won원)';

  String format({String locale = 'ko_KR'}) {
    final f = NumberFormat.decimalPattern(locale);
    return '${f.format(won)}원';
  }
}

/// 한국 반올림 정책: 0.5는 항상 absolute value 큰 쪽으로(half-away-from-zero).
/// 음수에서도 일관되게 동작.
int _roundDiv(int numerator, int denominator) {
  final q = numerator ~/ denominator;
  final r = numerator.remainder(denominator);
  if (r == 0) return q;
  final doubled = r.abs() * 2;
  if (doubled < denominator.abs()) return q;
  if (doubled > denominator.abs()) return q + (numerator.sign * denominator.sign);
  // 정확히 0.5인 경우 — half-away-from-zero
  return q + (numerator.sign * denominator.sign);
}
