// SPDX-License-Identifier: GPL-3.0-only
/// 공제 방식. 비과세가 기본값.
enum DeductionMode {
  none('비과세'),
  businessIncome3_3('사업소득 3.3%'),
  fourInsurance('4대보험');

  const DeductionMode(this.label);
  final String label;
}
