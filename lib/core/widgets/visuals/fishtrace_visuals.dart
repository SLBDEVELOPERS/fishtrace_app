import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:qr_flutter/qr_flutter.dart';

import '../../../app/theme/fishtrace_colors.dart';
import '../../../app/theme/fishtrace_dimensions.dart';
import '../cards/fishtrace_cards.dart';

class QRScannerFrame extends StatelessWidget {
  const QRScannerFrame({
    super.key,
    required this.child,
    this.instruction = 'Align QR code within the frame',
  });

  final Widget child;
  final String instruction;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(FishTraceRadii.card),
    child: Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(child: child),
        Positioned.fill(
          child: ColoredBox(color: Colors.black.withValues(alpha: .16)),
        ),
        SizedBox.square(
          dimension: 236,
          child: CustomPaint(painter: const _ScannerCornersPainter()),
        ),
        Positioned(
          top: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: .45),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              instruction,
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ),
        ),
      ],
    ),
  );
}

class _ScannerCornersPainter extends CustomPainter {
  const _ScannerCornersPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = FishTraceColors.aqua
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;
    const length = 34.0;
    final corners = [
      (Offset.zero, const Offset(length, 0), const Offset(0, length)),
      (
        Offset(size.width, 0),
        Offset(size.width - length, 0),
        Offset(size.width, length),
      ),
      (
        Offset(0, size.height),
        Offset(length, size.height),
        Offset(0, size.height - length),
      ),
      (
        Offset(size.width, size.height),
        Offset(size.width - length, size.height),
        Offset(size.width, size.height - length),
      ),
    ];
    for (final corner in corners) {
      canvas.drawLine(corner.$1, corner.$2, paint);
      canvas.drawLine(corner.$1, corner.$3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class QRCodeCard extends StatelessWidget {
  const QRCodeCard({
    super.key,
    required this.data,
    this.caption,
    this.size = 210,
    this.dark = false,
    this.onFullscreen,
  });

  final String data;
  final String? caption;
  final double size;
  final bool dark;
  final VoidCallback? onFullscreen;

  @override
  Widget build(BuildContext context) => FishTraceCard(
    color: dark ? FishTraceColors.navy : FishTraceColors.surface,
    borderColor: dark ? FishTraceColors.primary : FishTraceColors.border,
    child: Column(
      children: [
        InkWell(
          onTap: onFullscreen,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(FishTraceRadii.input),
            ),
            child: QrImageView(
              data: data,
              size: size,
              padding: EdgeInsets.zero,
              semanticsLabel: 'Traceability QR code for $data',
            ),
          ),
        ),
        if (caption != null) ...[
          const SizedBox(height: FishTraceSpacing.sm),
          Text(
            caption!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: dark ? Colors.white : FishTraceColors.textSecondary,
            ),
          ),
        ],
      ],
    ),
  );
}

class MapPreviewCard extends StatelessWidget {
  const MapPreviewCard({
    super.key,
    required this.center,
    this.route = const [],
    this.height = 150,
    this.caption,
    this.interactive = false,
  });

  final LatLng center;
  final List<LatLng> route;
  final double height;
  final String? caption;
  final bool interactive;

  @override
  Widget build(BuildContext context) => FishTraceCard(
    padding: EdgeInsets.zero,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: height,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(FishTraceRadii.card),
            ),
            child: FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: 10,
                interactionOptions: InteractionOptions(
                  flags: interactive
                      ? InteractiveFlag.all
                      : InteractiveFlag.none,
                ),
              ),
              children: [
                const _MapBackdropLayer(),
                if (route.length > 1)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: route,
                        color: FishTraceColors.primary,
                        strokeWidth: 3,
                        pattern: const StrokePattern.dotted(),
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: center,
                      width: 36,
                      height: 36,
                      child: const Icon(
                        Icons.location_on,
                        color: FishTraceColors.primary,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(FishTraceSpacing.sm),
          child: Text(
            caption ??
                '${center.latitude.toStringAsFixed(4)}° N, '
                    '${center.longitude.toStringAsFixed(4)}° E',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    ),
  );
}

class _MapBackdropLayer extends StatelessWidget {
  const _MapBackdropLayer();

  @override
  Widget build(BuildContext context) => Container(
    color: FishTraceColors.mapLand,
    child: CustomPaint(painter: _MapBackdropPainter()),
  );
}

class _MapBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final water = Path()
      ..moveTo(size.width * .48, 0)
      ..quadraticBezierTo(
        size.width * .63,
        size.height * .28,
        size.width * .55,
        size.height * .5,
      )
      ..quadraticBezierTo(
        size.width * .45,
        size.height * .74,
        size.width * .72,
        size.height,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(water, Paint()..color = FishTraceColors.mapWater);
    final road = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    for (var index = 0; index < 5; index++) {
      final y = size.height * (.14 + index * .18);
      canvas.drawLine(Offset(0, y), Offset(size.width * .58, y + 25), road);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ChartCard extends StatelessWidget {
  const ChartCard({
    super.key,
    required this.title,
    required this.values,
    this.unit = '',
    this.height = 150,
  });

  final String title;
  final List<double> values;
  final String unit;
  final double height;

  @override
  Widget build(BuildContext context) {
    final spots = [
      for (var index = 0; index < values.length; index++)
        FlSpot(index.toDouble(), values[index]),
    ];
    return FishTraceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              if (values.isNotEmpty)
                Text(
                  '${values.last.toStringAsFixed(1)}$unit',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: FishTraceColors.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: FishTraceSpacing.sm),
          SizedBox(
            height: height,
            child: values.length < 2
                ? const Center(child: Text('Not enough readings'))
                : LineChart(
                    LineChartData(
                      gridData: const FlGridData(
                        drawVerticalLine: false,
                        horizontalInterval: 1,
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: const FlTitlesData(
                        topTitles: AxisTitles(),
                        rightTitles: AxisTitles(),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22,
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: FishTraceColors.chartPrimary,
                          barWidth: 2.5,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: FishTraceColors.chartPrimary.withValues(
                              alpha: .1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
