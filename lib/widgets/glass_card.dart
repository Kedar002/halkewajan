import 'dart:ui';
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

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular(24);
    final accent = accentColor;

    return Container(
      // Shadows outside the clip
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
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: CustomPaint(
            foregroundPainter: _LiquidGlassPainter(
              radius: br,
              accent: accent,
            ),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
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

class _LiquidGlassPainter extends CustomPainter {
  final BorderRadius radius;
  final Color? accent;

  _LiquidGlassPainter({required this.radius, this.accent});

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

    // Inner luminosity — warm glow from top
    final glowRect = Rect.fromLTWH(0, 0, size.width, size.height * 0.5);
    final glowPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x14FFFFFF),
          Color(0x00FFFFFF),
        ],
      ).createShader(glowRect);
    canvas.drawRect(glowRect, glowPaint);

    // Secondary specular — bottom-right for depth
    final secRect = Rect.fromLTWH(
      size.width * 0.3, size.height * 0.5,
      size.width * 0.7, size.height * 0.5,
    );
    final secPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.bottomRight,
        radius: 0.8,
        colors: [
          Colors.white.withValues(alpha: 0.04),
          Colors.transparent,
        ],
      ).createShader(secRect);
    canvas.drawRect(secRect, secPaint);

    canvas.restore();

    // Directional rim border
    final borderPaint = Paint()
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
      ).createShader(rect);

    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  bool shouldRepaint(_LiquidGlassPainter old) => accent != old.accent;
}
