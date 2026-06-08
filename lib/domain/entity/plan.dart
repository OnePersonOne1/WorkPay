// SPDX-License-Identifier: GPL-3.0-only
/// 시프트의 plan (안).
/// - 메인: id=0, year/month=0 (sentinel) — DB row 없음
/// - 모의안: id>0, 특정 (year, month) — DB row 존재
class Plan {
  const Plan({
    required this.id,
    required this.year,
    required this.month,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 메인 plan sentinel. DB에 row 없음.
  /// id=0 / year=0 / month=0 / name='메인'.
  static Plan get main {
    final epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    return Plan(
      id: 0,
      year: 0,
      month: 0,
      name: '메인',
      createdAt: epoch,
      updatedAt: epoch,
    );
  }

  final int id;
  final int year;
  final int month;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isMain => id == 0;

  @override
  bool operator ==(Object other) =>
      other is Plan &&
      other.id == id &&
      other.year == year &&
      other.month == month &&
      other.name == name;

  @override
  int get hashCode => Object.hash(id, year, month, name);
}
