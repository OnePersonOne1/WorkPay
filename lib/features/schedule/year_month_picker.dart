import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 년/월 선택 dialog — 숫자 입력 + 월 grid 동시 제공.
///
/// 반환: (year, month) 또는 null (취소).
Future<DateTime?> pickYearMonth(
  BuildContext context, {
  required DateTime initial,
  int firstYear = 2020,
  int lastYear = 2099,
}) {
  return showDialog<DateTime>(
    context: context,
    builder: (ctx) => _YearMonthPickerDialog(
      initial: initial,
      firstYear: firstYear,
      lastYear: lastYear,
    ),
  );
}

class _YearMonthPickerDialog extends StatefulWidget {
  const _YearMonthPickerDialog({
    required this.initial,
    required this.firstYear,
    required this.lastYear,
  });

  final DateTime initial;
  final int firstYear;
  final int lastYear;

  @override
  State<_YearMonthPickerDialog> createState() => _State();
}

class _State extends State<_YearMonthPickerDialog> {
  late int _year;
  late int _month;
  late TextEditingController _yearCtrl;
  late TextEditingController _monthCtrl;

  @override
  void initState() {
    super.initState();
    _year = widget.initial.year;
    _month = widget.initial.month;
    _yearCtrl = TextEditingController(text: '$_year');
    _monthCtrl = TextEditingController(text: '$_month');
  }

  @override
  void dispose() {
    _yearCtrl.dispose();
    _monthCtrl.dispose();
    super.dispose();
  }

  void _setYear(int y) {
    if (y < widget.firstYear || y > widget.lastYear) return;
    setState(() {
      _year = y;
      if (_yearCtrl.text != '$y') _yearCtrl.text = '$y';
    });
  }

  void _setMonth(int m) {
    if (m < 1 || m > 12) return;
    setState(() {
      _month = m;
      if (_monthCtrl.text != '$m') _monthCtrl.text = '$m';
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text('년/월 이동'),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 숫자 입력 필드 (가로 2개)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _yearCtrl,
                    decoration: const InputDecoration(
                      labelText: '년도',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    onChanged: (v) {
                      final n = int.tryParse(v);
                      if (n != null && n >= widget.firstYear && n <= widget.lastYear) {
                        setState(() => _year = n);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 90,
                  child: TextField(
                    controller: _monthCtrl,
                    decoration: const InputDecoration(
                      labelText: '월',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                    onChanged: (v) {
                      final n = int.tryParse(v);
                      if (n != null && n >= 1 && n <= 12) {
                        setState(() => _month = n);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 년도 stepper
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _year > widget.firstYear ? () => _setYear(_year - 1) : null,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '$_year년',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _year < widget.lastYear ? () => _setYear(_year + 1) : null,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 월 grid (3 행 × 4 열)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.6,
              children: [
                for (var m = 1; m <= 12; m++)
                  _MonthChip(
                    month: m,
                    selected: m == _month,
                    onTap: () => _setMonth(m),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '현재 선택: $_year년 $_month월',
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(DateTime(_year, _month)),
          child: const Text('이동'),
        ),
      ],
    );
  }
}

class _MonthChip extends StatelessWidget {
  const _MonthChip({
    required this.month,
    required this.selected,
    required this.onTap,
  });
  final int month;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? scheme.primary : scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Text(
            '$month월',
            style: TextStyle(
              color: selected ? scheme.onPrimary : scheme.onSurface,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
