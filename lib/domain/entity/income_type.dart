// SPDX-License-Identifier: GPL-3.0-only
/// 소득 유형. UI 분류 + 기본 토글 힌트에 사용 (강제 비활성화는 아님).
enum IncomeType {
  partTime('아르바이트'),
  workStudy('근로장학');

  const IncomeType(this.label);
  final String label;
}
