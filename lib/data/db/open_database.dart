// SPDX-License-Identifier: GPL-3.0-only
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app_database.dart';

/// 앱이 사용하는 실제 DB 파일을 열어 [AppDatabase] 인스턴스를 반환한다.
///
/// 데스크톱·Android·iOS 모두 동일 경로 규칙(앱 documents/salary_app.sqlite)을 사용한다.
/// sqlite3 ^2.0의 네이티브 라이브러리는 sqlite3 패키지 자체에 번들되어 별도 초기화 불필요.
Future<AppDatabase> openAppDatabase() async {
  final executor = LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'salary_app.sqlite'));
    return NativeDatabase.createInBackground(file);
  });

  return AppDatabase(executor);
}
