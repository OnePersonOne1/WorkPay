// SPDX-License-Identifier: GPL-3.0-only
import 'dart:convert';

/// ICS(VEVENT) 하나로 변환될 일정. Shift → 이 값으로 매핑한 뒤 [buildIcs]에 전달.
class CalendarEventData {
  const CalendarEventData({
    required this.uid,
    required this.start,
    required this.end,
    required this.summary,
    this.description,
  });

  /// RFC 5545 UID. 시프트 id 기반 결정적 생성 → 같은 시프트를 다시 내보내도 동일.
  final String uid;

  /// 로컬 벽시계 시각. floating time으로 기록되어 가져오는 캘린더의
  /// 시간대 기준으로 해석된다 (해외 이주 시에도 근무 시각 표기가 유지됨).
  final DateTime start;
  final DateTime end;

  final String summary;
  final String? description;
}

/// 시프트 id로 결정적 UID 생성.
String shiftUid(int shiftId) => 'shift-$shiftId@salary-app';

/// iCalendar(RFC 5545) 문서 생성. 구글/애플/네이버 캘린더 '가져오기' 호환.
///
/// [nowUtc]는 DTSTAMP에 기록될 생성 시각(UTC).
String buildIcs(List<CalendarEventData> events, {required DateTime nowUtc}) {
  final lines = <String>[
    'BEGIN:VCALENDAR',
    'VERSION:2.0',
    'PRODID:-//salary_app//shift export//EN',
    'CALSCALE:GREGORIAN',
    'METHOD:PUBLISH',
  ];
  final stamp = _formatUtc(nowUtc);
  for (final e in events) {
    lines
      ..add('BEGIN:VEVENT')
      ..add('UID:${_escapeText(e.uid)}')
      ..add('DTSTAMP:$stamp')
      ..add('DTSTART:${_formatLocal(e.start)}')
      ..add('DTEND:${_formatLocal(e.end)}')
      ..add('SUMMARY:${_escapeText(e.summary)}');
    final desc = e.description;
    if (desc != null && desc.isNotEmpty) {
      lines.add('DESCRIPTION:${_escapeText(desc)}');
    }
    lines.add('END:VEVENT');
  }
  lines.add('END:VCALENDAR');
  return '${lines.map(_foldLine).join('\r\n')}\r\n';
}

/// 로컬 floating time: yyyyMMddTHHmmss (TZID/Z 없음).
String _formatLocal(DateTime dt) {
  final d = dt.toLocal();
  return '${_p4(d.year)}${_p2(d.month)}${_p2(d.day)}'
      'T${_p2(d.hour)}${_p2(d.minute)}${_p2(d.second)}';
}

/// UTC: yyyyMMddTHHmmssZ.
String _formatUtc(DateTime dt) {
  final d = dt.toUtc();
  return '${_p4(d.year)}${_p2(d.month)}${_p2(d.day)}'
      'T${_p2(d.hour)}${_p2(d.minute)}${_p2(d.second)}Z';
}

String _p2(int v) => v.toString().padLeft(2, '0');
String _p4(int v) => v.toString().padLeft(4, '0');

/// RFC 5545 3.3.11 TEXT escaping: \ ; , 개행.
String _escapeText(String value) {
  return value
      .replaceAll('\\', '\\\\')
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n')
      .replaceAll('\n', '\\n')
      .replaceAll(';', '\\;')
      .replaceAll(',', '\\,');
}

/// RFC 5545 3.1 line folding: 75옥텟 초과 라인은 CRLF + 공백으로 접는다.
/// UTF-8 멀티바이트 문자를 중간에서 자르지 않도록 rune 단위로 누적.
String _foldLine(String line) {
  const maxOctets = 75;
  if (utf8.encode(line).length <= maxOctets) return line;

  final buf = StringBuffer();
  var octets = 0;
  var first = true;
  for (final rune in line.runes) {
    final ch = String.fromCharCode(rune);
    final chLen = utf8.encode(ch).length;
    // 이어지는 줄은 선행 공백 1옥텟을 차지한다.
    final limit = first ? maxOctets : maxOctets - 1;
    if (octets + chLen > limit) {
      buf.write('\r\n ');
      octets = 0;
      first = false;
    }
    buf.write(ch);
    octets += chLen;
  }
  return buf.toString();
}
