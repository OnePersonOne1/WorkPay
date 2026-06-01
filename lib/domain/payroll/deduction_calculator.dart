import '../entity/deduction_mode.dart';
import '../entity/job_payroll_options.dart';
import 'payroll_constants.dart';

class DeductionResult {
  const DeductionResult({
    required this.businessIncomeWithholdingWon,
    required this.fourInsuranceDeductionWon,
  });

  final int businessIncomeWithholdingWon;
  final int fourInsuranceDeductionWon;
}

/// grossWon = 기본급 + 모든 가산수당. 이 금액에 deductionMode에 따른 공제를 계산.
DeductionResult computeDeduction(
  int grossWon,
  JobPayrollOptions options,
  PayrollConstants constants,
) {
  switch (options.deductionMode) {
    case DeductionMode.none:
      return const DeductionResult(
        businessIncomeWithholdingWon: 0,
        fourInsuranceDeductionWon: 0,
      );
    case DeductionMode.businessIncome3_3:
      return DeductionResult(
        businessIncomeWithholdingWon: _bp(grossWon, constants.businessIncomeWithholdingRateBp),
        fourInsuranceDeductionWon: 0,
      );
    case DeductionMode.fourInsurance:
      return DeductionResult(
        businessIncomeWithholdingWon: 0,
        fourInsuranceDeductionWon: _bp(grossWon, options.fourInsuranceRate),
      );
  }
}

int _bp(int amount, int rateBp) => _roundDiv(amount * rateBp, 10000);

int _roundDiv(int numerator, int denominator) {
  final q = numerator ~/ denominator;
  final r = numerator.remainder(denominator);
  if (r == 0) return q;
  if (r.abs() * 2 < denominator.abs()) return q;
  return q + (numerator.sign * denominator.sign);
}
