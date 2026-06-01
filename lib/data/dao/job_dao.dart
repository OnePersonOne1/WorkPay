import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../db/tables.dart';

part 'job_dao.g.dart';

@DriftAccessor(tables: [Jobs, JobPayrollOptionsTable])
class JobDao extends DatabaseAccessor<AppDatabase> with _$JobDaoMixin {
  JobDao(super.db);

  Stream<List<Job>> watchActiveJobs() {
    return (select(jobs)
          ..where((j) => j.archived.equals(false))
          ..orderBy([(j) => OrderingTerm(expression: j.createdAt)]))
        .watch();
  }

  Stream<List<Job>> watchAllJobs() {
    return (select(jobs)
          ..orderBy([(j) => OrderingTerm(expression: j.createdAt)]))
        .watch();
  }

  Future<Job?> findById(int id) {
    return (select(jobs)..where((j) => j.id.equals(id))).getSingleOrNull();
  }

  /// Job + 기본 옵션을 한 트랜잭션에 생성. 생성된 Job row 반환.
  Future<Job> create(JobsCompanion job, JobPayrollOptionsTableCompanion options) {
    return transaction(() async {
      final inserted = await into(jobs).insertReturning(job);
      // 옵션의 jobId는 호출자가 모르니 여기서 채워준다.
      final filledOptions = options.copyWith(jobId: Value(inserted.id));
      await into(jobPayrollOptionsTable).insert(filledOptions);
      return inserted;
    });
  }

  Future<void> updateJob(int id, JobsCompanion job) {
    return (update(jobs)..where((j) => j.id.equals(id))).write(job);
  }

  Future<void> setArchived(int id, {required bool archived, required DateTime updatedAt}) {
    return (update(jobs)..where((j) => j.id.equals(id))).write(
      JobsCompanion(
        archived: Value(archived),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  Stream<JobPayrollOptionsTableData> watchOptions(int jobId) {
    return (select(jobPayrollOptionsTable)..where((o) => o.jobId.equals(jobId)))
        .watchSingle();
  }

  Future<void> updateOptions(int jobId, JobPayrollOptionsTableCompanion options) {
    return (update(jobPayrollOptionsTable)
          ..where((o) => o.jobId.equals(jobId)))
        .write(options);
  }
}
