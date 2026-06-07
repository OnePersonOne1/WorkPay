import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 다이얼 없는 시간 입력 dialog. 한 화면에 숫자 입력과 휠(드래그) 둘 다 제공.
///
/// - 상단: 시/분 TextField (직접 타이핑)
/// - 하단: CupertinoDatePicker (휠 스크롤)
/// - 둘은 같은 상태를 공유 — 한 쪽에서 바꾸면 다른 쪽도 갱신
Future<TimeOfDay?> pickTimeDialog(
  BuildContext context, {
  required TimeOfDay initial,
  required bool use24Hour,
}) {
  return showDialog<TimeOfDay>(
    context: context,
    builder: (ctx) => _TimePickerDialog(
      initial: initial,
      use24Hour: use24Hour,
    ),
  );
}

class _TimePickerDialog extends StatefulWidget {
  const _TimePickerDialog({
    required this.initial,
    required this.use24Hour,
  });
  final TimeOfDay initial;
  final bool use24Hour;

  @override
  State<_TimePickerDialog> createState() => _State();
}

class _State extends State<_TimePickerDialog> {
  late TimeOfDay _value;
  late TextEditingController _hourCtrl;
  late TextEditingController _minCtrl;
  // 휠을 강제로 리빌드해 새 시간으로 점프할 때만 증가
  int _wheelKey = 0;

  @override
  void initState() {
    super.initState();
    _value = widget.initial;
    _hourCtrl = TextEditingController(text: _hourText(_value.hour));
    _minCtrl = TextEditingController(text: _value.minute.toString().padLeft(2, '0'));
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minCtrl.dispose();
    super.dispose();
  }

  String _hourText(int hour) {
    if (widget.use24Hour) return hour.toString().padLeft(2, '0');
    if (hour == 0) return '12';
    if (hour > 12) return (hour - 12).toString();
    return hour.toString();
  }

  bool _isPm(int hour) => hour >= 12;

  void _setFromInputs() {
    final hStr = _hourCtrl.text.trim();
    final mStr = _minCtrl.text.trim();
    final h = int.tryParse(hStr);
    final m = int.tryParse(mStr);
    if (h == null || m == null) return;
    if (m < 0 || m > 59) return;
    int hour24;
    if (widget.use24Hour) {
      if (h < 0 || h > 23) return;
      hour24 = h;
    } else {
      if (h < 1 || h > 12) return;
      final pm = _isPm(_value.hour);
      hour24 = (h % 12) + (pm ? 12 : 0);
    }
    setState(() {
      _value = TimeOfDay(hour: hour24, minute: m);
      _wheelKey++;
    });
  }

  void _togglePeriod() {
    if (widget.use24Hour) return;
    final wasPm = _isPm(_value.hour);
    final newHour = wasPm ? _value.hour - 12 : _value.hour + 12;
    setState(() {
      _value = TimeOfDay(hour: newHour.clamp(0, 23), minute: _value.minute);
      _hourCtrl.text = _hourText(_value.hour);
      _wheelKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('시간 선택'),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 숫자 직접 입력
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (!widget.use24Hour)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: OutlinedButton(
                      onPressed: _togglePeriod,
                      child: Text(_isPm(_value.hour) ? '오후' : '오전'),
                    ),
                  ),
                Expanded(
                  child: TextField(
                    controller: _hourCtrl,
                    decoration: const InputDecoration(
                      labelText: '시',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                    onChanged: (_) => _setFromInputs(),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(':'),
                ),
                Expanded(
                  child: TextField(
                    controller: _minCtrl,
                    decoration: const InputDecoration(
                      labelText: '분',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                    onChanged: (_) => _setFromInputs(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 휠 (드래그 입력)
            SizedBox(
              height: 180,
              child: CupertinoTheme(
                data: CupertinoTheme.of(context).copyWith(
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                child: CupertinoDatePicker(
                  key: ValueKey(_wheelKey),
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: widget.use24Hour,
                  initialDateTime: DateTime(2026, 1, 1, _value.hour, _value.minute),
                  onDateTimeChanged: (dt) {
                    setState(() {
                      _value = TimeOfDay(hour: dt.hour, minute: dt.minute);
                      _hourCtrl.text = _hourText(dt.hour);
                      _minCtrl.text = dt.minute.toString().padLeft(2, '0');
                    });
                  },
                ),
              ),
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
          onPressed: () => Navigator.of(context).pop(_value),
          child: const Text('확인'),
        ),
      ],
    );
  }
}
