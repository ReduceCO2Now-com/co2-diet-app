import 'package:co2diet/core/theme/spacing_tokens.dart';
import 'package:co2diet/core/theme/text_tokens.dart';
import 'package:co2diet/features/legal/widgets/consent_checkbox_tile.dart';
import 'package:flutter/material.dart';

/// Minimum passphrase length enforced by [PassphrasePromptDialog.showCreate]
/// — length-first per NIST SP 800-63B, no other composition rules. A
/// strength meter is deliberately not shown (08-RESEARCH.md: "UI theatre").
const kMinPassphraseLength = 10;

/// Exact unrecoverability warning shown above the confirm button on the
/// create-mode dialog, before an encrypted backup is ever created.
const _unrecoverabilityWarning =
    "Only you can unlock this backup. We can't reset it, and neither can "
    "the server — it only ever holds bytes it can't read. If you lose "
    'this passphrase, this backup is gone.';

/// Exact confirmation-checkbox label, mirroring LEGAL-01's established
/// separate-unchecked-checkbox pattern.
const _confirmationCheckboxLabel =
    "I understand this backup can't be recovered without this passphrase.";

/// A `showDialog<String>`-based passphrase prompt with two entry points:
/// [showCreate] (set a new passphrase, with a mandatory unrecoverability
/// warning) and [showEnter] (enter an existing passphrase to decrypt a
/// restore). Both return the entered passphrase, or `null` if the user
/// cancelled.
class PassphrasePromptDialog extends StatefulWidget {
  const PassphrasePromptDialog._({required this.isCreateMode, this.errorText});

  /// Whether this is the create-mode (passphrase + confirm + warning +
  /// checkbox) or enter-mode (single field) dialog.
  final bool isCreateMode;

  /// Enter-mode only: an inline error shown above the field, e.g. after a
  /// failed restore attempt.
  final String? errorText;

  /// Shows the create-mode dialog: passphrase + confirm fields, the
  /// unrecoverability warning, and a mandatory confirmation checkbox.
  /// Returns the entered passphrase once both fields match, are at least
  /// [kMinPassphraseLength] characters, and the checkbox is checked -- or
  /// `null` if the user cancelled.
  static Future<String?> showCreate(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (_) => const PassphrasePromptDialog._(isCreateMode: true),
    );
  }

  /// Shows the enter-mode dialog: a single passphrase field, with an
  /// optional inline [errorText] for a wrong-passphrase retry. Returns the
  /// entered passphrase once non-empty, or `null` if the user cancelled.
  static Future<String?> showEnter(BuildContext context, {String? errorText}) {
    return showDialog<String>(
      context: context,
      builder: (_) => PassphrasePromptDialog._(
        isCreateMode: false,
        errorText: errorText,
      ),
    );
  }

  @override
  State<PassphrasePromptDialog> createState() =>
      _PassphrasePromptDialogState();
}

class _PassphrasePromptDialogState extends State<PassphrasePromptDialog> {
  final _passphraseController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _confirmed = false;

  @override
  void initState() {
    super.initState();
    _passphraseController.addListener(_onChanged);
    _confirmController.addListener(_onChanged);
  }

  @override
  void dispose() {
    _passphraseController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  bool get _createModeCanSubmit =>
      _passphraseController.text.length >= kMinPassphraseLength &&
      _passphraseController.text == _confirmController.text &&
      _confirmed;

  bool get _enterModeCanSubmit => _passphraseController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (widget.isCreateMode) {
      return AlertDialog(
        title: const Text('Encrypt this backup'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _passphraseController,
                obscureText: true,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Passphrase'),
              ),
              const SizedBox(height: AppSpacing.stackGap),
              TextField(
                controller: _confirmController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm passphrase',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                _unrecoverabilityWarning,
                style: AppTextTheme.bodySm.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.stackGap),
              ConsentCheckboxTile(
                value: _confirmed,
                onChanged: (value) =>
                    setState(() => _confirmed = value ?? false),
                label: _confirmationCheckboxLabel,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: _createModeCanSubmit
                ? () => Navigator.of(context).pop(_passphraseController.text)
                : null,
            child: const Text('Encrypt'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: const Text('Enter passphrase'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.errorText != null) ...[
            Text(
              widget.errorText!,
              style: AppTextTheme.bodySm.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: AppSpacing.stackGap),
          ],
          TextField(
            controller: _passphraseController,
            obscureText: true,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Passphrase'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _enterModeCanSubmit
              ? () => Navigator.of(context).pop(_passphraseController.text)
              : null,
          child: const Text('Unlock'),
        ),
      ],
    );
  }
}
