import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../domain/entity/job.dart';
import '../../domain/entity/shift.dart';
import '../../domain/payroll/holiday_calendar.dart';
import '../../domain/payroll/monthly_computation.dart';
import '../../domain/payroll/payroll_constants.dart';
import '../../domain/payroll/payroll_engine.dart';
import '../job/job_providers.dart';
import 'monthly_report_bundle.dart';
import 'schedule_providers.dart';

/// 앱 전역 PayrollConstants. 향후 '고고급 설정' UI에서 override 시 이곳을 갈아끼우면 된다.
final payrollConstantsProvider = Provider<PayrollConstants>((ref) {
  return PayrollConstants.koreanDefault();
});

/// 한국 공휴일 캘린더. 향후 패키지 교체 시 이 provider만 갈아끼움.
final holidayCalendarProvider = Provider<HolidayCalendar>((ref) {
  return FixedHolidayCalendar.korea2025to2027();
});

final payrollEngineProvider = Provider<PayrollEngine>((ref) {
  return PayrollEngine(
    constants: ref.watch(payrollConstantsProvider),
    holidayCalendar: ref.watch(holidayCalendarProvider),
  );
});

/// 선택된 월의 전체+근무처별 계산 묶음.
///
/// shifts + jobs stream을 모두 watch하므로 새 시프트 추가/편집/삭제, 근무처 옵션 변경 시
/// 자동으로 재계산된다.
final monthlyReportBundleProvider =
    FutureProvider<MonthlyReportBundle>((ref) async {
  final month = ref.watch(selectedMonthProvider);
  final engine = ref.watch(payrollEngineProvider);
  final jobRepo = ref.watch(jobRepositoryProvider);

  final allShifts = await ref.watch(shiftsInSelectedMonthProvider.future);
  final jobs = await ref.watch(activeJobsProvider.future);

  final byJob = <int, List<Shift>>{};
  for (final s in allShifts) {
    byJob.putIfAbsent(s.jobId, () => []).add(s);
  }

  var combined = MonthlyComputation.empty(month.year, month.month);
  final perJob = <({Job job, MonthlyComputation computation})>[];
  for (final job in jobs) {
    final jobShifts = byJob[job.id] ?? const <Shift>[];
    if (jobShifts.isEmpty) continue;
    final opts = await jobRepo.watchOptions(job.id).first;
    final comp = engine.computeWithBreakdown(
      year: month.year,
      month: month.month,
      shifts: jobShifts,
      options: opts,
    );
    perJob.add((job: job, computation: comp));
    combined = combined.merge(comp);
  }

  return MonthlyReportBundle(combined: combined, perJob: perJob);
});

/// 캘린더가 사용하는 기존 인터페이스 — bundle.combined만 노출.
/// FutureProvider로 유지해 핫리로드 시 ProviderContainer 타입 충돌 회피.
final monthlyComputationProvider = FutureProvider<MonthlyComputation>((ref) async {
  final bundle = await ref.watch(monthlyReportBundleProvider.future);
  return bundle.combined;
});
