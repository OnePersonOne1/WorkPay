import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/palette/job_colors.dart';
import '../../data/providers.dart';
import '../../domain/entity/job.dart';
import '../../domain/repository/shift_repository.dart';
import '../job/job_providers.dart';
import 'schedule_providers.dart';

const int _kMaxBulkShifts = 366; // 안전장치: 1년치 상한

/// 반복 시프트 일괄 입력 modal sheet.
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

  /// 패턴을 (startAt, endAt) 페어 목록으로 펼친다 (로컬 시각 기준).
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
        // 자정 넘김
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
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (picked == null) return;
    setState(() => _startTime = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (picked == null) return;
    setState(() => _endTime = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final job = _selectedJob;
    if (job == null) {
      _snack('근무처를 선택하세요');
      return;
    }
    if (_weekdays.isEmpty) {
      _snack('반복할 요일을 1개 이상 선택하세요');
      return;
    }
    final pairs = _expand();
    if (pairs.isEmpty) {
      _snack('선택한 기간/요일에 매칭되는 날짜가 없습니다');
      return;
    }
    if (pairs.length > _kMaxBulkShifts) {
      _snack('한 번에 만들 수 있는 최대 시프트는 $_kMaxBulkShifts개입니다 (현재 ${pairs.length}개)');
      return;
    }
    final breakMinutes = int.parse(_breakCtrl.text.trim());
    final firstDuration =
        pairs.first.endAt.difference(pairs.first.startAt).inMinutes;
    if (breakMinutes >= firstDuration) {
      _snack('휴게가 근무 시간보다 깁니다');
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

    setState(() => _saving = true);
    try {
      final repo = ref.read(shiftRepositoryProvider);
      final created = await repo.createBulk(jobId: job.id, drafts: drafts);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('시프트 ${created.length}개 추가됨')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _snack('추가 실패: $e');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
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
        if (jobs.isEmpty) {
          return const SizedBox(
            height: 200,
            child: Center(child: Text('근무처가 없어요. 먼저 근무처를 추가하세요.')),
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
                '반복 시프트 추가',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
            // 근무처
            DropdownButtonFormField<Job>(
              initialValue: _selectedJob,
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
            // 요일 다중 선택
            const _SectionLabel('반복 요일'),
            _WeekdayPicker(
              selected: _weekdays,
              onChanged: (set) => setState(() => _weekdays = set),
            ),
            const SizedBox(height: 16),
            // 시각
            const _SectionLabel('시각'),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.access_time, size: 16),
                    label: Text('시작 ${_fmtTime(_startTime)}'),
                    onPressed: _pickStartTime,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.access_time, size: 16),
                    label: Text('종료 ${_fmtTime(_endTime)}'),
                    onPressed: _pickEndTime,
                  ),
                ),
              ],
            ),
            if (!_endIsAfterStart())
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  '종료가 시작 이전 — 자정을 넘기는 시프트로 처리됩니다',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            // 기간
            const _SectionLabel('기간'),
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
            // 휴게 + 메모
            TextFormField(
              controller: _breakCtrl,
              decoration: const InputDecoration(
                labelText: '휴게 시간',
                suffixText: '분',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                final t = v?.trim() ?? '';
                if (t.isEmpty) return '0 이상 입력';
                final n = int.tryParse(t);
                if (n == null || n < 0) return '0 이상의 숫자';
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _memoCtrl,
              decoration: const InputDecoration(
                labelText: '메모 (모든 시프트에 공통, 선택)',
                border: OutlineInputBorder(),
              ),
              maxLength: 120,
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            // 미리보기
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
                    : Text('$count개 시프트 일괄 추가'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _endIsAfterStart() {
    final startMin = _startTime.hour * 60 + _startTime.minute;
    final endMin = _endTime.hour * 60 + _endTime.minute;
    return endMin > startMin;
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

  static const _labels = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      children: List.generate(7, (i) {
        final weekday = i + 1; // 1=월
        final isSelected = selected.contains(weekday);
        return FilterChip(
          label: Text(_labels[i]),
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
              overLimit
                  ? '$count개 — 한 번에 $max개를 초과합니다. 기간을 줄이세요.'
                  : count == 0
                      ? '조건에 매칭되는 날짜가 없어요'
                      : '이 패턴으로 $count개 시프트가 만들어져요',
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
