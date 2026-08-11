import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/fishtrace_colors.dart';

class FishTraceMark extends StatelessWidget {
  const FishTraceMark({super.key, this.size = 42, this.onDark = false});

  final double size;
  final bool onDark;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'FishTrace',
    image: true,
    child: SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _FishTraceMarkPainter(onDark: onDark)),
    ),
  );
}

class FishTraceWordmark extends StatelessWidget {
  const FishTraceWordmark({
    super.key,
    this.compact = false,
    this.onDark = false,
  });

  final bool compact;
  final bool onDark;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      FishTraceMark(size: compact ? 32 : 44, onDark: onDark),
      const SizedBox(width: 8),
      Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Fish',
              style: TextStyle(
                color: onDark ? Colors.white : FishTraceColors.navy,
              ),
            ),
            const TextSpan(
              text: 'Trace',
              style: TextStyle(color: FishTraceColors.cyan),
            ),
          ],
        ),
        style: TextStyle(
          fontSize: compact ? 22 : 28,
          height: 1,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
}

class _FishTraceMarkPainter extends CustomPainter {
  const _FishTraceMarkPainter({required this.onDark});

  final bool onDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * .43;
    final arcPaint = Paint()
      ..color = onDark ? Colors.white : FishTraceColors.primary
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.shortestSide * .08;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * .25,
      math.pi * 1.38,
      false,
      arcPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 1.78,
      math.pi * .23,
      false,
      arcPaint..color = FishTraceColors.cyan,
    );

    final fishPaint = Paint()
      ..color = onDark ? FishTraceColors.aqua : FishTraceColors.primary;
    final fishBody = Rect.fromCenter(
      center: Offset(size.width * .54, size.height * .52),
      width: size.width * .48,
      height: size.height * .22,
    );
    canvas.drawOval(fishBody, fishPaint);
    final tail = Path()
      ..moveTo(size.width * .31, size.height * .52)
      ..lineTo(size.width * .16, size.height * .36)
      ..lineTo(size.width * .18, size.height * .66)
      ..close();
    canvas.drawPath(tail, fishPaint);
    canvas.drawCircle(
      Offset(size.width * .68, size.height * .48),
      size.width * .025,
      Paint()..color = FishTraceColors.surface,
    );
  }

  @override
  bool shouldRepaint(covariant _FishTraceMarkPainter oldDelegate) =>
      oldDelegate.onDark != onDark;
}
