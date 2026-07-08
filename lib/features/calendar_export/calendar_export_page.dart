// SPDX-License-Identifier: GPL-3.0-only
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/providers.dart';
import '../../domain/entity/shift.dart';
import '../../l10n/generated/app_localizations.dart';
import '../schedule/plan_providers.dart';
import '../schedule/schedule_providers.dart';
import '../schedule/year_month_picker.dart';
import 'ics_builder.dart';

/// 구글 캘린더 내보내기 — 표준 .ics 파일 생성 + 처음 쓰는 사용자용 안내.
/// 로그인·네트워크 없이 파일 공유/저장만 사용한다 (백업 내보내기와 동일한 흐름).
class CalendarExportPage extends ConsumerStatefulWidget {
  const CalendarExportPage({super.key});

  @override
  ConsumerState<CalendarExportPage> createState() => _CalendarExportPageState();
}

class _CalendarExportPageState extends ConsumerState<CalendarExportPage> {
  /// 페이지 로컬 월 상태 — 여기서 월을 바꿔도 일정표 화면에는 영향 없음.
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    _month = ref.read(selectedMonthProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final planId = ref.watch(activePlanIdProvider);
    final repo = ref.watch(shiftRepositoryProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l.calExportTitle)),
      body: StreamBuilder<List<Shift>>(
        stream: repo.watchShiftsInMonth(
          _month.year,
          _month.month,
          planId: planId,
        ),
        builder: (context, snapshot) {
          final shifts = snapshot.data ?? const <Shift>[];
          final loaded = snapshot.hasData;
          return ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              _monthSelector(context),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  !loaded
                      ? ''
                      : shifts.isEmpty
                          ? l.calExportNoShifts
                          : l.calExportMonthShiftCount(shifts.length),
                  style: TextStyle(
                    color: shifts.isEmpty && loaded
                        ? scheme.error
                        : scheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: FilledButton.icon(
                  icon: const Icon(Icons.event_available),
                  label: Text(l.calExportButton),
                  onPressed:
                      shifts.isEmpty ? null : () => _export(context, shifts),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              _guideSection(
                context,
                icon: Icons.lightbulb_outline,
                title: l.calExportFirstTimeTitle,
                body: l.calExportFirstTimeBody,
              ),
              _guideSection(
                context,
                icon: Icons.checklist,
                title: l.calExportHowToTitle,
                body: '${l.calExportHowToMobile}\n\n${l.calExportHowToPc}',
              ),
              _guideSection(
                context,
                icon: Icons.privacy_tip_outlined,
                title: l.calExportNotesTitle,
                body: l.calExportNotesBody,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _monthSelector(BuildContext context) {
    final l = AppLocalizations.of(context);
    void shiftMonth(int delta) {
      setState(() {
        _month = DateTime(_month.year, _month.month + delta);
      });
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: l.schedulePrevMonth,
            onPressed: () => shiftMonth(-1),
          ),
          Expanded(
            child: InkWell(
              onTap: () async {
                final picked = await pickYearMonth(context, initial: _month);
                if (picked != null) {
                  setState(() {
                    _month = DateTime(picked.year, picked.month);
                  });
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat.yMMMM(l.localeName).format(_month),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, size: 22),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: l.scheduleNextMonth,
            onPressed: () => shiftMonth(1),
          ),
        ],
      ),
    );
  }

  Widget _guideSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String body,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: scheme.primary),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }

  Future<void> _export(BuildContext context, List<Shift> shifts) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      // archived 포함 전체 근무처 — 옛 시프트가 참조하는 이름도 해석되도록.
      final jobs = await ref.read(jobRepositoryProvider).watchAllJobs().first;
      final nameById = {for (final j in jobs) j.id: j.name};

      final events = <CalendarEventData>[
        for (final s in shifts)
          CalendarEventData(
            uid: shiftUid(s.id),
            start: s.startAt.toLocal(),
            end: s.endAt.toLocal(),
            summary: nameById[s.jobId] ?? l.calExportUnknownJob,
            // 급여·시급 정보는 의도적으로 제외 (캘린더는 공유되는 경우가 많음).
            description: [
              if (s.breakMinutes > 0) l.scheduleBreakSuffix(s.breakMinutes),
              if (s.memo != null && s.memo!.isNotEmpty) s.memo!,
            ].join('\n'),
          ),
      ];
      final ics = buildIcs(events, nowUtc: DateTime.now().toUtc());
      final filename =
          'salary_app_${_month.year}-${_month.month.toString().padLeft(2, '0')}.ics';
      final encoded = Uint8List.fromList(utf8.encode(ics));

      // Android: 열기/저장/공유 선택 시트. 구글 캘린더는 공유(ACTION_SEND)를 받지
      // 않고 열기(ACTION_VIEW)만 처리하며, 최신 공유 시트에는 '파일 저장' 항목이
      // 없는 기기도 있어 세 동작을 직접 제공한다. iOS: 공유 시트. 데스크톱: 저장.
      if (Platform.isAndroid) {
        if (!context.mounted) return;
        final action = await _pickAndroidAction(context);
        switch (action) {
          case null:
            return;
          case _ExportAction.openCalendar:
            final file = await _writeTempFile(filename, encoded);
            final result =
                await OpenFilex.open(file.path, type: 'text/calendar');
            if (result.type != ResultType.done) {
              messenger.showSnackBar(
                SnackBar(content: Text(l.calExportNoCalendarApp)),
              );
            }
          case _ExportAction.saveFile:
            final path = await FlutterFileDialog.saveFile(
              params: SaveFileDialogParams(
                data: encoded,
                fileName: filename,
                mimeTypesFilter: const ['text/calendar'],
              ),
            );
            if (path == null) return;
            messenger.showSnackBar(
              SnackBar(content: Text(l.calExportSaved(filename))),
            );
          case _ExportAction.share:
            final file = await _writeTempFile(filename, encoded);
            final result = await SharePlus.instance.share(
              ShareParams(
                subject: filename,
                files: [
                  XFile(
                    file.path,
                    mimeType: 'text/calendar',
                    name: filename,
                  ),
                ],
              ),
            );
            if (result.status == ShareResultStatus.dismissed) return;
            messenger.showSnackBar(
              SnackBar(content: Text(l.calExportSaved(filename))),
            );
        }
      } else if (Platform.isIOS) {
        final file = await _writeTempFile(filename, encoded);
        final result = await SharePlus.instance.share(
          ShareParams(
            subject: filename,
            files: [
              XFile(
                file.path,
                mimeType: 'text/calendar',
                name: filename,
              ),
            ],
          ),
        );
        if (result.status == ShareResultStatus.dismissed) return;
        messenger.showSnackBar(
          SnackBar(content: Text(l.calExportSaved(filename))),
        );
      } else {
        final location = await getSaveLocation(
          suggestedName: filename,
          acceptedTypeGroups: const [
            XTypeGroup(label: 'iCalendar', extensions: ['ics']),
          ],
        );
        if (location == null) return;
        await File(location.path).writeAsBytes(encoded);
        messenger.showSnackBar(
          SnackBar(content: Text(l.calExportSaved(location.path))),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l.calExportFailed(e.toString()))),
      );
    }
  }

  Future<File> _writeTempFile(String filename, Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, filename));
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<_ExportAction?> _pickAndroidAction(BuildContext context) {
    final l = AppLocalizations.of(context);
    return showModalBottomSheet<_ExportAction>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.event),
              title: Text(l.calExportOpenCalendarApp),
              subtitle: Text(l.calExportOpenCalendarAppDesc),
              onTap: () => Navigator.pop(context, _ExportAction.openCalendar),
            ),
            ListTile(
              leading: const Icon(Icons.save_alt),
              title: Text(l.calExportSaveToFile),
              subtitle: Text(l.calExportSaveToFileDesc),
              onTap: () => Navigator.pop(context, _ExportAction.saveFile),
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: Text(l.calExportShareOther),
              subtitle: Text(l.calExportShareOtherDesc),
              onTap: () => Navigator.pop(context, _ExportAction.share),
            ),
          ],
        ),
      ),
    );
  }
}

/// 안드로이드에서 .ics 파일을 처리할 방법.
enum _ExportAction { openCalendar, saveFile, share }
