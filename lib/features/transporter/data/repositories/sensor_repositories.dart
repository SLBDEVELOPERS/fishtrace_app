import 'dart:async';

import 'package:firebase_database/firebase_database.dart';

import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/models/models.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_support.dart';
import '../../../../core/network/sensor_stream.dart';
import '../../../authentication/domain/repositories/firebase_session_repository.dart';
import '../../domain/repositories/sensor_repositories.dart';

class MockSensorRepository implements SensorRepository {
  MockSensorRepository(this._stream);
  final SensorStream _stream;
  @override
  Future<SensorReading> latest(String tripId) => _stream.latest();
  @override
  Future<List<SensorReading>> history(String tripId) => _stream.history();
}

class LaravelSensorRepository implements SensorRepository {
  const LaravelSensorRepository(this._api);
  final ApiClient _api;

  @override
  Future<SensorReading?> latest(String tripId) async {
    final envelope = ApiData.map(
      await _api.get(ApiEndpoints.latestSensorReading(tripId)),
    );
    final data = envelope['data'];
    return data is Map ? _reading(data.cast<Object?, Object?>()) : null;
  }

  @override
  Future<List<SensorReading>> history(String tripId) async => ApiData.list(
    await _api.get(ApiEndpoints.sensorReadings(tripId)),
  ).map(_reading).toList(growable: false);
}

class MockLiveSensorRepository implements LiveSensorRepository {
  MockLiveSensorRepository(this._stream);
  final SensorStream _stream;
  @override
  Stream<SensorReading> watchTrip(String tripId) => _stream.watch();
  @override
  Future<void> dispose() => _stream.dispose();
}

/// Uses the permanent Laravel telemetry API when Firebase streaming is
/// intentionally disabled. No readings are synthesized.
class PollingLiveSensorRepository implements LiveSensorRepository {
  PollingLiveSensorRepository(
    this._sensors, {
    this.interval = const Duration(seconds: 10),
  });

  final SensorRepository _sensors;
  final Duration interval;
  var _generation = 0;

  @override
  Stream<SensorReading> watchTrip(String tripId) async* {
    final generation = ++_generation;
    DateTime? lastRecordedAt;
    while (generation == _generation) {
      final reading = await _sensors.latest(tripId);
      if (reading != null && reading.recordedAt != lastRecordedAt) {
        lastRecordedAt = reading.recordedAt;
        yield reading;
      }
      await Future<void>.delayed(interval);
    }
  }

  @override
  Future<void> dispose() async {
    _generation++;
  }
}

class FirebaseLiveSensorRepository implements LiveSensorRepository {
  FirebaseLiveSensorRepository({
    required ApiClient api,
    required FirebaseSessionRepository session,
    FirebaseDatabase? database,
  }) : _api = api,
       _session = session,
       _providedDatabase = database;

  final ApiClient _api;
  final FirebaseSessionRepository _session;
  final FirebaseDatabase? _providedDatabase;
  FirebaseDatabase get _database =>
      _providedDatabase ?? FirebaseDatabase.instance;
  StreamSubscription<DatabaseEvent>? _activeSubscription;
  StreamController<SensorReading>? _activeController;

  @override
  Stream<SensorReading> watchTrip(String tripId) {
    late final StreamController<SensorReading> controller;
    controller = StreamController<SensorReading>(
      onListen: () => _connect(tripId, controller),
      onCancel: () async {
        await _activeSubscription?.cancel();
        _activeSubscription = null;
      },
    );
    _activeController = controller;
    return controller.stream;
  }

  Future<void> _connect(
    String tripId,
    StreamController<SensorReading> controller,
  ) async {
    try {
      if (!_session.isAuthenticated) await _session.createSession();
      final access = ApiData.map(
        await _api.get(ApiEndpoints.liveAccess(tripId)),
      );
      final payload = access['data'] is Map
          ? ApiData.map(access['data'])
          : access;
      final authorizedPath = ApiData.string(
        payload,
        'path',
        '/liveTrips/$tripId',
      );
      if (!authorizedPath.startsWith('/liveTrips/$tripId')) {
        throw const ForbiddenException(
          'The live trip path was not authorized.',
        );
      }
      await _activeSubscription?.cancel();
      _activeSubscription = _database.ref(authorizedPath).onValue.listen((
        event,
      ) {
        final value = event.snapshot.value;
        if (value is Map) {
          controller.add(_reading(value.cast<Object?, Object?>()));
        }
      }, onError: controller.addError);
    } catch (error, stackTrace) {
      controller.addError(error, stackTrace);
    }
  }

  @override
  Future<void> dispose() async {
    await _activeSubscription?.cancel();
    _activeSubscription = null;
    final controller = _activeController;
    _activeController = null;
    if (controller != null && !controller.isClosed) await controller.close();
  }
}

SensorReading _reading(Map<Object?, Object?> raw) {
  final json = raw.map((key, value) => MapEntry(key.toString(), value));
  final nested = json['latest'] is Map
      ? (json['latest'] as Map).map(
          (key, value) => MapEntry(key.toString(), value),
        )
      : json;
  return SensorReading(
    productTemp: _nullableNumber(nested, 'productTemperature'),
    airTemp: _nullableNumber(nested, 'airTemperature'),
    humidity: _nullableNumber(nested, 'humidity'),
    battery: _nullableNumber(nested, 'batteryPercentage'),
    latitude: _nullableNumber(nested, 'latitude'),
    longitude: _nullableNumber(nested, 'longitude'),
    doorOpen: ApiData.boolean(nested, 'doorOpen'),
    recordedAt: _nullableDate(nested, 'recordedAt'),
    temperatureStatus: ApiData.string(nested, 'temperatureStatus'),
  );
}

double? _nullableNumber(Map<String, Object?> json, String key) {
  final value = ApiData.value(json, key);
  if (value is num) return value.toDouble();
  return double.tryParse('$value');
}

DateTime? _nullableDate(Map<String, Object?> json, String key) {
  final value = ApiData.value(json, key);
  if (value is num) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt(), isUtc: true);
  }
  return DateTime.tryParse('$value')?.toUtc();
}
