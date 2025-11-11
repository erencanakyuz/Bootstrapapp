// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $HabitsTable extends Habits with TableInfo<$HabitsTable, Habit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconCodePointMeta = const VerificationMeta(
    'iconCodePoint',
  );
  @override
  late final GeneratedColumn<int> iconCodePoint = GeneratedColumn<int>(
    'icon_code_point',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeBlockMeta = const VerificationMeta(
    'timeBlock',
  );
  @override
  late final GeneratedColumn<String> timeBlock = GeneratedColumn<String>(
    'time_block',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weeklyTargetMeta = const VerificationMeta(
    'weeklyTarget',
  );
  @override
  late final GeneratedColumn<int> weeklyTarget = GeneratedColumn<int>(
    'weekly_target',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _monthlyTargetMeta = const VerificationMeta(
    'monthlyTarget',
  );
  @override
  late final GeneratedColumn<int> monthlyTarget = GeneratedColumn<int>(
    'monthly_target',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(20),
  );
  static const VerificationMeta _freezeUsesThisWeekMeta =
      const VerificationMeta('freezeUsesThisWeek');
  @override
  late final GeneratedColumn<int> freezeUsesThisWeek = GeneratedColumn<int>(
    'freeze_uses_this_week',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastFreezeResetMeta = const VerificationMeta(
    'lastFreezeReset',
  );
  @override
  late final GeneratedColumn<DateTime> lastFreezeReset =
      GeneratedColumn<DateTime>(
        'last_freeze_reset',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
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
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    color,
    iconCodePoint,
    createdAt,
    category,
    timeBlock,
    difficulty,
    archived,
    archivedAt,
    weeklyTarget,
    monthlyTarget,
    freezeUsesThisWeek,
    lastFreezeReset,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habits';
  @override
  VerificationContext validateIntegrity(
    Insertable<Habit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('icon_code_point')) {
      context.handle(
        _iconCodePointMeta,
        iconCodePoint.isAcceptableOrUnknown(
          data['icon_code_point']!,
          _iconCodePointMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_iconCodePointMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('time_block')) {
      context.handle(
        _timeBlockMeta,
        timeBlock.isAcceptableOrUnknown(data['time_block']!, _timeBlockMeta),
      );
    } else if (isInserting) {
      context.missing(_timeBlockMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    } else if (isInserting) {
      context.missing(_difficultyMeta);
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    if (data.containsKey('weekly_target')) {
      context.handle(
        _weeklyTargetMeta,
        weeklyTarget.isAcceptableOrUnknown(
          data['weekly_target']!,
          _weeklyTargetMeta,
        ),
      );
    }
    if (data.containsKey('monthly_target')) {
      context.handle(
        _monthlyTargetMeta,
        monthlyTarget.isAcceptableOrUnknown(
          data['monthly_target']!,
          _monthlyTargetMeta,
        ),
      );
    }
    if (data.containsKey('freeze_uses_this_week')) {
      context.handle(
        _freezeUsesThisWeekMeta,
        freezeUsesThisWeek.isAcceptableOrUnknown(
          data['freeze_uses_this_week']!,
          _freezeUsesThisWeekMeta,
        ),
      );
    }
    if (data.containsKey('last_freeze_reset')) {
      context.handle(
        _lastFreezeResetMeta,
        lastFreezeReset.isAcceptableOrUnknown(
          data['last_freeze_reset']!,
          _lastFreezeResetMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Habit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Habit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      iconCodePoint: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}icon_code_point'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      timeBlock: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_block'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}difficulty'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
      weeklyTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekly_target'],
      )!,
      monthlyTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monthly_target'],
      )!,
      freezeUsesThisWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}freeze_uses_this_week'],
      )!,
      lastFreezeReset: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_freeze_reset'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $HabitsTable createAlias(String alias) {
    return $HabitsTable(attachedDatabase, alias);
  }
}

class Habit extends DataClass implements Insertable<Habit> {
  final String id;
  final String title;
  final String? description;
  final int color;
  final int iconCodePoint;
  final DateTime createdAt;
  final String category;
  final String timeBlock;
  final String difficulty;
  final bool archived;
  final DateTime? archivedAt;
  final int weeklyTarget;
  final int monthlyTarget;
  final int freezeUsesThisWeek;
  final DateTime? lastFreezeReset;
  final DateTime updatedAt;
  const Habit({
    required this.id,
    required this.title,
    this.description,
    required this.color,
    required this.iconCodePoint,
    required this.createdAt,
    required this.category,
    required this.timeBlock,
    required this.difficulty,
    required this.archived,
    this.archivedAt,
    required this.weeklyTarget,
    required this.monthlyTarget,
    required this.freezeUsesThisWeek,
    this.lastFreezeReset,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['color'] = Variable<int>(color);
    map['icon_code_point'] = Variable<int>(iconCodePoint);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['category'] = Variable<String>(category);
    map['time_block'] = Variable<String>(timeBlock);
    map['difficulty'] = Variable<String>(difficulty);
    map['archived'] = Variable<bool>(archived);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    map['weekly_target'] = Variable<int>(weeklyTarget);
    map['monthly_target'] = Variable<int>(monthlyTarget);
    map['freeze_uses_this_week'] = Variable<int>(freezeUsesThisWeek);
    if (!nullToAbsent || lastFreezeReset != null) {
      map['last_freeze_reset'] = Variable<DateTime>(lastFreezeReset);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  HabitsCompanion toCompanion(bool nullToAbsent) {
    return HabitsCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      color: Value(color),
      iconCodePoint: Value(iconCodePoint),
      createdAt: Value(createdAt),
      category: Value(category),
      timeBlock: Value(timeBlock),
      difficulty: Value(difficulty),
      archived: Value(archived),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
      weeklyTarget: Value(weeklyTarget),
      monthlyTarget: Value(monthlyTarget),
      freezeUsesThisWeek: Value(freezeUsesThisWeek),
      lastFreezeReset: lastFreezeReset == null && nullToAbsent
          ? const Value.absent()
          : Value(lastFreezeReset),
      updatedAt: Value(updatedAt),
    );
  }

  factory Habit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Habit(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      color: serializer.fromJson<int>(json['color']),
      iconCodePoint: serializer.fromJson<int>(json['iconCodePoint']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      category: serializer.fromJson<String>(json['category']),
      timeBlock: serializer.fromJson<String>(json['timeBlock']),
      difficulty: serializer.fromJson<String>(json['difficulty']),
      archived: serializer.fromJson<bool>(json['archived']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
      weeklyTarget: serializer.fromJson<int>(json['weeklyTarget']),
      monthlyTarget: serializer.fromJson<int>(json['monthlyTarget']),
      freezeUsesThisWeek: serializer.fromJson<int>(json['freezeUsesThisWeek']),
      lastFreezeReset: serializer.fromJson<DateTime?>(json['lastFreezeReset']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'color': serializer.toJson<int>(color),
      'iconCodePoint': serializer.toJson<int>(iconCodePoint),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'category': serializer.toJson<String>(category),
      'timeBlock': serializer.toJson<String>(timeBlock),
      'difficulty': serializer.toJson<String>(difficulty),
      'archived': serializer.toJson<bool>(archived),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
      'weeklyTarget': serializer.toJson<int>(weeklyTarget),
      'monthlyTarget': serializer.toJson<int>(monthlyTarget),
      'freezeUsesThisWeek': serializer.toJson<int>(freezeUsesThisWeek),
      'lastFreezeReset': serializer.toJson<DateTime?>(lastFreezeReset),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Habit copyWith({
    String? id,
    String? title,
    Value<String?> description = const Value.absent(),
    int? color,
    int? iconCodePoint,
    DateTime? createdAt,
    String? category,
    String? timeBlock,
    String? difficulty,
    bool? archived,
    Value<DateTime?> archivedAt = const Value.absent(),
    int? weeklyTarget,
    int? monthlyTarget,
    int? freezeUsesThisWeek,
    Value<DateTime?> lastFreezeReset = const Value.absent(),
    DateTime? updatedAt,
  }) => Habit(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    color: color ?? this.color,
    iconCodePoint: iconCodePoint ?? this.iconCodePoint,
    createdAt: createdAt ?? this.createdAt,
    category: category ?? this.category,
    timeBlock: timeBlock ?? this.timeBlock,
    difficulty: difficulty ?? this.difficulty,
    archived: archived ?? this.archived,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
    weeklyTarget: weeklyTarget ?? this.weeklyTarget,
    monthlyTarget: monthlyTarget ?? this.monthlyTarget,
    freezeUsesThisWeek: freezeUsesThisWeek ?? this.freezeUsesThisWeek,
    lastFreezeReset: lastFreezeReset.present
        ? lastFreezeReset.value
        : this.lastFreezeReset,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Habit copyWithCompanion(HabitsCompanion data) {
    return Habit(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      color: data.color.present ? data.color.value : this.color,
      iconCodePoint: data.iconCodePoint.present
          ? data.iconCodePoint.value
          : this.iconCodePoint,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      category: data.category.present ? data.category.value : this.category,
      timeBlock: data.timeBlock.present ? data.timeBlock.value : this.timeBlock,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      archived: data.archived.present ? data.archived.value : this.archived,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
      weeklyTarget: data.weeklyTarget.present
          ? data.weeklyTarget.value
          : this.weeklyTarget,
      monthlyTarget: data.monthlyTarget.present
          ? data.monthlyTarget.value
          : this.monthlyTarget,
      freezeUsesThisWeek: data.freezeUsesThisWeek.present
          ? data.freezeUsesThisWeek.value
          : this.freezeUsesThisWeek,
      lastFreezeReset: data.lastFreezeReset.present
          ? data.lastFreezeReset.value
          : this.lastFreezeReset,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Habit(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('color: $color, ')
          ..write('iconCodePoint: $iconCodePoint, ')
          ..write('createdAt: $createdAt, ')
          ..write('category: $category, ')
          ..write('timeBlock: $timeBlock, ')
          ..write('difficulty: $difficulty, ')
          ..write('archived: $archived, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('weeklyTarget: $weeklyTarget, ')
          ..write('monthlyTarget: $monthlyTarget, ')
          ..write('freezeUsesThisWeek: $freezeUsesThisWeek, ')
          ..write('lastFreezeReset: $lastFreezeReset, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    color,
    iconCodePoint,
    createdAt,
    category,
    timeBlock,
    difficulty,
    archived,
    archivedAt,
    weeklyTarget,
    monthlyTarget,
    freezeUsesThisWeek,
    lastFreezeReset,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Habit &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.color == this.color &&
          other.iconCodePoint == this.iconCodePoint &&
          other.createdAt == this.createdAt &&
          other.category == this.category &&
          other.timeBlock == this.timeBlock &&
          other.difficulty == this.difficulty &&
          other.archived == this.archived &&
          other.archivedAt == this.archivedAt &&
          other.weeklyTarget == this.weeklyTarget &&
          other.monthlyTarget == this.monthlyTarget &&
          other.freezeUsesThisWeek == this.freezeUsesThisWeek &&
          other.lastFreezeReset == this.lastFreezeReset &&
          other.updatedAt == this.updatedAt);
}

class HabitsCompanion extends UpdateCompanion<Habit> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<int> color;
  final Value<int> iconCodePoint;
  final Value<DateTime> createdAt;
  final Value<String> category;
  final Value<String> timeBlock;
  final Value<String> difficulty;
  final Value<bool> archived;
  final Value<DateTime?> archivedAt;
  final Value<int> weeklyTarget;
  final Value<int> monthlyTarget;
  final Value<int> freezeUsesThisWeek;
  final Value<DateTime?> lastFreezeReset;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const HabitsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.color = const Value.absent(),
    this.iconCodePoint = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.category = const Value.absent(),
    this.timeBlock = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.archived = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.weeklyTarget = const Value.absent(),
    this.monthlyTarget = const Value.absent(),
    this.freezeUsesThisWeek = const Value.absent(),
    this.lastFreezeReset = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitsCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    required int color,
    required int iconCodePoint,
    required DateTime createdAt,
    required String category,
    required String timeBlock,
    required String difficulty,
    this.archived = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.weeklyTarget = const Value.absent(),
    this.monthlyTarget = const Value.absent(),
    this.freezeUsesThisWeek = const Value.absent(),
    this.lastFreezeReset = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       color = Value(color),
       iconCodePoint = Value(iconCodePoint),
       createdAt = Value(createdAt),
       category = Value(category),
       timeBlock = Value(timeBlock),
       difficulty = Value(difficulty);
  static Insertable<Habit> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? color,
    Expression<int>? iconCodePoint,
    Expression<DateTime>? createdAt,
    Expression<String>? category,
    Expression<String>? timeBlock,
    Expression<String>? difficulty,
    Expression<bool>? archived,
    Expression<DateTime>? archivedAt,
    Expression<int>? weeklyTarget,
    Expression<int>? monthlyTarget,
    Expression<int>? freezeUsesThisWeek,
    Expression<DateTime>? lastFreezeReset,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (color != null) 'color': color,
      if (iconCodePoint != null) 'icon_code_point': iconCodePoint,
      if (createdAt != null) 'created_at': createdAt,
      if (category != null) 'category': category,
      if (timeBlock != null) 'time_block': timeBlock,
      if (difficulty != null) 'difficulty': difficulty,
      if (archived != null) 'archived': archived,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (weeklyTarget != null) 'weekly_target': weeklyTarget,
      if (monthlyTarget != null) 'monthly_target': monthlyTarget,
      if (freezeUsesThisWeek != null)
        'freeze_uses_this_week': freezeUsesThisWeek,
      if (lastFreezeReset != null) 'last_freeze_reset': lastFreezeReset,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? description,
    Value<int>? color,
    Value<int>? iconCodePoint,
    Value<DateTime>? createdAt,
    Value<String>? category,
    Value<String>? timeBlock,
    Value<String>? difficulty,
    Value<bool>? archived,
    Value<DateTime?>? archivedAt,
    Value<int>? weeklyTarget,
    Value<int>? monthlyTarget,
    Value<int>? freezeUsesThisWeek,
    Value<DateTime?>? lastFreezeReset,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return HabitsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      color: color ?? this.color,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      timeBlock: timeBlock ?? this.timeBlock,
      difficulty: difficulty ?? this.difficulty,
      archived: archived ?? this.archived,
      archivedAt: archivedAt ?? this.archivedAt,
      weeklyTarget: weeklyTarget ?? this.weeklyTarget,
      monthlyTarget: monthlyTarget ?? this.monthlyTarget,
      freezeUsesThisWeek: freezeUsesThisWeek ?? this.freezeUsesThisWeek,
      lastFreezeReset: lastFreezeReset ?? this.lastFreezeReset,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (iconCodePoint.present) {
      map['icon_code_point'] = Variable<int>(iconCodePoint.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (timeBlock.present) {
      map['time_block'] = Variable<String>(timeBlock.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (weeklyTarget.present) {
      map['weekly_target'] = Variable<int>(weeklyTarget.value);
    }
    if (monthlyTarget.present) {
      map['monthly_target'] = Variable<int>(monthlyTarget.value);
    }
    if (freezeUsesThisWeek.present) {
      map['freeze_uses_this_week'] = Variable<int>(freezeUsesThisWeek.value);
    }
    if (lastFreezeReset.present) {
      map['last_freeze_reset'] = Variable<DateTime>(lastFreezeReset.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('color: $color, ')
          ..write('iconCodePoint: $iconCodePoint, ')
          ..write('createdAt: $createdAt, ')
          ..write('category: $category, ')
          ..write('timeBlock: $timeBlock, ')
          ..write('difficulty: $difficulty, ')
          ..write('archived: $archived, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('weeklyTarget: $weeklyTarget, ')
          ..write('monthlyTarget: $monthlyTarget, ')
          ..write('freezeUsesThisWeek: $freezeUsesThisWeek, ')
          ..write('lastFreezeReset: $lastFreezeReset, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HabitCompletionsTable extends HabitCompletions
    with TableInfo<$HabitCompletionsTable, HabitCompletion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitCompletionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<String> habitId = GeneratedColumn<String>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completionDateMeta = const VerificationMeta(
    'completionDate',
  );
  @override
  late final GeneratedColumn<DateTime> completionDate =
      GeneratedColumn<DateTime>(
        'completion_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
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
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    habitId,
    completionDate,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habit_completions';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitCompletion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('completion_date')) {
      context.handle(
        _completionDateMeta,
        completionDate.isAcceptableOrUnknown(
          data['completion_date']!,
          _completionDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completionDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HabitCompletion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitCompletion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habit_id'],
      )!,
      completionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completion_date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $HabitCompletionsTable createAlias(String alias) {
    return $HabitCompletionsTable(attachedDatabase, alias);
  }
}

class HabitCompletion extends DataClass implements Insertable<HabitCompletion> {
  final String id;
  final String habitId;
  final DateTime completionDate;
  final DateTime createdAt;
  const HabitCompletion({
    required this.id,
    required this.habitId,
    required this.completionDate,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['habit_id'] = Variable<String>(habitId);
    map['completion_date'] = Variable<DateTime>(completionDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  HabitCompletionsCompanion toCompanion(bool nullToAbsent) {
    return HabitCompletionsCompanion(
      id: Value(id),
      habitId: Value(habitId),
      completionDate: Value(completionDate),
      createdAt: Value(createdAt),
    );
  }

  factory HabitCompletion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitCompletion(
      id: serializer.fromJson<String>(json['id']),
      habitId: serializer.fromJson<String>(json['habitId']),
      completionDate: serializer.fromJson<DateTime>(json['completionDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'habitId': serializer.toJson<String>(habitId),
      'completionDate': serializer.toJson<DateTime>(completionDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  HabitCompletion copyWith({
    String? id,
    String? habitId,
    DateTime? completionDate,
    DateTime? createdAt,
  }) => HabitCompletion(
    id: id ?? this.id,
    habitId: habitId ?? this.habitId,
    completionDate: completionDate ?? this.completionDate,
    createdAt: createdAt ?? this.createdAt,
  );
  HabitCompletion copyWithCompanion(HabitCompletionsCompanion data) {
    return HabitCompletion(
      id: data.id.present ? data.id.value : this.id,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      completionDate: data.completionDate.present
          ? data.completionDate.value
          : this.completionDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitCompletion(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('completionDate: $completionDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, habitId, completionDate, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitCompletion &&
          other.id == this.id &&
          other.habitId == this.habitId &&
          other.completionDate == this.completionDate &&
          other.createdAt == this.createdAt);
}

class HabitCompletionsCompanion extends UpdateCompanion<HabitCompletion> {
  final Value<String> id;
  final Value<String> habitId;
  final Value<DateTime> completionDate;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const HabitCompletionsCompanion({
    this.id = const Value.absent(),
    this.habitId = const Value.absent(),
    this.completionDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitCompletionsCompanion.insert({
    required String id,
    required String habitId,
    required DateTime completionDate,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       habitId = Value(habitId),
       completionDate = Value(completionDate);
  static Insertable<HabitCompletion> custom({
    Expression<String>? id,
    Expression<String>? habitId,
    Expression<DateTime>? completionDate,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (habitId != null) 'habit_id': habitId,
      if (completionDate != null) 'completion_date': completionDate,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitCompletionsCompanion copyWith({
    Value<String>? id,
    Value<String>? habitId,
    Value<DateTime>? completionDate,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return HabitCompletionsCompanion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      completionDate: completionDate ?? this.completionDate,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<String>(habitId.value);
    }
    if (completionDate.present) {
      map['completion_date'] = Variable<DateTime>(completionDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitCompletionsCompanion(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('completionDate: $completionDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HabitNotesTable extends HabitNotes
    with TableInfo<$HabitNotesTable, HabitNote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<String> habitId = GeneratedColumn<String>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteDateMeta = const VerificationMeta(
    'noteDate',
  );
  @override
  late final GeneratedColumn<DateTime> noteDate = GeneratedColumn<DateTime>(
    'note_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteTextMeta = const VerificationMeta(
    'noteText',
  );
  @override
  late final GeneratedColumn<String> noteText = GeneratedColumn<String>(
    'note_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    habitId,
    noteDate,
    noteText,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habit_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitNote> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('note_date')) {
      context.handle(
        _noteDateMeta,
        noteDate.isAcceptableOrUnknown(data['note_date']!, _noteDateMeta),
      );
    } else if (isInserting) {
      context.missing(_noteDateMeta);
    }
    if (data.containsKey('note_text')) {
      context.handle(
        _noteTextMeta,
        noteText.isAcceptableOrUnknown(data['note_text']!, _noteTextMeta),
      );
    } else if (isInserting) {
      context.missing(_noteTextMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HabitNote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitNote(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habit_id'],
      )!,
      noteDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}note_date'],
      )!,
      noteText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_text'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $HabitNotesTable createAlias(String alias) {
    return $HabitNotesTable(attachedDatabase, alias);
  }
}

class HabitNote extends DataClass implements Insertable<HabitNote> {
  final String id;
  final String habitId;
  final DateTime noteDate;
  final String noteText;
  final DateTime createdAt;
  const HabitNote({
    required this.id,
    required this.habitId,
    required this.noteDate,
    required this.noteText,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['habit_id'] = Variable<String>(habitId);
    map['note_date'] = Variable<DateTime>(noteDate);
    map['note_text'] = Variable<String>(noteText);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  HabitNotesCompanion toCompanion(bool nullToAbsent) {
    return HabitNotesCompanion(
      id: Value(id),
      habitId: Value(habitId),
      noteDate: Value(noteDate),
      noteText: Value(noteText),
      createdAt: Value(createdAt),
    );
  }

  factory HabitNote.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitNote(
      id: serializer.fromJson<String>(json['id']),
      habitId: serializer.fromJson<String>(json['habitId']),
      noteDate: serializer.fromJson<DateTime>(json['noteDate']),
      noteText: serializer.fromJson<String>(json['noteText']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'habitId': serializer.toJson<String>(habitId),
      'noteDate': serializer.toJson<DateTime>(noteDate),
      'noteText': serializer.toJson<String>(noteText),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  HabitNote copyWith({
    String? id,
    String? habitId,
    DateTime? noteDate,
    String? noteText,
    DateTime? createdAt,
  }) => HabitNote(
    id: id ?? this.id,
    habitId: habitId ?? this.habitId,
    noteDate: noteDate ?? this.noteDate,
    noteText: noteText ?? this.noteText,
    createdAt: createdAt ?? this.createdAt,
  );
  HabitNote copyWithCompanion(HabitNotesCompanion data) {
    return HabitNote(
      id: data.id.present ? data.id.value : this.id,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      noteDate: data.noteDate.present ? data.noteDate.value : this.noteDate,
      noteText: data.noteText.present ? data.noteText.value : this.noteText,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitNote(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('noteDate: $noteDate, ')
          ..write('noteText: $noteText, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, habitId, noteDate, noteText, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitNote &&
          other.id == this.id &&
          other.habitId == this.habitId &&
          other.noteDate == this.noteDate &&
          other.noteText == this.noteText &&
          other.createdAt == this.createdAt);
}

class HabitNotesCompanion extends UpdateCompanion<HabitNote> {
  final Value<String> id;
  final Value<String> habitId;
  final Value<DateTime> noteDate;
  final Value<String> noteText;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const HabitNotesCompanion({
    this.id = const Value.absent(),
    this.habitId = const Value.absent(),
    this.noteDate = const Value.absent(),
    this.noteText = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitNotesCompanion.insert({
    required String id,
    required String habitId,
    required DateTime noteDate,
    required String noteText,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       habitId = Value(habitId),
       noteDate = Value(noteDate),
       noteText = Value(noteText);
  static Insertable<HabitNote> custom({
    Expression<String>? id,
    Expression<String>? habitId,
    Expression<DateTime>? noteDate,
    Expression<String>? noteText,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (habitId != null) 'habit_id': habitId,
      if (noteDate != null) 'note_date': noteDate,
      if (noteText != null) 'note_text': noteText,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitNotesCompanion copyWith({
    Value<String>? id,
    Value<String>? habitId,
    Value<DateTime>? noteDate,
    Value<String>? noteText,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return HabitNotesCompanion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      noteDate: noteDate ?? this.noteDate,
      noteText: noteText ?? this.noteText,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<String>(habitId.value);
    }
    if (noteDate.present) {
      map['note_date'] = Variable<DateTime>(noteDate.value);
    }
    if (noteText.present) {
      map['note_text'] = Variable<String>(noteText.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitNotesCompanion(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('noteDate: $noteDate, ')
          ..write('noteText: $noteText, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HabitTasksTable extends HabitTasks
    with TableInfo<$HabitTasksTable, HabitTask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<String> habitId = GeneratedColumn<String>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    habitId,
    title,
    completed,
    completedAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habit_tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitTask> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HabitTask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitTask(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habit_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $HabitTasksTable createAlias(String alias) {
    return $HabitTasksTable(attachedDatabase, alias);
  }
}

class HabitTask extends DataClass implements Insertable<HabitTask> {
  final String id;
  final String habitId;
  final String title;
  final bool completed;
  final DateTime? completedAt;
  final DateTime createdAt;
  const HabitTask({
    required this.id,
    required this.habitId,
    required this.title,
    required this.completed,
    this.completedAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['habit_id'] = Variable<String>(habitId);
    map['title'] = Variable<String>(title);
    map['completed'] = Variable<bool>(completed);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  HabitTasksCompanion toCompanion(bool nullToAbsent) {
    return HabitTasksCompanion(
      id: Value(id),
      habitId: Value(habitId),
      title: Value(title),
      completed: Value(completed),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      createdAt: Value(createdAt),
    );
  }

  factory HabitTask.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitTask(
      id: serializer.fromJson<String>(json['id']),
      habitId: serializer.fromJson<String>(json['habitId']),
      title: serializer.fromJson<String>(json['title']),
      completed: serializer.fromJson<bool>(json['completed']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'habitId': serializer.toJson<String>(habitId),
      'title': serializer.toJson<String>(title),
      'completed': serializer.toJson<bool>(completed),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  HabitTask copyWith({
    String? id,
    String? habitId,
    String? title,
    bool? completed,
    Value<DateTime?> completedAt = const Value.absent(),
    DateTime? createdAt,
  }) => HabitTask(
    id: id ?? this.id,
    habitId: habitId ?? this.habitId,
    title: title ?? this.title,
    completed: completed ?? this.completed,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    createdAt: createdAt ?? this.createdAt,
  );
  HabitTask copyWithCompanion(HabitTasksCompanion data) {
    return HabitTask(
      id: data.id.present ? data.id.value : this.id,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      title: data.title.present ? data.title.value : this.title,
      completed: data.completed.present ? data.completed.value : this.completed,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitTask(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('title: $title, ')
          ..write('completed: $completed, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, habitId, title, completed, completedAt, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitTask &&
          other.id == this.id &&
          other.habitId == this.habitId &&
          other.title == this.title &&
          other.completed == this.completed &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt);
}

class HabitTasksCompanion extends UpdateCompanion<HabitTask> {
  final Value<String> id;
  final Value<String> habitId;
  final Value<String> title;
  final Value<bool> completed;
  final Value<DateTime?> completedAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const HabitTasksCompanion({
    this.id = const Value.absent(),
    this.habitId = const Value.absent(),
    this.title = const Value.absent(),
    this.completed = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitTasksCompanion.insert({
    required String id,
    required String habitId,
    required String title,
    this.completed = const Value.absent(),
    this.completedAt = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       habitId = Value(habitId),
       title = Value(title),
       createdAt = Value(createdAt);
  static Insertable<HabitTask> custom({
    Expression<String>? id,
    Expression<String>? habitId,
    Expression<String>? title,
    Expression<bool>? completed,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (habitId != null) 'habit_id': habitId,
      if (title != null) 'title': title,
      if (completed != null) 'completed': completed,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitTasksCompanion copyWith({
    Value<String>? id,
    Value<String>? habitId,
    Value<String>? title,
    Value<bool>? completed,
    Value<DateTime?>? completedAt,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return HabitTasksCompanion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<String>(habitId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitTasksCompanion(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('title: $title, ')
          ..write('completed: $completed, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HabitRemindersTable extends HabitReminders
    with TableInfo<$HabitRemindersTable, HabitReminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitRemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<String> habitId = GeneratedColumn<String>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hourMeta = const VerificationMeta('hour');
  @override
  late final GeneratedColumn<int> hour = GeneratedColumn<int>(
    'hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minuteMeta = const VerificationMeta('minute');
  @override
  late final GeneratedColumn<int> minute = GeneratedColumn<int>(
    'minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekdaysMeta = const VerificationMeta(
    'weekdays',
  );
  @override
  late final GeneratedColumn<String> weekdays = GeneratedColumn<String>(
    'weekdays',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    habitId,
    hour,
    minute,
    weekdays,
    enabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habit_reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitReminder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('hour')) {
      context.handle(
        _hourMeta,
        hour.isAcceptableOrUnknown(data['hour']!, _hourMeta),
      );
    } else if (isInserting) {
      context.missing(_hourMeta);
    }
    if (data.containsKey('minute')) {
      context.handle(
        _minuteMeta,
        minute.isAcceptableOrUnknown(data['minute']!, _minuteMeta),
      );
    } else if (isInserting) {
      context.missing(_minuteMeta);
    }
    if (data.containsKey('weekdays')) {
      context.handle(
        _weekdaysMeta,
        weekdays.isAcceptableOrUnknown(data['weekdays']!, _weekdaysMeta),
      );
    } else if (isInserting) {
      context.missing(_weekdaysMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HabitReminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitReminder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habit_id'],
      )!,
      hour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hour'],
      )!,
      minute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minute'],
      )!,
      weekdays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weekdays'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
    );
  }

  @override
  $HabitRemindersTable createAlias(String alias) {
    return $HabitRemindersTable(attachedDatabase, alias);
  }
}

class HabitReminder extends DataClass implements Insertable<HabitReminder> {
  final String id;
  final String habitId;
  final int hour;
  final int minute;
  final String weekdays;
  final bool enabled;
  const HabitReminder({
    required this.id,
    required this.habitId,
    required this.hour,
    required this.minute,
    required this.weekdays,
    required this.enabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['habit_id'] = Variable<String>(habitId);
    map['hour'] = Variable<int>(hour);
    map['minute'] = Variable<int>(minute);
    map['weekdays'] = Variable<String>(weekdays);
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  HabitRemindersCompanion toCompanion(bool nullToAbsent) {
    return HabitRemindersCompanion(
      id: Value(id),
      habitId: Value(habitId),
      hour: Value(hour),
      minute: Value(minute),
      weekdays: Value(weekdays),
      enabled: Value(enabled),
    );
  }

  factory HabitReminder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitReminder(
      id: serializer.fromJson<String>(json['id']),
      habitId: serializer.fromJson<String>(json['habitId']),
      hour: serializer.fromJson<int>(json['hour']),
      minute: serializer.fromJson<int>(json['minute']),
      weekdays: serializer.fromJson<String>(json['weekdays']),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'habitId': serializer.toJson<String>(habitId),
      'hour': serializer.toJson<int>(hour),
      'minute': serializer.toJson<int>(minute),
      'weekdays': serializer.toJson<String>(weekdays),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  HabitReminder copyWith({
    String? id,
    String? habitId,
    int? hour,
    int? minute,
    String? weekdays,
    bool? enabled,
  }) => HabitReminder(
    id: id ?? this.id,
    habitId: habitId ?? this.habitId,
    hour: hour ?? this.hour,
    minute: minute ?? this.minute,
    weekdays: weekdays ?? this.weekdays,
    enabled: enabled ?? this.enabled,
  );
  HabitReminder copyWithCompanion(HabitRemindersCompanion data) {
    return HabitReminder(
      id: data.id.present ? data.id.value : this.id,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      hour: data.hour.present ? data.hour.value : this.hour,
      minute: data.minute.present ? data.minute.value : this.minute,
      weekdays: data.weekdays.present ? data.weekdays.value : this.weekdays,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitReminder(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('hour: $hour, ')
          ..write('minute: $minute, ')
          ..write('weekdays: $weekdays, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, habitId, hour, minute, weekdays, enabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitReminder &&
          other.id == this.id &&
          other.habitId == this.habitId &&
          other.hour == this.hour &&
          other.minute == this.minute &&
          other.weekdays == this.weekdays &&
          other.enabled == this.enabled);
}

class HabitRemindersCompanion extends UpdateCompanion<HabitReminder> {
  final Value<String> id;
  final Value<String> habitId;
  final Value<int> hour;
  final Value<int> minute;
  final Value<String> weekdays;
  final Value<bool> enabled;
  final Value<int> rowid;
  const HabitRemindersCompanion({
    this.id = const Value.absent(),
    this.habitId = const Value.absent(),
    this.hour = const Value.absent(),
    this.minute = const Value.absent(),
    this.weekdays = const Value.absent(),
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitRemindersCompanion.insert({
    required String id,
    required String habitId,
    required int hour,
    required int minute,
    required String weekdays,
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       habitId = Value(habitId),
       hour = Value(hour),
       minute = Value(minute),
       weekdays = Value(weekdays);
  static Insertable<HabitReminder> custom({
    Expression<String>? id,
    Expression<String>? habitId,
    Expression<int>? hour,
    Expression<int>? minute,
    Expression<String>? weekdays,
    Expression<bool>? enabled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (habitId != null) 'habit_id': habitId,
      if (hour != null) 'hour': hour,
      if (minute != null) 'minute': minute,
      if (weekdays != null) 'weekdays': weekdays,
      if (enabled != null) 'enabled': enabled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitRemindersCompanion copyWith({
    Value<String>? id,
    Value<String>? habitId,
    Value<int>? hour,
    Value<int>? minute,
    Value<String>? weekdays,
    Value<bool>? enabled,
    Value<int>? rowid,
  }) {
    return HabitRemindersCompanion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      weekdays: weekdays ?? this.weekdays,
      enabled: enabled ?? this.enabled,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<String>(habitId.value);
    }
    if (hour.present) {
      map['hour'] = Variable<int>(hour.value);
    }
    if (minute.present) {
      map['minute'] = Variable<int>(minute.value);
    }
    if (weekdays.present) {
      map['weekdays'] = Variable<String>(weekdays.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitRemindersCompanion(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('hour: $hour, ')
          ..write('minute: $minute, ')
          ..write('weekdays: $weekdays, ')
          ..write('enabled: $enabled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HabitActiveWeekdaysTable extends HabitActiveWeekdays
    with TableInfo<$HabitActiveWeekdaysTable, HabitActiveWeekday> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitActiveWeekdaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<String> habitId = GeneratedColumn<String>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekdayMeta = const VerificationMeta(
    'weekday',
  );
  @override
  late final GeneratedColumn<int> weekday = GeneratedColumn<int>(
    'weekday',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [habitId, weekday];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habit_active_weekdays';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitActiveWeekday> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('weekday')) {
      context.handle(
        _weekdayMeta,
        weekday.isAcceptableOrUnknown(data['weekday']!, _weekdayMeta),
      );
    } else if (isInserting) {
      context.missing(_weekdayMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {habitId, weekday};
  @override
  HabitActiveWeekday map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitActiveWeekday(
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habit_id'],
      )!,
      weekday: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekday'],
      )!,
    );
  }

  @override
  $HabitActiveWeekdaysTable createAlias(String alias) {
    return $HabitActiveWeekdaysTable(attachedDatabase, alias);
  }
}

class HabitActiveWeekday extends DataClass
    implements Insertable<HabitActiveWeekday> {
  final String habitId;
  final int weekday;
  const HabitActiveWeekday({required this.habitId, required this.weekday});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['habit_id'] = Variable<String>(habitId);
    map['weekday'] = Variable<int>(weekday);
    return map;
  }

  HabitActiveWeekdaysCompanion toCompanion(bool nullToAbsent) {
    return HabitActiveWeekdaysCompanion(
      habitId: Value(habitId),
      weekday: Value(weekday),
    );
  }

  factory HabitActiveWeekday.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitActiveWeekday(
      habitId: serializer.fromJson<String>(json['habitId']),
      weekday: serializer.fromJson<int>(json['weekday']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'habitId': serializer.toJson<String>(habitId),
      'weekday': serializer.toJson<int>(weekday),
    };
  }

  HabitActiveWeekday copyWith({String? habitId, int? weekday}) =>
      HabitActiveWeekday(
        habitId: habitId ?? this.habitId,
        weekday: weekday ?? this.weekday,
      );
  HabitActiveWeekday copyWithCompanion(HabitActiveWeekdaysCompanion data) {
    return HabitActiveWeekday(
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      weekday: data.weekday.present ? data.weekday.value : this.weekday,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitActiveWeekday(')
          ..write('habitId: $habitId, ')
          ..write('weekday: $weekday')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(habitId, weekday);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitActiveWeekday &&
          other.habitId == this.habitId &&
          other.weekday == this.weekday);
}

class HabitActiveWeekdaysCompanion extends UpdateCompanion<HabitActiveWeekday> {
  final Value<String> habitId;
  final Value<int> weekday;
  final Value<int> rowid;
  const HabitActiveWeekdaysCompanion({
    this.habitId = const Value.absent(),
    this.weekday = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitActiveWeekdaysCompanion.insert({
    required String habitId,
    required int weekday,
    this.rowid = const Value.absent(),
  }) : habitId = Value(habitId),
       weekday = Value(weekday);
  static Insertable<HabitActiveWeekday> custom({
    Expression<String>? habitId,
    Expression<int>? weekday,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (habitId != null) 'habit_id': habitId,
      if (weekday != null) 'weekday': weekday,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitActiveWeekdaysCompanion copyWith({
    Value<String>? habitId,
    Value<int>? weekday,
    Value<int>? rowid,
  }) {
    return HabitActiveWeekdaysCompanion(
      habitId: habitId ?? this.habitId,
      weekday: weekday ?? this.weekday,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (habitId.present) {
      map['habit_id'] = Variable<String>(habitId.value);
    }
    if (weekday.present) {
      map['weekday'] = Variable<int>(weekday.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitActiveWeekdaysCompanion(')
          ..write('habitId: $habitId, ')
          ..write('weekday: $weekday, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HabitDependenciesTable extends HabitDependencies
    with TableInfo<$HabitDependenciesTable, HabitDependency> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitDependenciesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<String> habitId = GeneratedColumn<String>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dependsOnHabitIdMeta = const VerificationMeta(
    'dependsOnHabitId',
  );
  @override
  late final GeneratedColumn<String> dependsOnHabitId = GeneratedColumn<String>(
    'depends_on_habit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [habitId, dependsOnHabitId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habit_dependencies';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitDependency> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('depends_on_habit_id')) {
      context.handle(
        _dependsOnHabitIdMeta,
        dependsOnHabitId.isAcceptableOrUnknown(
          data['depends_on_habit_id']!,
          _dependsOnHabitIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dependsOnHabitIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {habitId, dependsOnHabitId};
  @override
  HabitDependency map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitDependency(
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habit_id'],
      )!,
      dependsOnHabitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}depends_on_habit_id'],
      )!,
    );
  }

  @override
  $HabitDependenciesTable createAlias(String alias) {
    return $HabitDependenciesTable(attachedDatabase, alias);
  }
}

class HabitDependency extends DataClass implements Insertable<HabitDependency> {
  final String habitId;
  final String dependsOnHabitId;
  const HabitDependency({
    required this.habitId,
    required this.dependsOnHabitId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['habit_id'] = Variable<String>(habitId);
    map['depends_on_habit_id'] = Variable<String>(dependsOnHabitId);
    return map;
  }

  HabitDependenciesCompanion toCompanion(bool nullToAbsent) {
    return HabitDependenciesCompanion(
      habitId: Value(habitId),
      dependsOnHabitId: Value(dependsOnHabitId),
    );
  }

  factory HabitDependency.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitDependency(
      habitId: serializer.fromJson<String>(json['habitId']),
      dependsOnHabitId: serializer.fromJson<String>(json['dependsOnHabitId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'habitId': serializer.toJson<String>(habitId),
      'dependsOnHabitId': serializer.toJson<String>(dependsOnHabitId),
    };
  }

  HabitDependency copyWith({String? habitId, String? dependsOnHabitId}) =>
      HabitDependency(
        habitId: habitId ?? this.habitId,
        dependsOnHabitId: dependsOnHabitId ?? this.dependsOnHabitId,
      );
  HabitDependency copyWithCompanion(HabitDependenciesCompanion data) {
    return HabitDependency(
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      dependsOnHabitId: data.dependsOnHabitId.present
          ? data.dependsOnHabitId.value
          : this.dependsOnHabitId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitDependency(')
          ..write('habitId: $habitId, ')
          ..write('dependsOnHabitId: $dependsOnHabitId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(habitId, dependsOnHabitId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitDependency &&
          other.habitId == this.habitId &&
          other.dependsOnHabitId == this.dependsOnHabitId);
}

class HabitDependenciesCompanion extends UpdateCompanion<HabitDependency> {
  final Value<String> habitId;
  final Value<String> dependsOnHabitId;
  final Value<int> rowid;
  const HabitDependenciesCompanion({
    this.habitId = const Value.absent(),
    this.dependsOnHabitId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitDependenciesCompanion.insert({
    required String habitId,
    required String dependsOnHabitId,
    this.rowid = const Value.absent(),
  }) : habitId = Value(habitId),
       dependsOnHabitId = Value(dependsOnHabitId);
  static Insertable<HabitDependency> custom({
    Expression<String>? habitId,
    Expression<String>? dependsOnHabitId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (habitId != null) 'habit_id': habitId,
      if (dependsOnHabitId != null) 'depends_on_habit_id': dependsOnHabitId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitDependenciesCompanion copyWith({
    Value<String>? habitId,
    Value<String>? dependsOnHabitId,
    Value<int>? rowid,
  }) {
    return HabitDependenciesCompanion(
      habitId: habitId ?? this.habitId,
      dependsOnHabitId: dependsOnHabitId ?? this.dependsOnHabitId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (habitId.present) {
      map['habit_id'] = Variable<String>(habitId.value);
    }
    if (dependsOnHabitId.present) {
      map['depends_on_habit_id'] = Variable<String>(dependsOnHabitId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitDependenciesCompanion(')
          ..write('habitId: $habitId, ')
          ..write('dependsOnHabitId: $dependsOnHabitId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HabitTagsTable extends HabitTags
    with TableInfo<$HabitTagsTable, HabitTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<String> habitId = GeneratedColumn<String>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
    'tag',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [habitId, tag];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habit_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('tag')) {
      context.handle(
        _tagMeta,
        tag.isAcceptableOrUnknown(data['tag']!, _tagMeta),
      );
    } else if (isInserting) {
      context.missing(_tagMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {habitId, tag};
  @override
  HabitTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitTag(
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habit_id'],
      )!,
      tag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag'],
      )!,
    );
  }

  @override
  $HabitTagsTable createAlias(String alias) {
    return $HabitTagsTable(attachedDatabase, alias);
  }
}

class HabitTag extends DataClass implements Insertable<HabitTag> {
  final String habitId;
  final String tag;
  const HabitTag({required this.habitId, required this.tag});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['habit_id'] = Variable<String>(habitId);
    map['tag'] = Variable<String>(tag);
    return map;
  }

  HabitTagsCompanion toCompanion(bool nullToAbsent) {
    return HabitTagsCompanion(habitId: Value(habitId), tag: Value(tag));
  }

  factory HabitTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitTag(
      habitId: serializer.fromJson<String>(json['habitId']),
      tag: serializer.fromJson<String>(json['tag']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'habitId': serializer.toJson<String>(habitId),
      'tag': serializer.toJson<String>(tag),
    };
  }

  HabitTag copyWith({String? habitId, String? tag}) =>
      HabitTag(habitId: habitId ?? this.habitId, tag: tag ?? this.tag);
  HabitTag copyWithCompanion(HabitTagsCompanion data) {
    return HabitTag(
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      tag: data.tag.present ? data.tag.value : this.tag,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitTag(')
          ..write('habitId: $habitId, ')
          ..write('tag: $tag')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(habitId, tag);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitTag &&
          other.habitId == this.habitId &&
          other.tag == this.tag);
}

class HabitTagsCompanion extends UpdateCompanion<HabitTag> {
  final Value<String> habitId;
  final Value<String> tag;
  final Value<int> rowid;
  const HabitTagsCompanion({
    this.habitId = const Value.absent(),
    this.tag = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitTagsCompanion.insert({
    required String habitId,
    required String tag,
    this.rowid = const Value.absent(),
  }) : habitId = Value(habitId),
       tag = Value(tag);
  static Insertable<HabitTag> custom({
    Expression<String>? habitId,
    Expression<String>? tag,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (habitId != null) 'habit_id': habitId,
      if (tag != null) 'tag': tag,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitTagsCompanion copyWith({
    Value<String>? habitId,
    Value<String>? tag,
    Value<int>? rowid,
  }) {
    return HabitTagsCompanion(
      habitId: habitId ?? this.habitId,
      tag: tag ?? this.tag,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (habitId.present) {
      map['habit_id'] = Variable<String>(habitId.value);
    }
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitTagsCompanion(')
          ..write('habitId: $habitId, ')
          ..write('tag: $tag, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $HabitsTable habits = $HabitsTable(this);
  late final $HabitCompletionsTable habitCompletions = $HabitCompletionsTable(
    this,
  );
  late final $HabitNotesTable habitNotes = $HabitNotesTable(this);
  late final $HabitTasksTable habitTasks = $HabitTasksTable(this);
  late final $HabitRemindersTable habitReminders = $HabitRemindersTable(this);
  late final $HabitActiveWeekdaysTable habitActiveWeekdays =
      $HabitActiveWeekdaysTable(this);
  late final $HabitDependenciesTable habitDependencies =
      $HabitDependenciesTable(this);
  late final $HabitTagsTable habitTags = $HabitTagsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    habits,
    habitCompletions,
    habitNotes,
    habitTasks,
    habitReminders,
    habitActiveWeekdays,
    habitDependencies,
    habitTags,
  ];
}

typedef $$HabitsTableCreateCompanionBuilder =
    HabitsCompanion Function({
      required String id,
      required String title,
      Value<String?> description,
      required int color,
      required int iconCodePoint,
      required DateTime createdAt,
      required String category,
      required String timeBlock,
      required String difficulty,
      Value<bool> archived,
      Value<DateTime?> archivedAt,
      Value<int> weeklyTarget,
      Value<int> monthlyTarget,
      Value<int> freezeUsesThisWeek,
      Value<DateTime?> lastFreezeReset,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$HabitsTableUpdateCompanionBuilder =
    HabitsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> description,
      Value<int> color,
      Value<int> iconCodePoint,
      Value<DateTime> createdAt,
      Value<String> category,
      Value<String> timeBlock,
      Value<String> difficulty,
      Value<bool> archived,
      Value<DateTime?> archivedAt,
      Value<int> weeklyTarget,
      Value<int> monthlyTarget,
      Value<int> freezeUsesThisWeek,
      Value<DateTime?> lastFreezeReset,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$HabitsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeBlock => $composableBuilder(
    column: $table.timeBlock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weeklyTarget => $composableBuilder(
    column: $table.weeklyTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthlyTarget => $composableBuilder(
    column: $table.monthlyTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get freezeUsesThisWeek => $composableBuilder(
    column: $table.freezeUsesThisWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastFreezeReset => $composableBuilder(
    column: $table.lastFreezeReset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HabitsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeBlock => $composableBuilder(
    column: $table.timeBlock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weeklyTarget => $composableBuilder(
    column: $table.weeklyTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthlyTarget => $composableBuilder(
    column: $table.monthlyTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get freezeUsesThisWeek => $composableBuilder(
    column: $table.freezeUsesThisWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastFreezeReset => $composableBuilder(
    column: $table.lastFreezeReset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get timeBlock =>
      $composableBuilder(column: $table.timeBlock, builder: (column) => column);

  GeneratedColumn<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weeklyTarget => $composableBuilder(
    column: $table.weeklyTarget,
    builder: (column) => column,
  );

  GeneratedColumn<int> get monthlyTarget => $composableBuilder(
    column: $table.monthlyTarget,
    builder: (column) => column,
  );

  GeneratedColumn<int> get freezeUsesThisWeek => $composableBuilder(
    column: $table.freezeUsesThisWeek,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastFreezeReset => $composableBuilder(
    column: $table.lastFreezeReset,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$HabitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitsTable,
          Habit,
          $$HabitsTableFilterComposer,
          $$HabitsTableOrderingComposer,
          $$HabitsTableAnnotationComposer,
          $$HabitsTableCreateCompanionBuilder,
          $$HabitsTableUpdateCompanionBuilder,
          (Habit, BaseReferences<_$AppDatabase, $HabitsTable, Habit>),
          Habit,
          PrefetchHooks Function()
        > {
  $$HabitsTableTableManager(_$AppDatabase db, $HabitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<int> iconCodePoint = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> timeBlock = const Value.absent(),
                Value<String> difficulty = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> weeklyTarget = const Value.absent(),
                Value<int> monthlyTarget = const Value.absent(),
                Value<int> freezeUsesThisWeek = const Value.absent(),
                Value<DateTime?> lastFreezeReset = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitsCompanion(
                id: id,
                title: title,
                description: description,
                color: color,
                iconCodePoint: iconCodePoint,
                createdAt: createdAt,
                category: category,
                timeBlock: timeBlock,
                difficulty: difficulty,
                archived: archived,
                archivedAt: archivedAt,
                weeklyTarget: weeklyTarget,
                monthlyTarget: monthlyTarget,
                freezeUsesThisWeek: freezeUsesThisWeek,
                lastFreezeReset: lastFreezeReset,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> description = const Value.absent(),
                required int color,
                required int iconCodePoint,
                required DateTime createdAt,
                required String category,
                required String timeBlock,
                required String difficulty,
                Value<bool> archived = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> weeklyTarget = const Value.absent(),
                Value<int> monthlyTarget = const Value.absent(),
                Value<int> freezeUsesThisWeek = const Value.absent(),
                Value<DateTime?> lastFreezeReset = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitsCompanion.insert(
                id: id,
                title: title,
                description: description,
                color: color,
                iconCodePoint: iconCodePoint,
                createdAt: createdAt,
                category: category,
                timeBlock: timeBlock,
                difficulty: difficulty,
                archived: archived,
                archivedAt: archivedAt,
                weeklyTarget: weeklyTarget,
                monthlyTarget: monthlyTarget,
                freezeUsesThisWeek: freezeUsesThisWeek,
                lastFreezeReset: lastFreezeReset,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HabitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitsTable,
      Habit,
      $$HabitsTableFilterComposer,
      $$HabitsTableOrderingComposer,
      $$HabitsTableAnnotationComposer,
      $$HabitsTableCreateCompanionBuilder,
      $$HabitsTableUpdateCompanionBuilder,
      (Habit, BaseReferences<_$AppDatabase, $HabitsTable, Habit>),
      Habit,
      PrefetchHooks Function()
    >;
typedef $$HabitCompletionsTableCreateCompanionBuilder =
    HabitCompletionsCompanion Function({
      required String id,
      required String habitId,
      required DateTime completionDate,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$HabitCompletionsTableUpdateCompanionBuilder =
    HabitCompletionsCompanion Function({
      Value<String> id,
      Value<String> habitId,
      Value<DateTime> completionDate,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$HabitCompletionsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitCompletionsTable> {
  $$HabitCompletionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completionDate => $composableBuilder(
    column: $table.completionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HabitCompletionsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitCompletionsTable> {
  $$HabitCompletionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completionDate => $composableBuilder(
    column: $table.completionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitCompletionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitCompletionsTable> {
  $$HabitCompletionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get habitId =>
      $composableBuilder(column: $table.habitId, builder: (column) => column);

  GeneratedColumn<DateTime> get completionDate => $composableBuilder(
    column: $table.completionDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$HabitCompletionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitCompletionsTable,
          HabitCompletion,
          $$HabitCompletionsTableFilterComposer,
          $$HabitCompletionsTableOrderingComposer,
          $$HabitCompletionsTableAnnotationComposer,
          $$HabitCompletionsTableCreateCompanionBuilder,
          $$HabitCompletionsTableUpdateCompanionBuilder,
          (
            HabitCompletion,
            BaseReferences<
              _$AppDatabase,
              $HabitCompletionsTable,
              HabitCompletion
            >,
          ),
          HabitCompletion,
          PrefetchHooks Function()
        > {
  $$HabitCompletionsTableTableManager(
    _$AppDatabase db,
    $HabitCompletionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitCompletionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitCompletionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitCompletionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> habitId = const Value.absent(),
                Value<DateTime> completionDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitCompletionsCompanion(
                id: id,
                habitId: habitId,
                completionDate: completionDate,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String habitId,
                required DateTime completionDate,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitCompletionsCompanion.insert(
                id: id,
                habitId: habitId,
                completionDate: completionDate,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HabitCompletionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitCompletionsTable,
      HabitCompletion,
      $$HabitCompletionsTableFilterComposer,
      $$HabitCompletionsTableOrderingComposer,
      $$HabitCompletionsTableAnnotationComposer,
      $$HabitCompletionsTableCreateCompanionBuilder,
      $$HabitCompletionsTableUpdateCompanionBuilder,
      (
        HabitCompletion,
        BaseReferences<_$AppDatabase, $HabitCompletionsTable, HabitCompletion>,
      ),
      HabitCompletion,
      PrefetchHooks Function()
    >;
typedef $$HabitNotesTableCreateCompanionBuilder =
    HabitNotesCompanion Function({
      required String id,
      required String habitId,
      required DateTime noteDate,
      required String noteText,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$HabitNotesTableUpdateCompanionBuilder =
    HabitNotesCompanion Function({
      Value<String> id,
      Value<String> habitId,
      Value<DateTime> noteDate,
      Value<String> noteText,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$HabitNotesTableFilterComposer
    extends Composer<_$AppDatabase, $HabitNotesTable> {
  $$HabitNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get noteDate => $composableBuilder(
    column: $table.noteDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noteText => $composableBuilder(
    column: $table.noteText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HabitNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitNotesTable> {
  $$HabitNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get noteDate => $composableBuilder(
    column: $table.noteDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noteText => $composableBuilder(
    column: $table.noteText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitNotesTable> {
  $$HabitNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get habitId =>
      $composableBuilder(column: $table.habitId, builder: (column) => column);

  GeneratedColumn<DateTime> get noteDate =>
      $composableBuilder(column: $table.noteDate, builder: (column) => column);

  GeneratedColumn<String> get noteText =>
      $composableBuilder(column: $table.noteText, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$HabitNotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitNotesTable,
          HabitNote,
          $$HabitNotesTableFilterComposer,
          $$HabitNotesTableOrderingComposer,
          $$HabitNotesTableAnnotationComposer,
          $$HabitNotesTableCreateCompanionBuilder,
          $$HabitNotesTableUpdateCompanionBuilder,
          (
            HabitNote,
            BaseReferences<_$AppDatabase, $HabitNotesTable, HabitNote>,
          ),
          HabitNote,
          PrefetchHooks Function()
        > {
  $$HabitNotesTableTableManager(_$AppDatabase db, $HabitNotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> habitId = const Value.absent(),
                Value<DateTime> noteDate = const Value.absent(),
                Value<String> noteText = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitNotesCompanion(
                id: id,
                habitId: habitId,
                noteDate: noteDate,
                noteText: noteText,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String habitId,
                required DateTime noteDate,
                required String noteText,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitNotesCompanion.insert(
                id: id,
                habitId: habitId,
                noteDate: noteDate,
                noteText: noteText,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HabitNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitNotesTable,
      HabitNote,
      $$HabitNotesTableFilterComposer,
      $$HabitNotesTableOrderingComposer,
      $$HabitNotesTableAnnotationComposer,
      $$HabitNotesTableCreateCompanionBuilder,
      $$HabitNotesTableUpdateCompanionBuilder,
      (HabitNote, BaseReferences<_$AppDatabase, $HabitNotesTable, HabitNote>),
      HabitNote,
      PrefetchHooks Function()
    >;
typedef $$HabitTasksTableCreateCompanionBuilder =
    HabitTasksCompanion Function({
      required String id,
      required String habitId,
      required String title,
      Value<bool> completed,
      Value<DateTime?> completedAt,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$HabitTasksTableUpdateCompanionBuilder =
    HabitTasksCompanion Function({
      Value<String> id,
      Value<String> habitId,
      Value<String> title,
      Value<bool> completed,
      Value<DateTime?> completedAt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$HabitTasksTableFilterComposer
    extends Composer<_$AppDatabase, $HabitTasksTable> {
  $$HabitTasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HabitTasksTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitTasksTable> {
  $$HabitTasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitTasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitTasksTable> {
  $$HabitTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get habitId =>
      $composableBuilder(column: $table.habitId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$HabitTasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitTasksTable,
          HabitTask,
          $$HabitTasksTableFilterComposer,
          $$HabitTasksTableOrderingComposer,
          $$HabitTasksTableAnnotationComposer,
          $$HabitTasksTableCreateCompanionBuilder,
          $$HabitTasksTableUpdateCompanionBuilder,
          (
            HabitTask,
            BaseReferences<_$AppDatabase, $HabitTasksTable, HabitTask>,
          ),
          HabitTask,
          PrefetchHooks Function()
        > {
  $$HabitTasksTableTableManager(_$AppDatabase db, $HabitTasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> habitId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitTasksCompanion(
                id: id,
                habitId: habitId,
                title: title,
                completed: completed,
                completedAt: completedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String habitId,
                required String title,
                Value<bool> completed = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => HabitTasksCompanion.insert(
                id: id,
                habitId: habitId,
                title: title,
                completed: completed,
                completedAt: completedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HabitTasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitTasksTable,
      HabitTask,
      $$HabitTasksTableFilterComposer,
      $$HabitTasksTableOrderingComposer,
      $$HabitTasksTableAnnotationComposer,
      $$HabitTasksTableCreateCompanionBuilder,
      $$HabitTasksTableUpdateCompanionBuilder,
      (HabitTask, BaseReferences<_$AppDatabase, $HabitTasksTable, HabitTask>),
      HabitTask,
      PrefetchHooks Function()
    >;
typedef $$HabitRemindersTableCreateCompanionBuilder =
    HabitRemindersCompanion Function({
      required String id,
      required String habitId,
      required int hour,
      required int minute,
      required String weekdays,
      Value<bool> enabled,
      Value<int> rowid,
    });
typedef $$HabitRemindersTableUpdateCompanionBuilder =
    HabitRemindersCompanion Function({
      Value<String> id,
      Value<String> habitId,
      Value<int> hour,
      Value<int> minute,
      Value<String> weekdays,
      Value<bool> enabled,
      Value<int> rowid,
    });

class $$HabitRemindersTableFilterComposer
    extends Composer<_$AppDatabase, $HabitRemindersTable> {
  $$HabitRemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hour => $composableBuilder(
    column: $table.hour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minute => $composableBuilder(
    column: $table.minute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weekdays => $composableBuilder(
    column: $table.weekdays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HabitRemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitRemindersTable> {
  $$HabitRemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hour => $composableBuilder(
    column: $table.hour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minute => $composableBuilder(
    column: $table.minute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weekdays => $composableBuilder(
    column: $table.weekdays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitRemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitRemindersTable> {
  $$HabitRemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get habitId =>
      $composableBuilder(column: $table.habitId, builder: (column) => column);

  GeneratedColumn<int> get hour =>
      $composableBuilder(column: $table.hour, builder: (column) => column);

  GeneratedColumn<int> get minute =>
      $composableBuilder(column: $table.minute, builder: (column) => column);

  GeneratedColumn<String> get weekdays =>
      $composableBuilder(column: $table.weekdays, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);
}

class $$HabitRemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitRemindersTable,
          HabitReminder,
          $$HabitRemindersTableFilterComposer,
          $$HabitRemindersTableOrderingComposer,
          $$HabitRemindersTableAnnotationComposer,
          $$HabitRemindersTableCreateCompanionBuilder,
          $$HabitRemindersTableUpdateCompanionBuilder,
          (
            HabitReminder,
            BaseReferences<_$AppDatabase, $HabitRemindersTable, HabitReminder>,
          ),
          HabitReminder,
          PrefetchHooks Function()
        > {
  $$HabitRemindersTableTableManager(
    _$AppDatabase db,
    $HabitRemindersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitRemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitRemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitRemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> habitId = const Value.absent(),
                Value<int> hour = const Value.absent(),
                Value<int> minute = const Value.absent(),
                Value<String> weekdays = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitRemindersCompanion(
                id: id,
                habitId: habitId,
                hour: hour,
                minute: minute,
                weekdays: weekdays,
                enabled: enabled,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String habitId,
                required int hour,
                required int minute,
                required String weekdays,
                Value<bool> enabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitRemindersCompanion.insert(
                id: id,
                habitId: habitId,
                hour: hour,
                minute: minute,
                weekdays: weekdays,
                enabled: enabled,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HabitRemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitRemindersTable,
      HabitReminder,
      $$HabitRemindersTableFilterComposer,
      $$HabitRemindersTableOrderingComposer,
      $$HabitRemindersTableAnnotationComposer,
      $$HabitRemindersTableCreateCompanionBuilder,
      $$HabitRemindersTableUpdateCompanionBuilder,
      (
        HabitReminder,
        BaseReferences<_$AppDatabase, $HabitRemindersTable, HabitReminder>,
      ),
      HabitReminder,
      PrefetchHooks Function()
    >;
typedef $$HabitActiveWeekdaysTableCreateCompanionBuilder =
    HabitActiveWeekdaysCompanion Function({
      required String habitId,
      required int weekday,
      Value<int> rowid,
    });
typedef $$HabitActiveWeekdaysTableUpdateCompanionBuilder =
    HabitActiveWeekdaysCompanion Function({
      Value<String> habitId,
      Value<int> weekday,
      Value<int> rowid,
    });

class $$HabitActiveWeekdaysTableFilterComposer
    extends Composer<_$AppDatabase, $HabitActiveWeekdaysTable> {
  $$HabitActiveWeekdaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HabitActiveWeekdaysTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitActiveWeekdaysTable> {
  $$HabitActiveWeekdaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitActiveWeekdaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitActiveWeekdaysTable> {
  $$HabitActiveWeekdaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get habitId =>
      $composableBuilder(column: $table.habitId, builder: (column) => column);

  GeneratedColumn<int> get weekday =>
      $composableBuilder(column: $table.weekday, builder: (column) => column);
}

class $$HabitActiveWeekdaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitActiveWeekdaysTable,
          HabitActiveWeekday,
          $$HabitActiveWeekdaysTableFilterComposer,
          $$HabitActiveWeekdaysTableOrderingComposer,
          $$HabitActiveWeekdaysTableAnnotationComposer,
          $$HabitActiveWeekdaysTableCreateCompanionBuilder,
          $$HabitActiveWeekdaysTableUpdateCompanionBuilder,
          (
            HabitActiveWeekday,
            BaseReferences<
              _$AppDatabase,
              $HabitActiveWeekdaysTable,
              HabitActiveWeekday
            >,
          ),
          HabitActiveWeekday,
          PrefetchHooks Function()
        > {
  $$HabitActiveWeekdaysTableTableManager(
    _$AppDatabase db,
    $HabitActiveWeekdaysTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitActiveWeekdaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitActiveWeekdaysTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$HabitActiveWeekdaysTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> habitId = const Value.absent(),
                Value<int> weekday = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitActiveWeekdaysCompanion(
                habitId: habitId,
                weekday: weekday,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String habitId,
                required int weekday,
                Value<int> rowid = const Value.absent(),
              }) => HabitActiveWeekdaysCompanion.insert(
                habitId: habitId,
                weekday: weekday,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HabitActiveWeekdaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitActiveWeekdaysTable,
      HabitActiveWeekday,
      $$HabitActiveWeekdaysTableFilterComposer,
      $$HabitActiveWeekdaysTableOrderingComposer,
      $$HabitActiveWeekdaysTableAnnotationComposer,
      $$HabitActiveWeekdaysTableCreateCompanionBuilder,
      $$HabitActiveWeekdaysTableUpdateCompanionBuilder,
      (
        HabitActiveWeekday,
        BaseReferences<
          _$AppDatabase,
          $HabitActiveWeekdaysTable,
          HabitActiveWeekday
        >,
      ),
      HabitActiveWeekday,
      PrefetchHooks Function()
    >;
typedef $$HabitDependenciesTableCreateCompanionBuilder =
    HabitDependenciesCompanion Function({
      required String habitId,
      required String dependsOnHabitId,
      Value<int> rowid,
    });
typedef $$HabitDependenciesTableUpdateCompanionBuilder =
    HabitDependenciesCompanion Function({
      Value<String> habitId,
      Value<String> dependsOnHabitId,
      Value<int> rowid,
    });

class $$HabitDependenciesTableFilterComposer
    extends Composer<_$AppDatabase, $HabitDependenciesTable> {
  $$HabitDependenciesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dependsOnHabitId => $composableBuilder(
    column: $table.dependsOnHabitId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HabitDependenciesTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitDependenciesTable> {
  $$HabitDependenciesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dependsOnHabitId => $composableBuilder(
    column: $table.dependsOnHabitId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitDependenciesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitDependenciesTable> {
  $$HabitDependenciesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get habitId =>
      $composableBuilder(column: $table.habitId, builder: (column) => column);

  GeneratedColumn<String> get dependsOnHabitId => $composableBuilder(
    column: $table.dependsOnHabitId,
    builder: (column) => column,
  );
}

class $$HabitDependenciesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitDependenciesTable,
          HabitDependency,
          $$HabitDependenciesTableFilterComposer,
          $$HabitDependenciesTableOrderingComposer,
          $$HabitDependenciesTableAnnotationComposer,
          $$HabitDependenciesTableCreateCompanionBuilder,
          $$HabitDependenciesTableUpdateCompanionBuilder,
          (
            HabitDependency,
            BaseReferences<
              _$AppDatabase,
              $HabitDependenciesTable,
              HabitDependency
            >,
          ),
          HabitDependency,
          PrefetchHooks Function()
        > {
  $$HabitDependenciesTableTableManager(
    _$AppDatabase db,
    $HabitDependenciesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitDependenciesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitDependenciesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitDependenciesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> habitId = const Value.absent(),
                Value<String> dependsOnHabitId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitDependenciesCompanion(
                habitId: habitId,
                dependsOnHabitId: dependsOnHabitId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String habitId,
                required String dependsOnHabitId,
                Value<int> rowid = const Value.absent(),
              }) => HabitDependenciesCompanion.insert(
                habitId: habitId,
                dependsOnHabitId: dependsOnHabitId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HabitDependenciesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitDependenciesTable,
      HabitDependency,
      $$HabitDependenciesTableFilterComposer,
      $$HabitDependenciesTableOrderingComposer,
      $$HabitDependenciesTableAnnotationComposer,
      $$HabitDependenciesTableCreateCompanionBuilder,
      $$HabitDependenciesTableUpdateCompanionBuilder,
      (
        HabitDependency,
        BaseReferences<_$AppDatabase, $HabitDependenciesTable, HabitDependency>,
      ),
      HabitDependency,
      PrefetchHooks Function()
    >;
typedef $$HabitTagsTableCreateCompanionBuilder =
    HabitTagsCompanion Function({
      required String habitId,
      required String tag,
      Value<int> rowid,
    });
typedef $$HabitTagsTableUpdateCompanionBuilder =
    HabitTagsCompanion Function({
      Value<String> habitId,
      Value<String> tag,
      Value<int> rowid,
    });

class $$HabitTagsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitTagsTable> {
  $$HabitTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HabitTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitTagsTable> {
  $$HabitTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitTagsTable> {
  $$HabitTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get habitId =>
      $composableBuilder(column: $table.habitId, builder: (column) => column);

  GeneratedColumn<String> get tag =>
      $composableBuilder(column: $table.tag, builder: (column) => column);
}

class $$HabitTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitTagsTable,
          HabitTag,
          $$HabitTagsTableFilterComposer,
          $$HabitTagsTableOrderingComposer,
          $$HabitTagsTableAnnotationComposer,
          $$HabitTagsTableCreateCompanionBuilder,
          $$HabitTagsTableUpdateCompanionBuilder,
          (HabitTag, BaseReferences<_$AppDatabase, $HabitTagsTable, HabitTag>),
          HabitTag,
          PrefetchHooks Function()
        > {
  $$HabitTagsTableTableManager(_$AppDatabase db, $HabitTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> habitId = const Value.absent(),
                Value<String> tag = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  HabitTagsCompanion(habitId: habitId, tag: tag, rowid: rowid),
          createCompanionCallback:
              ({
                required String habitId,
                required String tag,
                Value<int> rowid = const Value.absent(),
              }) => HabitTagsCompanion.insert(
                habitId: habitId,
                tag: tag,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HabitTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitTagsTable,
      HabitTag,
      $$HabitTagsTableFilterComposer,
      $$HabitTagsTableOrderingComposer,
      $$HabitTagsTableAnnotationComposer,
      $$HabitTagsTableCreateCompanionBuilder,
      $$HabitTagsTableUpdateCompanionBuilder,
      (HabitTag, BaseReferences<_$AppDatabase, $HabitTagsTable, HabitTag>),
      HabitTag,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$HabitsTableTableManager get habits =>
      $$HabitsTableTableManager(_db, _db.habits);
  $$HabitCompletionsTableTableManager get habitCompletions =>
      $$HabitCompletionsTableTableManager(_db, _db.habitCompletions);
  $$HabitNotesTableTableManager get habitNotes =>
      $$HabitNotesTableTableManager(_db, _db.habitNotes);
  $$HabitTasksTableTableManager get habitTasks =>
      $$HabitTasksTableTableManager(_db, _db.habitTasks);
  $$HabitRemindersTableTableManager get habitReminders =>
      $$HabitRemindersTableTableManager(_db, _db.habitReminders);
  $$HabitActiveWeekdaysTableTableManager get habitActiveWeekdays =>
      $$HabitActiveWeekdaysTableTableManager(_db, _db.habitActiveWeekdays);
  $$HabitDependenciesTableTableManager get habitDependencies =>
      $$HabitDependenciesTableTableManager(_db, _db.habitDependencies);
  $$HabitTagsTableTableManager get habitTags =>
      $$HabitTagsTableTableManager(_db, _db.habitTags);
}
