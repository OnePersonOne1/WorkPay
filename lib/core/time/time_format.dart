// SPDX-License-Identifier: GPL-3.0-only
/// 시각 표시 포맷 헬퍼. 24시간 / AM·PM 분기.
///
/// AM/PM 라벨은 호출자가 locale에 맞춰 전달 (기본 한국어).
library;

/// HH:MM (24h) 또는 "{am} H:MM" / "{pm} H:MM".
String formatHM(
  DateTime dt, {
  required bool use24Hour,
  String am = '오전',
  String pm = '오후',
}) {
  final h = dt.hour;
  final mm = dt.minute.toString().padLeft(2, '0');
  if (use24Hour) {
    return '${h.toString().padLeft(2, '0')}:$mm';
  }
  if (h == 0) return '$am 12:$mm';
  if (h < 12) return '$am $h:$mm';
  if (h == 12) return '$pm 12:$mm';
  return '$pm ${h - 12}:$mm';
}

/// 좁은 공간용 — 공백 없는 컴팩트 버전.
String formatHMCompact(
  DateTime dt, {
  required bool use24Hour,
  String am = '오전',
  String pm = '오후',
}) {
  final h = dt.hour;
  final mm = dt.minute.toString().padLeft(2, '0');
  if (use24Hour) {
    return '${h.toString().padLeft(2, '0')}:$mm';
  }
  if (h == 0) return '$am 12:$mm';
  if (h < 12) return '$am $h:$mm';
  if (h == 12) return '$pm 12:$mm';
  return '$pm ${h - 12}:$mm';
}
