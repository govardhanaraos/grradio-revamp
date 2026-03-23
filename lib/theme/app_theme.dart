import 'package:flutter/material.dart';

/// Single source of truth for app typography, [ColorScheme], and [ThemeData].
///
/// Edit [buildBaseTextTheme], [light] / [dark] [ColorScheme], or brand colors
/// here so the whole app updates together.
class AppTheme {
  AppTheme._();

  static const String fontFamily = 'Outfit';

  /// Primary brand — deep violet (use for CTAs, active states).
  static const Color brandViolet = Color(0xFF7C4DFF);
  static const Color brandBlue = Color(0xFF448AFF);

  /// “Royal” accent — warm gold for highlights, badges, premium hints (tertiary in [ColorScheme]).
  static const Color royalGold = Color(0xFFC9A227);
  static const Color royalGoldLight = Color(0xFFE8D48A);

  static const Color _lightOnSurface = Color(0xFF121212);
  static const Color _darkOnSurface = Color(0xFFE8E8E8);

  /// Base [TextTheme] before applying light/dark [bodyColor] / [displayColor].
  static TextTheme buildBaseTextTheme() {
    return const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
      displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
    ).apply(fontFamily: fontFamily);
  }

  static ThemeData light() {
    final base = buildBaseTextTheme();
    final cs = ColorScheme.light(
      primary: brandViolet,
      onPrimary: Colors.white,
      secondary: brandBlue,
      onSecondary: Colors.white,
      tertiary: royalGold,
      onTertiary: Color(0xFF1A1408),
      error: Colors.redAccent,
      onError: Colors.white,
      surface: Colors.white,
      onSurface: _lightOnSurface,
      onSurfaceVariant: Color(0xFF5C5F67),
      surfaceContainerHighest: Color(0xFFF0EEFF),
      outline: Color(0xFFE4E0F0),
      outlineVariant: Color(0xFFCDC8D8),
    );

    return ThemeData(
      fontFamily: fontFamily,
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: brandViolet,
      scaffoldBackgroundColor: const Color(0xFFF7F6FC),
      colorScheme: cs,
      dividerColor: cs.outline.withValues(alpha: 0.35),
      textTheme: base.apply(
        bodyColor: cs.onSurface,
        displayColor: cs.onSurface,
      ),
      primaryTextTheme: base.apply(
        bodyColor: cs.onSurface,
        displayColor: cs.onSurface,
      ),
      iconTheme: IconThemeData(color: cs.onSurface, size: 24),
      listTileTheme: ListTileThemeData(
        iconColor: cs.onSurfaceVariant,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w800,
          fontSize: 16,
          color: cs.onSurface,
        ),
        subtitleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w800,
          fontSize: 12,
          color: cs.onSurfaceVariant,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        hintStyle: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: cs.onSurfaceVariant.withValues(alpha: 0.75),
        ),
        labelStyle: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w600,
          color: cs.onSurfaceVariant,
        ),
        border: InputBorder.none,
      ),
      snackBarTheme: SnackBarThemeData(
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w800,
          fontSize: 14,
          color: Colors.white,
        ),
        backgroundColor: cs.inverseSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        iconTheme: IconThemeData(color: cs.onSurface),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: cs.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w900,
        ),
        toolbarTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: cs.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cs.surface,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w800,
          fontSize: 20,
          color: cs.onSurface,
        ),
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: cs.onSurfaceVariant,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  static ThemeData dark() {
    final base = buildBaseTextTheme();
    final cs = ColorScheme.dark(
      primary: brandViolet,
      onPrimary: Colors.white,
      secondary: brandBlue,
      onSecondary: Colors.white,
      tertiary: royalGoldLight,
      onTertiary: Color(0xFF1A1408),
      error: Colors.redAccent,
      onError: Colors.white,
      surface: Color(0xFF121212),
      onSurface: _darkOnSurface,
      onSurfaceVariant: Color(0xFF9E9EAE),
      surfaceContainerHighest: Color(0xFF2A2A38),
      outline: Color(0xFF4A4A58),
      outlineVariant: Color(0xFF3A3A48),
    );

    return ThemeData(
      fontFamily: fontFamily,
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: brandViolet,
      scaffoldBackgroundColor: cs.surface,
      cardColor: const Color(0xFF1E1E1E),
      colorScheme: cs,
      dividerColor: cs.outline.withValues(alpha: 0.35),
      textTheme: base.apply(
        bodyColor: cs.onSurface,
        displayColor: Colors.white,
      ),
      primaryTextTheme: base.apply(
        bodyColor: cs.onSurface,
        displayColor: Colors.white,
      ),
      iconTheme: IconThemeData(color: cs.onSurface, size: 24),
      listTileTheme: ListTileThemeData(
        iconColor: cs.onSurfaceVariant,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w800,
          fontSize: 16,
          color: cs.onSurface,
        ),
        subtitleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w800,
          fontSize: 12,
          color: cs.onSurfaceVariant,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        hintStyle: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: cs.onSurfaceVariant.withValues(alpha: 0.85),
        ),
        labelStyle: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w600,
          color: cs.onSurfaceVariant,
        ),
        border: InputBorder.none,
      ),
      snackBarTheme: SnackBarThemeData(
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w800,
          fontSize: 14,
          color: Colors.white,
        ),
        backgroundColor: cs.inverseSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: cs.onSurface),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: cs.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w900,
        ),
        toolbarTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: cs.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w800,
          fontSize: 20,
          color: cs.onSurface,
        ),
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: cs.onSurfaceVariant,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
