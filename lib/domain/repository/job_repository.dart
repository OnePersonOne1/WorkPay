// SPDX-License-Identifier: GPL-3.0-only
import '../entity/business_size.dart';
import '../entity/income_type.dart';
import '../entity/job.dart';
import '../entity/job_payroll_options.dart';

abstract interface class JobRepository {
  /// 활성(archived=false) 근무처 스트림. UI에서 기본으로 사용.
  Stream<List<Job>> watchActiveJobs();

  /// archived 포함 전체 스트림. 설정 화면에서 사용.
  Stream<List<Job>> watchAllJobs();

  Future<Job?> findById(int id);

  /// Job + 기본 PayrollOptions를 한 트랜잭션에 생성한다.
  Future<Job> create({
    required String name,
    required int hourlyWage,
    required IncomeType incomeType,
    required BusinessSize businessSize,
    required int colorArgb,
  });

  Future<void> update(Job job);

  /// archived 토글 (소프트 삭제). 시프트는 보존된다.
  Future<void> setArchived(int id, {required bool archived});

  /// 옵션 단독 watch — Job 변경과 옵션 변경을 별개 stream으로 분리해 UI rebuild 최소화.
  Stream<JobPayrollOptions> watchOptions(int jobId);

  Future<void> updateOptions(JobPayrollOptions options);
}
