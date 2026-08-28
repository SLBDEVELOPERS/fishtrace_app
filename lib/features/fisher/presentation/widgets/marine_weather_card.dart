import 'package:flutter/material.dart';

import '../../../../app/theme/fishtrace_colors.dart';
import '../../../../app/theme/fishtrace_dimensions.dart';
import '../../../../core/widgets/fishtrace_widgets.dart';
import '../../../../core/utils/fishtrace_time.dart';
import '../controllers/fisher_controller.dart';
import '../../../common/presentation/controllers/mobile_settings_controller.dart';
import '../../../common/presentation/formatters/measurement_formatter.dart';
import 'package:get/get.dart';

class MarineWeatherCard extends StatelessWidget {
  const MarineWeatherCard({required this.controller, super.key});

  final FisherController controller;

  @override
  Widget build(BuildContext context) {
    final weather = controller.marineWeather.value;
    final settings = Get.find<MobileSettingsController>().settings.value;

    if (controller.weatherLoading.value) {
      return const FishTraceCard(
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: FishTraceSpacing.sm),
            Text('Loading live marine forecast...'),
          ],
        ),
      );
    }

    if (weather == null) {
      final hasLocation =
          controller.weatherLatitude != null &&
          controller.weatherLongitude != null;
      return FishTraceCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              color: FishTraceColors.warning,
            ),
            const SizedBox(width: FishTraceSpacing.sm),
            Expanded(
              child: Text(
                hasLocation
                    ? 'Live marine weather is unavailable. Check your connection and an official forecast before departure.'
                    : controller.locationMessage.value ??
                          'Current location is unavailable. Enable location access to view marine weather.',
              ),
            ),
            IconButton(
              tooltip: hasLocation ? 'Retry forecast' : 'Retry location',
              onPressed: controller.loadMarineWeather,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
      );
    }

    return FishTraceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: FishTraceSpacing.lg,
            runSpacing: FishTraceSpacing.md,
            children: [
              _WeatherValue(
                icon: Icons.waves,
                label: 'Wave height',
                value: _value(weather.waveHeight, 'm'),
              ),
              _WeatherValue(
                icon: Icons.explore_outlined,
                label: 'Direction',
                value: weather.waveDirection == null
                    ? '--'
                    : '${weather.waveDirection!.round()}° ${_compass(weather.waveDirection!)}',
              ),
              _WeatherValue(
                icon: Icons.timer_outlined,
                label: 'Wave period',
                value: _value(weather.wavePeriod, 's'),
              ),
              _WeatherValue(
                icon: Icons.thermostat_outlined,
                label: 'Sea temperature',
                value: weather.seaSurfaceTemperature == null
                    ? '--'
                    : MeasurementFormatter.temperature(
                        weather.seaSurfaceTemperature!,
                        settings,
                      ),
              ),
            ],
          ),
          const SizedBox(height: FishTraceSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Updated ${FishTraceTime.format(weather.observedAt, 'MMM d, hh:mm a')} · ${controller.activeTrip.value == null ? 'Current location' : 'Trip location'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              IconButton(
                tooltip: 'Refresh forecast',
                onPressed: controller.loadMarineWeather,
                icon: const Icon(Icons.refresh, size: 20),
              ),
            ],
          ),
          Text(
            'For safety-critical decisions, confirm with an official marine forecast.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: FishTraceColors.warning),
          ),
        ],
      ),
    );
  }

  static String _value(double? value, String unit) =>
      value == null ? '--' : '${value.toStringAsFixed(1)} $unit';

  static String _compass(double degrees) {
    const points = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    return points[((degrees % 360) / 45).round() % points.length];
  }
}

class _WeatherValue extends StatelessWidget {
  const _WeatherValue({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 130,
    child: Row(
      children: [
        Icon(icon, size: 22, color: FishTraceColors.primary),
        const SizedBox(width: FishTraceSpacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              Text(value, style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
        ),
      ],
    ),
  );
}
