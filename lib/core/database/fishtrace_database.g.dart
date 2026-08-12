// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fishtrace_database.dart';

// ignore_for_file: type=lint
class $SyncOperationsTable extends SyncOperations
    with TableInfo<$SyncOperationsTable, SyncOperation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOperationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordTypeMeta = const VerificationMeta(
    'recordType',
  );
  @override
  late final GeneratedColumn<String> recordType = GeneratedColumn<String>(
    'record_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('operation'),
  );
  static const VerificationMeta _clientRecordIdMeta = const VerificationMeta(
    'clientRecordId',
  );
  @override
  late final GeneratedColumn<String> clientRecordId = GeneratedColumn<String>(
    'client_record_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endpointMeta = const VerificationMeta(
    'endpoint',
  );
  @override
  late final GeneratedColumn<String> endpoint = GeneratedColumn<String>(
    'endpoint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('/sync'),
  );
  static const VerificationMeta _requestMethodMeta = const VerificationMeta(
    'requestMethod',
  );
  @override
  late final GeneratedColumn<String> requestMethod = GeneratedColumn<String>(
    'request_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('POST'),
  );
  static const VerificationMeta _localFileReferencesMeta =
      const VerificationMeta('localFileReferences');
  @override
  late final GeneratedColumn<String> localFileReferences =
      GeneratedColumn<String>(
        'local_file_references',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta(
    'nextAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>(
        'next_attempt_at',
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
    serverId,
    label,
    recordType,
    clientRecordId,
    endpoint,
    requestMethod,
    localFileReferences,
    payload,
    status,
    retryCount,
    lastError,
    idempotencyKey,
    nextAttemptAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncOperation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('record_type')) {
      context.handle(
        _recordTypeMeta,
        recordType.isAcceptableOrUnknown(data['record_type']!, _recordTypeMeta),
      );
    }
    if (data.containsKey('client_record_id')) {
      context.handle(
        _clientRecordIdMeta,
        clientRecordId.isAcceptableOrUnknown(
          data['client_record_id']!,
          _clientRecordIdMeta,
        ),
      );
    }
    if (data.containsKey('endpoint')) {
      context.handle(
        _endpointMeta,
        endpoint.isAcceptableOrUnknown(data['endpoint']!, _endpointMeta),
      );
    }
    if (data.containsKey('request_method')) {
      context.handle(
        _requestMethodMeta,
        requestMethod.isAcceptableOrUnknown(
          data['request_method']!,
          _requestMethodMeta,
        ),
      );
    }
    if (data.containsKey('local_file_references')) {
      context.handle(
        _localFileReferencesMeta,
        localFileReferences.isAcceptableOrUnknown(
          data['local_file_references']!,
          _localFileReferencesMeta,
        ),
      );
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(
          data['next_attempt_at']!,
          _nextAttemptAtMeta,
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
  SyncOperation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOperation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      recordType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_type'],
      )!,
      clientRecordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_record_id'],
      ),
      endpoint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}endpoint'],
      )!,
      requestMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_method'],
      )!,
      localFileReferences: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_file_references'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_attempt_at'],
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
  $SyncOperationsTable createAlias(String alias) {
    return $SyncOperationsTable(attachedDatabase, alias);
  }
}

class SyncOperation extends DataClass implements Insertable<SyncOperation> {
  final String id;
  final String? serverId;
  final String label;
  final String recordType;
  final String? clientRecordId;
  final String endpoint;
  final String requestMethod;
  final String localFileReferences;
  final String payload;
  final String status;
  final int retryCount;
  final String? lastError;
  final String idempotencyKey;
  final DateTime? nextAttemptAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SyncOperation({
    required this.id,
    this.serverId,
    required this.label,
    required this.recordType,
    this.clientRecordId,
    required this.endpoint,
    required this.requestMethod,
    required this.localFileReferences,
    required this.payload,
    required this.status,
    required this.retryCount,
    this.lastError,
    required this.idempotencyKey,
    this.nextAttemptAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['label'] = Variable<String>(label);
    map['record_type'] = Variable<String>(recordType);
    if (!nullToAbsent || clientRecordId != null) {
      map['client_record_id'] = Variable<String>(clientRecordId);
    }
    map['endpoint'] = Variable<String>(endpoint);
    map['request_method'] = Variable<String>(requestMethod);
    map['local_file_references'] = Variable<String>(localFileReferences);
    map['payload'] = Variable<String>(payload);
    map['status'] = Variable<String>(status);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SyncOperationsCompanion toCompanion(bool nullToAbsent) {
    return SyncOperationsCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      label: Value(label),
      recordType: Value(recordType),
      clientRecordId: clientRecordId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientRecordId),
      endpoint: Value(endpoint),
      requestMethod: Value(requestMethod),
      localFileReferences: Value(localFileReferences),
      payload: Value(payload),
      status: Value(status),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      idempotencyKey: Value(idempotencyKey),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SyncOperation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOperation(
      id: serializer.fromJson<String>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      label: serializer.fromJson<String>(json['label']),
      recordType: serializer.fromJson<String>(json['recordType']),
      clientRecordId: serializer.fromJson<String?>(json['clientRecordId']),
      endpoint: serializer.fromJson<String>(json['endpoint']),
      requestMethod: serializer.fromJson<String>(json['requestMethod']),
      localFileReferences: serializer.fromJson<String>(
        json['localFileReferences'],
      ),
      payload: serializer.fromJson<String>(json['payload']),
      status: serializer.fromJson<String>(json['status']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['nextAttemptAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'label': serializer.toJson<String>(label),
      'recordType': serializer.toJson<String>(recordType),
      'clientRecordId': serializer.toJson<String?>(clientRecordId),
      'endpoint': serializer.toJson<String>(endpoint),
      'requestMethod': serializer.toJson<String>(requestMethod),
      'localFileReferences': serializer.toJson<String>(localFileReferences),
      'payload': serializer.toJson<String>(payload),
      'status': serializer.toJson<String>(status),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'nextAttemptAt': serializer.toJson<DateTime?>(nextAttemptAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SyncOperation copyWith({
    String? id,
    Value<String?> serverId = const Value.absent(),
    String? label,
    String? recordType,
    Value<String?> clientRecordId = const Value.absent(),
    String? endpoint,
    String? requestMethod,
    String? localFileReferences,
    String? payload,
    String? status,
    int? retryCount,
    Value<String?> lastError = const Value.absent(),
    String? idempotencyKey,
    Value<DateTime?> nextAttemptAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SyncOperation(
    id: id ?? this.id,
    serverId: serverId.present ? serverId.value : this.serverId,
    label: label ?? this.label,
    recordType: recordType ?? this.recordType,
    clientRecordId: clientRecordId.present
        ? clientRecordId.value
        : this.clientRecordId,
    endpoint: endpoint ?? this.endpoint,
    requestMethod: requestMethod ?? this.requestMethod,
    localFileReferences: localFileReferences ?? this.localFileReferences,
    payload: payload ?? this.payload,
    status: status ?? this.status,
    retryCount: retryCount ?? this.retryCount,
    lastError: lastError.present ? lastError.value : this.lastError,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    nextAttemptAt: nextAttemptAt.present
        ? nextAttemptAt.value
        : this.nextAttemptAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SyncOperation copyWithCompanion(SyncOperationsCompanion data) {
    return SyncOperation(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      label: data.label.present ? data.label.value : this.label,
      recordType: data.recordType.present
          ? data.recordType.value
          : this.recordType,
      clientRecordId: data.clientRecordId.present
          ? data.clientRecordId.value
          : this.clientRecordId,
      endpoint: data.endpoint.present ? data.endpoint.value : this.endpoint,
      requestMethod: data.requestMethod.present
          ? data.requestMethod.value
          : this.requestMethod,
      localFileReferences: data.localFileReferences.present
          ? data.localFileReferences.value
          : this.localFileReferences,
      payload: data.payload.present ? data.payload.value : this.payload,
      status: data.status.present ? data.status.value : this.status,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOperation(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('label: $label, ')
          ..write('recordType: $recordType, ')
          ..write('clientRecordId: $clientRecordId, ')
          ..write('endpoint: $endpoint, ')
          ..write('requestMethod: $requestMethod, ')
          ..write('localFileReferences: $localFileReferences, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serverId,
    label,
    recordType,
    clientRecordId,
    endpoint,
    requestMethod,
    localFileReferences,
    payload,
    status,
    retryCount,
    lastError,
    idempotencyKey,
    nextAttemptAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOperation &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.label == this.label &&
          other.recordType == this.recordType &&
          other.clientRecordId == this.clientRecordId &&
          other.endpoint == this.endpoint &&
          other.requestMethod == this.requestMethod &&
          other.localFileReferences == this.localFileReferences &&
          other.payload == this.payload &&
          other.status == this.status &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError &&
          other.idempotencyKey == this.idempotencyKey &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SyncOperationsCompanion extends UpdateCompanion<SyncOperation> {
  final Value<String> id;
  final Value<String?> serverId;
  final Value<String> label;
  final Value<String> recordType;
  final Value<String?> clientRecordId;
  final Value<String> endpoint;
  final Value<String> requestMethod;
  final Value<String> localFileReferences;
  final Value<String> payload;
  final Value<String> status;
  final Value<int> retryCount;
  final Value<String?> lastError;
  final Value<String> idempotencyKey;
  final Value<DateTime?> nextAttemptAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SyncOperationsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.label = const Value.absent(),
    this.recordType = const Value.absent(),
    this.clientRecordId = const Value.absent(),
    this.endpoint = const Value.absent(),
    this.requestMethod = const Value.absent(),
    this.localFileReferences = const Value.absent(),
    this.payload = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncOperationsCompanion.insert({
    required String id,
    this.serverId = const Value.absent(),
    required String label,
    this.recordType = const Value.absent(),
    this.clientRecordId = const Value.absent(),
    this.endpoint = const Value.absent(),
    this.requestMethod = const Value.absent(),
    this.localFileReferences = const Value.absent(),
    this.payload = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    required String idempotencyKey,
    this.nextAttemptAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       label = Value(label),
       idempotencyKey = Value(idempotencyKey),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SyncOperation> custom({
    Expression<String>? id,
    Expression<String>? serverId,
    Expression<String>? label,
    Expression<String>? recordType,
    Expression<String>? clientRecordId,
    Expression<String>? endpoint,
    Expression<String>? requestMethod,
    Expression<String>? localFileReferences,
    Expression<String>? payload,
    Expression<String>? status,
    Expression<int>? retryCount,
    Expression<String>? lastError,
    Expression<String>? idempotencyKey,
    Expression<DateTime>? nextAttemptAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (label != null) 'label': label,
      if (recordType != null) 'record_type': recordType,
      if (clientRecordId != null) 'client_record_id': clientRecordId,
      if (endpoint != null) 'endpoint': endpoint,
      if (requestMethod != null) 'request_method': requestMethod,
      if (localFileReferences != null)
        'local_file_references': localFileReferences,
      if (payload != null) 'payload': payload,
      if (status != null) 'status': status,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncOperationsCompanion copyWith({
    Value<String>? id,
    Value<String?>? serverId,
    Value<String>? label,
    Value<String>? recordType,
    Value<String?>? clientRecordId,
    Value<String>? endpoint,
    Value<String>? requestMethod,
    Value<String>? localFileReferences,
    Value<String>? payload,
    Value<String>? status,
    Value<int>? retryCount,
    Value<String?>? lastError,
    Value<String>? idempotencyKey,
    Value<DateTime?>? nextAttemptAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SyncOperationsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      label: label ?? this.label,
      recordType: recordType ?? this.recordType,
      clientRecordId: clientRecordId ?? this.clientRecordId,
      endpoint: endpoint ?? this.endpoint,
      requestMethod: requestMethod ?? this.requestMethod,
      localFileReferences: localFileReferences ?? this.localFileReferences,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      createdAt: createdAt ?? this.createdAt,
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
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (recordType.present) {
      map['record_type'] = Variable<String>(recordType.value);
    }
    if (clientRecordId.present) {
      map['client_record_id'] = Variable<String>(clientRecordId.value);
    }
    if (endpoint.present) {
      map['endpoint'] = Variable<String>(endpoint.value);
    }
    if (requestMethod.present) {
      map['request_method'] = Variable<String>(requestMethod.value);
    }
    if (localFileReferences.present) {
      map['local_file_references'] = Variable<String>(
        localFileReferences.value,
      );
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('SyncOperationsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('label: $label, ')
          ..write('recordType: $recordType, ')
          ..write('clientRecordId: $clientRecordId, ')
          ..write('endpoint: $endpoint, ')
          ..write('requestMethod: $requestMethod, ')
          ..write('localFileReferences: $localFileReferences, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalRecordsTable extends LocalRecords
    with TableInfo<$LocalRecordsTable, LocalRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordTypeMeta = const VerificationMeta(
    'recordType',
  );
  @override
  late final GeneratedColumn<String> recordType = GeneratedColumn<String>(
    'record_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
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
    localId,
    serverId,
    recordType,
    payload,
    syncStatus,
    version,
    deleted,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('record_type')) {
      context.handle(
        _recordTypeMeta,
        recordType.isAcceptableOrUnknown(data['record_type']!, _recordTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_recordTypeMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
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
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  LocalRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalRecord(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      recordType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_type'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
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
  $LocalRecordsTable createAlias(String alias) {
    return $LocalRecordsTable(attachedDatabase, alias);
  }
}

class LocalRecord extends DataClass implements Insertable<LocalRecord> {
  final String localId;
  final String? serverId;
  final String recordType;
  final String payload;
  final String syncStatus;
  final int version;
  final bool deleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LocalRecord({
    required this.localId,
    this.serverId,
    required this.recordType,
    required this.payload,
    required this.syncStatus,
    required this.version,
    required this.deleted,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<String>(localId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['record_type'] = Variable<String>(recordType);
    map['payload'] = Variable<String>(payload);
    map['sync_status'] = Variable<String>(syncStatus);
    map['version'] = Variable<int>(version);
    map['deleted'] = Variable<bool>(deleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalRecordsCompanion toCompanion(bool nullToAbsent) {
    return LocalRecordsCompanion(
      localId: Value(localId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      recordType: Value(recordType),
      payload: Value(payload),
      syncStatus: Value(syncStatus),
      version: Value(version),
      deleted: Value(deleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalRecord(
      localId: serializer.fromJson<String>(json['localId']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      recordType: serializer.fromJson<String>(json['recordType']),
      payload: serializer.fromJson<String>(json['payload']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      version: serializer.fromJson<int>(json['version']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<String>(localId),
      'serverId': serializer.toJson<String?>(serverId),
      'recordType': serializer.toJson<String>(recordType),
      'payload': serializer.toJson<String>(payload),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'version': serializer.toJson<int>(version),
      'deleted': serializer.toJson<bool>(deleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalRecord copyWith({
    String? localId,
    Value<String?> serverId = const Value.absent(),
    String? recordType,
    String? payload,
    String? syncStatus,
    int? version,
    bool? deleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LocalRecord(
    localId: localId ?? this.localId,
    serverId: serverId.present ? serverId.value : this.serverId,
    recordType: recordType ?? this.recordType,
    payload: payload ?? this.payload,
    syncStatus: syncStatus ?? this.syncStatus,
    version: version ?? this.version,
    deleted: deleted ?? this.deleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalRecord copyWithCompanion(LocalRecordsCompanion data) {
    return LocalRecord(
      localId: data.localId.present ? data.localId.value : this.localId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      recordType: data.recordType.present
          ? data.recordType.value
          : this.recordType,
      payload: data.payload.present ? data.payload.value : this.payload,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      version: data.version.present ? data.version.value : this.version,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalRecord(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('recordType: $recordType, ')
          ..write('payload: $payload, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('version: $version, ')
          ..write('deleted: $deleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    serverId,
    recordType,
    payload,
    syncStatus,
    version,
    deleted,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalRecord &&
          other.localId == this.localId &&
          other.serverId == this.serverId &&
          other.recordType == this.recordType &&
          other.payload == this.payload &&
          other.syncStatus == this.syncStatus &&
          other.version == this.version &&
          other.deleted == this.deleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalRecordsCompanion extends UpdateCompanion<LocalRecord> {
  final Value<String> localId;
  final Value<String?> serverId;
  final Value<String> recordType;
  final Value<String> payload;
  final Value<String> syncStatus;
  final Value<int> version;
  final Value<bool> deleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalRecordsCompanion({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.recordType = const Value.absent(),
    this.payload = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.version = const Value.absent(),
    this.deleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalRecordsCompanion.insert({
    required String localId,
    this.serverId = const Value.absent(),
    required String recordType,
    this.payload = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.version = const Value.absent(),
    this.deleted = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : localId = Value(localId),
       recordType = Value(recordType),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalRecord> custom({
    Expression<String>? localId,
    Expression<String>? serverId,
    Expression<String>? recordType,
    Expression<String>? payload,
    Expression<String>? syncStatus,
    Expression<int>? version,
    Expression<bool>? deleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (serverId != null) 'server_id': serverId,
      if (recordType != null) 'record_type': recordType,
      if (payload != null) 'payload': payload,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (version != null) 'version': version,
      if (deleted != null) 'deleted': deleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalRecordsCompanion copyWith({
    Value<String>? localId,
    Value<String?>? serverId,
    Value<String>? recordType,
    Value<String>? payload,
    Value<String>? syncStatus,
    Value<int>? version,
    Value<bool>? deleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalRecordsCompanion(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      recordType: recordType ?? this.recordType,
      payload: payload ?? this.payload,
      syncStatus: syncStatus ?? this.syncStatus,
      version: version ?? this.version,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (recordType.present) {
      map['record_type'] = Variable<String>(recordType.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('LocalRecordsCompanion(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('recordType: $recordType, ')
          ..write('payload: $payload, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('version: $version, ')
          ..write('deleted: $deleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuthMetadataRowsTable extends AuthMetadataRows
    with TableInfo<$AuthMetadataRowsTable, AuthMetadataRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuthMetadataRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastLoginAtMeta = const VerificationMeta(
    'lastLoginAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastLoginAt = GeneratedColumn<DateTime>(
    'last_login_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    displayName,
    email,
    role,
    lastLoginAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'auth_metadata_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuthMetadataRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('last_login_at')) {
      context.handle(
        _lastLoginAtMeta,
        lastLoginAt.isAcceptableOrUnknown(
          data['last_login_at']!,
          _lastLoginAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastLoginAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  AuthMetadataRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuthMetadataRow(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      lastLoginAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_login_at'],
      )!,
    );
  }

  @override
  $AuthMetadataRowsTable createAlias(String alias) {
    return $AuthMetadataRowsTable(attachedDatabase, alias);
  }
}

class AuthMetadataRow extends DataClass implements Insertable<AuthMetadataRow> {
  final String userId;
  final String displayName;
  final String email;
  final String role;
  final DateTime lastLoginAt;
  const AuthMetadataRow({
    required this.userId,
    required this.displayName,
    required this.email,
    required this.role,
    required this.lastLoginAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['display_name'] = Variable<String>(displayName);
    map['email'] = Variable<String>(email);
    map['role'] = Variable<String>(role);
    map['last_login_at'] = Variable<DateTime>(lastLoginAt);
    return map;
  }

  AuthMetadataRowsCompanion toCompanion(bool nullToAbsent) {
    return AuthMetadataRowsCompanion(
      userId: Value(userId),
      displayName: Value(displayName),
      email: Value(email),
      role: Value(role),
      lastLoginAt: Value(lastLoginAt),
    );
  }

  factory AuthMetadataRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuthMetadataRow(
      userId: serializer.fromJson<String>(json['userId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      email: serializer.fromJson<String>(json['email']),
      role: serializer.fromJson<String>(json['role']),
      lastLoginAt: serializer.fromJson<DateTime>(json['lastLoginAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'displayName': serializer.toJson<String>(displayName),
      'email': serializer.toJson<String>(email),
      'role': serializer.toJson<String>(role),
      'lastLoginAt': serializer.toJson<DateTime>(lastLoginAt),
    };
  }

  AuthMetadataRow copyWith({
    String? userId,
    String? displayName,
    String? email,
    String? role,
    DateTime? lastLoginAt,
  }) => AuthMetadataRow(
    userId: userId ?? this.userId,
    displayName: displayName ?? this.displayName,
    email: email ?? this.email,
    role: role ?? this.role,
    lastLoginAt: lastLoginAt ?? this.lastLoginAt,
  );
  AuthMetadataRow copyWithCompanion(AuthMetadataRowsCompanion data) {
    return AuthMetadataRow(
      userId: data.userId.present ? data.userId.value : this.userId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      email: data.email.present ? data.email.value : this.email,
      role: data.role.present ? data.role.value : this.role,
      lastLoginAt: data.lastLoginAt.present
          ? data.lastLoginAt.value
          : this.lastLoginAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuthMetadataRow(')
          ..write('userId: $userId, ')
          ..write('displayName: $displayName, ')
          ..write('email: $email, ')
          ..write('role: $role, ')
          ..write('lastLoginAt: $lastLoginAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(userId, displayName, email, role, lastLoginAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuthMetadataRow &&
          other.userId == this.userId &&
          other.displayName == this.displayName &&
          other.email == this.email &&
          other.role == this.role &&
          other.lastLoginAt == this.lastLoginAt);
}

class AuthMetadataRowsCompanion extends UpdateCompanion<AuthMetadataRow> {
  final Value<String> userId;
  final Value<String> displayName;
  final Value<String> email;
  final Value<String> role;
  final Value<DateTime> lastLoginAt;
  final Value<int> rowid;
  const AuthMetadataRowsCompanion({
    this.userId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.email = const Value.absent(),
    this.role = const Value.absent(),
    this.lastLoginAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuthMetadataRowsCompanion.insert({
    required String userId,
    required String displayName,
    required String email,
    required String role,
    required DateTime lastLoginAt,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       displayName = Value(displayName),
       email = Value(email),
       role = Value(role),
       lastLoginAt = Value(lastLoginAt);
  static Insertable<AuthMetadataRow> custom({
    Expression<String>? userId,
    Expression<String>? displayName,
    Expression<String>? email,
    Expression<String>? role,
    Expression<DateTime>? lastLoginAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (displayName != null) 'display_name': displayName,
      if (email != null) 'email': email,
      if (role != null) 'role': role,
      if (lastLoginAt != null) 'last_login_at': lastLoginAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuthMetadataRowsCompanion copyWith({
    Value<String>? userId,
    Value<String>? displayName,
    Value<String>? email,
    Value<String>? role,
    Value<DateTime>? lastLoginAt,
    Value<int>? rowid,
  }) {
    return AuthMetadataRowsCompanion(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      role: role ?? this.role,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (lastLoginAt.present) {
      map['last_login_at'] = Variable<DateTime>(lastLoginAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuthMetadataRowsCompanion(')
          ..write('userId: $userId, ')
          ..write('displayName: $displayName, ')
          ..write('email: $email, ')
          ..write('role: $role, ')
          ..write('lastLoginAt: $lastLoginAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BoatRowsTable extends BoatRows with TableInfo<$BoatRowsTable, BoatRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BoatRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _registrationMeta = const VerificationMeta(
    'registration',
  );
  @override
  late final GeneratedColumn<String> registration = GeneratedColumn<String>(
    'registration',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lengthMetresMeta = const VerificationMeta(
    'lengthMetres',
  );
  @override
  late final GeneratedColumn<double> lengthMetres = GeneratedColumn<double>(
    'length_metres',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _engineMeta = const VerificationMeta('engine');
  @override
  late final GeneratedColumn<String> engine = GeneratedColumn<String>(
    'engine',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _boatTypeMeta = const VerificationMeta(
    'boatType',
  );
  @override
  late final GeneratedColumn<String> boatType = GeneratedColumn<String>(
    'boat_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _homePortMeta = const VerificationMeta(
    'homePort',
  );
  @override
  late final GeneratedColumn<String> homePort = GeneratedColumn<String>(
    'home_port',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    localId,
    serverId,
    name,
    registration,
    lengthMetres,
    engine,
    boatType,
    homePort,
    active,
    syncStatus,
    retryCount,
    lastError,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'boat_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<BoatRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('registration')) {
      context.handle(
        _registrationMeta,
        registration.isAcceptableOrUnknown(
          data['registration']!,
          _registrationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_registrationMeta);
    }
    if (data.containsKey('length_metres')) {
      context.handle(
        _lengthMetresMeta,
        lengthMetres.isAcceptableOrUnknown(
          data['length_metres']!,
          _lengthMetresMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lengthMetresMeta);
    }
    if (data.containsKey('engine')) {
      context.handle(
        _engineMeta,
        engine.isAcceptableOrUnknown(data['engine']!, _engineMeta),
      );
    } else if (isInserting) {
      context.missing(_engineMeta);
    }
    if (data.containsKey('boat_type')) {
      context.handle(
        _boatTypeMeta,
        boatType.isAcceptableOrUnknown(data['boat_type']!, _boatTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_boatTypeMeta);
    }
    if (data.containsKey('home_port')) {
      context.handle(
        _homePortMeta,
        homePort.isAcceptableOrUnknown(data['home_port']!, _homePortMeta),
      );
    } else if (isInserting) {
      context.missing(_homePortMeta);
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
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
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  BoatRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BoatRow(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      registration: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}registration'],
      )!,
      lengthMetres: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}length_metres'],
      )!,
      engine: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}engine'],
      )!,
      boatType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}boat_type'],
      )!,
      homePort: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}home_port'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
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
  $BoatRowsTable createAlias(String alias) {
    return $BoatRowsTable(attachedDatabase, alias);
  }
}

class BoatRow extends DataClass implements Insertable<BoatRow> {
  final String localId;
  final String? serverId;
  final String name;
  final String registration;
  final double lengthMetres;
  final String engine;
  final String boatType;
  final String homePort;
  final bool active;
  final String syncStatus;
  final int retryCount;
  final String? lastError;
  final DateTime createdAt;
  final DateTime updatedAt;
  const BoatRow({
    required this.localId,
    this.serverId,
    required this.name,
    required this.registration,
    required this.lengthMetres,
    required this.engine,
    required this.boatType,
    required this.homePort,
    required this.active,
    required this.syncStatus,
    required this.retryCount,
    this.lastError,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<String>(localId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['name'] = Variable<String>(name);
    map['registration'] = Variable<String>(registration);
    map['length_metres'] = Variable<double>(lengthMetres);
    map['engine'] = Variable<String>(engine);
    map['boat_type'] = Variable<String>(boatType);
    map['home_port'] = Variable<String>(homePort);
    map['active'] = Variable<bool>(active);
    map['sync_status'] = Variable<String>(syncStatus);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BoatRowsCompanion toCompanion(bool nullToAbsent) {
    return BoatRowsCompanion(
      localId: Value(localId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      name: Value(name),
      registration: Value(registration),
      lengthMetres: Value(lengthMetres),
      engine: Value(engine),
      boatType: Value(boatType),
      homePort: Value(homePort),
      active: Value(active),
      syncStatus: Value(syncStatus),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory BoatRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BoatRow(
      localId: serializer.fromJson<String>(json['localId']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      name: serializer.fromJson<String>(json['name']),
      registration: serializer.fromJson<String>(json['registration']),
      lengthMetres: serializer.fromJson<double>(json['lengthMetres']),
      engine: serializer.fromJson<String>(json['engine']),
      boatType: serializer.fromJson<String>(json['boatType']),
      homePort: serializer.fromJson<String>(json['homePort']),
      active: serializer.fromJson<bool>(json['active']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<String>(localId),
      'serverId': serializer.toJson<String?>(serverId),
      'name': serializer.toJson<String>(name),
      'registration': serializer.toJson<String>(registration),
      'lengthMetres': serializer.toJson<double>(lengthMetres),
      'engine': serializer.toJson<String>(engine),
      'boatType': serializer.toJson<String>(boatType),
      'homePort': serializer.toJson<String>(homePort),
      'active': serializer.toJson<bool>(active),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  BoatRow copyWith({
    String? localId,
    Value<String?> serverId = const Value.absent(),
    String? name,
    String? registration,
    double? lengthMetres,
    String? engine,
    String? boatType,
    String? homePort,
    bool? active,
    String? syncStatus,
    int? retryCount,
    Value<String?> lastError = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => BoatRow(
    localId: localId ?? this.localId,
    serverId: serverId.present ? serverId.value : this.serverId,
    name: name ?? this.name,
    registration: registration ?? this.registration,
    lengthMetres: lengthMetres ?? this.lengthMetres,
    engine: engine ?? this.engine,
    boatType: boatType ?? this.boatType,
    homePort: homePort ?? this.homePort,
    active: active ?? this.active,
    syncStatus: syncStatus ?? this.syncStatus,
    retryCount: retryCount ?? this.retryCount,
    lastError: lastError.present ? lastError.value : this.lastError,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  BoatRow copyWithCompanion(BoatRowsCompanion data) {
    return BoatRow(
      localId: data.localId.present ? data.localId.value : this.localId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      name: data.name.present ? data.name.value : this.name,
      registration: data.registration.present
          ? data.registration.value
          : this.registration,
      lengthMetres: data.lengthMetres.present
          ? data.lengthMetres.value
          : this.lengthMetres,
      engine: data.engine.present ? data.engine.value : this.engine,
      boatType: data.boatType.present ? data.boatType.value : this.boatType,
      homePort: data.homePort.present ? data.homePort.value : this.homePort,
      active: data.active.present ? data.active.value : this.active,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BoatRow(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('name: $name, ')
          ..write('registration: $registration, ')
          ..write('lengthMetres: $lengthMetres, ')
          ..write('engine: $engine, ')
          ..write('boatType: $boatType, ')
          ..write('homePort: $homePort, ')
          ..write('active: $active, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    serverId,
    name,
    registration,
    lengthMetres,
    engine,
    boatType,
    homePort,
    active,
    syncStatus,
    retryCount,
    lastError,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BoatRow &&
          other.localId == this.localId &&
          other.serverId == this.serverId &&
          other.name == this.name &&
          other.registration == this.registration &&
          other.lengthMetres == this.lengthMetres &&
          other.engine == this.engine &&
          other.boatType == this.boatType &&
          other.homePort == this.homePort &&
          other.active == this.active &&
          other.syncStatus == this.syncStatus &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BoatRowsCompanion extends UpdateCompanion<BoatRow> {
  final Value<String> localId;
  final Value<String?> serverId;
  final Value<String> name;
  final Value<String> registration;
  final Value<double> lengthMetres;
  final Value<String> engine;
  final Value<String> boatType;
  final Value<String> homePort;
  final Value<bool> active;
  final Value<String> syncStatus;
  final Value<int> retryCount;
  final Value<String?> lastError;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const BoatRowsCompanion({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.name = const Value.absent(),
    this.registration = const Value.absent(),
    this.lengthMetres = const Value.absent(),
    this.engine = const Value.absent(),
    this.boatType = const Value.absent(),
    this.homePort = const Value.absent(),
    this.active = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BoatRowsCompanion.insert({
    required String localId,
    this.serverId = const Value.absent(),
    required String name,
    required String registration,
    required double lengthMetres,
    required String engine,
    required String boatType,
    required String homePort,
    this.active = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : localId = Value(localId),
       name = Value(name),
       registration = Value(registration),
       lengthMetres = Value(lengthMetres),
       engine = Value(engine),
       boatType = Value(boatType),
       homePort = Value(homePort),
       updatedAt = Value(updatedAt);
  static Insertable<BoatRow> custom({
    Expression<String>? localId,
    Expression<String>? serverId,
    Expression<String>? name,
    Expression<String>? registration,
    Expression<double>? lengthMetres,
    Expression<String>? engine,
    Expression<String>? boatType,
    Expression<String>? homePort,
    Expression<bool>? active,
    Expression<String>? syncStatus,
    Expression<int>? retryCount,
    Expression<String>? lastError,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (serverId != null) 'server_id': serverId,
      if (name != null) 'name': name,
      if (registration != null) 'registration': registration,
      if (lengthMetres != null) 'length_metres': lengthMetres,
      if (engine != null) 'engine': engine,
      if (boatType != null) 'boat_type': boatType,
      if (homePort != null) 'home_port': homePort,
      if (active != null) 'active': active,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BoatRowsCompanion copyWith({
    Value<String>? localId,
    Value<String?>? serverId,
    Value<String>? name,
    Value<String>? registration,
    Value<double>? lengthMetres,
    Value<String>? engine,
    Value<String>? boatType,
    Value<String>? homePort,
    Value<bool>? active,
    Value<String>? syncStatus,
    Value<int>? retryCount,
    Value<String?>? lastError,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return BoatRowsCompanion(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      name: name ?? this.name,
      registration: registration ?? this.registration,
      lengthMetres: lengthMetres ?? this.lengthMetres,
      engine: engine ?? this.engine,
      boatType: boatType ?? this.boatType,
      homePort: homePort ?? this.homePort,
      active: active ?? this.active,
      syncStatus: syncStatus ?? this.syncStatus,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (registration.present) {
      map['registration'] = Variable<String>(registration.value);
    }
    if (lengthMetres.present) {
      map['length_metres'] = Variable<double>(lengthMetres.value);
    }
    if (engine.present) {
      map['engine'] = Variable<String>(engine.value);
    }
    if (boatType.present) {
      map['boat_type'] = Variable<String>(boatType.value);
    }
    if (homePort.present) {
      map['home_port'] = Variable<String>(homePort.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('BoatRowsCompanion(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('name: $name, ')
          ..write('registration: $registration, ')
          ..write('lengthMetres: $lengthMetres, ')
          ..write('engine: $engine, ')
          ..write('boatType: $boatType, ')
          ..write('homePort: $homePort, ')
          ..write('active: $active, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FishingTripRowsTable extends FishingTripRows
    with TableInfo<$FishingTripRowsTable, FishingTripRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FishingTripRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _boatIdMeta = const VerificationMeta('boatId');
  @override
  late final GeneratedColumn<String> boatId = GeneratedColumn<String>(
    'boat_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _boatNameMeta = const VerificationMeta(
    'boatName',
  );
  @override
  late final GeneratedColumn<String> boatName = GeneratedColumn<String>(
    'boat_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fishingAreaMeta = const VerificationMeta(
    'fishingArea',
  );
  @override
  late final GeneratedColumn<String> fishingArea = GeneratedColumn<String>(
    'fishing_area',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _crewJsonMeta = const VerificationMeta(
    'crewJson',
  );
  @override
  late final GeneratedColumn<String> crewJson = GeneratedColumn<String>(
    'crew_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _catchKgMeta = const VerificationMeta(
    'catchKg',
  );
  @override
  late final GeneratedColumn<double> catchKg = GeneratedColumn<double>(
    'catch_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _batchCountMeta = const VerificationMeta(
    'batchCount',
  );
  @override
  late final GeneratedColumn<int> batchCount = GeneratedColumn<int>(
    'batch_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    localId,
    serverId,
    boatId,
    boatName,
    startedAt,
    fishingArea,
    latitude,
    longitude,
    crewJson,
    catchKg,
    batchCount,
    status,
    syncStatus,
    retryCount,
    lastError,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fishing_trip_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<FishingTripRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('boat_id')) {
      context.handle(
        _boatIdMeta,
        boatId.isAcceptableOrUnknown(data['boat_id']!, _boatIdMeta),
      );
    } else if (isInserting) {
      context.missing(_boatIdMeta);
    }
    if (data.containsKey('boat_name')) {
      context.handle(
        _boatNameMeta,
        boatName.isAcceptableOrUnknown(data['boat_name']!, _boatNameMeta),
      );
    } else if (isInserting) {
      context.missing(_boatNameMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('fishing_area')) {
      context.handle(
        _fishingAreaMeta,
        fishingArea.isAcceptableOrUnknown(
          data['fishing_area']!,
          _fishingAreaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fishingAreaMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('crew_json')) {
      context.handle(
        _crewJsonMeta,
        crewJson.isAcceptableOrUnknown(data['crew_json']!, _crewJsonMeta),
      );
    }
    if (data.containsKey('catch_kg')) {
      context.handle(
        _catchKgMeta,
        catchKg.isAcceptableOrUnknown(data['catch_kg']!, _catchKgMeta),
      );
    }
    if (data.containsKey('batch_count')) {
      context.handle(
        _batchCountMeta,
        batchCount.isAcceptableOrUnknown(data['batch_count']!, _batchCountMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
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
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  FishingTripRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FishingTripRow(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      boatId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}boat_id'],
      )!,
      boatName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}boat_name'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      fishingArea: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fishing_area'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      crewJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}crew_json'],
      )!,
      catchKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}catch_kg'],
      )!,
      batchCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}batch_count'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
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
  $FishingTripRowsTable createAlias(String alias) {
    return $FishingTripRowsTable(attachedDatabase, alias);
  }
}

class FishingTripRow extends DataClass implements Insertable<FishingTripRow> {
  final String localId;
  final String? serverId;
  final String boatId;
  final String boatName;
  final DateTime startedAt;
  final String fishingArea;
  final double? latitude;
  final double? longitude;
  final String crewJson;
  final double catchKg;
  final int batchCount;
  final String status;
  final String syncStatus;
  final int retryCount;
  final String? lastError;
  final DateTime createdAt;
  final DateTime updatedAt;
  const FishingTripRow({
    required this.localId,
    this.serverId,
    required this.boatId,
    required this.boatName,
    required this.startedAt,
    required this.fishingArea,
    this.latitude,
    this.longitude,
    required this.crewJson,
    required this.catchKg,
    required this.batchCount,
    required this.status,
    required this.syncStatus,
    required this.retryCount,
    this.lastError,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<String>(localId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['boat_id'] = Variable<String>(boatId);
    map['boat_name'] = Variable<String>(boatName);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['fishing_area'] = Variable<String>(fishingArea);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    map['crew_json'] = Variable<String>(crewJson);
    map['catch_kg'] = Variable<double>(catchKg);
    map['batch_count'] = Variable<int>(batchCount);
    map['status'] = Variable<String>(status);
    map['sync_status'] = Variable<String>(syncStatus);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FishingTripRowsCompanion toCompanion(bool nullToAbsent) {
    return FishingTripRowsCompanion(
      localId: Value(localId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      boatId: Value(boatId),
      boatName: Value(boatName),
      startedAt: Value(startedAt),
      fishingArea: Value(fishingArea),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      crewJson: Value(crewJson),
      catchKg: Value(catchKg),
      batchCount: Value(batchCount),
      status: Value(status),
      syncStatus: Value(syncStatus),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FishingTripRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FishingTripRow(
      localId: serializer.fromJson<String>(json['localId']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      boatId: serializer.fromJson<String>(json['boatId']),
      boatName: serializer.fromJson<String>(json['boatName']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      fishingArea: serializer.fromJson<String>(json['fishingArea']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      crewJson: serializer.fromJson<String>(json['crewJson']),
      catchKg: serializer.fromJson<double>(json['catchKg']),
      batchCount: serializer.fromJson<int>(json['batchCount']),
      status: serializer.fromJson<String>(json['status']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<String>(localId),
      'serverId': serializer.toJson<String?>(serverId),
      'boatId': serializer.toJson<String>(boatId),
      'boatName': serializer.toJson<String>(boatName),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'fishingArea': serializer.toJson<String>(fishingArea),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'crewJson': serializer.toJson<String>(crewJson),
      'catchKg': serializer.toJson<double>(catchKg),
      'batchCount': serializer.toJson<int>(batchCount),
      'status': serializer.toJson<String>(status),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  FishingTripRow copyWith({
    String? localId,
    Value<String?> serverId = const Value.absent(),
    String? boatId,
    String? boatName,
    DateTime? startedAt,
    String? fishingArea,
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    String? crewJson,
    double? catchKg,
    int? batchCount,
    String? status,
    String? syncStatus,
    int? retryCount,
    Value<String?> lastError = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => FishingTripRow(
    localId: localId ?? this.localId,
    serverId: serverId.present ? serverId.value : this.serverId,
    boatId: boatId ?? this.boatId,
    boatName: boatName ?? this.boatName,
    startedAt: startedAt ?? this.startedAt,
    fishingArea: fishingArea ?? this.fishingArea,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    crewJson: crewJson ?? this.crewJson,
    catchKg: catchKg ?? this.catchKg,
    batchCount: batchCount ?? this.batchCount,
    status: status ?? this.status,
    syncStatus: syncStatus ?? this.syncStatus,
    retryCount: retryCount ?? this.retryCount,
    lastError: lastError.present ? lastError.value : this.lastError,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FishingTripRow copyWithCompanion(FishingTripRowsCompanion data) {
    return FishingTripRow(
      localId: data.localId.present ? data.localId.value : this.localId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      boatId: data.boatId.present ? data.boatId.value : this.boatId,
      boatName: data.boatName.present ? data.boatName.value : this.boatName,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      fishingArea: data.fishingArea.present
          ? data.fishingArea.value
          : this.fishingArea,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      crewJson: data.crewJson.present ? data.crewJson.value : this.crewJson,
      catchKg: data.catchKg.present ? data.catchKg.value : this.catchKg,
      batchCount: data.batchCount.present
          ? data.batchCount.value
          : this.batchCount,
      status: data.status.present ? data.status.value : this.status,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FishingTripRow(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('boatId: $boatId, ')
          ..write('boatName: $boatName, ')
          ..write('startedAt: $startedAt, ')
          ..write('fishingArea: $fishingArea, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('crewJson: $crewJson, ')
          ..write('catchKg: $catchKg, ')
          ..write('batchCount: $batchCount, ')
          ..write('status: $status, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    serverId,
    boatId,
    boatName,
    startedAt,
    fishingArea,
    latitude,
    longitude,
    crewJson,
    catchKg,
    batchCount,
    status,
    syncStatus,
    retryCount,
    lastError,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FishingTripRow &&
          other.localId == this.localId &&
          other.serverId == this.serverId &&
          other.boatId == this.boatId &&
          other.boatName == this.boatName &&
          other.startedAt == this.startedAt &&
          other.fishingArea == this.fishingArea &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.crewJson == this.crewJson &&
          other.catchKg == this.catchKg &&
          other.batchCount == this.batchCount &&
          other.status == this.status &&
          other.syncStatus == this.syncStatus &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FishingTripRowsCompanion extends UpdateCompanion<FishingTripRow> {
  final Value<String> localId;
  final Value<String?> serverId;
  final Value<String> boatId;
  final Value<String> boatName;
  final Value<DateTime> startedAt;
  final Value<String> fishingArea;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String> crewJson;
  final Value<double> catchKg;
  final Value<int> batchCount;
  final Value<String> status;
  final Value<String> syncStatus;
  final Value<int> retryCount;
  final Value<String?> lastError;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const FishingTripRowsCompanion({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.boatId = const Value.absent(),
    this.boatName = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.fishingArea = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.crewJson = const Value.absent(),
    this.catchKg = const Value.absent(),
    this.batchCount = const Value.absent(),
    this.status = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FishingTripRowsCompanion.insert({
    required String localId,
    this.serverId = const Value.absent(),
    required String boatId,
    required String boatName,
    required DateTime startedAt,
    required String fishingArea,
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.crewJson = const Value.absent(),
    this.catchKg = const Value.absent(),
    this.batchCount = const Value.absent(),
    required String status,
    this.syncStatus = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : localId = Value(localId),
       boatId = Value(boatId),
       boatName = Value(boatName),
       startedAt = Value(startedAt),
       fishingArea = Value(fishingArea),
       status = Value(status),
       updatedAt = Value(updatedAt);
  static Insertable<FishingTripRow> custom({
    Expression<String>? localId,
    Expression<String>? serverId,
    Expression<String>? boatId,
    Expression<String>? boatName,
    Expression<DateTime>? startedAt,
    Expression<String>? fishingArea,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? crewJson,
    Expression<double>? catchKg,
    Expression<int>? batchCount,
    Expression<String>? status,
    Expression<String>? syncStatus,
    Expression<int>? retryCount,
    Expression<String>? lastError,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (serverId != null) 'server_id': serverId,
      if (boatId != null) 'boat_id': boatId,
      if (boatName != null) 'boat_name': boatName,
      if (startedAt != null) 'started_at': startedAt,
      if (fishingArea != null) 'fishing_area': fishingArea,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (crewJson != null) 'crew_json': crewJson,
      if (catchKg != null) 'catch_kg': catchKg,
      if (batchCount != null) 'batch_count': batchCount,
      if (status != null) 'status': status,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FishingTripRowsCompanion copyWith({
    Value<String>? localId,
    Value<String?>? serverId,
    Value<String>? boatId,
    Value<String>? boatName,
    Value<DateTime>? startedAt,
    Value<String>? fishingArea,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<String>? crewJson,
    Value<double>? catchKg,
    Value<int>? batchCount,
    Value<String>? status,
    Value<String>? syncStatus,
    Value<int>? retryCount,
    Value<String?>? lastError,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return FishingTripRowsCompanion(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      boatId: boatId ?? this.boatId,
      boatName: boatName ?? this.boatName,
      startedAt: startedAt ?? this.startedAt,
      fishingArea: fishingArea ?? this.fishingArea,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      crewJson: crewJson ?? this.crewJson,
      catchKg: catchKg ?? this.catchKg,
      batchCount: batchCount ?? this.batchCount,
      status: status ?? this.status,
      syncStatus: syncStatus ?? this.syncStatus,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (boatId.present) {
      map['boat_id'] = Variable<String>(boatId.value);
    }
    if (boatName.present) {
      map['boat_name'] = Variable<String>(boatName.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (fishingArea.present) {
      map['fishing_area'] = Variable<String>(fishingArea.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (crewJson.present) {
      map['crew_json'] = Variable<String>(crewJson.value);
    }
    if (catchKg.present) {
      map['catch_kg'] = Variable<double>(catchKg.value);
    }
    if (batchCount.present) {
      map['batch_count'] = Variable<int>(batchCount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('FishingTripRowsCompanion(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('boatId: $boatId, ')
          ..write('boatName: $boatName, ')
          ..write('startedAt: $startedAt, ')
          ..write('fishingArea: $fishingArea, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('crewJson: $crewJson, ')
          ..write('catchKg: $catchKg, ')
          ..write('batchCount: $batchCount, ')
          ..write('status: $status, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatchDraftRowsTable extends CatchDraftRows
    with TableInfo<$CatchDraftRowsTable, CatchDraftRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatchDraftRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speciesMeta = const VerificationMeta(
    'species',
  );
  @override
  late final GeneratedColumn<String> species = GeneratedColumn<String>(
    'species',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scientificNameMeta = const VerificationMeta(
    'scientificName',
  );
  @override
  late final GeneratedColumn<String> scientificName = GeneratedColumn<String>(
    'scientific_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caughtAtMeta = const VerificationMeta(
    'caughtAt',
  );
  @override
  late final GeneratedColumn<DateTime> caughtAt = GeneratedColumn<DateTime>(
    'caught_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gearMeta = const VerificationMeta('gear');
  @override
  late final GeneratedColumn<String> gear = GeneratedColumn<String>(
    'gear',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conditionMeta = const VerificationMeta(
    'condition',
  );
  @override
  late final GeneratedColumn<String> condition = GeneratedColumn<String>(
    'condition',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verifiedMeta = const VerificationMeta(
    'verified',
  );
  @override
  late final GeneratedColumn<bool> verified = GeneratedColumn<bool>(
    'verified',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("verified" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _linkedBatchIdMeta = const VerificationMeta(
    'linkedBatchId',
  );
  @override
  late final GeneratedColumn<String> linkedBatchId = GeneratedColumn<String>(
    'linked_batch_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
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
    localId,
    serverId,
    tripId,
    species,
    scientificName,
    weightKg,
    quantity,
    caughtAt,
    latitude,
    longitude,
    gear,
    condition,
    verified,
    linkedBatchId,
    syncStatus,
    retryCount,
    lastError,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catch_draft_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatchDraftRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('species')) {
      context.handle(
        _speciesMeta,
        species.isAcceptableOrUnknown(data['species']!, _speciesMeta),
      );
    } else if (isInserting) {
      context.missing(_speciesMeta);
    }
    if (data.containsKey('scientific_name')) {
      context.handle(
        _scientificNameMeta,
        scientificName.isAcceptableOrUnknown(
          data['scientific_name']!,
          _scientificNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scientificNameMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('caught_at')) {
      context.handle(
        _caughtAtMeta,
        caughtAt.isAcceptableOrUnknown(data['caught_at']!, _caughtAtMeta),
      );
    } else if (isInserting) {
      context.missing(_caughtAtMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('gear')) {
      context.handle(
        _gearMeta,
        gear.isAcceptableOrUnknown(data['gear']!, _gearMeta),
      );
    } else if (isInserting) {
      context.missing(_gearMeta);
    }
    if (data.containsKey('condition')) {
      context.handle(
        _conditionMeta,
        condition.isAcceptableOrUnknown(data['condition']!, _conditionMeta),
      );
    } else if (isInserting) {
      context.missing(_conditionMeta);
    }
    if (data.containsKey('verified')) {
      context.handle(
        _verifiedMeta,
        verified.isAcceptableOrUnknown(data['verified']!, _verifiedMeta),
      );
    }
    if (data.containsKey('linked_batch_id')) {
      context.handle(
        _linkedBatchIdMeta,
        linkedBatchId.isAcceptableOrUnknown(
          data['linked_batch_id']!,
          _linkedBatchIdMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
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
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  CatchDraftRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatchDraftRow(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      species: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}species'],
      )!,
      scientificName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scientific_name'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      caughtAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}caught_at'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      gear: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gear'],
      )!,
      condition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}condition'],
      )!,
      verified: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}verified'],
      )!,
      linkedBatchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linked_batch_id'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
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
  $CatchDraftRowsTable createAlias(String alias) {
    return $CatchDraftRowsTable(attachedDatabase, alias);
  }
}

class CatchDraftRow extends DataClass implements Insertable<CatchDraftRow> {
  final String localId;
  final String? serverId;
  final String tripId;
  final String species;
  final String scientificName;
  final double weightKg;
  final int quantity;
  final DateTime caughtAt;
  final double latitude;
  final double longitude;
  final String gear;
  final String condition;
  final bool verified;
  final String? linkedBatchId;
  final String syncStatus;
  final int retryCount;
  final String? lastError;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CatchDraftRow({
    required this.localId,
    this.serverId,
    required this.tripId,
    required this.species,
    required this.scientificName,
    required this.weightKg,
    required this.quantity,
    required this.caughtAt,
    required this.latitude,
    required this.longitude,
    required this.gear,
    required this.condition,
    required this.verified,
    this.linkedBatchId,
    required this.syncStatus,
    required this.retryCount,
    this.lastError,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<String>(localId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['trip_id'] = Variable<String>(tripId);
    map['species'] = Variable<String>(species);
    map['scientific_name'] = Variable<String>(scientificName);
    map['weight_kg'] = Variable<double>(weightKg);
    map['quantity'] = Variable<int>(quantity);
    map['caught_at'] = Variable<DateTime>(caughtAt);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['gear'] = Variable<String>(gear);
    map['condition'] = Variable<String>(condition);
    map['verified'] = Variable<bool>(verified);
    if (!nullToAbsent || linkedBatchId != null) {
      map['linked_batch_id'] = Variable<String>(linkedBatchId);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CatchDraftRowsCompanion toCompanion(bool nullToAbsent) {
    return CatchDraftRowsCompanion(
      localId: Value(localId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      tripId: Value(tripId),
      species: Value(species),
      scientificName: Value(scientificName),
      weightKg: Value(weightKg),
      quantity: Value(quantity),
      caughtAt: Value(caughtAt),
      latitude: Value(latitude),
      longitude: Value(longitude),
      gear: Value(gear),
      condition: Value(condition),
      verified: Value(verified),
      linkedBatchId: linkedBatchId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedBatchId),
      syncStatus: Value(syncStatus),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CatchDraftRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatchDraftRow(
      localId: serializer.fromJson<String>(json['localId']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      tripId: serializer.fromJson<String>(json['tripId']),
      species: serializer.fromJson<String>(json['species']),
      scientificName: serializer.fromJson<String>(json['scientificName']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      quantity: serializer.fromJson<int>(json['quantity']),
      caughtAt: serializer.fromJson<DateTime>(json['caughtAt']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      gear: serializer.fromJson<String>(json['gear']),
      condition: serializer.fromJson<String>(json['condition']),
      verified: serializer.fromJson<bool>(json['verified']),
      linkedBatchId: serializer.fromJson<String?>(json['linkedBatchId']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<String>(localId),
      'serverId': serializer.toJson<String?>(serverId),
      'tripId': serializer.toJson<String>(tripId),
      'species': serializer.toJson<String>(species),
      'scientificName': serializer.toJson<String>(scientificName),
      'weightKg': serializer.toJson<double>(weightKg),
      'quantity': serializer.toJson<int>(quantity),
      'caughtAt': serializer.toJson<DateTime>(caughtAt),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'gear': serializer.toJson<String>(gear),
      'condition': serializer.toJson<String>(condition),
      'verified': serializer.toJson<bool>(verified),
      'linkedBatchId': serializer.toJson<String?>(linkedBatchId),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CatchDraftRow copyWith({
    String? localId,
    Value<String?> serverId = const Value.absent(),
    String? tripId,
    String? species,
    String? scientificName,
    double? weightKg,
    int? quantity,
    DateTime? caughtAt,
    double? latitude,
    double? longitude,
    String? gear,
    String? condition,
    bool? verified,
    Value<String?> linkedBatchId = const Value.absent(),
    String? syncStatus,
    int? retryCount,
    Value<String?> lastError = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CatchDraftRow(
    localId: localId ?? this.localId,
    serverId: serverId.present ? serverId.value : this.serverId,
    tripId: tripId ?? this.tripId,
    species: species ?? this.species,
    scientificName: scientificName ?? this.scientificName,
    weightKg: weightKg ?? this.weightKg,
    quantity: quantity ?? this.quantity,
    caughtAt: caughtAt ?? this.caughtAt,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    gear: gear ?? this.gear,
    condition: condition ?? this.condition,
    verified: verified ?? this.verified,
    linkedBatchId: linkedBatchId.present
        ? linkedBatchId.value
        : this.linkedBatchId,
    syncStatus: syncStatus ?? this.syncStatus,
    retryCount: retryCount ?? this.retryCount,
    lastError: lastError.present ? lastError.value : this.lastError,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CatchDraftRow copyWithCompanion(CatchDraftRowsCompanion data) {
    return CatchDraftRow(
      localId: data.localId.present ? data.localId.value : this.localId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      species: data.species.present ? data.species.value : this.species,
      scientificName: data.scientificName.present
          ? data.scientificName.value
          : this.scientificName,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      caughtAt: data.caughtAt.present ? data.caughtAt.value : this.caughtAt,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      gear: data.gear.present ? data.gear.value : this.gear,
      condition: data.condition.present ? data.condition.value : this.condition,
      verified: data.verified.present ? data.verified.value : this.verified,
      linkedBatchId: data.linkedBatchId.present
          ? data.linkedBatchId.value
          : this.linkedBatchId,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatchDraftRow(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('tripId: $tripId, ')
          ..write('species: $species, ')
          ..write('scientificName: $scientificName, ')
          ..write('weightKg: $weightKg, ')
          ..write('quantity: $quantity, ')
          ..write('caughtAt: $caughtAt, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('gear: $gear, ')
          ..write('condition: $condition, ')
          ..write('verified: $verified, ')
          ..write('linkedBatchId: $linkedBatchId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    serverId,
    tripId,
    species,
    scientificName,
    weightKg,
    quantity,
    caughtAt,
    latitude,
    longitude,
    gear,
    condition,
    verified,
    linkedBatchId,
    syncStatus,
    retryCount,
    lastError,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatchDraftRow &&
          other.localId == this.localId &&
          other.serverId == this.serverId &&
          other.tripId == this.tripId &&
          other.species == this.species &&
          other.scientificName == this.scientificName &&
          other.weightKg == this.weightKg &&
          other.quantity == this.quantity &&
          other.caughtAt == this.caughtAt &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.gear == this.gear &&
          other.condition == this.condition &&
          other.verified == this.verified &&
          other.linkedBatchId == this.linkedBatchId &&
          other.syncStatus == this.syncStatus &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CatchDraftRowsCompanion extends UpdateCompanion<CatchDraftRow> {
  final Value<String> localId;
  final Value<String?> serverId;
  final Value<String> tripId;
  final Value<String> species;
  final Value<String> scientificName;
  final Value<double> weightKg;
  final Value<int> quantity;
  final Value<DateTime> caughtAt;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<String> gear;
  final Value<String> condition;
  final Value<bool> verified;
  final Value<String?> linkedBatchId;
  final Value<String> syncStatus;
  final Value<int> retryCount;
  final Value<String?> lastError;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CatchDraftRowsCompanion({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.tripId = const Value.absent(),
    this.species = const Value.absent(),
    this.scientificName = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.quantity = const Value.absent(),
    this.caughtAt = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.gear = const Value.absent(),
    this.condition = const Value.absent(),
    this.verified = const Value.absent(),
    this.linkedBatchId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatchDraftRowsCompanion.insert({
    required String localId,
    this.serverId = const Value.absent(),
    required String tripId,
    required String species,
    required String scientificName,
    required double weightKg,
    required int quantity,
    required DateTime caughtAt,
    required double latitude,
    required double longitude,
    required String gear,
    required String condition,
    this.verified = const Value.absent(),
    this.linkedBatchId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : localId = Value(localId),
       tripId = Value(tripId),
       species = Value(species),
       scientificName = Value(scientificName),
       weightKg = Value(weightKg),
       quantity = Value(quantity),
       caughtAt = Value(caughtAt),
       latitude = Value(latitude),
       longitude = Value(longitude),
       gear = Value(gear),
       condition = Value(condition),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CatchDraftRow> custom({
    Expression<String>? localId,
    Expression<String>? serverId,
    Expression<String>? tripId,
    Expression<String>? species,
    Expression<String>? scientificName,
    Expression<double>? weightKg,
    Expression<int>? quantity,
    Expression<DateTime>? caughtAt,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? gear,
    Expression<String>? condition,
    Expression<bool>? verified,
    Expression<String>? linkedBatchId,
    Expression<String>? syncStatus,
    Expression<int>? retryCount,
    Expression<String>? lastError,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (serverId != null) 'server_id': serverId,
      if (tripId != null) 'trip_id': tripId,
      if (species != null) 'species': species,
      if (scientificName != null) 'scientific_name': scientificName,
      if (weightKg != null) 'weight_kg': weightKg,
      if (quantity != null) 'quantity': quantity,
      if (caughtAt != null) 'caught_at': caughtAt,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (gear != null) 'gear': gear,
      if (condition != null) 'condition': condition,
      if (verified != null) 'verified': verified,
      if (linkedBatchId != null) 'linked_batch_id': linkedBatchId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatchDraftRowsCompanion copyWith({
    Value<String>? localId,
    Value<String?>? serverId,
    Value<String>? tripId,
    Value<String>? species,
    Value<String>? scientificName,
    Value<double>? weightKg,
    Value<int>? quantity,
    Value<DateTime>? caughtAt,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<String>? gear,
    Value<String>? condition,
    Value<bool>? verified,
    Value<String?>? linkedBatchId,
    Value<String>? syncStatus,
    Value<int>? retryCount,
    Value<String?>? lastError,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CatchDraftRowsCompanion(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      tripId: tripId ?? this.tripId,
      species: species ?? this.species,
      scientificName: scientificName ?? this.scientificName,
      weightKg: weightKg ?? this.weightKg,
      quantity: quantity ?? this.quantity,
      caughtAt: caughtAt ?? this.caughtAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      gear: gear ?? this.gear,
      condition: condition ?? this.condition,
      verified: verified ?? this.verified,
      linkedBatchId: linkedBatchId ?? this.linkedBatchId,
      syncStatus: syncStatus ?? this.syncStatus,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (species.present) {
      map['species'] = Variable<String>(species.value);
    }
    if (scientificName.present) {
      map['scientific_name'] = Variable<String>(scientificName.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (caughtAt.present) {
      map['caught_at'] = Variable<DateTime>(caughtAt.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (gear.present) {
      map['gear'] = Variable<String>(gear.value);
    }
    if (condition.present) {
      map['condition'] = Variable<String>(condition.value);
    }
    if (verified.present) {
      map['verified'] = Variable<bool>(verified.value);
    }
    if (linkedBatchId.present) {
      map['linked_batch_id'] = Variable<String>(linkedBatchId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('CatchDraftRowsCompanion(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('tripId: $tripId, ')
          ..write('species: $species, ')
          ..write('scientificName: $scientificName, ')
          ..write('weightKg: $weightKg, ')
          ..write('quantity: $quantity, ')
          ..write('caughtAt: $caughtAt, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('gear: $gear, ')
          ..write('condition: $condition, ')
          ..write('verified: $verified, ')
          ..write('linkedBatchId: $linkedBatchId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatchPhotoRowsTable extends CatchPhotoRows
    with TableInfo<$CatchPhotoRowsTable, CatchPhotoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatchPhotoRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _catchLocalIdMeta = const VerificationMeta(
    'catchLocalId',
  );
  @override
  late final GeneratedColumn<String> catchLocalId = GeneratedColumn<String>(
    'catch_local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteUrlMeta = const VerificationMeta(
    'remoteUrl',
  );
  @override
  late final GeneratedColumn<String> remoteUrl = GeneratedColumn<String>(
    'remote_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
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
    catchLocalId,
    localPath,
    remoteUrl,
    syncStatus,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catch_photo_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatchPhotoRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('catch_local_id')) {
      context.handle(
        _catchLocalIdMeta,
        catchLocalId.isAcceptableOrUnknown(
          data['catch_local_id']!,
          _catchLocalIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_catchLocalIdMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('remote_url')) {
      context.handle(
        _remoteUrlMeta,
        remoteUrl.isAcceptableOrUnknown(data['remote_url']!, _remoteUrlMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
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
  CatchPhotoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatchPhotoRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      catchLocalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catch_local_id'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      remoteUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_url'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CatchPhotoRowsTable createAlias(String alias) {
    return $CatchPhotoRowsTable(attachedDatabase, alias);
  }
}

class CatchPhotoRow extends DataClass implements Insertable<CatchPhotoRow> {
  final String id;
  final String catchLocalId;
  final String localPath;
  final String? remoteUrl;
  final String syncStatus;
  final DateTime createdAt;
  const CatchPhotoRow({
    required this.id,
    required this.catchLocalId,
    required this.localPath,
    this.remoteUrl,
    required this.syncStatus,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['catch_local_id'] = Variable<String>(catchLocalId);
    map['local_path'] = Variable<String>(localPath);
    if (!nullToAbsent || remoteUrl != null) {
      map['remote_url'] = Variable<String>(remoteUrl);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CatchPhotoRowsCompanion toCompanion(bool nullToAbsent) {
    return CatchPhotoRowsCompanion(
      id: Value(id),
      catchLocalId: Value(catchLocalId),
      localPath: Value(localPath),
      remoteUrl: remoteUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteUrl),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
    );
  }

  factory CatchPhotoRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatchPhotoRow(
      id: serializer.fromJson<String>(json['id']),
      catchLocalId: serializer.fromJson<String>(json['catchLocalId']),
      localPath: serializer.fromJson<String>(json['localPath']),
      remoteUrl: serializer.fromJson<String?>(json['remoteUrl']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'catchLocalId': serializer.toJson<String>(catchLocalId),
      'localPath': serializer.toJson<String>(localPath),
      'remoteUrl': serializer.toJson<String?>(remoteUrl),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CatchPhotoRow copyWith({
    String? id,
    String? catchLocalId,
    String? localPath,
    Value<String?> remoteUrl = const Value.absent(),
    String? syncStatus,
    DateTime? createdAt,
  }) => CatchPhotoRow(
    id: id ?? this.id,
    catchLocalId: catchLocalId ?? this.catchLocalId,
    localPath: localPath ?? this.localPath,
    remoteUrl: remoteUrl.present ? remoteUrl.value : this.remoteUrl,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
  );
  CatchPhotoRow copyWithCompanion(CatchPhotoRowsCompanion data) {
    return CatchPhotoRow(
      id: data.id.present ? data.id.value : this.id,
      catchLocalId: data.catchLocalId.present
          ? data.catchLocalId.value
          : this.catchLocalId,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      remoteUrl: data.remoteUrl.present ? data.remoteUrl.value : this.remoteUrl,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatchPhotoRow(')
          ..write('id: $id, ')
          ..write('catchLocalId: $catchLocalId, ')
          ..write('localPath: $localPath, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    catchLocalId,
    localPath,
    remoteUrl,
    syncStatus,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatchPhotoRow &&
          other.id == this.id &&
          other.catchLocalId == this.catchLocalId &&
          other.localPath == this.localPath &&
          other.remoteUrl == this.remoteUrl &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt);
}

class CatchPhotoRowsCompanion extends UpdateCompanion<CatchPhotoRow> {
  final Value<String> id;
  final Value<String> catchLocalId;
  final Value<String> localPath;
  final Value<String?> remoteUrl;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CatchPhotoRowsCompanion({
    this.id = const Value.absent(),
    this.catchLocalId = const Value.absent(),
    this.localPath = const Value.absent(),
    this.remoteUrl = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatchPhotoRowsCompanion.insert({
    required String id,
    required String catchLocalId,
    required String localPath,
    this.remoteUrl = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       catchLocalId = Value(catchLocalId),
       localPath = Value(localPath),
       createdAt = Value(createdAt);
  static Insertable<CatchPhotoRow> custom({
    Expression<String>? id,
    Expression<String>? catchLocalId,
    Expression<String>? localPath,
    Expression<String>? remoteUrl,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (catchLocalId != null) 'catch_local_id': catchLocalId,
      if (localPath != null) 'local_path': localPath,
      if (remoteUrl != null) 'remote_url': remoteUrl,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatchPhotoRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? catchLocalId,
    Value<String>? localPath,
    Value<String?>? remoteUrl,
    Value<String>? syncStatus,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CatchPhotoRowsCompanion(
      id: id ?? this.id,
      catchLocalId: catchLocalId ?? this.catchLocalId,
      localPath: localPath ?? this.localPath,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (catchLocalId.present) {
      map['catch_local_id'] = Variable<String>(catchLocalId.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (remoteUrl.present) {
      map['remote_url'] = Variable<String>(remoteUrl.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
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
    return (StringBuffer('CatchPhotoRowsCompanion(')
          ..write('id: $id, ')
          ..write('catchLocalId: $catchLocalId, ')
          ..write('localPath: $localPath, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BatchDraftRowsTable extends BatchDraftRows
    with TableInfo<$BatchDraftRowsTable, BatchDraftRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BatchDraftRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speciesMeta = const VerificationMeta(
    'species',
  );
  @override
  late final GeneratedColumn<String> species = GeneratedColumn<String>(
    'species',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fishCountMeta = const VerificationMeta(
    'fishCount',
  );
  @override
  late final GeneratedColumn<int> fishCount = GeneratedColumn<int>(
    'fish_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<String> grade = GeneratedColumn<String>(
    'grade',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _catchIdsJsonMeta = const VerificationMeta(
    'catchIdsJson',
  );
  @override
  late final GeneratedColumn<String> catchIdsJson = GeneratedColumn<String>(
    'catch_ids_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
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
    localId,
    serverId,
    tripId,
    species,
    weightKg,
    fishCount,
    grade,
    status,
    catchIdsJson,
    payload,
    syncStatus,
    retryCount,
    lastError,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'batch_draft_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<BatchDraftRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('species')) {
      context.handle(
        _speciesMeta,
        species.isAcceptableOrUnknown(data['species']!, _speciesMeta),
      );
    } else if (isInserting) {
      context.missing(_speciesMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('fish_count')) {
      context.handle(
        _fishCountMeta,
        fishCount.isAcceptableOrUnknown(data['fish_count']!, _fishCountMeta),
      );
    } else if (isInserting) {
      context.missing(_fishCountMeta);
    }
    if (data.containsKey('grade')) {
      context.handle(
        _gradeMeta,
        grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta),
      );
    } else if (isInserting) {
      context.missing(_gradeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('catch_ids_json')) {
      context.handle(
        _catchIdsJsonMeta,
        catchIdsJson.isAcceptableOrUnknown(
          data['catch_ids_json']!,
          _catchIdsJsonMeta,
        ),
      );
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
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
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  BatchDraftRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BatchDraftRow(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      species: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}species'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
      fishCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fish_count'],
      )!,
      grade: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grade'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      catchIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catch_ids_json'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
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
  $BatchDraftRowsTable createAlias(String alias) {
    return $BatchDraftRowsTable(attachedDatabase, alias);
  }
}

class BatchDraftRow extends DataClass implements Insertable<BatchDraftRow> {
  final String localId;
  final String? serverId;
  final String tripId;
  final String species;
  final double weightKg;
  final int fishCount;
  final String grade;
  final String status;
  final String catchIdsJson;
  final String payload;
  final String syncStatus;
  final int retryCount;
  final String? lastError;
  final DateTime createdAt;
  final DateTime updatedAt;
  const BatchDraftRow({
    required this.localId,
    this.serverId,
    required this.tripId,
    required this.species,
    required this.weightKg,
    required this.fishCount,
    required this.grade,
    required this.status,
    required this.catchIdsJson,
    required this.payload,
    required this.syncStatus,
    required this.retryCount,
    this.lastError,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<String>(localId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['trip_id'] = Variable<String>(tripId);
    map['species'] = Variable<String>(species);
    map['weight_kg'] = Variable<double>(weightKg);
    map['fish_count'] = Variable<int>(fishCount);
    map['grade'] = Variable<String>(grade);
    map['status'] = Variable<String>(status);
    map['catch_ids_json'] = Variable<String>(catchIdsJson);
    map['payload'] = Variable<String>(payload);
    map['sync_status'] = Variable<String>(syncStatus);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BatchDraftRowsCompanion toCompanion(bool nullToAbsent) {
    return BatchDraftRowsCompanion(
      localId: Value(localId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      tripId: Value(tripId),
      species: Value(species),
      weightKg: Value(weightKg),
      fishCount: Value(fishCount),
      grade: Value(grade),
      status: Value(status),
      catchIdsJson: Value(catchIdsJson),
      payload: Value(payload),
      syncStatus: Value(syncStatus),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory BatchDraftRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BatchDraftRow(
      localId: serializer.fromJson<String>(json['localId']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      tripId: serializer.fromJson<String>(json['tripId']),
      species: serializer.fromJson<String>(json['species']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      fishCount: serializer.fromJson<int>(json['fishCount']),
      grade: serializer.fromJson<String>(json['grade']),
      status: serializer.fromJson<String>(json['status']),
      catchIdsJson: serializer.fromJson<String>(json['catchIdsJson']),
      payload: serializer.fromJson<String>(json['payload']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<String>(localId),
      'serverId': serializer.toJson<String?>(serverId),
      'tripId': serializer.toJson<String>(tripId),
      'species': serializer.toJson<String>(species),
      'weightKg': serializer.toJson<double>(weightKg),
      'fishCount': serializer.toJson<int>(fishCount),
      'grade': serializer.toJson<String>(grade),
      'status': serializer.toJson<String>(status),
      'catchIdsJson': serializer.toJson<String>(catchIdsJson),
      'payload': serializer.toJson<String>(payload),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  BatchDraftRow copyWith({
    String? localId,
    Value<String?> serverId = const Value.absent(),
    String? tripId,
    String? species,
    double? weightKg,
    int? fishCount,
    String? grade,
    String? status,
    String? catchIdsJson,
    String? payload,
    String? syncStatus,
    int? retryCount,
    Value<String?> lastError = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => BatchDraftRow(
    localId: localId ?? this.localId,
    serverId: serverId.present ? serverId.value : this.serverId,
    tripId: tripId ?? this.tripId,
    species: species ?? this.species,
    weightKg: weightKg ?? this.weightKg,
    fishCount: fishCount ?? this.fishCount,
    grade: grade ?? this.grade,
    status: status ?? this.status,
    catchIdsJson: catchIdsJson ?? this.catchIdsJson,
    payload: payload ?? this.payload,
    syncStatus: syncStatus ?? this.syncStatus,
    retryCount: retryCount ?? this.retryCount,
    lastError: lastError.present ? lastError.value : this.lastError,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  BatchDraftRow copyWithCompanion(BatchDraftRowsCompanion data) {
    return BatchDraftRow(
      localId: data.localId.present ? data.localId.value : this.localId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      species: data.species.present ? data.species.value : this.species,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      fishCount: data.fishCount.present ? data.fishCount.value : this.fishCount,
      grade: data.grade.present ? data.grade.value : this.grade,
      status: data.status.present ? data.status.value : this.status,
      catchIdsJson: data.catchIdsJson.present
          ? data.catchIdsJson.value
          : this.catchIdsJson,
      payload: data.payload.present ? data.payload.value : this.payload,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BatchDraftRow(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('tripId: $tripId, ')
          ..write('species: $species, ')
          ..write('weightKg: $weightKg, ')
          ..write('fishCount: $fishCount, ')
          ..write('grade: $grade, ')
          ..write('status: $status, ')
          ..write('catchIdsJson: $catchIdsJson, ')
          ..write('payload: $payload, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    serverId,
    tripId,
    species,
    weightKg,
    fishCount,
    grade,
    status,
    catchIdsJson,
    payload,
    syncStatus,
    retryCount,
    lastError,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BatchDraftRow &&
          other.localId == this.localId &&
          other.serverId == this.serverId &&
          other.tripId == this.tripId &&
          other.species == this.species &&
          other.weightKg == this.weightKg &&
          other.fishCount == this.fishCount &&
          other.grade == this.grade &&
          other.status == this.status &&
          other.catchIdsJson == this.catchIdsJson &&
          other.payload == this.payload &&
          other.syncStatus == this.syncStatus &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BatchDraftRowsCompanion extends UpdateCompanion<BatchDraftRow> {
  final Value<String> localId;
  final Value<String?> serverId;
  final Value<String> tripId;
  final Value<String> species;
  final Value<double> weightKg;
  final Value<int> fishCount;
  final Value<String> grade;
  final Value<String> status;
  final Value<String> catchIdsJson;
  final Value<String> payload;
  final Value<String> syncStatus;
  final Value<int> retryCount;
  final Value<String?> lastError;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const BatchDraftRowsCompanion({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.tripId = const Value.absent(),
    this.species = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.fishCount = const Value.absent(),
    this.grade = const Value.absent(),
    this.status = const Value.absent(),
    this.catchIdsJson = const Value.absent(),
    this.payload = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BatchDraftRowsCompanion.insert({
    required String localId,
    this.serverId = const Value.absent(),
    required String tripId,
    required String species,
    required double weightKg,
    required int fishCount,
    required String grade,
    required String status,
    this.catchIdsJson = const Value.absent(),
    this.payload = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : localId = Value(localId),
       tripId = Value(tripId),
       species = Value(species),
       weightKg = Value(weightKg),
       fishCount = Value(fishCount),
       grade = Value(grade),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<BatchDraftRow> custom({
    Expression<String>? localId,
    Expression<String>? serverId,
    Expression<String>? tripId,
    Expression<String>? species,
    Expression<double>? weightKg,
    Expression<int>? fishCount,
    Expression<String>? grade,
    Expression<String>? status,
    Expression<String>? catchIdsJson,
    Expression<String>? payload,
    Expression<String>? syncStatus,
    Expression<int>? retryCount,
    Expression<String>? lastError,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (serverId != null) 'server_id': serverId,
      if (tripId != null) 'trip_id': tripId,
      if (species != null) 'species': species,
      if (weightKg != null) 'weight_kg': weightKg,
      if (fishCount != null) 'fish_count': fishCount,
      if (grade != null) 'grade': grade,
      if (status != null) 'status': status,
      if (catchIdsJson != null) 'catch_ids_json': catchIdsJson,
      if (payload != null) 'payload': payload,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BatchDraftRowsCompanion copyWith({
    Value<String>? localId,
    Value<String?>? serverId,
    Value<String>? tripId,
    Value<String>? species,
    Value<double>? weightKg,
    Value<int>? fishCount,
    Value<String>? grade,
    Value<String>? status,
    Value<String>? catchIdsJson,
    Value<String>? payload,
    Value<String>? syncStatus,
    Value<int>? retryCount,
    Value<String?>? lastError,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return BatchDraftRowsCompanion(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      tripId: tripId ?? this.tripId,
      species: species ?? this.species,
      weightKg: weightKg ?? this.weightKg,
      fishCount: fishCount ?? this.fishCount,
      grade: grade ?? this.grade,
      status: status ?? this.status,
      catchIdsJson: catchIdsJson ?? this.catchIdsJson,
      payload: payload ?? this.payload,
      syncStatus: syncStatus ?? this.syncStatus,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (species.present) {
      map['species'] = Variable<String>(species.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (fishCount.present) {
      map['fish_count'] = Variable<int>(fishCount.value);
    }
    if (grade.present) {
      map['grade'] = Variable<String>(grade.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (catchIdsJson.present) {
      map['catch_ids_json'] = Variable<String>(catchIdsJson.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('BatchDraftRowsCompanion(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('tripId: $tripId, ')
          ..write('species: $species, ')
          ..write('weightKg: $weightKg, ')
          ..write('fishCount: $fishCount, ')
          ..write('grade: $grade, ')
          ..write('status: $status, ')
          ..write('catchIdsJson: $catchIdsJson, ')
          ..write('payload: $payload, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReferenceDataRowsTable extends ReferenceDataRows
    with TableInfo<$ReferenceDataRowsTable, ReferenceDataRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReferenceDataRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    key,
    category,
    payload,
    fetchedAt,
    expiresAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reference_data_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReferenceDataRow> instance, {
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
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  ReferenceDataRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReferenceDataRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      ),
    );
  }

  @override
  $ReferenceDataRowsTable createAlias(String alias) {
    return $ReferenceDataRowsTable(attachedDatabase, alias);
  }
}

class ReferenceDataRow extends DataClass
    implements Insertable<ReferenceDataRow> {
  final String key;
  final String category;
  final String payload;
  final DateTime fetchedAt;
  final DateTime? expiresAt;
  const ReferenceDataRow({
    required this.key,
    required this.category,
    required this.payload,
    required this.fetchedAt,
    this.expiresAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['category'] = Variable<String>(category);
    map['payload'] = Variable<String>(payload);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<DateTime>(expiresAt);
    }
    return map;
  }

  ReferenceDataRowsCompanion toCompanion(bool nullToAbsent) {
    return ReferenceDataRowsCompanion(
      key: Value(key),
      category: Value(category),
      payload: Value(payload),
      fetchedAt: Value(fetchedAt),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
    );
  }

  factory ReferenceDataRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReferenceDataRow(
      key: serializer.fromJson<String>(json['key']),
      category: serializer.fromJson<String>(json['category']),
      payload: serializer.fromJson<String>(json['payload']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
      expiresAt: serializer.fromJson<DateTime?>(json['expiresAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'category': serializer.toJson<String>(category),
      'payload': serializer.toJson<String>(payload),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
      'expiresAt': serializer.toJson<DateTime?>(expiresAt),
    };
  }

  ReferenceDataRow copyWith({
    String? key,
    String? category,
    String? payload,
    DateTime? fetchedAt,
    Value<DateTime?> expiresAt = const Value.absent(),
  }) => ReferenceDataRow(
    key: key ?? this.key,
    category: category ?? this.category,
    payload: payload ?? this.payload,
    fetchedAt: fetchedAt ?? this.fetchedAt,
    expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
  );
  ReferenceDataRow copyWithCompanion(ReferenceDataRowsCompanion data) {
    return ReferenceDataRow(
      key: data.key.present ? data.key.value : this.key,
      category: data.category.present ? data.category.value : this.category,
      payload: data.payload.present ? data.payload.value : this.payload,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReferenceDataRow(')
          ..write('key: $key, ')
          ..write('category: $category, ')
          ..write('payload: $payload, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, category, payload, fetchedAt, expiresAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReferenceDataRow &&
          other.key == this.key &&
          other.category == this.category &&
          other.payload == this.payload &&
          other.fetchedAt == this.fetchedAt &&
          other.expiresAt == this.expiresAt);
}

class ReferenceDataRowsCompanion extends UpdateCompanion<ReferenceDataRow> {
  final Value<String> key;
  final Value<String> category;
  final Value<String> payload;
  final Value<DateTime> fetchedAt;
  final Value<DateTime?> expiresAt;
  final Value<int> rowid;
  const ReferenceDataRowsCompanion({
    this.key = const Value.absent(),
    this.category = const Value.absent(),
    this.payload = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReferenceDataRowsCompanion.insert({
    required String key,
    required String category,
    required String payload,
    required DateTime fetchedAt,
    this.expiresAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       category = Value(category),
       payload = Value(payload),
       fetchedAt = Value(fetchedAt);
  static Insertable<ReferenceDataRow> custom({
    Expression<String>? key,
    Expression<String>? category,
    Expression<String>? payload,
    Expression<DateTime>? fetchedAt,
    Expression<DateTime>? expiresAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (category != null) 'category': category,
      if (payload != null) 'payload': payload,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReferenceDataRowsCompanion copyWith({
    Value<String>? key,
    Value<String>? category,
    Value<String>? payload,
    Value<DateTime>? fetchedAt,
    Value<DateTime?>? expiresAt,
    Value<int>? rowid,
  }) {
    return ReferenceDataRowsCompanion(
      key: key ?? this.key,
      category: category ?? this.category,
      payload: payload ?? this.payload,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReferenceDataRowsCompanion(')
          ..write('key: $key, ')
          ..write('category: $category, ')
          ..write('payload: $payload, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$FishTraceDatabase extends GeneratedDatabase {
  _$FishTraceDatabase(QueryExecutor e) : super(e);
  $FishTraceDatabaseManager get managers => $FishTraceDatabaseManager(this);
  late final $SyncOperationsTable syncOperations = $SyncOperationsTable(this);
  late final $LocalRecordsTable localRecords = $LocalRecordsTable(this);
  late final $AuthMetadataRowsTable authMetadataRows = $AuthMetadataRowsTable(
    this,
  );
  late final $BoatRowsTable boatRows = $BoatRowsTable(this);
  late final $FishingTripRowsTable fishingTripRows = $FishingTripRowsTable(
    this,
  );
  late final $CatchDraftRowsTable catchDraftRows = $CatchDraftRowsTable(this);
  late final $CatchPhotoRowsTable catchPhotoRows = $CatchPhotoRowsTable(this);
  late final $BatchDraftRowsTable batchDraftRows = $BatchDraftRowsTable(this);
  late final $ReferenceDataRowsTable referenceDataRows =
      $ReferenceDataRowsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    syncOperations,
    localRecords,
    authMetadataRows,
    boatRows,
    fishingTripRows,
    catchDraftRows,
    catchPhotoRows,
    batchDraftRows,
    referenceDataRows,
  ];
}

typedef $$SyncOperationsTableCreateCompanionBuilder =
    SyncOperationsCompanion Function({
      required String id,
      Value<String?> serverId,
      required String label,
      Value<String> recordType,
      Value<String?> clientRecordId,
      Value<String> endpoint,
      Value<String> requestMethod,
      Value<String> localFileReferences,
      Value<String> payload,
      Value<String> status,
      Value<int> retryCount,
      Value<String?> lastError,
      required String idempotencyKey,
      Value<DateTime?> nextAttemptAt,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SyncOperationsTableUpdateCompanionBuilder =
    SyncOperationsCompanion Function({
      Value<String> id,
      Value<String?> serverId,
      Value<String> label,
      Value<String> recordType,
      Value<String?> clientRecordId,
      Value<String> endpoint,
      Value<String> requestMethod,
      Value<String> localFileReferences,
      Value<String> payload,
      Value<String> status,
      Value<int> retryCount,
      Value<String?> lastError,
      Value<String> idempotencyKey,
      Value<DateTime?> nextAttemptAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SyncOperationsTableFilterComposer
    extends Composer<_$FishTraceDatabase, $SyncOperationsTable> {
  $$SyncOperationsTableFilterComposer({
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

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientRecordId => $composableBuilder(
    column: $table.clientRecordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endpoint => $composableBuilder(
    column: $table.endpoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestMethod => $composableBuilder(
    column: $table.requestMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localFileReferences => $composableBuilder(
    column: $table.localFileReferences,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
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
}

class $$SyncOperationsTableOrderingComposer
    extends Composer<_$FishTraceDatabase, $SyncOperationsTable> {
  $$SyncOperationsTableOrderingComposer({
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

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientRecordId => $composableBuilder(
    column: $table.clientRecordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endpoint => $composableBuilder(
    column: $table.endpoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestMethod => $composableBuilder(
    column: $table.requestMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localFileReferences => $composableBuilder(
    column: $table.localFileReferences,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
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

class $$SyncOperationsTableAnnotationComposer
    extends Composer<_$FishTraceDatabase, $SyncOperationsTable> {
  $$SyncOperationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get clientRecordId => $composableBuilder(
    column: $table.clientRecordId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get endpoint =>
      $composableBuilder(column: $table.endpoint, builder: (column) => column);

  GeneratedColumn<String> get requestMethod => $composableBuilder(
    column: $table.requestMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localFileReferences => $composableBuilder(
    column: $table.localFileReferences,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SyncOperationsTableTableManager
    extends
        RootTableManager<
          _$FishTraceDatabase,
          $SyncOperationsTable,
          SyncOperation,
          $$SyncOperationsTableFilterComposer,
          $$SyncOperationsTableOrderingComposer,
          $$SyncOperationsTableAnnotationComposer,
          $$SyncOperationsTableCreateCompanionBuilder,
          $$SyncOperationsTableUpdateCompanionBuilder,
          (
            SyncOperation,
            BaseReferences<
              _$FishTraceDatabase,
              $SyncOperationsTable,
              SyncOperation
            >,
          ),
          SyncOperation,
          PrefetchHooks Function()
        > {
  $$SyncOperationsTableTableManager(
    _$FishTraceDatabase db,
    $SyncOperationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOperationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOperationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOperationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> recordType = const Value.absent(),
                Value<String?> clientRecordId = const Value.absent(),
                Value<String> endpoint = const Value.absent(),
                Value<String> requestMethod = const Value.absent(),
                Value<String> localFileReferences = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOperationsCompanion(
                id: id,
                serverId: serverId,
                label: label,
                recordType: recordType,
                clientRecordId: clientRecordId,
                endpoint: endpoint,
                requestMethod: requestMethod,
                localFileReferences: localFileReferences,
                payload: payload,
                status: status,
                retryCount: retryCount,
                lastError: lastError,
                idempotencyKey: idempotencyKey,
                nextAttemptAt: nextAttemptAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> serverId = const Value.absent(),
                required String label,
                Value<String> recordType = const Value.absent(),
                Value<String?> clientRecordId = const Value.absent(),
                Value<String> endpoint = const Value.absent(),
                Value<String> requestMethod = const Value.absent(),
                Value<String> localFileReferences = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                required String idempotencyKey,
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncOperationsCompanion.insert(
                id: id,
                serverId: serverId,
                label: label,
                recordType: recordType,
                clientRecordId: clientRecordId,
                endpoint: endpoint,
                requestMethod: requestMethod,
                localFileReferences: localFileReferences,
                payload: payload,
                status: status,
                retryCount: retryCount,
                lastError: lastError,
                idempotencyKey: idempotencyKey,
                nextAttemptAt: nextAttemptAt,
                createdAt: createdAt,
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

typedef $$SyncOperationsTableProcessedTableManager =
    ProcessedTableManager<
      _$FishTraceDatabase,
      $SyncOperationsTable,
      SyncOperation,
      $$SyncOperationsTableFilterComposer,
      $$SyncOperationsTableOrderingComposer,
      $$SyncOperationsTableAnnotationComposer,
      $$SyncOperationsTableCreateCompanionBuilder,
      $$SyncOperationsTableUpdateCompanionBuilder,
      (
        SyncOperation,
        BaseReferences<
          _$FishTraceDatabase,
          $SyncOperationsTable,
          SyncOperation
        >,
      ),
      SyncOperation,
      PrefetchHooks Function()
    >;
typedef $$LocalRecordsTableCreateCompanionBuilder =
    LocalRecordsCompanion Function({
      required String localId,
      Value<String?> serverId,
      required String recordType,
      Value<String> payload,
      Value<String> syncStatus,
      Value<int> version,
      Value<bool> deleted,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalRecordsTableUpdateCompanionBuilder =
    LocalRecordsCompanion Function({
      Value<String> localId,
      Value<String?> serverId,
      Value<String> recordType,
      Value<String> payload,
      Value<String> syncStatus,
      Value<int> version,
      Value<bool> deleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalRecordsTableFilterComposer
    extends Composer<_$FishTraceDatabase, $LocalRecordsTable> {
  $$LocalRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
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
}

class $$LocalRecordsTableOrderingComposer
    extends Composer<_$FishTraceDatabase, $LocalRecordsTable> {
  $$LocalRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
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

class $$LocalRecordsTableAnnotationComposer
    extends Composer<_$FishTraceDatabase, $LocalRecordsTable> {
  $$LocalRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalRecordsTableTableManager
    extends
        RootTableManager<
          _$FishTraceDatabase,
          $LocalRecordsTable,
          LocalRecord,
          $$LocalRecordsTableFilterComposer,
          $$LocalRecordsTableOrderingComposer,
          $$LocalRecordsTableAnnotationComposer,
          $$LocalRecordsTableCreateCompanionBuilder,
          $$LocalRecordsTableUpdateCompanionBuilder,
          (
            LocalRecord,
            BaseReferences<
              _$FishTraceDatabase,
              $LocalRecordsTable,
              LocalRecord
            >,
          ),
          LocalRecord,
          PrefetchHooks Function()
        > {
  $$LocalRecordsTableTableManager(
    _$FishTraceDatabase db,
    $LocalRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> localId = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> recordType = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalRecordsCompanion(
                localId: localId,
                serverId: serverId,
                recordType: recordType,
                payload: payload,
                syncStatus: syncStatus,
                version: version,
                deleted: deleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localId,
                Value<String?> serverId = const Value.absent(),
                required String recordType,
                Value<String> payload = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalRecordsCompanion.insert(
                localId: localId,
                serverId: serverId,
                recordType: recordType,
                payload: payload,
                syncStatus: syncStatus,
                version: version,
                deleted: deleted,
                createdAt: createdAt,
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

typedef $$LocalRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$FishTraceDatabase,
      $LocalRecordsTable,
      LocalRecord,
      $$LocalRecordsTableFilterComposer,
      $$LocalRecordsTableOrderingComposer,
      $$LocalRecordsTableAnnotationComposer,
      $$LocalRecordsTableCreateCompanionBuilder,
      $$LocalRecordsTableUpdateCompanionBuilder,
      (
        LocalRecord,
        BaseReferences<_$FishTraceDatabase, $LocalRecordsTable, LocalRecord>,
      ),
      LocalRecord,
      PrefetchHooks Function()
    >;
typedef $$AuthMetadataRowsTableCreateCompanionBuilder =
    AuthMetadataRowsCompanion Function({
      required String userId,
      required String displayName,
      required String email,
      required String role,
      required DateTime lastLoginAt,
      Value<int> rowid,
    });
typedef $$AuthMetadataRowsTableUpdateCompanionBuilder =
    AuthMetadataRowsCompanion Function({
      Value<String> userId,
      Value<String> displayName,
      Value<String> email,
      Value<String> role,
      Value<DateTime> lastLoginAt,
      Value<int> rowid,
    });

class $$AuthMetadataRowsTableFilterComposer
    extends Composer<_$FishTraceDatabase, $AuthMetadataRowsTable> {
  $$AuthMetadataRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AuthMetadataRowsTableOrderingComposer
    extends Composer<_$FishTraceDatabase, $AuthMetadataRowsTable> {
  $$AuthMetadataRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AuthMetadataRowsTableAnnotationComposer
    extends Composer<_$FishTraceDatabase, $AuthMetadataRowsTable> {
  $$AuthMetadataRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => column,
  );
}

class $$AuthMetadataRowsTableTableManager
    extends
        RootTableManager<
          _$FishTraceDatabase,
          $AuthMetadataRowsTable,
          AuthMetadataRow,
          $$AuthMetadataRowsTableFilterComposer,
          $$AuthMetadataRowsTableOrderingComposer,
          $$AuthMetadataRowsTableAnnotationComposer,
          $$AuthMetadataRowsTableCreateCompanionBuilder,
          $$AuthMetadataRowsTableUpdateCompanionBuilder,
          (
            AuthMetadataRow,
            BaseReferences<
              _$FishTraceDatabase,
              $AuthMetadataRowsTable,
              AuthMetadataRow
            >,
          ),
          AuthMetadataRow,
          PrefetchHooks Function()
        > {
  $$AuthMetadataRowsTableTableManager(
    _$FishTraceDatabase db,
    $AuthMetadataRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuthMetadataRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuthMetadataRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuthMetadataRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<DateTime> lastLoginAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuthMetadataRowsCompanion(
                userId: userId,
                displayName: displayName,
                email: email,
                role: role,
                lastLoginAt: lastLoginAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String displayName,
                required String email,
                required String role,
                required DateTime lastLoginAt,
                Value<int> rowid = const Value.absent(),
              }) => AuthMetadataRowsCompanion.insert(
                userId: userId,
                displayName: displayName,
                email: email,
                role: role,
                lastLoginAt: lastLoginAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AuthMetadataRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$FishTraceDatabase,
      $AuthMetadataRowsTable,
      AuthMetadataRow,
      $$AuthMetadataRowsTableFilterComposer,
      $$AuthMetadataRowsTableOrderingComposer,
      $$AuthMetadataRowsTableAnnotationComposer,
      $$AuthMetadataRowsTableCreateCompanionBuilder,
      $$AuthMetadataRowsTableUpdateCompanionBuilder,
      (
        AuthMetadataRow,
        BaseReferences<
          _$FishTraceDatabase,
          $AuthMetadataRowsTable,
          AuthMetadataRow
        >,
      ),
      AuthMetadataRow,
      PrefetchHooks Function()
    >;
typedef $$BoatRowsTableCreateCompanionBuilder =
    BoatRowsCompanion Function({
      required String localId,
      Value<String?> serverId,
      required String name,
      required String registration,
      required double lengthMetres,
      required String engine,
      required String boatType,
      required String homePort,
      Value<bool> active,
      Value<String> syncStatus,
      Value<int> retryCount,
      Value<String?> lastError,
      Value<DateTime> createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$BoatRowsTableUpdateCompanionBuilder =
    BoatRowsCompanion Function({
      Value<String> localId,
      Value<String?> serverId,
      Value<String> name,
      Value<String> registration,
      Value<double> lengthMetres,
      Value<String> engine,
      Value<String> boatType,
      Value<String> homePort,
      Value<bool> active,
      Value<String> syncStatus,
      Value<int> retryCount,
      Value<String?> lastError,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$BoatRowsTableFilterComposer
    extends Composer<_$FishTraceDatabase, $BoatRowsTable> {
  $$BoatRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get registration => $composableBuilder(
    column: $table.registration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lengthMetres => $composableBuilder(
    column: $table.lengthMetres,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get engine => $composableBuilder(
    column: $table.engine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get boatType => $composableBuilder(
    column: $table.boatType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get homePort => $composableBuilder(
    column: $table.homePort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
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
}

class $$BoatRowsTableOrderingComposer
    extends Composer<_$FishTraceDatabase, $BoatRowsTable> {
  $$BoatRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get registration => $composableBuilder(
    column: $table.registration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lengthMetres => $composableBuilder(
    column: $table.lengthMetres,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get engine => $composableBuilder(
    column: $table.engine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get boatType => $composableBuilder(
    column: $table.boatType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get homePort => $composableBuilder(
    column: $table.homePort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
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

class $$BoatRowsTableAnnotationComposer
    extends Composer<_$FishTraceDatabase, $BoatRowsTable> {
  $$BoatRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get registration => $composableBuilder(
    column: $table.registration,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lengthMetres => $composableBuilder(
    column: $table.lengthMetres,
    builder: (column) => column,
  );

  GeneratedColumn<String> get engine =>
      $composableBuilder(column: $table.engine, builder: (column) => column);

  GeneratedColumn<String> get boatType =>
      $composableBuilder(column: $table.boatType, builder: (column) => column);

  GeneratedColumn<String> get homePort =>
      $composableBuilder(column: $table.homePort, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$BoatRowsTableTableManager
    extends
        RootTableManager<
          _$FishTraceDatabase,
          $BoatRowsTable,
          BoatRow,
          $$BoatRowsTableFilterComposer,
          $$BoatRowsTableOrderingComposer,
          $$BoatRowsTableAnnotationComposer,
          $$BoatRowsTableCreateCompanionBuilder,
          $$BoatRowsTableUpdateCompanionBuilder,
          (
            BoatRow,
            BaseReferences<_$FishTraceDatabase, $BoatRowsTable, BoatRow>,
          ),
          BoatRow,
          PrefetchHooks Function()
        > {
  $$BoatRowsTableTableManager(_$FishTraceDatabase db, $BoatRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BoatRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BoatRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BoatRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> localId = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> registration = const Value.absent(),
                Value<double> lengthMetres = const Value.absent(),
                Value<String> engine = const Value.absent(),
                Value<String> boatType = const Value.absent(),
                Value<String> homePort = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BoatRowsCompanion(
                localId: localId,
                serverId: serverId,
                name: name,
                registration: registration,
                lengthMetres: lengthMetres,
                engine: engine,
                boatType: boatType,
                homePort: homePort,
                active: active,
                syncStatus: syncStatus,
                retryCount: retryCount,
                lastError: lastError,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localId,
                Value<String?> serverId = const Value.absent(),
                required String name,
                required String registration,
                required double lengthMetres,
                required String engine,
                required String boatType,
                required String homePort,
                Value<bool> active = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => BoatRowsCompanion.insert(
                localId: localId,
                serverId: serverId,
                name: name,
                registration: registration,
                lengthMetres: lengthMetres,
                engine: engine,
                boatType: boatType,
                homePort: homePort,
                active: active,
                syncStatus: syncStatus,
                retryCount: retryCount,
                lastError: lastError,
                createdAt: createdAt,
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

typedef $$BoatRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$FishTraceDatabase,
      $BoatRowsTable,
      BoatRow,
      $$BoatRowsTableFilterComposer,
      $$BoatRowsTableOrderingComposer,
      $$BoatRowsTableAnnotationComposer,
      $$BoatRowsTableCreateCompanionBuilder,
      $$BoatRowsTableUpdateCompanionBuilder,
      (BoatRow, BaseReferences<_$FishTraceDatabase, $BoatRowsTable, BoatRow>),
      BoatRow,
      PrefetchHooks Function()
    >;
typedef $$FishingTripRowsTableCreateCompanionBuilder =
    FishingTripRowsCompanion Function({
      required String localId,
      Value<String?> serverId,
      required String boatId,
      required String boatName,
      required DateTime startedAt,
      required String fishingArea,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String> crewJson,
      Value<double> catchKg,
      Value<int> batchCount,
      required String status,
      Value<String> syncStatus,
      Value<int> retryCount,
      Value<String?> lastError,
      Value<DateTime> createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$FishingTripRowsTableUpdateCompanionBuilder =
    FishingTripRowsCompanion Function({
      Value<String> localId,
      Value<String?> serverId,
      Value<String> boatId,
      Value<String> boatName,
      Value<DateTime> startedAt,
      Value<String> fishingArea,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String> crewJson,
      Value<double> catchKg,
      Value<int> batchCount,
      Value<String> status,
      Value<String> syncStatus,
      Value<int> retryCount,
      Value<String?> lastError,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$FishingTripRowsTableFilterComposer
    extends Composer<_$FishTraceDatabase, $FishingTripRowsTable> {
  $$FishingTripRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get boatId => $composableBuilder(
    column: $table.boatId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get boatName => $composableBuilder(
    column: $table.boatName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fishingArea => $composableBuilder(
    column: $table.fishingArea,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get crewJson => $composableBuilder(
    column: $table.crewJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get catchKg => $composableBuilder(
    column: $table.catchKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get batchCount => $composableBuilder(
    column: $table.batchCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
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
}

class $$FishingTripRowsTableOrderingComposer
    extends Composer<_$FishTraceDatabase, $FishingTripRowsTable> {
  $$FishingTripRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get boatId => $composableBuilder(
    column: $table.boatId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get boatName => $composableBuilder(
    column: $table.boatName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fishingArea => $composableBuilder(
    column: $table.fishingArea,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get crewJson => $composableBuilder(
    column: $table.crewJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get catchKg => $composableBuilder(
    column: $table.catchKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get batchCount => $composableBuilder(
    column: $table.batchCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
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

class $$FishingTripRowsTableAnnotationComposer
    extends Composer<_$FishTraceDatabase, $FishingTripRowsTable> {
  $$FishingTripRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get boatId =>
      $composableBuilder(column: $table.boatId, builder: (column) => column);

  GeneratedColumn<String> get boatName =>
      $composableBuilder(column: $table.boatName, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<String> get fishingArea => $composableBuilder(
    column: $table.fishingArea,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get crewJson =>
      $composableBuilder(column: $table.crewJson, builder: (column) => column);

  GeneratedColumn<double> get catchKg =>
      $composableBuilder(column: $table.catchKg, builder: (column) => column);

  GeneratedColumn<int> get batchCount => $composableBuilder(
    column: $table.batchCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FishingTripRowsTableTableManager
    extends
        RootTableManager<
          _$FishTraceDatabase,
          $FishingTripRowsTable,
          FishingTripRow,
          $$FishingTripRowsTableFilterComposer,
          $$FishingTripRowsTableOrderingComposer,
          $$FishingTripRowsTableAnnotationComposer,
          $$FishingTripRowsTableCreateCompanionBuilder,
          $$FishingTripRowsTableUpdateCompanionBuilder,
          (
            FishingTripRow,
            BaseReferences<
              _$FishTraceDatabase,
              $FishingTripRowsTable,
              FishingTripRow
            >,
          ),
          FishingTripRow,
          PrefetchHooks Function()
        > {
  $$FishingTripRowsTableTableManager(
    _$FishTraceDatabase db,
    $FishingTripRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FishingTripRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FishingTripRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FishingTripRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> localId = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> boatId = const Value.absent(),
                Value<String> boatName = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<String> fishingArea = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String> crewJson = const Value.absent(),
                Value<double> catchKg = const Value.absent(),
                Value<int> batchCount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FishingTripRowsCompanion(
                localId: localId,
                serverId: serverId,
                boatId: boatId,
                boatName: boatName,
                startedAt: startedAt,
                fishingArea: fishingArea,
                latitude: latitude,
                longitude: longitude,
                crewJson: crewJson,
                catchKg: catchKg,
                batchCount: batchCount,
                status: status,
                syncStatus: syncStatus,
                retryCount: retryCount,
                lastError: lastError,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localId,
                Value<String?> serverId = const Value.absent(),
                required String boatId,
                required String boatName,
                required DateTime startedAt,
                required String fishingArea,
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String> crewJson = const Value.absent(),
                Value<double> catchKg = const Value.absent(),
                Value<int> batchCount = const Value.absent(),
                required String status,
                Value<String> syncStatus = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => FishingTripRowsCompanion.insert(
                localId: localId,
                serverId: serverId,
                boatId: boatId,
                boatName: boatName,
                startedAt: startedAt,
                fishingArea: fishingArea,
                latitude: latitude,
                longitude: longitude,
                crewJson: crewJson,
                catchKg: catchKg,
                batchCount: batchCount,
                status: status,
                syncStatus: syncStatus,
                retryCount: retryCount,
                lastError: lastError,
                createdAt: createdAt,
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

typedef $$FishingTripRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$FishTraceDatabase,
      $FishingTripRowsTable,
      FishingTripRow,
      $$FishingTripRowsTableFilterComposer,
      $$FishingTripRowsTableOrderingComposer,
      $$FishingTripRowsTableAnnotationComposer,
      $$FishingTripRowsTableCreateCompanionBuilder,
      $$FishingTripRowsTableUpdateCompanionBuilder,
      (
        FishingTripRow,
        BaseReferences<
          _$FishTraceDatabase,
          $FishingTripRowsTable,
          FishingTripRow
        >,
      ),
      FishingTripRow,
      PrefetchHooks Function()
    >;
typedef $$CatchDraftRowsTableCreateCompanionBuilder =
    CatchDraftRowsCompanion Function({
      required String localId,
      Value<String?> serverId,
      required String tripId,
      required String species,
      required String scientificName,
      required double weightKg,
      required int quantity,
      required DateTime caughtAt,
      required double latitude,
      required double longitude,
      required String gear,
      required String condition,
      Value<bool> verified,
      Value<String?> linkedBatchId,
      Value<String> syncStatus,
      Value<int> retryCount,
      Value<String?> lastError,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CatchDraftRowsTableUpdateCompanionBuilder =
    CatchDraftRowsCompanion Function({
      Value<String> localId,
      Value<String?> serverId,
      Value<String> tripId,
      Value<String> species,
      Value<String> scientificName,
      Value<double> weightKg,
      Value<int> quantity,
      Value<DateTime> caughtAt,
      Value<double> latitude,
      Value<double> longitude,
      Value<String> gear,
      Value<String> condition,
      Value<bool> verified,
      Value<String?> linkedBatchId,
      Value<String> syncStatus,
      Value<int> retryCount,
      Value<String?> lastError,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CatchDraftRowsTableFilterComposer
    extends Composer<_$FishTraceDatabase, $CatchDraftRowsTable> {
  $$CatchDraftRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get species => $composableBuilder(
    column: $table.species,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scientificName => $composableBuilder(
    column: $table.scientificName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get caughtAt => $composableBuilder(
    column: $table.caughtAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gear => $composableBuilder(
    column: $table.gear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get condition => $composableBuilder(
    column: $table.condition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get verified => $composableBuilder(
    column: $table.verified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linkedBatchId => $composableBuilder(
    column: $table.linkedBatchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
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
}

class $$CatchDraftRowsTableOrderingComposer
    extends Composer<_$FishTraceDatabase, $CatchDraftRowsTable> {
  $$CatchDraftRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get species => $composableBuilder(
    column: $table.species,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scientificName => $composableBuilder(
    column: $table.scientificName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get caughtAt => $composableBuilder(
    column: $table.caughtAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gear => $composableBuilder(
    column: $table.gear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get condition => $composableBuilder(
    column: $table.condition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get verified => $composableBuilder(
    column: $table.verified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkedBatchId => $composableBuilder(
    column: $table.linkedBatchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
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

class $$CatchDraftRowsTableAnnotationComposer
    extends Composer<_$FishTraceDatabase, $CatchDraftRowsTable> {
  $$CatchDraftRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => column);

  GeneratedColumn<String> get species =>
      $composableBuilder(column: $table.species, builder: (column) => column);

  GeneratedColumn<String> get scientificName => $composableBuilder(
    column: $table.scientificName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<DateTime> get caughtAt =>
      $composableBuilder(column: $table.caughtAt, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get gear =>
      $composableBuilder(column: $table.gear, builder: (column) => column);

  GeneratedColumn<String> get condition =>
      $composableBuilder(column: $table.condition, builder: (column) => column);

  GeneratedColumn<bool> get verified =>
      $composableBuilder(column: $table.verified, builder: (column) => column);

  GeneratedColumn<String> get linkedBatchId => $composableBuilder(
    column: $table.linkedBatchId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CatchDraftRowsTableTableManager
    extends
        RootTableManager<
          _$FishTraceDatabase,
          $CatchDraftRowsTable,
          CatchDraftRow,
          $$CatchDraftRowsTableFilterComposer,
          $$CatchDraftRowsTableOrderingComposer,
          $$CatchDraftRowsTableAnnotationComposer,
          $$CatchDraftRowsTableCreateCompanionBuilder,
          $$CatchDraftRowsTableUpdateCompanionBuilder,
          (
            CatchDraftRow,
            BaseReferences<
              _$FishTraceDatabase,
              $CatchDraftRowsTable,
              CatchDraftRow
            >,
          ),
          CatchDraftRow,
          PrefetchHooks Function()
        > {
  $$CatchDraftRowsTableTableManager(
    _$FishTraceDatabase db,
    $CatchDraftRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatchDraftRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatchDraftRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatchDraftRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> localId = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<String> species = const Value.absent(),
                Value<String> scientificName = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<DateTime> caughtAt = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<String> gear = const Value.absent(),
                Value<String> condition = const Value.absent(),
                Value<bool> verified = const Value.absent(),
                Value<String?> linkedBatchId = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatchDraftRowsCompanion(
                localId: localId,
                serverId: serverId,
                tripId: tripId,
                species: species,
                scientificName: scientificName,
                weightKg: weightKg,
                quantity: quantity,
                caughtAt: caughtAt,
                latitude: latitude,
                longitude: longitude,
                gear: gear,
                condition: condition,
                verified: verified,
                linkedBatchId: linkedBatchId,
                syncStatus: syncStatus,
                retryCount: retryCount,
                lastError: lastError,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localId,
                Value<String?> serverId = const Value.absent(),
                required String tripId,
                required String species,
                required String scientificName,
                required double weightKg,
                required int quantity,
                required DateTime caughtAt,
                required double latitude,
                required double longitude,
                required String gear,
                required String condition,
                Value<bool> verified = const Value.absent(),
                Value<String?> linkedBatchId = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CatchDraftRowsCompanion.insert(
                localId: localId,
                serverId: serverId,
                tripId: tripId,
                species: species,
                scientificName: scientificName,
                weightKg: weightKg,
                quantity: quantity,
                caughtAt: caughtAt,
                latitude: latitude,
                longitude: longitude,
                gear: gear,
                condition: condition,
                verified: verified,
                linkedBatchId: linkedBatchId,
                syncStatus: syncStatus,
                retryCount: retryCount,
                lastError: lastError,
                createdAt: createdAt,
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

typedef $$CatchDraftRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$FishTraceDatabase,
      $CatchDraftRowsTable,
      CatchDraftRow,
      $$CatchDraftRowsTableFilterComposer,
      $$CatchDraftRowsTableOrderingComposer,
      $$CatchDraftRowsTableAnnotationComposer,
      $$CatchDraftRowsTableCreateCompanionBuilder,
      $$CatchDraftRowsTableUpdateCompanionBuilder,
      (
        CatchDraftRow,
        BaseReferences<
          _$FishTraceDatabase,
          $CatchDraftRowsTable,
          CatchDraftRow
        >,
      ),
      CatchDraftRow,
      PrefetchHooks Function()
    >;
typedef $$CatchPhotoRowsTableCreateCompanionBuilder =
    CatchPhotoRowsCompanion Function({
      required String id,
      required String catchLocalId,
      required String localPath,
      Value<String?> remoteUrl,
      Value<String> syncStatus,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CatchPhotoRowsTableUpdateCompanionBuilder =
    CatchPhotoRowsCompanion Function({
      Value<String> id,
      Value<String> catchLocalId,
      Value<String> localPath,
      Value<String?> remoteUrl,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$CatchPhotoRowsTableFilterComposer
    extends Composer<_$FishTraceDatabase, $CatchPhotoRowsTable> {
  $$CatchPhotoRowsTableFilterComposer({
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

  ColumnFilters<String> get catchLocalId => $composableBuilder(
    column: $table.catchLocalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteUrl => $composableBuilder(
    column: $table.remoteUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CatchPhotoRowsTableOrderingComposer
    extends Composer<_$FishTraceDatabase, $CatchPhotoRowsTable> {
  $$CatchPhotoRowsTableOrderingComposer({
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

  ColumnOrderings<String> get catchLocalId => $composableBuilder(
    column: $table.catchLocalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteUrl => $composableBuilder(
    column: $table.remoteUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CatchPhotoRowsTableAnnotationComposer
    extends Composer<_$FishTraceDatabase, $CatchPhotoRowsTable> {
  $$CatchPhotoRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get catchLocalId => $composableBuilder(
    column: $table.catchLocalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get remoteUrl =>
      $composableBuilder(column: $table.remoteUrl, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CatchPhotoRowsTableTableManager
    extends
        RootTableManager<
          _$FishTraceDatabase,
          $CatchPhotoRowsTable,
          CatchPhotoRow,
          $$CatchPhotoRowsTableFilterComposer,
          $$CatchPhotoRowsTableOrderingComposer,
          $$CatchPhotoRowsTableAnnotationComposer,
          $$CatchPhotoRowsTableCreateCompanionBuilder,
          $$CatchPhotoRowsTableUpdateCompanionBuilder,
          (
            CatchPhotoRow,
            BaseReferences<
              _$FishTraceDatabase,
              $CatchPhotoRowsTable,
              CatchPhotoRow
            >,
          ),
          CatchPhotoRow,
          PrefetchHooks Function()
        > {
  $$CatchPhotoRowsTableTableManager(
    _$FishTraceDatabase db,
    $CatchPhotoRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatchPhotoRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatchPhotoRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatchPhotoRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> catchLocalId = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<String?> remoteUrl = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatchPhotoRowsCompanion(
                id: id,
                catchLocalId: catchLocalId,
                localPath: localPath,
                remoteUrl: remoteUrl,
                syncStatus: syncStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String catchLocalId,
                required String localPath,
                Value<String?> remoteUrl = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CatchPhotoRowsCompanion.insert(
                id: id,
                catchLocalId: catchLocalId,
                localPath: localPath,
                remoteUrl: remoteUrl,
                syncStatus: syncStatus,
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

typedef $$CatchPhotoRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$FishTraceDatabase,
      $CatchPhotoRowsTable,
      CatchPhotoRow,
      $$CatchPhotoRowsTableFilterComposer,
      $$CatchPhotoRowsTableOrderingComposer,
      $$CatchPhotoRowsTableAnnotationComposer,
      $$CatchPhotoRowsTableCreateCompanionBuilder,
      $$CatchPhotoRowsTableUpdateCompanionBuilder,
      (
        CatchPhotoRow,
        BaseReferences<
          _$FishTraceDatabase,
          $CatchPhotoRowsTable,
          CatchPhotoRow
        >,
      ),
      CatchPhotoRow,
      PrefetchHooks Function()
    >;
typedef $$BatchDraftRowsTableCreateCompanionBuilder =
    BatchDraftRowsCompanion Function({
      required String localId,
      Value<String?> serverId,
      required String tripId,
      required String species,
      required double weightKg,
      required int fishCount,
      required String grade,
      required String status,
      Value<String> catchIdsJson,
      Value<String> payload,
      Value<String> syncStatus,
      Value<int> retryCount,
      Value<String?> lastError,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$BatchDraftRowsTableUpdateCompanionBuilder =
    BatchDraftRowsCompanion Function({
      Value<String> localId,
      Value<String?> serverId,
      Value<String> tripId,
      Value<String> species,
      Value<double> weightKg,
      Value<int> fishCount,
      Value<String> grade,
      Value<String> status,
      Value<String> catchIdsJson,
      Value<String> payload,
      Value<String> syncStatus,
      Value<int> retryCount,
      Value<String?> lastError,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$BatchDraftRowsTableFilterComposer
    extends Composer<_$FishTraceDatabase, $BatchDraftRowsTable> {
  $$BatchDraftRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get species => $composableBuilder(
    column: $table.species,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fishCount => $composableBuilder(
    column: $table.fishCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catchIdsJson => $composableBuilder(
    column: $table.catchIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
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
}

class $$BatchDraftRowsTableOrderingComposer
    extends Composer<_$FishTraceDatabase, $BatchDraftRowsTable> {
  $$BatchDraftRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get species => $composableBuilder(
    column: $table.species,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fishCount => $composableBuilder(
    column: $table.fishCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catchIdsJson => $composableBuilder(
    column: $table.catchIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
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

class $$BatchDraftRowsTableAnnotationComposer
    extends Composer<_$FishTraceDatabase, $BatchDraftRowsTable> {
  $$BatchDraftRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => column);

  GeneratedColumn<String> get species =>
      $composableBuilder(column: $table.species, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<int> get fishCount =>
      $composableBuilder(column: $table.fishCount, builder: (column) => column);

  GeneratedColumn<String> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get catchIdsJson => $composableBuilder(
    column: $table.catchIdsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$BatchDraftRowsTableTableManager
    extends
        RootTableManager<
          _$FishTraceDatabase,
          $BatchDraftRowsTable,
          BatchDraftRow,
          $$BatchDraftRowsTableFilterComposer,
          $$BatchDraftRowsTableOrderingComposer,
          $$BatchDraftRowsTableAnnotationComposer,
          $$BatchDraftRowsTableCreateCompanionBuilder,
          $$BatchDraftRowsTableUpdateCompanionBuilder,
          (
            BatchDraftRow,
            BaseReferences<
              _$FishTraceDatabase,
              $BatchDraftRowsTable,
              BatchDraftRow
            >,
          ),
          BatchDraftRow,
          PrefetchHooks Function()
        > {
  $$BatchDraftRowsTableTableManager(
    _$FishTraceDatabase db,
    $BatchDraftRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BatchDraftRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BatchDraftRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BatchDraftRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> localId = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<String> species = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<int> fishCount = const Value.absent(),
                Value<String> grade = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> catchIdsJson = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BatchDraftRowsCompanion(
                localId: localId,
                serverId: serverId,
                tripId: tripId,
                species: species,
                weightKg: weightKg,
                fishCount: fishCount,
                grade: grade,
                status: status,
                catchIdsJson: catchIdsJson,
                payload: payload,
                syncStatus: syncStatus,
                retryCount: retryCount,
                lastError: lastError,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localId,
                Value<String?> serverId = const Value.absent(),
                required String tripId,
                required String species,
                required double weightKg,
                required int fishCount,
                required String grade,
                required String status,
                Value<String> catchIdsJson = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => BatchDraftRowsCompanion.insert(
                localId: localId,
                serverId: serverId,
                tripId: tripId,
                species: species,
                weightKg: weightKg,
                fishCount: fishCount,
                grade: grade,
                status: status,
                catchIdsJson: catchIdsJson,
                payload: payload,
                syncStatus: syncStatus,
                retryCount: retryCount,
                lastError: lastError,
                createdAt: createdAt,
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

typedef $$BatchDraftRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$FishTraceDatabase,
      $BatchDraftRowsTable,
      BatchDraftRow,
      $$BatchDraftRowsTableFilterComposer,
      $$BatchDraftRowsTableOrderingComposer,
      $$BatchDraftRowsTableAnnotationComposer,
      $$BatchDraftRowsTableCreateCompanionBuilder,
      $$BatchDraftRowsTableUpdateCompanionBuilder,
      (
        BatchDraftRow,
        BaseReferences<
          _$FishTraceDatabase,
          $BatchDraftRowsTable,
          BatchDraftRow
        >,
      ),
      BatchDraftRow,
      PrefetchHooks Function()
    >;
typedef $$ReferenceDataRowsTableCreateCompanionBuilder =
    ReferenceDataRowsCompanion Function({
      required String key,
      required String category,
      required String payload,
      required DateTime fetchedAt,
      Value<DateTime?> expiresAt,
      Value<int> rowid,
    });
typedef $$ReferenceDataRowsTableUpdateCompanionBuilder =
    ReferenceDataRowsCompanion Function({
      Value<String> key,
      Value<String> category,
      Value<String> payload,
      Value<DateTime> fetchedAt,
      Value<DateTime?> expiresAt,
      Value<int> rowid,
    });

class $$ReferenceDataRowsTableFilterComposer
    extends Composer<_$FishTraceDatabase, $ReferenceDataRowsTable> {
  $$ReferenceDataRowsTableFilterComposer({
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

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReferenceDataRowsTableOrderingComposer
    extends Composer<_$FishTraceDatabase, $ReferenceDataRowsTable> {
  $$ReferenceDataRowsTableOrderingComposer({
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

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReferenceDataRowsTableAnnotationComposer
    extends Composer<_$FishTraceDatabase, $ReferenceDataRowsTable> {
  $$ReferenceDataRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);
}

class $$ReferenceDataRowsTableTableManager
    extends
        RootTableManager<
          _$FishTraceDatabase,
          $ReferenceDataRowsTable,
          ReferenceDataRow,
          $$ReferenceDataRowsTableFilterComposer,
          $$ReferenceDataRowsTableOrderingComposer,
          $$ReferenceDataRowsTableAnnotationComposer,
          $$ReferenceDataRowsTableCreateCompanionBuilder,
          $$ReferenceDataRowsTableUpdateCompanionBuilder,
          (
            ReferenceDataRow,
            BaseReferences<
              _$FishTraceDatabase,
              $ReferenceDataRowsTable,
              ReferenceDataRow
            >,
          ),
          ReferenceDataRow,
          PrefetchHooks Function()
        > {
  $$ReferenceDataRowsTableTableManager(
    _$FishTraceDatabase db,
    $ReferenceDataRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReferenceDataRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReferenceDataRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReferenceDataRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReferenceDataRowsCompanion(
                key: key,
                category: category,
                payload: payload,
                fetchedAt: fetchedAt,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String category,
                required String payload,
                required DateTime fetchedAt,
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReferenceDataRowsCompanion.insert(
                key: key,
                category: category,
                payload: payload,
                fetchedAt: fetchedAt,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReferenceDataRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$FishTraceDatabase,
      $ReferenceDataRowsTable,
      ReferenceDataRow,
      $$ReferenceDataRowsTableFilterComposer,
      $$ReferenceDataRowsTableOrderingComposer,
      $$ReferenceDataRowsTableAnnotationComposer,
      $$ReferenceDataRowsTableCreateCompanionBuilder,
      $$ReferenceDataRowsTableUpdateCompanionBuilder,
      (
        ReferenceDataRow,
        BaseReferences<
          _$FishTraceDatabase,
          $ReferenceDataRowsTable,
          ReferenceDataRow
        >,
      ),
      ReferenceDataRow,
      PrefetchHooks Function()
    >;

class $FishTraceDatabaseManager {
  final _$FishTraceDatabase _db;
  $FishTraceDatabaseManager(this._db);
  $$SyncOperationsTableTableManager get syncOperations =>
      $$SyncOperationsTableTableManager(_db, _db.syncOperations);
  $$LocalRecordsTableTableManager get localRecords =>
      $$LocalRecordsTableTableManager(_db, _db.localRecords);
  $$AuthMetadataRowsTableTableManager get authMetadataRows =>
      $$AuthMetadataRowsTableTableManager(_db, _db.authMetadataRows);
  $$BoatRowsTableTableManager get boatRows =>
      $$BoatRowsTableTableManager(_db, _db.boatRows);
  $$FishingTripRowsTableTableManager get fishingTripRows =>
      $$FishingTripRowsTableTableManager(_db, _db.fishingTripRows);
  $$CatchDraftRowsTableTableManager get catchDraftRows =>
      $$CatchDraftRowsTableTableManager(_db, _db.catchDraftRows);
  $$CatchPhotoRowsTableTableManager get catchPhotoRows =>
      $$CatchPhotoRowsTableTableManager(_db, _db.catchPhotoRows);
  $$BatchDraftRowsTableTableManager get batchDraftRows =>
      $$BatchDraftRowsTableTableManager(_db, _db.batchDraftRows);
  $$ReferenceDataRowsTableTableManager get referenceDataRows =>
      $$ReferenceDataRowsTableTableManager(_db, _db.referenceDataRows);
}
