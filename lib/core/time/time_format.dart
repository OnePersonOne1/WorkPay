/// 시각 표시 포맷 헬퍼. 24시간 / 오전·오후 분기.
library;

/// HH:MM (24h) 또는 "오전 H:MM" / "오후 H:MM".
String formatHM(DateTime dt, {required bool use24Hour}) {
  final h = dt.hour;
  final mm = dt.minute.toString().padLeft(2, '0');
  if (use24Hour) {
    return '${h.toString().padLeft(2, '0')}:$mm';
  }
  if (h == 0) return '오전 12:$mm';
  if (h < 12) return '오전 $h:$mm';
  if (h == 12) return '오후 12:$mm';
  return '오후 ${h - 12}:$mm';
}

/// 캘린더 셀처럼 좁은 공간 — 공백 없는 컴팩트 버전.
/// 24h: "HH:MM" / AM-PM: "오전H:MM" or "오후H:MM"
String formatHMCompact(DateTime dt, {required bool use24Hour}) {
  final h = dt.hour;
  final mm = dt.minute.toString().padLeft(2, '0');
  if (use24Hour) {
    return '${h.toString().padLeft(2, '0')}:$mm';
  }
  if (h == 0) return '오전12:$mm';
  if (h < 12) return '오전$h:$mm';
  if (h == 12) return '오후12:$mm';
  return '오후${h - 12}:$mm';
}
