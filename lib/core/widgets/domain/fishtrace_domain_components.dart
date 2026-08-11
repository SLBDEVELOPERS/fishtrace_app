import 'package:flutter/material.dart';

import '../../../app/theme/fishtrace_colors.dart';
import '../../../app/theme/fishtrace_dimensions.dart';
import '../cards/fishtrace_cards.dart';

class TimelineEntry {
  const TimelineEntry({
    required this.title,
    required this.subtitle,
    this.trailing,
    this.completed = true,
    this.icon,
  });

  final String title;
  final String subtitle;
  final String? trailing;
  final bool completed;
  final IconData? icon;
}

class Timeline extends StatelessWidget {
  const Timeline({super.key, required this.entries});

  final List<TimelineEntry> entries;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var index = 0; index < entries.length; index++)
        _TimelineRow(
          entry: entries[index],
          isFirst: index == 0,
          isLast: index == entries.length - 1,
        ),
    ],
  );
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.entry,
    required this.isFirst,
    required this.isLast,
  });

  final TimelineEntry entry;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 28,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: 2,
                  color: isFirst ? Colors.transparent : FishTraceColors.primary,
                ),
              ),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: entry.completed
                      ? FishTraceColors.primary
                      : FishTraceColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: FishTraceColors.primary),
                ),
                child: Icon(
                  entry.icon ??
                      (entry.completed ? Icons.check : Icons.more_horiz),
                  size: 13,
                  color: entry.completed
                      ? Colors.white
                      : FishTraceColors.primary,
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: isLast ? Colors.transparent : FishTraceColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        entry.subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (entry.trailing != null)
                  Text(
                    entry.trailing!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class TemperatureCard extends StatelessWidget {
  const TemperatureCard({
    super.key,
    required this.current,
    this.minimum,
    this.maximum,
    this.label = 'Product temperature',
    this.normal = true,
    this.onTap,
  });

  final double current;
  final double? minimum;
  final double? maximum;
  final String label;
  final bool normal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => FishTraceCard(
    onTap: onTap,
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (normal ? FishTraceColors.info : FishTraceColors.error)
                .withValues(alpha: .1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.thermostat,
            color: normal ? FishTraceColors.info : FishTraceColors.error,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              Text(
                '${current.toStringAsFixed(1)}°C',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (minimum != null || maximum != null)
                Text(
                  'Range ${minimum?.toStringAsFixed(1) ?? '—'} – '
                  '${maximum?.toStringAsFixed(1) ?? '—'}°C',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
        StatusChip(
          label: normal ? 'Normal' : 'Alert',
          color: normal ? FishTraceColors.success : FishTraceColors.error,
        ),
      ],
    ),
  );
}

class SensorMetricCard extends StatelessWidget {
  const SensorMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.status = 'Normal',
    this.color = FishTraceColors.primary,
    this.sparkline = const [],
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final String status;
  final Color color;
  final List<double> sparkline;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => FishTraceCard(
    onTap: onTap,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 3),
        Text(
          '● $status',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
        ),
        if (sparkline.isNotEmpty) ...[
          const SizedBox(height: 6),
          SizedBox(
            height: 24,
            width: double.infinity,
            child: CustomPaint(painter: _SparklinePainter(sparkline, color)),
          ),
        ],
      ],
    ),
  );
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter(this.values, this.color);
  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue == 0 ? 1 : maxValue - minValue;
    final path = Path();
    for (var index = 0; index < values.length; index++) {
      final x = size.width * index / (values.length - 1);
      final y =
          size.height - ((values[index] - minValue) / range * size.height);
      index == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}

class FishBatchCard extends StatelessWidget {
  const FishBatchCard({
    super.key,
    required this.batchId,
    required this.species,
    required this.weight,
    required this.status,
    this.subtitle,
    this.temperature,
    this.onTap,
  });

  final String batchId;
  final String species;
  final String weight;
  final String status;
  final String? subtitle;
  final String? temperature;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => _TraceabilityRecordCard(
    icon: Icons.set_meal_outlined,
    title: batchId,
    subtitle: '$species${subtitle == null ? '' : ' • $subtitle'}',
    value: weight,
    status: status,
    supporting: temperature,
    onTap: onTap,
  );
}

class CatchCard extends StatelessWidget {
  const CatchCard({
    super.key,
    required this.species,
    required this.weight,
    required this.metadata,
    required this.status,
    this.onTap,
  });

  final String species;
  final String weight;
  final String metadata;
  final String status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => _TraceabilityRecordCard(
    icon: Icons.set_meal,
    title: species,
    subtitle: metadata,
    value: weight,
    status: status,
    onTap: onTap,
  );
}

class TripCard extends StatelessWidget {
  const TripCard({
    super.key,
    required this.tripId,
    required this.origin,
    required this.destination,
    required this.status,
    this.details = const {},
    this.onTap,
  });

  final String tripId;
  final String origin;
  final String destination;
  final String status;
  final Map<String, String> details;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => FishTraceCard(
    onTap: onTap,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                tripId,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            StatusChip(label: status, color: _statusColor(status)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Flexible(child: Text(origin)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 7),
              child: Icon(Icons.arrow_forward, size: 15),
            ),
            Expanded(child: Text(destination)),
          ],
        ),
        if (details.isNotEmpty) ...[
          const Divider(height: 18),
          Row(
            children: [
              for (final detail in details.entries)
                Expanded(
                  child: _MiniDetail(label: detail.key, value: detail.value),
                ),
            ],
          ),
        ],
      ],
    ),
  );
}

class VehicleCard extends StatelessWidget {
  const VehicleCard({
    super.key,
    required this.registration,
    required this.vehicleType,
    required this.status,
    this.temperature,
    this.onTap,
    this.trailing,
  });

  final String registration;
  final String vehicleType;
  final String status;
  final String? temperature;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => _AssetCard(
    icon: Icons.local_shipping_outlined,
    title: registration,
    subtitle: vehicleType,
    status: status,
    supporting: temperature,
    onTap: onTap,
    trailing: trailing,
  );
}

class DeviceCard extends StatelessWidget {
  const DeviceCard({
    super.key,
    required this.deviceId,
    required this.deviceType,
    required this.status,
    this.battery,
    this.selected = false,
    this.onTap,
  });

  final String deviceId;
  final String deviceType;
  final String status;
  final int? battery;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => _AssetCard(
    icon: Icons.sensors,
    title: deviceId,
    subtitle: deviceType,
    status: status,
    supporting: battery == null ? null : 'Battery $battery%',
    borderColor: selected ? FishTraceColors.primary : FishTraceColors.border,
    onTap: onTap,
    trailing: Radio<bool>(
      value: true,
      groupValue: selected,
      onChanged: onTap == null ? null : (_) => onTap!(),
    ),
  );
}

class InventoryProductCard extends StatelessWidget {
  const InventoryProductCard({
    super.key,
    required this.name,
    required this.scientificName,
    required this.stock,
    required this.expiry,
    required this.status,
    this.category = 'Fish',
    this.onTap,
  });

  final String name;
  final String scientificName;
  final String stock;
  final String expiry;
  final String status;
  final String category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => FishTraceCard(
    onTap: onTap,
    child: Row(
      children: [
        Container(
          width: 58,
          height: 48,
          decoration: BoxDecoration(
            color: FishTraceColors.infoSurface,
            borderRadius: BorderRadius.circular(FishTraceRadii.input),
          ),
          child: Icon(
            category == 'Shellfish' ? Icons.set_meal_outlined : Icons.water,
            color: FishTraceColors.primary,
            size: 29,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: Theme.of(context).textTheme.titleSmall),
              Text(
                scientificName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 3),
              Text(stock, style: Theme.of(context).textTheme.labelLarge),
              Text(
                'Expiry: $expiry',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        StatusChip(label: status, color: _statusColor(status)),
      ],
    ),
  );
}

class _TraceabilityRecordCard extends StatelessWidget {
  const _TraceabilityRecordCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.status,
    this.supporting,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final String status;
  final String? supporting;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => FishTraceCard(
    onTap: onTap,
    child: Row(
      children: [
        Container(
          width: 48,
          height: 44,
          decoration: BoxDecoration(
            color: FishTraceColors.infoSurface,
            borderRadius: BorderRadius.circular(FishTraceRadii.input),
          ),
          child: Icon(icon, color: FishTraceColors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (supporting != null)
                Text(supporting!, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(value, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 5),
            StatusChip(label: status, color: _statusColor(status)),
          ],
        ),
      ],
    ),
  );
}

class _AssetCard extends StatelessWidget {
  const _AssetCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    this.supporting,
    this.borderColor = FishTraceColors.border,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final String? supporting;
  final Color borderColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => FishTraceCard(
    onTap: onTap,
    borderColor: borderColor,
    child: Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: FishTraceColors.infoSurface,
            borderRadius: BorderRadius.circular(FishTraceRadii.input),
          ),
          child: Icon(icon, color: FishTraceColors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              if (supporting != null)
                Text(supporting!, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        if (trailing != null)
          trailing!
        else
          StatusChip(label: status, color: _statusColor(status)),
      ],
    ),
  );
}

class _MiniDetail extends StatelessWidget {
  const _MiniDetail({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.bodySmall),
      Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelLarge,
      ),
    ],
  );
}

Color _statusColor(String status) {
  final normalized = status.toLowerCase();
  if (normalized.contains('quarant') ||
      normalized.contains('reject') ||
      normalized.contains('alert') ||
      normalized.contains('offline')) {
    return FishTraceColors.error;
  }
  if (normalized.contains('low') ||
      normalized.contains('warn') ||
      normalized.contains('upcoming') ||
      normalized.contains('inactive')) {
    return FishTraceColors.warning;
  }
  if (normalized.contains('progress') ||
      normalized.contains('assigned') ||
      normalized.contains('info')) {
    return FishTraceColors.info;
  }
  return FishTraceColors.success;
}
