import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double blur;
  final BorderRadius? borderRadius;
  final Color? accentColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.blur = 30.0,
    this.borderRadius,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(24);
    final accent = accentColor;

    return Container(
      // Shadow layer — outside the clip so shadows are visible
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          // Contact shadow — soft grounding
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          // Ambient shadow — floating depth
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 40,
            spreadRadius: -8,
            offset: const Offset(0, 20),
          ),
          // Warm ambient glow — makes the card feel alive
          BoxShadow(
            color: (accent ?? const Color(0xFFFFF8F0)).withValues(alpha: 0.03),
            blurRadius: 20,
            spreadRadius: -5,
          ),
          // Accent color spill
          if (accent != null)
            BoxShadow(
              color: accent.withValues(alpha: 0.06),
              blurRadius: 30,
              spreadRadius: -10,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          // Higher blur = smoother, more diffuse frosting
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: CustomPaint(
            foregroundPainter: _LiquidGlassPainter(
              radius: radius,
              accent: accent,
            ),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                // Warm-tinted radial specular — not pure white
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
                          // Warm white specular — slight amber warmth
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

/// Paints the liquid glass surface treatment: inner luminosity,
/// secondary depth highlight, and directional rim border.
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

    // 1. Inner luminosity — warm glow from top, extending deep
    final glowRect = Rect.fromLTWH(0, 0, size.width, size.height * 0.5);
    final glowPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x14FFFFFF), // white ~8%
          Color(0x00FFFFFF), // transparent
        ],
      ).createShader(glowRect);
    canvas.drawRect(glowRect, glowPaint);

    // 2. Secondary specular — subtle bottom-right for 3D volume
    final secondaryRect = Rect.fromLTWH(
      size.width * 0.3,
      size.height * 0.5,
      size.width * 0.7,
      size.height * 0.5,
    );
    final secondaryPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.bottomRight,
        radius: 0.8,
        colors: [
          Colors.white.withValues(alpha: 0.04),
          Colors.transparent,
        ],
      ).createShader(secondaryRect);
    canvas.drawRect(secondaryRect, secondaryPaint);

    canvas.restore();

    // 3. Directional rim border — softer, wider, luminous gradient
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
