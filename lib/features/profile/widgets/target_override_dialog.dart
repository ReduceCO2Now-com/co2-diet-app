import 'package:flutter/material.dart';

/// What the user chose in [TargetOverrideDialog].
///
/// A `null` result from `showDialog` means dismissed without choosing (back
/// button or barrier tap) — deliberately distinct from
/// [TargetOverrideResult.reset], which is an explicit "go back to the
/// calculated value".
class TargetOverrideResult {
  /// The user entered a value and tapped Save.
  ///
  /// [value] is null when the text could not be parsed as a number.
  const TargetOverrideResult.save(this.value) : isReset = false;

  /// The user asked to clear the override and return to the calculated value.
  const TargetOverrideResult.reset() : value = null, isReset = true;

  /// The entered target, or null when input was unparseable or this is a reset.
  final double? value;

  /// Whether the user asked to clear the override.
  final bool isReset;
}

/// The "Set custom target" dialog for a Daily Targets card.
///
/// A `StatefulWidget` specifically so it owns its [TextEditingController] and
/// disposes it in [State.dispose], which Flutter calls once this element is
/// genuinely unmounted — after the route's exit transition has finished.
///
/// **This ownership is the fix for a real crash, not a style preference.**
/// The controller previously lived in `ProfileScreen._showOverrideDialog` and
/// was disposed on the line after `await showDialog(...)`. That await
/// completes when the route is *popped*, not when it is *gone*, so the
/// controller was destroyed while the dialog was still animating out and its
/// `TextFormField` was still rebuilding. On device that threw:
///
/// ```text
/// A TextEditingController was used after being disposed.
///   The relevant error-causing widget was: TextFormField
/// ...cascading into: '_dependents.isEmpty': is not true
/// ```
///
/// and took the app down on every completed dialog. The `_dependents`
/// assertion is second-order, which is why three investigations chasing it
/// never reached the cause. See
/// `.planning/debug/profile-daily-targets-crash.md`.
///
/// If this is ever refactored back into a caller-owned controller, the crash
/// returns.
class TargetOverrideDialog extends StatefulWidget {
  /// Creates a [TargetOverrideDialog].
  const TargetOverrideDialog({this.initialValue, super.key});

  /// Current target, pre-filled into the field. Null shows an empty field.
  final double? initialValue;

  @override
  State<TargetOverrideDialog> createState() => _TargetOverrideDialogState();
}

class _TargetOverrideDialogState extends State<TargetOverrideDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue?.toStringAsFixed(0) ?? '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set custom target'),
      content: TextFormField(
        controller: _controller,
        keyboardType: TextInputType.number,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Value'),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(const TargetOverrideResult.reset()),
          child: const Text('Reset to calculated'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            TargetOverrideResult.save(double.tryParse(_controller.text)),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
