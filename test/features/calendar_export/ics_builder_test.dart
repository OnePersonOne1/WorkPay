// SPDX-License-Identifier: GPL-3.0-only
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:salary_app/features/calendar_export/ics_builder.dart';

void main() {
  final nowUtc = DateTime.utc(2026, 7, 7, 3, 0, 0);

  CalendarEventData event({
    String uid = 'shift-1@salary-app',
    DateTime? start,
    DateTime? end,
    String summary = '편의점',
    String? description,
  }) {
    return CalendarEventData(
      uid: uid,
      start: start ?? DateTime(2026, 7, 10, 9, 0),
      end: end ?? DateTime(2026, 7, 10, 18, 30),
      summary: summary,
      description: description,
    );
  }

  test('VCALENDAR 골격 + CRLF 줄바꿈', () {
    final ics = buildIcs([event()], nowUtc: nowUtc);
    expect(ics, startsWith('BEGIN:VCALENDAR\r\n'));
    expect(ics, endsWith('END:VCALENDAR\r\n'));
    expect(ics, contains('VERSION:2.0'));
    expect(ics, contains('METHOD:PUBLISH'));
    // 모든 줄바꿈이 CRLF — 고아 LF 없음.
    expect(ics.replaceAll('\r\n', '').contains('\n'), isFalse);
  });

  test('VEVENT 필드 — floating local DTSTART/DTEND, UTC DTSTAMP', () {
    final ics = buildIcs([event()], nowUtc: nowUtc);
    expect(ics, contains('UID:shift-1@salary-app'));
    expect(ics, contains('DTSTART:20260710T090000'));
    expect(ics, contains('DTEND:20260710T183000'));
    expect(ics, contains('DTSTAMP:20260707T030000Z'));
    expect(ics, contains('SUMMARY:편의점'));
    // Z가 DTSTART에 붙지 않음 (floating time).
    expect(ics, isNot(contains('DTSTART:20260710T090000Z')));
  });

  test('description 없으면 DESCRIPTION 라인 생략', () {
    final ics = buildIcs([event(description: '')], nowUtc: nowUtc);
    expect(ics, isNot(contains('DESCRIPTION')));
  });

  test('TEXT escaping — 콤마/세미콜론/역슬래시/개행', () {
    final ics = buildIcs(
      [event(summary: 'a,b;c\\d', description: '줄1\n줄2')],
      nowUtc: nowUtc,
    );
    expect(ics, contains('SUMMARY:a\\,b\\;c\\\\d'));
    expect(ics, contains('DESCRIPTION:줄1\\n줄2'));
  });

  test('75옥텟 초과 라인은 접히고, 접힌 줄은 공백으로 시작', () {
    final longMemo = '아주 긴 메모 ' * 20;
    final ics = buildIcs([event(description: longMemo)], nowUtc: nowUtc);
    for (final line in ics.split('\r\n')) {
      expect(
        utf8.encode(line).length,
        lessThanOrEqualTo(75),
        reason: 'folded line must be <= 75 octets: $line',
      );
    }
    expect(ics, contains('\r\n ')); // continuation line
    // unfold하면 원문 복원 (escaping된 형태 기준).
    final unfolded = ics.replaceAll('\r\n ', '');
    expect(unfolded, contains('DESCRIPTION:${longMemo.trim()}'));
  });

  test('멀티바이트 문자를 fold 경계에서 자르지 않음 (unfold 시 손상 없음)', () {
    final korean = '가나다라마바사아자차카타파하' * 10;
    final ics = buildIcs([event(description: korean)], nowUtc: nowUtc);
    final unfolded = ics.replaceAll('\r\n ', '');
    expect(unfolded, contains(korean));
  });

  test('shiftUid는 결정적', () {
    expect(shiftUid(42), 'shift-42@salary-app');
    expect(shiftUid(42), shiftUid(42));
  });

  test('이벤트 여러 개', () {
    final ics = buildIcs(
      [event(), event(uid: 'shift-2@salary-app', summary: '카페')],
      nowUtc: nowUtc,
    );
    expect('BEGIN:VEVENT'.allMatches(ics).length, 2);
    expect('END:VEVENT'.allMatches(ics).length, 2);
  });
}
