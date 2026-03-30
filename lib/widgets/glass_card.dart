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
    this.blur = 20.0,
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
          // Contact shadow — grounds the card
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
          // Ambient shadow — floating-in-space depth
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 40,
            spreadRadius: -5,
            offset: const Offset(0, 16),
          ),
          // Accent glow — color spill from content
          if (accent != null)
            BoxShadow(
              color: accent.withValues(alpha: 0.08),
              blurRadius: 30,
              spreadRadius: -10,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: CustomPaint(
            foregroundPainter: _LiquidGlassPainter(
              radius: radius,
              accent: accent,
            ),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                // Radial specular highlight — concentrated bright spot
                gradient: RadialGradient(
                  center: const Alignment(-0.5, -0.7),
                  radius: 1.5,
                  colors: accent != null
                      ? [
                          accent.withValues(alpha: 0.14),
                          accent.withValues(alpha: 0.04),
                          Colors.white.withValues(alpha: 0.02),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.12),
                          Colors.white.withValues(alpha: 0.04),
                          Colors.white.withValues(alpha: 0.02),
                        ],
                  stops: const [0.0, 0.5, 1.0],
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

/// Draws the directional border and inner glow on top of the glass surface.
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

    // 1. Inner top glow — light refracting along the top edge
    canvas.save();
    canvas.clipRRect(rrect);
    final glowRect = Rect.fromLTWH(0, 0, size.width, size.height * 0.4);
    final glowPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x0FFFFFFF), // white ~6%
          Color(0x00FFFFFF), // transparent
        ],
      ).createShader(glowRect);
    canvas.drawRect(glowRect, glowPaint);
    canvas.restore();

    // 2. Directional border — brighter top-left, fading bottom-right
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: accent != null
            ? [
                accent!.withValues(alpha: 0.25),
                accent!.withValues(alpha: 0.08),
                Colors.white.withValues(alpha: 0.02),
              ]
            : [
                Colors.white.withValues(alpha: 0.15),
                Colors.white.withValues(alpha: 0.06),
                Colors.white.withValues(alpha: 0.02),
              ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(rect);

    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  bool shouldRepaint(_LiquidGlassPainter old) => accent != old.accent;
}
