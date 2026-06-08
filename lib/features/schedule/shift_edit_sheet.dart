import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/palette/job_colors.dart';
import '../../core/time/time_picker_dialog.dart';
import '../../data/providers.dart';
import '../../domain/entity/business_size.dart';
import '../../domain/entity/income_type.dart';
import '../../domain/entity/job.dart';
import '../../domain/entity/shift.dart';
import '../job/job_providers.dart';
import '../settings/settings_providers.dart';
import 'payroll_providers.dart';
import 'schedule_providers.dart';
import 'undo_controller.dart';

/// 시프트 생성/편집 modal sheet.
/// [shift]이 null이면 생성, 아니면 편집. [defaultDate]는 새 시프트의 기본 시작 날짜.
Future<bool?> showShiftEditSheet(
  BuildContext context, {
  Shift? shift,
  DateTime? defaultDate,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: _ShiftEditSheet(initial: shift, defaultDate: defaultDate),
    ),
  );
}

class _ShiftEditSheet extends ConsumerStatefulWidget {
  const _ShiftEditSheet({this.initial, this.defaultDate});
  final Shift? initial;
  final DateTime? defaultDate;

  @override
  ConsumerState<_ShiftEditSheet> createState() => _ShiftEditSheetState();
}

class _ShiftEditSheetState extends ConsumerState<_ShiftEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _breakCtrl;
  late final TextEditingController _memoCtrl;

  Job? _selectedJob;
  late DateTime _startAt;
  // 종료가 시작 이전이거나 같으면 null로 자동 해제 — 사용자가 다시 골라야 저장 가능
  DateTime? _endAt;
  DateTime? _breakStartAt;
  bool _saving = false;
  bool _deleting = false;
  bool _preciseBreak = false;

  @override
  void initState() {
    super.initState();
    final s = widget.initial;
    if (s != null) {
      _startAt = s.startAt.toLocal();
      _endAt = s.endAt.toLocal();
      _breakStartAt = s.breakStartAt?.toLocal();
      _breakCtrl = TextEditingController(text: s.breakMinutes.toString());
      _memoCtrl = TextEditingController(text: s.memo ?? '');
    } else {
      final base = widget.defaultDate ?? DateTime.now();
      final day = DateTime(base.year, base.month, base.day);
      _startAt = day.add(const Duration(hours: 9));
      _endAt = day.add(const Duration(hours: 18));
      _breakCtrl = TextEditingController(text: '0');
      _memoCtrl = TextEditingController();
    }
  }

  @override
  void dispose() {
    _breakCtrl.dispose();
    _memoCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final base = isStart ? _startAt : (_endAt ?? _startAt.add(const Duration(hours: 9)));
    final picked = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(2020),
      lastDate: DateTime(2099),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startAt = DateTime(
          picked.year, picked.month, picked.day,
          _startAt.hour, _startAt.minute,
        );
        // 종료가 시작 이전이거나 같으면 해제 (사용자가 다시 골라야 함)
        if (_endAt != null && !_endAt!.isAfter(_startAt)) {
          _endAt = null;
        }
      } else {
        final h = _endAt?.hour ?? 18;
        final m = _endAt?.minute ?? 0;
        final candidate = DateTime(picked.year, picked.month, picked.day, h, m);
        _endAt = candidate.isAfter(_startAt) ? candidate : null;
      }
    });
  }

  Future<void> _pickTime(bool isStart) async {
    final base = isStart
        ? _startAt
        : (_endAt ?? _startAt.add(const Duration(hours: 9)));
    final use24 = ref.read(use24HourFormatProvider);
    final picked = await pickTimeDialog(
      context,
      initial: TimeOfDay(hour: base.hour, minute: base.minute),
      use24Hour: use24,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startAt = DateTime(
          _startAt.year, _startAt.month, _startAt.day,
          picked.hour, picked.minute,
        );
        if (_endAt != null && !_endAt!.isAfter(_startAt)) {
          _endAt = null;
        }
      } else {
        // 종료 날짜가 있으면 그 날짜에, 없으면 시작 날짜에 시간만 설정
        final endDate = _endAt ?? _startAt;
        final candidate = DateTime(
          endDate.year, endDate.month, endDate.day,
          picked.hour, picked.minute,
        );
        _endAt = candidate.isAfter(_startAt) ? candidate : null;
      }
    });
  }

  Future<void> _pickBreakStart() async {
    final use24 = ref.read(use24HourFormatProvider);
    final picked = await pickTimeDialog(
      context,
      initial: TimeOfDay(
        hour: _breakStartAt?.hour ?? 12,
        minute: _breakStartAt?.minute ?? 0,
      ),
      use24Hour: use24,
    );
    if (picked == null) return;
    setState(() {
      final base = _breakStartAt ?? _startAt;
      _breakStartAt = DateTime(
        base.year, base.month, base.day, picked.hour, picked.minute,
      );
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final job = _selectedJob;
    if (job == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('근무처를 선택하세요')),
      );
      return;
    }
    // 종료 시간이 해제됐을 때 — 시작 시간 변경으로 자동 해제됐거나 미선택
    final endAt = _endAt;
    if (endAt == null) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('종료 시간을 추가하세요'),
          content: const Text(
            '근무 종료 시간이 선택돼 있지 않아요.\n'
            '종료 시간을 골라야 시프트를 추가할 수 있어요.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('닫기'),
            ),
          ],
        ),
      );
      return;
    }
    final totalMinutes = endAt.difference(_startAt).inMinutes;
    final breakMinutes = int.parse(_breakCtrl.text.trim());
    if (breakMinutes >= totalMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('휴게 시간이 근무 시간보다 깁니다')),
      );
      return;
    }

    // 겹침 검증 — allowShiftOverlap가 false면 차단
    final constants = ref.read(payrollConstantsProvider);
    if (!constants.allowShiftOverlap) {
      final repo = ref.read(shiftRepositoryProvider);
      final existing = await repo
          .watchShiftsInMonth(_startAt.year, _startAt.month)
          .first;
      final excludeId = widget.initial?.id;
      final hasOverlap = existing.any((s) {
        if (s.id == excludeId) return false;
        final sStart = s.startAt.toLocal();
        final sEnd = s.endAt.toLocal();
        return _startAt.isBefore(sEnd) && sStart.isBefore(endAt);
      });
      if (hasOverlap) {
        if (mounted) {
          await showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('시간이 겹쳐요'),
              content: const Text(
                '같은 시간대에 이미 추가된 시프트가 있어요.\n\n'
                '겹치는 시프트는 그대로 보존됩니다.\n'
                '겹침을 허용하려면 설정 → 고급 설정에서 '
                '"시프트 시간 겹침 허용"을 켜세요.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('닫기'),
                ),
              ],
            ),
          );
        }
        return;
      }
    }

    setState(() => _saving = true);
    final repo = ref.read(shiftRepositoryProvider);
    final memo = _memoCtrl.text.trim().isEmpty ? null : _memoCtrl.text.trim();
    try {
      // Undo snapshot — mutation 직전 현재 월 상태 저장
      await ref.read(undoControllerProvider.notifier).snapshotBefore(
            year: _startAt.year,
            month: _startAt.month,
            description: widget.initial == null ? '시프트 추가' : '시프트 편집',
          );
      if (widget.initial == null) {
        await repo.create(
          jobId: job.id,
          startAt: _startAt,
          endAt: endAt,
          breakMinutes: breakMinutes,
          breakStartAt: _preciseBreak ? _breakStartAt : null,
          memo: memo,
        );
      } else {
        await repo.update(
          widget.initial!.copyWith(
            jobId: job.id,
            startAt: _startAt.toUtc(),
            endAt: endAt.toUtc(),
            breakMinutes: breakMinutes,
            breakStartAt: _preciseBreak ? _breakStartAt?.toUtc() : null,
            clearBreakStartAt: !_preciseBreak,
            memo: memo,
            clearMemo: memo == null,
            updatedAt: DateTime.now().toUtc(),
          ),
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      }
    }
  }

  Future<void> _delete() async {
    final initial = widget.initial;
    if (initial == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('시프트 삭제'),
        content: const Text('이 시프트를 삭제할까요? 되돌릴 수 없어요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소'),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    setState(() => _deleting = true);
    try {
      final startLocal = initial.startAt.toLocal();
      await ref.read(undoControllerProvider.notifier).snapshotBefore(
            year: startLocal.year,
            month: startLocal.month,
            description: '시프트 삭제',
          );
      await ref.read(shiftRepositoryProvider).delete(initial.id);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _deleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    final asyncJobs = ref.watch(activeJobsProvider);

    return asyncJobs.when(
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => SizedBox(
        height: 200,
        child: Center(child: Text('근무처 로드 오류: $e')),
      ),
      data: (jobs) {
        // 초기 Job 선택 + 옵션 로드.
        // 우선순위: 편집 중인 시프트의 jobId > 일정표에서 활성 선택된 근무처 > 첫 번째
        if (_selectedJob == null) {
          final initialJobId =
              widget.initial?.jobId ?? ref.read(selectedJobProvider);
          _selectedJob = initialJobId == null
              ? (jobs.isNotEmpty ? jobs.first : null)
              : jobs.firstWhere(
                  (j) => j.id == initialJobId,
                  orElse: () => jobs.isNotEmpty ? jobs.first : _placeholderJob(),
                );
        }
        if (jobs.isEmpty || _selectedJob == null) {
          return const SizedBox(
            height: 200,
            child: Center(child: Text('근무처가 없어서 시프트를 추가할 수 없어요.')),
          );
        }
        return _buildForm(context, jobs, isEdit);
      },
    );
  }

  /// jobs가 비어있을 때만 잠깐 쓰이는 fallback. 실제로는 위 가드로 도달 안 됨.
  Job _placeholderJob() => Job(
        id: -1,
        name: '',
        hourlyWage: 0,
        incomeType: IncomeType.partTime,
        businessSize: BusinessSize.under5,
        colorArgb: 0,
        archived: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  Widget _buildForm(BuildContext context, List<Job> jobs, bool isEdit) {
    final scheme = Theme.of(context).colorScheme;
    final selectedJob = _selectedJob!;
    final totalMinutes = (_endAt != null && _endAt!.isAfter(_startAt))
        ? _endAt!.difference(_startAt).inMinutes
        : 0;
    final breakMin = int.tryParse(_breakCtrl.text.trim()) ?? 0;
    final workMin = (totalMinutes - breakMin).clamp(0, 1 << 30);

    // 선택된 Job의 preciseBreakInput 옵션 비동기 로드
    final optsAsync = ref.watch(_optionsForJobProvider(selectedJob.id));
    optsAsync.whenData((opts) {
      if (_preciseBreak != opts.preciseBreakInput) {
        // 빌드 중 setState는 위험 — postFrame 사용
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() => _preciseBreak = opts.preciseBreakInput);
          }
        });
      }
    });

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                isEdit ? '시프트 편집' : '시프트 추가',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
            // 근무처 선택
            DropdownButtonFormField<Job>(
              initialValue: selectedJob,
              decoration: const InputDecoration(
                labelText: '근무처',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final j in jobs)
                  DropdownMenuItem(
                    value: j,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 8,
                          backgroundColor: JobColors.fromArgb(j.colorArgb),
                        ),
                        const SizedBox(width: 10),
                        Text(j.name),
                      ],
                    ),
                  ),
              ],
              onChanged: (j) => setState(() => _selectedJob = j),
            ),
            const SizedBox(height: 16),
            _DateTimeRow(
              label: '시작',
              date: _startAt,
              onPickDate: () => _pickDate(true),
              onPickTime: () => _pickTime(true),
            ),
            const SizedBox(height: 8),
            _DateTimeRow(
              label: '종료',
              date: _endAt,
              onPickDate: () => _pickDate(false),
              onPickTime: () => _pickTime(false),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _breakCtrl,
              decoration: const InputDecoration(
                labelText: '휴게 시간',
                suffixText: '분',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {}),
              validator: (v) {
                final t = v?.trim() ?? '';
                if (t.isEmpty) return '0 이상 입력';
                final n = int.tryParse(t);
                if (n == null) return '숫자만 입력';
                if (n < 0) return '0 이상';
                return null;
              },
            ),
            if (_preciseBreak) ...[
              const SizedBox(height: 8),
              _BreakStartRow(
                value: _breakStartAt,
                onPick: _pickBreakStart,
                onClear: () => setState(() => _breakStartAt = null),
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _memoCtrl,
              decoration: const InputDecoration(
                labelText: '메모 (선택)',
                border: OutlineInputBorder(),
              ),
              maxLength: 120,
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 18),
                  const SizedBox(width: 8),
                  Text('실 근무 시간: ${_formatDuration(workMin)}'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (isEdit)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _deleting || _saving ? null : _delete,
                      icon: const Icon(Icons.delete_outline),
                      label: _deleting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('삭제'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: scheme.error,
                      ),
                    ),
                  ),
                if (isEdit) const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _saving || _deleting ? null : _save,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(isEdit ? '저장' : '추가'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '$m분';
    if (m == 0) return '$h시간';
    return '$h시간 $m분';
  }
}

class _DateTimeRow extends StatelessWidget {
  const _DateTimeRow({
    required this.label,
    required this.date,
    required this.onPickDate,
    required this.onPickTime,
  });
  final String label;
  // null이면 미선택 상태 — 버튼 텍스트가 "날짜 선택"/"시간 선택"으로 바뀜
  final DateTime? date;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;

  @override
  Widget build(BuildContext context) {
    final hasValue = date != null;
    final dateText = hasValue
        ? '${date!.year}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}'
        : '날짜 선택';
    final timeText = hasValue
        ? '${date!.hour.toString().padLeft(2, '0')}:${date!.minute.toString().padLeft(2, '0')}'
        : '시간 선택';
    final scheme = Theme.of(context).colorScheme;
    final missingStyle = !hasValue
        ? OutlinedButton.styleFrom(foregroundColor: scheme.error)
        : null;
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        Expanded(
          flex: 3,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today_outlined, size: 16),
            label: Text(dateText),
            onPressed: onPickDate,
            style: missingStyle,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          flex: 2,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.access_time, size: 16),
            label: Text(timeText),
            onPressed: onPickTime,
            style: missingStyle,
          ),
        ),
      ],
    );
  }
}

class _BreakStartRow extends StatelessWidget {
  const _BreakStartRow({
    required this.value,
    required this.onPick,
    required this.onClear,
  });
  final DateTime? value;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = value == null
        ? '휴게 시작 시각 선택'
        : '휴게 시작 ${value!.hour.toString().padLeft(2, '0')}:${value!.minute.toString().padLeft(2, '0')}';
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.free_breakfast_outlined, size: 16),
            label: Text(text),
            onPressed: onPick,
          ),
        ),
        if (value != null)
          IconButton(
            icon: Icon(Icons.close, color: scheme.onSurfaceVariant),
            onPressed: onClear,
          ),
      ],
    );
  }
}

/// Job별 옵션을 stream으로 가져오는 family provider.
/// shift sheet에서 preciseBreakInput을 보기 위해 사용.
final _optionsForJobProvider =
    StreamProvider.family<_JobOptsLite, int>((ref, jobId) {
  return ref.watch(jobRepositoryProvider).watchOptions(jobId).map(
        (o) => _JobOptsLite(preciseBreakInput: o.preciseBreakInput),
      );
});

class _JobOptsLite {
  const _JobOptsLite({required this.preciseBreakInput});
  final bool preciseBreakInput;
}
