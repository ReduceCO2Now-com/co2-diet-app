import 'package:co2diet/core/theme/spacing_tokens.dart';
import 'package:co2diet/core/theme/text_tokens.dart';
import 'package:flutter/material.dart';

/// A single consent checkbox row: a [Checkbox] merged with its [label]
/// text into one screen-reader-discoverable semantics node (ACC-03),
/// plus an optional [trailingLink] (e.g. a "View Terms" button) that
/// stays independently tappable and navigable before the box is checked
/// (LEGAL-04).
///
/// Used exclusively by the Legal Consent screen — every checkbox on that
/// screen starts unchecked ([value] is owned by the parent, never
/// defaulted here) per PITFALLS.md C5's hard "no pre-checked boxes"
/// requirement.
class ConsentCheckboxTile extends StatelessWidget {
  /// Creates a [ConsentCheckboxTile].
  const ConsentCheckboxTile({
    required this.value,
    required this.onChanged,
    required this.label,
    this.trailingLink,
    super.key,
  });

  /// Whether this checkbox is currently checked. Owned by the parent —
  /// this widget never initializes or mutates it directly.
  final bool value;

  /// Called with the new checkbox value when the user taps it.
  final ValueChanged<bool?> onChanged;

  /// The row's label text, announced by screen readers alongside the
  /// checked state as a single merged semantics node.
  final String label;

  /// An optional inline link widget (e.g. `TextButton('View Terms')`)
  /// rendered after the label, outside the merged checkbox semantics so
  /// it stays independently focusable/tappable.
  final Widget? trailingLink;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      // ACC-05: minimum 44x44pt tappable row area.
      constraints: const BoxConstraints(minHeight: 44),
      child: Row(
        children: [
          Expanded(
            child: MergeSemantics(
              child: Row(
                children: [
                  Checkbox(value: value, onChanged: onChanged),
                  const SizedBox(width: AppSpacing.base),
                  Expanded(
                    child: Text(
                      label,
                      style: AppTextTheme.bodyLg.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ?trailingLink,
        ],
      ),
    );
  }
}
