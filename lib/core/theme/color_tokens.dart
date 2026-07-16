// Token files have many const Color members. Doc-comments would add noise;
// the DESIGN.md frontmatter is the source of truth for all hex values.
// ignore_for_file: public_member_api_docs
import 'package:flutter/material.dart';

/// All DESIGN.md color tokens as const [Color] values.
///
/// Hex values are verbatim from the DESIGN.md frontmatter
/// (Eco-Minimalist Wellness palette). Individual token comments below
/// are omitted in favour of the DESIGN.md source of truth.
abstract final class AppColors {
  // Surface family
  static const Color surface = Color(0xFFF9F9FC);
  static const Color surfaceDim = Color(0xFFDADADC);
  static const Color surfaceBright = Color(0xFFF9F9FC);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F3F6);
  static const Color surfaceContainer = Color(0xFFEEEEF0);
  static const Color surfaceContainerHigh = Color(0xFFE8E8EA);
  static const Color surfaceContainerHighest = Color(0xFFE2E2E5);
  static const Color onSurface = Color(0xFF1A1C1E);
  static const Color onSurfaceVariant = Color(0xFF3F493F);
  static const Color inverseSurface = Color(0xFF2F3133);
  static const Color inverseOnSurface = Color(0xFFF0F0F3);
  static const Color outline = Color(0xFF6F7A6E);
  static const Color outlineVariant = Color(0xFFBECABC);
  static const Color surfaceTint = Color(0xFF016D2F);

  // Primary
  static const Color primary = Color(0xFF005222);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF006D2F);
  static const Color onPrimaryContainer = Color(0xFF90EC9F);
  static const Color inversePrimary = Color(0xFF7FDA8F);
  static const Color primaryFixed = Color(0xFF9BF7A9);
  static const Color primaryFixedDim = Color(0xFF7FDA8F);
  static const Color onPrimaryFixed = Color(0xFF002109);
  static const Color onPrimaryFixedVariant = Color(0xFF005322);

  // Secondary
  static const Color secondary = Color(0xFF0155C7);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF336FE2);
  static const Color onSecondaryContainer = Color(0xFFFEFCFF);
  static const Color secondaryFixed = Color(0xFFD9E2FF);
  static const Color secondaryFixedDim = Color(0xFFB0C6FF);
  static const Color onSecondaryFixed = Color(0xFF001945);
  static const Color onSecondaryFixedVariant = Color(0xFF00419C);

  // Tertiary
  static const Color tertiary = Color(0xFF00512D);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF006C3D);
  static const Color onTertiaryContainer = Color(0xFF91EAAF);
  static const Color tertiaryFixed = Color(0xFF9CF6BA);
  static const Color tertiaryFixedDim = Color(0xFF80D99F);
  static const Color onTertiaryFixed = Color(0xFF00210F);
  static const Color onTertiaryFixedVariant = Color(0xFF00522D);

  // Error
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Background (alias for surface per DESIGN.md)
  static const Color background = Color(0xFFF9F9FC);
  static const Color onBackground = Color(0xFF1A1C1E);

  // Surface variant (alias for surfaceContainerHighest)
  static const Color surfaceVariant = Color(0xFFE2E2E5);

  // Brand extras
  static const Color leafGreen = Color(0xFF2EB85C);
  static const Color softMint = Color(0xFF4BB477);
  static const Color skyBlue = Color(0xFF316FE2);
  static const Color surfaceLowest = Color(0xFFFFFFFF);
}
