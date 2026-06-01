// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_dao.dart';

// ignore_for_file: type=lint
mixin _$ShiftDaoMixin on DatabaseAccessor<AppDatabase> {
  $JobsTable get jobs => attachedDatabase.jobs;
  $ShiftsTable get shifts => attachedDatabase.shifts;
  ShiftDaoManager get managers => ShiftDaoManager(this);
}

class ShiftDaoManager {
  final _$ShiftDaoMixin _db;
  ShiftDaoManager(this._db);
  $$JobsTableTableManager get jobs =>
      $$JobsTableTableManager(_db.attachedDatabase, _db.jobs);
  $$ShiftsTableTableManager get shifts =>
      $$ShiftsTableTableManager(_db.attachedDatabase, _db.shifts);
}
