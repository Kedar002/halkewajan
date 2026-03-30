import 'package:flutter/material.dart';

/// Premium background — wallpaper image that liquid glass refracts against.
class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image — fills entire screen
        Positioned.fill(
          child: Image.asset(
            'assets/images/bg.jpg',
            fit: BoxFit.cover,
          ),
        ),

        // Commented out: old gradient washes
        // Container(color: const Color(0xFF050B18)),
        // Positioned(top: -350, right: -300, width: 900, height: 900,
        //   child: _wash(const Color(0xFF0D7377), 0.35)),
        // Positioned(bottom: -350, left: -300, width: 950, height: 950,
        //   child: _wash(const Color(0xFF1A3A6B), 0.30)),
        // Positioned(top: 150, left: -250, width: 750, height: 750,
        //   child: _wash(const Color(0xFF2D1B69), 0.20)),

        // Content
        child,
      ],
    );
  }
}
