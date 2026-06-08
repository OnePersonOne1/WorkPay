// SPDX-License-Identifier: GPL-3.0-only
import '../../core/time/work_segment.dart';

/// 휴게시간(분)을 각 segment에 길이 비례로 차감한다.
/// 합이 정확히 [breakMinutes]만큼 줄어들도록 잔여를 마지막 segment에 정산.
///
/// 차감 결과가 음수가 되면 0으로 클램프하고, 그만큼 다음 segment에서 더 차감한다.
List<WorkSegment> distributeBreak(
  List<WorkSegment> segments, {
  required int breakMinutes,
}) {
  if (breakMinutes <= 0) return segments;
  if (segments.isEmpty) return segments;

  final totalMinutes = segments.fold<int>(0, (sum, s) => sum + s.minutes);
  if (breakMinutes >= totalMinutes) {
    // 휴게가 근무시간 이상이면 전부 0
    return segments.map((s) => s.copyWith(minutes: 0)).toList();
  }

  final result = <WorkSegment>[];
  var remainingBreak = breakMinutes;
  var allocatedBreak = 0;

  for (var i = 0; i < segments.length; i++) {
    final s = segments[i];
    int subtract;
    if (i == segments.length - 1) {
      // 마지막 segment에는 남은 휴게 전부 부여 (합 보존)
      subtract = remainingBreak;
    } else {
      // 비례 분배 후 반올림
      subtract = ((s.minutes * breakMinutes) / totalMinutes).round();
      // 남은 양보다 많이 잡으면 cap
      if (subtract > remainingBreak) subtract = remainingBreak;
    }
    var newMinutes = s.minutes - subtract;
    if (newMinutes < 0) {
      // 이 segment에서 다 못 빼면 다음 segment로 carry
      remainingBreak -= s.minutes;
      newMinutes = 0;
      allocatedBreak += s.minutes;
    } else {
      remainingBreak -= subtract;
      allocatedBreak += subtract;
    }
    result.add(s.copyWith(minutes: newMinutes));
  }

  // 검증: 누락된 휴게 분이 있으면 (보통 carry로 인해) 첫 segment부터 추가 차감
  var deficit = breakMinutes - allocatedBreak;
  if (deficit > 0) {
    for (var i = 0; i < result.length && deficit > 0; i++) {
      final s = result[i];
      if (s.minutes <= 0) continue;
      final take = s.minutes < deficit ? s.minutes : deficit;
      result[i] = s.copyWith(minutes: s.minutes - take);
      deficit -= take;
    }
  }

  return result;
}
