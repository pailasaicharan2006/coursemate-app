import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Atom Orbit logo widget:
/// - Central purple nucleus with subtle radial gradient.
/// - Three intersecting elliptical orbital rings with purple/cyan gradients.
/// - Cyan/teal particle sparkles on orbital nodes.
/// - Scalable custom painter, no raster pixelation, no robot face, no text.
class AtomOrbitAvatar extends StatelessWidget {
  final double size;
  final Color? backgroundColor;

  const AtomOrbitAvatar({
    super.key,
    this.size = 36,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? const Color(0xFF1B1834),
        border: Border.all(
          color: const Color(0xFF6C63FF).withAlpha(120),
          width: math.max(1.0, size * 0.035),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withAlpha(60),
            blurRadius: size * 0.25,
            spreadRadius: size * 0.02,
          ),
        ],
      ),
      child: ClipOval(
        child: CustomPaint(
          size: Size(size, size),
          painter: const _AtomOrbitPainter(),
        ),
      ),
    );
  }
}

class _AtomOrbitPainter extends CustomPainter {
  const _AtomOrbitPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = math.max(1.2, size.width * 0.04);

    // 1. Central Nucleus with radial gradient
    final nucleusRadius = size.width * 0.16;
    final nucleusPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFFB388FF), // Bright lavender core
          Color(0xFF6C63FF), // Deep purple
          Color(0xFF4A3FD4), // Shadow rim
        ],
        stops: [0.0, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: nucleusRadius));
    canvas.drawCircle(center, nucleusRadius, nucleusPaint);

    // Nucleus highlight pip
    final highlightPaint = Paint()
      ..color = Colors.white.withAlpha(200)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      center - Offset(nucleusRadius * 0.35, nucleusRadius * 0.35),
      math.max(1.0, nucleusRadius * 0.22),
      highlightPaint,
    );

    // 2. Orbital Rings
    final orbitA = size.width * 0.40;
    final orbitB = size.height * 0.16;

    final ringAngles = [-35.0, 35.0, 90.0];
    final ringColors = [
      [const Color(0xFF6C63FF), const Color(0xFF00E5FF)],
      [const Color(0xFF8A7BFF), const Color(0xFF4FC3F7)],
      [const Color(0xFFB388FF), const Color(0xFF00E5FF)],
    ];

    for (int i = 0; i < 3; i++) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(ringAngles[i] * math.pi / 180);

      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: orbitA * 2,
        height: orbitB * 2,
      );

      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..shader = LinearGradient(
          colors: ringColors[i],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect);

      canvas.drawOval(rect, ringPaint);
      canvas.restore();
    }

    // 3. Orbiting Cyan Particles / Sparkles
    // Particle 1 on Ring 1 (angle -35°, at t = 0.85 rad)
    const p1Angle = -35.0 * math.pi / 180;
    const t1 = 0.85;
    final p1LocalX = orbitA * math.cos(t1);
    final p1LocalY = orbitB * math.sin(t1);
    final p1X = center.dx + p1LocalX * math.cos(p1Angle) - p1LocalY * math.sin(p1Angle);
    final p1Y = center.dy + p1LocalX * math.sin(p1Angle) + p1LocalY * math.cos(p1Angle);

    final p1Radius = math.max(1.8, size.width * 0.055);
    final particle1Paint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(p1X, p1Y), p1Radius, particle1Paint);

    final particle1Core = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(p1X, p1Y), p1Radius * 0.5, particle1Core);

    // Particle 2: Small sparkle on Ring 2
    const p2Angle = 35.0 * math.pi / 180;
    const t2 = 3.6;
    final p2LocalX = orbitA * math.cos(t2);
    final p2LocalY = orbitB * math.sin(t2);
    final p2X = center.dx + p2LocalX * math.cos(p2Angle) - p2LocalY * math.sin(p2Angle);
    final p2Y = center.dy + p2LocalX * math.sin(p2Angle) + p2LocalY * math.cos(p2Angle);

    final p2Radius = math.max(1.2, size.width * 0.038);
    final particle2Paint = Paint()
      ..color = const Color(0xFF4FC3F7)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(p2X, p2Y), p2Radius, particle2Paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
