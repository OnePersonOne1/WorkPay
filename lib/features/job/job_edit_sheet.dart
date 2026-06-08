// SPDX-License-Identifier: GPL-3.0-only
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/palette/job_colors.dart';
import '../../data/providers.dart';
import '../../domain/entity/business_size.dart';
import '../../domain/entity/deduction_mode.dart';
import '../../domain/entity/income_type.dart';
import '../../domain/entity/job.dart';
import '../../l10n/enum_labels.dart';
import '../../l10n/generated/app_localizations.dart';
import '../settings/settings_providers.dart';

/// 근무처 분류 프리셋. UI 임시 상태.
enum JobPreset { workStudy, under5, fiveOrMore }

class _PresetValues {
  const _PresetValues({
    required this.incomeType,
    required this.businessSize,
    required this.weeklyHolidayAllowance,
    required this.nightPremium,
    required this.dailyOvertime,
    required this.weeklyOvertime,
    required this.holidayPremium,
    required this.deductionMode,
  });

  final IncomeType incomeType;
  final BusinessSize businessSize;
  final bool weeklyHolidayAllowance;
  final bool nightPremium;
  final bool dailyOvertime;
  final bool weeklyOvertime;
  final bool holidayPremium;
  final DeductionMode deductionMode;

  static const _PresetValues workStudy = _PresetValues(
    incomeType: IncomeType.workStudy,
    businessSize: BusinessSize.under5,
    weeklyHolidayAllowance: false,
    nightPremium: false,
    dailyOvertime: false,
    weeklyOvertime: false,
    holidayPremium: false,
    deductionMode: DeductionMode.none,
  );

  static const _PresetValues under5 = _PresetValues(
    incomeType: IncomeType.partTime,
    businessSize: BusinessSize.under5,
    weeklyHolidayAllowance: true,
    nightPremium: false,
    dailyOvertime: false,
    weeklyOvertime: false,
    holidayPremium: false,
    deductionMode: DeductionMode.none,
  );

  static const _PresetValues fiveOrMore = _PresetValues(
    incomeType: IncomeType.partTime,
    businessSize: BusinessSize.fiveOrMore,
    weeklyHolidayAllowance: true,
    nightPremium: true,
    dailyOvertime: true,
    weeklyOvertime: true,
    holidayPremium: true,
    deductionMode: DeductionMode.fourInsurance,
  );

  static _PresetValues of(JobPreset preset) => switch (preset) {
        JobPreset.workStudy => workStudy,
        JobPreset.under5 => under5,
        JobPreset.fiveOrMore => fiveOrMore,
      };
}

String _presetLabel(JobPreset p, AppLocalizations l) => switch (p) {
      JobPreset.workStudy => l.incomeWorkStudy,
      JobPreset.under5 => l.businessUnder5,
      JobPreset.fiveOrMore => l.businessFiveOrMore,
    };

Future<bool?> showJobEditSheet(BuildContext context, {Job? job}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: _JobEditSheet(initial: job),
    ),
  );
}

class _JobEditSheet extends ConsumerStatefulWidget {
  const _JobEditSheet({this.initial});
  final Job? initial;

  @override
  ConsumerState<_JobEditSheet> createState() => _JobEditSheetState();
}

class _JobEditSheetState extends ConsumerState<_JobEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _wageCtrl;

  late int _colorArgb;
  JobPreset? _selectedPreset;

  bool _loadingOptions = false;
  bool _weeklyHolidayAllowance = false;
  bool _nightPremium = false;
  bool _dailyOvertime = false;
  bool _weeklyOvertime = false;
  bool _holidayPremium = false;
  bool _preciseBreakInput = false;
  DeductionMode _deductionMode = DeductionMode.none;
  IncomeType _incomeType = IncomeType.partTime;
  BusinessSize _businessSize = BusinessSize.under5;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final j = widget.initial;
    _nameCtrl = TextEditingController(text: j?.name ?? '');
    _wageCtrl = TextEditingController(
      text: j == null ? '' : j.hourlyWage.toString(),
    );
    _colorArgb = j?.colorArgb ?? JobColors.defaultArgb();
    if (j != null) {
      _incomeType = j.incomeType;
      _businessSize = j.businessSize;
      _loadingOptions = true;
      _loadOptions(j.id);
    }
  }

  Future<void> _loadOptions(int jobId) async {
    final opts =
        await ref.read(jobRepositoryProvider).watchOptions(jobId).first;
    if (!mounted) return;
    setState(() {
      _weeklyHolidayAllowance = opts.weeklyHolidayAllowance;
      _nightPremium = opts.nightPremium;
      _dailyOvertime = opts.dailyOvertime;
      _weeklyOvertime = opts.weeklyOvertime;
      _holidayPremium = opts.holidayPremium;
      _preciseBreakInput = opts.preciseBreakInput;
      _deductionMode = opts.deductionMode;
      _loadingOptions = false;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _wageCtrl.dispose();
    super.dispose();
  }

  void _togglePreset(JobPreset preset, bool on) {
    setState(() {
      if (!on) {
        if (_selectedPreset == preset) _selectedPreset = null;
        return;
      }
      _selectedPreset = preset;
      final v = _PresetValues.of(preset);
      _incomeType = v.incomeType;
      _businessSize = v.businessSize;
      _weeklyHolidayAllowance = v.weeklyHolidayAllowance;
      _nightPremium = v.nightPremium;
      _dailyOvertime = v.dailyOvertime;
      _weeklyOvertime = v.weeklyOvertime;
      _holidayPremium = v.holidayPremium;
      _deductionMode = v.deductionMode;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final l = AppLocalizations.of(context);
    final repo = ref.read(jobRepositoryProvider);
    final name = _nameCtrl.text.trim();
    final wage = int.parse(_wageCtrl.text.trim());
    final now = DateTime.now().toUtc();

    try {
      late int jobId;
      if (widget.initial == null) {
        final created = await repo.create(
          name: name,
          hourlyWage: wage,
          incomeType: _incomeType,
          businessSize: _businessSize,
          colorArgb: _colorArgb,
        );
        jobId = created.id;
      } else {
        await repo.update(
          widget.initial!.copyWith(
            name: name,
            hourlyWage: wage,
            incomeType: _incomeType,
            businessSize: _businessSize,
            colorArgb: _colorArgb,
            updatedAt: now,
          ),
        );
        jobId = widget.initial!.id;
      }
      final currentOptions = await repo.watchOptions(jobId).first;
      await repo.updateOptions(
        currentOptions.copyWith(
          weeklyHolidayAllowance: _weeklyHolidayAllowance,
          nightPremium: _nightPremium,
          dailyOvertime: _dailyOvertime,
          weeklyOvertime: _weeklyOvertime,
          holidayPremium: _holidayPremium,
          preciseBreakInput: _preciseBreakInput,
          deductionMode: _deductionMode,
          updatedAt: now,
        ),
      );
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.jobSheetSaved(name))),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final laborLawOn = ref.watch(koreanLaborLawComplianceProvider);
    final isEdit = widget.initial != null;
    if (_loadingOptions) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }
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
                isEdit ? l.jobSheetTitleEdit : l.jobSheetTitleNew,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: l.jobSheetName,
                hintText: l.jobSheetNameHint,
                border: const OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              autofocus: !isEdit,
              maxLength: 60,
              validator: (v) {
                final t = v?.trim() ?? '';
                if (t.isEmpty) return l.jobSheetNameRequired;
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _wageCtrl,
              decoration: InputDecoration(
                labelText: l.jobSheetWage,
                border: const OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: false),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                final t = v?.trim() ?? '';
                if (t.isEmpty) return l.jobSheetWageRequired;
                final n = int.tryParse(t);
                if (n == null) return l.jobSheetWageInvalid;
                if (n <= 0) return l.jobSheetWageInvalid;
                return null;
              },
            ),
            const SizedBox(height: 16),
            _SectionLabel(l.jobSheetColor),
            _ColorPalette(
              selectedArgb: _colorArgb,
              onSelected: (argb) => setState(() => _colorArgb = argb),
            ),
            const SizedBox(height: 16),
            // 노동법 OFF면 고급 옵션 섹션 자체를 숨김.
            if (laborLawOn)
              _AdvancedSection(
                selectedPreset: _selectedPreset,
                onPresetToggled: _togglePreset,
                weeklyHolidayAllowance: _weeklyHolidayAllowance,
                nightPremium: _nightPremium,
                dailyOvertime: _dailyOvertime,
                weeklyOvertime: _weeklyOvertime,
                holidayPremium: _holidayPremium,
                preciseBreakInput: _preciseBreakInput,
                deductionMode: _deductionMode,
                onWeekly: (v) => setState(() => _weeklyHolidayAllowance = v),
                onNight: (v) => setState(() => _nightPremium = v),
                onDailyOT: (v) => setState(() => _dailyOvertime = v),
                onWeeklyOT: (v) => setState(() => _weeklyOvertime = v),
                onHoliday: (v) => setState(() => _holidayPremium = v),
                onPreciseBreak: (v) => setState(() => _preciseBreakInput = v),
                onDeduction: (v) => setState(() => _deductionMode = v),
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isEdit ? l.actionSave : l.actionAdd),
              ),
            ),
          ],
        ),
      ),
    );
  }
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

class _ColorPalette extends StatelessWidget {
  const _ColorPalette({
    required this.selectedArgb,
    required this.onSelected,
  });
  final int selectedArgb;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final color in JobColors.palette)
          _ColorDot(
            color: color,
            selected: color.toARGB32() == selectedArgb,
            onTap: () => onSelected(color.toARGB32()),
          ),
      ],
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: selected
              ? Border.all(
                  color: Theme.of(context).colorScheme.onSurface,
                  width: 3,
                )
              : null,
        ),
        child: selected
            ? const Icon(Icons.check, color: Colors.white, size: 20)
            : null,
      ),
    );
  }
}

class _AdvancedSection extends StatelessWidget {
  const _AdvancedSection({
    required this.selectedPreset,
    required this.onPresetToggled,
    required this.weeklyHolidayAllowance,
    required this.nightPremium,
    required this.dailyOvertime,
    required this.weeklyOvertime,
    required this.holidayPremium,
    required this.preciseBreakInput,
    required this.deductionMode,
    required this.onWeekly,
    required this.onNight,
    required this.onDailyOT,
    required this.onWeeklyOT,
    required this.onHoliday,
    required this.onPreciseBreak,
    required this.onDeduction,
  });

  final JobPreset? selectedPreset;
  final void Function(JobPreset preset, bool on) onPresetToggled;
  final bool weeklyHolidayAllowance;
  final bool nightPremium;
  final bool dailyOvertime;
  final bool weeklyOvertime;
  final bool holidayPremium;
  final bool preciseBreakInput;
  final DeductionMode deductionMode;
  final ValueChanged<bool> onWeekly;
  final ValueChanged<bool> onNight;
  final ValueChanged<bool> onDailyOT;
  final ValueChanged<bool> onWeeklyOT;
  final ValueChanged<bool> onHoliday;
  final ValueChanged<bool> onPreciseBreak;
  final ValueChanged<DeductionMode> onDeduction;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
          title: Text(l.jobsAdvancedOptions),
          children: [
            for (final preset in JobPreset.values)
              SwitchListTile(
                value: selectedPreset == preset,
                onChanged: (v) => onPresetToggled(preset, v),
                title: Text(_presetLabel(preset, l)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                dense: true,
              ),
            const Divider(height: 28),
            _ToggleTile(
              title: l.jobAdvWeeklyHoliday,
              value: weeklyHolidayAllowance,
              onChanged: onWeekly,
            ),
            _ToggleTile(
              title: l.jobAdvNightPremium,
              value: nightPremium,
              onChanged: onNight,
            ),
            _ToggleTile(
              title: l.jobAdvDailyOvertime,
              value: dailyOvertime,
              onChanged: onDailyOT,
            ),
            _ToggleTile(
              title: l.jobAdvWeeklyOvertime,
              value: weeklyOvertime,
              onChanged: onWeeklyOT,
            ),
            _ToggleTile(
              title: l.jobAdvHolidayPremium,
              value: holidayPremium,
              onChanged: onHoliday,
            ),
            const Divider(height: 24),
            _ToggleTile(
              title: l.jobAdvPreciseBreak,
              value: preciseBreakInput,
              onChanged: onPreciseBreak,
            ),
            const Divider(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                l.jobAdvDeductionMode,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            RadioGroup<DeductionMode>(
              groupValue: deductionMode,
              onChanged: (v) {
                if (v != null) onDeduction(v);
              },
              child: Column(
                children: [
                  for (final m in DeductionMode.values)
                    RadioListTile<DeductionMode>(
                      value: m,
                      title: Text(deductionModeLabel(m, l)),
                      dense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 8),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      dense: true,
    );
  }
}
