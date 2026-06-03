import '../../domain/entity/job.dart';
import '../../domain/payroll/monthly_computation.dart';

/// 월별 급여 데이터의 묶음.
/// - [combined]: 모든 활성 근무처를 합산한 계산
/// - [perJob]: 각 근무처별 계산 ([job], [computation]) — 표시 순서는 활성 근무처 순서
class MonthlyReportBundle {
  const MonthlyReportBundle({
    required this.combined,
    required this.perJob,
  });

  final MonthlyComputation combined;
  final List<({Job job, MonthlyComputation computation})> perJob;

  factory MonthlyReportBundle.empty(int year, int month) => MonthlyReportBundle(
        combined: MonthlyComputation.empty(year, month),
        perJob: const [],
      );
}
