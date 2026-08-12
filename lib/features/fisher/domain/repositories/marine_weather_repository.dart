import '../entities/fisher_entities.dart';

abstract interface class MarineWeatherRepository {
  Future<MarineWeather> getCurrent({
    required double latitude,
    required double longitude,
  });
}
