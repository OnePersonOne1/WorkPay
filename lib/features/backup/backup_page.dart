// SPDX-License-Identifier: GPL-3.0-only
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../l10n/generated/app_localizations.dart';
import '../settings/settings_providers.dart';
import 'backup_providers.dart';
import 'backup_service.dart';

class BackupPage extends ConsumerWidget {
  const BackupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final asyncSettings = ref.watch(appSettingsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.backupTitle)),
      body: ListView(
        children: [
          asyncSettings.maybeWhen(
            data: (s) => _LastBackupTile(at: s.lastBackupAt),
            orElse: () => ListTile(
              leading: const Icon(Icons.history),
              title: Text(l.backupLastBackupNever),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: Text(l.backupExport),
            onTap: () => _export(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: Text(l.backupImport),
            onTap: () => _import(context, ref),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Text(
              l.backupSectionWhatBody,
              style: const TextStyle(fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final service = ref.read(backupServiceProvider);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final jsonStr = await service.exportToJson();
      final now = DateTime.now();
      final filename =
          'salary_app_backup_${_yyyymmdd(now)}_${_hhmm(now)}.json';
      final encoded = Uint8List.fromList(utf8.encode(jsonStr));

      // Android/iOS: 시스템 저장 다이얼로그가 없어 공유 시트로 내보낸다.
      // 데스크톱: 저장 위치 선택 다이얼로그로 직접 파일을 쓴다.
      if (Platform.isAndroid || Platform.isIOS) {
        final dir = await getTemporaryDirectory();
        final file = File(p.join(dir.path, filename));
        await file.writeAsBytes(encoded);
        final result = await SharePlus.instance.share(
          ShareParams(
            subject: filename,
            files: [
              XFile(
                file.path,
                mimeType: 'application/json',
                name: filename,
              ),
            ],
          ),
        );
        if (result.status == ShareResultStatus.dismissed) return;
        await service.markBackedUp(now.toUtc());
        messenger.showSnackBar(
          SnackBar(content: Text(l.backupExportSaved(filename))),
        );
      } else {
        final location = await getSaveLocation(
          suggestedName: filename,
          acceptedTypeGroups: const [
            XTypeGroup(label: 'JSON', extensions: ['json']),
          ],
        );
        if (location == null) return;
        await File(location.path).writeAsBytes(encoded);
        await service.markBackedUp(now.toUtc());
        messenger.showSnackBar(
          SnackBar(content: Text(l.backupExportSaved(location.path))),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l.backupExportFailed(e.toString()))),
      );
    }
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final service = ref.read(backupServiceProvider);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final picked = await openFile(
        acceptedTypeGroups: const [
          XTypeGroup(
            label: 'JSON',
            extensions: ['json'],
            mimeTypes: ['application/json'],
          ),
        ],
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      final jsonStr = utf8.decode(bytes);

      final data = service.parse(jsonStr);
      if (!context.mounted) return;
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          final lc = AppLocalizations.of(ctx);
          return AlertDialog(
            title: Text(lc.backupImportConfirmTitle),
            content: Text(lc.backupImportConfirmBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(lc.actionCancel),
              ),
              FilledButton.tonal(
                style: FilledButton.styleFrom(
                  foregroundColor: Theme.of(ctx).colorScheme.error,
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(lc.actionReplace),
              ),
            ],
          );
        },
      );
      if (confirm != true) return;
      final result = await service.import(data);
      messenger.showSnackBar(
        SnackBar(
          content:
              Text(l.backupImportRestored(result.jobs, result.shifts)),
        ),
      );
    } on IncompatibleBackupException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l.backupIncompatibleVersion(
          e.backupVersion,
          e.appVersion,
        ))),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l.backupImportFailed(e.toString()))),
      );
    }
  }

  static String _yyyymmdd(DateTime d) =>
      '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';
  static String _hhmm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}${d.minute.toString().padLeft(2, '0')}';
}

class _LastBackupTile extends StatelessWidget {
  const _LastBackupTile({required this.at});
  final DateTime? at;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = at == null
        ? l.backupLastBackupNever
        : l.backupLastBackupAt(
            DateFormat('yyyy-MM-dd HH:mm', l.localeName).format(at!.toLocal()),
          );
    return ListTile(
      leading: const Icon(Icons.history),
      title: Text(text),
    );
  }
}
