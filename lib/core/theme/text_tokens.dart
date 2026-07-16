import 'package:flutter/material.dart';

/// Typography token constants matching DESIGN.md typography definitions.
///
/// Font families are Plus Jakarta Sans and Inter (bundled as local assets).
/// Individual token doc comments reference DESIGN.md frontmatter for values.
abstract final class AppTextTheme {
  /// Display Large — Plus Jakarta Sans, 40px, w700, h48, ls -0.02em
  static const TextStyle displayLg = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.2, // 48/40 = 1.2
    letterSpacing: -0.8, // -0.02em * 40px
  );

  /// Headline Large — Plus Jakarta Sans, 32px, w700, h40, ls -0.02em
  static const TextStyle headlineLg = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25, // 40/32 = 1.25
    letterSpacing: -0.64, // -0.02em * 32px
  );

  /// Headline Large Mobile — Plus Jakarta Sans, 28px, w700, h34
  static const TextStyle headlineLgMobile = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.214, // 34/28 ≈ 1.214
  );

  /// Title Medium — Plus Jakarta Sans, 20px, w600, h28
  static const TextStyle titleMd = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4, // 28/20 = 1.4
  );

  /// Body Large — Plus Jakarta Sans, 16px, w400, h24
  static const TextStyle bodyLg = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5, // 24/16 = 1.5
  );

  /// Body Small — Plus Jakarta Sans, 14px, w400, h20
  static const TextStyle bodySm = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.429, // 20/14 ≈ 1.429
  );

  /// Label Caps — Inter, 12px, w600, h16, ls 0.05em, uppercase
  static const TextStyle labelCaps = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.333, // 16/12 ≈ 1.333
    letterSpacing: 0.6, // 0.05em * 12px
  );
}
