import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/palette/job_colors.dart';
import '../../data/providers.dart';
import '../../domain/entity/business_size.dart';
import '../../domain/entity/deduction_mode.dart';
import '../../domain/entity/income_type.dart';
import '../../domain/entity/job.dart';

/// Job 생성/편집용 modal bottom sheet.
/// [job]이 null이면 생성, 아니면 편집.
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

  // 고급 필드 (편집 시 옵션 로드 후 채움)
  bool _loadingOptions = false;
  bool _weeklyHolidayAllowance = false;
  bool _nightPremium = false;
  bool _dailyOvertime = false;
  bool _weeklyOvertime = false;
  bool _holidayPremium = false;
  DeductionMode _deductionMode = DeductionMode.none;
  bool _isWorkStudy = false; // IncomeType 매핑
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
      _isWorkStudy = j.incomeType == IncomeType.workStudy;
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final repo = ref.read(jobRepositoryProvider);
    final name = _nameCtrl.text.trim();
    final wage = int.parse(_wageCtrl.text.trim());
    final incomeType = _isWorkStudy ? IncomeType.workStudy : IncomeType.partTime;
    final now = DateTime.now().toUtc();

    try {
      late int jobId;
      if (widget.initial == null) {
        final created = await repo.create(
          name: name,
          hourlyWage: wage,
          incomeType: incomeType,
          businessSize: _businessSize,
          colorArgb: _colorArgb,
        );
        jobId = created.id;
      } else {
        await repo.update(
          widget.initial!.copyWith(
            name: name,
            hourlyWage: wage,
            incomeType: incomeType,
            businessSize: _businessSize,
            colorArgb: _colorArgb,
            updatedAt: now,
          ),
        );
        jobId = widget.initial!.id;
      }

      // 옵션 저장 (defaultsFor와 다른 경우만 의미 있지만 항상 update해도 무방)
      final currentOptions = await repo.watchOptions(jobId).first;
      await repo.updateOptions(
        currentOptions.copyWith(
          weeklyHolidayAllowance: _weeklyHolidayAllowance,
          nightPremium: _nightPremium,
          dailyOvertime: _dailyOvertime,
          weeklyOvertime: _weeklyOvertime,
          holidayPremium: _holidayPremium,
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
              weeklyHolidayAllowance: _weeklyHolidayAllowance,
              nightPremium: _nightPremium,
              dailyOvertime: _dailyOvertime,
              weeklyOvertime: _weeklyOvertime,
              holidayPremium: _holidayPremium,
              deductionMode: _deductionMode,
              isWorkStudy: _isWorkStudy,
              businessSize: _businessSize,
              onWeekly: (v) => setState(() => _weeklyHolidayAllowance = v),
              onNight: (v) => setState(() => _nightPremium = v),
              onDailyOT: (v) => setState(() => _dailyOvertime = v),
              onWeeklyOT: (v) => setState(() => _weeklyOvertime = v),
              onHoliday: (v) => setState(() => _holidayPremium = v),
              onDeduction: (v) => setState(() => _deductionMode = v),
              onWorkStudy: (v) => setState(() => _isWorkStudy = v),
              onBusinessSize: (v) => setState(() => _businessSize = v),
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
    required this.weeklyHolidayAllowance,
    required this.nightPremium,
    required this.dailyOvertime,
    required this.weeklyOvertime,
    required this.holidayPremium,
    required this.deductionMode,
    required this.isWorkStudy,
    required this.businessSize,
    required this.onWeekly,
    required this.onNight,
    required this.onDailyOT,
    required this.onWeeklyOT,
    required this.onHoliday,
    required this.onDeduction,
    required this.onWorkStudy,
    required this.onBusinessSize,
  });

  final bool weeklyHolidayAllowance;
  final bool nightPremium;
  final bool dailyOvertime;
  final bool weeklyOvertime;
  final bool holidayPremium;
  final DeductionMode deductionMode;
  final bool isWorkStudy;
  final BusinessSize businessSize;
  final ValueChanged<bool> onWeekly;
  final ValueChanged<bool> onNight;
  final ValueChanged<bool> onDailyOT;
  final ValueChanged<bool> onWeeklyOT;
  final ValueChanged<bool> onHoliday;
  final ValueChanged<DeductionMode> onDeduction;
  final ValueChanged<bool> onWorkStudy;
  final ValueChanged<BusinessSize> onBusinessSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Theme(
        // ExpansionTile의 분할선 제거
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
          title: const Text('고급 옵션'),
          subtitle: Text(
            '수당, 세금, 사업장 분류 — 기본은 모두 OFF',
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
          ),
          children: [
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
            const Divider(height: 24),
            _SubSectionLabel('근무처 분류'),
            _ToggleTile(
              title: '근로장학금',
              hint: '학교에서 받는 근로장학금이에요. 보통 비과세이고 주휴수당이 없어요. (위 옵션과 독립적으로 동작)',
              value: isWorkStudy,
              onChanged: onWorkStudy,
            ),
            const Divider(height: 24),
            _SubSectionLabel('사업장 규모'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SegmentedButton<BusinessSize>(
                    segments: [
                      for (final s in BusinessSize.values)
                        ButtonSegment(value: s, label: Text(s.label)),
                    ],
                    selected: {businessSize},
                    onSelectionChanged: (s) => onBusinessSize(s.first),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '5인 미만 사업장은 야간·연장·휴일 가산수당이 법적으로 의무가 아니에요. '
                    '위 토글은 그래도 직접 켜고 끌 수 있어요.',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
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

class _SubSectionLabel extends StatelessWidget {
  const _SubSectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
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
