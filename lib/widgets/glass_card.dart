import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final BorderRadius? borderRadius;
  final Color? accentColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius,
    this.accentColor,
  });

  /// Rec. 709 saturation matrix — boosts blurred backdrop vibrancy.
  static List<double> _saturationMatrix(double s) {
    const lumR = 0.299;
    const lumG = 0.587;
    const lumB = 0.114;
    final inv = 1.0 - s;
    return [
      lumR * inv + s, lumG * inv,     lumB * inv,     0, 0,
      lumR * inv,     lumG * inv + s, lumB * inv,     0, 0,
      lumR * inv,     lumG * inv,     lumB * inv + s, 0, 0,
      0,              0,              0,              1, 0,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular(24);
    final accent = accentColor;

    // Saturation boost + gaussian blur (from FakeGlass)
    final combinedFilter = ui.ImageFilter.compose(
      inner: ui.ColorFilter.matrix(_saturationMatrix(1.4)),
      outer: ui.ImageFilter.blur(
        sigmaX: 25,
        sigmaY: 25,
        tileMode: TileMode.mirror,
      ),
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: br,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 40,
            spreadRadius: -8,
            offset: const Offset(0, 20),
          ),
          if (accent != null)
            BoxShadow(
              color: accent.withValues(alpha: 0.06),
              blurRadius: 30,
              spreadRadius: -10,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: br,
        child: BackdropFilter(
          filter: combinedFilter,
          child: CustomPaint(
            foregroundPainter: _GlassPainter(radius: br, accent: accent),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                // Warm radial specular highlight
                gradient: RadialGradient(
                  center: const Alignment(-0.5, -0.8),
                  radius: 1.8,
                  colors: accent != null
                      ? [
                          accent.withValues(alpha: 0.12),
                          accent.withValues(alpha: 0.03),
                          Colors.white.withValues(alpha: 0.01),
                        ]
                      : [
                          const Color(0xFFFFFAF5).withValues(alpha: 0.10),
                          Colors.white.withValues(alpha: 0.03),
                          Colors.white.withValues(alpha: 0.01),
                        ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Inner glow + secondary highlight + directional border.
class _GlassPainter extends CustomPainter {
  final BorderRadius radius;
  final Color? accent;

  _GlassPainter({required this.radius, this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndCorners(
      rect,
      topLeft: radius.topLeft,
      topRight: radius.topRight,
      bottomLeft: radius.bottomLeft,
      bottomRight: radius.bottomRight,
    );

    canvas.save();
    canvas.clipRRect(rrect);

    // Inner glow from top
    final glowRect = Rect.fromLTWH(0, 0, size.width, size.height * 0.5);
    canvas.drawRect(
      glowRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x14FFFFFF), Color(0x00FFFFFF)],
        ).createShader(glowRect),
    );

    // Secondary highlight bottom-right
    final secRect = Rect.fromLTWH(
      size.width * 0.3, size.height * 0.5,
      size.width * 0.7, size.height * 0.5,
    );
    canvas.drawRect(
      secRect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.bottomRight,
          radius: 0.8,
          colors: [
            Colors.white.withValues(alpha: 0.04),
            Colors.transparent,
          ],
        ).createShader(secRect),
    );

    canvas.restore();

    // Directional border
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: accent != null
              ? [
                  accent!.withValues(alpha: 0.20),
                  accent!.withValues(alpha: 0.10),
                  accent!.withValues(alpha: 0.03),
                  Colors.white.withValues(alpha: 0.01),
                ]
              : [
                  Colors.white.withValues(alpha: 0.14),
                  Colors.white.withValues(alpha: 0.08),
                  Colors.white.withValues(alpha: 0.03),
                  Colors.white.withValues(alpha: 0.01),
                ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_GlassPainter old) => accent != old.accent;
}
