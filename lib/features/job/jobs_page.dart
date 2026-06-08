import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/palette/job_colors.dart';
import '../../data/providers.dart';
import '../../domain/entity/income_type.dart';
import '../../domain/entity/job.dart';
import 'job_edit_sheet.dart';
import 'job_providers.dart';

class JobsPage extends ConsumerStatefulWidget {
  const JobsPage({super.key});

  @override
  ConsumerState<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends ConsumerState<JobsPage> {
  bool _showArchived = false;

  @override
  Widget build(BuildContext context) {
    final source = _showArchived ? allJobsProvider : activeJobsProvider;
    final asyncJobs = ref.watch(source);

    return Scaffold(
      appBar: AppBar(
        title: const Text('근무처 관리'),
        actions: [
          TextButton.icon(
            icon: Icon(
              _showArchived ? Icons.archive : Icons.archive_outlined,
              size: 18,
            ),
            label: Text(_showArchived ? '활성만' : '보관 포함'),
            onPressed: () => setState(() => _showArchived = !_showArchived),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: asyncJobs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('로드 오류: $e')),
        data: (jobs) {
          if (jobs.isEmpty) return const _EmptyState();
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: jobs.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) => _JobTile(job: jobs[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('근무처 추가'),
        onPressed: () => showJobEditSheet(context),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.work_outline, size: 48),
            const SizedBox(height: 12),
            const Text(
              '아직 근무처가 없습니다',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              '아래 "근무처 추가"로 첫 근무처를 등록하세요.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _JobTile extends ConsumerWidget {
  const _JobTile({required this.job});
  final Job job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wageFmt = NumberFormat.decimalPattern('ko_KR').format(job.hourlyWage);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: JobColors.fromArgb(job.colorArgb),
        radius: 14,
      ),
      title: Text(
        job.name,
        style: TextStyle(
          decoration: job.archived ? TextDecoration.lineThrough : null,
          color: job.archived
              ? Theme.of(context).colorScheme.onSurfaceVariant
              : null,
        ),
      ),
      subtitle: Text(
        job.incomeType == IncomeType.workStudy
            ? '시급 ₩$wageFmt · 근로장학금'
            : '시급 ₩$wageFmt',
      ),
      trailing: PopupMenuButton<_JobMenuAction>(
        onSelected: (action) => _handleMenu(context, ref, action),
        itemBuilder: (ctx) => [
          const PopupMenuItem(
            value: _JobMenuAction.edit,
            child: ListTile(
              leading: Icon(Icons.edit_outlined),
              title: Text('편집'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          PopupMenuItem(
            value: job.archived
                ? _JobMenuAction.unarchive
                : _JobMenuAction.archive,
            child: ListTile(
              leading: Icon(
                job.archived ? Icons.unarchive_outlined : Icons.archive_outlined,
              ),
              title: Text(job.archived ? '복원' : '보관'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const PopupMenuItem(
            value: _JobMenuAction.deleteAllShifts,
            child: ListTile(
              leading: Icon(Icons.delete_sweep_outlined),
              title: Text('이 근무처 시프트 전체 삭제'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
      onTap: () => showJobEditSheet(context, job: job),
    );
  }

  Future<void> _handleMenu(
    BuildContext context,
    WidgetRef ref,
    _JobMenuAction action,
  ) async {
    switch (action) {
      case _JobMenuAction.edit:
        await showJobEditSheet(context, job: job);
      case _JobMenuAction.archive:
        await ref.read(jobRepositoryProvider).setArchived(job.id, archived: true);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('"${job.name}" 보관됨')),
          );
        }
      case _JobMenuAction.unarchive:
        await ref
            .read(jobRepositoryProvider)
            .setArchived(job.id, archived: false);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('"${job.name}" 복원됨')),
          );
        }
      case _JobMenuAction.deleteAllShifts:
        await _deleteAllShifts(context, ref);
    }
  }

  Future<void> _deleteAllShifts(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('"${job.name}" 시프트 전체 삭제'),
        content: const Text(
          '이 근무처의 모든 시프트(과거 포함)를 삭제합니다.\n'
          '근무처 자체는 남습니다.\n\n'
          '※ 되돌리기는 같은 달 단위로만 동작하므로\n'
          '   여러 달에 걸친 삭제는 일부만 복원될 수 있어요.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소'),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;
    final count =
        await ref.read(shiftRepositoryProvider).deleteShiftsOfJob(job.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$count개 시프트 삭제됨')),
      );
    }
  }
}

enum _JobMenuAction { edit, archive, unarchive, deleteAllShifts }
