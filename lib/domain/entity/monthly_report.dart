import '../../core/money/money.dart';

/// 월별 집계 결과. Phase 3 급여 계산 엔진의 출력 타입.
/// 세부 항목별 breakdown은 Phase 3에서 추가한다.
class MonthlyReport {
  const MonthlyReport({
    required this.year,
    required this.month,
    required this.totalWorkMinutes,
    required this.basePay,
    required this.netPay,
  });

  final int year;
  final int month;
  final int totalWorkMinutes;
  final Money basePay;
  final Money netPay;

  @override
  bool operator ==(Object other) =>
      other is MonthlyReport &&
      other.year == year &&
      other.month == month &&
      other.totalWorkMinutes == totalWorkMinutes &&
      other.basePay == basePay &&
      other.netPay == netPay;

  @override
  int get hashCode => Object.hash(year, month, totalWorkMinutes, basePay, netPay);
}
