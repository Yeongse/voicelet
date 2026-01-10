import 'package:flutter/material.dart';

/// Voicelet アプリテーマ
/// デザインガイド「夜のささやき」に基づく
class AppTheme {
  AppTheme._();

  // === ベースカラー（夜空） ===
  static const Color bgPrimary = Color(0xFF1A1625);
  static const Color bgSecondary = Color(0xFF241F31);
  static const Color bgTertiary = Color(0xFF2D2640);
  static const Color bgElevated = Color(0xFF362F4A);

  // === アクセントカラー（葉・光） ===
  static const Color accentPrimary = Color(0xFF7ECFB3);
  static const Color accentSecondary = Color(0xFF9EE7D1);
  static const Color accentTertiary = Color(0xFF5FB89A);

  // === ライトパーティクル ===
  static const Color particleWarm = Color(0xFFF5D78E);
  static const Color particleCool = Color(0xFFA8D4F0);
  static const Color particlePink = Color(0xFFE8B4D6);

  // === テキストカラー ===
  static const Color textPrimary = Color(0xFFF0EEF5);
  static const Color textSecondary = Color(0xFFB8B3C7);
  static const Color textTertiary = Color(0xFF7D7891);
  static const Color textInverse = Color(0xFF1A1625);

  // === セマンティックカラー ===
  static const Color success = Color(0xFF7ECFB3);
  static const Color warning = Color(0xFFF5D78E);
  static const Color error = Color(0xFFE88B8B);
  static const Color errorDark = Color(0xFFD46A6A);
  static const Color info = Color(0xFFA8D4F0);

  // === 角丸 ===
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radius2xl = 32.0;
  static const double radiusFull = 9999.0;

  // === スペーシング ===
  static const double space1 = 4.0;
  static const double space2 = 8.0;
  static const double space3 = 12.0;
  static const double space4 = 16.0;
  static const double space5 = 20.0;
  static const double space6 = 24.0;
  static const double space8 = 32.0;
  static const double space10 = 40.0;
  static const double space12 = 48.0;
  static const double space16 = 64.0;

  // === アニメーション ===
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 400);
  static const Curve curveDefault = Curves.easeOutCubic;
  static const Curve curveBounce = Curves.elasticOut;

  // === シャドウ ===
  static List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get shadowLg => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.25),
          blurRadius: 32,
          offset: const Offset(0, 8),
        ),
      ];

  // === グロー ===
  static List<BoxShadow> get glowAccent => [
        BoxShadow(
          color: accentPrimary.withValues(alpha: 0.3),
          blurRadius: 20,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get glowRecording => [
        BoxShadow(
          color: error.withValues(alpha: 0.4),
          blurRadius: 30,
          spreadRadius: 0,
        ),
      ];

  // === グラデーション ===
  static const LinearGradient gradientBgMain = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgPrimary, bgSecondary, bgPrimary],
  );

  static const LinearGradient gradientAccent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentPrimary, accentTertiary],
  );

  static const LinearGradient gradientRecording = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [error, errorDark],
  );

  /// アプリ全体のThemeData
  static ThemeData get themeData => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bgPrimary,
        colorScheme: const ColorScheme.dark(
          primary: accentPrimary,
          secondary: accentSecondary,
          surface: bgSecondary,
          error: error,
          onPrimary: textInverse,
          onSecondary: textInverse,
          onSurface: textPrimary,
          onError: textInverse,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          iconTheme: IconThemeData(color: textSecondary),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          displayMedium: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          displaySmall: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          headlineMedium: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: textPrimary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: textSecondary,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            color: textTertiary,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
        ),
        useMaterial3: true,
      );
}
