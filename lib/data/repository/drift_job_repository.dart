// SPDX-License-Identifier: GPL-3.0-only
import 'package:drift/drift.dart';

import '../../domain/entity/business_size.dart';
import '../../domain/entity/income_type.dart';
import '../../domain/entity/job.dart' as ent;
import '../../domain/entity/job_payroll_options.dart' as ent;
import '../../domain/repository/job_repository.dart';
import '../dao/job_dao.dart';
import '../db/app_database.dart' as db;
import 'mappers.dart';

class DriftJobRepository implements JobRepository {
  DriftJobRepository(this._dao, {DateTime Function()? clock})
      : _clock = clock ?? (() => DateTime.now().toUtc());

  final JobDao _dao;
  final DateTime Function() _clock;

  @override
  Stream<List<ent.Job>> watchActiveJobs() =>
      _dao.watchActiveJobs().map((rows) => rows.map((r) => r.toEntity()).toList());

  @override
  Stream<List<ent.Job>> watchAllJobs() =>
      _dao.watchAllJobs().map((rows) => rows.map((r) => r.toEntity()).toList());

  @override
  Future<ent.Job?> findById(int id) async {
    final row = await _dao.findById(id);
    return row?.toEntity();
  }

  @override
  Future<ent.Job> create({
    required String name,
    required int hourlyWage,
    required IncomeType incomeType,
    required BusinessSize businessSize,
    required int colorArgb,
  }) async {
    final now = _clock();
    final defaults = ent.JobPayrollOptions.defaultsFor(0, now); // jobId는 DAO가 채움
    final row = await _dao.create(
      db.JobsCompanion.insert(
        name: name,
        hourlyWage: hourlyWage,
        incomeType: incomeType.name,
        businessSize: businessSize.name,
        colorArgb: colorArgb,
        createdAt: now,
        updatedAt: now,
      ),
      defaults.toCompanion(),
    );
    return row.toEntity();
  }

  @override
  Future<void> update(ent.Job job) {
    return _dao.updateJob(
      job.id,
      db.JobsCompanion(
        name: Value(job.name),
        hourlyWage: Value(job.hourlyWage),
        incomeType: Value(job.incomeType.name),
        businessSize: Value(job.businessSize.name),
        colorArgb: Value(job.colorArgb),
        archived: Value(job.archived),
        updatedAt: Value(_clock()),
      ),
    );
  }

  @override
  Future<void> setArchived(int id, {required bool archived}) {
    return _dao.setArchived(id, archived: archived, updatedAt: _clock());
  }

  @override
  Stream<ent.JobPayrollOptions> watchOptions(int jobId) =>
      _dao.watchOptions(jobId).map((r) => r.toEntity());

  @override
  Future<void> updateOptions(ent.JobPayrollOptions options) {
    final companion = options
        .copyWith(updatedAt: _clock())
        .toCompanion();
    return _dao.updateOptions(options.jobId, companion);
  }
}
