import '../../domain/payroll/holiday_calendar.dart';
import '../../domain/payroll/payroll_constants.dart';
import 'work_segment.dart';

/// 시프트 [start, end]를 분 단위 (날짜, 야간/주간, 휴일/평일) segment로 분해한다.
///
/// **시각 입력은 로컬 DateTime**을 가정한다. 호출자가 UTC→로컬 변환을 책임진다.
/// 분 단위까지 자르며, 1분 단위 정확.
class TimeSegmenter {
  TimeSegmenter(this.constants, this.holidayCalendar);

  final PayrollConstants constants;
  final HolidayCalendar holidayCalendar;

  List<WorkSegment> segment(DateTime startLocal, DateTime endLocal) {
    if (!endLocal.isAfter(startLocal)) {
      throw ArgumentError('endLocal must be after startLocal');
    }

    // 분 단위로 자른 후 1분씩 훑으면 너무 비효율적이므로, 상태가 바뀌는 경계점만 찾는다.
    // 경계 후보: (1) 매 자정, (2) 야간 시작/종료 시각.
    final boundaries = _collectBoundaries(startLocal, endLocal);

    final segments = <WorkSegment>[];
    var cursor = startLocal;
    for (final next in boundaries) {
      if (!next.isAfter(cursor)) continue;
      final minutes = next.difference(cursor).inMinutes;
      if (minutes > 0) {
        segments.add(_buildSegment(cursor, minutes));
      }
      cursor = next;
    }
    // 마지막 구간
    if (cursor.isBefore(endLocal)) {
      final minutes = endLocal.difference(cursor).inMinutes;
      if (minutes > 0) {
        segments.add(_buildSegment(cursor, minutes));
      }
    }

    return _coalesce(segments);
  }

  WorkSegment _buildSegment(DateTime startLocal, int minutes) {
    final day = DateTime(startLocal.year, startLocal.month, startLocal.day);
    return WorkSegment(
      dayLocal: day,
      isNight: _isNightMinute(startLocal),
      isHoliday: _isHolidayDate(day),
      minutes: minutes,
    );
  }

  List<DateTime> _collectBoundaries(DateTime startLocal, DateTime endLocal) {
    final result = <DateTime>{};
    // 각 날의 자정 + 야간 시작/종료 시각을 후보로 추가.
    var day = DateTime(startLocal.year, startLocal.month, startLocal.day);
    final endDay = DateTime(endLocal.year, endLocal.month, endLocal.day);
    while (!day.isAfter(endDay)) {
      result.add(day); // 자정
      result.add(day.add(Duration(minutes: constants.nightStartMinuteOfDay)));
      result.add(day.add(Duration(minutes: constants.nightEndMinuteOfDay)));
      day = day.add(const Duration(days: 1));
    }
    result.add(day); // endDay 다음 자정
    // 범위 밖 제거 + 정렬
    final sorted = result
        .where((d) => d.isAfter(startLocal) && d.isBefore(endLocal))
        .toList()
      ..sort();
    return sorted;
  }

  bool _isNightMinute(DateTime localTime) {
    final mod = localTime.hour * 60 + localTime.minute;
    final start = constants.nightStartMinuteOfDay;
    final end = constants.nightEndMinuteOfDay;
    if (start < end) {
      // 같은 날 내 구간 (예: 22:00~23:00)
      return mod >= start && mod < end;
    } else {
      // 자정 넘김 (기본: 22:00~06:00 다음 날)
      return mod >= start || mod < end;
    }
  }

  bool _isHolidayDate(DateTime dayLocal) {
    if (constants.sundayIsHoliday && dayLocal.weekday == DateTime.sunday) {
      return true;
    }
    return holidayCalendar.isPublicHoliday(dayLocal);
  }

  /// 인접한 같은 (dayLocal, isNight, isHoliday) segment를 병합.
  List<WorkSegment> _coalesce(List<WorkSegment> segments) {
    if (segments.length <= 1) return segments;
    final out = <WorkSegment>[];
    var current = segments.first;
    for (final s in segments.skip(1)) {
      if (s.dayLocal == current.dayLocal &&
          s.isNight == current.isNight &&
          s.isHoliday == current.isHoliday) {
        current = current.copyWith(minutes: current.minutes + s.minutes);
      } else {
        out.add(current);
        current = s;
      }
    }
    out.add(current);
    return out;
  }
}
