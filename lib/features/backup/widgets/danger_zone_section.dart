import 'dart:async';

import 'package:co2diet/core/theme/color_tokens.dart';
import 'package:co2diet/core/theme/spacing_tokens.dart';
import 'package:co2diet/core/theme/text_tokens.dart';
import 'package:flutter/material.dart';

/// The exact confirmation word the typed field must match, case-sensitive
/// (05-CONTEXT.md's locked fixed-word decision, PRIV-09).
const _confirmationWord = 'DELETE';

/// Danger Zone section (PRIV-09): a full local-data wipe gated behind an
/// exact-match typed confirmation — the delete button stays disabled until
/// the field's text is exactly `'DELETE'`.
///
/// [onConfirmedDelete] is wired by `BackupRestoreScreen` to
/// `BackupExportService.clearAllLocalData()`. This widget never decides
/// *what* gets deleted — it only owns the typed-confirmation gate
/// (T-05-16-01's only mitigation).
class DangerZoneSection extends StatefulWidget {
  /// Creates a [DangerZoneSection] invoking [onConfirmedDelete] once the
  /// typed word is confirmed and the delete button is tapped.
  const DangerZoneSection({required this.onConfirmedDelete, super.key});

  /// Called when the user taps the (now-enabled) delete button. The
  /// caller performs the actual full local-data wipe.
  final Future<void> Function() onConfirmedDelete;

  @override
  State<DangerZoneSection> createState() => _DangerZoneSectionState();
}

class _DangerZoneSectionState extends State<DangerZoneSection> {
  final _controller = TextEditingController();
  bool _isDeleting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canDelete =>
      !_isDeleting && _controller.text == _confirmationWord;

  Future<void> _handleDelete() async {
    setState(() => _isDeleting = true);
    try {
      await widget.onConfirmedDelete();
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danger Zone',
          style: AppTextTheme.titleMd.copyWith(color: AppColors.error),
        ),
        const SizedBox(height: AppSpacing.stackGap),
        Text(
          'This permanently deletes every meal entry, favorite, custom '
          'food, weigh-in, and setting stored on this device. This '
          'cannot be undone. Type $_confirmationWord below to confirm.',
          style: AppTextTheme.bodySm.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.stackGap),
        TextField(
          controller: _controller,
          decoration: const InputDecoration(
            labelText: 'Type DELETE to confirm',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.stackGap),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onError,
            ),
            onPressed: _canDelete
                ? () => unawaited(_handleDelete())
                : null,
            child: _isDeleting
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Delete all local data'),
          ),
        ),
      ],
    );
  }
}
