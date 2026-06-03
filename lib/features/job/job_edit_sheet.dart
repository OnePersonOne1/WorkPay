import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/palette/job_colors.dart';
import '../../data/providers.dart';
import '../../domain/entity/business_size.dart';
import '../../domain/entity/deduction_mode.dart';
import '../../domain/entity/income_type.dart';
import '../../domain/entity/job.dart';

/// 근무처 분류 프리셋. 클릭 시 수동 옵션들에 일괄 적용된다.
/// DB에 영구 저장되지 않으며, 시트 세션 동안의 UI 선택 상태일 뿐이다.
enum JobPreset {
  workStudy('근로장학'),
  under5('5인 미만'),
  fiveOrMore('5인 이상');

  const JobPreset(this.label);
  final String label;
}

/// 프리셋이 적용하는 값 묶음.
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

  static _PresetValues of(JobPreset preset) {
    switch (preset) {
      case JobPreset.workStudy:
        return workStudy;
      case JobPreset.under5:
        return under5;
      case JobPreset.fiveOrMore:
        return fiveOrMore;
    }
  }
}

/// Job 생성/편집용 modal bottom sheet.
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

  // 기본 필드
  late int _colorArgb;

  // 프리셋 UI 상태 (영구 저장 X)
  JobPreset? _selectedPreset;

  // 고급 옵션 (실제 저장값)
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
    final opts = await ref
        .read(jobRepositoryProvider)
        .watchOptions(jobId)
        .first;
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

  /// 프리셋 토글. on=true면 선택+적용, on=false면 해제(값 유지).
  void _togglePreset(JobPreset preset, bool on) {
    setState(() {
      if (!on) {
        // 같은 프리셋 재클릭 → 해제만 (값은 그대로)
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

  @override
  Widget build(BuildContext context) {
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
                isEdit ? '근무처 편집' : '근무처 추가',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: '이름',
                hintText: '예: 스타벅스 OO점',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              autofocus: !isEdit,
              maxLength: 60,
              validator: (v) {
                final t = v?.trim() ?? '';
                if (t.isEmpty) return '이름을 입력하세요';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _wageCtrl,
              decoration: const InputDecoration(
                labelText: '시급',
                hintText: '예: 11000',
                border: OutlineInputBorder(),
                suffixText: '원',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                final t = v?.trim() ?? '';
                if (t.isEmpty) return '시급을 입력하세요';
                final n = int.tryParse(t);
                if (n == null) return '숫자만 입력';
                if (n <= 0) return '0보다 커야 합니다';
                return null;
              },
            ),
            const SizedBox(height: 16),
            const _SectionLabel('색상'),
            _ColorPalette(
              selectedArgb: _colorArgb,
              onSelected: (argb) => setState(() => _colorArgb = argb),
            ),
            const SizedBox(height: 16),
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
                    : Text(isEdit ? '저장' : '추가'),
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
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
          title: const Text('고급 옵션'),
          subtitle: Text(
            '근무처 분류로 자동 적용하거나, 항목별로 직접 조정하세요',
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
          ),
          children: [
            // ─────────────────────────────────
            //  근무처 분류 (프리셋)
            // ─────────────────────────────────
            _BigSectionLabel('근무처 분류 (프리셋)'),
            for (final preset in JobPreset.values)
              _PresetTile(
                preset: preset,
                selected: selectedPreset == preset,
                onChanged: (v) => onPresetToggled(preset, v),
              ),
            const Divider(height: 28),
            // ─────────────────────────────────
            //  수동 옵션 변경
            // ─────────────────────────────────
            _BigSectionLabel('수동 옵션 변경'),
            _SubSectionLabel('수당 가산'),
            _ToggleTile(
              title: '주휴수당',
              hint: '주 15시간 이상 근무 시 1일분(통상시급 × 주근로/5, 최대 8h) 추가 지급',
              value: weeklyHolidayAllowance,
              onChanged: onWeekly,
            ),
            _ToggleTile(
              title: '야간 가산수당',
              hint: '22:00 ~ 06:00 근무 시간에 +50% 가산',
              value: nightPremium,
              onChanged: onNight,
            ),
            _ToggleTile(
              title: '일 연장 가산수당',
              hint: '하루 8시간 초과 근무분에 +50% 가산',
              value: dailyOvertime,
              onChanged: onDailyOT,
            ),
            _ToggleTile(
              title: '주 연장 가산수당',
              hint: '주 40시간 초과 근무분에 +50% 가산 (일 연장과 중복 안 됨)',
              value: weeklyOvertime,
              onChanged: onWeeklyOT,
            ),
            _ToggleTile(
              title: '휴일근로 가산수당',
              hint: '휴일 근무에 +50%, 그 중 8시간 초과분은 +100%',
              value: holidayPremium,
              onChanged: onHoliday,
            ),
            const Divider(height: 24),
            _SubSectionLabel('입력 옵션'),
            _ToggleTile(
              title: '정밀 휴게 입력',
              hint: '시프트 입력 시 휴게 분뿐 아니라 휴게 시작 시각도 함께 입력해요',
              value: preciseBreakInput,
              onChanged: onPreciseBreak,
            ),
            const Divider(height: 24),
            _SubSectionLabel('세금·공제'),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
              child: Text(
                '월급에서 떼는 금액. 보통 학교 근로장학은 비과세, 알바 일부는 3.3%, 정규 사업장은 4대보험.',
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 4),
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
                      title: Text(m.label),
                      subtitle: Text(
                        _deductionHint(m),
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _deductionHint(DeductionMode m) {
    switch (m) {
      case DeductionMode.none:
        return '공제 없음';
      case DeductionMode.businessIncome3_3:
        return '월급에서 3.3% 자동 차감 (소득세 3% + 지방소득세 0.3%)';
      case DeductionMode.fourInsurance:
        return '월급에서 약 9.4% 자동 차감 (국민연금·건강·고용 합산)';
    }
  }
}

class _BigSectionLabel extends StatelessWidget {
  const _BigSectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
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

class _SubSectionLabel extends StatelessWidget {
  const _SubSectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _PresetTile extends StatelessWidget {
  const _PresetTile({
    required this.preset,
    required this.selected,
    required this.onChanged,
  });
  final JobPreset preset;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: selected,
      onChanged: onChanged,
      title: Text(preset.label),
      subtitle: Text(
        'On하면 프리셋이 자동 적용돼요',
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      dense: true,
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.title,
    required this.hint,
    required this.value,
    required this.onChanged,
  });
  final String title;
  final String hint;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title),
      subtitle: Text(
        hint,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      dense: true,
    );
  }
}
