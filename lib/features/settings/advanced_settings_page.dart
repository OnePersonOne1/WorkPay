import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../domain/payroll/payroll_constants.dart';
import 'settings_providers.dart';

/// PayrollConstants override 편집 화면 ("고고급 옵션").
class AdvancedSettingsPage extends ConsumerStatefulWidget {
  const AdvancedSettingsPage({super.key});

  @override
  ConsumerState<AdvancedSettingsPage> createState() => _State();
}

class _State extends ConsumerState<AdvancedSettingsPage> {
  late PayrollConstants _edited;
  bool _loaded = false;
  bool _saving = false;

  void _ensureLoaded() {
    if (_loaded) return;
    final c = ref.read(_initialConstantsProvider);
    _edited = c;
    _loaded = true;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final repo = ref.read(appSettingsRepositoryProvider);
      final settings = await repo.read();
      await repo.update(
        settings.copyWith(
          payrollConstantsJson: jsonEncode(_edited.toJson()),
          updatedAt: DateTime.now().toUtc(),
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('고고급 설정 저장됨')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: $e')),
      );
    }
  }

  Future<void> _resetToDefault() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('기본값으로 초기화'),
        content: const Text('모든 항목을 한국 노동법 기본값으로 되돌릴까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('초기화'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    if (!mounted) return;
    setState(() => _saving = true);
    try {
      final repo = ref.read(appSettingsRepositoryProvider);
      final settings = await repo.read();
      await repo.update(
        settings.copyWith(
          clearPayrollConstantsJson: true,
          updatedAt: DateTime.now().toUtc(),
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('기본값으로 초기화됨')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('초기화 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _ensureLoaded();
    return Scaffold(
      appBar: AppBar(
        title: const Text('고고급 설정'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _resetToDefault,
            child: const Text('초기화'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          _Note(),
          const SizedBox(height: 12),
          const _SectionHeader('시간대 / 기준'),
          _TimeOfDayField(
            label: '야간 시작',
            minuteOfDay: _edited.nightStartMinuteOfDay,
            onChanged: (v) => setState(
                () => _edited = _edited.copyWith(nightStartMinuteOfDay: v)),
          ),
          _TimeOfDayField(
            label: '야간 종료',
            minuteOfDay: _edited.nightEndMinuteOfDay,
            onChanged: (v) => setState(
                () => _edited = _edited.copyWith(nightEndMinuteOfDay: v)),
          ),
          _HoursField(
            label: '일 연장 기준',
            minutes: _edited.dailyOvertimeThresholdMinutes,
            onChanged: (v) => setState(() =>
                _edited = _edited.copyWith(dailyOvertimeThresholdMinutes: v)),
            hint: '하루 이 시간을 초과하면 일 연장근로',
          ),
          _HoursField(
            label: '주 연장 기준',
            minutes: _edited.weeklyOvertimeThresholdMinutes,
            onChanged: (v) => setState(() => _edited =
                _edited.copyWith(weeklyOvertimeThresholdMinutes: v)),
            hint: '한 주에 이 시간을 초과하면 주 연장근로',
          ),
          _HoursField(
            label: '주휴수당 자격 시간',
            minutes: _edited.weeklyHolidayThresholdMinutes,
            onChanged: (v) => setState(() => _edited =
                _edited.copyWith(weeklyHolidayThresholdMinutes: v)),
            hint: '한 주 근무가 이 시간 이상이면 주휴수당 지급',
          ),
          const SizedBox(height: 16),
          const _SectionHeader('가산율'),
          _PercentField(
            label: '야간 가산율',
            rateBp: _edited.nightPremiumRateBp,
            onChanged: (v) => setState(
                () => _edited = _edited.copyWith(nightPremiumRateBp: v)),
          ),
          _PercentField(
            label: '일 연장 가산율',
            rateBp: _edited.dailyOvertimePremiumRateBp,
            onChanged: (v) => setState(() =>
                _edited = _edited.copyWith(dailyOvertimePremiumRateBp: v)),
          ),
          _PercentField(
            label: '주 연장 가산율',
            rateBp: _edited.weeklyOvertimePremiumRateBp,
            onChanged: (v) => setState(() =>
                _edited = _edited.copyWith(weeklyOvertimePremiumRateBp: v)),
          ),
          _PercentField(
            label: '휴일근로 8h 이내 가산율',
            rateBp: _edited.holidayPremiumWithinDailyThresholdRateBp,
            onChanged: (v) => setState(() => _edited = _edited.copyWith(
                holidayPremiumWithinDailyThresholdRateBp: v)),
          ),
          _PercentField(
            label: '휴일근로 8h 초과 가산율',
            rateBp: _edited.holidayPremiumOverDailyThresholdRateBp,
            onChanged: (v) => setState(() => _edited = _edited.copyWith(
                holidayPremiumOverDailyThresholdRateBp: v)),
          ),
          const SizedBox(height: 16),
          const _SectionHeader('기타'),
          _PercentField(
            label: '사업소득 원천징수율',
            rateBp: _edited.businessIncomeWithholdingRateBp,
            onChanged: (v) => setState(() =>
                _edited = _edited.copyWith(businessIncomeWithholdingRateBp: v)),
          ),
          _WeekStartField(
            value: _edited.weekStartsOn,
            onChanged: (v) =>
                setState(() => _edited = _edited.copyWith(weekStartsOn: v)),
          ),
          SwitchListTile(
            title: const Text('일요일을 휴일로 처리'),
            subtitle: const Text(
              'OFF면 공휴일만 휴일. 일요일은 평일 취급',
              style: TextStyle(fontSize: 12),
            ),
            value: _edited.sundayIsHoliday,
            onChanged: (v) =>
                setState(() => _edited = _edited.copyWith(sundayIsHoliday: v)),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton(
            onPressed: _saving ? null : _save,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('저장'),
            ),
          ),
        ),
      ),
    );
  }
}

/// 초기 상수 (현재 저장된 값) — read만, 변경 안 됨.
final _initialConstantsProvider = Provider<PayrollConstants>((ref) {
  final async = ref.watch(appSettingsProvider);
  return async.maybeWhen(
    data: (s) {
      final raw = s.payrollConstantsJson;
      if (raw == null || raw.isEmpty) return PayrollConstants.koreanDefault();
      try {
        return PayrollConstants.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
      } catch (_) {
        return PayrollConstants.koreanDefault();
      }
    },
    orElse: () => PayrollConstants.koreanDefault(),
  );
});

class _Note extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: scheme.onTertiaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '한국 노동법(2025) 기본값에서 수정하지 않는 한 변경 불필요. '
              '근무처별 가산 토글과는 별개로 적용되는 글로벌 상수입니다.',
              style: TextStyle(
                color: scheme.onTertiaryContainer,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);
  final String label;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _TimeOfDayField extends StatelessWidget {
  const _TimeOfDayField({
    required this.label,
    required this.minuteOfDay,
    required this.onChanged,
  });
  final String label;
  final int minuteOfDay;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final h = minuteOfDay ~/ 60;
    final m = minuteOfDay % 60;
    final timeStr =
        '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: TextButton(
        onPressed: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay(hour: h, minute: m),
          );
          if (picked != null) {
            onChanged(picked.hour * 60 + picked.minute);
          }
        },
        child: Text(timeStr),
      ),
    );
  }
}

class _HoursField extends StatefulWidget {
  const _HoursField({
    required this.label,
    required this.minutes,
    required this.onChanged,
    this.hint,
  });
  final String label;
  final int minutes;
  final ValueChanged<int> onChanged;
  final String? hint;

  @override
  State<_HoursField> createState() => _HoursFieldState();
}

class _HoursFieldState extends State<_HoursField> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: (widget.minutes / 60).toStringAsFixed(
        widget.minutes % 60 == 0 ? 0 : 2,
      ),
    );
  }

  @override
  void didUpdateWidget(_HoursField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.minutes != widget.minutes) {
      final newText = (widget.minutes / 60).toStringAsFixed(
        widget.minutes % 60 == 0 ? 0 : 2,
      );
      if (_ctrl.text != newText) _ctrl.text = newText;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextFormField(
        controller: _ctrl,
        decoration: InputDecoration(
          labelText: widget.label,
          helperText: widget.hint,
          suffixText: '시간',
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}(\.\d{0,2})?')),
        ],
        onChanged: (v) {
          final hours = double.tryParse(v);
          if (hours == null || hours < 0) return;
          widget.onChanged((hours * 60).round());
        },
      ),
    );
  }
}

class _PercentField extends StatefulWidget {
  const _PercentField({
    required this.label,
    required this.rateBp,
    required this.onChanged,
  });
  final String label;
  final int rateBp;
  final ValueChanged<int> onChanged;

  @override
  State<_PercentField> createState() => _PercentFieldState();
}

class _PercentFieldState extends State<_PercentField> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: _toText(widget.rateBp));
  }

  @override
  void didUpdateWidget(_PercentField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rateBp != widget.rateBp) {
      final t = _toText(widget.rateBp);
      if (_ctrl.text != t) _ctrl.text = t;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  static String _toText(int bp) {
    final pct = bp / 100; // 5000bp = 50.00%
    return pct.toStringAsFixed(bp % 100 == 0 ? 0 : 2);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextFormField(
        controller: _ctrl,
        decoration: InputDecoration(
          labelText: widget.label,
          suffixText: '%',
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d{0,4}(\.\d{0,2})?')),
        ],
        onChanged: (v) {
          final pct = double.tryParse(v);
          if (pct == null || pct < 0) return;
          widget.onChanged((pct * 100).round());
        },
      ),
    );
  }
}

class _WeekStartField extends StatelessWidget {
  const _WeekStartField({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: DropdownButtonFormField<int>(
        initialValue: value,
        decoration: const InputDecoration(
          labelText: '주 시작 요일',
          border: OutlineInputBorder(),
          isDense: true,
        ),
        items: const [
          DropdownMenuItem(value: DateTime.monday, child: Text('월요일')),
          DropdownMenuItem(value: DateTime.sunday, child: Text('일요일')),
        ],
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}
