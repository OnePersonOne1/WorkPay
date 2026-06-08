// SPDX-License-Identifier: GPL-3.0-only
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salary_app/data/db/app_database.dart';
import 'package:salary_app/data/repository/drift_job_repository.dart';
import 'package:salary_app/data/repository/drift_shift_repository.dart';
import 'package:salary_app/domain/entity/business_size.dart';
import 'package:salary_app/domain/entity/income_type.dart';

void main() {
  late AppDatabase db;
  late DriftJobRepository jobRepo;
  late DriftShiftRepository shiftRepo;
  final fixedNow = DateTime.utc(2026, 6, 1, 0, 0);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    jobRepo = DriftJobRepository(db.jobDao, clock: () => fixedNow);
    shiftRepo = DriftShiftRepository(db.shiftDao, clock: () => fixedNow);
  });

  tearDown(() async => db.close());

  group('JobRepository', () {
    test('create는 Job과 기본 옵션을 같은 트랜잭션에 만든다', () async {
      final job = await jobRepo.create(
        name: '카페',
        hourlyWage: 11000,
        incomeType: IncomeType.partTime,
        businessSize: BusinessSize.under5,
        colorArgb: 0xFFCC0000,
      );
      expect(job.name, '카페');
      expect(job.hourlyWage, 11000);

      // 옵션 stream을 한 번 읽어본다
      final opts = await jobRepo.watchOptions(job.id).first;
      expect(opts.weeklyHolidayAllowance, false);
      expect(opts.nightPremium, false);
      expect(opts.fourInsuranceRate, 940);
    });

    test('setArchived 후 watchActiveJobs에서 사라진다', () async {
      final job = await jobRepo.create(
        name: '편의점',
        hourlyWage: 10000,
        incomeType: IncomeType.partTime,
        businessSize: BusinessSize.under5,
        colorArgb: 0xFF00CC00,
      );
      expect((await jobRepo.watchActiveJobs().first).length, 1);

      await jobRepo.setArchived(job.id, archived: true);
      expect(await jobRepo.watchActiveJobs().first, isEmpty);
      expect((await jobRepo.watchAllJobs().first).length, 1); // 전체에서는 보임
    });
  });

  group('ShiftRepository', () {
    test('Shift 생성 시 Job의 현재 hourlyWage가 snapshot으로 복사된다', () async {
      final job = await jobRepo.create(
        name: '카페',
        hourlyWage: 12000,
        incomeType: IncomeType.partTime,
        businessSize: BusinessSize.under5,
        colorArgb: 0,
      );
      final shift = await shiftRepo.create(
        jobId: job.id,
        startAt: DateTime.utc(2026, 6, 1, 9),
        endAt: DateTime.utc(2026, 6, 1, 18),
        breakMinutes: 60,
        planId: 0,
      );
      expect(shift.hourlyWageSnapshot, 12000);
    });

    test('Job 시급 변경 후에도 과거 Shift의 snapshot은 그대로다', () async {
      final job = await jobRepo.create(
        name: '카페',
        hourlyWage: 12000,
        incomeType: IncomeType.partTime,
        businessSize: BusinessSize.under5,
        colorArgb: 0,
      );
      final oldShift = await shiftRepo.create(
        jobId: job.id,
        startAt: DateTime.utc(2026, 6, 1, 9),
        endAt: DateTime.utc(2026, 6, 1, 13),
        breakMinutes: 0,
        planId: 0,
      );

      // 시급 인상
      await jobRepo.update(job.copyWith(hourlyWage: 13000));

      final newShift = await shiftRepo.create(
        jobId: job.id,
        startAt: DateTime.utc(2026, 6, 2, 9),
        endAt: DateTime.utc(2026, 6, 2, 13),
        breakMinutes: 0,
        planId: 0,
      );

      final oldReloaded = await shiftRepo.findById(oldShift.id);
      expect(oldReloaded!.hourlyWageSnapshot, 12000);
      expect(newShift.hourlyWageSnapshot, 13000);
    });

    test('watchShiftsInMonth는 startAt 기준으로 필터링한다', () async {
      final job = await jobRepo.create(
        name: '카페',
        hourlyWage: 10000,
        incomeType: IncomeType.partTime,
        businessSize: BusinessSize.under5,
        colorArgb: 0,
      );

      // 5월 마지막 날 자정 넘김 시프트 (5/31 22:00 ~ 6/1 02:00) — 5월에 속해야 함
      await shiftRepo.create(
        jobId: job.id,
        startAt: DateTime(2026, 5, 31, 22),
        endAt: DateTime(2026, 6, 1, 2),
        breakMinutes: 0,
        planId: 0,
      );

      // 순수 6월 시프트
      await shiftRepo.create(
        jobId: job.id,
        startAt: DateTime(2026, 6, 1, 9),
        endAt: DateTime(2026, 6, 1, 18),
        breakMinutes: 60,
        planId: 0,
      );

      final mayShifts = await shiftRepo.watchShiftsInMonth(2026, 5, planId: 0).first;
      final juneShifts = await shiftRepo.watchShiftsInMonth(2026, 6, planId: 0).first;

      expect(mayShifts.length, 1, reason: '자정 넘김 시프트는 startAt의 달(5월)에 속함');
      expect(juneShifts.length, 1);
    });

    test('delete 후 findById는 null', () async {
      final job = await jobRepo.create(
        name: '카페',
        hourlyWage: 10000,
        incomeType: IncomeType.partTime,
        businessSize: BusinessSize.under5,
        colorArgb: 0,
      );
      final shift = await shiftRepo.create(
        jobId: job.id,
        startAt: DateTime.utc(2026, 6, 1, 9),
        endAt: DateTime.utc(2026, 6, 1, 18),
        breakMinutes: 0,
        planId: 0,
      );
      await shiftRepo.delete(shift.id);
      expect(await shiftRepo.findById(shift.id), isNull);
    });
  });

  group('AppSettings', () {
    test('AppSettings는 onCreate에서 seed되어 즉시 읽힌다', () async {
      final repo = await db.appSettingsDao.read();
      expect(repo.id, 1);
      expect(repo.schemaVersion, kCurrentSchemaVersion);
      expect(repo.locale, 'ko');
    });
  });
}
