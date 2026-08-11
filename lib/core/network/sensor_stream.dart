import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/models.dart';
import 'api_support.dart';

abstract interface class SensorStream {
  Stream<SensorReading> watch();
  Future<SensorReading> latest();
  Future<List<SensorReading>> history();
  Future<void> dispose();
}

class MockSensorStream implements SensorStream {
  SensorReading _current = const SensorReading(
    productTemp: 2.1,
    airTemp: 2.3,
    humidity: 62,
    battery: 68,
  );
  bool _disposed = false;
  Timer? _timer;
  var _tick = 0;

  @override
  Stream<SensorReading> watch() {
    late final StreamController<SensorReading> controller;
    controller = StreamController<SensorReading>(
      onListen: () {
        _timer?.cancel();
        _timer = Timer.periodic(const Duration(seconds: 2), (_) {
          if (_disposed) return;
          _tick++;
          final warningCycle = _tick % 30;
          _current = SensorReading(
            productTemp: warningCycle == 24
                ? 4.3
                : _wrap((_current.productTemp ?? 2.1) + .08, 1.7, 4.4),
            airTemp: _wrap((_current.airTemp ?? 2.3) + .05, 1.9, 4.7),
            humidity: _wrap((_current.humidity ?? 62) + .3, 58, 71),
            battery: warningCycle == 27
                ? 18
                : (_current.battery ?? 68) > 18
                ? (_current.battery ?? 68) - .15
                : 68,
            latitude: (_current.latitude ?? 10) + .00015,
            longitude: (_current.longitude ?? 76) + .0001,
            doorOpen: warningCycle == 20,
            recordedAt: DateTime.now(),
          );
          controller.add(_current);
        });
      },
      onCancel: () {
        _timer?.cancel();
        _timer = null;
      },
    );
    return controller.stream;
  }

  @override
  Future<SensorReading> latest() async => _current;
  @override
  Future<List<SensorReading>> history() async => [_current];
  @override
  Future<void> dispose() async {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
  }

  double _wrap(double value, double min, double max) => value > max
      ? min
      : value < min
      ? max
      : value;
}

class ApiSensorStream implements SensorStream {
  ApiSensorStream(this._dio, this._socketUri);
  final Dio _dio;
  final Uri _socketUri;
  bool _disposed = false;
  WebSocketChannel? _channel;

  @override
  Stream<SensorReading> watch() async* {
    var retry = 0;
    while (!_disposed) {
      try {
        final channel = WebSocketChannel.connect(_socketUri);
        _channel = channel;
        await channel.ready;
        retry = 0;
        await for (final event in channel.stream) {
          if (_disposed) break;
          yield _parse(event is String ? jsonDecode(event) : event);
        }
      } catch (_) {
        if (_disposed) break;
        retry++;
        final seconds = retry > 5 ? 30 : 1 << retry;
        await Future<void>.delayed(Duration(seconds: seconds));
      }
    }
  }

  @override
  Future<SensorReading> latest() async =>
      _parse((await _dio.get<Object?>('/sensors/latest')).data);

  @override
  Future<List<SensorReading>> history() async => ApiData.list(
    (await _dio.get<Object?>('/sensors/history')).data,
  ).map(_parse).toList(growable: false);

  SensorReading _parse(Object? value) {
    final json = ApiData.map(
      value is Map && value['data'] != null ? value['data'] : value,
    );
    return SensorReading(
      productTemp: _nullableNumber(json, 'productTemperature', 'productTemp'),
      airTemp: _nullableNumber(json, 'airTemperature', 'airTemp'),
      humidity: _nullableNumber(json, 'humidity'),
      battery: _nullableNumber(json, 'batteryPercentage', 'battery'),
      latitude: _nullableNumber(json, 'latitude'),
      longitude: _nullableNumber(json, 'longitude'),
      doorOpen: ApiData.boolean(json, 'doorOpen'),
      recordedAt: _nullableDate(json, 'recordedAt'),
    );
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    await _channel?.sink.close();
  }
}

double? _nullableNumber(
  Map<String, Object?> json,
  String key, [
  String? alternateKey,
]) {
  final value =
      ApiData.value(json, key) ??
      (alternateKey == null ? null : ApiData.value(json, alternateKey));
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
