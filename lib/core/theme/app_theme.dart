// ColorScheme constructors have white defaults for on-colors. We explicitly
// set them to AppColors tokens so the mapping is auditable against DESIGN.md.
// ignore_for_file: avoid_redundant_argument_values
import 'package:co2diet/core/theme/color_tokens.dart';
import 'package:co2diet/core/theme/text_tokens.dart';
import 'package:flutter/material.dart';

/// Builds the Material 3 light [ThemeData] from DESIGN.md color tokens.
ThemeData buildLightTheme() {
  return ThemeData(
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      inversePrimary: AppColors.inversePrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      inverseSurface: AppColors.inverseSurface,
      onInverseSurface: AppColors.inverseOnSurface,
      surfaceTint: AppColors.surfaceTint,
      surfaceContainerLowest: AppColors.surfaceContainerLowest,
      surfaceContainerLow: AppColors.surfaceContainerLow,
      surfaceContainer: AppColors.surfaceContainer,
      surfaceContainerHigh: AppColors.surfaceContainerHigh,
      surfaceContainerHighest: AppColors.surfaceContainerHighest,
    ),
    fontFamily: 'Plus Jakarta Sans',
    textTheme: _buildTextTheme(),
    cardTheme: const CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
  );
}

/// Builds the Material 3 dark [ThemeData] using M3 inverse-surface conventions.
///
/// DESIGN.md defines a single light-mode color set. For dark mode, we apply
/// Material 3 inverse-surface semantics: [AppColors.inverseSurface] becomes the
/// primary canvas, [AppColors.inverseOnSurface] becomes the primary on-surface
/// text color, and [AppColors.inversePrimary] becomes the primary accent.
ThemeData buildDarkTheme() {
  return ThemeData(
    colorScheme: const ColorScheme.dark(
      primary: AppColors.inversePrimary,
      onPrimary: AppColors.onPrimaryFixed,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      inversePrimary: AppColors.primary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.inverseSurface,
      onSurface: AppColors.inverseOnSurface,
      onSurfaceVariant: AppColors.outlineVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.onSurfaceVariant,
      inverseSurface: AppColors.surface,
      onInverseSurface: AppColors.onSurface,
      surfaceTint: AppColors.inversePrimary,
      surfaceContainerLowest: Color(0xFF1A1C1E),
      surfaceContainerLow: Color(0xFF222426),
      surfaceContainer: Color(0xFF2A2C2E),
      surfaceContainerHigh: Color(0xFF323436),
      surfaceContainerHighest: Color(0xFF3A3C3E),
    ),
    fontFamily: 'Plus Jakarta Sans',
    textTheme: _buildTextTheme(),
    cardTheme: const CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.inversePrimary, width: 2),
      ),
    ),
  );
}

/// Maps DESIGN.md typography tokens to Material [TextTheme] slots.
TextTheme _buildTextTheme() {
  return const TextTheme(
    displayLarge: AppTextTheme.displayLg,
    headlineLarge: AppTextTheme.headlineLg,
    headlineMedium: AppTextTheme.headlineLgMobile,
    titleMedium: AppTextTheme.titleMd,
    bodyLarge: AppTextTheme.bodyLg,
    bodyMedium: AppTextTheme.bodySm,
    labelSmall: AppTextTheme.labelCaps,
  );
}
