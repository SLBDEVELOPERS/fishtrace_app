import 'package:dio/dio.dart';
import 'package:fishtrace/features/fisher/data/repositories/open_meteo_marine_weather_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'uses sea cells and falls back to the first populated hourly row',
    () async {
      late RequestOptions captured;
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              captured = options;
              handler.resolve(
                Response(
                  requestOptions: options,
                  data: {
                    'current': {
                      'time': '2026-08-12T09:00',
                      'wave_height': null,
                      'wave_direction': null,
                    },
                    'hourly': {
                      'time': ['2026-08-12T09:00', '2026-08-12T10:00'],
                      'wave_height': [null, 1.4],
                      'wave_direction': [null, 225],
                      'wave_period': [null, 7.2],
                      'sea_surface_temperature': [null, 28.6],
                    },
                  },
                ),
              );
            },
          ),
        );
      final repository = OpenMeteoMarineWeatherRepository(dio: dio);

      final weather = await repository.getCurrent(
        latitude: 6.9271,
        longitude: 79.8612,
      );

      expect(captured.queryParameters['cell_selection'], 'sea');
      expect(captured.queryParameters['forecast_hours'], 12);
      expect(weather.waveHeight, 1.4);
      expect(weather.waveDirection, 225);
      expect(weather.wavePeriod, 7.2);
      expect(weather.seaSurfaceTemperature, 28.6);
    },
  );
}
