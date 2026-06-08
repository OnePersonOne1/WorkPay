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

/// 겹침 알림 dialog — 충돌하는 시프트들을 색 dot + 근무처명 + 시간으로 나열.
Future<void> showOverlapDialog(
  BuildContext context,
  List<Shift> conflicts,
  Map<int, Job> jobsById,
  bool use24Hour,
) {
  String fmt(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    if (use24Hour) return '$h:$m';
    final ampm = dt.hour < 12 ? '오전' : '오후';
    final h12 = (dt.hour % 12 == 0 ? 12 : dt.hour % 12);
    return '$ampm $h12:$m';
  }

  final shown = conflicts.take(5).toList();
  final more = conflicts.length - shown.length;
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('시간이 겹쳐요'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('아래 시프트와 시간이 겹칩니다:'),
          const SizedBox(height: 8),
          for (final s in shown)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 6,
                    backgroundColor: jobsById[s.jobId] == null
                        ? Colors.grey
                        : JobColors.fromArgb(jobsById[s.jobId]!.colorArgb),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      '${jobsById[s.jobId]?.name ?? "(삭제된 근무처)"}'
                      '  ${fmt(s.startAt.toLocal())}~${fmt(s.endAt.toLocal())}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          if (more > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 18),
              child: Text(
                '... 외 $more개 더',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          const SizedBox(height: 12),
          const Text(
            '겹치는 기존 시프트는 그대로 보존됩니다.\n'
            '겹침을 허용하려면 설정 → 고급 설정에서 '
            '"시프트 시간 겹침 허용"을 켜세요.',
            style: TextStyle(fontSize: 12),
          ),
        ],
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
  // 시작/종료 모두 nullable: 자동 초기화 시 한 쪽이 null이 될 수 있음.
  // 시작/종료 모두 있어야 저장 가능. _baseDate는 picker initial용 기준 날짜.
  DateTime? _startAt;
  DateTime? _endAt;
  late DateTime _baseDate;
  DateTime? _breakStartAt;
  bool _saving = false;
  bool _deleting = false;
  bool _preciseBreak = false;

  @override
  void initState() {
    super.initState();
    final s = widget.initial;
    if (s != null) {
      final start = s.startAt.toLocal();
      _baseDate = DateTime(start.year, start.month, start.day);
      _startAt = start;
      _endAt = s.endAt.toLocal();
      _breakStartAt = s.breakStartAt?.toLocal();
      _breakCtrl = TextEditingController(text: s.breakMinutes.toString());
      _memoCtrl = TextEditingController(text: s.memo ?? '');
    } else {
      final base = widget.defaultDate ?? DateTime.now();
      _baseDate = DateTime(base.year, base.month, base.day);
      _startAt = _baseDate.add(const Duration(hours: 9));
      _endAt = _baseDate.add(const Duration(hours: 18));
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

  DateTime _baseFor({required bool start}) {
    final v = start ? _startAt : _endAt;
    if (v != null) return v;
    return _baseDate.add(Duration(hours: start ? 9 : 18));
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _baseFor(start: isStart),
      firstDate: DateTime(2020),
      lastDate: DateTime(2099),
    );
    if (picked == null) return;
    if (isStart) {
      final newStart = DateTime(
        picked.year, picked.month, picked.day,
        _startAt?.hour ?? 9, _startAt?.minute ?? 0,
      );
      setState(() => _startAt = newStart);
      await _autoResetIfInvalid(changed: 'start');
    } else {
      final newEnd = DateTime(
        picked.year, picked.month, picked.day,
        _endAt?.hour ?? 18, _endAt?.minute ?? 0,
      );
      setState(() => _endAt = newEnd);
      await _autoResetIfInvalid(changed: 'end');
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final use24 = ref.read(use24HourFormatProvider);
    final baseDateTime = _baseFor(start: isStart);
    final picked = await pickTimeDialog(
      context,
      initial: TimeOfDay(hour: baseDateTime.hour, minute: baseDateTime.minute),
      use24Hour: use24,
    );
    if (picked == null) return;
    if (isStart) {
      final dateBase = _startAt ?? _baseDate;
      final newStart = DateTime(
        dateBase.year, dateBase.month, dateBase.day,
        picked.hour, picked.minute,
      );
      setState(() => _startAt = newStart);
      await _autoResetIfInvalid(changed: 'start');
    } else {
      final dateBase = _endAt ?? _startAt ?? _baseDate;
      final newEnd = DateTime(
        dateBase.year, dateBase.month, dateBase.day,
        picked.hour, picked.minute,
      );
      setState(() => _endAt = newEnd);
      await _autoResetIfInvalid(changed: 'end');
    }
  }

  /// 사용자가 변경한 쪽(`changed`)을 유지하고, 무효 상태면 반대쪽을 초기화 후 안내 팝업.
  ///
  /// - changed='start': 새 시작이 종료보다 늦으면 → 종료 초기화
  /// - changed='end': 새 종료가 시작보다 이르면 → 시작 초기화
  Future<void> _autoResetIfInvalid({required String changed}) async {
    final s = _startAt;
    final e = _endAt;
    if (s == null || e == null) return;
    if (e.isAfter(s)) return; // 유효

    if (changed == 'start') {
      setState(() => _endAt = null);
      if (!mounted) return;
      await _showAutoResetDialog(
        title: '종료 시간을 초기화합니다',
        body: '시작 시간이 종료 시간보다 늦습니다.\n종료 시간을 다시 선택하세요.',
      );
    } else {
      setState(() => _startAt = null);
      if (!mounted) return;
      await _showAutoResetDialog(
        title: '시작 시간을 초기화합니다',
        body: '종료 시간이 시작 시간보다 이릅니다.\n시작 시간을 다시 선택하세요.',
      );
    }
  }

  Future<void> _showAutoResetDialog({required String title, required String body}) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
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
      final base = _breakStartAt ?? _startAt ?? _baseDate;
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
    final startAt = _startAt;
    final endAt = _endAt;
    if (startAt == null) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('시작 시간을 추가하세요'),
          content: const Text(
            '근무 시작 시간이 선택돼 있지 않아요.\n시작 시간을 골라야 시프트를 추가할 수 있어요.',
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
    if (endAt == null) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('종료 시간을 추가하세요'),
          content: const Text(
            '근무 종료 시간이 선택돼 있지 않아요.\n종료 시간을 골라야 시프트를 추가할 수 있어요.',
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
    final totalMinutes = endAt.difference(startAt).inMinutes;
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
          .watchShiftsInMonth(startAt.year, startAt.month)
          .first;
      final excludeId = widget.initial?.id;
      final conflicts = existing.where((s) {
        if (s.id == excludeId) return false;
        final sStart = s.startAt.toLocal();
        final sEnd = s.endAt.toLocal();
        return startAt.isBefore(sEnd) && sStart.isBefore(endAt);
      }).toList();
      if (conflicts.isNotEmpty) {
        if (mounted) {
          final jobs = await ref.read(activeJobsProvider.future);
          final jobsById = {for (final j in jobs) j.id: j};
          final use24 = ref.read(use24HourFormatProvider);
          if (!mounted) return;
          await showOverlapDialog(context, conflicts, jobsById, use24);
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
            year: startAt.year,
            month: startAt.month,
            description: widget.initial == null ? '시프트 추가' : '시프트 편집',
          );
      if (widget.initial == null) {
        await repo.create(
          jobId: job.id,
          startAt: startAt,
          endAt: endAt,
          breakMinutes: breakMinutes,
          breakStartAt: _preciseBreak ? _breakStartAt : null,
          memo: memo,
        );
      } else {
        await repo.update(
          widget.initial!.copyWith(
            jobId: job.id,
            startAt: startAt.toUtc(),
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
    // 개별 삭제 — 확인 없이 즉시 삭제 + SnackBar
    setState(() => _deleting = true);
    try {
      final startLocal = initial.startAt.toLocal();
      await ref.read(undoControllerProvider.notifier).snapshotBefore(
            year: startLocal.year,
            month: startLocal.month,
            description: '시프트 삭제',
          );
      await ref.read(shiftRepositoryProvider).delete(initial.id);
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('삭제 완료. 되돌리기로 되돌릴 수 있어요.'),
          ),
        );
      }
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
    final s = _startAt;
    final e = _endAt;
    final totalMinutes = (s != null && e != null && e.isAfter(s))
        ? e.difference(s).inMinutes
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
