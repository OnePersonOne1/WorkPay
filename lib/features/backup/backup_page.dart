import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../settings/settings_providers.dart';
import 'backup_providers.dart';
import 'backup_service.dart';

class BackupPage extends ConsumerWidget {
  const BackupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSettings = ref.watch(appSettingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('백업 및 복원')),
      body: ListView(
        children: [
          asyncSettings.maybeWhen(
            data: (s) => _LastBackupTile(at: s.lastBackupAt),
            orElse: () => const ListTile(
              leading: Icon(Icons.history),
              title: Text('마지막 백업'),
              subtitle: Text('로드 중…'),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('내보내기 (JSON)'),
            subtitle: const Text('모든 근무처와 시프트를 한 파일로 저장해요'),
            onTap: () => _export(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('가져오기 (JSON)'),
            subtitle: const Text('백업 파일로 현재 데이터를 완전히 교체해요'),
            onTap: () => _import(context, ref),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Text(
              '• 가져오기는 기존 데이터를 모두 덮어씁니다.\n'
              '• 다른 버전의 앱에서 만든 백업은 호환되지 않을 수 있어요.\n'
              '• 클라우드에 자동 백업되지 않습니다. 파일을 직접 안전한 곳에 보관하세요.',
              style: TextStyle(fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final service = ref.read(backupServiceProvider);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final jsonStr = await service.exportToJson();
      final now = DateTime.now();
      final filename =
          'salary_app_backup_${_yyyymmdd(now)}_${_hhmm(now)}.json';
      final encoded = Uint8List.fromList(utf8.encode(jsonStr));
      final path = await FilePicker.saveFile(
        dialogTitle: '백업 저장 위치 선택',
        fileName: filename,
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: encoded,
      );
      if (path == null) return; // 사용자 취소
      // Windows/Linux desktop: saveFile은 경로만 반환하고 직접 쓰지 않으므로 보강.
      // Android/mobile: saveFile이 bytes로 직접 썼을 수 있어 이미 존재할 수 있음.
      final file = File(path);
      if (!await file.exists() || (await file.length()) == 0) {
        await file.writeAsBytes(encoded);
      }
      await service.markBackedUp(now.toUtc());
      messenger.showSnackBar(
        SnackBar(content: Text('백업 저장됨: $path')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('내보내기 실패: $e')),
      );
    }
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final service = ref.read(backupServiceProvider);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final picked = await FilePicker.pickFiles(
        dialogTitle: '백업 파일 선택',
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );
      if (picked == null || picked.files.isEmpty) return;
      final file = picked.files.single;
      final bytes = file.bytes ?? await File(file.path!).readAsBytes();
      final jsonStr = utf8.decode(bytes);

      // 먼저 parse로 검증 (schemaVersion 등)
      final data = service.parse(jsonStr);
      if (!context.mounted) return;
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('가져오기 확인'),
          content: Text(
            '현재 데이터를 모두 삭제하고 백업 파일로 교체합니다.\n\n'
            '• 근무처 ${data.jobs.length}개\n'
            '• 시프트 ${data.shifts.length}개\n'
            '• 백업 시각: ${data.exportedAt.toLocal()}\n\n'
            '되돌릴 수 없어요. 계속할까요?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('취소'),
            ),
            FilledButton.tonal(
              style: FilledButton.styleFrom(
                foregroundColor: Theme.of(ctx).colorScheme.error,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('덮어쓰기'),
            ),
          ],
        ),
      );
      if (confirm != true) return;
      final result = await service.import(data);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
              '가져오기 완료: 근무처 ${result.jobs}개, 시프트 ${result.shifts}개'),
        ),
      );
    } on IncompatibleBackupException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('가져오기 실패: $e')),
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
    final text = at == null
        ? '없음'
        : DateFormat('yyyy-MM-dd HH:mm', 'ko_KR').format(at!.toLocal());
    return ListTile(
      leading: const Icon(Icons.history),
      title: const Text('마지막 백업'),
      subtitle: Text(text),
    );
  }
}

