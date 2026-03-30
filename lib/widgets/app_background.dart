import 'package:flutter/material.dart';

/// Premium ambient background — soft light sources in a dark void.
class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  static Widget _wash(Color color, double alpha) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: alpha),
              color.withValues(alpha: alpha * 0.55),
              color.withValues(alpha: alpha * 0.25),
              color.withValues(alpha: alpha * 0.08),
              color.withValues(alpha: alpha * 0.02),
              Colors.transparent,
            ],
            stops: const [0.0, 0.1, 0.25, 0.45, 0.7, 1.0],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Deep navy-black base
        Container(color: const Color(0xFF050B18)),

        // Teal wash — top-right, primary light source
        Positioned(
          top: -350,
          right: -300,
          width: 900,
          height: 900,
          child: _wash(const Color(0xFF0D7377), 0.35),
        ),

        // Blue wash — bottom-left, secondary light
        Positioned(
          bottom: -350,
          left: -300,
          width: 950,
          height: 950,
          child: _wash(const Color(0xFF1A3A6B), 0.30),
        ),

        // Purple accent — center-left, depth
        Positioned(
          top: 150,
          left: -250,
          width: 750,
          height: 750,
          child: _wash(const Color(0xFF2D1B69), 0.20),
        ),

        // Content
        child,
      ],
    );
  }
}
