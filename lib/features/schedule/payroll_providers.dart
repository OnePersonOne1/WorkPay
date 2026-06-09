// SPDX-License-Identifier: GPL-3.0-only
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../domain/entity/deduction_mode.dart';
import '../../domain/entity/job.dart';
import '../../domain/entity/job_payroll_options.dart';
import '../../domain/entity/shift.dart';
import '../../domain/payroll/holiday_calendar.dart';
import '../../domain/payroll/monthly_computation.dart';
import '../../domain/payroll/payroll_constants.dart';
import '../../domain/payroll/payroll_engine.dart';
import '../job/job_providers.dart';
import '../settings/settings_providers.dart';
import 'monthly_report_bundle.dart';
import 'plan_providers.dart';
import 'schedule_providers.dart';

/// 한국 노동법 OFF 시 모든 가산/공제 옵션을 강제 비활성화.
/// 사용자의 Job 옵션 row는 보존됨 — 토글을 다시 켜면 그대로 복원.
JobPayrollOptions _gateByLaborLaw(JobPayrollOptions opts, bool laborLawOn) {
  if (laborLawOn) return opts;
  return JobPayrollOptions(
    jobId: opts.jobId,
    weeklyHolidayAllowance: false,
    nightPremium: false,
    dailyOvertime: false,
    weeklyOvertime: false,
    holidayPremium: false,
    preciseBreakInput: opts.preciseBreakInput, // 휴게 입력 UX는 노동법과 무관
    deductionMode: DeductionMode.none,
    fourInsuranceRate: opts.fourInsuranceRate,
    updatedAt: opts.updatedAt,
  );
}

/// 앱 전역 PayrollConstants. AppSettings.payrollConstantsJson이 있으면 그걸 사용,
/// 없거나 파싱 실패면 koreanDefault().
final payrollConstantsProvider = Provider<PayrollConstants>((ref) {
  final async = ref.watch(appSettingsProvider);
  return async.maybeWhen(
    data: (s) {
      final raw = s.payrollConstantsJson;
      if (raw == null || raw.isEmpty) return PayrollConstants.koreanDefault();
      try {
        return PayrollConstants.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
      } catch (_) {
        return PayrollConstants.koreanDefault();
      }
    },
    orElse: () => PayrollConstants.koreanDefault(),
  );
});

/// 공휴일 캘린더. AppSettings.holidayCountry로 결정.
/// 'KR'=한국(기본), 'none'=공휴일 없음. 향후 다른 국가 추가 가능.
final holidayCalendarProvider = Provider<HolidayCalendar>((ref) {
  final async = ref.watch(appSettingsProvider);
  final country = async.maybeWhen(
    data: (s) => s.holidayCountry,
    orElse: () => 'KR',
  );
  return switch (country) {
    'none' => FixedHolidayCalendar(const []),
    _ => FixedHolidayCalendar.korea2025to2027(),
  };
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
  final laborLawOn = ref.watch(koreanLaborLawComplianceProvider);

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
    final rawOpts = await jobRepo.watchOptions(job.id).first;
    final opts = _gateByLaborLaw(rawOpts, laborLawOn);
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

/// 급여 명세서 페이지가 사용하는 bundle — [reportPlanIdProvider] 기반.
/// 캘린더의 활성 plan과 독립. 페이지 진입 시 reportPlanId는 0(메인)으로 초기화됨.
final reportBundleProvider =
    FutureProvider.autoDispose<MonthlyReportBundle>((ref) async {
  final month = ref.watch(selectedMonthProvider);
  final planId = ref.watch(reportPlanIdProvider);
  final engine = ref.watch(payrollEngineProvider);
  final jobRepo = ref.watch(jobRepositoryProvider);
  final shiftRepo = ref.watch(shiftRepositoryProvider);
  final laborLawOn = ref.watch(koreanLaborLawComplianceProvider);

  final allShifts = await shiftRepo
      .watchShiftsInMonth(month.year, month.month, planId: planId)
      .first;
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
    final rawOpts = await jobRepo.watchOptions(job.id).first;
    final opts = _gateByLaborLaw(rawOpts, laborLawOn);
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
