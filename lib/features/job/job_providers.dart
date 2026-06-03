import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../domain/entity/job.dart';

/// 활성(archived=false) 근무처 stream.
final activeJobsProvider = StreamProvider<List<Job>>((ref) {
  return ref.watch(jobRepositoryProvider).watchActiveJobs();
});

/// archived 포함 전체 근무처 stream.
final allJobsProvider = StreamProvider<List<Job>>((ref) {
  return ref.watch(jobRepositoryProvider).watchAllJobs();
});
