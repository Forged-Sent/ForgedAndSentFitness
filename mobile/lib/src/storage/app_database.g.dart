// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CompletionEventsTable extends CompletionEvents
    with TableInfo<$CompletionEventsTable, CompletionEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompletionEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemMeta = const VerificationMeta('item');
  @override
  late final GeneratedColumn<String> item = GeneratedColumn<String>(
    'item',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<bool> done = GeneratedColumn<bool>(
    'done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("done" IN (0, 1))',
    ),
  );
  static const VerificationMeta _counterMeta = const VerificationMeta(
    'counter',
  );
  @override
  late final GeneratedColumn<int> counter = GeneratedColumn<int>(
    'counter',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _tappedAtUtcMsMeta = const VerificationMeta(
    'tappedAtUtcMs',
  );
  @override
  late final GeneratedColumn<int> tappedAtUtcMs = GeneratedColumn<int>(
    'tapped_at_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _utcOffsetMinutesMeta = const VerificationMeta(
    'utcOffsetMinutes',
  );
  @override
  late final GeneratedColumn<int> utcOffsetMinutes = GeneratedColumn<int>(
    'utc_offset_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _replacesEventIdMeta = const VerificationMeta(
    'replacesEventId',
  );
  @override
  late final GeneratedColumn<String> replacesEventId = GeneratedColumn<String>(
    'replaces_event_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    day,
    item,
    done,
    counter,
    tappedAtUtcMs,
    utcOffsetMinutes,
    replacesEventId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'completion_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompletionEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('item')) {
      context.handle(
        _itemMeta,
        item.isAcceptableOrUnknown(data['item']!, _itemMeta),
      );
    } else if (isInserting) {
      context.missing(_itemMeta);
    }
    if (data.containsKey('done')) {
      context.handle(
        _doneMeta,
        done.isAcceptableOrUnknown(data['done']!, _doneMeta),
      );
    } else if (isInserting) {
      context.missing(_doneMeta);
    }
    if (data.containsKey('counter')) {
      context.handle(
        _counterMeta,
        counter.isAcceptableOrUnknown(data['counter']!, _counterMeta),
      );
    } else if (isInserting) {
      context.missing(_counterMeta);
    }
    if (data.containsKey('tapped_at_utc_ms')) {
      context.handle(
        _tappedAtUtcMsMeta,
        tappedAtUtcMs.isAcceptableOrUnknown(
          data['tapped_at_utc_ms']!,
          _tappedAtUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tappedAtUtcMsMeta);
    }
    if (data.containsKey('utc_offset_minutes')) {
      context.handle(
        _utcOffsetMinutesMeta,
        utcOffsetMinutes.isAcceptableOrUnknown(
          data['utc_offset_minutes']!,
          _utcOffsetMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_utcOffsetMinutesMeta);
    }
    if (data.containsKey('replaces_event_id')) {
      context.handle(
        _replacesEventIdMeta,
        replacesEventId.isAcceptableOrUnknown(
          data['replaces_event_id']!,
          _replacesEventIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CompletionEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompletionEventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      item: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item'],
      )!,
      done: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}done'],
      )!,
      counter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}counter'],
      )!,
      tappedAtUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tapped_at_utc_ms'],
      )!,
      utcOffsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}utc_offset_minutes'],
      )!,
      replacesEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}replaces_event_id'],
      ),
    );
  }

  @override
  $CompletionEventsTable createAlias(String alias) {
    return $CompletionEventsTable(attachedDatabase, alias);
  }
}

class CompletionEventRow extends DataClass
    implements Insertable<CompletionEventRow> {
  /// Client-generated UUID.
  final String id;
  final String ownerId;

  /// The local day the event belongs to, as `YYYY-MM-DD`.
  final String day;
  final String item;

  /// The state the tap asked for.
  final bool done;

  /// This event's place in this database's order of events. The highest
  /// counter for a box is its latest event; the phone's clock is never
  /// used for that.
  final int counter;

  /// When the tap happened: a UTC instant, and the phone's offset from UTC
  /// at that moment. For the record and for display only.
  final int tappedAtUtcMs;
  final int utcOffsetMinutes;

  /// The event that set the box when the tap was made, if any.
  final String? replacesEventId;
  const CompletionEventRow({
    required this.id,
    required this.ownerId,
    required this.day,
    required this.item,
    required this.done,
    required this.counter,
    required this.tappedAtUtcMs,
    required this.utcOffsetMinutes,
    this.replacesEventId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['day'] = Variable<String>(day);
    map['item'] = Variable<String>(item);
    map['done'] = Variable<bool>(done);
    map['counter'] = Variable<int>(counter);
    map['tapped_at_utc_ms'] = Variable<int>(tappedAtUtcMs);
    map['utc_offset_minutes'] = Variable<int>(utcOffsetMinutes);
    if (!nullToAbsent || replacesEventId != null) {
      map['replaces_event_id'] = Variable<String>(replacesEventId);
    }
    return map;
  }

  CompletionEventsCompanion toCompanion(bool nullToAbsent) {
    return CompletionEventsCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      day: Value(day),
      item: Value(item),
      done: Value(done),
      counter: Value(counter),
      tappedAtUtcMs: Value(tappedAtUtcMs),
      utcOffsetMinutes: Value(utcOffsetMinutes),
      replacesEventId: replacesEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(replacesEventId),
    );
  }

  factory CompletionEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompletionEventRow(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      day: serializer.fromJson<String>(json['day']),
      item: serializer.fromJson<String>(json['item']),
      done: serializer.fromJson<bool>(json['done']),
      counter: serializer.fromJson<int>(json['counter']),
      tappedAtUtcMs: serializer.fromJson<int>(json['tappedAtUtcMs']),
      utcOffsetMinutes: serializer.fromJson<int>(json['utcOffsetMinutes']),
      replacesEventId: serializer.fromJson<String?>(json['replacesEventId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'day': serializer.toJson<String>(day),
      'item': serializer.toJson<String>(item),
      'done': serializer.toJson<bool>(done),
      'counter': serializer.toJson<int>(counter),
      'tappedAtUtcMs': serializer.toJson<int>(tappedAtUtcMs),
      'utcOffsetMinutes': serializer.toJson<int>(utcOffsetMinutes),
      'replacesEventId': serializer.toJson<String?>(replacesEventId),
    };
  }

  CompletionEventRow copyWith({
    String? id,
    String? ownerId,
    String? day,
    String? item,
    bool? done,
    int? counter,
    int? tappedAtUtcMs,
    int? utcOffsetMinutes,
    Value<String?> replacesEventId = const Value.absent(),
  }) => CompletionEventRow(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    day: day ?? this.day,
    item: item ?? this.item,
    done: done ?? this.done,
    counter: counter ?? this.counter,
    tappedAtUtcMs: tappedAtUtcMs ?? this.tappedAtUtcMs,
    utcOffsetMinutes: utcOffsetMinutes ?? this.utcOffsetMinutes,
    replacesEventId: replacesEventId.present
        ? replacesEventId.value
        : this.replacesEventId,
  );
  CompletionEventRow copyWithCompanion(CompletionEventsCompanion data) {
    return CompletionEventRow(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      day: data.day.present ? data.day.value : this.day,
      item: data.item.present ? data.item.value : this.item,
      done: data.done.present ? data.done.value : this.done,
      counter: data.counter.present ? data.counter.value : this.counter,
      tappedAtUtcMs: data.tappedAtUtcMs.present
          ? data.tappedAtUtcMs.value
          : this.tappedAtUtcMs,
      utcOffsetMinutes: data.utcOffsetMinutes.present
          ? data.utcOffsetMinutes.value
          : this.utcOffsetMinutes,
      replacesEventId: data.replacesEventId.present
          ? data.replacesEventId.value
          : this.replacesEventId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompletionEventRow(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('day: $day, ')
          ..write('item: $item, ')
          ..write('done: $done, ')
          ..write('counter: $counter, ')
          ..write('tappedAtUtcMs: $tappedAtUtcMs, ')
          ..write('utcOffsetMinutes: $utcOffsetMinutes, ')
          ..write('replacesEventId: $replacesEventId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    day,
    item,
    done,
    counter,
    tappedAtUtcMs,
    utcOffsetMinutes,
    replacesEventId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompletionEventRow &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.day == this.day &&
          other.item == this.item &&
          other.done == this.done &&
          other.counter == this.counter &&
          other.tappedAtUtcMs == this.tappedAtUtcMs &&
          other.utcOffsetMinutes == this.utcOffsetMinutes &&
          other.replacesEventId == this.replacesEventId);
}

class CompletionEventsCompanion extends UpdateCompanion<CompletionEventRow> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> day;
  final Value<String> item;
  final Value<bool> done;
  final Value<int> counter;
  final Value<int> tappedAtUtcMs;
  final Value<int> utcOffsetMinutes;
  final Value<String?> replacesEventId;
  final Value<int> rowid;
  const CompletionEventsCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.day = const Value.absent(),
    this.item = const Value.absent(),
    this.done = const Value.absent(),
    this.counter = const Value.absent(),
    this.tappedAtUtcMs = const Value.absent(),
    this.utcOffsetMinutes = const Value.absent(),
    this.replacesEventId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompletionEventsCompanion.insert({
    required String id,
    required String ownerId,
    required String day,
    required String item,
    required bool done,
    required int counter,
    required int tappedAtUtcMs,
    required int utcOffsetMinutes,
    this.replacesEventId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       day = Value(day),
       item = Value(item),
       done = Value(done),
       counter = Value(counter),
       tappedAtUtcMs = Value(tappedAtUtcMs),
       utcOffsetMinutes = Value(utcOffsetMinutes);
  static Insertable<CompletionEventRow> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? day,
    Expression<String>? item,
    Expression<bool>? done,
    Expression<int>? counter,
    Expression<int>? tappedAtUtcMs,
    Expression<int>? utcOffsetMinutes,
    Expression<String>? replacesEventId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (day != null) 'day': day,
      if (item != null) 'item': item,
      if (done != null) 'done': done,
      if (counter != null) 'counter': counter,
      if (tappedAtUtcMs != null) 'tapped_at_utc_ms': tappedAtUtcMs,
      if (utcOffsetMinutes != null) 'utc_offset_minutes': utcOffsetMinutes,
      if (replacesEventId != null) 'replaces_event_id': replacesEventId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompletionEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String>? day,
    Value<String>? item,
    Value<bool>? done,
    Value<int>? counter,
    Value<int>? tappedAtUtcMs,
    Value<int>? utcOffsetMinutes,
    Value<String?>? replacesEventId,
    Value<int>? rowid,
  }) {
    return CompletionEventsCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      day: day ?? this.day,
      item: item ?? this.item,
      done: done ?? this.done,
      counter: counter ?? this.counter,
      tappedAtUtcMs: tappedAtUtcMs ?? this.tappedAtUtcMs,
      utcOffsetMinutes: utcOffsetMinutes ?? this.utcOffsetMinutes,
      replacesEventId: replacesEventId ?? this.replacesEventId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (item.present) {
      map['item'] = Variable<String>(item.value);
    }
    if (done.present) {
      map['done'] = Variable<bool>(done.value);
    }
    if (counter.present) {
      map['counter'] = Variable<int>(counter.value);
    }
    if (tappedAtUtcMs.present) {
      map['tapped_at_utc_ms'] = Variable<int>(tappedAtUtcMs.value);
    }
    if (utcOffsetMinutes.present) {
      map['utc_offset_minutes'] = Variable<int>(utcOffsetMinutes.value);
    }
    if (replacesEventId.present) {
      map['replaces_event_id'] = Variable<String>(replacesEventId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompletionEventsCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('day: $day, ')
          ..write('item: $item, ')
          ..write('done: $done, ')
          ..write('counter: $counter, ')
          ..write('tappedAtUtcMs: $tappedAtUtcMs, ')
          ..write('utcOffsetMinutes: $utcOffsetMinutes, ')
          ..write('replacesEventId: $replacesEventId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DayStatesTable extends DayStates
    with TableInfo<$DayStatesTable, DayStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DayStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemMeta = const VerificationMeta('item');
  @override
  late final GeneratedColumn<String> item = GeneratedColumn<String>(
    'item',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<bool> done = GeneratedColumn<bool>(
    'done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("done" IN (0, 1))',
    ),
  );
  static const VerificationMeta _latestEventIdMeta = const VerificationMeta(
    'latestEventId',
  );
  @override
  late final GeneratedColumn<String> latestEventId = GeneratedColumn<String>(
    'latest_event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latestCounterMeta = const VerificationMeta(
    'latestCounter',
  );
  @override
  late final GeneratedColumn<int> latestCounter = GeneratedColumn<int>(
    'latest_counter',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    ownerId,
    day,
    item,
    done,
    latestEventId,
    latestCounter,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'day_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<DayStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('item')) {
      context.handle(
        _itemMeta,
        item.isAcceptableOrUnknown(data['item']!, _itemMeta),
      );
    } else if (isInserting) {
      context.missing(_itemMeta);
    }
    if (data.containsKey('done')) {
      context.handle(
        _doneMeta,
        done.isAcceptableOrUnknown(data['done']!, _doneMeta),
      );
    } else if (isInserting) {
      context.missing(_doneMeta);
    }
    if (data.containsKey('latest_event_id')) {
      context.handle(
        _latestEventIdMeta,
        latestEventId.isAcceptableOrUnknown(
          data['latest_event_id']!,
          _latestEventIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_latestEventIdMeta);
    }
    if (data.containsKey('latest_counter')) {
      context.handle(
        _latestCounterMeta,
        latestCounter.isAcceptableOrUnknown(
          data['latest_counter']!,
          _latestCounterMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_latestCounterMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ownerId, day, item};
  @override
  DayStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DayStateRow(
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      item: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item'],
      )!,
      done: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}done'],
      )!,
      latestEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}latest_event_id'],
      )!,
      latestCounter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}latest_counter'],
      )!,
    );
  }

  @override
  $DayStatesTable createAlias(String alias) {
    return $DayStatesTable(attachedDatabase, alias);
  }
}

class DayStateRow extends DataClass implements Insertable<DayStateRow> {
  final String ownerId;
  final String day;
  final String item;
  final bool done;
  final String latestEventId;
  final int latestCounter;
  const DayStateRow({
    required this.ownerId,
    required this.day,
    required this.item,
    required this.done,
    required this.latestEventId,
    required this.latestCounter,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_id'] = Variable<String>(ownerId);
    map['day'] = Variable<String>(day);
    map['item'] = Variable<String>(item);
    map['done'] = Variable<bool>(done);
    map['latest_event_id'] = Variable<String>(latestEventId);
    map['latest_counter'] = Variable<int>(latestCounter);
    return map;
  }

  DayStatesCompanion toCompanion(bool nullToAbsent) {
    return DayStatesCompanion(
      ownerId: Value(ownerId),
      day: Value(day),
      item: Value(item),
      done: Value(done),
      latestEventId: Value(latestEventId),
      latestCounter: Value(latestCounter),
    );
  }

  factory DayStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DayStateRow(
      ownerId: serializer.fromJson<String>(json['ownerId']),
      day: serializer.fromJson<String>(json['day']),
      item: serializer.fromJson<String>(json['item']),
      done: serializer.fromJson<bool>(json['done']),
      latestEventId: serializer.fromJson<String>(json['latestEventId']),
      latestCounter: serializer.fromJson<int>(json['latestCounter']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerId': serializer.toJson<String>(ownerId),
      'day': serializer.toJson<String>(day),
      'item': serializer.toJson<String>(item),
      'done': serializer.toJson<bool>(done),
      'latestEventId': serializer.toJson<String>(latestEventId),
      'latestCounter': serializer.toJson<int>(latestCounter),
    };
  }

  DayStateRow copyWith({
    String? ownerId,
    String? day,
    String? item,
    bool? done,
    String? latestEventId,
    int? latestCounter,
  }) => DayStateRow(
    ownerId: ownerId ?? this.ownerId,
    day: day ?? this.day,
    item: item ?? this.item,
    done: done ?? this.done,
    latestEventId: latestEventId ?? this.latestEventId,
    latestCounter: latestCounter ?? this.latestCounter,
  );
  DayStateRow copyWithCompanion(DayStatesCompanion data) {
    return DayStateRow(
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      day: data.day.present ? data.day.value : this.day,
      item: data.item.present ? data.item.value : this.item,
      done: data.done.present ? data.done.value : this.done,
      latestEventId: data.latestEventId.present
          ? data.latestEventId.value
          : this.latestEventId,
      latestCounter: data.latestCounter.present
          ? data.latestCounter.value
          : this.latestCounter,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DayStateRow(')
          ..write('ownerId: $ownerId, ')
          ..write('day: $day, ')
          ..write('item: $item, ')
          ..write('done: $done, ')
          ..write('latestEventId: $latestEventId, ')
          ..write('latestCounter: $latestCounter')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(ownerId, day, item, done, latestEventId, latestCounter);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DayStateRow &&
          other.ownerId == this.ownerId &&
          other.day == this.day &&
          other.item == this.item &&
          other.done == this.done &&
          other.latestEventId == this.latestEventId &&
          other.latestCounter == this.latestCounter);
}

class DayStatesCompanion extends UpdateCompanion<DayStateRow> {
  final Value<String> ownerId;
  final Value<String> day;
  final Value<String> item;
  final Value<bool> done;
  final Value<String> latestEventId;
  final Value<int> latestCounter;
  final Value<int> rowid;
  const DayStatesCompanion({
    this.ownerId = const Value.absent(),
    this.day = const Value.absent(),
    this.item = const Value.absent(),
    this.done = const Value.absent(),
    this.latestEventId = const Value.absent(),
    this.latestCounter = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DayStatesCompanion.insert({
    required String ownerId,
    required String day,
    required String item,
    required bool done,
    required String latestEventId,
    required int latestCounter,
    this.rowid = const Value.absent(),
  }) : ownerId = Value(ownerId),
       day = Value(day),
       item = Value(item),
       done = Value(done),
       latestEventId = Value(latestEventId),
       latestCounter = Value(latestCounter);
  static Insertable<DayStateRow> custom({
    Expression<String>? ownerId,
    Expression<String>? day,
    Expression<String>? item,
    Expression<bool>? done,
    Expression<String>? latestEventId,
    Expression<int>? latestCounter,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerId != null) 'owner_id': ownerId,
      if (day != null) 'day': day,
      if (item != null) 'item': item,
      if (done != null) 'done': done,
      if (latestEventId != null) 'latest_event_id': latestEventId,
      if (latestCounter != null) 'latest_counter': latestCounter,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DayStatesCompanion copyWith({
    Value<String>? ownerId,
    Value<String>? day,
    Value<String>? item,
    Value<bool>? done,
    Value<String>? latestEventId,
    Value<int>? latestCounter,
    Value<int>? rowid,
  }) {
    return DayStatesCompanion(
      ownerId: ownerId ?? this.ownerId,
      day: day ?? this.day,
      item: item ?? this.item,
      done: done ?? this.done,
      latestEventId: latestEventId ?? this.latestEventId,
      latestCounter: latestCounter ?? this.latestCounter,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (item.present) {
      map['item'] = Variable<String>(item.value);
    }
    if (done.present) {
      map['done'] = Variable<bool>(done.value);
    }
    if (latestEventId.present) {
      map['latest_event_id'] = Variable<String>(latestEventId.value);
    }
    if (latestCounter.present) {
      map['latest_counter'] = Variable<int>(latestCounter.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DayStatesCompanion(')
          ..write('ownerId: $ownerId, ')
          ..write('day: $day, ')
          ..write('item: $item, ')
          ..write('done: $done, ')
          ..write('latestEventId: $latestEventId, ')
          ..write('latestCounter: $latestCounter, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSettingRow extends DataClass implements Insertable<AppSettingRow> {
  final String key;
  final String value;
  const AppSettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSettingRow copyWith({String? key, String? value}) =>
      AppSettingRow(key: key ?? this.key, value: value ?? this.value);
  AppSettingRow copyWithCompanion(AppSettingsCompanion data) {
    return AppSettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JournalEntriesTable extends JournalEntries
    with TableInfo<$JournalEntriesTable, JournalEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JournalEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtUtcMsMeta = const VerificationMeta(
    'createdAtUtcMs',
  );
  @override
  late final GeneratedColumn<int> createdAtUtcMs = GeneratedColumn<int>(
    'created_at_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _utcOffsetMinutesMeta = const VerificationMeta(
    'utcOffsetMinutes',
  );
  @override
  late final GeneratedColumn<int> utcOffsetMinutes = GeneratedColumn<int>(
    'utc_offset_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyFormatMeta = const VerificationMeta(
    'bodyFormat',
  );
  @override
  late final GeneratedColumn<String> bodyFormat = GeneratedColumn<String>(
    'body_format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _promptMeta = const VerificationMeta('prompt');
  @override
  late final GeneratedColumn<String> prompt = GeneratedColumn<String>(
    'prompt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _editedAtUtcMsMeta = const VerificationMeta(
    'editedAtUtcMs',
  );
  @override
  late final GeneratedColumn<int> editedAtUtcMs = GeneratedColumn<int>(
    'edited_at_utc_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtUtcMsMeta = const VerificationMeta(
    'deletedAtUtcMs',
  );
  @override
  late final GeneratedColumn<int> deletedAtUtcMs = GeneratedColumn<int>(
    'deleted_at_utc_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    day,
    createdAtUtcMs,
    utcOffsetMinutes,
    body,
    bodyFormat,
    source,
    prompt,
    editedAtUtcMs,
    deletedAtUtcMs,
    revision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journal_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<JournalEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('created_at_utc_ms')) {
      context.handle(
        _createdAtUtcMsMeta,
        createdAtUtcMs.isAcceptableOrUnknown(
          data['created_at_utc_ms']!,
          _createdAtUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMsMeta);
    }
    if (data.containsKey('utc_offset_minutes')) {
      context.handle(
        _utcOffsetMinutesMeta,
        utcOffsetMinutes.isAcceptableOrUnknown(
          data['utc_offset_minutes']!,
          _utcOffsetMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_utcOffsetMinutesMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('body_format')) {
      context.handle(
        _bodyFormatMeta,
        bodyFormat.isAcceptableOrUnknown(data['body_format']!, _bodyFormatMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyFormatMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('prompt')) {
      context.handle(
        _promptMeta,
        prompt.isAcceptableOrUnknown(data['prompt']!, _promptMeta),
      );
    } else if (isInserting) {
      context.missing(_promptMeta);
    }
    if (data.containsKey('edited_at_utc_ms')) {
      context.handle(
        _editedAtUtcMsMeta,
        editedAtUtcMs.isAcceptableOrUnknown(
          data['edited_at_utc_ms']!,
          _editedAtUtcMsMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at_utc_ms')) {
      context.handle(
        _deletedAtUtcMsMeta,
        deletedAtUtcMs.isAcceptableOrUnknown(
          data['deleted_at_utc_ms']!,
          _deletedAtUtcMsMeta,
        ),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JournalEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JournalEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      createdAtUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc_ms'],
      )!,
      utcOffsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}utc_offset_minutes'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      bodyFormat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body_format'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      prompt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prompt'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      editedAtUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}edited_at_utc_ms'],
      ),
      deletedAtUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at_utc_ms'],
      ),
    );
  }

  @override
  $JournalEntriesTable createAlias(String alias) {
    return $JournalEntriesTable(attachedDatabase, alias);
  }
}

class JournalEntriesCompanion extends UpdateCompanion<JournalEntryRow> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> day;
  final Value<int> createdAtUtcMs;
  final Value<int> utcOffsetMinutes;
  final Value<String> body;
  final Value<String> bodyFormat;
  final Value<String> source;
  final Value<String> prompt;
  final Value<int?> editedAtUtcMs;
  final Value<int?> deletedAtUtcMs;
  final Value<int> revision;
  final Value<int> rowid;
  const JournalEntriesCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.day = const Value.absent(),
    this.createdAtUtcMs = const Value.absent(),
    this.utcOffsetMinutes = const Value.absent(),
    this.body = const Value.absent(),
    this.bodyFormat = const Value.absent(),
    this.source = const Value.absent(),
    this.prompt = const Value.absent(),
    this.editedAtUtcMs = const Value.absent(),
    this.deletedAtUtcMs = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JournalEntriesCompanion.insert({
    required String id,
    required String ownerId,
    required String day,
    required int createdAtUtcMs,
    required int utcOffsetMinutes,
    required String body,
    required String bodyFormat,
    required String source,
    required String prompt,
    this.editedAtUtcMs = const Value.absent(),
    this.deletedAtUtcMs = const Value.absent(),
    required int revision,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       day = Value(day),
       createdAtUtcMs = Value(createdAtUtcMs),
       utcOffsetMinutes = Value(utcOffsetMinutes),
       body = Value(body),
       bodyFormat = Value(bodyFormat),
       source = Value(source),
       prompt = Value(prompt),
       revision = Value(revision);
  static Insertable<JournalEntryRow> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? day,
    Expression<int>? createdAtUtcMs,
    Expression<int>? utcOffsetMinutes,
    Expression<String>? body,
    Expression<String>? bodyFormat,
    Expression<String>? source,
    Expression<String>? prompt,
    Expression<int>? editedAtUtcMs,
    Expression<int>? deletedAtUtcMs,
    Expression<int>? revision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (day != null) 'day': day,
      if (createdAtUtcMs != null) 'created_at_utc_ms': createdAtUtcMs,
      if (utcOffsetMinutes != null) 'utc_offset_minutes': utcOffsetMinutes,
      if (body != null) 'body': body,
      if (bodyFormat != null) 'body_format': bodyFormat,
      if (source != null) 'source': source,
      if (prompt != null) 'prompt': prompt,
      if (editedAtUtcMs != null) 'edited_at_utc_ms': editedAtUtcMs,
      if (deletedAtUtcMs != null) 'deleted_at_utc_ms': deletedAtUtcMs,
      if (revision != null) 'revision': revision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JournalEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String>? day,
    Value<int>? createdAtUtcMs,
    Value<int>? utcOffsetMinutes,
    Value<String>? body,
    Value<String>? bodyFormat,
    Value<String>? source,
    Value<String>? prompt,
    Value<int?>? editedAtUtcMs,
    Value<int?>? deletedAtUtcMs,
    Value<int>? revision,
    Value<int>? rowid,
  }) {
    return JournalEntriesCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      day: day ?? this.day,
      createdAtUtcMs: createdAtUtcMs ?? this.createdAtUtcMs,
      utcOffsetMinutes: utcOffsetMinutes ?? this.utcOffsetMinutes,
      body: body ?? this.body,
      bodyFormat: bodyFormat ?? this.bodyFormat,
      source: source ?? this.source,
      prompt: prompt ?? this.prompt,
      editedAtUtcMs: editedAtUtcMs ?? this.editedAtUtcMs,
      deletedAtUtcMs: deletedAtUtcMs ?? this.deletedAtUtcMs,
      revision: revision ?? this.revision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (createdAtUtcMs.present) {
      map['created_at_utc_ms'] = Variable<int>(createdAtUtcMs.value);
    }
    if (utcOffsetMinutes.present) {
      map['utc_offset_minutes'] = Variable<int>(utcOffsetMinutes.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (bodyFormat.present) {
      map['body_format'] = Variable<String>(bodyFormat.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (prompt.present) {
      map['prompt'] = Variable<String>(prompt.value);
    }
    if (editedAtUtcMs.present) {
      map['edited_at_utc_ms'] = Variable<int>(editedAtUtcMs.value);
    }
    if (deletedAtUtcMs.present) {
      map['deleted_at_utc_ms'] = Variable<int>(deletedAtUtcMs.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntriesCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('day: $day, ')
          ..write('createdAtUtcMs: $createdAtUtcMs, ')
          ..write('utcOffsetMinutes: $utcOffsetMinutes, ')
          ..write('body: $body, ')
          ..write('bodyFormat: $bodyFormat, ')
          ..write('source: $source, ')
          ..write('prompt: $prompt, ')
          ..write('editedAtUtcMs: $editedAtUtcMs, ')
          ..write('deletedAtUtcMs: $deletedAtUtcMs, ')
          ..write('revision: $revision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JournalChangesTable extends JournalChanges
    with TableInfo<$JournalChangesTable, JournalChangeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JournalChangesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _counterMeta = const VerificationMeta(
    'counter',
  );
  @override
  late final GeneratedColumn<int> counter = GeneratedColumn<int>(
    'counter',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _atUtcMsMeta = const VerificationMeta(
    'atUtcMs',
  );
  @override
  late final GeneratedColumn<int> atUtcMs = GeneratedColumn<int>(
    'at_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _utcOffsetMinutesMeta = const VerificationMeta(
    'utcOffsetMinutes',
  );
  @override
  late final GeneratedColumn<int> utcOffsetMinutes = GeneratedColumn<int>(
    'utc_offset_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    entryId,
    kind,
    revision,
    counter,
    atUtcMs,
    utcOffsetMinutes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journal_changes';
  @override
  VerificationContext validateIntegrity(
    Insertable<JournalChangeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    if (data.containsKey('counter')) {
      context.handle(
        _counterMeta,
        counter.isAcceptableOrUnknown(data['counter']!, _counterMeta),
      );
    } else if (isInserting) {
      context.missing(_counterMeta);
    }
    if (data.containsKey('at_utc_ms')) {
      context.handle(
        _atUtcMsMeta,
        atUtcMs.isAcceptableOrUnknown(data['at_utc_ms']!, _atUtcMsMeta),
      );
    } else if (isInserting) {
      context.missing(_atUtcMsMeta);
    }
    if (data.containsKey('utc_offset_minutes')) {
      context.handle(
        _utcOffsetMinutesMeta,
        utcOffsetMinutes.isAcceptableOrUnknown(
          data['utc_offset_minutes']!,
          _utcOffsetMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_utcOffsetMinutesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JournalChangeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JournalChangeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      counter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}counter'],
      )!,
      atUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}at_utc_ms'],
      )!,
      utcOffsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}utc_offset_minutes'],
      )!,
    );
  }

  @override
  $JournalChangesTable createAlias(String alias) {
    return $JournalChangesTable(attachedDatabase, alias);
  }
}

class JournalChangeRow extends DataClass
    implements Insertable<JournalChangeRow> {
  /// Client-generated UUID.
  final String id;
  final String ownerId;
  final String entryId;

  /// `save` or `delete`.
  final String kind;

  /// The entry's revision once this change was applied.
  final int revision;

  /// This change's place in this database's order of journal changes.
  final int counter;
  final int atUtcMs;
  final int utcOffsetMinutes;
  const JournalChangeRow({
    required this.id,
    required this.ownerId,
    required this.entryId,
    required this.kind,
    required this.revision,
    required this.counter,
    required this.atUtcMs,
    required this.utcOffsetMinutes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['entry_id'] = Variable<String>(entryId);
    map['kind'] = Variable<String>(kind);
    map['revision'] = Variable<int>(revision);
    map['counter'] = Variable<int>(counter);
    map['at_utc_ms'] = Variable<int>(atUtcMs);
    map['utc_offset_minutes'] = Variable<int>(utcOffsetMinutes);
    return map;
  }

  JournalChangesCompanion toCompanion(bool nullToAbsent) {
    return JournalChangesCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      entryId: Value(entryId),
      kind: Value(kind),
      revision: Value(revision),
      counter: Value(counter),
      atUtcMs: Value(atUtcMs),
      utcOffsetMinutes: Value(utcOffsetMinutes),
    );
  }

  factory JournalChangeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JournalChangeRow(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      entryId: serializer.fromJson<String>(json['entryId']),
      kind: serializer.fromJson<String>(json['kind']),
      revision: serializer.fromJson<int>(json['revision']),
      counter: serializer.fromJson<int>(json['counter']),
      atUtcMs: serializer.fromJson<int>(json['atUtcMs']),
      utcOffsetMinutes: serializer.fromJson<int>(json['utcOffsetMinutes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'entryId': serializer.toJson<String>(entryId),
      'kind': serializer.toJson<String>(kind),
      'revision': serializer.toJson<int>(revision),
      'counter': serializer.toJson<int>(counter),
      'atUtcMs': serializer.toJson<int>(atUtcMs),
      'utcOffsetMinutes': serializer.toJson<int>(utcOffsetMinutes),
    };
  }

  JournalChangeRow copyWith({
    String? id,
    String? ownerId,
    String? entryId,
    String? kind,
    int? revision,
    int? counter,
    int? atUtcMs,
    int? utcOffsetMinutes,
  }) => JournalChangeRow(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    entryId: entryId ?? this.entryId,
    kind: kind ?? this.kind,
    revision: revision ?? this.revision,
    counter: counter ?? this.counter,
    atUtcMs: atUtcMs ?? this.atUtcMs,
    utcOffsetMinutes: utcOffsetMinutes ?? this.utcOffsetMinutes,
  );
  JournalChangeRow copyWithCompanion(JournalChangesCompanion data) {
    return JournalChangeRow(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      kind: data.kind.present ? data.kind.value : this.kind,
      revision: data.revision.present ? data.revision.value : this.revision,
      counter: data.counter.present ? data.counter.value : this.counter,
      atUtcMs: data.atUtcMs.present ? data.atUtcMs.value : this.atUtcMs,
      utcOffsetMinutes: data.utcOffsetMinutes.present
          ? data.utcOffsetMinutes.value
          : this.utcOffsetMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JournalChangeRow(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('entryId: $entryId, ')
          ..write('kind: $kind, ')
          ..write('revision: $revision, ')
          ..write('counter: $counter, ')
          ..write('atUtcMs: $atUtcMs, ')
          ..write('utcOffsetMinutes: $utcOffsetMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    entryId,
    kind,
    revision,
    counter,
    atUtcMs,
    utcOffsetMinutes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JournalChangeRow &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.entryId == this.entryId &&
          other.kind == this.kind &&
          other.revision == this.revision &&
          other.counter == this.counter &&
          other.atUtcMs == this.atUtcMs &&
          other.utcOffsetMinutes == this.utcOffsetMinutes);
}

class JournalChangesCompanion extends UpdateCompanion<JournalChangeRow> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> entryId;
  final Value<String> kind;
  final Value<int> revision;
  final Value<int> counter;
  final Value<int> atUtcMs;
  final Value<int> utcOffsetMinutes;
  final Value<int> rowid;
  const JournalChangesCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.entryId = const Value.absent(),
    this.kind = const Value.absent(),
    this.revision = const Value.absent(),
    this.counter = const Value.absent(),
    this.atUtcMs = const Value.absent(),
    this.utcOffsetMinutes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JournalChangesCompanion.insert({
    required String id,
    required String ownerId,
    required String entryId,
    required String kind,
    required int revision,
    required int counter,
    required int atUtcMs,
    required int utcOffsetMinutes,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       entryId = Value(entryId),
       kind = Value(kind),
       revision = Value(revision),
       counter = Value(counter),
       atUtcMs = Value(atUtcMs),
       utcOffsetMinutes = Value(utcOffsetMinutes);
  static Insertable<JournalChangeRow> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? entryId,
    Expression<String>? kind,
    Expression<int>? revision,
    Expression<int>? counter,
    Expression<int>? atUtcMs,
    Expression<int>? utcOffsetMinutes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (entryId != null) 'entry_id': entryId,
      if (kind != null) 'kind': kind,
      if (revision != null) 'revision': revision,
      if (counter != null) 'counter': counter,
      if (atUtcMs != null) 'at_utc_ms': atUtcMs,
      if (utcOffsetMinutes != null) 'utc_offset_minutes': utcOffsetMinutes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JournalChangesCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String>? entryId,
    Value<String>? kind,
    Value<int>? revision,
    Value<int>? counter,
    Value<int>? atUtcMs,
    Value<int>? utcOffsetMinutes,
    Value<int>? rowid,
  }) {
    return JournalChangesCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      entryId: entryId ?? this.entryId,
      kind: kind ?? this.kind,
      revision: revision ?? this.revision,
      counter: counter ?? this.counter,
      atUtcMs: atUtcMs ?? this.atUtcMs,
      utcOffsetMinutes: utcOffsetMinutes ?? this.utcOffsetMinutes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (counter.present) {
      map['counter'] = Variable<int>(counter.value);
    }
    if (atUtcMs.present) {
      map['at_utc_ms'] = Variable<int>(atUtcMs.value);
    }
    if (utcOffsetMinutes.present) {
      map['utc_offset_minutes'] = Variable<int>(utcOffsetMinutes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JournalChangesCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('entryId: $entryId, ')
          ..write('kind: $kind, ')
          ..write('revision: $revision, ')
          ..write('counter: $counter, ')
          ..write('atUtcMs: $atUtcMs, ')
          ..write('utcOffsetMinutes: $utcOffsetMinutes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CompletionEventsTable completionEvents = $CompletionEventsTable(
    this,
  );
  late final $DayStatesTable dayStates = $DayStatesTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $JournalEntriesTable journalEntries = $JournalEntriesTable(this);
  late final $JournalChangesTable journalChanges = $JournalChangesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    completionEvents,
    dayStates,
    appSettings,
    journalEntries,
    journalChanges,
  ];
}

typedef $$CompletionEventsTableCreateCompanionBuilder =
    CompletionEventsCompanion Function({
      required String id,
      required String ownerId,
      required String day,
      required String item,
      required bool done,
      required int counter,
      required int tappedAtUtcMs,
      required int utcOffsetMinutes,
      Value<String?> replacesEventId,
      Value<int> rowid,
    });
typedef $$CompletionEventsTableUpdateCompanionBuilder =
    CompletionEventsCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<String> day,
      Value<String> item,
      Value<bool> done,
      Value<int> counter,
      Value<int> tappedAtUtcMs,
      Value<int> utcOffsetMinutes,
      Value<String?> replacesEventId,
      Value<int> rowid,
    });

class $$CompletionEventsTableFilterComposer
    extends Composer<_$AppDatabase, $CompletionEventsTable> {
  $$CompletionEventsTableFilterComposer({
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

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get item => $composableBuilder(
    column: $table.item,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get counter => $composableBuilder(
    column: $table.counter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tappedAtUtcMs => $composableBuilder(
    column: $table.tappedAtUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get utcOffsetMinutes => $composableBuilder(
    column: $table.utcOffsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get replacesEventId => $composableBuilder(
    column: $table.replacesEventId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CompletionEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $CompletionEventsTable> {
  $$CompletionEventsTableOrderingComposer({
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

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get item => $composableBuilder(
    column: $table.item,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get counter => $composableBuilder(
    column: $table.counter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tappedAtUtcMs => $composableBuilder(
    column: $table.tappedAtUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get utcOffsetMinutes => $composableBuilder(
    column: $table.utcOffsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get replacesEventId => $composableBuilder(
    column: $table.replacesEventId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CompletionEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompletionEventsTable> {
  $$CompletionEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get item =>
      $composableBuilder(column: $table.item, builder: (column) => column);

  GeneratedColumn<bool> get done =>
      $composableBuilder(column: $table.done, builder: (column) => column);

  GeneratedColumn<int> get counter =>
      $composableBuilder(column: $table.counter, builder: (column) => column);

  GeneratedColumn<int> get tappedAtUtcMs => $composableBuilder(
    column: $table.tappedAtUtcMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get utcOffsetMinutes => $composableBuilder(
    column: $table.utcOffsetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get replacesEventId => $composableBuilder(
    column: $table.replacesEventId,
    builder: (column) => column,
  );
}

class $$CompletionEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompletionEventsTable,
          CompletionEventRow,
          $$CompletionEventsTableFilterComposer,
          $$CompletionEventsTableOrderingComposer,
          $$CompletionEventsTableAnnotationComposer,
          $$CompletionEventsTableCreateCompanionBuilder,
          $$CompletionEventsTableUpdateCompanionBuilder,
          (
            CompletionEventRow,
            BaseReferences<
              _$AppDatabase,
              $CompletionEventsTable,
              CompletionEventRow
            >,
          ),
          CompletionEventRow,
          PrefetchHooks Function()
        > {
  $$CompletionEventsTableTableManager(
    _$AppDatabase db,
    $CompletionEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompletionEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompletionEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompletionEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<String> item = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<int> counter = const Value.absent(),
                Value<int> tappedAtUtcMs = const Value.absent(),
                Value<int> utcOffsetMinutes = const Value.absent(),
                Value<String?> replacesEventId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompletionEventsCompanion(
                id: id,
                ownerId: ownerId,
                day: day,
                item: item,
                done: done,
                counter: counter,
                tappedAtUtcMs: tappedAtUtcMs,
                utcOffsetMinutes: utcOffsetMinutes,
                replacesEventId: replacesEventId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                required String day,
                required String item,
                required bool done,
                required int counter,
                required int tappedAtUtcMs,
                required int utcOffsetMinutes,
                Value<String?> replacesEventId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompletionEventsCompanion.insert(
                id: id,
                ownerId: ownerId,
                day: day,
                item: item,
                done: done,
                counter: counter,
                tappedAtUtcMs: tappedAtUtcMs,
                utcOffsetMinutes: utcOffsetMinutes,
                replacesEventId: replacesEventId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CompletionEventsTable, CompletionEventRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $CompletionEventsTable,
                    CompletionEventRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CompletionEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompletionEventsTable,
      CompletionEventRow,
      $$CompletionEventsTableFilterComposer,
      $$CompletionEventsTableOrderingComposer,
      $$CompletionEventsTableAnnotationComposer,
      $$CompletionEventsTableCreateCompanionBuilder,
      $$CompletionEventsTableUpdateCompanionBuilder,
      (
        CompletionEventRow,
        BaseReferences<
          _$AppDatabase,
          $CompletionEventsTable,
          CompletionEventRow
        >,
      ),
      CompletionEventRow,
      PrefetchHooks Function()
    >;
typedef $$DayStatesTableCreateCompanionBuilder =
    DayStatesCompanion Function({
      required String ownerId,
      required String day,
      required String item,
      required bool done,
      required String latestEventId,
      required int latestCounter,
      Value<int> rowid,
    });
typedef $$DayStatesTableUpdateCompanionBuilder =
    DayStatesCompanion Function({
      Value<String> ownerId,
      Value<String> day,
      Value<String> item,
      Value<bool> done,
      Value<String> latestEventId,
      Value<int> latestCounter,
      Value<int> rowid,
    });

class $$DayStatesTableFilterComposer
    extends Composer<_$AppDatabase, $DayStatesTable> {
  $$DayStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get item => $composableBuilder(
    column: $table.item,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get latestEventId => $composableBuilder(
    column: $table.latestEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get latestCounter => $composableBuilder(
    column: $table.latestCounter,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DayStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $DayStatesTable> {
  $$DayStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get item => $composableBuilder(
    column: $table.item,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get latestEventId => $composableBuilder(
    column: $table.latestEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get latestCounter => $composableBuilder(
    column: $table.latestCounter,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DayStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DayStatesTable> {
  $$DayStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get item =>
      $composableBuilder(column: $table.item, builder: (column) => column);

  GeneratedColumn<bool> get done =>
      $composableBuilder(column: $table.done, builder: (column) => column);

  GeneratedColumn<String> get latestEventId => $composableBuilder(
    column: $table.latestEventId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get latestCounter => $composableBuilder(
    column: $table.latestCounter,
    builder: (column) => column,
  );
}

class $$DayStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DayStatesTable,
          DayStateRow,
          $$DayStatesTableFilterComposer,
          $$DayStatesTableOrderingComposer,
          $$DayStatesTableAnnotationComposer,
          $$DayStatesTableCreateCompanionBuilder,
          $$DayStatesTableUpdateCompanionBuilder,
          (
            DayStateRow,
            BaseReferences<_$AppDatabase, $DayStatesTable, DayStateRow>,
          ),
          DayStateRow,
          PrefetchHooks Function()
        > {
  $$DayStatesTableTableManager(_$AppDatabase db, $DayStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DayStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DayStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DayStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> ownerId = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<String> item = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<String> latestEventId = const Value.absent(),
                Value<int> latestCounter = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayStatesCompanion(
                ownerId: ownerId,
                day: day,
                item: item,
                done: done,
                latestEventId: latestEventId,
                latestCounter: latestCounter,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ownerId,
                required String day,
                required String item,
                required bool done,
                required String latestEventId,
                required int latestCounter,
                Value<int> rowid = const Value.absent(),
              }) => DayStatesCompanion.insert(
                ownerId: ownerId,
                day: day,
                item: item,
                done: done,
                latestEventId: latestEventId,
                latestCounter: latestCounter,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DayStatesTable, DayStateRow>(table),
                  BaseReferences<_$AppDatabase, $DayStatesTable, DayStateRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DayStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DayStatesTable,
      DayStateRow,
      $$DayStatesTableFilterComposer,
      $$DayStatesTableOrderingComposer,
      $$DayStatesTableAnnotationComposer,
      $$DayStatesTableCreateCompanionBuilder,
      $$DayStatesTableUpdateCompanionBuilder,
      (
        DayStateRow,
        BaseReferences<_$AppDatabase, $DayStatesTable, DayStateRow>,
      ),
      DayStateRow,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSettingRow,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSettingRow,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingRow>,
          ),
          AppSettingRow,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSettingRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AppSettingsTable,
                    AppSettingRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSettingRow,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSettingRow,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingRow>,
      ),
      AppSettingRow,
      PrefetchHooks Function()
    >;
typedef $$JournalEntriesTableCreateCompanionBuilder =
    JournalEntriesCompanion Function({
      required String id,
      required String ownerId,
      required String day,
      required int createdAtUtcMs,
      required int utcOffsetMinutes,
      required String body,
      required String bodyFormat,
      required String source,
      required String prompt,
      Value<int?> editedAtUtcMs,
      Value<int?> deletedAtUtcMs,
      required int revision,
      Value<int> rowid,
    });
typedef $$JournalEntriesTableUpdateCompanionBuilder =
    JournalEntriesCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<String> day,
      Value<int> createdAtUtcMs,
      Value<int> utcOffsetMinutes,
      Value<String> body,
      Value<String> bodyFormat,
      Value<String> source,
      Value<String> prompt,
      Value<int?> editedAtUtcMs,
      Value<int?> deletedAtUtcMs,
      Value<int> revision,
      Value<int> rowid,
    });

class $$JournalEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableFilterComposer({
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

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtcMs => $composableBuilder(
    column: $table.createdAtUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get utcOffsetMinutes => $composableBuilder(
    column: $table.utcOffsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bodyFormat => $composableBuilder(
    column: $table.bodyFormat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prompt => $composableBuilder(
    column: $table.prompt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get editedAtUtcMs => $composableBuilder(
    column: $table.editedAtUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAtUtcMs => $composableBuilder(
    column: $table.deletedAtUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );
}

class $$JournalEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtcMs => $composableBuilder(
    column: $table.createdAtUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get utcOffsetMinutes => $composableBuilder(
    column: $table.utcOffsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bodyFormat => $composableBuilder(
    column: $table.bodyFormat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prompt => $composableBuilder(
    column: $table.prompt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get editedAtUtcMs => $composableBuilder(
    column: $table.editedAtUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAtUtcMs => $composableBuilder(
    column: $table.deletedAtUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JournalEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get createdAtUtcMs => $composableBuilder(
    column: $table.createdAtUtcMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get utcOffsetMinutes => $composableBuilder(
    column: $table.utcOffsetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get bodyFormat => $composableBuilder(
    column: $table.bodyFormat,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get prompt =>
      $composableBuilder(column: $table.prompt, builder: (column) => column);

  GeneratedColumn<int> get editedAtUtcMs => $composableBuilder(
    column: $table.editedAtUtcMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAtUtcMs => $composableBuilder(
    column: $table.deletedAtUtcMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);
}

class $$JournalEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JournalEntriesTable,
          JournalEntryRow,
          $$JournalEntriesTableFilterComposer,
          $$JournalEntriesTableOrderingComposer,
          $$JournalEntriesTableAnnotationComposer,
          $$JournalEntriesTableCreateCompanionBuilder,
          $$JournalEntriesTableUpdateCompanionBuilder,
          (
            JournalEntryRow,
            BaseReferences<
              _$AppDatabase,
              $JournalEntriesTable,
              JournalEntryRow
            >,
          ),
          JournalEntryRow,
          PrefetchHooks Function()
        > {
  $$JournalEntriesTableTableManager(
    _$AppDatabase db,
    $JournalEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JournalEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JournalEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JournalEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<int> createdAtUtcMs = const Value.absent(),
                Value<int> utcOffsetMinutes = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> bodyFormat = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> prompt = const Value.absent(),
                Value<int?> editedAtUtcMs = const Value.absent(),
                Value<int?> deletedAtUtcMs = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JournalEntriesCompanion(
                id: id,
                ownerId: ownerId,
                day: day,
                createdAtUtcMs: createdAtUtcMs,
                utcOffsetMinutes: utcOffsetMinutes,
                body: body,
                bodyFormat: bodyFormat,
                source: source,
                prompt: prompt,
                editedAtUtcMs: editedAtUtcMs,
                deletedAtUtcMs: deletedAtUtcMs,
                revision: revision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                required String day,
                required int createdAtUtcMs,
                required int utcOffsetMinutes,
                required String body,
                required String bodyFormat,
                required String source,
                required String prompt,
                Value<int?> editedAtUtcMs = const Value.absent(),
                Value<int?> deletedAtUtcMs = const Value.absent(),
                required int revision,
                Value<int> rowid = const Value.absent(),
              }) => JournalEntriesCompanion.insert(
                id: id,
                ownerId: ownerId,
                day: day,
                createdAtUtcMs: createdAtUtcMs,
                utcOffsetMinutes: utcOffsetMinutes,
                body: body,
                bodyFormat: bodyFormat,
                source: source,
                prompt: prompt,
                editedAtUtcMs: editedAtUtcMs,
                deletedAtUtcMs: deletedAtUtcMs,
                revision: revision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$JournalEntriesTable, JournalEntryRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $JournalEntriesTable,
                    JournalEntryRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JournalEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JournalEntriesTable,
      JournalEntryRow,
      $$JournalEntriesTableFilterComposer,
      $$JournalEntriesTableOrderingComposer,
      $$JournalEntriesTableAnnotationComposer,
      $$JournalEntriesTableCreateCompanionBuilder,
      $$JournalEntriesTableUpdateCompanionBuilder,
      (
        JournalEntryRow,
        BaseReferences<_$AppDatabase, $JournalEntriesTable, JournalEntryRow>,
      ),
      JournalEntryRow,
      PrefetchHooks Function()
    >;
typedef $$JournalChangesTableCreateCompanionBuilder =
    JournalChangesCompanion Function({
      required String id,
      required String ownerId,
      required String entryId,
      required String kind,
      required int revision,
      required int counter,
      required int atUtcMs,
      required int utcOffsetMinutes,
      Value<int> rowid,
    });
typedef $$JournalChangesTableUpdateCompanionBuilder =
    JournalChangesCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<String> entryId,
      Value<String> kind,
      Value<int> revision,
      Value<int> counter,
      Value<int> atUtcMs,
      Value<int> utcOffsetMinutes,
      Value<int> rowid,
    });

class $$JournalChangesTableFilterComposer
    extends Composer<_$AppDatabase, $JournalChangesTable> {
  $$JournalChangesTableFilterComposer({
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

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get counter => $composableBuilder(
    column: $table.counter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get atUtcMs => $composableBuilder(
    column: $table.atUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get utcOffsetMinutes => $composableBuilder(
    column: $table.utcOffsetMinutes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$JournalChangesTableOrderingComposer
    extends Composer<_$AppDatabase, $JournalChangesTable> {
  $$JournalChangesTableOrderingComposer({
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

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get counter => $composableBuilder(
    column: $table.counter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get atUtcMs => $composableBuilder(
    column: $table.atUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get utcOffsetMinutes => $composableBuilder(
    column: $table.utcOffsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JournalChangesTableAnnotationComposer
    extends Composer<_$AppDatabase, $JournalChangesTable> {
  $$JournalChangesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get entryId =>
      $composableBuilder(column: $table.entryId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<int> get counter =>
      $composableBuilder(column: $table.counter, builder: (column) => column);

  GeneratedColumn<int> get atUtcMs =>
      $composableBuilder(column: $table.atUtcMs, builder: (column) => column);

  GeneratedColumn<int> get utcOffsetMinutes => $composableBuilder(
    column: $table.utcOffsetMinutes,
    builder: (column) => column,
  );
}

class $$JournalChangesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JournalChangesTable,
          JournalChangeRow,
          $$JournalChangesTableFilterComposer,
          $$JournalChangesTableOrderingComposer,
          $$JournalChangesTableAnnotationComposer,
          $$JournalChangesTableCreateCompanionBuilder,
          $$JournalChangesTableUpdateCompanionBuilder,
          (
            JournalChangeRow,
            BaseReferences<
              _$AppDatabase,
              $JournalChangesTable,
              JournalChangeRow
            >,
          ),
          JournalChangeRow,
          PrefetchHooks Function()
        > {
  $$JournalChangesTableTableManager(
    _$AppDatabase db,
    $JournalChangesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JournalChangesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JournalChangesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JournalChangesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> entryId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> counter = const Value.absent(),
                Value<int> atUtcMs = const Value.absent(),
                Value<int> utcOffsetMinutes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JournalChangesCompanion(
                id: id,
                ownerId: ownerId,
                entryId: entryId,
                kind: kind,
                revision: revision,
                counter: counter,
                atUtcMs: atUtcMs,
                utcOffsetMinutes: utcOffsetMinutes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                required String entryId,
                required String kind,
                required int revision,
                required int counter,
                required int atUtcMs,
                required int utcOffsetMinutes,
                Value<int> rowid = const Value.absent(),
              }) => JournalChangesCompanion.insert(
                id: id,
                ownerId: ownerId,
                entryId: entryId,
                kind: kind,
                revision: revision,
                counter: counter,
                atUtcMs: atUtcMs,
                utcOffsetMinutes: utcOffsetMinutes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$JournalChangesTable, JournalChangeRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $JournalChangesTable,
                    JournalChangeRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JournalChangesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JournalChangesTable,
      JournalChangeRow,
      $$JournalChangesTableFilterComposer,
      $$JournalChangesTableOrderingComposer,
      $$JournalChangesTableAnnotationComposer,
      $$JournalChangesTableCreateCompanionBuilder,
      $$JournalChangesTableUpdateCompanionBuilder,
      (
        JournalChangeRow,
        BaseReferences<_$AppDatabase, $JournalChangesTable, JournalChangeRow>,
      ),
      JournalChangeRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CompletionEventsTableTableManager get completionEvents =>
      $$CompletionEventsTableTableManager(_db, _db.completionEvents);
  $$DayStatesTableTableManager get dayStates =>
      $$DayStatesTableTableManager(_db, _db.dayStates);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$JournalEntriesTableTableManager get journalEntries =>
      $$JournalEntriesTableTableManager(_db, _db.journalEntries);
  $$JournalChangesTableTableManager get journalChanges =>
      $$JournalChangesTableTableManager(_db, _db.journalChanges);
}
