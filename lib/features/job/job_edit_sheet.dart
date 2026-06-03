import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/palette/job_colors.dart';
import '../../data/providers.dart';
import '../../domain/entity/business_size.dart';
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
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(ctx).viewInsets.bottom,
      ),
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
  late IncomeType _incomeType;
  late BusinessSize _businessSize;
  late int _colorArgb;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final j = widget.initial;
    _nameCtrl = TextEditingController(text: j?.name ?? '');
    _wageCtrl = TextEditingController(
      text: j == null ? '' : j.hourlyWage.toString(),
    );
    _incomeType = j?.incomeType ?? IncomeType.partTime;
    _businessSize = j?.businessSize ?? BusinessSize.under5;
    _colorArgb = j?.colorArgb ?? JobColors.defaultArgb();
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
    try {
      if (widget.initial == null) {
        await repo.create(
          name: name,
          hourlyWage: wage,
          incomeType: _incomeType,
          businessSize: _businessSize,
          colorArgb: _colorArgb,
        );
      } else {
        await repo.update(
          widget.initial!.copyWith(
            name: name,
            hourlyWage: wage,
            incomeType: _incomeType,
            businessSize: _businessSize,
            colorArgb: _colorArgb,
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

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
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
                labelText: '시급 (원)',
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
            _SectionLabel('소득 유형'),
            _IncomeTypeSelector(
              value: _incomeType,
              onChanged: (v) => setState(() => _incomeType = v),
            ),
            const SizedBox(height: 16),
            _SectionLabel('사업장 규모'),
            _BusinessSizeSelector(
              value: _businessSize,
              onChanged: (v) => setState(() => _businessSize = v),
            ),
            const SizedBox(height: 16),
            _SectionLabel('색상'),
            _ColorPalette(
              selectedArgb: _colorArgb,
              onSelected: (argb) => setState(() => _colorArgb = argb),
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

class _IncomeTypeSelector extends StatelessWidget {
  const _IncomeTypeSelector({required this.value, required this.onChanged});
  final IncomeType value;
  final ValueChanged<IncomeType> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<IncomeType>(
      segments: [
        for (final t in IncomeType.values)
          ButtonSegment(value: t, label: Text(t.label)),
      ],
      selected: {value},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

class _BusinessSizeSelector extends StatelessWidget {
  const _BusinessSizeSelector({required this.value, required this.onChanged});
  final BusinessSize value;
  final ValueChanged<BusinessSize> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<BusinessSize>(
      segments: [
        for (final s in BusinessSize.values)
          ButtonSegment(value: s, label: Text(s.label)),
      ],
      selected: {value},
      onSelectionChanged: (s) => onChanged(s.first),
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
