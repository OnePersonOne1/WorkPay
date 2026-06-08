// SPDX-License-Identifier: GPL-3.0-only
/// 사업장 규모. 야간/연장/휴일 가산수당 적용 여부 UI 힌트에 사용.
/// 법적으로 5인 미만은 가산수당 미적용이지만, 사용자 토글이 우선.
enum BusinessSize {
  under5('5인 미만'),
  fiveOrMore('5인 이상');

  const BusinessSize(this.label);
  final String label;
}
