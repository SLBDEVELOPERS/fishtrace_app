import '../../domain/entities/mobile_settings.dart';

abstract final class MeasurementFormatter {
  static String weight(
    double kilograms,
    MobileSettings settings, {
    int decimals = 1,
  }) {
    if (settings.measurementSystem == MeasurementSystem.imperial) {
      return '${(kilograms * 2.2046226218).toStringAsFixed(decimals)} lb';
    }
    return '${kilograms.toStringAsFixed(decimals)} kg';
  }

  static String distance(
    double kilometres,
    MobileSettings settings, {
    int decimals = 1,
  }) {
    if (settings.measurementSystem == MeasurementSystem.imperial) {
      return '${(kilometres * 0.6213711922).toStringAsFixed(decimals)} mi';
    }
    return '${kilometres.toStringAsFixed(decimals)} km';
  }

  static String temperature(
    double celsius,
    MobileSettings settings, {
    int decimals = 1,
  }) {
    if (settings.measurementSystem == MeasurementSystem.imperial) {
      return '${(celsius * 9 / 5 + 32).toStringAsFixed(decimals)}°F';
    }
    return '${celsius.toStringAsFixed(decimals)}°C';
  }
}
