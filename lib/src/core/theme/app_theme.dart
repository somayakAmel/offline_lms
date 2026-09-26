import 'package:flutter/material.dart';

/// Brand colours. Widgets read them through `Theme.of(context).colorScheme`.
class AppColors {
  AppColors._();

  static const Color lightPrimary = Color(0xFFB8E2F2);
  static const Color darkPrimary = Color(0xFF9DD9F3);

  /// Deep sea-blue used for text on the primary colour.
  static const Color ink = Color(0xFF0F2A36);

  /// Stronger blue for progress on light surfaces, where the pale primary
  /// would not stand out.
  static const Color lightProgress = Color(0xFF2B7896);

  /// Light-mode splash background.
  static const Color splashBackground = Color(0xFFF8FAF9);
}

class AppTheme {
  AppTheme._();

  static const String _fontFamily = 'ReadexPro';

  static final ThemeData light = _build(
    ColorScheme.fromSeed(
      seedColor: AppColors.lightPrimary,
    ).copyWith(
      primary: AppColors.lightPrimary,
      onPrimary: AppColors.ink,
      primaryContainer: AppColors.lightPrimary,
      onPrimaryContainer: AppColors.ink,
      secondary: AppColors.lightProgress,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFDCEEF5),
      onSecondaryContainer: AppColors.ink,
      surface: const Color(0xFFF5F8FA),
      onSurface: AppColors.ink,
      onSurfaceVariant: const Color(0xFF3D4F59),
      surfaceContainerLowest: Colors.white,
      surfaceContainerHighest: const Color(0xFFE6EDF0),
      outline: const Color(0xFFB7C4CB),
      outlineVariant: const Color(0xFFDCE4E8),
    ),
  );

  static final ThemeData dark = _build(
    ColorScheme.fromSeed(
      seedColor: AppColors.darkPrimary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.darkPrimary,
      onPrimary: const Color(0xFF062634),
      primaryContainer: const Color(0xFF17394A),
      onPrimaryContainer: const Color(0xFFD6F0FA),
      secondary: AppColors.darkPrimary,
      onSecondary: const Color(0xFF062634),
      secondaryContainer: const Color(0xFF22343D),
      onSecondaryContainer: const Color(0xFFD6F0FA),
      surface: const Color(0xFF0E1518),
      onSurface: const Color(0xFFE3ECF0),
      onSurfaceVariant: const Color(0xFFB6C6CE),
      surfaceContainerLowest: const Color(0xFF151E22),
      surfaceContainerHighest: const Color(0xFF22343D),
      outline: const Color(0xFF4A5B63),
      outlineVariant: const Color(0xFF263238),
    ),
  );

  static ThemeData _build(ColorScheme scheme) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: _fontFamily,
      scaffoldBackgroundColor: scheme.surface,
    );
    final text = base.textTheme;
    return base.copyWith(
      textTheme: text.copyWith(
        // Headings are bold and large; metadata is regular and small, so the
        // hierarchy reads at a glance.
        headlineSmall: text.headlineSmall
            ?.copyWith(fontSize: 28, fontWeight: FontWeight.w700, height: 1.3),
        titleLarge: text.titleLarge
            ?.copyWith(fontSize: 20, fontWeight: FontWeight.w700, height: 1.35),
        titleMedium: text.titleMedium
            ?.copyWith(fontSize: 17, fontWeight: FontWeight.w600, height: 1.4),
        bodyLarge: text.bodyLarge?.copyWith(fontSize: 16, height: 1.55),
        bodyMedium: text.bodyMedium?.copyWith(
          fontSize: 15,
          height: 1.55,
          color: scheme.onSurfaceVariant,
        ),
        bodySmall: text.bodySmall?.copyWith(
          fontSize: 13,
          height: 1.45,
          color: scheme.onSurfaceVariant,
        ),
        labelLarge: text.labelLarge
            ?.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
