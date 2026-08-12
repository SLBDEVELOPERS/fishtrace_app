import 'package:dio/dio.dart';

import '../../../../core/errors/app_exceptions.dart';
import '../../domain/entities/fisher_entities.dart';
import '../../domain/repositories/marine_weather_repository.dart';

class OpenMeteoMarineWeatherRepository implements MarineWeatherRepository {
  OpenMeteoMarineWeatherRepository({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://marine-api.open-meteo.com',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
              headers: const {'Accept': 'application/json'},
            ),
          );

  final Dio _dio;

  @override
  Future<MarineWeather> getCurrent({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/v1/marine',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'current': [
            'wave_height',
            'wave_direction',
            'wave_period',
            'sea_surface_temperature',
          ].join(','),
          'hourly': [
            'wave_height',
            'wave_direction',
            'wave_period',
            'sea_surface_temperature',
          ].join(','),
          'forecast_hours': 12,
          'cell_selection': 'sea',
          'timezone': 'Asia/Colombo',
        },
      );

      print(response);

      final current = response.data?['current'];
      final currentValues = current is Map
          ? current.cast<String, dynamic>()
          : const <String, dynamic>{};
      MarineWeather? weather = _weatherFrom(currentValues);
      if (!_hasValues(weather)) {
        weather = _firstHourlyWeather(response.data?['hourly']);
      }
      if (weather == null || !_hasValues(weather)) {
        throw const ApiException(
          'No marine forecast is available near this location.',
        );
      }
      return weather;
    } on DioException catch (error) {
      if (error.response != null) {
        throw const ApiException('Marine forecast is currently unavailable.');
      }
      throw const NetworkException('Unable to connect to marine weather.');
    }
  }

  static double? _number(Object? value) =>
      value is num ? value.toDouble() : null;

  static MarineWeather _weatherFrom(Map<String, dynamic> values) =>
      MarineWeather(
        observedAt:
            DateTime.tryParse(values['time']?.toString() ?? '') ??
            DateTime.now(),
        waveHeight: _number(values['wave_height']),
        waveDirection: _number(values['wave_direction']),
        wavePeriod: _number(values['wave_period']),
        seaSurfaceTemperature: _number(values['sea_surface_temperature']),
      );

  static MarineWeather? _firstHourlyWeather(Object? raw) {
    if (raw is! Map) return null;
    final hourly = raw.cast<String, dynamic>();
    final times = hourly['time'];
    if (times is! List) return null;
    for (var index = 0; index < times.length; index++) {
      Object? at(String key) {
        final values = hourly[key];
        return values is List && index < values.length ? values[index] : null;
      }

      final weather = MarineWeather(
        observedAt:
            DateTime.tryParse(times[index]?.toString() ?? '') ?? DateTime.now(),
        waveHeight: _number(at('wave_height')),
        waveDirection: _number(at('wave_direction')),
        wavePeriod: _number(at('wave_period')),
        seaSurfaceTemperature: _number(at('sea_surface_temperature')),
      );
      if (_hasValues(weather)) return weather;
    }
    return null;
  }

  static bool _hasValues(MarineWeather? weather) =>
      weather != null &&
      (weather.waveHeight != null ||
          weather.waveDirection != null ||
          weather.wavePeriod != null ||
          weather.seaSurfaceTemperature != null);
}
