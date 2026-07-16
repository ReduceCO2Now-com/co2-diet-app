/// Spacing token constants matching DESIGN.md spacing definitions.
///
/// Based on a base-4 scale. Individual token doc comments omitted —
/// see DESIGN.md frontmatter for source.
abstract final class AppSpacing {
  /// 4px — base unit
  static const double base = 4;

  /// 8px
  static const double xs = 8;

  /// 16px
  static const double sm = 16;

  /// 24px
  static const double md = 24;

  /// 32px
  static const double lg = 32;

  /// 48px
  static const double xl = 48;

  /// 20px — mobile container margin
  static const double containerMargin = 20;

  /// 12px — vertical stack gap
  static const double stackGap = 12;
}
