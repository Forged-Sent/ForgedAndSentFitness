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

class $WorkoutPlansTable extends WorkoutPlans
    with TableInfo<$WorkoutPlansTable, WorkoutPlanRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutPlansTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _programMeta = const VerificationMeta(
    'program',
  );
  @override
  late final GeneratedColumn<String> program = GeneratedColumn<String>(
    'program',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _equipmentMeta = const VerificationMeta(
    'equipment',
  );
  @override
  late final GeneratedColumn<String> equipment = GeneratedColumn<String>(
    'equipment',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _restWeekdayMeta = const VerificationMeta(
    'restWeekday',
  );
  @override
  late final GeneratedColumn<int> restWeekday = GeneratedColumn<int>(
    'rest_weekday',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _liftWeekdaysMeta = const VerificationMeta(
    'liftWeekdays',
  );
  @override
  late final GeneratedColumn<String> liftWeekdays = GeneratedColumn<String>(
    'lift_weekdays',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fourthDayMeta = const VerificationMeta(
    'fourthDay',
  );
  @override
  late final GeneratedColumn<bool> fourthDay = GeneratedColumn<bool>(
    'fourth_day',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("fourth_day" IN (0, 1))',
    ),
  );
  static const VerificationMeta _startDayMeta = const VerificationMeta(
    'startDay',
  );
  @override
  late final GeneratedColumn<String> startDay = GeneratedColumn<String>(
    'start_day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    ownerId,
    program,
    equipment,
    restWeekday,
    liftWeekdays,
    fourthDay,
    startDay,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutPlanRow> instance, {
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
    if (data.containsKey('program')) {
      context.handle(
        _programMeta,
        program.isAcceptableOrUnknown(data['program']!, _programMeta),
      );
    } else if (isInserting) {
      context.missing(_programMeta);
    }
    if (data.containsKey('equipment')) {
      context.handle(
        _equipmentMeta,
        equipment.isAcceptableOrUnknown(data['equipment']!, _equipmentMeta),
      );
    } else if (isInserting) {
      context.missing(_equipmentMeta);
    }
    if (data.containsKey('rest_weekday')) {
      context.handle(
        _restWeekdayMeta,
        restWeekday.isAcceptableOrUnknown(
          data['rest_weekday']!,
          _restWeekdayMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_restWeekdayMeta);
    }
    if (data.containsKey('lift_weekdays')) {
      context.handle(
        _liftWeekdaysMeta,
        liftWeekdays.isAcceptableOrUnknown(
          data['lift_weekdays']!,
          _liftWeekdaysMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_liftWeekdaysMeta);
    }
    if (data.containsKey('fourth_day')) {
      context.handle(
        _fourthDayMeta,
        fourthDay.isAcceptableOrUnknown(data['fourth_day']!, _fourthDayMeta),
      );
    } else if (isInserting) {
      context.missing(_fourthDayMeta);
    }
    if (data.containsKey('start_day')) {
      context.handle(
        _startDayMeta,
        startDay.isAcceptableOrUnknown(data['start_day']!, _startDayMeta),
      );
    } else if (isInserting) {
      context.missing(_startDayMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ownerId};
  @override
  WorkoutPlanRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutPlanRow(
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      program: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}program'],
      )!,
      equipment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipment'],
      )!,
      restWeekday: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_weekday'],
      )!,
      liftWeekdays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lift_weekdays'],
      )!,
      fourthDay: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}fourth_day'],
      )!,
      startDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_day'],
      )!,
    );
  }

  @override
  $WorkoutPlansTable createAlias(String alias) {
    return $WorkoutPlansTable(attachedDatabase, alias);
  }
}

class WorkoutPlanRow extends DataClass implements Insertable<WorkoutPlanRow> {
  final String ownerId;
  final String program;

  /// The equipment setup the movement names are shown for.
  final String equipment;

  /// The weekly rest day.
  final int restWeekday;

  /// The three lifting weekdays, in order from the day after the rest day,
  /// as `1,3,5`.
  final String liftWeekdays;

  /// Whether the optional fourth training day is on.
  final bool fourthDay;

  /// The first day of the plan's first week, as `YYYY-MM-DD`: always the
  /// day after a rest day.
  final String startDay;
  const WorkoutPlanRow({
    required this.ownerId,
    required this.program,
    required this.equipment,
    required this.restWeekday,
    required this.liftWeekdays,
    required this.fourthDay,
    required this.startDay,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_id'] = Variable<String>(ownerId);
    map['program'] = Variable<String>(program);
    map['equipment'] = Variable<String>(equipment);
    map['rest_weekday'] = Variable<int>(restWeekday);
    map['lift_weekdays'] = Variable<String>(liftWeekdays);
    map['fourth_day'] = Variable<bool>(fourthDay);
    map['start_day'] = Variable<String>(startDay);
    return map;
  }

  WorkoutPlansCompanion toCompanion(bool nullToAbsent) {
    return WorkoutPlansCompanion(
      ownerId: Value(ownerId),
      program: Value(program),
      equipment: Value(equipment),
      restWeekday: Value(restWeekday),
      liftWeekdays: Value(liftWeekdays),
      fourthDay: Value(fourthDay),
      startDay: Value(startDay),
    );
  }

  factory WorkoutPlanRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutPlanRow(
      ownerId: serializer.fromJson<String>(json['ownerId']),
      program: serializer.fromJson<String>(json['program']),
      equipment: serializer.fromJson<String>(json['equipment']),
      restWeekday: serializer.fromJson<int>(json['restWeekday']),
      liftWeekdays: serializer.fromJson<String>(json['liftWeekdays']),
      fourthDay: serializer.fromJson<bool>(json['fourthDay']),
      startDay: serializer.fromJson<String>(json['startDay']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerId': serializer.toJson<String>(ownerId),
      'program': serializer.toJson<String>(program),
      'equipment': serializer.toJson<String>(equipment),
      'restWeekday': serializer.toJson<int>(restWeekday),
      'liftWeekdays': serializer.toJson<String>(liftWeekdays),
      'fourthDay': serializer.toJson<bool>(fourthDay),
      'startDay': serializer.toJson<String>(startDay),
    };
  }

  WorkoutPlanRow copyWith({
    String? ownerId,
    String? program,
    String? equipment,
    int? restWeekday,
    String? liftWeekdays,
    bool? fourthDay,
    String? startDay,
  }) => WorkoutPlanRow(
    ownerId: ownerId ?? this.ownerId,
    program: program ?? this.program,
    equipment: equipment ?? this.equipment,
    restWeekday: restWeekday ?? this.restWeekday,
    liftWeekdays: liftWeekdays ?? this.liftWeekdays,
    fourthDay: fourthDay ?? this.fourthDay,
    startDay: startDay ?? this.startDay,
  );
  WorkoutPlanRow copyWithCompanion(WorkoutPlansCompanion data) {
    return WorkoutPlanRow(
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      program: data.program.present ? data.program.value : this.program,
      equipment: data.equipment.present ? data.equipment.value : this.equipment,
      restWeekday: data.restWeekday.present
          ? data.restWeekday.value
          : this.restWeekday,
      liftWeekdays: data.liftWeekdays.present
          ? data.liftWeekdays.value
          : this.liftWeekdays,
      fourthDay: data.fourthDay.present ? data.fourthDay.value : this.fourthDay,
      startDay: data.startDay.present ? data.startDay.value : this.startDay,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutPlanRow(')
          ..write('ownerId: $ownerId, ')
          ..write('program: $program, ')
          ..write('equipment: $equipment, ')
          ..write('restWeekday: $restWeekday, ')
          ..write('liftWeekdays: $liftWeekdays, ')
          ..write('fourthDay: $fourthDay, ')
          ..write('startDay: $startDay')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    ownerId,
    program,
    equipment,
    restWeekday,
    liftWeekdays,
    fourthDay,
    startDay,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutPlanRow &&
          other.ownerId == this.ownerId &&
          other.program == this.program &&
          other.equipment == this.equipment &&
          other.restWeekday == this.restWeekday &&
          other.liftWeekdays == this.liftWeekdays &&
          other.fourthDay == this.fourthDay &&
          other.startDay == this.startDay);
}

class WorkoutPlansCompanion extends UpdateCompanion<WorkoutPlanRow> {
  final Value<String> ownerId;
  final Value<String> program;
  final Value<String> equipment;
  final Value<int> restWeekday;
  final Value<String> liftWeekdays;
  final Value<bool> fourthDay;
  final Value<String> startDay;
  final Value<int> rowid;
  const WorkoutPlansCompanion({
    this.ownerId = const Value.absent(),
    this.program = const Value.absent(),
    this.equipment = const Value.absent(),
    this.restWeekday = const Value.absent(),
    this.liftWeekdays = const Value.absent(),
    this.fourthDay = const Value.absent(),
    this.startDay = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutPlansCompanion.insert({
    required String ownerId,
    required String program,
    required String equipment,
    required int restWeekday,
    required String liftWeekdays,
    required bool fourthDay,
    required String startDay,
    this.rowid = const Value.absent(),
  }) : ownerId = Value(ownerId),
       program = Value(program),
       equipment = Value(equipment),
       restWeekday = Value(restWeekday),
       liftWeekdays = Value(liftWeekdays),
       fourthDay = Value(fourthDay),
       startDay = Value(startDay);
  static Insertable<WorkoutPlanRow> custom({
    Expression<String>? ownerId,
    Expression<String>? program,
    Expression<String>? equipment,
    Expression<int>? restWeekday,
    Expression<String>? liftWeekdays,
    Expression<bool>? fourthDay,
    Expression<String>? startDay,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerId != null) 'owner_id': ownerId,
      if (program != null) 'program': program,
      if (equipment != null) 'equipment': equipment,
      if (restWeekday != null) 'rest_weekday': restWeekday,
      if (liftWeekdays != null) 'lift_weekdays': liftWeekdays,
      if (fourthDay != null) 'fourth_day': fourthDay,
      if (startDay != null) 'start_day': startDay,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutPlansCompanion copyWith({
    Value<String>? ownerId,
    Value<String>? program,
    Value<String>? equipment,
    Value<int>? restWeekday,
    Value<String>? liftWeekdays,
    Value<bool>? fourthDay,
    Value<String>? startDay,
    Value<int>? rowid,
  }) {
    return WorkoutPlansCompanion(
      ownerId: ownerId ?? this.ownerId,
      program: program ?? this.program,
      equipment: equipment ?? this.equipment,
      restWeekday: restWeekday ?? this.restWeekday,
      liftWeekdays: liftWeekdays ?? this.liftWeekdays,
      fourthDay: fourthDay ?? this.fourthDay,
      startDay: startDay ?? this.startDay,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (program.present) {
      map['program'] = Variable<String>(program.value);
    }
    if (equipment.present) {
      map['equipment'] = Variable<String>(equipment.value);
    }
    if (restWeekday.present) {
      map['rest_weekday'] = Variable<int>(restWeekday.value);
    }
    if (liftWeekdays.present) {
      map['lift_weekdays'] = Variable<String>(liftWeekdays.value);
    }
    if (fourthDay.present) {
      map['fourth_day'] = Variable<bool>(fourthDay.value);
    }
    if (startDay.present) {
      map['start_day'] = Variable<String>(startDay.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutPlansCompanion(')
          ..write('ownerId: $ownerId, ')
          ..write('program: $program, ')
          ..write('equipment: $equipment, ')
          ..write('restWeekday: $restWeekday, ')
          ..write('liftWeekdays: $liftWeekdays, ')
          ..write('fourthDay: $fourthDay, ')
          ..write('startDay: $startDay, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSessionsTable extends WorkoutSessions
    with TableInfo<$WorkoutSessionsTable, WorkoutSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSessionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _programMeta = const VerificationMeta(
    'program',
  );
  @override
  late final GeneratedColumn<String> program = GeneratedColumn<String>(
    'program',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _planDayMeta = const VerificationMeta(
    'planDay',
  );
  @override
  late final GeneratedColumn<int> planDay = GeneratedColumn<int>(
    'plan_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _planWeekMeta = const VerificationMeta(
    'planWeek',
  );
  @override
  late final GeneratedColumn<int> planWeek = GeneratedColumn<int>(
    'plan_week',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _sessionTypeMeta = const VerificationMeta(
    'sessionType',
  );
  @override
  late final GeneratedColumn<String> sessionType = GeneratedColumn<String>(
    'session_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minutesMeta = const VerificationMeta(
    'minutes',
  );
  @override
  late final GeneratedColumn<int> minutes = GeneratedColumn<int>(
    'minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtUtcMsMeta = const VerificationMeta(
    'startedAtUtcMs',
  );
  @override
  late final GeneratedColumn<int> startedAtUtcMs = GeneratedColumn<int>(
    'started_at_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startUtcOffsetMinutesMeta =
      const VerificationMeta('startUtcOffsetMinutes');
  @override
  late final GeneratedColumn<int> startUtcOffsetMinutes = GeneratedColumn<int>(
    'start_utc_offset_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finishedAtUtcMsMeta = const VerificationMeta(
    'finishedAtUtcMs',
  );
  @override
  late final GeneratedColumn<int> finishedAtUtcMs = GeneratedColumn<int>(
    'finished_at_utc_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _finishUtcOffsetMinutesMeta =
      const VerificationMeta('finishUtcOffsetMinutes');
  @override
  late final GeneratedColumn<int> finishUtcOffsetMinutes = GeneratedColumn<int>(
    'finish_utc_offset_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _finishEventIdMeta = const VerificationMeta(
    'finishEventId',
  );
  @override
  late final GeneratedColumn<String> finishEventId = GeneratedColumn<String>(
    'finish_event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    day,
    program,
    planDay,
    planWeek,
    title,
    sessionType,
    minutes,
    startedAtUtcMs,
    startUtcOffsetMinutes,
    finishedAtUtcMs,
    finishUtcOffsetMinutes,
    finishEventId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutSessionRow> instance, {
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
    if (data.containsKey('program')) {
      context.handle(
        _programMeta,
        program.isAcceptableOrUnknown(data['program']!, _programMeta),
      );
    } else if (isInserting) {
      context.missing(_programMeta);
    }
    if (data.containsKey('plan_day')) {
      context.handle(
        _planDayMeta,
        planDay.isAcceptableOrUnknown(data['plan_day']!, _planDayMeta),
      );
    } else if (isInserting) {
      context.missing(_planDayMeta);
    }
    if (data.containsKey('plan_week')) {
      context.handle(
        _planWeekMeta,
        planWeek.isAcceptableOrUnknown(data['plan_week']!, _planWeekMeta),
      );
    } else if (isInserting) {
      context.missing(_planWeekMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('session_type')) {
      context.handle(
        _sessionTypeMeta,
        sessionType.isAcceptableOrUnknown(
          data['session_type']!,
          _sessionTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionTypeMeta);
    }
    if (data.containsKey('minutes')) {
      context.handle(
        _minutesMeta,
        minutes.isAcceptableOrUnknown(data['minutes']!, _minutesMeta),
      );
    } else if (isInserting) {
      context.missing(_minutesMeta);
    }
    if (data.containsKey('started_at_utc_ms')) {
      context.handle(
        _startedAtUtcMsMeta,
        startedAtUtcMs.isAcceptableOrUnknown(
          data['started_at_utc_ms']!,
          _startedAtUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startedAtUtcMsMeta);
    }
    if (data.containsKey('start_utc_offset_minutes')) {
      context.handle(
        _startUtcOffsetMinutesMeta,
        startUtcOffsetMinutes.isAcceptableOrUnknown(
          data['start_utc_offset_minutes']!,
          _startUtcOffsetMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startUtcOffsetMinutesMeta);
    }
    if (data.containsKey('finished_at_utc_ms')) {
      context.handle(
        _finishedAtUtcMsMeta,
        finishedAtUtcMs.isAcceptableOrUnknown(
          data['finished_at_utc_ms']!,
          _finishedAtUtcMsMeta,
        ),
      );
    }
    if (data.containsKey('finish_utc_offset_minutes')) {
      context.handle(
        _finishUtcOffsetMinutesMeta,
        finishUtcOffsetMinutes.isAcceptableOrUnknown(
          data['finish_utc_offset_minutes']!,
          _finishUtcOffsetMinutesMeta,
        ),
      );
    }
    if (data.containsKey('finish_event_id')) {
      context.handle(
        _finishEventIdMeta,
        finishEventId.isAcceptableOrUnknown(
          data['finish_event_id']!,
          _finishEventIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_finishEventIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {ownerId, day},
  ];
  @override
  WorkoutSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSessionRow(
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
      program: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}program'],
      )!,
      planDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plan_day'],
      )!,
      planWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plan_week'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      sessionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_type'],
      )!,
      minutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minutes'],
      )!,
      startedAtUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at_utc_ms'],
      )!,
      startUtcOffsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_utc_offset_minutes'],
      )!,
      finishedAtUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}finished_at_utc_ms'],
      ),
      finishUtcOffsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}finish_utc_offset_minutes'],
      ),
      finishEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}finish_event_id'],
      )!,
    );
  }

  @override
  $WorkoutSessionsTable createAlias(String alias) {
    return $WorkoutSessionsTable(attachedDatabase, alias);
  }
}

class WorkoutSessionRow extends DataClass
    implements Insertable<WorkoutSessionRow> {
  /// Client-generated UUID.
  final String id;
  final String ownerId;

  /// The local day the session was started on, as `YYYY-MM-DD`.
  final String day;
  final String program;

  /// The plan's day and week numbers when the session was started. For the
  /// line above the title only; nothing is looked up by them.
  final int planDay;
  final int planWeek;
  final String title;
  final String sessionType;
  final int minutes;

  /// When Amen was tapped: a UTC instant, and the phone's offset from UTC
  /// at that moment. The workout clock is worked out from this.
  final int startedAtUtcMs;
  final int startUtcOffsetMinutes;

  /// When the session was finished. Null while it is in progress.
  final int? finishedAtUtcMs;
  final int? finishUtcOffsetMinutes;

  /// The id of the completion event that finishing this session records,
  /// made when the session was started. Finishing twice therefore records
  /// one completion.
  final String finishEventId;
  const WorkoutSessionRow({
    required this.id,
    required this.ownerId,
    required this.day,
    required this.program,
    required this.planDay,
    required this.planWeek,
    required this.title,
    required this.sessionType,
    required this.minutes,
    required this.startedAtUtcMs,
    required this.startUtcOffsetMinutes,
    this.finishedAtUtcMs,
    this.finishUtcOffsetMinutes,
    required this.finishEventId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['day'] = Variable<String>(day);
    map['program'] = Variable<String>(program);
    map['plan_day'] = Variable<int>(planDay);
    map['plan_week'] = Variable<int>(planWeek);
    map['title'] = Variable<String>(title);
    map['session_type'] = Variable<String>(sessionType);
    map['minutes'] = Variable<int>(minutes);
    map['started_at_utc_ms'] = Variable<int>(startedAtUtcMs);
    map['start_utc_offset_minutes'] = Variable<int>(startUtcOffsetMinutes);
    if (!nullToAbsent || finishedAtUtcMs != null) {
      map['finished_at_utc_ms'] = Variable<int>(finishedAtUtcMs);
    }
    if (!nullToAbsent || finishUtcOffsetMinutes != null) {
      map['finish_utc_offset_minutes'] = Variable<int>(finishUtcOffsetMinutes);
    }
    map['finish_event_id'] = Variable<String>(finishEventId);
    return map;
  }

  WorkoutSessionsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSessionsCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      day: Value(day),
      program: Value(program),
      planDay: Value(planDay),
      planWeek: Value(planWeek),
      title: Value(title),
      sessionType: Value(sessionType),
      minutes: Value(minutes),
      startedAtUtcMs: Value(startedAtUtcMs),
      startUtcOffsetMinutes: Value(startUtcOffsetMinutes),
      finishedAtUtcMs: finishedAtUtcMs == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAtUtcMs),
      finishUtcOffsetMinutes: finishUtcOffsetMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(finishUtcOffsetMinutes),
      finishEventId: Value(finishEventId),
    );
  }

  factory WorkoutSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSessionRow(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      day: serializer.fromJson<String>(json['day']),
      program: serializer.fromJson<String>(json['program']),
      planDay: serializer.fromJson<int>(json['planDay']),
      planWeek: serializer.fromJson<int>(json['planWeek']),
      title: serializer.fromJson<String>(json['title']),
      sessionType: serializer.fromJson<String>(json['sessionType']),
      minutes: serializer.fromJson<int>(json['minutes']),
      startedAtUtcMs: serializer.fromJson<int>(json['startedAtUtcMs']),
      startUtcOffsetMinutes: serializer.fromJson<int>(
        json['startUtcOffsetMinutes'],
      ),
      finishedAtUtcMs: serializer.fromJson<int?>(json['finishedAtUtcMs']),
      finishUtcOffsetMinutes: serializer.fromJson<int?>(
        json['finishUtcOffsetMinutes'],
      ),
      finishEventId: serializer.fromJson<String>(json['finishEventId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'day': serializer.toJson<String>(day),
      'program': serializer.toJson<String>(program),
      'planDay': serializer.toJson<int>(planDay),
      'planWeek': serializer.toJson<int>(planWeek),
      'title': serializer.toJson<String>(title),
      'sessionType': serializer.toJson<String>(sessionType),
      'minutes': serializer.toJson<int>(minutes),
      'startedAtUtcMs': serializer.toJson<int>(startedAtUtcMs),
      'startUtcOffsetMinutes': serializer.toJson<int>(startUtcOffsetMinutes),
      'finishedAtUtcMs': serializer.toJson<int?>(finishedAtUtcMs),
      'finishUtcOffsetMinutes': serializer.toJson<int?>(finishUtcOffsetMinutes),
      'finishEventId': serializer.toJson<String>(finishEventId),
    };
  }

  WorkoutSessionRow copyWith({
    String? id,
    String? ownerId,
    String? day,
    String? program,
    int? planDay,
    int? planWeek,
    String? title,
    String? sessionType,
    int? minutes,
    int? startedAtUtcMs,
    int? startUtcOffsetMinutes,
    Value<int?> finishedAtUtcMs = const Value.absent(),
    Value<int?> finishUtcOffsetMinutes = const Value.absent(),
    String? finishEventId,
  }) => WorkoutSessionRow(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    day: day ?? this.day,
    program: program ?? this.program,
    planDay: planDay ?? this.planDay,
    planWeek: planWeek ?? this.planWeek,
    title: title ?? this.title,
    sessionType: sessionType ?? this.sessionType,
    minutes: minutes ?? this.minutes,
    startedAtUtcMs: startedAtUtcMs ?? this.startedAtUtcMs,
    startUtcOffsetMinutes: startUtcOffsetMinutes ?? this.startUtcOffsetMinutes,
    finishedAtUtcMs: finishedAtUtcMs.present
        ? finishedAtUtcMs.value
        : this.finishedAtUtcMs,
    finishUtcOffsetMinutes: finishUtcOffsetMinutes.present
        ? finishUtcOffsetMinutes.value
        : this.finishUtcOffsetMinutes,
    finishEventId: finishEventId ?? this.finishEventId,
  );
  WorkoutSessionRow copyWithCompanion(WorkoutSessionsCompanion data) {
    return WorkoutSessionRow(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      day: data.day.present ? data.day.value : this.day,
      program: data.program.present ? data.program.value : this.program,
      planDay: data.planDay.present ? data.planDay.value : this.planDay,
      planWeek: data.planWeek.present ? data.planWeek.value : this.planWeek,
      title: data.title.present ? data.title.value : this.title,
      sessionType: data.sessionType.present
          ? data.sessionType.value
          : this.sessionType,
      minutes: data.minutes.present ? data.minutes.value : this.minutes,
      startedAtUtcMs: data.startedAtUtcMs.present
          ? data.startedAtUtcMs.value
          : this.startedAtUtcMs,
      startUtcOffsetMinutes: data.startUtcOffsetMinutes.present
          ? data.startUtcOffsetMinutes.value
          : this.startUtcOffsetMinutes,
      finishedAtUtcMs: data.finishedAtUtcMs.present
          ? data.finishedAtUtcMs.value
          : this.finishedAtUtcMs,
      finishUtcOffsetMinutes: data.finishUtcOffsetMinutes.present
          ? data.finishUtcOffsetMinutes.value
          : this.finishUtcOffsetMinutes,
      finishEventId: data.finishEventId.present
          ? data.finishEventId.value
          : this.finishEventId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSessionRow(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('day: $day, ')
          ..write('program: $program, ')
          ..write('planDay: $planDay, ')
          ..write('planWeek: $planWeek, ')
          ..write('title: $title, ')
          ..write('sessionType: $sessionType, ')
          ..write('minutes: $minutes, ')
          ..write('startedAtUtcMs: $startedAtUtcMs, ')
          ..write('startUtcOffsetMinutes: $startUtcOffsetMinutes, ')
          ..write('finishedAtUtcMs: $finishedAtUtcMs, ')
          ..write('finishUtcOffsetMinutes: $finishUtcOffsetMinutes, ')
          ..write('finishEventId: $finishEventId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    day,
    program,
    planDay,
    planWeek,
    title,
    sessionType,
    minutes,
    startedAtUtcMs,
    startUtcOffsetMinutes,
    finishedAtUtcMs,
    finishUtcOffsetMinutes,
    finishEventId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSessionRow &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.day == this.day &&
          other.program == this.program &&
          other.planDay == this.planDay &&
          other.planWeek == this.planWeek &&
          other.title == this.title &&
          other.sessionType == this.sessionType &&
          other.minutes == this.minutes &&
          other.startedAtUtcMs == this.startedAtUtcMs &&
          other.startUtcOffsetMinutes == this.startUtcOffsetMinutes &&
          other.finishedAtUtcMs == this.finishedAtUtcMs &&
          other.finishUtcOffsetMinutes == this.finishUtcOffsetMinutes &&
          other.finishEventId == this.finishEventId);
}

class WorkoutSessionsCompanion extends UpdateCompanion<WorkoutSessionRow> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> day;
  final Value<String> program;
  final Value<int> planDay;
  final Value<int> planWeek;
  final Value<String> title;
  final Value<String> sessionType;
  final Value<int> minutes;
  final Value<int> startedAtUtcMs;
  final Value<int> startUtcOffsetMinutes;
  final Value<int?> finishedAtUtcMs;
  final Value<int?> finishUtcOffsetMinutes;
  final Value<String> finishEventId;
  final Value<int> rowid;
  const WorkoutSessionsCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.day = const Value.absent(),
    this.program = const Value.absent(),
    this.planDay = const Value.absent(),
    this.planWeek = const Value.absent(),
    this.title = const Value.absent(),
    this.sessionType = const Value.absent(),
    this.minutes = const Value.absent(),
    this.startedAtUtcMs = const Value.absent(),
    this.startUtcOffsetMinutes = const Value.absent(),
    this.finishedAtUtcMs = const Value.absent(),
    this.finishUtcOffsetMinutes = const Value.absent(),
    this.finishEventId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutSessionsCompanion.insert({
    required String id,
    required String ownerId,
    required String day,
    required String program,
    required int planDay,
    required int planWeek,
    required String title,
    required String sessionType,
    required int minutes,
    required int startedAtUtcMs,
    required int startUtcOffsetMinutes,
    this.finishedAtUtcMs = const Value.absent(),
    this.finishUtcOffsetMinutes = const Value.absent(),
    required String finishEventId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       day = Value(day),
       program = Value(program),
       planDay = Value(planDay),
       planWeek = Value(planWeek),
       title = Value(title),
       sessionType = Value(sessionType),
       minutes = Value(minutes),
       startedAtUtcMs = Value(startedAtUtcMs),
       startUtcOffsetMinutes = Value(startUtcOffsetMinutes),
       finishEventId = Value(finishEventId);
  static Insertable<WorkoutSessionRow> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? day,
    Expression<String>? program,
    Expression<int>? planDay,
    Expression<int>? planWeek,
    Expression<String>? title,
    Expression<String>? sessionType,
    Expression<int>? minutes,
    Expression<int>? startedAtUtcMs,
    Expression<int>? startUtcOffsetMinutes,
    Expression<int>? finishedAtUtcMs,
    Expression<int>? finishUtcOffsetMinutes,
    Expression<String>? finishEventId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (day != null) 'day': day,
      if (program != null) 'program': program,
      if (planDay != null) 'plan_day': planDay,
      if (planWeek != null) 'plan_week': planWeek,
      if (title != null) 'title': title,
      if (sessionType != null) 'session_type': sessionType,
      if (minutes != null) 'minutes': minutes,
      if (startedAtUtcMs != null) 'started_at_utc_ms': startedAtUtcMs,
      if (startUtcOffsetMinutes != null)
        'start_utc_offset_minutes': startUtcOffsetMinutes,
      if (finishedAtUtcMs != null) 'finished_at_utc_ms': finishedAtUtcMs,
      if (finishUtcOffsetMinutes != null)
        'finish_utc_offset_minutes': finishUtcOffsetMinutes,
      if (finishEventId != null) 'finish_event_id': finishEventId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String>? day,
    Value<String>? program,
    Value<int>? planDay,
    Value<int>? planWeek,
    Value<String>? title,
    Value<String>? sessionType,
    Value<int>? minutes,
    Value<int>? startedAtUtcMs,
    Value<int>? startUtcOffsetMinutes,
    Value<int?>? finishedAtUtcMs,
    Value<int?>? finishUtcOffsetMinutes,
    Value<String>? finishEventId,
    Value<int>? rowid,
  }) {
    return WorkoutSessionsCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      day: day ?? this.day,
      program: program ?? this.program,
      planDay: planDay ?? this.planDay,
      planWeek: planWeek ?? this.planWeek,
      title: title ?? this.title,
      sessionType: sessionType ?? this.sessionType,
      minutes: minutes ?? this.minutes,
      startedAtUtcMs: startedAtUtcMs ?? this.startedAtUtcMs,
      startUtcOffsetMinutes:
          startUtcOffsetMinutes ?? this.startUtcOffsetMinutes,
      finishedAtUtcMs: finishedAtUtcMs ?? this.finishedAtUtcMs,
      finishUtcOffsetMinutes:
          finishUtcOffsetMinutes ?? this.finishUtcOffsetMinutes,
      finishEventId: finishEventId ?? this.finishEventId,
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
    if (program.present) {
      map['program'] = Variable<String>(program.value);
    }
    if (planDay.present) {
      map['plan_day'] = Variable<int>(planDay.value);
    }
    if (planWeek.present) {
      map['plan_week'] = Variable<int>(planWeek.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (sessionType.present) {
      map['session_type'] = Variable<String>(sessionType.value);
    }
    if (minutes.present) {
      map['minutes'] = Variable<int>(minutes.value);
    }
    if (startedAtUtcMs.present) {
      map['started_at_utc_ms'] = Variable<int>(startedAtUtcMs.value);
    }
    if (startUtcOffsetMinutes.present) {
      map['start_utc_offset_minutes'] = Variable<int>(
        startUtcOffsetMinutes.value,
      );
    }
    if (finishedAtUtcMs.present) {
      map['finished_at_utc_ms'] = Variable<int>(finishedAtUtcMs.value);
    }
    if (finishUtcOffsetMinutes.present) {
      map['finish_utc_offset_minutes'] = Variable<int>(
        finishUtcOffsetMinutes.value,
      );
    }
    if (finishEventId.present) {
      map['finish_event_id'] = Variable<String>(finishEventId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSessionsCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('day: $day, ')
          ..write('program: $program, ')
          ..write('planDay: $planDay, ')
          ..write('planWeek: $planWeek, ')
          ..write('title: $title, ')
          ..write('sessionType: $sessionType, ')
          ..write('minutes: $minutes, ')
          ..write('startedAtUtcMs: $startedAtUtcMs, ')
          ..write('startUtcOffsetMinutes: $startUtcOffsetMinutes, ')
          ..write('finishedAtUtcMs: $finishedAtUtcMs, ')
          ..write('finishUtcOffsetMinutes: $finishUtcOffsetMinutes, ')
          ..write('finishEventId: $finishEventId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutExercisesTable extends WorkoutExercises
    with TableInfo<$WorkoutExercisesTable, WorkoutExerciseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workout_sessions (id)',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _movementIdMeta = const VerificationMeta(
    'movementId',
  );
  @override
  late final GeneratedColumn<String> movementId = GeneratedColumn<String>(
    'movement_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _prescriptionMeta = const VerificationMeta(
    'prescription',
  );
  @override
  late final GeneratedColumn<String> prescription = GeneratedColumn<String>(
    'prescription',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _measureMeta = const VerificationMeta(
    'measure',
  );
  @override
  late final GeneratedColumn<String> measure = GeneratedColumn<String>(
    'measure',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightModeMeta = const VerificationMeta(
    'weightMode',
  );
  @override
  late final GeneratedColumn<String> weightMode = GeneratedColumn<String>(
    'weight_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _restBaseSecondsMeta = const VerificationMeta(
    'restBaseSeconds',
  );
  @override
  late final GeneratedColumn<int> restBaseSeconds = GeneratedColumn<int>(
    'rest_base_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _restEndsAtUtcMsMeta = const VerificationMeta(
    'restEndsAtUtcMs',
  );
  @override
  late final GeneratedColumn<int> restEndsAtUtcMs = GeneratedColumn<int>(
    'rest_ends_at_utc_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _restPausedSecondsMeta = const VerificationMeta(
    'restPausedSeconds',
  );
  @override
  late final GeneratedColumn<int> restPausedSeconds = GeneratedColumn<int>(
    'rest_paused_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    position,
    movementId,
    name,
    prescription,
    measure,
    weightMode,
    restBaseSeconds,
    restEndsAtUtcMs,
    restPausedSeconds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutExerciseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('movement_id')) {
      context.handle(
        _movementIdMeta,
        movementId.isAcceptableOrUnknown(data['movement_id']!, _movementIdMeta),
      );
    } else if (isInserting) {
      context.missing(_movementIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('prescription')) {
      context.handle(
        _prescriptionMeta,
        prescription.isAcceptableOrUnknown(
          data['prescription']!,
          _prescriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_prescriptionMeta);
    }
    if (data.containsKey('measure')) {
      context.handle(
        _measureMeta,
        measure.isAcceptableOrUnknown(data['measure']!, _measureMeta),
      );
    } else if (isInserting) {
      context.missing(_measureMeta);
    }
    if (data.containsKey('weight_mode')) {
      context.handle(
        _weightModeMeta,
        weightMode.isAcceptableOrUnknown(data['weight_mode']!, _weightModeMeta),
      );
    } else if (isInserting) {
      context.missing(_weightModeMeta);
    }
    if (data.containsKey('rest_base_seconds')) {
      context.handle(
        _restBaseSecondsMeta,
        restBaseSeconds.isAcceptableOrUnknown(
          data['rest_base_seconds']!,
          _restBaseSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_restBaseSecondsMeta);
    }
    if (data.containsKey('rest_ends_at_utc_ms')) {
      context.handle(
        _restEndsAtUtcMsMeta,
        restEndsAtUtcMs.isAcceptableOrUnknown(
          data['rest_ends_at_utc_ms']!,
          _restEndsAtUtcMsMeta,
        ),
      );
    }
    if (data.containsKey('rest_paused_seconds')) {
      context.handle(
        _restPausedSecondsMeta,
        restPausedSeconds.isAcceptableOrUnknown(
          data['rest_paused_seconds']!,
          _restPausedSecondsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutExerciseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutExerciseRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      movementId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}movement_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      prescription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prescription'],
      )!,
      measure: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}measure'],
      )!,
      weightMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weight_mode'],
      )!,
      restBaseSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_base_seconds'],
      )!,
      restEndsAtUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_ends_at_utc_ms'],
      ),
      restPausedSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_paused_seconds'],
      ),
    );
  }

  @override
  $WorkoutExercisesTable createAlias(String alias) {
    return $WorkoutExercisesTable(attachedDatabase, alias);
  }
}

class WorkoutExerciseRow extends DataClass
    implements Insertable<WorkoutExerciseRow> {
  /// Client-generated UUID.
  final String id;
  final String sessionId;

  /// Where the exercise stands on the page. For display order only: "last
  /// time" is found by [movementId], never by this.
  final int position;

  /// The movement's key in the workout library.
  final String movementId;

  /// The name shown for the member's equipment.
  final String name;

  /// The prescription text, for example `3 x 5 (RPE 7, rest 2 min)`.
  final String prescription;

  /// What a set of this exercise records: `reps`, `seconds`, or `tick` for
  /// an exercise that is only marked done.
  final String measure;

  /// Whether a set needs a weight: `required`, `optional` (a bodyweight
  /// lift that can be loaded) or `none`.
  final String weightMode;

  /// The rest timer's full length in seconds.
  final int restBaseSeconds;

  /// The UTC instant the running rest timer reaches zero. Null when it is
  /// not running.
  final int? restEndsAtUtcMs;

  /// The seconds left on a paused rest timer. Null when it is not paused.
  final int? restPausedSeconds;
  const WorkoutExerciseRow({
    required this.id,
    required this.sessionId,
    required this.position,
    required this.movementId,
    required this.name,
    required this.prescription,
    required this.measure,
    required this.weightMode,
    required this.restBaseSeconds,
    this.restEndsAtUtcMs,
    this.restPausedSeconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['position'] = Variable<int>(position);
    map['movement_id'] = Variable<String>(movementId);
    map['name'] = Variable<String>(name);
    map['prescription'] = Variable<String>(prescription);
    map['measure'] = Variable<String>(measure);
    map['weight_mode'] = Variable<String>(weightMode);
    map['rest_base_seconds'] = Variable<int>(restBaseSeconds);
    if (!nullToAbsent || restEndsAtUtcMs != null) {
      map['rest_ends_at_utc_ms'] = Variable<int>(restEndsAtUtcMs);
    }
    if (!nullToAbsent || restPausedSeconds != null) {
      map['rest_paused_seconds'] = Variable<int>(restPausedSeconds);
    }
    return map;
  }

  WorkoutExercisesCompanion toCompanion(bool nullToAbsent) {
    return WorkoutExercisesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      position: Value(position),
      movementId: Value(movementId),
      name: Value(name),
      prescription: Value(prescription),
      measure: Value(measure),
      weightMode: Value(weightMode),
      restBaseSeconds: Value(restBaseSeconds),
      restEndsAtUtcMs: restEndsAtUtcMs == null && nullToAbsent
          ? const Value.absent()
          : Value(restEndsAtUtcMs),
      restPausedSeconds: restPausedSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(restPausedSeconds),
    );
  }

  factory WorkoutExerciseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutExerciseRow(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      position: serializer.fromJson<int>(json['position']),
      movementId: serializer.fromJson<String>(json['movementId']),
      name: serializer.fromJson<String>(json['name']),
      prescription: serializer.fromJson<String>(json['prescription']),
      measure: serializer.fromJson<String>(json['measure']),
      weightMode: serializer.fromJson<String>(json['weightMode']),
      restBaseSeconds: serializer.fromJson<int>(json['restBaseSeconds']),
      restEndsAtUtcMs: serializer.fromJson<int?>(json['restEndsAtUtcMs']),
      restPausedSeconds: serializer.fromJson<int?>(json['restPausedSeconds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'position': serializer.toJson<int>(position),
      'movementId': serializer.toJson<String>(movementId),
      'name': serializer.toJson<String>(name),
      'prescription': serializer.toJson<String>(prescription),
      'measure': serializer.toJson<String>(measure),
      'weightMode': serializer.toJson<String>(weightMode),
      'restBaseSeconds': serializer.toJson<int>(restBaseSeconds),
      'restEndsAtUtcMs': serializer.toJson<int?>(restEndsAtUtcMs),
      'restPausedSeconds': serializer.toJson<int?>(restPausedSeconds),
    };
  }

  WorkoutExerciseRow copyWith({
    String? id,
    String? sessionId,
    int? position,
    String? movementId,
    String? name,
    String? prescription,
    String? measure,
    String? weightMode,
    int? restBaseSeconds,
    Value<int?> restEndsAtUtcMs = const Value.absent(),
    Value<int?> restPausedSeconds = const Value.absent(),
  }) => WorkoutExerciseRow(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    position: position ?? this.position,
    movementId: movementId ?? this.movementId,
    name: name ?? this.name,
    prescription: prescription ?? this.prescription,
    measure: measure ?? this.measure,
    weightMode: weightMode ?? this.weightMode,
    restBaseSeconds: restBaseSeconds ?? this.restBaseSeconds,
    restEndsAtUtcMs: restEndsAtUtcMs.present
        ? restEndsAtUtcMs.value
        : this.restEndsAtUtcMs,
    restPausedSeconds: restPausedSeconds.present
        ? restPausedSeconds.value
        : this.restPausedSeconds,
  );
  WorkoutExerciseRow copyWithCompanion(WorkoutExercisesCompanion data) {
    return WorkoutExerciseRow(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      position: data.position.present ? data.position.value : this.position,
      movementId: data.movementId.present
          ? data.movementId.value
          : this.movementId,
      name: data.name.present ? data.name.value : this.name,
      prescription: data.prescription.present
          ? data.prescription.value
          : this.prescription,
      measure: data.measure.present ? data.measure.value : this.measure,
      weightMode: data.weightMode.present
          ? data.weightMode.value
          : this.weightMode,
      restBaseSeconds: data.restBaseSeconds.present
          ? data.restBaseSeconds.value
          : this.restBaseSeconds,
      restEndsAtUtcMs: data.restEndsAtUtcMs.present
          ? data.restEndsAtUtcMs.value
          : this.restEndsAtUtcMs,
      restPausedSeconds: data.restPausedSeconds.present
          ? data.restPausedSeconds.value
          : this.restPausedSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutExerciseRow(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('position: $position, ')
          ..write('movementId: $movementId, ')
          ..write('name: $name, ')
          ..write('prescription: $prescription, ')
          ..write('measure: $measure, ')
          ..write('weightMode: $weightMode, ')
          ..write('restBaseSeconds: $restBaseSeconds, ')
          ..write('restEndsAtUtcMs: $restEndsAtUtcMs, ')
          ..write('restPausedSeconds: $restPausedSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    position,
    movementId,
    name,
    prescription,
    measure,
    weightMode,
    restBaseSeconds,
    restEndsAtUtcMs,
    restPausedSeconds,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutExerciseRow &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.position == this.position &&
          other.movementId == this.movementId &&
          other.name == this.name &&
          other.prescription == this.prescription &&
          other.measure == this.measure &&
          other.weightMode == this.weightMode &&
          other.restBaseSeconds == this.restBaseSeconds &&
          other.restEndsAtUtcMs == this.restEndsAtUtcMs &&
          other.restPausedSeconds == this.restPausedSeconds);
}

class WorkoutExercisesCompanion extends UpdateCompanion<WorkoutExerciseRow> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<int> position;
  final Value<String> movementId;
  final Value<String> name;
  final Value<String> prescription;
  final Value<String> measure;
  final Value<String> weightMode;
  final Value<int> restBaseSeconds;
  final Value<int?> restEndsAtUtcMs;
  final Value<int?> restPausedSeconds;
  final Value<int> rowid;
  const WorkoutExercisesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.position = const Value.absent(),
    this.movementId = const Value.absent(),
    this.name = const Value.absent(),
    this.prescription = const Value.absent(),
    this.measure = const Value.absent(),
    this.weightMode = const Value.absent(),
    this.restBaseSeconds = const Value.absent(),
    this.restEndsAtUtcMs = const Value.absent(),
    this.restPausedSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutExercisesCompanion.insert({
    required String id,
    required String sessionId,
    required int position,
    required String movementId,
    required String name,
    required String prescription,
    required String measure,
    required String weightMode,
    required int restBaseSeconds,
    this.restEndsAtUtcMs = const Value.absent(),
    this.restPausedSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       position = Value(position),
       movementId = Value(movementId),
       name = Value(name),
       prescription = Value(prescription),
       measure = Value(measure),
       weightMode = Value(weightMode),
       restBaseSeconds = Value(restBaseSeconds);
  static Insertable<WorkoutExerciseRow> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<int>? position,
    Expression<String>? movementId,
    Expression<String>? name,
    Expression<String>? prescription,
    Expression<String>? measure,
    Expression<String>? weightMode,
    Expression<int>? restBaseSeconds,
    Expression<int>? restEndsAtUtcMs,
    Expression<int>? restPausedSeconds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (position != null) 'position': position,
      if (movementId != null) 'movement_id': movementId,
      if (name != null) 'name': name,
      if (prescription != null) 'prescription': prescription,
      if (measure != null) 'measure': measure,
      if (weightMode != null) 'weight_mode': weightMode,
      if (restBaseSeconds != null) 'rest_base_seconds': restBaseSeconds,
      if (restEndsAtUtcMs != null) 'rest_ends_at_utc_ms': restEndsAtUtcMs,
      if (restPausedSeconds != null) 'rest_paused_seconds': restPausedSeconds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutExercisesCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<int>? position,
    Value<String>? movementId,
    Value<String>? name,
    Value<String>? prescription,
    Value<String>? measure,
    Value<String>? weightMode,
    Value<int>? restBaseSeconds,
    Value<int?>? restEndsAtUtcMs,
    Value<int?>? restPausedSeconds,
    Value<int>? rowid,
  }) {
    return WorkoutExercisesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      position: position ?? this.position,
      movementId: movementId ?? this.movementId,
      name: name ?? this.name,
      prescription: prescription ?? this.prescription,
      measure: measure ?? this.measure,
      weightMode: weightMode ?? this.weightMode,
      restBaseSeconds: restBaseSeconds ?? this.restBaseSeconds,
      restEndsAtUtcMs: restEndsAtUtcMs ?? this.restEndsAtUtcMs,
      restPausedSeconds: restPausedSeconds ?? this.restPausedSeconds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (movementId.present) {
      map['movement_id'] = Variable<String>(movementId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (prescription.present) {
      map['prescription'] = Variable<String>(prescription.value);
    }
    if (measure.present) {
      map['measure'] = Variable<String>(measure.value);
    }
    if (weightMode.present) {
      map['weight_mode'] = Variable<String>(weightMode.value);
    }
    if (restBaseSeconds.present) {
      map['rest_base_seconds'] = Variable<int>(restBaseSeconds.value);
    }
    if (restEndsAtUtcMs.present) {
      map['rest_ends_at_utc_ms'] = Variable<int>(restEndsAtUtcMs.value);
    }
    if (restPausedSeconds.present) {
      map['rest_paused_seconds'] = Variable<int>(restPausedSeconds.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutExercisesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('position: $position, ')
          ..write('movementId: $movementId, ')
          ..write('name: $name, ')
          ..write('prescription: $prescription, ')
          ..write('measure: $measure, ')
          ..write('weightMode: $weightMode, ')
          ..write('restBaseSeconds: $restBaseSeconds, ')
          ..write('restEndsAtUtcMs: $restEndsAtUtcMs, ')
          ..write('restPausedSeconds: $restPausedSeconds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSetsTable extends WorkoutSets
    with TableInfo<$WorkoutSetsTable, WorkoutSetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workout_exercises (id)',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetMeta = const VerificationMeta('target');
  @override
  late final GeneratedColumn<String> target = GeneratedColumn<String>(
    'target',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightLbMeta = const VerificationMeta(
    'weightLb',
  );
  @override
  late final GeneratedColumn<double> weightLb = GeneratedColumn<double>(
    'weight_lb',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tickedMeta = const VerificationMeta('ticked');
  @override
  late final GeneratedColumn<bool> ticked = GeneratedColumn<bool>(
    'ticked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("ticked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    exerciseId,
    position,
    target,
    reps,
    weightLb,
    ticked,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_sets';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutSetRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('target')) {
      context.handle(
        _targetMeta,
        target.isAcceptableOrUnknown(data['target']!, _targetMeta),
      );
    } else if (isInserting) {
      context.missing(_targetMeta);
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    }
    if (data.containsKey('weight_lb')) {
      context.handle(
        _weightLbMeta,
        weightLb.isAcceptableOrUnknown(data['weight_lb']!, _weightLbMeta),
      );
    }
    if (data.containsKey('ticked')) {
      context.handle(
        _tickedMeta,
        ticked.isAcceptableOrUnknown(data['ticked']!, _tickedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutSetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSetRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      target: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target'],
      )!,
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      ),
      weightLb: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_lb'],
      ),
      ticked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}ticked'],
      )!,
    );
  }

  @override
  $WorkoutSetsTable createAlias(String alias) {
    return $WorkoutSetsTable(attachedDatabase, alias);
  }
}

class WorkoutSetRow extends DataClass implements Insertable<WorkoutSetRow> {
  /// Client-generated UUID.
  final String id;
  final String exerciseId;
  final int position;

  /// What the plan asked for in this set, for example `5` or `25 sec`.
  final String target;

  /// Reps done, or seconds for a timed set. Null until entered.
  final int? reps;

  /// The weight on the bar in pounds, or the weight added to a bodyweight
  /// lift. Never the member's body weight. Null until entered.
  final double? weightLb;

  /// For an exercise that is only marked done.
  final bool ticked;
  const WorkoutSetRow({
    required this.id,
    required this.exerciseId,
    required this.position,
    required this.target,
    this.reps,
    this.weightLb,
    required this.ticked,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['position'] = Variable<int>(position);
    map['target'] = Variable<String>(target);
    if (!nullToAbsent || reps != null) {
      map['reps'] = Variable<int>(reps);
    }
    if (!nullToAbsent || weightLb != null) {
      map['weight_lb'] = Variable<double>(weightLb);
    }
    map['ticked'] = Variable<bool>(ticked);
    return map;
  }

  WorkoutSetsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSetsCompanion(
      id: Value(id),
      exerciseId: Value(exerciseId),
      position: Value(position),
      target: Value(target),
      reps: reps == null && nullToAbsent ? const Value.absent() : Value(reps),
      weightLb: weightLb == null && nullToAbsent
          ? const Value.absent()
          : Value(weightLb),
      ticked: Value(ticked),
    );
  }

  factory WorkoutSetRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSetRow(
      id: serializer.fromJson<String>(json['id']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      position: serializer.fromJson<int>(json['position']),
      target: serializer.fromJson<String>(json['target']),
      reps: serializer.fromJson<int?>(json['reps']),
      weightLb: serializer.fromJson<double?>(json['weightLb']),
      ticked: serializer.fromJson<bool>(json['ticked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'position': serializer.toJson<int>(position),
      'target': serializer.toJson<String>(target),
      'reps': serializer.toJson<int?>(reps),
      'weightLb': serializer.toJson<double?>(weightLb),
      'ticked': serializer.toJson<bool>(ticked),
    };
  }

  WorkoutSetRow copyWith({
    String? id,
    String? exerciseId,
    int? position,
    String? target,
    Value<int?> reps = const Value.absent(),
    Value<double?> weightLb = const Value.absent(),
    bool? ticked,
  }) => WorkoutSetRow(
    id: id ?? this.id,
    exerciseId: exerciseId ?? this.exerciseId,
    position: position ?? this.position,
    target: target ?? this.target,
    reps: reps.present ? reps.value : this.reps,
    weightLb: weightLb.present ? weightLb.value : this.weightLb,
    ticked: ticked ?? this.ticked,
  );
  WorkoutSetRow copyWithCompanion(WorkoutSetsCompanion data) {
    return WorkoutSetRow(
      id: data.id.present ? data.id.value : this.id,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      position: data.position.present ? data.position.value : this.position,
      target: data.target.present ? data.target.value : this.target,
      reps: data.reps.present ? data.reps.value : this.reps,
      weightLb: data.weightLb.present ? data.weightLb.value : this.weightLb,
      ticked: data.ticked.present ? data.ticked.value : this.ticked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSetRow(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('position: $position, ')
          ..write('target: $target, ')
          ..write('reps: $reps, ')
          ..write('weightLb: $weightLb, ')
          ..write('ticked: $ticked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, exerciseId, position, target, reps, weightLb, ticked);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSetRow &&
          other.id == this.id &&
          other.exerciseId == this.exerciseId &&
          other.position == this.position &&
          other.target == this.target &&
          other.reps == this.reps &&
          other.weightLb == this.weightLb &&
          other.ticked == this.ticked);
}

class WorkoutSetsCompanion extends UpdateCompanion<WorkoutSetRow> {
  final Value<String> id;
  final Value<String> exerciseId;
  final Value<int> position;
  final Value<String> target;
  final Value<int?> reps;
  final Value<double?> weightLb;
  final Value<bool> ticked;
  final Value<int> rowid;
  const WorkoutSetsCompanion({
    this.id = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.position = const Value.absent(),
    this.target = const Value.absent(),
    this.reps = const Value.absent(),
    this.weightLb = const Value.absent(),
    this.ticked = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutSetsCompanion.insert({
    required String id,
    required String exerciseId,
    required int position,
    required String target,
    this.reps = const Value.absent(),
    this.weightLb = const Value.absent(),
    this.ticked = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       exerciseId = Value(exerciseId),
       position = Value(position),
       target = Value(target);
  static Insertable<WorkoutSetRow> custom({
    Expression<String>? id,
    Expression<String>? exerciseId,
    Expression<int>? position,
    Expression<String>? target,
    Expression<int>? reps,
    Expression<double>? weightLb,
    Expression<bool>? ticked,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (position != null) 'position': position,
      if (target != null) 'target': target,
      if (reps != null) 'reps': reps,
      if (weightLb != null) 'weight_lb': weightLb,
      if (ticked != null) 'ticked': ticked,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutSetsCompanion copyWith({
    Value<String>? id,
    Value<String>? exerciseId,
    Value<int>? position,
    Value<String>? target,
    Value<int?>? reps,
    Value<double?>? weightLb,
    Value<bool>? ticked,
    Value<int>? rowid,
  }) {
    return WorkoutSetsCompanion(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      position: position ?? this.position,
      target: target ?? this.target,
      reps: reps ?? this.reps,
      weightLb: weightLb ?? this.weightLb,
      ticked: ticked ?? this.ticked,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (target.present) {
      map['target'] = Variable<String>(target.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (weightLb.present) {
      map['weight_lb'] = Variable<double>(weightLb.value);
    }
    if (ticked.present) {
      map['ticked'] = Variable<bool>(ticked.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSetsCompanion(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('position: $position, ')
          ..write('target: $target, ')
          ..write('reps: $reps, ')
          ..write('weightLb: $weightLb, ')
          ..write('ticked: $ticked, ')
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
  late final $WorkoutPlansTable workoutPlans = $WorkoutPlansTable(this);
  late final $WorkoutSessionsTable workoutSessions = $WorkoutSessionsTable(
    this,
  );
  late final $WorkoutExercisesTable workoutExercises = $WorkoutExercisesTable(
    this,
  );
  late final $WorkoutSetsTable workoutSets = $WorkoutSetsTable(this);
  late final Index workoutExercisesSession = Index(
    'workout_exercises_session',
    'CREATE INDEX workout_exercises_session ON workout_exercises (session_id)',
  );
  late final Index workoutExercisesMovement = Index(
    'workout_exercises_movement',
    'CREATE INDEX workout_exercises_movement ON workout_exercises (movement_id)',
  );
  late final Index workoutSetsExercise = Index(
    'workout_sets_exercise',
    'CREATE INDEX workout_sets_exercise ON workout_sets (exercise_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    completionEvents,
    dayStates,
    appSettings,
    workoutPlans,
    workoutSessions,
    workoutExercises,
    workoutSets,
    workoutExercisesSession,
    workoutExercisesMovement,
    workoutSetsExercise,
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
typedef $$WorkoutPlansTableCreateCompanionBuilder =
    WorkoutPlansCompanion Function({
      required String ownerId,
      required String program,
      required String equipment,
      required int restWeekday,
      required String liftWeekdays,
      required bool fourthDay,
      required String startDay,
      Value<int> rowid,
    });
typedef $$WorkoutPlansTableUpdateCompanionBuilder =
    WorkoutPlansCompanion Function({
      Value<String> ownerId,
      Value<String> program,
      Value<String> equipment,
      Value<int> restWeekday,
      Value<String> liftWeekdays,
      Value<bool> fourthDay,
      Value<String> startDay,
      Value<int> rowid,
    });

class $$WorkoutPlansTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutPlansTable> {
  $$WorkoutPlansTableFilterComposer({
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

  ColumnFilters<String> get program => $composableBuilder(
    column: $table.program,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restWeekday => $composableBuilder(
    column: $table.restWeekday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get liftWeekdays => $composableBuilder(
    column: $table.liftWeekdays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get fourthDay => $composableBuilder(
    column: $table.fourthDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startDay => $composableBuilder(
    column: $table.startDay,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkoutPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutPlansTable> {
  $$WorkoutPlansTableOrderingComposer({
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

  ColumnOrderings<String> get program => $composableBuilder(
    column: $table.program,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restWeekday => $composableBuilder(
    column: $table.restWeekday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get liftWeekdays => $composableBuilder(
    column: $table.liftWeekdays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get fourthDay => $composableBuilder(
    column: $table.fourthDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDay => $composableBuilder(
    column: $table.startDay,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutPlansTable> {
  $$WorkoutPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get program =>
      $composableBuilder(column: $table.program, builder: (column) => column);

  GeneratedColumn<String> get equipment =>
      $composableBuilder(column: $table.equipment, builder: (column) => column);

  GeneratedColumn<int> get restWeekday => $composableBuilder(
    column: $table.restWeekday,
    builder: (column) => column,
  );

  GeneratedColumn<String> get liftWeekdays => $composableBuilder(
    column: $table.liftWeekdays,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get fourthDay =>
      $composableBuilder(column: $table.fourthDay, builder: (column) => column);

  GeneratedColumn<String> get startDay =>
      $composableBuilder(column: $table.startDay, builder: (column) => column);
}

class $$WorkoutPlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutPlansTable,
          WorkoutPlanRow,
          $$WorkoutPlansTableFilterComposer,
          $$WorkoutPlansTableOrderingComposer,
          $$WorkoutPlansTableAnnotationComposer,
          $$WorkoutPlansTableCreateCompanionBuilder,
          $$WorkoutPlansTableUpdateCompanionBuilder,
          (
            WorkoutPlanRow,
            BaseReferences<_$AppDatabase, $WorkoutPlansTable, WorkoutPlanRow>,
          ),
          WorkoutPlanRow,
          PrefetchHooks Function()
        > {
  $$WorkoutPlansTableTableManager(_$AppDatabase db, $WorkoutPlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> ownerId = const Value.absent(),
                Value<String> program = const Value.absent(),
                Value<String> equipment = const Value.absent(),
                Value<int> restWeekday = const Value.absent(),
                Value<String> liftWeekdays = const Value.absent(),
                Value<bool> fourthDay = const Value.absent(),
                Value<String> startDay = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutPlansCompanion(
                ownerId: ownerId,
                program: program,
                equipment: equipment,
                restWeekday: restWeekday,
                liftWeekdays: liftWeekdays,
                fourthDay: fourthDay,
                startDay: startDay,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ownerId,
                required String program,
                required String equipment,
                required int restWeekday,
                required String liftWeekdays,
                required bool fourthDay,
                required String startDay,
                Value<int> rowid = const Value.absent(),
              }) => WorkoutPlansCompanion.insert(
                ownerId: ownerId,
                program: program,
                equipment: equipment,
                restWeekday: restWeekday,
                liftWeekdays: liftWeekdays,
                fourthDay: fourthDay,
                startDay: startDay,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkoutPlansTable, WorkoutPlanRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $WorkoutPlansTable,
                    WorkoutPlanRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkoutPlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutPlansTable,
      WorkoutPlanRow,
      $$WorkoutPlansTableFilterComposer,
      $$WorkoutPlansTableOrderingComposer,
      $$WorkoutPlansTableAnnotationComposer,
      $$WorkoutPlansTableCreateCompanionBuilder,
      $$WorkoutPlansTableUpdateCompanionBuilder,
      (
        WorkoutPlanRow,
        BaseReferences<_$AppDatabase, $WorkoutPlansTable, WorkoutPlanRow>,
      ),
      WorkoutPlanRow,
      PrefetchHooks Function()
    >;
typedef $$WorkoutSessionsTableCreateCompanionBuilder =
    WorkoutSessionsCompanion Function({
      required String id,
      required String ownerId,
      required String day,
      required String program,
      required int planDay,
      required int planWeek,
      required String title,
      required String sessionType,
      required int minutes,
      required int startedAtUtcMs,
      required int startUtcOffsetMinutes,
      Value<int?> finishedAtUtcMs,
      Value<int?> finishUtcOffsetMinutes,
      required String finishEventId,
      Value<int> rowid,
    });
typedef $$WorkoutSessionsTableUpdateCompanionBuilder =
    WorkoutSessionsCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<String> day,
      Value<String> program,
      Value<int> planDay,
      Value<int> planWeek,
      Value<String> title,
      Value<String> sessionType,
      Value<int> minutes,
      Value<int> startedAtUtcMs,
      Value<int> startUtcOffsetMinutes,
      Value<int?> finishedAtUtcMs,
      Value<int?> finishUtcOffsetMinutes,
      Value<String> finishEventId,
      Value<int> rowid,
    });

final class $$WorkoutSessionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $WorkoutSessionsTable,
          WorkoutSessionRow
        > {
  $$WorkoutSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$WorkoutExercisesTable, List<WorkoutExerciseRow>>
  _workoutExercisesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workoutExercises,
    aliasName: 'workout_sessions__id__workout_exercises__session_id',
  );

  $$WorkoutExercisesTableProcessedTableManager get workoutExercisesRefs {
    final manager = $$WorkoutExercisesTableTableManager(
      $_db,
      $_db.workoutExercises,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workoutExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkoutSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableFilterComposer({
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

  ColumnFilters<String> get program => $composableBuilder(
    column: $table.program,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get planDay => $composableBuilder(
    column: $table.planDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get planWeek => $composableBuilder(
    column: $table.planWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionType => $composableBuilder(
    column: $table.sessionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minutes => $composableBuilder(
    column: $table.minutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAtUtcMs => $composableBuilder(
    column: $table.startedAtUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startUtcOffsetMinutes => $composableBuilder(
    column: $table.startUtcOffsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get finishedAtUtcMs => $composableBuilder(
    column: $table.finishedAtUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get finishUtcOffsetMinutes => $composableBuilder(
    column: $table.finishUtcOffsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get finishEventId => $composableBuilder(
    column: $table.finishEventId,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> workoutExercisesRefs(
    Expression<bool> Function($$WorkoutExercisesTableFilterComposer f) f,
  ) {
    final $$WorkoutExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutExercises,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutExercisesTableFilterComposer(
            $db: $db,
            $table: $db.workoutExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableOrderingComposer({
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

  ColumnOrderings<String> get program => $composableBuilder(
    column: $table.program,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get planDay => $composableBuilder(
    column: $table.planDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get planWeek => $composableBuilder(
    column: $table.planWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionType => $composableBuilder(
    column: $table.sessionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minutes => $composableBuilder(
    column: $table.minutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAtUtcMs => $composableBuilder(
    column: $table.startedAtUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startUtcOffsetMinutes => $composableBuilder(
    column: $table.startUtcOffsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get finishedAtUtcMs => $composableBuilder(
    column: $table.finishedAtUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get finishUtcOffsetMinutes => $composableBuilder(
    column: $table.finishUtcOffsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get finishEventId => $composableBuilder(
    column: $table.finishEventId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableAnnotationComposer({
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

  GeneratedColumn<String> get program =>
      $composableBuilder(column: $table.program, builder: (column) => column);

  GeneratedColumn<int> get planDay =>
      $composableBuilder(column: $table.planDay, builder: (column) => column);

  GeneratedColumn<int> get planWeek =>
      $composableBuilder(column: $table.planWeek, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get sessionType => $composableBuilder(
    column: $table.sessionType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minutes =>
      $composableBuilder(column: $table.minutes, builder: (column) => column);

  GeneratedColumn<int> get startedAtUtcMs => $composableBuilder(
    column: $table.startedAtUtcMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startUtcOffsetMinutes => $composableBuilder(
    column: $table.startUtcOffsetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get finishedAtUtcMs => $composableBuilder(
    column: $table.finishedAtUtcMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get finishUtcOffsetMinutes => $composableBuilder(
    column: $table.finishUtcOffsetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get finishEventId => $composableBuilder(
    column: $table.finishEventId,
    builder: (column) => column,
  );

  Expression<T> workoutExercisesRefs<T extends Object>(
    Expression<T> Function($$WorkoutExercisesTableAnnotationComposer a) f,
  ) {
    final $$WorkoutExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutExercises,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutSessionsTable,
          WorkoutSessionRow,
          $$WorkoutSessionsTableFilterComposer,
          $$WorkoutSessionsTableOrderingComposer,
          $$WorkoutSessionsTableAnnotationComposer,
          $$WorkoutSessionsTableCreateCompanionBuilder,
          $$WorkoutSessionsTableUpdateCompanionBuilder,
          (WorkoutSessionRow, $$WorkoutSessionsTableReferences),
          WorkoutSessionRow,
          PrefetchHooks Function({bool workoutExercisesRefs})
        > {
  $$WorkoutSessionsTableTableManager(
    _$AppDatabase db,
    $WorkoutSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<String> program = const Value.absent(),
                Value<int> planDay = const Value.absent(),
                Value<int> planWeek = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> sessionType = const Value.absent(),
                Value<int> minutes = const Value.absent(),
                Value<int> startedAtUtcMs = const Value.absent(),
                Value<int> startUtcOffsetMinutes = const Value.absent(),
                Value<int?> finishedAtUtcMs = const Value.absent(),
                Value<int?> finishUtcOffsetMinutes = const Value.absent(),
                Value<String> finishEventId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutSessionsCompanion(
                id: id,
                ownerId: ownerId,
                day: day,
                program: program,
                planDay: planDay,
                planWeek: planWeek,
                title: title,
                sessionType: sessionType,
                minutes: minutes,
                startedAtUtcMs: startedAtUtcMs,
                startUtcOffsetMinutes: startUtcOffsetMinutes,
                finishedAtUtcMs: finishedAtUtcMs,
                finishUtcOffsetMinutes: finishUtcOffsetMinutes,
                finishEventId: finishEventId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                required String day,
                required String program,
                required int planDay,
                required int planWeek,
                required String title,
                required String sessionType,
                required int minutes,
                required int startedAtUtcMs,
                required int startUtcOffsetMinutes,
                Value<int?> finishedAtUtcMs = const Value.absent(),
                Value<int?> finishUtcOffsetMinutes = const Value.absent(),
                required String finishEventId,
                Value<int> rowid = const Value.absent(),
              }) => WorkoutSessionsCompanion.insert(
                id: id,
                ownerId: ownerId,
                day: day,
                program: program,
                planDay: planDay,
                planWeek: planWeek,
                title: title,
                sessionType: sessionType,
                minutes: minutes,
                startedAtUtcMs: startedAtUtcMs,
                startUtcOffsetMinutes: startUtcOffsetMinutes,
                finishedAtUtcMs: finishedAtUtcMs,
                finishUtcOffsetMinutes: finishUtcOffsetMinutes,
                finishEventId: finishEventId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkoutSessionsTable, WorkoutSessionRow>(table),
                  $$WorkoutSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workoutExercisesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (workoutExercisesRefs) db.workoutExercises,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (workoutExercisesRefs)
                    await $_getPrefetchedDataByColumns<
                      WorkoutSessionRow,
                      $WorkoutSessionsTable,
                      WorkoutExerciseRow,
                      $WorkoutExercisesTable
                    >(
                      currentTable: table,
                      referencedTable: $$WorkoutSessionsTableReferences
                          ._workoutExercisesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$WorkoutSessionsTableReferences(
                            db,
                            table,
                            p0,
                          ).workoutExercisesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'session_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WorkoutSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutSessionsTable,
      WorkoutSessionRow,
      $$WorkoutSessionsTableFilterComposer,
      $$WorkoutSessionsTableOrderingComposer,
      $$WorkoutSessionsTableAnnotationComposer,
      $$WorkoutSessionsTableCreateCompanionBuilder,
      $$WorkoutSessionsTableUpdateCompanionBuilder,
      (WorkoutSessionRow, $$WorkoutSessionsTableReferences),
      WorkoutSessionRow,
      PrefetchHooks Function({bool workoutExercisesRefs})
    >;
typedef $$WorkoutExercisesTableCreateCompanionBuilder =
    WorkoutExercisesCompanion Function({
      required String id,
      required String sessionId,
      required int position,
      required String movementId,
      required String name,
      required String prescription,
      required String measure,
      required String weightMode,
      required int restBaseSeconds,
      Value<int?> restEndsAtUtcMs,
      Value<int?> restPausedSeconds,
      Value<int> rowid,
    });
typedef $$WorkoutExercisesTableUpdateCompanionBuilder =
    WorkoutExercisesCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<int> position,
      Value<String> movementId,
      Value<String> name,
      Value<String> prescription,
      Value<String> measure,
      Value<String> weightMode,
      Value<int> restBaseSeconds,
      Value<int?> restEndsAtUtcMs,
      Value<int?> restPausedSeconds,
      Value<int> rowid,
    });

final class $$WorkoutExercisesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $WorkoutExercisesTable,
          WorkoutExerciseRow
        > {
  $$WorkoutExercisesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkoutSessionsTable _sessionIdTable(_$AppDatabase db) => db
      .workoutSessions
      .createAlias('workout_exercises__session_id__workout_sessions__id');

  $$WorkoutSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$WorkoutSessionsTableTableManager(
      $_db,
      $_db.workoutSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$WorkoutSetsTable, List<WorkoutSetRow>>
  _workoutSetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workoutSets,
    aliasName: 'workout_exercises__id__workout_sets__exercise_id',
  );

  $$WorkoutSetsTableProcessedTableManager get workoutSetsRefs {
    final manager = $$WorkoutSetsTableTableManager(
      $_db,
      $_db.workoutSets,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_workoutSetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkoutExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutExercisesTable> {
  $$WorkoutExercisesTableFilterComposer({
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

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get movementId => $composableBuilder(
    column: $table.movementId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prescription => $composableBuilder(
    column: $table.prescription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get measure => $composableBuilder(
    column: $table.measure,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weightMode => $composableBuilder(
    column: $table.weightMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restBaseSeconds => $composableBuilder(
    column: $table.restBaseSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restEndsAtUtcMs => $composableBuilder(
    column: $table.restEndsAtUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restPausedSeconds => $composableBuilder(
    column: $table.restPausedSeconds,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutSessionsTableFilterComposer get sessionId {
    final $$WorkoutSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableFilterComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> workoutSetsRefs(
    Expression<bool> Function($$WorkoutSetsTableFilterComposer f) f,
  ) {
    final $$WorkoutSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutSets,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSetsTableFilterComposer(
            $db: $db,
            $table: $db.workoutSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutExercisesTable> {
  $$WorkoutExercisesTableOrderingComposer({
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

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get movementId => $composableBuilder(
    column: $table.movementId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prescription => $composableBuilder(
    column: $table.prescription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get measure => $composableBuilder(
    column: $table.measure,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weightMode => $composableBuilder(
    column: $table.weightMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restBaseSeconds => $composableBuilder(
    column: $table.restBaseSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restEndsAtUtcMs => $composableBuilder(
    column: $table.restEndsAtUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restPausedSeconds => $composableBuilder(
    column: $table.restPausedSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutSessionsTableOrderingComposer get sessionId {
    final $$WorkoutSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutExercisesTable> {
  $$WorkoutExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get movementId => $composableBuilder(
    column: $table.movementId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get prescription => $composableBuilder(
    column: $table.prescription,
    builder: (column) => column,
  );

  GeneratedColumn<String> get measure =>
      $composableBuilder(column: $table.measure, builder: (column) => column);

  GeneratedColumn<String> get weightMode => $composableBuilder(
    column: $table.weightMode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get restBaseSeconds => $composableBuilder(
    column: $table.restBaseSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get restEndsAtUtcMs => $composableBuilder(
    column: $table.restEndsAtUtcMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get restPausedSeconds => $composableBuilder(
    column: $table.restPausedSeconds,
    builder: (column) => column,
  );

  $$WorkoutSessionsTableAnnotationComposer get sessionId {
    final $$WorkoutSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> workoutSetsRefs<T extends Object>(
    Expression<T> Function($$WorkoutSetsTableAnnotationComposer a) f,
  ) {
    final $$WorkoutSetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutSets,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSetsTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutExercisesTable,
          WorkoutExerciseRow,
          $$WorkoutExercisesTableFilterComposer,
          $$WorkoutExercisesTableOrderingComposer,
          $$WorkoutExercisesTableAnnotationComposer,
          $$WorkoutExercisesTableCreateCompanionBuilder,
          $$WorkoutExercisesTableUpdateCompanionBuilder,
          (WorkoutExerciseRow, $$WorkoutExercisesTableReferences),
          WorkoutExerciseRow,
          PrefetchHooks Function({bool sessionId, bool workoutSetsRefs})
        > {
  $$WorkoutExercisesTableTableManager(
    _$AppDatabase db,
    $WorkoutExercisesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> movementId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> prescription = const Value.absent(),
                Value<String> measure = const Value.absent(),
                Value<String> weightMode = const Value.absent(),
                Value<int> restBaseSeconds = const Value.absent(),
                Value<int?> restEndsAtUtcMs = const Value.absent(),
                Value<int?> restPausedSeconds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutExercisesCompanion(
                id: id,
                sessionId: sessionId,
                position: position,
                movementId: movementId,
                name: name,
                prescription: prescription,
                measure: measure,
                weightMode: weightMode,
                restBaseSeconds: restBaseSeconds,
                restEndsAtUtcMs: restEndsAtUtcMs,
                restPausedSeconds: restPausedSeconds,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required int position,
                required String movementId,
                required String name,
                required String prescription,
                required String measure,
                required String weightMode,
                required int restBaseSeconds,
                Value<int?> restEndsAtUtcMs = const Value.absent(),
                Value<int?> restPausedSeconds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutExercisesCompanion.insert(
                id: id,
                sessionId: sessionId,
                position: position,
                movementId: movementId,
                name: name,
                prescription: prescription,
                measure: measure,
                weightMode: weightMode,
                restBaseSeconds: restBaseSeconds,
                restEndsAtUtcMs: restEndsAtUtcMs,
                restPausedSeconds: restPausedSeconds,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkoutExercisesTable, WorkoutExerciseRow>(
                    table,
                  ),
                  $$WorkoutExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({sessionId = false, workoutSetsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (workoutSetsRefs) db.workoutSets,
                  ],
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
                        if (sessionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sessionId,
                                    referencedTable:
                                        $$WorkoutExercisesTableReferences
                                            ._sessionIdTable(db),
                                    referencedColumn:
                                        $$WorkoutExercisesTableReferences
                                            ._sessionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (workoutSetsRefs)
                        await $_getPrefetchedDataByColumns<
                          WorkoutExerciseRow,
                          $WorkoutExercisesTable,
                          WorkoutSetRow,
                          $WorkoutSetsTable
                        >(
                          currentTable: table,
                          referencedTable: $$WorkoutExercisesTableReferences
                              ._workoutSetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkoutExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutSetsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'exercise_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$WorkoutExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutExercisesTable,
      WorkoutExerciseRow,
      $$WorkoutExercisesTableFilterComposer,
      $$WorkoutExercisesTableOrderingComposer,
      $$WorkoutExercisesTableAnnotationComposer,
      $$WorkoutExercisesTableCreateCompanionBuilder,
      $$WorkoutExercisesTableUpdateCompanionBuilder,
      (WorkoutExerciseRow, $$WorkoutExercisesTableReferences),
      WorkoutExerciseRow,
      PrefetchHooks Function({bool sessionId, bool workoutSetsRefs})
    >;
typedef $$WorkoutSetsTableCreateCompanionBuilder =
    WorkoutSetsCompanion Function({
      required String id,
      required String exerciseId,
      required int position,
      required String target,
      Value<int?> reps,
      Value<double?> weightLb,
      Value<bool> ticked,
      Value<int> rowid,
    });
typedef $$WorkoutSetsTableUpdateCompanionBuilder =
    WorkoutSetsCompanion Function({
      Value<String> id,
      Value<String> exerciseId,
      Value<int> position,
      Value<String> target,
      Value<int?> reps,
      Value<double?> weightLb,
      Value<bool> ticked,
      Value<int> rowid,
    });

final class $$WorkoutSetsTableReferences
    extends BaseReferences<_$AppDatabase, $WorkoutSetsTable, WorkoutSetRow> {
  $$WorkoutSetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkoutExercisesTable _exerciseIdTable(_$AppDatabase db) => db
      .workoutExercises
      .createAlias('workout_sets__exercise_id__workout_exercises__id');

  $$WorkoutExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<String>('exercise_id')!;

    final manager = $$WorkoutExercisesTableTableManager(
      $_db,
      $_db.workoutExercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WorkoutSetsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableFilterComposer({
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

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightLb => $composableBuilder(
    column: $table.weightLb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get ticked => $composableBuilder(
    column: $table.ticked,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutExercisesTableFilterComposer get exerciseId {
    final $$WorkoutExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.workoutExercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutExercisesTableFilterComposer(
            $db: $db,
            $table: $db.workoutExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutSetsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableOrderingComposer({
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

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightLb => $composableBuilder(
    column: $table.weightLb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get ticked => $composableBuilder(
    column: $table.ticked,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutExercisesTableOrderingComposer get exerciseId {
    final $$WorkoutExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.workoutExercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.workoutExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutSetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<double> get weightLb =>
      $composableBuilder(column: $table.weightLb, builder: (column) => column);

  GeneratedColumn<bool> get ticked =>
      $composableBuilder(column: $table.ticked, builder: (column) => column);

  $$WorkoutExercisesTableAnnotationComposer get exerciseId {
    final $$WorkoutExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.workoutExercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutSetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutSetsTable,
          WorkoutSetRow,
          $$WorkoutSetsTableFilterComposer,
          $$WorkoutSetsTableOrderingComposer,
          $$WorkoutSetsTableAnnotationComposer,
          $$WorkoutSetsTableCreateCompanionBuilder,
          $$WorkoutSetsTableUpdateCompanionBuilder,
          (WorkoutSetRow, $$WorkoutSetsTableReferences),
          WorkoutSetRow,
          PrefetchHooks Function({bool exerciseId})
        > {
  $$WorkoutSetsTableTableManager(_$AppDatabase db, $WorkoutSetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> target = const Value.absent(),
                Value<int?> reps = const Value.absent(),
                Value<double?> weightLb = const Value.absent(),
                Value<bool> ticked = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutSetsCompanion(
                id: id,
                exerciseId: exerciseId,
                position: position,
                target: target,
                reps: reps,
                weightLb: weightLb,
                ticked: ticked,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String exerciseId,
                required int position,
                required String target,
                Value<int?> reps = const Value.absent(),
                Value<double?> weightLb = const Value.absent(),
                Value<bool> ticked = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutSetsCompanion.insert(
                id: id,
                exerciseId: exerciseId,
                position: position,
                target: target,
                reps: reps,
                weightLb: weightLb,
                ticked: ticked,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkoutSetsTable, WorkoutSetRow>(table),
                  $$WorkoutSetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseId = false}) {
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
                    if (exerciseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseId,
                                referencedTable: $$WorkoutSetsTableReferences
                                    ._exerciseIdTable(db),
                                referencedColumn: $$WorkoutSetsTableReferences
                                    ._exerciseIdTable(db)
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

typedef $$WorkoutSetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutSetsTable,
      WorkoutSetRow,
      $$WorkoutSetsTableFilterComposer,
      $$WorkoutSetsTableOrderingComposer,
      $$WorkoutSetsTableAnnotationComposer,
      $$WorkoutSetsTableCreateCompanionBuilder,
      $$WorkoutSetsTableUpdateCompanionBuilder,
      (WorkoutSetRow, $$WorkoutSetsTableReferences),
      WorkoutSetRow,
      PrefetchHooks Function({bool exerciseId})
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
  $$WorkoutPlansTableTableManager get workoutPlans =>
      $$WorkoutPlansTableTableManager(_db, _db.workoutPlans);
  $$WorkoutSessionsTableTableManager get workoutSessions =>
      $$WorkoutSessionsTableTableManager(_db, _db.workoutSessions);
  $$WorkoutExercisesTableTableManager get workoutExercises =>
      $$WorkoutExercisesTableTableManager(_db, _db.workoutExercises);
  $$WorkoutSetsTableTableManager get workoutSets =>
      $$WorkoutSetsTableTableManager(_db, _db.workoutSets);
}
