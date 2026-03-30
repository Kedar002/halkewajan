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
  // Core palette
  static const Color ink = Color(0xFF1D1D1F);
  static const Color canvas = Color(0xFFF8F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color accent = Color(0xFF34C759);
  static const Color secondary = Color(0x801D1D1F);
  static const Color divider = Color(0x1A1D1D1F);
  static const Color whisper = Color(0x0D1D1D1F);

  // Semantic data colors — charts and data badges ONLY
  static const Color calories = Color(0xFFFF9500);
  static const Color protein = Color(0xFFAF52DE);
  static const Color weight = Color(0xFF007AFF);
  static const Color fat = Color(0xFFFF2D55);
  static const Color carbs = Color(0xFF5AC8FA);

  // Radii
  static const double radiusCard = 24.0;
  static const double radiusControl = 12.0;
  static const BorderRadius borderRadiusCard =
      BorderRadius.all(Radius.circular(24));
  static const BorderRadius borderRadiusControl =
      BorderRadius.all(Radius.circular(12));
  static const BorderRadius borderRadiusPill =
      BorderRadius.all(Radius.circular(999));

  // The living gradient background — soft color orbs behind glass
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment(-0.8, -1.0),
    end: Alignment(0.8, 1.0),
    colors: [
      Color(0xFFF2F0F7), // lavender whisper
      Color(0xFFEDF5F0), // mint whisper
      Color(0xFFF5F0EC), // peach whisper
      Color(0xFFEEF1F7), // sky whisper
    ],
    stops: [0.0, 0.35, 0.65, 1.0],
  );

  static SystemUiOverlayStyle get systemOverlay => const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      );

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: canvas,
        colorScheme: const ColorScheme.light(
          primary: accent,
          onPrimary: surface,
          secondary: secondary,
          surface: surface,
          onSurface: ink,
          error: fat,
          onError: surface,
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
            color: secondary,
            height: 1.4,
          ),
          labelLarge: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: secondary,
            letterSpacing: 0.5,
          ),
          labelMedium: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: secondary,
            letterSpacing: 0.8,
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
            foregroundColor: surface,
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
