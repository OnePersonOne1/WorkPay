// SPDX-License-Identifier: GPL-3.0-only
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/palette/job_colors.dart';
import '../../core/time/time_format.dart';
import '../../core/time/time_picker_dialog.dart';
import '../../data/providers.dart';
import '../../domain/entity/business_size.dart';
import '../../domain/entity/income_type.dart';
import '../../domain/entity/job.dart';
import '../../domain/entity/shift.dart';
import '../../l10n/generated/app_localizations.dart';
import '../job/job_providers.dart';
import '../settings/settings_providers.dart';
import 'payroll_providers.dart';
import 'plan_providers.dart';
import 'schedule_providers.dart';
import 'undo_controller.dart';

/// 겹침 알림 dialog — 충돌하는 시프트들을 색 dot + 근무처명 + 시간으로 나열.
Future<void> showOverlapDialog(
  BuildContext context,
  List<Shift> conflicts,
  Map<int, Job> jobsById,
  bool use24Hour,
) {
  final shown = conflicts.take(5).toList();
  final more = conflicts.length - shown.length;
  return showDialog<void>(
    context: context,
    builder: (ctx) {
      final l = AppLocalizations.of(ctx);
      return AlertDialog(
        title: Text(l.shiftSheetOverlapTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.shiftSheetOverlapBody),
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
                        l.shiftSheetOverlapItem(
                          jobsById[s.jobId]?.name ?? '?',
                          formatHM(s.startAt.toLocal(),
                              use24Hour: use24Hour, am: l.amSuffix, pm: l.pmSuffix),
                          formatHM(s.endAt.toLocal(),
                              use24Hour: use24Hour, am: l.amSuffix, pm: l.pmSuffix),
                        ),
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
                  '... +$more',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.actionClose),
          ),
        ],
      );
    },
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

  Future<void> _autoResetIfInvalid({required String changed}) async {
    final s = _startAt;
    final e = _endAt;
    if (s == null || e == null) return;
    if (e.isAfter(s)) return;

    final l = AppLocalizations.of(context);
    if (changed == 'start') {
      setState(() => _endAt = null);
      if (!mounted) return;
      await _showAutoResetDialog(
        title: l.shiftSheetSelectEnd,
        body: l.shiftSheetEndBeforeStart,
      );
    } else {
      setState(() => _startAt = null);
      if (!mounted) return;
      await _showAutoResetDialog(
        title: l.shiftSheetSelectStart,
        body: l.shiftSheetEndBeforeStart,
      );
    }
  }

  Future<void> _showAutoResetDialog({required String title, required String body}) {
    return showDialog<void>(
      context: context,
      builder: (ctx) {
        final lc = AppLocalizations.of(ctx);
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(lc.actionClose),
            ),
          ],
        );
      },
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
    final l = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    final job = _selectedJob;
    if (job == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.shiftSheetSelectJob)),
      );
      return;
    }
    final startAt = _startAt;
    final endAt = _endAt;
    if (startAt == null) {
      await _showAutoResetDialog(
        title: l.shiftSheetSelectStart,
        body: l.shiftSheetSelectStart,
      );
      return;
    }
    if (endAt == null) {
      await _showAutoResetDialog(
        title: l.shiftSheetSelectEnd,
        body: l.shiftSheetSelectEnd,
      );
      return;
    }
    final totalMinutes = endAt.difference(startAt).inMinutes;
    final breakMinutes = int.parse(_breakCtrl.text.trim());
    if (breakMinutes >= totalMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.shiftSheetBreakTooLong)),
      );
      return;
    }

    final planId = ref.read(activePlanIdProvider);

    // 겹침 검증 — allowShiftOverlap가 false면 차단 (현재 plan 내에서만)
    final constants = ref.read(payrollConstantsProvider);
    if (!constants.allowShiftOverlap) {
      final repo = ref.read(shiftRepositoryProvider);
      final existing = await repo
          .watchShiftsInMonth(startAt.year, startAt.month, planId: planId)
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
      await ref.read(undoControllerProvider.notifier).snapshotBefore(
            year: startAt.year,
            month: startAt.month,
            planId: planId,
            description: widget.initial == null
                ? l.shiftSheetCreatedSnapshot
                : l.shiftSheetSavedSnapshot,
          );
      if (widget.initial == null) {
        await repo.create(
          jobId: job.id,
          startAt: startAt,
          endAt: endAt,
          breakMinutes: breakMinutes,
          breakStartAt: _preciseBreak ? _breakStartAt : null,
          memo: memo,
          planId: planId,
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
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _delete() async {
    final l = AppLocalizations.of(context);
    final initial = widget.initial;
    if (initial == null) return;
    setState(() => _deleting = true);
    try {
      final startLocal = initial.startAt.toLocal();
      final planId = ref.read(activePlanIdProvider);
      await ref.read(undoControllerProvider.notifier).snapshotBefore(
            year: startLocal.year,
            month: startLocal.month,
            planId: planId,
            description: l.scheduleShiftDeleteSnapshotWithDate(
              startLocal.month,
              startLocal.day,
            ),
          );
      await ref.read(shiftRepositoryProvider).delete(initial.id);
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.scheduleSingleShiftDeleted)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _deleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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
      error: (e, _) {
        final l = AppLocalizations.of(context);
        return SizedBox(
          height: 200,
          child: Center(child: Text(l.scheduleJobLoadError(e.toString()))),
        );
      },
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
          final l = AppLocalizations.of(context);
          return SizedBox(
            height: 200,
            child: Center(child: Text(l.scheduleNoJobsHint)),
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
    final l = AppLocalizations.of(context);
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
                isEdit ? l.shiftSheetTitleEdit : l.shiftSheetTitleNew,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
            DropdownButtonFormField<Job>(
              initialValue: selectedJob,
              decoration: InputDecoration(
                labelText: l.shiftSheetJob,
                border: const OutlineInputBorder(),
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
              label: l.shiftSheetStart,
              date: _startAt,
              onPickDate: () => _pickDate(true),
              onPickTime: () => _pickTime(true),
            ),
            const SizedBox(height: 8),
            _DateTimeRow(
              label: l.shiftSheetEnd,
              date: _endAt,
              onPickDate: () => _pickDate(false),
              onPickTime: () => _pickTime(false),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _breakCtrl,
              decoration: InputDecoration(
                labelText: l.shiftSheetBreak,
                suffixText: l.shiftSheetBreakUnit,
                border: const OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {}),
              validator: (v) {
                final t = v?.trim() ?? '';
                if (t.isEmpty) return '0+';
                final n = int.tryParse(t);
                if (n == null) return '0+';
                if (n < 0) return '0+';
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
              decoration: InputDecoration(
                labelText: l.shiftSheetMemo,
                hintText: l.shiftSheetMemoHint,
                border: const OutlineInputBorder(),
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
                  Text(l.shiftSheetWorkHours(_formatHoursShort(workMin))),
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
                          : Text(l.actionDelete),
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
                          : Text(isEdit ? l.actionSave : l.actionAdd),
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

  String _formatHoursShort(int minutes) {
    final h = minutes / 60;
    if (h == h.toInt()) return h.toInt().toString();
    return h.toStringAsFixed(1);
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
    final l = AppLocalizations.of(context);
    final hasValue = date != null;
    final dateText = hasValue
        ? '${date!.year}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}'
        : l.shiftSheetStart;
    final timeText = hasValue
        ? '${date!.hour.toString().padLeft(2, '0')}:${date!.minute.toString().padLeft(2, '0')}'
        : l.shiftSheetStart;
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
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = value == null
        ? l.shiftSheetBreak
        : '${l.shiftSheetBreak} ${value!.hour.toString().padLeft(2, '0')}:${value!.minute.toString().padLeft(2, '0')}';
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
