// SPDX-License-Identifier: GPL-3.0-only
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../domain/entity/plan.dart';
import '../settings/settings_providers.dart';
import 'schedule_providers.dart';

/// 현재 활성 plan id (AppSettings.activePlanId watch).
final activePlanIdProvider = Provider<int>((ref) {
  final async = ref.watch(appSettingsProvider);
  return async.maybeWhen(
    data: (s) => s.activePlanId,
    orElse: () => 0,
  );
});

/// 현재 활성 Plan entity. 0이면 Plan.main, 그 외엔 DB 조회.
final activePlanProvider = FutureProvider<Plan>((ref) async {
  final id = ref.watch(activePlanIdProvider);
  if (id == 0) return Plan.main;
  final repo = ref.watch(planRepositoryProvider);
  final plan = await repo.findById(id);
  return plan ?? Plan.main;
});

/// 선택된 월의 모의안 list (메인 제외, year/month 매칭).
final mockPlansForSelectedMonthProvider =
    StreamProvider<List<Plan>>((ref) {
  final month = ref.watch(selectedMonthProvider);
  final repo = ref.watch(planRepositoryProvider);
  return repo.watchForMonth(month.year, month.month);
});

/// 다음 가안 이름 자동 생성: "M월 가안 N" (N은 기존 중 가장 큰 + 1).
String generateMockPlanName(int month, List<Plan> existingForMonth) {
  var maxN = 0;
  final prefix = '$month월 가안 ';
  for (final p in existingForMonth) {
    if (p.name.startsWith(prefix)) {
      final rest = p.name.substring(prefix.length).trim();
      final n = int.tryParse(rest);
      if (n != null && n > maxN) maxN = n;
    }
  }
  return '$month월 가안 ${maxN + 1}';
}

/// 급여 명세서 페이지의 보기용 planId. 활성 plan과 독립적.
/// 기본값 = 0 (메인). 페이지 닫히면 자동 dispose 되어 다음 진입 시 메인으로 초기화.
class ReportPlanIdNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void set(int id) => state = id;
}

final reportPlanIdProvider =
    NotifierProvider.autoDispose<ReportPlanIdNotifier, int>(
  ReportPlanIdNotifier.new,
);
