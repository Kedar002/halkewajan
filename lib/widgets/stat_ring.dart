import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatRing extends StatelessWidget {
  final double progress;
  final Color color;
  final String value;
  final String unit;
  final double size;
  final double strokeWidth;
  final Gradient? valueGradient;

  const StatRing({
    super.key,
    required this.progress,
    required this.color,
    required this.value,
    this.unit = '',
    this.size = 160,
    this.strokeWidth = 12,
    this.valueGradient,
  });

  @override
  Widget build(BuildContext context) {
    Widget valueWidget = Text(
      value,
      style: TextStyle(
        fontSize: size * 0.2,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: -1.0,
        height: 1.1,
      ),
    );

    if (valueGradient != null) {
      valueWidget = ShaderMask(
        shaderCallback: (bounds) => valueGradient!.createShader(
          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
        ),
        child: valueWidget,
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress.clamp(0.0, 1.0),
          color: color,
          strokeWidth: strokeWidth,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              valueWidget,
              if (unit.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    unit,
                    style: TextStyle(
                      fontSize: size * 0.08,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.5),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background track
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc with improved gradient
    if (progress > 0) {
      final sweepAngle = 2 * math.pi * progress;

      // Create lighter shade for gradient start
      final hsl = HSLColor.fromColor(color);
      final lighterColor = hsl
          .withLightness((hsl.lightness + 0.15).clamp(0.0, 1.0))
          .toColor();

      final gradient = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + sweepAngle,
        colors: [
          lighterColor,
          color,
          color,
        ],
        stops: const [0.0, 0.5, 1.0],
        transform: const GradientRotation(-math.pi / 2),
      );

      final progressPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        rect,
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );

      // Glow at the tip
      final tipAngle = -math.pi / 2 + sweepAngle;
      final tipX = center.dx + radius * math.cos(tipAngle);
      final tipY = center.dy + radius * math.sin(tipAngle);

      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(Offset(tipX, tipY), strokeWidth / 2, glowPaint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      progress != oldDelegate.progress || color != oldDelegate.color;
}

/// Concentric activity rings — Apple Watch style
class ActivityRings extends StatelessWidget {
  final double calorieProgress;
  final double proteinProgress;
  final double carbsProgress;
  final double fatProgress;
  final double size;

  const ActivityRings({
    super.key,
    required this.calorieProgress,
    required this.proteinProgress,
    required this.carbsProgress,
    required this.fatProgress,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ActivityRingsPainter(
          calorieProgress: calorieProgress.clamp(0.0, 1.0),
          proteinProgress: proteinProgress.clamp(0.0, 1.0),
          carbsProgress: carbsProgress.clamp(0.0, 1.0),
          fatProgress: fatProgress.clamp(0.0, 1.0),
        ),
      ),
    );
  }
}

class _ActivityRingsPainter extends CustomPainter {
  final double calorieProgress;
  final double proteinProgress;
  final double carbsProgress;
  final double fatProgress;

  _ActivityRingsPainter({
    required this.calorieProgress,
    required this.proteinProgress,
    required this.carbsProgress,
    required this.fatProgress,
  });

  void _drawRing(Canvas canvas, Offset center, double radius, double progress,
      Color color, double strokeWidth) {
    // Background track
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    if (progress <= 0) return;

    final sweepAngle = 2 * math.pi * progress;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Improved gradient — lighter start
    final hsl = HSLColor.fromColor(color);
    final lighterColor = hsl
        .withLightness((hsl.lightness + 0.15).clamp(0.0, 1.0))
        .toColor();

    final gradient = SweepGradient(
      colors: [
        lighterColor.withValues(alpha: 0.7),
        color,
        color,
      ],
      stops: const [0.0, 0.4, 1.0],
      transform: const GradientRotation(-math.pi / 2),
    );

    final arcPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, arcPaint);

    // Tip glow
    final tipAngle = -math.pi / 2 + sweepAngle;
    final tipX = center.dx + radius * math.cos(tipAngle);
    final tipY = center.dy + radius * math.sin(tipAngle);
    canvas.drawCircle(
      Offset(tipX, tipY),
      strokeWidth * 0.4,
      Paint()
        ..color = color.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 10.0;
    const gap = 14.0;

    final outerR = (size.width - strokeWidth) / 2;

    _drawRing(canvas, center, outerR, calorieProgress, AppTheme.calories, strokeWidth);
    _drawRing(canvas, center, outerR - gap, proteinProgress, AppTheme.protein, strokeWidth);
    _drawRing(canvas, center, outerR - gap * 2, carbsProgress, AppTheme.carbs, strokeWidth);
    _drawRing(canvas, center, outerR - gap * 3, fatProgress, AppTheme.fat, strokeWidth);
  }

  @override
  bool shouldRepaint(_ActivityRingsPainter old) =>
      calorieProgress != old.calorieProgress ||
      proteinProgress != old.proteinProgress ||
      carbsProgress != old.carbsProgress ||
      fatProgress != old.fatProgress;
}
