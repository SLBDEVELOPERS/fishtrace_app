import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/fishtrace_colors.dart';

class OceanBackground extends StatelessWidget {
  const OceanBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          FishTraceColors.navy,
          FishTraceColors.ocean,
          Color(0xFF00566A),
        ],
      ),
    ),
    child: CustomPaint(painter: const _OceanPainter(), child: child),
  );
}

class _OceanPainter extends CustomPainter {
  const _OceanPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final wave = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: .07);
    for (var row = 0; row < 7; row++) {
      final y = size.height * (.08 + row * .075);
      final path = Path()..moveTo(0, y);
      for (double x = 0; x <= size.width; x += 12) {
        path.lineTo(x, y + math.sin((x / size.width * math.pi * 4) + row) * 5);
      }
      canvas.drawPath(path, wave);
    }

    final fish = Paint()..color = Colors.white.withValues(alpha: .09);
    for (var i = 0; i < 13; i++) {
      final x = size.width * (.08 + (i % 5) * .2);
      final y = size.height * (.58 + (i % 4) * .07);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 32, height: 11),
        fish,
      );
      final tail = Path()
        ..moveTo(x - 15, y)
        ..lineTo(x - 25, y - 8)
        ..lineTo(x - 24, y + 8)
        ..close();
      canvas.drawPath(tail, fish);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
