import '../../domain/entity/app_settings.dart' as ent;
import '../../domain/repository/app_settings_repository.dart';
import '../dao/app_settings_dao.dart';
import 'mappers.dart';

class DriftAppSettingsRepository implements AppSettingsRepository {
  DriftAppSettingsRepository(this._dao);

  final AppSettingsDao _dao;

  @override
  Stream<ent.AppSettings> watch() =>
      _dao.watch().map((r) => r.toEntity());

  @override
  Future<ent.AppSettings> read() async {
    final row = await _dao.read();
    return row.toEntity();
  }

  @override
  Future<void> update(ent.AppSettings settings) {
    return _dao.save(settings.toCompanion());
  }
}
