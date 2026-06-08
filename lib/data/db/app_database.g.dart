// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $JobsTable extends Jobs with TableInfo<$JobsTable, Job> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hourlyWageMeta = const VerificationMeta(
    'hourlyWage',
  );
  @override
  late final GeneratedColumn<int> hourlyWage = GeneratedColumn<int>(
    'hourly_wage',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _incomeTypeMeta = const VerificationMeta(
    'incomeType',
  );
  @override
  late final GeneratedColumn<String> incomeType = GeneratedColumn<String>(
    'income_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessSizeMeta = const VerificationMeta(
    'businessSize',
  );
  @override
  late final GeneratedColumn<String> businessSize = GeneratedColumn<String>(
    'business_size',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorArgbMeta = const VerificationMeta(
    'colorArgb',
  );
  @override
  late final GeneratedColumn<int> colorArgb = GeneratedColumn<int>(
    'color_argb',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    hourlyWage,
    incomeType,
    businessSize,
    colorArgb,
    archived,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'jobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Job> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('hourly_wage')) {
      context.handle(
        _hourlyWageMeta,
        hourlyWage.isAcceptableOrUnknown(data['hourly_wage']!, _hourlyWageMeta),
      );
    } else if (isInserting) {
      context.missing(_hourlyWageMeta);
    }
    if (data.containsKey('income_type')) {
      context.handle(
        _incomeTypeMeta,
        incomeType.isAcceptableOrUnknown(data['income_type']!, _incomeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_incomeTypeMeta);
    }
    if (data.containsKey('business_size')) {
      context.handle(
        _businessSizeMeta,
        businessSize.isAcceptableOrUnknown(
          data['business_size']!,
          _businessSizeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_businessSizeMeta);
    }
    if (data.containsKey('color_argb')) {
      context.handle(
        _colorArgbMeta,
        colorArgb.isAcceptableOrUnknown(data['color_argb']!, _colorArgbMeta),
      );
    } else if (isInserting) {
      context.missing(_colorArgbMeta);
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Job map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Job(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      hourlyWage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hourly_wage'],
      )!,
      incomeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}income_type'],
      )!,
      businessSize: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_size'],
      )!,
      colorArgb: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_argb'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $JobsTable createAlias(String alias) {
    return $JobsTable(attachedDatabase, alias);
  }
}

class Job extends DataClass implements Insertable<Job> {
  final int id;
  final String name;
  final int hourlyWage;
  final String incomeType;
  final String businessSize;
  final int colorArgb;
  final bool archived;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Job({
    required this.id,
    required this.name,
    required this.hourlyWage,
    required this.incomeType,
    required this.businessSize,
    required this.colorArgb,
    required this.archived,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['hourly_wage'] = Variable<int>(hourlyWage);
    map['income_type'] = Variable<String>(incomeType);
    map['business_size'] = Variable<String>(businessSize);
    map['color_argb'] = Variable<int>(colorArgb);
    map['archived'] = Variable<bool>(archived);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  JobsCompanion toCompanion(bool nullToAbsent) {
    return JobsCompanion(
      id: Value(id),
      name: Value(name),
      hourlyWage: Value(hourlyWage),
      incomeType: Value(incomeType),
      businessSize: Value(businessSize),
      colorArgb: Value(colorArgb),
      archived: Value(archived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Job.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Job(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      hourlyWage: serializer.fromJson<int>(json['hourlyWage']),
      incomeType: serializer.fromJson<String>(json['incomeType']),
      businessSize: serializer.fromJson<String>(json['businessSize']),
      colorArgb: serializer.fromJson<int>(json['colorArgb']),
      archived: serializer.fromJson<bool>(json['archived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'hourlyWage': serializer.toJson<int>(hourlyWage),
      'incomeType': serializer.toJson<String>(incomeType),
      'businessSize': serializer.toJson<String>(businessSize),
      'colorArgb': serializer.toJson<int>(colorArgb),
      'archived': serializer.toJson<bool>(archived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Job copyWith({
    int? id,
    String? name,
    int? hourlyWage,
    String? incomeType,
    String? businessSize,
    int? colorArgb,
    bool? archived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Job(
    id: id ?? this.id,
    name: name ?? this.name,
    hourlyWage: hourlyWage ?? this.hourlyWage,
    incomeType: incomeType ?? this.incomeType,
    businessSize: businessSize ?? this.businessSize,
    colorArgb: colorArgb ?? this.colorArgb,
    archived: archived ?? this.archived,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Job copyWithCompanion(JobsCompanion data) {
    return Job(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      hourlyWage: data.hourlyWage.present
          ? data.hourlyWage.value
          : this.hourlyWage,
      incomeType: data.incomeType.present
          ? data.incomeType.value
          : this.incomeType,
      businessSize: data.businessSize.present
          ? data.businessSize.value
          : this.businessSize,
      colorArgb: data.colorArgb.present ? data.colorArgb.value : this.colorArgb,
      archived: data.archived.present ? data.archived.value : this.archived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Job(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('hourlyWage: $hourlyWage, ')
          ..write('incomeType: $incomeType, ')
          ..write('businessSize: $businessSize, ')
          ..write('colorArgb: $colorArgb, ')
          ..write('archived: $archived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    hourlyWage,
    incomeType,
    businessSize,
    colorArgb,
    archived,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Job &&
          other.id == this.id &&
          other.name == this.name &&
          other.hourlyWage == this.hourlyWage &&
          other.incomeType == this.incomeType &&
          other.businessSize == this.businessSize &&
          other.colorArgb == this.colorArgb &&
          other.archived == this.archived &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class JobsCompanion extends UpdateCompanion<Job> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> hourlyWage;
  final Value<String> incomeType;
  final Value<String> businessSize;
  final Value<int> colorArgb;
  final Value<bool> archived;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const JobsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.hourlyWage = const Value.absent(),
    this.incomeType = const Value.absent(),
    this.businessSize = const Value.absent(),
    this.colorArgb = const Value.absent(),
    this.archived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  JobsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int hourlyWage,
    required String incomeType,
    required String businessSize,
    required int colorArgb,
    this.archived = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : name = Value(name),
       hourlyWage = Value(hourlyWage),
       incomeType = Value(incomeType),
       businessSize = Value(businessSize),
       colorArgb = Value(colorArgb),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Job> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? hourlyWage,
    Expression<String>? incomeType,
    Expression<String>? businessSize,
    Expression<int>? colorArgb,
    Expression<bool>? archived,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (hourlyWage != null) 'hourly_wage': hourlyWage,
      if (incomeType != null) 'income_type': incomeType,
      if (businessSize != null) 'business_size': businessSize,
      if (colorArgb != null) 'color_argb': colorArgb,
      if (archived != null) 'archived': archived,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  JobsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? hourlyWage,
    Value<String>? incomeType,
    Value<String>? businessSize,
    Value<int>? colorArgb,
    Value<bool>? archived,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return JobsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      hourlyWage: hourlyWage ?? this.hourlyWage,
      incomeType: incomeType ?? this.incomeType,
      businessSize: businessSize ?? this.businessSize,
      colorArgb: colorArgb ?? this.colorArgb,
      archived: archived ?? this.archived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (hourlyWage.present) {
      map['hourly_wage'] = Variable<int>(hourlyWage.value);
    }
    if (incomeType.present) {
      map['income_type'] = Variable<String>(incomeType.value);
    }
    if (businessSize.present) {
      map['business_size'] = Variable<String>(businessSize.value);
    }
    if (colorArgb.present) {
      map['color_argb'] = Variable<int>(colorArgb.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JobsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('hourlyWage: $hourlyWage, ')
          ..write('incomeType: $incomeType, ')
          ..write('businessSize: $businessSize, ')
          ..write('colorArgb: $colorArgb, ')
          ..write('archived: $archived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $JobPayrollOptionsTableTable extends JobPayrollOptionsTable
    with TableInfo<$JobPayrollOptionsTableTable, JobPayrollOptionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JobPayrollOptionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _jobIdMeta = const VerificationMeta('jobId');
  @override
  late final GeneratedColumn<int> jobId = GeneratedColumn<int>(
    'job_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES jobs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _weeklyHolidayAllowanceMeta =
      const VerificationMeta('weeklyHolidayAllowance');
  @override
  late final GeneratedColumn<bool> weeklyHolidayAllowance =
      GeneratedColumn<bool>(
        'weekly_holiday_allowance',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("weekly_holiday_allowance" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _nightPremiumMeta = const VerificationMeta(
    'nightPremium',
  );
  @override
  late final GeneratedColumn<bool> nightPremium = GeneratedColumn<bool>(
    'night_premium',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("night_premium" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dailyOvertimeMeta = const VerificationMeta(
    'dailyOvertime',
  );
  @override
  late final GeneratedColumn<bool> dailyOvertime = GeneratedColumn<bool>(
    'daily_overtime',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("daily_overtime" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _weeklyOvertimeMeta = const VerificationMeta(
    'weeklyOvertime',
  );
  @override
  late final GeneratedColumn<bool> weeklyOvertime = GeneratedColumn<bool>(
    'weekly_overtime',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("weekly_overtime" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _holidayPremiumMeta = const VerificationMeta(
    'holidayPremium',
  );
  @override
  late final GeneratedColumn<bool> holidayPremium = GeneratedColumn<bool>(
    'holiday_premium',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("holiday_premium" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _preciseBreakInputMeta = const VerificationMeta(
    'preciseBreakInput',
  );
  @override
  late final GeneratedColumn<bool> preciseBreakInput = GeneratedColumn<bool>(
    'precise_break_input',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("precise_break_input" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deductionModeMeta = const VerificationMeta(
    'deductionMode',
  );
  @override
  late final GeneratedColumn<String> deductionMode = GeneratedColumn<String>(
    'deduction_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _fourInsuranceRateMeta = const VerificationMeta(
    'fourInsuranceRate',
  );
  @override
  late final GeneratedColumn<int> fourInsuranceRate = GeneratedColumn<int>(
    'four_insurance_rate',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(940),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    jobId,
    weeklyHolidayAllowance,
    nightPremium,
    dailyOvertime,
    weeklyOvertime,
    holidayPremium,
    preciseBreakInput,
    deductionMode,
    fourInsuranceRate,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'job_payroll_options';
  @override
  VerificationContext validateIntegrity(
    Insertable<JobPayrollOptionsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('job_id')) {
      context.handle(
        _jobIdMeta,
        jobId.isAcceptableOrUnknown(data['job_id']!, _jobIdMeta),
      );
    }
    if (data.containsKey('weekly_holiday_allowance')) {
      context.handle(
        _weeklyHolidayAllowanceMeta,
        weeklyHolidayAllowance.isAcceptableOrUnknown(
          data['weekly_holiday_allowance']!,
          _weeklyHolidayAllowanceMeta,
        ),
      );
    }
    if (data.containsKey('night_premium')) {
      context.handle(
        _nightPremiumMeta,
        nightPremium.isAcceptableOrUnknown(
          data['night_premium']!,
          _nightPremiumMeta,
        ),
      );
    }
    if (data.containsKey('daily_overtime')) {
      context.handle(
        _dailyOvertimeMeta,
        dailyOvertime.isAcceptableOrUnknown(
          data['daily_overtime']!,
          _dailyOvertimeMeta,
        ),
      );
    }
    if (data.containsKey('weekly_overtime')) {
      context.handle(
        _weeklyOvertimeMeta,
        weeklyOvertime.isAcceptableOrUnknown(
          data['weekly_overtime']!,
          _weeklyOvertimeMeta,
        ),
      );
    }
    if (data.containsKey('holiday_premium')) {
      context.handle(
        _holidayPremiumMeta,
        holidayPremium.isAcceptableOrUnknown(
          data['holiday_premium']!,
          _holidayPremiumMeta,
        ),
      );
    }
    if (data.containsKey('precise_break_input')) {
      context.handle(
        _preciseBreakInputMeta,
        preciseBreakInput.isAcceptableOrUnknown(
          data['precise_break_input']!,
          _preciseBreakInputMeta,
        ),
      );
    }
    if (data.containsKey('deduction_mode')) {
      context.handle(
        _deductionModeMeta,
        deductionMode.isAcceptableOrUnknown(
          data['deduction_mode']!,
          _deductionModeMeta,
        ),
      );
    }
    if (data.containsKey('four_insurance_rate')) {
      context.handle(
        _fourInsuranceRateMeta,
        fourInsuranceRate.isAcceptableOrUnknown(
          data['four_insurance_rate']!,
          _fourInsuranceRateMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {jobId};
  @override
  JobPayrollOptionsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JobPayrollOptionsTableData(
      jobId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}job_id'],
      )!,
      weeklyHolidayAllowance: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}weekly_holiday_allowance'],
      )!,
      nightPremium: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}night_premium'],
      )!,
      dailyOvertime: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}daily_overtime'],
      )!,
      weeklyOvertime: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}weekly_overtime'],
      )!,
      holidayPremium: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}holiday_premium'],
      )!,
      preciseBreakInput: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}precise_break_input'],
      )!,
      deductionMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deduction_mode'],
      )!,
      fourInsuranceRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}four_insurance_rate'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $JobPayrollOptionsTableTable createAlias(String alias) {
    return $JobPayrollOptionsTableTable(attachedDatabase, alias);
  }
}

class JobPayrollOptionsTableData extends DataClass
    implements Insertable<JobPayrollOptionsTableData> {
  final int jobId;
  final bool weeklyHolidayAllowance;
  final bool nightPremium;
  final bool dailyOvertime;
  final bool weeklyOvertime;
  final bool holidayPremium;
  final bool preciseBreakInput;
  final String deductionMode;

  /// 만분율. 940 = 9.40%.
  final int fourInsuranceRate;
  final DateTime updatedAt;
  const JobPayrollOptionsTableData({
    required this.jobId,
    required this.weeklyHolidayAllowance,
    required this.nightPremium,
    required this.dailyOvertime,
    required this.weeklyOvertime,
    required this.holidayPremium,
    required this.preciseBreakInput,
    required this.deductionMode,
    required this.fourInsuranceRate,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['job_id'] = Variable<int>(jobId);
    map['weekly_holiday_allowance'] = Variable<bool>(weeklyHolidayAllowance);
    map['night_premium'] = Variable<bool>(nightPremium);
    map['daily_overtime'] = Variable<bool>(dailyOvertime);
    map['weekly_overtime'] = Variable<bool>(weeklyOvertime);
    map['holiday_premium'] = Variable<bool>(holidayPremium);
    map['precise_break_input'] = Variable<bool>(preciseBreakInput);
    map['deduction_mode'] = Variable<String>(deductionMode);
    map['four_insurance_rate'] = Variable<int>(fourInsuranceRate);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  JobPayrollOptionsTableCompanion toCompanion(bool nullToAbsent) {
    return JobPayrollOptionsTableCompanion(
      jobId: Value(jobId),
      weeklyHolidayAllowance: Value(weeklyHolidayAllowance),
      nightPremium: Value(nightPremium),
      dailyOvertime: Value(dailyOvertime),
      weeklyOvertime: Value(weeklyOvertime),
      holidayPremium: Value(holidayPremium),
      preciseBreakInput: Value(preciseBreakInput),
      deductionMode: Value(deductionMode),
      fourInsuranceRate: Value(fourInsuranceRate),
      updatedAt: Value(updatedAt),
    );
  }

  factory JobPayrollOptionsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JobPayrollOptionsTableData(
      jobId: serializer.fromJson<int>(json['jobId']),
      weeklyHolidayAllowance: serializer.fromJson<bool>(
        json['weeklyHolidayAllowance'],
      ),
      nightPremium: serializer.fromJson<bool>(json['nightPremium']),
      dailyOvertime: serializer.fromJson<bool>(json['dailyOvertime']),
      weeklyOvertime: serializer.fromJson<bool>(json['weeklyOvertime']),
      holidayPremium: serializer.fromJson<bool>(json['holidayPremium']),
      preciseBreakInput: serializer.fromJson<bool>(json['preciseBreakInput']),
      deductionMode: serializer.fromJson<String>(json['deductionMode']),
      fourInsuranceRate: serializer.fromJson<int>(json['fourInsuranceRate']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'jobId': serializer.toJson<int>(jobId),
      'weeklyHolidayAllowance': serializer.toJson<bool>(weeklyHolidayAllowance),
      'nightPremium': serializer.toJson<bool>(nightPremium),
      'dailyOvertime': serializer.toJson<bool>(dailyOvertime),
      'weeklyOvertime': serializer.toJson<bool>(weeklyOvertime),
      'holidayPremium': serializer.toJson<bool>(holidayPremium),
      'preciseBreakInput': serializer.toJson<bool>(preciseBreakInput),
      'deductionMode': serializer.toJson<String>(deductionMode),
      'fourInsuranceRate': serializer.toJson<int>(fourInsuranceRate),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  JobPayrollOptionsTableData copyWith({
    int? jobId,
    bool? weeklyHolidayAllowance,
    bool? nightPremium,
    bool? dailyOvertime,
    bool? weeklyOvertime,
    bool? holidayPremium,
    bool? preciseBreakInput,
    String? deductionMode,
    int? fourInsuranceRate,
    DateTime? updatedAt,
  }) => JobPayrollOptionsTableData(
    jobId: jobId ?? this.jobId,
    weeklyHolidayAllowance:
        weeklyHolidayAllowance ?? this.weeklyHolidayAllowance,
    nightPremium: nightPremium ?? this.nightPremium,
    dailyOvertime: dailyOvertime ?? this.dailyOvertime,
    weeklyOvertime: weeklyOvertime ?? this.weeklyOvertime,
    holidayPremium: holidayPremium ?? this.holidayPremium,
    preciseBreakInput: preciseBreakInput ?? this.preciseBreakInput,
    deductionMode: deductionMode ?? this.deductionMode,
    fourInsuranceRate: fourInsuranceRate ?? this.fourInsuranceRate,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  JobPayrollOptionsTableData copyWithCompanion(
    JobPayrollOptionsTableCompanion data,
  ) {
    return JobPayrollOptionsTableData(
      jobId: data.jobId.present ? data.jobId.value : this.jobId,
      weeklyHolidayAllowance: data.weeklyHolidayAllowance.present
          ? data.weeklyHolidayAllowance.value
          : this.weeklyHolidayAllowance,
      nightPremium: data.nightPremium.present
          ? data.nightPremium.value
          : this.nightPremium,
      dailyOvertime: data.dailyOvertime.present
          ? data.dailyOvertime.value
          : this.dailyOvertime,
      weeklyOvertime: data.weeklyOvertime.present
          ? data.weeklyOvertime.value
          : this.weeklyOvertime,
      holidayPremium: data.holidayPremium.present
          ? data.holidayPremium.value
          : this.holidayPremium,
      preciseBreakInput: data.preciseBreakInput.present
          ? data.preciseBreakInput.value
          : this.preciseBreakInput,
      deductionMode: data.deductionMode.present
          ? data.deductionMode.value
          : this.deductionMode,
      fourInsuranceRate: data.fourInsuranceRate.present
          ? data.fourInsuranceRate.value
          : this.fourInsuranceRate,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JobPayrollOptionsTableData(')
          ..write('jobId: $jobId, ')
          ..write('weeklyHolidayAllowance: $weeklyHolidayAllowance, ')
          ..write('nightPremium: $nightPremium, ')
          ..write('dailyOvertime: $dailyOvertime, ')
          ..write('weeklyOvertime: $weeklyOvertime, ')
          ..write('holidayPremium: $holidayPremium, ')
          ..write('preciseBreakInput: $preciseBreakInput, ')
          ..write('deductionMode: $deductionMode, ')
          ..write('fourInsuranceRate: $fourInsuranceRate, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    jobId,
    weeklyHolidayAllowance,
    nightPremium,
    dailyOvertime,
    weeklyOvertime,
    holidayPremium,
    preciseBreakInput,
    deductionMode,
    fourInsuranceRate,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JobPayrollOptionsTableData &&
          other.jobId == this.jobId &&
          other.weeklyHolidayAllowance == this.weeklyHolidayAllowance &&
          other.nightPremium == this.nightPremium &&
          other.dailyOvertime == this.dailyOvertime &&
          other.weeklyOvertime == this.weeklyOvertime &&
          other.holidayPremium == this.holidayPremium &&
          other.preciseBreakInput == this.preciseBreakInput &&
          other.deductionMode == this.deductionMode &&
          other.fourInsuranceRate == this.fourInsuranceRate &&
          other.updatedAt == this.updatedAt);
}

class JobPayrollOptionsTableCompanion
    extends UpdateCompanion<JobPayrollOptionsTableData> {
  final Value<int> jobId;
  final Value<bool> weeklyHolidayAllowance;
  final Value<bool> nightPremium;
  final Value<bool> dailyOvertime;
  final Value<bool> weeklyOvertime;
  final Value<bool> holidayPremium;
  final Value<bool> preciseBreakInput;
  final Value<String> deductionMode;
  final Value<int> fourInsuranceRate;
  final Value<DateTime> updatedAt;
  const JobPayrollOptionsTableCompanion({
    this.jobId = const Value.absent(),
    this.weeklyHolidayAllowance = const Value.absent(),
    this.nightPremium = const Value.absent(),
    this.dailyOvertime = const Value.absent(),
    this.weeklyOvertime = const Value.absent(),
    this.holidayPremium = const Value.absent(),
    this.preciseBreakInput = const Value.absent(),
    this.deductionMode = const Value.absent(),
    this.fourInsuranceRate = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  JobPayrollOptionsTableCompanion.insert({
    this.jobId = const Value.absent(),
    this.weeklyHolidayAllowance = const Value.absent(),
    this.nightPremium = const Value.absent(),
    this.dailyOvertime = const Value.absent(),
    this.weeklyOvertime = const Value.absent(),
    this.holidayPremium = const Value.absent(),
    this.preciseBreakInput = const Value.absent(),
    this.deductionMode = const Value.absent(),
    this.fourInsuranceRate = const Value.absent(),
    required DateTime updatedAt,
  }) : updatedAt = Value(updatedAt);
  static Insertable<JobPayrollOptionsTableData> custom({
    Expression<int>? jobId,
    Expression<bool>? weeklyHolidayAllowance,
    Expression<bool>? nightPremium,
    Expression<bool>? dailyOvertime,
    Expression<bool>? weeklyOvertime,
    Expression<bool>? holidayPremium,
    Expression<bool>? preciseBreakInput,
    Expression<String>? deductionMode,
    Expression<int>? fourInsuranceRate,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (jobId != null) 'job_id': jobId,
      if (weeklyHolidayAllowance != null)
        'weekly_holiday_allowance': weeklyHolidayAllowance,
      if (nightPremium != null) 'night_premium': nightPremium,
      if (dailyOvertime != null) 'daily_overtime': dailyOvertime,
      if (weeklyOvertime != null) 'weekly_overtime': weeklyOvertime,
      if (holidayPremium != null) 'holiday_premium': holidayPremium,
      if (preciseBreakInput != null) 'precise_break_input': preciseBreakInput,
      if (deductionMode != null) 'deduction_mode': deductionMode,
      if (fourInsuranceRate != null) 'four_insurance_rate': fourInsuranceRate,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  JobPayrollOptionsTableCompanion copyWith({
    Value<int>? jobId,
    Value<bool>? weeklyHolidayAllowance,
    Value<bool>? nightPremium,
    Value<bool>? dailyOvertime,
    Value<bool>? weeklyOvertime,
    Value<bool>? holidayPremium,
    Value<bool>? preciseBreakInput,
    Value<String>? deductionMode,
    Value<int>? fourInsuranceRate,
    Value<DateTime>? updatedAt,
  }) {
    return JobPayrollOptionsTableCompanion(
      jobId: jobId ?? this.jobId,
      weeklyHolidayAllowance:
          weeklyHolidayAllowance ?? this.weeklyHolidayAllowance,
      nightPremium: nightPremium ?? this.nightPremium,
      dailyOvertime: dailyOvertime ?? this.dailyOvertime,
      weeklyOvertime: weeklyOvertime ?? this.weeklyOvertime,
      holidayPremium: holidayPremium ?? this.holidayPremium,
      preciseBreakInput: preciseBreakInput ?? this.preciseBreakInput,
      deductionMode: deductionMode ?? this.deductionMode,
      fourInsuranceRate: fourInsuranceRate ?? this.fourInsuranceRate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (jobId.present) {
      map['job_id'] = Variable<int>(jobId.value);
    }
    if (weeklyHolidayAllowance.present) {
      map['weekly_holiday_allowance'] = Variable<bool>(
        weeklyHolidayAllowance.value,
      );
    }
    if (nightPremium.present) {
      map['night_premium'] = Variable<bool>(nightPremium.value);
    }
    if (dailyOvertime.present) {
      map['daily_overtime'] = Variable<bool>(dailyOvertime.value);
    }
    if (weeklyOvertime.present) {
      map['weekly_overtime'] = Variable<bool>(weeklyOvertime.value);
    }
    if (holidayPremium.present) {
      map['holiday_premium'] = Variable<bool>(holidayPremium.value);
    }
    if (preciseBreakInput.present) {
      map['precise_break_input'] = Variable<bool>(preciseBreakInput.value);
    }
    if (deductionMode.present) {
      map['deduction_mode'] = Variable<String>(deductionMode.value);
    }
    if (fourInsuranceRate.present) {
      map['four_insurance_rate'] = Variable<int>(fourInsuranceRate.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JobPayrollOptionsTableCompanion(')
          ..write('jobId: $jobId, ')
          ..write('weeklyHolidayAllowance: $weeklyHolidayAllowance, ')
          ..write('nightPremium: $nightPremium, ')
          ..write('dailyOvertime: $dailyOvertime, ')
          ..write('weeklyOvertime: $weeklyOvertime, ')
          ..write('holidayPremium: $holidayPremium, ')
          ..write('preciseBreakInput: $preciseBreakInput, ')
          ..write('deductionMode: $deductionMode, ')
          ..write('fourInsuranceRate: $fourInsuranceRate, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ShiftsTable extends Shifts with TableInfo<$ShiftsTable, Shift> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShiftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _jobIdMeta = const VerificationMeta('jobId');
  @override
  late final GeneratedColumn<int> jobId = GeneratedColumn<int>(
    'job_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES jobs (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _startAtMeta = const VerificationMeta(
    'startAt',
  );
  @override
  late final GeneratedColumn<DateTime> startAt = GeneratedColumn<DateTime>(
    'start_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endAtMeta = const VerificationMeta('endAt');
  @override
  late final GeneratedColumn<DateTime> endAt = GeneratedColumn<DateTime>(
    'end_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _breakMinutesMeta = const VerificationMeta(
    'breakMinutes',
  );
  @override
  late final GeneratedColumn<int> breakMinutes = GeneratedColumn<int>(
    'break_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _breakStartAtMeta = const VerificationMeta(
    'breakStartAt',
  );
  @override
  late final GeneratedColumn<DateTime> breakStartAt = GeneratedColumn<DateTime>(
    'break_start_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hourlyWageSnapshotMeta =
      const VerificationMeta('hourlyWageSnapshot');
  @override
  late final GeneratedColumn<int> hourlyWageSnapshot = GeneratedColumn<int>(
    'hourly_wage_snapshot',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
    'memo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    jobId,
    startAt,
    endAt,
    breakMinutes,
    breakStartAt,
    hourlyWageSnapshot,
    memo,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shifts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Shift> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('job_id')) {
      context.handle(
        _jobIdMeta,
        jobId.isAcceptableOrUnknown(data['job_id']!, _jobIdMeta),
      );
    } else if (isInserting) {
      context.missing(_jobIdMeta);
    }
    if (data.containsKey('start_at')) {
      context.handle(
        _startAtMeta,
        startAt.isAcceptableOrUnknown(data['start_at']!, _startAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startAtMeta);
    }
    if (data.containsKey('end_at')) {
      context.handle(
        _endAtMeta,
        endAt.isAcceptableOrUnknown(data['end_at']!, _endAtMeta),
      );
    } else if (isInserting) {
      context.missing(_endAtMeta);
    }
    if (data.containsKey('break_minutes')) {
      context.handle(
        _breakMinutesMeta,
        breakMinutes.isAcceptableOrUnknown(
          data['break_minutes']!,
          _breakMinutesMeta,
        ),
      );
    }
    if (data.containsKey('break_start_at')) {
      context.handle(
        _breakStartAtMeta,
        breakStartAt.isAcceptableOrUnknown(
          data['break_start_at']!,
          _breakStartAtMeta,
        ),
      );
    }
    if (data.containsKey('hourly_wage_snapshot')) {
      context.handle(
        _hourlyWageSnapshotMeta,
        hourlyWageSnapshot.isAcceptableOrUnknown(
          data['hourly_wage_snapshot']!,
          _hourlyWageSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hourlyWageSnapshotMeta);
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Shift map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Shift(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      jobId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}job_id'],
      )!,
      startAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_at'],
      )!,
      endAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_at'],
      )!,
      breakMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}break_minutes'],
      )!,
      breakStartAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}break_start_at'],
      ),
      hourlyWageSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hourly_wage_snapshot'],
      )!,
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ShiftsTable createAlias(String alias) {
    return $ShiftsTable(attachedDatabase, alias);
  }
}

class Shift extends DataClass implements Insertable<Shift> {
  final int id;
  final int jobId;
  final DateTime startAt;
  final DateTime endAt;
  final int breakMinutes;
  final DateTime? breakStartAt;
  final int hourlyWageSnapshot;
  final String? memo;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Shift({
    required this.id,
    required this.jobId,
    required this.startAt,
    required this.endAt,
    required this.breakMinutes,
    this.breakStartAt,
    required this.hourlyWageSnapshot,
    this.memo,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['job_id'] = Variable<int>(jobId);
    map['start_at'] = Variable<DateTime>(startAt);
    map['end_at'] = Variable<DateTime>(endAt);
    map['break_minutes'] = Variable<int>(breakMinutes);
    if (!nullToAbsent || breakStartAt != null) {
      map['break_start_at'] = Variable<DateTime>(breakStartAt);
    }
    map['hourly_wage_snapshot'] = Variable<int>(hourlyWageSnapshot);
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ShiftsCompanion toCompanion(bool nullToAbsent) {
    return ShiftsCompanion(
      id: Value(id),
      jobId: Value(jobId),
      startAt: Value(startAt),
      endAt: Value(endAt),
      breakMinutes: Value(breakMinutes),
      breakStartAt: breakStartAt == null && nullToAbsent
          ? const Value.absent()
          : Value(breakStartAt),
      hourlyWageSnapshot: Value(hourlyWageSnapshot),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Shift.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Shift(
      id: serializer.fromJson<int>(json['id']),
      jobId: serializer.fromJson<int>(json['jobId']),
      startAt: serializer.fromJson<DateTime>(json['startAt']),
      endAt: serializer.fromJson<DateTime>(json['endAt']),
      breakMinutes: serializer.fromJson<int>(json['breakMinutes']),
      breakStartAt: serializer.fromJson<DateTime?>(json['breakStartAt']),
      hourlyWageSnapshot: serializer.fromJson<int>(json['hourlyWageSnapshot']),
      memo: serializer.fromJson<String?>(json['memo']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'jobId': serializer.toJson<int>(jobId),
      'startAt': serializer.toJson<DateTime>(startAt),
      'endAt': serializer.toJson<DateTime>(endAt),
      'breakMinutes': serializer.toJson<int>(breakMinutes),
      'breakStartAt': serializer.toJson<DateTime?>(breakStartAt),
      'hourlyWageSnapshot': serializer.toJson<int>(hourlyWageSnapshot),
      'memo': serializer.toJson<String?>(memo),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Shift copyWith({
    int? id,
    int? jobId,
    DateTime? startAt,
    DateTime? endAt,
    int? breakMinutes,
    Value<DateTime?> breakStartAt = const Value.absent(),
    int? hourlyWageSnapshot,
    Value<String?> memo = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Shift(
    id: id ?? this.id,
    jobId: jobId ?? this.jobId,
    startAt: startAt ?? this.startAt,
    endAt: endAt ?? this.endAt,
    breakMinutes: breakMinutes ?? this.breakMinutes,
    breakStartAt: breakStartAt.present ? breakStartAt.value : this.breakStartAt,
    hourlyWageSnapshot: hourlyWageSnapshot ?? this.hourlyWageSnapshot,
    memo: memo.present ? memo.value : this.memo,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Shift copyWithCompanion(ShiftsCompanion data) {
    return Shift(
      id: data.id.present ? data.id.value : this.id,
      jobId: data.jobId.present ? data.jobId.value : this.jobId,
      startAt: data.startAt.present ? data.startAt.value : this.startAt,
      endAt: data.endAt.present ? data.endAt.value : this.endAt,
      breakMinutes: data.breakMinutes.present
          ? data.breakMinutes.value
          : this.breakMinutes,
      breakStartAt: data.breakStartAt.present
          ? data.breakStartAt.value
          : this.breakStartAt,
      hourlyWageSnapshot: data.hourlyWageSnapshot.present
          ? data.hourlyWageSnapshot.value
          : this.hourlyWageSnapshot,
      memo: data.memo.present ? data.memo.value : this.memo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Shift(')
          ..write('id: $id, ')
          ..write('jobId: $jobId, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('breakMinutes: $breakMinutes, ')
          ..write('breakStartAt: $breakStartAt, ')
          ..write('hourlyWageSnapshot: $hourlyWageSnapshot, ')
          ..write('memo: $memo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    jobId,
    startAt,
    endAt,
    breakMinutes,
    breakStartAt,
    hourlyWageSnapshot,
    memo,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Shift &&
          other.id == this.id &&
          other.jobId == this.jobId &&
          other.startAt == this.startAt &&
          other.endAt == this.endAt &&
          other.breakMinutes == this.breakMinutes &&
          other.breakStartAt == this.breakStartAt &&
          other.hourlyWageSnapshot == this.hourlyWageSnapshot &&
          other.memo == this.memo &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ShiftsCompanion extends UpdateCompanion<Shift> {
  final Value<int> id;
  final Value<int> jobId;
  final Value<DateTime> startAt;
  final Value<DateTime> endAt;
  final Value<int> breakMinutes;
  final Value<DateTime?> breakStartAt;
  final Value<int> hourlyWageSnapshot;
  final Value<String?> memo;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ShiftsCompanion({
    this.id = const Value.absent(),
    this.jobId = const Value.absent(),
    this.startAt = const Value.absent(),
    this.endAt = const Value.absent(),
    this.breakMinutes = const Value.absent(),
    this.breakStartAt = const Value.absent(),
    this.hourlyWageSnapshot = const Value.absent(),
    this.memo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ShiftsCompanion.insert({
    this.id = const Value.absent(),
    required int jobId,
    required DateTime startAt,
    required DateTime endAt,
    this.breakMinutes = const Value.absent(),
    this.breakStartAt = const Value.absent(),
    required int hourlyWageSnapshot,
    this.memo = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : jobId = Value(jobId),
       startAt = Value(startAt),
       endAt = Value(endAt),
       hourlyWageSnapshot = Value(hourlyWageSnapshot),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Shift> custom({
    Expression<int>? id,
    Expression<int>? jobId,
    Expression<DateTime>? startAt,
    Expression<DateTime>? endAt,
    Expression<int>? breakMinutes,
    Expression<DateTime>? breakStartAt,
    Expression<int>? hourlyWageSnapshot,
    Expression<String>? memo,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jobId != null) 'job_id': jobId,
      if (startAt != null) 'start_at': startAt,
      if (endAt != null) 'end_at': endAt,
      if (breakMinutes != null) 'break_minutes': breakMinutes,
      if (breakStartAt != null) 'break_start_at': breakStartAt,
      if (hourlyWageSnapshot != null)
        'hourly_wage_snapshot': hourlyWageSnapshot,
      if (memo != null) 'memo': memo,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ShiftsCompanion copyWith({
    Value<int>? id,
    Value<int>? jobId,
    Value<DateTime>? startAt,
    Value<DateTime>? endAt,
    Value<int>? breakMinutes,
    Value<DateTime?>? breakStartAt,
    Value<int>? hourlyWageSnapshot,
    Value<String?>? memo,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return ShiftsCompanion(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      breakMinutes: breakMinutes ?? this.breakMinutes,
      breakStartAt: breakStartAt ?? this.breakStartAt,
      hourlyWageSnapshot: hourlyWageSnapshot ?? this.hourlyWageSnapshot,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (jobId.present) {
      map['job_id'] = Variable<int>(jobId.value);
    }
    if (startAt.present) {
      map['start_at'] = Variable<DateTime>(startAt.value);
    }
    if (endAt.present) {
      map['end_at'] = Variable<DateTime>(endAt.value);
    }
    if (breakMinutes.present) {
      map['break_minutes'] = Variable<int>(breakMinutes.value);
    }
    if (breakStartAt.present) {
      map['break_start_at'] = Variable<DateTime>(breakStartAt.value);
    }
    if (hourlyWageSnapshot.present) {
      map['hourly_wage_snapshot'] = Variable<int>(hourlyWageSnapshot.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShiftsCompanion(')
          ..write('id: $id, ')
          ..write('jobId: $jobId, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('breakMinutes: $breakMinutes, ')
          ..write('breakStartAt: $breakStartAt, ')
          ..write('hourlyWageSnapshot: $hourlyWageSnapshot, ')
          ..write('memo: $memo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTableTable extends AppSettingsTable
    with TableInfo<$AppSettingsTableTable, AppSettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _themeModeMeta = const VerificationMeta(
    'themeMode',
  );
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
    'theme_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ko'),
  );
  static const VerificationMeta _lastBackupAtMeta = const VerificationMeta(
    'lastBackupAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastBackupAt = GeneratedColumn<DateTime>(
    'last_backup_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payrollConstantsJsonMeta =
      const VerificationMeta('payrollConstantsJson');
  @override
  late final GeneratedColumn<String> payrollConstantsJson =
      GeneratedColumn<String>(
        'payroll_constants_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _use24HourFormatMeta = const VerificationMeta(
    'use24HourFormat',
  );
  @override
  late final GeneratedColumn<bool> use24HourFormat = GeneratedColumn<bool>(
    'use24_hour_format',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("use24_hour_format" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _undoStackJsonMeta = const VerificationMeta(
    'undoStackJson',
  );
  @override
  late final GeneratedColumn<String> undoStackJson = GeneratedColumn<String>(
    'undo_stack_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    schemaVersion,
    themeMode,
    locale,
    lastBackupAt,
    payrollConstantsJson,
    use24HourFormat,
    undoStackJson,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_schemaVersionMeta);
    }
    if (data.containsKey('theme_mode')) {
      context.handle(
        _themeModeMeta,
        themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta),
      );
    }
    if (data.containsKey('locale')) {
      context.handle(
        _localeMeta,
        locale.isAcceptableOrUnknown(data['locale']!, _localeMeta),
      );
    }
    if (data.containsKey('last_backup_at')) {
      context.handle(
        _lastBackupAtMeta,
        lastBackupAt.isAcceptableOrUnknown(
          data['last_backup_at']!,
          _lastBackupAtMeta,
        ),
      );
    }
    if (data.containsKey('payroll_constants_json')) {
      context.handle(
        _payrollConstantsJsonMeta,
        payrollConstantsJson.isAcceptableOrUnknown(
          data['payroll_constants_json']!,
          _payrollConstantsJsonMeta,
        ),
      );
    }
    if (data.containsKey('use24_hour_format')) {
      context.handle(
        _use24HourFormatMeta,
        use24HourFormat.isAcceptableOrUnknown(
          data['use24_hour_format']!,
          _use24HourFormatMeta,
        ),
      );
    }
    if (data.containsKey('undo_stack_json')) {
      context.handle(
        _undoStackJsonMeta,
        undoStackJson.isAcceptableOrUnknown(
          data['undo_stack_json']!,
          _undoStackJsonMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
      themeMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_mode'],
      )!,
      locale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale'],
      )!,
      lastBackupAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_backup_at'],
      ),
      payrollConstantsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payroll_constants_json'],
      ),
      use24HourFormat: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}use24_hour_format'],
      )!,
      undoStackJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}undo_stack_json'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingsTableTable createAlias(String alias) {
    return $AppSettingsTableTable(attachedDatabase, alias);
  }
}

class AppSettingsTableData extends DataClass
    implements Insertable<AppSettingsTableData> {
  /// 항상 1. Single-row 불변식은 DAO 레벨에서 강제 (id=1 고정 upsert).
  final int id;
  final int schemaVersion;
  final String themeMode;
  final String locale;
  final DateTime? lastBackupAt;

  /// '고고급 설정'에서 사용자가 override한 PayrollConstants 직렬화 JSON.
  /// NULL이면 koreanDefault() 사용.
  final String? payrollConstantsJson;

  /// 24시간 형식 표시 여부. 기본 true (24h). false면 오전/오후 표시.
  final bool use24HourFormat;

  /// Undo 스택 JSON. 시프트 변경 시 직전 월 시프트 list snapshot을 누적.
  /// NULL이면 빈 스택. 최대 5개 entry.
  final String? undoStackJson;
  final DateTime updatedAt;
  const AppSettingsTableData({
    required this.id,
    required this.schemaVersion,
    required this.themeMode,
    required this.locale,
    this.lastBackupAt,
    this.payrollConstantsJson,
    required this.use24HourFormat,
    this.undoStackJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['schema_version'] = Variable<int>(schemaVersion);
    map['theme_mode'] = Variable<String>(themeMode);
    map['locale'] = Variable<String>(locale);
    if (!nullToAbsent || lastBackupAt != null) {
      map['last_backup_at'] = Variable<DateTime>(lastBackupAt);
    }
    if (!nullToAbsent || payrollConstantsJson != null) {
      map['payroll_constants_json'] = Variable<String>(payrollConstantsJson);
    }
    map['use24_hour_format'] = Variable<bool>(use24HourFormat);
    if (!nullToAbsent || undoStackJson != null) {
      map['undo_stack_json'] = Variable<String>(undoStackJson);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsTableCompanion(
      id: Value(id),
      schemaVersion: Value(schemaVersion),
      themeMode: Value(themeMode),
      locale: Value(locale),
      lastBackupAt: lastBackupAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastBackupAt),
      payrollConstantsJson: payrollConstantsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(payrollConstantsJson),
      use24HourFormat: Value(use24HourFormat),
      undoStackJson: undoStackJson == null && nullToAbsent
          ? const Value.absent()
          : Value(undoStackJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSettingsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingsTableData(
      id: serializer.fromJson<int>(json['id']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      locale: serializer.fromJson<String>(json['locale']),
      lastBackupAt: serializer.fromJson<DateTime?>(json['lastBackupAt']),
      payrollConstantsJson: serializer.fromJson<String?>(
        json['payrollConstantsJson'],
      ),
      use24HourFormat: serializer.fromJson<bool>(json['use24HourFormat']),
      undoStackJson: serializer.fromJson<String?>(json['undoStackJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
      'themeMode': serializer.toJson<String>(themeMode),
      'locale': serializer.toJson<String>(locale),
      'lastBackupAt': serializer.toJson<DateTime?>(lastBackupAt),
      'payrollConstantsJson': serializer.toJson<String?>(payrollConstantsJson),
      'use24HourFormat': serializer.toJson<bool>(use24HourFormat),
      'undoStackJson': serializer.toJson<String?>(undoStackJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSettingsTableData copyWith({
    int? id,
    int? schemaVersion,
    String? themeMode,
    String? locale,
    Value<DateTime?> lastBackupAt = const Value.absent(),
    Value<String?> payrollConstantsJson = const Value.absent(),
    bool? use24HourFormat,
    Value<String?> undoStackJson = const Value.absent(),
    DateTime? updatedAt,
  }) => AppSettingsTableData(
    id: id ?? this.id,
    schemaVersion: schemaVersion ?? this.schemaVersion,
    themeMode: themeMode ?? this.themeMode,
    locale: locale ?? this.locale,
    lastBackupAt: lastBackupAt.present ? lastBackupAt.value : this.lastBackupAt,
    payrollConstantsJson: payrollConstantsJson.present
        ? payrollConstantsJson.value
        : this.payrollConstantsJson,
    use24HourFormat: use24HourFormat ?? this.use24HourFormat,
    undoStackJson: undoStackJson.present
        ? undoStackJson.value
        : this.undoStackJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AppSettingsTableData copyWithCompanion(AppSettingsTableCompanion data) {
    return AppSettingsTableData(
      id: data.id.present ? data.id.value : this.id,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      locale: data.locale.present ? data.locale.value : this.locale,
      lastBackupAt: data.lastBackupAt.present
          ? data.lastBackupAt.value
          : this.lastBackupAt,
      payrollConstantsJson: data.payrollConstantsJson.present
          ? data.payrollConstantsJson.value
          : this.payrollConstantsJson,
      use24HourFormat: data.use24HourFormat.present
          ? data.use24HourFormat.value
          : this.use24HourFormat,
      undoStackJson: data.undoStackJson.present
          ? data.undoStackJson.value
          : this.undoStackJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsTableData(')
          ..write('id: $id, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('themeMode: $themeMode, ')
          ..write('locale: $locale, ')
          ..write('lastBackupAt: $lastBackupAt, ')
          ..write('payrollConstantsJson: $payrollConstantsJson, ')
          ..write('use24HourFormat: $use24HourFormat, ')
          ..write('undoStackJson: $undoStackJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    schemaVersion,
    themeMode,
    locale,
    lastBackupAt,
    payrollConstantsJson,
    use24HourFormat,
    undoStackJson,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingsTableData &&
          other.id == this.id &&
          other.schemaVersion == this.schemaVersion &&
          other.themeMode == this.themeMode &&
          other.locale == this.locale &&
          other.lastBackupAt == this.lastBackupAt &&
          other.payrollConstantsJson == this.payrollConstantsJson &&
          other.use24HourFormat == this.use24HourFormat &&
          other.undoStackJson == this.undoStackJson &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsTableCompanion extends UpdateCompanion<AppSettingsTableData> {
  final Value<int> id;
  final Value<int> schemaVersion;
  final Value<String> themeMode;
  final Value<String> locale;
  final Value<DateTime?> lastBackupAt;
  final Value<String?> payrollConstantsJson;
  final Value<bool> use24HourFormat;
  final Value<String?> undoStackJson;
  final Value<DateTime> updatedAt;
  const AppSettingsTableCompanion({
    this.id = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.locale = const Value.absent(),
    this.lastBackupAt = const Value.absent(),
    this.payrollConstantsJson = const Value.absent(),
    this.use24HourFormat = const Value.absent(),
    this.undoStackJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AppSettingsTableCompanion.insert({
    this.id = const Value.absent(),
    required int schemaVersion,
    this.themeMode = const Value.absent(),
    this.locale = const Value.absent(),
    this.lastBackupAt = const Value.absent(),
    this.payrollConstantsJson = const Value.absent(),
    this.use24HourFormat = const Value.absent(),
    this.undoStackJson = const Value.absent(),
    required DateTime updatedAt,
  }) : schemaVersion = Value(schemaVersion),
       updatedAt = Value(updatedAt);
  static Insertable<AppSettingsTableData> custom({
    Expression<int>? id,
    Expression<int>? schemaVersion,
    Expression<String>? themeMode,
    Expression<String>? locale,
    Expression<DateTime>? lastBackupAt,
    Expression<String>? payrollConstantsJson,
    Expression<bool>? use24HourFormat,
    Expression<String>? undoStackJson,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (themeMode != null) 'theme_mode': themeMode,
      if (locale != null) 'locale': locale,
      if (lastBackupAt != null) 'last_backup_at': lastBackupAt,
      if (payrollConstantsJson != null)
        'payroll_constants_json': payrollConstantsJson,
      if (use24HourFormat != null) 'use24_hour_format': use24HourFormat,
      if (undoStackJson != null) 'undo_stack_json': undoStackJson,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AppSettingsTableCompanion copyWith({
    Value<int>? id,
    Value<int>? schemaVersion,
    Value<String>? themeMode,
    Value<String>? locale,
    Value<DateTime?>? lastBackupAt,
    Value<String?>? payrollConstantsJson,
    Value<bool>? use24HourFormat,
    Value<String?>? undoStackJson,
    Value<DateTime>? updatedAt,
  }) {
    return AppSettingsTableCompanion(
      id: id ?? this.id,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      lastBackupAt: lastBackupAt ?? this.lastBackupAt,
      payrollConstantsJson: payrollConstantsJson ?? this.payrollConstantsJson,
      use24HourFormat: use24HourFormat ?? this.use24HourFormat,
      undoStackJson: undoStackJson ?? this.undoStackJson,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (lastBackupAt.present) {
      map['last_backup_at'] = Variable<DateTime>(lastBackupAt.value);
    }
    if (payrollConstantsJson.present) {
      map['payroll_constants_json'] = Variable<String>(
        payrollConstantsJson.value,
      );
    }
    if (use24HourFormat.present) {
      map['use24_hour_format'] = Variable<bool>(use24HourFormat.value);
    }
    if (undoStackJson.present) {
      map['undo_stack_json'] = Variable<String>(undoStackJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('themeMode: $themeMode, ')
          ..write('locale: $locale, ')
          ..write('lastBackupAt: $lastBackupAt, ')
          ..write('payrollConstantsJson: $payrollConstantsJson, ')
          ..write('use24HourFormat: $use24HourFormat, ')
          ..write('undoStackJson: $undoStackJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $JobsTable jobs = $JobsTable(this);
  late final $JobPayrollOptionsTableTable jobPayrollOptionsTable =
      $JobPayrollOptionsTableTable(this);
  late final $ShiftsTable shifts = $ShiftsTable(this);
  late final $AppSettingsTableTable appSettingsTable = $AppSettingsTableTable(
    this,
  );
  late final JobDao jobDao = JobDao(this as AppDatabase);
  late final ShiftDao shiftDao = ShiftDao(this as AppDatabase);
  late final AppSettingsDao appSettingsDao = AppSettingsDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    jobs,
    jobPayrollOptionsTable,
    shifts,
    appSettingsTable,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'jobs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('job_payroll_options', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$JobsTableCreateCompanionBuilder =
    JobsCompanion Function({
      Value<int> id,
      required String name,
      required int hourlyWage,
      required String incomeType,
      required String businessSize,
      required int colorArgb,
      Value<bool> archived,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$JobsTableUpdateCompanionBuilder =
    JobsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> hourlyWage,
      Value<String> incomeType,
      Value<String> businessSize,
      Value<int> colorArgb,
      Value<bool> archived,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$JobsTableReferences
    extends BaseReferences<_$AppDatabase, $JobsTable, Job> {
  $$JobsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $JobPayrollOptionsTableTable,
    List<JobPayrollOptionsTableData>
  >
  _jobPayrollOptionsTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.jobPayrollOptionsTable,
        aliasName: $_aliasNameGenerator(
          db.jobs.id,
          db.jobPayrollOptionsTable.jobId,
        ),
      );

  $$JobPayrollOptionsTableTableProcessedTableManager
  get jobPayrollOptionsTableRefs {
    final manager = $$JobPayrollOptionsTableTableTableManager(
      $_db,
      $_db.jobPayrollOptionsTable,
    ).filter((f) => f.jobId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _jobPayrollOptionsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ShiftsTable, List<Shift>> _shiftsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.shifts,
    aliasName: $_aliasNameGenerator(db.jobs.id, db.shifts.jobId),
  );

  $$ShiftsTableProcessedTableManager get shiftsRefs {
    final manager = $$ShiftsTableTableManager(
      $_db,
      $_db.shifts,
    ).filter((f) => f.jobId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_shiftsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$JobsTableFilterComposer extends Composer<_$AppDatabase, $JobsTable> {
  $$JobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hourlyWage => $composableBuilder(
    column: $table.hourlyWage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get incomeType => $composableBuilder(
    column: $table.incomeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessSize => $composableBuilder(
    column: $table.businessSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorArgb => $composableBuilder(
    column: $table.colorArgb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> jobPayrollOptionsTableRefs(
    Expression<bool> Function($$JobPayrollOptionsTableTableFilterComposer f) f,
  ) {
    final $$JobPayrollOptionsTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.jobPayrollOptionsTable,
          getReferencedColumn: (t) => t.jobId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$JobPayrollOptionsTableTableFilterComposer(
                $db: $db,
                $table: $db.jobPayrollOptionsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> shiftsRefs(
    Expression<bool> Function($$ShiftsTableFilterComposer f) f,
  ) {
    final $$ShiftsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shifts,
      getReferencedColumn: (t) => t.jobId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShiftsTableFilterComposer(
            $db: $db,
            $table: $db.shifts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$JobsTableOrderingComposer extends Composer<_$AppDatabase, $JobsTable> {
  $$JobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hourlyWage => $composableBuilder(
    column: $table.hourlyWage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get incomeType => $composableBuilder(
    column: $table.incomeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessSize => $composableBuilder(
    column: $table.businessSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorArgb => $composableBuilder(
    column: $table.colorArgb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $JobsTable> {
  $$JobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get hourlyWage => $composableBuilder(
    column: $table.hourlyWage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get incomeType => $composableBuilder(
    column: $table.incomeType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get businessSize => $composableBuilder(
    column: $table.businessSize,
    builder: (column) => column,
  );

  GeneratedColumn<int> get colorArgb =>
      $composableBuilder(column: $table.colorArgb, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> jobPayrollOptionsTableRefs<T extends Object>(
    Expression<T> Function($$JobPayrollOptionsTableTableAnnotationComposer a) f,
  ) {
    final $$JobPayrollOptionsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.jobPayrollOptionsTable,
          getReferencedColumn: (t) => t.jobId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$JobPayrollOptionsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.jobPayrollOptionsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> shiftsRefs<T extends Object>(
    Expression<T> Function($$ShiftsTableAnnotationComposer a) f,
  ) {
    final $$ShiftsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shifts,
      getReferencedColumn: (t) => t.jobId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShiftsTableAnnotationComposer(
            $db: $db,
            $table: $db.shifts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$JobsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JobsTable,
          Job,
          $$JobsTableFilterComposer,
          $$JobsTableOrderingComposer,
          $$JobsTableAnnotationComposer,
          $$JobsTableCreateCompanionBuilder,
          $$JobsTableUpdateCompanionBuilder,
          (Job, $$JobsTableReferences),
          Job,
          PrefetchHooks Function({
            bool jobPayrollOptionsTableRefs,
            bool shiftsRefs,
          })
        > {
  $$JobsTableTableManager(_$AppDatabase db, $JobsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> hourlyWage = const Value.absent(),
                Value<String> incomeType = const Value.absent(),
                Value<String> businessSize = const Value.absent(),
                Value<int> colorArgb = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => JobsCompanion(
                id: id,
                name: name,
                hourlyWage: hourlyWage,
                incomeType: incomeType,
                businessSize: businessSize,
                colorArgb: colorArgb,
                archived: archived,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int hourlyWage,
                required String incomeType,
                required String businessSize,
                required int colorArgb,
                Value<bool> archived = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => JobsCompanion.insert(
                id: id,
                name: name,
                hourlyWage: hourlyWage,
                incomeType: incomeType,
                businessSize: businessSize,
                colorArgb: colorArgb,
                archived: archived,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$JobsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({jobPayrollOptionsTableRefs = false, shiftsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (jobPayrollOptionsTableRefs) db.jobPayrollOptionsTable,
                    if (shiftsRefs) db.shifts,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (jobPayrollOptionsTableRefs)
                        await $_getPrefetchedData<
                          Job,
                          $JobsTable,
                          JobPayrollOptionsTableData
                        >(
                          currentTable: table,
                          referencedTable: $$JobsTableReferences
                              ._jobPayrollOptionsTableRefsTable(db),
                          managerFromTypedResult: (p0) => $$JobsTableReferences(
                            db,
                            table,
                            p0,
                          ).jobPayrollOptionsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.jobId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (shiftsRefs)
                        await $_getPrefetchedData<Job, $JobsTable, Shift>(
                          currentTable: table,
                          referencedTable: $$JobsTableReferences
                              ._shiftsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$JobsTableReferences(db, table, p0).shiftsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.jobId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$JobsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JobsTable,
      Job,
      $$JobsTableFilterComposer,
      $$JobsTableOrderingComposer,
      $$JobsTableAnnotationComposer,
      $$JobsTableCreateCompanionBuilder,
      $$JobsTableUpdateCompanionBuilder,
      (Job, $$JobsTableReferences),
      Job,
      PrefetchHooks Function({bool jobPayrollOptionsTableRefs, bool shiftsRefs})
    >;
typedef $$JobPayrollOptionsTableTableCreateCompanionBuilder =
    JobPayrollOptionsTableCompanion Function({
      Value<int> jobId,
      Value<bool> weeklyHolidayAllowance,
      Value<bool> nightPremium,
      Value<bool> dailyOvertime,
      Value<bool> weeklyOvertime,
      Value<bool> holidayPremium,
      Value<bool> preciseBreakInput,
      Value<String> deductionMode,
      Value<int> fourInsuranceRate,
      required DateTime updatedAt,
    });
typedef $$JobPayrollOptionsTableTableUpdateCompanionBuilder =
    JobPayrollOptionsTableCompanion Function({
      Value<int> jobId,
      Value<bool> weeklyHolidayAllowance,
      Value<bool> nightPremium,
      Value<bool> dailyOvertime,
      Value<bool> weeklyOvertime,
      Value<bool> holidayPremium,
      Value<bool> preciseBreakInput,
      Value<String> deductionMode,
      Value<int> fourInsuranceRate,
      Value<DateTime> updatedAt,
    });

final class $$JobPayrollOptionsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $JobPayrollOptionsTableTable,
          JobPayrollOptionsTableData
        > {
  $$JobPayrollOptionsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $JobsTable _jobIdTable(_$AppDatabase db) => db.jobs.createAlias(
    $_aliasNameGenerator(db.jobPayrollOptionsTable.jobId, db.jobs.id),
  );

  $$JobsTableProcessedTableManager get jobId {
    final $_column = $_itemColumn<int>('job_id')!;

    final manager = $$JobsTableTableManager(
      $_db,
      $_db.jobs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_jobIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$JobPayrollOptionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $JobPayrollOptionsTableTable> {
  $$JobPayrollOptionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get weeklyHolidayAllowance => $composableBuilder(
    column: $table.weeklyHolidayAllowance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get nightPremium => $composableBuilder(
    column: $table.nightPremium,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dailyOvertime => $composableBuilder(
    column: $table.dailyOvertime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get weeklyOvertime => $composableBuilder(
    column: $table.weeklyOvertime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get holidayPremium => $composableBuilder(
    column: $table.holidayPremium,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get preciseBreakInput => $composableBuilder(
    column: $table.preciseBreakInput,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deductionMode => $composableBuilder(
    column: $table.deductionMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fourInsuranceRate => $composableBuilder(
    column: $table.fourInsuranceRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$JobsTableFilterComposer get jobId {
    final $$JobsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jobId,
      referencedTable: $db.jobs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobsTableFilterComposer(
            $db: $db,
            $table: $db.jobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JobPayrollOptionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $JobPayrollOptionsTableTable> {
  $$JobPayrollOptionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get weeklyHolidayAllowance => $composableBuilder(
    column: $table.weeklyHolidayAllowance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get nightPremium => $composableBuilder(
    column: $table.nightPremium,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dailyOvertime => $composableBuilder(
    column: $table.dailyOvertime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get weeklyOvertime => $composableBuilder(
    column: $table.weeklyOvertime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get holidayPremium => $composableBuilder(
    column: $table.holidayPremium,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get preciseBreakInput => $composableBuilder(
    column: $table.preciseBreakInput,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deductionMode => $composableBuilder(
    column: $table.deductionMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fourInsuranceRate => $composableBuilder(
    column: $table.fourInsuranceRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$JobsTableOrderingComposer get jobId {
    final $$JobsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jobId,
      referencedTable: $db.jobs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobsTableOrderingComposer(
            $db: $db,
            $table: $db.jobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JobPayrollOptionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $JobPayrollOptionsTableTable> {
  $$JobPayrollOptionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get weeklyHolidayAllowance => $composableBuilder(
    column: $table.weeklyHolidayAllowance,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get nightPremium => $composableBuilder(
    column: $table.nightPremium,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get dailyOvertime => $composableBuilder(
    column: $table.dailyOvertime,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get weeklyOvertime => $composableBuilder(
    column: $table.weeklyOvertime,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get holidayPremium => $composableBuilder(
    column: $table.holidayPremium,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get preciseBreakInput => $composableBuilder(
    column: $table.preciseBreakInput,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deductionMode => $composableBuilder(
    column: $table.deductionMode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fourInsuranceRate => $composableBuilder(
    column: $table.fourInsuranceRate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$JobsTableAnnotationComposer get jobId {
    final $$JobsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jobId,
      referencedTable: $db.jobs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobsTableAnnotationComposer(
            $db: $db,
            $table: $db.jobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JobPayrollOptionsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JobPayrollOptionsTableTable,
          JobPayrollOptionsTableData,
          $$JobPayrollOptionsTableTableFilterComposer,
          $$JobPayrollOptionsTableTableOrderingComposer,
          $$JobPayrollOptionsTableTableAnnotationComposer,
          $$JobPayrollOptionsTableTableCreateCompanionBuilder,
          $$JobPayrollOptionsTableTableUpdateCompanionBuilder,
          (JobPayrollOptionsTableData, $$JobPayrollOptionsTableTableReferences),
          JobPayrollOptionsTableData,
          PrefetchHooks Function({bool jobId})
        > {
  $$JobPayrollOptionsTableTableTableManager(
    _$AppDatabase db,
    $JobPayrollOptionsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JobPayrollOptionsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$JobPayrollOptionsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$JobPayrollOptionsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> jobId = const Value.absent(),
                Value<bool> weeklyHolidayAllowance = const Value.absent(),
                Value<bool> nightPremium = const Value.absent(),
                Value<bool> dailyOvertime = const Value.absent(),
                Value<bool> weeklyOvertime = const Value.absent(),
                Value<bool> holidayPremium = const Value.absent(),
                Value<bool> preciseBreakInput = const Value.absent(),
                Value<String> deductionMode = const Value.absent(),
                Value<int> fourInsuranceRate = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => JobPayrollOptionsTableCompanion(
                jobId: jobId,
                weeklyHolidayAllowance: weeklyHolidayAllowance,
                nightPremium: nightPremium,
                dailyOvertime: dailyOvertime,
                weeklyOvertime: weeklyOvertime,
                holidayPremium: holidayPremium,
                preciseBreakInput: preciseBreakInput,
                deductionMode: deductionMode,
                fourInsuranceRate: fourInsuranceRate,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> jobId = const Value.absent(),
                Value<bool> weeklyHolidayAllowance = const Value.absent(),
                Value<bool> nightPremium = const Value.absent(),
                Value<bool> dailyOvertime = const Value.absent(),
                Value<bool> weeklyOvertime = const Value.absent(),
                Value<bool> holidayPremium = const Value.absent(),
                Value<bool> preciseBreakInput = const Value.absent(),
                Value<String> deductionMode = const Value.absent(),
                Value<int> fourInsuranceRate = const Value.absent(),
                required DateTime updatedAt,
              }) => JobPayrollOptionsTableCompanion.insert(
                jobId: jobId,
                weeklyHolidayAllowance: weeklyHolidayAllowance,
                nightPremium: nightPremium,
                dailyOvertime: dailyOvertime,
                weeklyOvertime: weeklyOvertime,
                holidayPremium: holidayPremium,
                preciseBreakInput: preciseBreakInput,
                deductionMode: deductionMode,
                fourInsuranceRate: fourInsuranceRate,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$JobPayrollOptionsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({jobId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (jobId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.jobId,
                                referencedTable:
                                    $$JobPayrollOptionsTableTableReferences
                                        ._jobIdTable(db),
                                referencedColumn:
                                    $$JobPayrollOptionsTableTableReferences
                                        ._jobIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$JobPayrollOptionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JobPayrollOptionsTableTable,
      JobPayrollOptionsTableData,
      $$JobPayrollOptionsTableTableFilterComposer,
      $$JobPayrollOptionsTableTableOrderingComposer,
      $$JobPayrollOptionsTableTableAnnotationComposer,
      $$JobPayrollOptionsTableTableCreateCompanionBuilder,
      $$JobPayrollOptionsTableTableUpdateCompanionBuilder,
      (JobPayrollOptionsTableData, $$JobPayrollOptionsTableTableReferences),
      JobPayrollOptionsTableData,
      PrefetchHooks Function({bool jobId})
    >;
typedef $$ShiftsTableCreateCompanionBuilder =
    ShiftsCompanion Function({
      Value<int> id,
      required int jobId,
      required DateTime startAt,
      required DateTime endAt,
      Value<int> breakMinutes,
      Value<DateTime?> breakStartAt,
      required int hourlyWageSnapshot,
      Value<String?> memo,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$ShiftsTableUpdateCompanionBuilder =
    ShiftsCompanion Function({
      Value<int> id,
      Value<int> jobId,
      Value<DateTime> startAt,
      Value<DateTime> endAt,
      Value<int> breakMinutes,
      Value<DateTime?> breakStartAt,
      Value<int> hourlyWageSnapshot,
      Value<String?> memo,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$ShiftsTableReferences
    extends BaseReferences<_$AppDatabase, $ShiftsTable, Shift> {
  $$ShiftsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $JobsTable _jobIdTable(_$AppDatabase db) =>
      db.jobs.createAlias($_aliasNameGenerator(db.shifts.jobId, db.jobs.id));

  $$JobsTableProcessedTableManager get jobId {
    final $_column = $_itemColumn<int>('job_id')!;

    final manager = $$JobsTableTableManager(
      $_db,
      $_db.jobs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_jobIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ShiftsTableFilterComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startAt => $composableBuilder(
    column: $table.startAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endAt => $composableBuilder(
    column: $table.endAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get breakMinutes => $composableBuilder(
    column: $table.breakMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get breakStartAt => $composableBuilder(
    column: $table.breakStartAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hourlyWageSnapshot => $composableBuilder(
    column: $table.hourlyWageSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$JobsTableFilterComposer get jobId {
    final $$JobsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jobId,
      referencedTable: $db.jobs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobsTableFilterComposer(
            $db: $db,
            $table: $db.jobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShiftsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startAt => $composableBuilder(
    column: $table.startAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endAt => $composableBuilder(
    column: $table.endAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get breakMinutes => $composableBuilder(
    column: $table.breakMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get breakStartAt => $composableBuilder(
    column: $table.breakStartAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hourlyWageSnapshot => $composableBuilder(
    column: $table.hourlyWageSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$JobsTableOrderingComposer get jobId {
    final $$JobsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jobId,
      referencedTable: $db.jobs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobsTableOrderingComposer(
            $db: $db,
            $table: $db.jobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShiftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startAt =>
      $composableBuilder(column: $table.startAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endAt =>
      $composableBuilder(column: $table.endAt, builder: (column) => column);

  GeneratedColumn<int> get breakMinutes => $composableBuilder(
    column: $table.breakMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get breakStartAt => $composableBuilder(
    column: $table.breakStartAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hourlyWageSnapshot => $composableBuilder(
    column: $table.hourlyWageSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$JobsTableAnnotationComposer get jobId {
    final $$JobsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jobId,
      referencedTable: $db.jobs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobsTableAnnotationComposer(
            $db: $db,
            $table: $db.jobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShiftsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShiftsTable,
          Shift,
          $$ShiftsTableFilterComposer,
          $$ShiftsTableOrderingComposer,
          $$ShiftsTableAnnotationComposer,
          $$ShiftsTableCreateCompanionBuilder,
          $$ShiftsTableUpdateCompanionBuilder,
          (Shift, $$ShiftsTableReferences),
          Shift,
          PrefetchHooks Function({bool jobId})
        > {
  $$ShiftsTableTableManager(_$AppDatabase db, $ShiftsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShiftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShiftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShiftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> jobId = const Value.absent(),
                Value<DateTime> startAt = const Value.absent(),
                Value<DateTime> endAt = const Value.absent(),
                Value<int> breakMinutes = const Value.absent(),
                Value<DateTime?> breakStartAt = const Value.absent(),
                Value<int> hourlyWageSnapshot = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ShiftsCompanion(
                id: id,
                jobId: jobId,
                startAt: startAt,
                endAt: endAt,
                breakMinutes: breakMinutes,
                breakStartAt: breakStartAt,
                hourlyWageSnapshot: hourlyWageSnapshot,
                memo: memo,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int jobId,
                required DateTime startAt,
                required DateTime endAt,
                Value<int> breakMinutes = const Value.absent(),
                Value<DateTime?> breakStartAt = const Value.absent(),
                required int hourlyWageSnapshot,
                Value<String?> memo = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => ShiftsCompanion.insert(
                id: id,
                jobId: jobId,
                startAt: startAt,
                endAt: endAt,
                breakMinutes: breakMinutes,
                breakStartAt: breakStartAt,
                hourlyWageSnapshot: hourlyWageSnapshot,
                memo: memo,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$ShiftsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({jobId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (jobId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.jobId,
                                referencedTable: $$ShiftsTableReferences
                                    ._jobIdTable(db),
                                referencedColumn: $$ShiftsTableReferences
                                    ._jobIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ShiftsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShiftsTable,
      Shift,
      $$ShiftsTableFilterComposer,
      $$ShiftsTableOrderingComposer,
      $$ShiftsTableAnnotationComposer,
      $$ShiftsTableCreateCompanionBuilder,
      $$ShiftsTableUpdateCompanionBuilder,
      (Shift, $$ShiftsTableReferences),
      Shift,
      PrefetchHooks Function({bool jobId})
    >;
typedef $$AppSettingsTableTableCreateCompanionBuilder =
    AppSettingsTableCompanion Function({
      Value<int> id,
      required int schemaVersion,
      Value<String> themeMode,
      Value<String> locale,
      Value<DateTime?> lastBackupAt,
      Value<String?> payrollConstantsJson,
      Value<bool> use24HourFormat,
      Value<String?> undoStackJson,
      required DateTime updatedAt,
    });
typedef $$AppSettingsTableTableUpdateCompanionBuilder =
    AppSettingsTableCompanion Function({
      Value<int> id,
      Value<int> schemaVersion,
      Value<String> themeMode,
      Value<String> locale,
      Value<DateTime?> lastBackupAt,
      Value<String?> payrollConstantsJson,
      Value<bool> use24HourFormat,
      Value<String?> undoStackJson,
      Value<DateTime> updatedAt,
    });

class $$AppSettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastBackupAt => $composableBuilder(
    column: $table.lastBackupAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payrollConstantsJson => $composableBuilder(
    column: $table.payrollConstantsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get use24HourFormat => $composableBuilder(
    column: $table.use24HourFormat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get undoStackJson => $composableBuilder(
    column: $table.undoStackJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastBackupAt => $composableBuilder(
    column: $table.lastBackupAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payrollConstantsJson => $composableBuilder(
    column: $table.payrollConstantsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get use24HourFormat => $composableBuilder(
    column: $table.use24HourFormat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get undoStackJson => $composableBuilder(
    column: $table.undoStackJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<DateTime> get lastBackupAt => $composableBuilder(
    column: $table.lastBackupAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payrollConstantsJson => $composableBuilder(
    column: $table.payrollConstantsJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get use24HourFormat => $composableBuilder(
    column: $table.use24HourFormat,
    builder: (column) => column,
  );

  GeneratedColumn<String> get undoStackJson => $composableBuilder(
    column: $table.undoStackJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTableTable,
          AppSettingsTableData,
          $$AppSettingsTableTableFilterComposer,
          $$AppSettingsTableTableOrderingComposer,
          $$AppSettingsTableTableAnnotationComposer,
          $$AppSettingsTableTableCreateCompanionBuilder,
          $$AppSettingsTableTableUpdateCompanionBuilder,
          (
            AppSettingsTableData,
            BaseReferences<
              _$AppDatabase,
              $AppSettingsTableTable,
              AppSettingsTableData
            >,
          ),
          AppSettingsTableData,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableTableManager(
    _$AppDatabase db,
    $AppSettingsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<DateTime?> lastBackupAt = const Value.absent(),
                Value<String?> payrollConstantsJson = const Value.absent(),
                Value<bool> use24HourFormat = const Value.absent(),
                Value<String?> undoStackJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AppSettingsTableCompanion(
                id: id,
                schemaVersion: schemaVersion,
                themeMode: themeMode,
                locale: locale,
                lastBackupAt: lastBackupAt,
                payrollConstantsJson: payrollConstantsJson,
                use24HourFormat: use24HourFormat,
                undoStackJson: undoStackJson,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int schemaVersion,
                Value<String> themeMode = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<DateTime?> lastBackupAt = const Value.absent(),
                Value<String?> payrollConstantsJson = const Value.absent(),
                Value<bool> use24HourFormat = const Value.absent(),
                Value<String?> undoStackJson = const Value.absent(),
                required DateTime updatedAt,
              }) => AppSettingsTableCompanion.insert(
                id: id,
                schemaVersion: schemaVersion,
                themeMode: themeMode,
                locale: locale,
                lastBackupAt: lastBackupAt,
                payrollConstantsJson: payrollConstantsJson,
                use24HourFormat: use24HourFormat,
                undoStackJson: undoStackJson,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTableTable,
      AppSettingsTableData,
      $$AppSettingsTableTableFilterComposer,
      $$AppSettingsTableTableOrderingComposer,
      $$AppSettingsTableTableAnnotationComposer,
      $$AppSettingsTableTableCreateCompanionBuilder,
      $$AppSettingsTableTableUpdateCompanionBuilder,
      (
        AppSettingsTableData,
        BaseReferences<
          _$AppDatabase,
          $AppSettingsTableTable,
          AppSettingsTableData
        >,
      ),
      AppSettingsTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$JobsTableTableManager get jobs => $$JobsTableTableManager(_db, _db.jobs);
  $$JobPayrollOptionsTableTableTableManager get jobPayrollOptionsTable =>
      $$JobPayrollOptionsTableTableTableManager(
        _db,
        _db.jobPayrollOptionsTable,
      );
  $$ShiftsTableTableManager get shifts =>
      $$ShiftsTableTableManager(_db, _db.shifts);
  $$AppSettingsTableTableTableManager get appSettingsTable =>
      $$AppSettingsTableTableTableManager(_db, _db.appSettingsTable);
}
