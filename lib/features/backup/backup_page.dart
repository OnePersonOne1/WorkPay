// SPDX-License-Identifier: GPL-3.0-only
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
      final path = await FilePicker.saveFile(
        dialogTitle: l.backupExport,
        fileName: filename,
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: encoded,
      );
      if (path == null) return;
      final file = File(path);
      if (!await file.exists() || (await file.length()) == 0) {
        await file.writeAsBytes(encoded);
      }
      await service.markBackedUp(now.toUtc());
      messenger.showSnackBar(
        SnackBar(content: Text(l.backupExportSaved(path))),
      );
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
      final picked = await FilePicker.pickFiles(
        dialogTitle: l.backupImport,
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );
      if (picked == null || picked.files.isEmpty) return;
      final file = picked.files.single;
      final bytes = file.bytes ?? await File(file.path!).readAsBytes();
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
