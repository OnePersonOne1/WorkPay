// SPDX-License-Identifier: GPL-3.0-only
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/time/time_format.dart';
import '../../core/time/time_picker_dialog.dart';
import '../../data/providers.dart';
import '../../domain/payroll/payroll_constants.dart';
import '../../l10n/generated/app_localizations.dart';
import 'settings_providers.dart';

/// PayrollConstants override 편집 화면.
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
    final l = AppLocalizations.of(context);
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
        SnackBar(content: Text(l.advancedSaved)),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _resetToDefault() async {
    final l = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final lc = AppLocalizations.of(ctx);
        return AlertDialog(
          title: Text(lc.advancedReset),
          content: Text(lc.advancedHelp),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(lc.actionCancel),
            ),
            FilledButton.tonal(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(lc.advancedReset),
            ),
          ],
        );
      },
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
        SnackBar(content: Text(l.advancedResetDone)),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _ensureLoaded();
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.advancedTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          _Note(),
          const SizedBox(height: 12),
          _ResetTile(onPressed: _saving ? null : _resetToDefault),
          const SizedBox(height: 8),
          _SectionHeader(l.advancedSectionThresholds),
          _TimeOfDayField(
            label: l.advancedNightStart,
            minuteOfDay: _edited.nightStartMinuteOfDay,
            onChanged: (v) => setState(
                () => _edited = _edited.copyWith(nightStartMinuteOfDay: v)),
          ),
          _TimeOfDayField(
            label: l.advancedNightEnd,
            minuteOfDay: _edited.nightEndMinuteOfDay,
            onChanged: (v) => setState(
                () => _edited = _edited.copyWith(nightEndMinuteOfDay: v)),
          ),
          _HoursField(
            label: l.advancedDailyOTThreshold,
            minutes: _edited.dailyOvertimeThresholdMinutes,
            onChanged: (v) => setState(() =>
                _edited = _edited.copyWith(dailyOvertimeThresholdMinutes: v)),
          ),
          _HoursField(
            label: l.advancedWeeklyOTThreshold,
            minutes: _edited.weeklyOvertimeThresholdMinutes,
            onChanged: (v) => setState(() => _edited =
                _edited.copyWith(weeklyOvertimeThresholdMinutes: v)),
          ),
          _HoursField(
            label: l.advancedWeeklyHolidayHours,
            minutes: _edited.weeklyHolidayThresholdMinutes,
            onChanged: (v) => setState(() => _edited =
                _edited.copyWith(weeklyHolidayThresholdMinutes: v)),
          ),
          const SizedBox(height: 16),
          _SectionHeader(l.advancedSectionPremiums),
          _PercentField(
            label: l.advancedNightPremiumPct,
            rateBp: _edited.nightPremiumRateBp,
            onChanged: (v) => setState(
                () => _edited = _edited.copyWith(nightPremiumRateBp: v)),
          ),
          _PercentField(
            label: l.advancedDailyOTPremiumPct,
            rateBp: _edited.dailyOvertimePremiumRateBp,
            onChanged: (v) => setState(() =>
                _edited = _edited.copyWith(dailyOvertimePremiumRateBp: v)),
          ),
          _PercentField(
            label: l.advancedWeeklyOTPremiumPct,
            rateBp: _edited.weeklyOvertimePremiumRateBp,
            onChanged: (v) => setState(() =>
                _edited = _edited.copyWith(weeklyOvertimePremiumRateBp: v)),
          ),
          _PercentField(
            label: l.advancedHolidayBasePct,
            rateBp: _edited.holidayPremiumWithinDailyThresholdRateBp,
            onChanged: (v) => setState(() => _edited = _edited.copyWith(
                holidayPremiumWithinDailyThresholdRateBp: v)),
          ),
          _PercentField(
            label: l.advancedHolidayOverPct,
            rateBp: _edited.holidayPremiumOverDailyThresholdRateBp,
            onChanged: (v) => setState(() => _edited = _edited.copyWith(
                holidayPremiumOverDailyThresholdRateBp: v)),
          ),
          const SizedBox(height: 16),
          _SectionHeader(l.advancedSectionDeductions),
          _PercentField(
            label: l.advancedBusinessIncomePct,
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
            title: Text(l.weekSun),
            value: _edited.sundayIsHoliday,
            onChanged: (v) =>
                setState(() => _edited = _edited.copyWith(sundayIsHoliday: v)),
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            title: Text(l.shiftSheetOverlapTitle),
            value: _edited.allowShiftOverlap,
            onChanged: (v) =>
                setState(() => _edited = _edited.copyWith(allowShiftOverlap: v)),
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
                  : Text(l.actionSave),
            ),
          ),
        ),
      ),
    );
  }
}

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
    final l = AppLocalizations.of(context);
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
              l.advancedHelp,
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

class _ResetTile extends StatelessWidget {
  const _ResetTile({required this.onPressed});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: const Icon(Icons.restart_alt),
        title: Text(l.advancedReset),
        trailing: const Icon(Icons.chevron_right),
        onTap: onPressed,
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

class _TimeOfDayField extends ConsumerWidget {
  const _TimeOfDayField({
    required this.label,
    required this.minuteOfDay,
    required this.onChanged,
  });
  final String label;
  final int minuteOfDay;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final h = minuteOfDay ~/ 60;
    final m = minuteOfDay % 60;
    final l = AppLocalizations.of(context);
    final use24 = ref.watch(use24HourFormatProvider);
    final timeStr = formatHM(
      DateTime(2026, 1, 1, h, m),
      use24Hour: use24,
      am: l.amSuffix,
      pm: l.pmSuffix,
    );
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: TextButton(
        onPressed: () async {
          final picked = await pickTimeDialog(
            context,
            initial: TimeOfDay(hour: h, minute: m),
            use24Hour: use24,
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
  });
  final String label;
  final int minutes;
  final ValueChanged<int> onChanged;

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
          suffixText: 'h',
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
    final pct = bp / 100;
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
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: DropdownButtonFormField<int>(
        initialValue: value,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
        ),
        items: [
          DropdownMenuItem(value: DateTime.monday, child: Text(l.weekMon)),
          DropdownMenuItem(value: DateTime.sunday, child: Text(l.weekSun)),
        ],
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}
