import 'package:co2diet/core/theme/color_tokens.dart';
import 'package:co2diet/core/theme/text_tokens.dart';
import 'package:flutter/material.dart';

/// Displays an em dash (—) when a computed target value is null.
///
/// Per D-07: no fake precision or population-average fallbacks — show
/// [MissingTargetDash] whenever a required anthropometric input is absent.
class MissingTargetDash extends StatelessWidget {
  /// Creates a [MissingTargetDash].
  ///
  /// Optionally accepts a [tooltip] string for accessibility.
  const MissingTargetDash({this.tooltip, super.key});

  /// Optional tooltip shown on long-press.
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      '—',
      style: AppTextTheme.titleMd.copyWith(
        color: AppColors.onSurfaceVariant,
      ),
    );
    if (tooltip != null) {
      return Tooltip(message: tooltip, child: text);
    }
    return text;
  }
}
