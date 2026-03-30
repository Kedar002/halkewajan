import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Spacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppTheme {
  // Core palette — dark mode
  static const Color ink = Color(0xFFFFFFFF);
  static const Color canvas = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF111116);
  static const Color accent = Color(0xFF00E676);
  static const Color secondary = Color(0x80FFFFFF);
  static const Color divider = Color(0x1AFFFFFF);
  static const Color whisper = Color(0x0DFFFFFF);

  // Semantic data colors — charts and data badges ONLY
  static const Color calories = Color(0xFFFF9500);
  static const Color protein = Color(0xFFAF52DE);
  static const Color weight = Color(0xFF007AFF);
  static const Color fat = Color(0xFFFF2D55);
  static const Color carbs = Color(0xFF5AC8FA);

  // Gradient pairs for accent/data text
  static const List<Color> accentGradient = [
    Color(0xFF00E676),
    Color(0xFF00C853),
  ];
  static const List<Color> caloriesGradient = [
    Color(0xFFFFB74D),
    Color(0xFFFF9500),
  ];
  static const List<Color> weightGradient = [
    Color(0xFF42A5F5),
    Color(0xFF007AFF),
  ];
  static const List<Color> proteinGradient = [
    Color(0xFFC77DFF),
    Color(0xFFAF52DE),
  ];
  static const List<Color> fatGradient = [
    Color(0xFFFF6B6B),
    Color(0xFFFF2D55),
  ];
  static const List<Color> carbsGradient = [
    Color(0xFF7DD3FC),
    Color(0xFF5AC8FA),
  ];

  // Shadow tokens
  static const List<BoxShadow> shadowSm = [
    BoxShadow(color: Color(0x4D000000), blurRadius: 8, offset: Offset(0, 4)),
  ];
  static const List<BoxShadow> shadowMd = [
    BoxShadow(color: Color(0x66000000), blurRadius: 16, offset: Offset(0, 8)),
  ];
  static const List<BoxShadow> shadowLg = [
    BoxShadow(color: Color(0x80000000), blurRadius: 24, offset: Offset(0, 12)),
  ];

  // Animation tokens
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animMedium = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);
  static const Curve animCurve = Curves.easeOutCubic;

  // Radii
  static const double radiusCard = 24.0;
  static const double radiusControl = 12.0;
  static const BorderRadius borderRadiusCard =
      BorderRadius.all(Radius.circular(24));
  static const BorderRadius borderRadiusControl =
      BorderRadius.all(Radius.circular(12));
  static const BorderRadius borderRadiusPill =
      BorderRadius.all(Radius.circular(999));

  // Dark void gradient — deep tinted blacks
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment(-0.8, -1.0),
    end: Alignment(0.8, 1.0),
    colors: [
      Color(0xFF0A0A12), // deep blue-black
      Color(0xFF0D0E14), // slate void
      Color(0xFF0A0C10), // dark teal hint
      Color(0xFF08080D), // pure void
    ],
    stops: [0.0, 0.35, 0.65, 1.0],
  );

  static SystemUiOverlayStyle get systemOverlay => const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      );

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: canvas,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          onPrimary: canvas,
          secondary: secondary,
          surface: surface,
          onSurface: ink,
          error: fat,
          onError: canvas,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: ink,
            letterSpacing: -1.0,
            height: 1.1,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: ink,
            letterSpacing: -0.5,
            height: 1.15,
          ),
          displaySmall: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: ink,
            letterSpacing: -0.3,
            height: 1.2,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: ink,
            height: 1.3,
          ),
          titleMedium: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: ink,
            height: 1.3,
          ),
          titleSmall: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: ink,
            height: 1.3,
          ),
          bodyLarge: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w400,
            color: ink,
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: ink,
            height: 1.5,
          ),
          bodySmall: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Color(0x80FFFFFF),
            height: 1.4,
          ),
          labelLarge: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0x80FFFFFF),
            letterSpacing: 0.5,
          ),
          labelMedium: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0x66FFFFFF),
            letterSpacing: 1.2,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: surface,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadiusCard,
            side: BorderSide(color: divider, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: canvas,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: borderRadiusPill),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: ink,
            side: BorderSide(color: divider),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: borderRadiusPill),
          ),
        ),
        dividerTheme:
            DividerThemeData(color: divider, thickness: 1, space: 1),
        iconTheme: const IconThemeData(color: ink, size: 22),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: ink,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: ink,
          ),
        ),
      );
}
