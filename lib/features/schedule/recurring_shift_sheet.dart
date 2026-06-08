// SPDX-License-Identifier: GPL-3.0-only
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/palette/job_colors.dart';
import '../../core/time/time_picker_dialog.dart';
import '../../data/providers.dart';
import '../../domain/entity/job.dart';
import '../../domain/entity/shift.dart';
import '../../domain/repository/shift_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../job/job_providers.dart';
import '../settings/settings_providers.dart';
import 'payroll_providers.dart';
import 'plan_providers.dart';
import 'schedule_providers.dart';
import 'shift_edit_sheet.dart' show showOverlapDialog;
import 'undo_controller.dart';

const int _kMaxBulkShifts = 366;

Future<bool?> showRecurringShiftSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: const _RecurringShiftSheet(),
    ),
  );
}

class _RecurringShiftSheet extends ConsumerStatefulWidget {
  const _RecurringShiftSheet();

  @override
  ConsumerState<_RecurringShiftSheet> createState() => _State();
}

class _State extends ConsumerState<_RecurringShiftSheet> {
  final _formKey = GlobalKey<FormState>();
  final _breakCtrl = TextEditingController(text: '0');
  final _memoCtrl = TextEditingController();

  Job? _selectedJob;
  Set<int> _weekdays = {DateTime.monday, DateTime.wednesday, DateTime.friday};
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 18, minute: 0);
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  bool _saving = false;

  @override
  void dispose() {
    _breakCtrl.dispose();
    _memoCtrl.dispose();
    super.dispose();
  }

  List<({DateTime startAt, DateTime endAt})> _expand() {
    final out = <({DateTime startAt, DateTime endAt})>[];
    final startMidnight =
        DateTime(_startDate.year, _startDate.month, _startDate.day);
    final endMidnight = DateTime(_endDate.year, _endDate.month, _endDate.day);
    for (var d = startMidnight;
        !d.isAfter(endMidnight);
        d = d.add(const Duration(days: 1))) {
      if (!_weekdays.contains(d.weekday)) continue;
      final start =
          DateTime(d.year, d.month, d.day, _startTime.hour, _startTime.minute);
      var end =
          DateTime(d.year, d.month, d.day, _endTime.hour, _endTime.minute);
      if (!end.isAfter(start)) {
        end = end.add(const Duration(days: 1));
      }
      out.add((startAt: start, endAt: end));
    }
    return out;
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2099),
    );
    if (picked == null) return;
    setState(() {
      _startDate = picked;
      if (_endDate.isBefore(_startDate)) {
        _endDate = _startDate.add(const Duration(days: 30));
      }
    });
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime(2099),
    );
    if (picked == null) return;
    setState(() => _endDate = picked);
  }

  Future<void> _pickStartTime() async {
    final use24 = ref.read(use24HourFormatProvider);
    final picked = await pickTimeDialog(
      context,
      initial: _startTime,
      use24Hour: use24,
    );
    if (picked == null) return;
    setState(() => _startTime = picked);
  }

  Future<void> _pickEndTime() async {
    final use24 = ref.read(use24HourFormatProvider);
    final picked = await pickTimeDialog(
      context,
      initial: _endTime,
      use24Hour: use24,
    );
    if (picked == null) return;
    setState(() => _endTime = picked);
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    final job = _selectedJob;
    if (job == null) {
      _snack(l.shiftSheetSelectJob);
      return;
    }
    if (_weekdays.isEmpty) {
      _snack(l.recurringSelectWeekdays);
      return;
    }
    final pairs = _expand();
    if (pairs.isEmpty) {
      _snack(l.recurringPreview(0, 0));
      return;
    }
    if (pairs.length > _kMaxBulkShifts) {
      _snack(l.recurringPreview(pairs.length, 0));
      return;
    }
    final breakMinutes = int.parse(_breakCtrl.text.trim());
    final firstDuration =
        pairs.first.endAt.difference(pairs.first.startAt).inMinutes;
    if (breakMinutes >= firstDuration) {
      _snack(l.shiftSheetBreakTooLong);
      return;
    }

    final memo = _memoCtrl.text.trim().isEmpty ? null : _memoCtrl.text.trim();
    final drafts = [
      for (final p in pairs)
        BulkShiftDraft(
          startAt: p.startAt,
          endAt: p.endAt,
          breakMinutes: breakMinutes,
          memo: memo,
        ),
    ];

    final constants = ref.read(payrollConstantsProvider);
    if (!constants.allowShiftOverlap) {
      final repo = ref.read(shiftRepositoryProvider);
      final planId = ref.read(activePlanIdProvider);
      final months = <(int, int)>{};
      for (final d in drafts) {
        months.add((d.startAt.year, d.startAt.month));
      }
      final existing = <Shift>[];
      for (final (y, m) in months) {
        existing.addAll(await repo.watchShiftsInMonth(y, m, planId: planId).first);
      }

      final conflictingExisting = <Shift>{};
      for (final d in drafts) {
        for (final ex in existing) {
          final exStart = ex.startAt.toLocal();
          final exEnd = ex.endAt.toLocal();
          if (d.startAt.isBefore(exEnd) && exStart.isBefore(d.endAt)) {
            conflictingExisting.add(ex);
          }
        }
      }
      if (conflictingExisting.isNotEmpty) {
        if (mounted) {
          final jobs = await ref.read(activeJobsProvider.future);
          final jobsById = {for (final j in jobs) j.id: j};
          final use24 = ref.read(use24HourFormatProvider);
          if (!mounted) return;
          await showOverlapDialog(
            context,
            conflictingExisting.toList()
              ..sort((a, b) => a.startAt.compareTo(b.startAt)),
            jobsById,
            use24,
          );
        }
        return;
      }
    }

    setState(() => _saving = true);
    try {
      final repo = ref.read(shiftRepositoryProvider);
      final planId = ref.read(activePlanIdProvider);
      final firstDate = drafts.first.startAt;
      await ref.read(undoControllerProvider.notifier).snapshotBefore(
            year: firstDate.year,
            month: firstDate.month,
            planId: planId,
            description: l.recurringSnapshot(drafts.length),
          );
      final created = await repo.createBulk(
        jobId: job.id,
        drafts: drafts,
        planId: planId,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.recurringCreatedCount(created.length))),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _snack('Error: $e');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final asyncJobs = ref.watch(activeJobsProvider);

    return asyncJobs.when(
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => SizedBox(
        height: 200,
        child: Center(child: Text(l.scheduleJobLoadError(e.toString()))),
      ),
      data: (jobs) {
        if (jobs.isEmpty) {
          return SizedBox(
            height: 200,
            child: Center(child: Text(l.scheduleNoJobsHint)),
          );
        }
        if (_selectedJob == null) {
          final preselectedId = ref.read(selectedJobProvider);
          _selectedJob = preselectedId == null
              ? jobs.first
              : jobs.firstWhere((j) => j.id == preselectedId,
                  orElse: () => jobs.first);
        }
        return _buildForm(context, jobs);
      },
    );
  }

  Widget _buildForm(BuildContext context, List<Job> jobs) {
    final l = AppLocalizations.of(context);
    final pairs = _expand();
    final count = pairs.length;

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
                l.recurringTitle,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
            DropdownButtonFormField<Job>(
              initialValue: _selectedJob,
              decoration: InputDecoration(
                labelText: l.recurringJob,
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
            _SectionLabel(l.recurringWeekdays),
            _WeekdayPicker(
              selected: _weekdays,
              onChanged: (set) => setState(() => _weekdays = set),
            ),
            const SizedBox(height: 16),
            _SectionLabel(l.recurringTimeBreak),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.access_time, size: 16),
                    label: Text('${l.shiftSheetStart} ${_fmtTime(_startTime)}'),
                    onPressed: _pickStartTime,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.access_time, size: 16),
                    label: Text('${l.shiftSheetEnd} ${_fmtTime(_endTime)}'),
                    onPressed: _pickEndTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionLabel(l.recurringPeriod),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today_outlined, size: 16),
                    label: Text(_fmtDate(_startDate)),
                    onPressed: _pickStartDate,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text('~'),
                ),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today_outlined, size: 16),
                    label: Text(_fmtDate(_endDate)),
                    onPressed: _pickEndDate,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _breakCtrl,
              decoration: InputDecoration(
                labelText: l.shiftSheetBreak,
                suffixText: 'm',
                border: const OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: false),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                final t = v?.trim() ?? '';
                if (t.isEmpty) return '0+';
                final n = int.tryParse(t);
                if (n == null || n < 0) return '0+';
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _memoCtrl,
              decoration: InputDecoration(
                labelText: l.shiftSheetMemo,
                border: const OutlineInputBorder(),
              ),
              maxLength: 120,
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            _PreviewBar(count: count, max: _kMaxBulkShifts),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving || count == 0 ? null : _save,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l.recurringCreatedCount(count)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}

class _WeekdayPicker extends StatelessWidget {
  const _WeekdayPicker({required this.selected, required this.onChanged});
  final Set<int> selected;
  final ValueChanged<Set<int>> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final labels = [
      l.weekMon,
      l.weekTue,
      l.weekWed,
      l.weekThu,
      l.weekFri,
      l.weekSat,
      l.weekSun,
    ];
    return Wrap(
      spacing: 6,
      children: List.generate(7, (i) {
        final weekday = i + 1;
        final isSelected = selected.contains(weekday);
        return FilterChip(
          label: Text(labels[i]),
          selected: isSelected,
          onSelected: (v) {
            final next = {...selected};
            if (v) {
              next.add(weekday);
            } else {
              next.remove(weekday);
            }
            onChanged(next);
          },
        );
      }),
    );
  }
}

class _PreviewBar extends StatelessWidget {
  const _PreviewBar({required this.count, required this.max});
  final int count;
  final int max;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final overLimit = count > max;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: overLimit
            ? scheme.errorContainer
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            overLimit ? Icons.error_outline : Icons.event_repeat,
            size: 18,
            color: overLimit ? scheme.onErrorContainer : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l.recurringPreview(count, overLimit ? max : 0),
              style: TextStyle(
                color: overLimit ? scheme.onErrorContainer : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
