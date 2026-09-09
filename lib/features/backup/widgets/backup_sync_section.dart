import 'dart:async';

import 'package:co2diet/core/di/backup_providers.dart';
import 'package:co2diet/core/theme/spacing_tokens.dart';
import 'package:co2diet/core/theme/text_tokens.dart';
import 'package:co2diet/data/repositories/food_catalog_repository.dart'
    show NetworkException;
import 'package:co2diet/domain/entities/auth_state.dart';
import 'package:co2diet/domain/services/backup_export_service.dart'
    show WrongBackupPassphraseException;
import 'package:co2diet/features/auth/providers/auth_provider.dart';
import 'package:co2diet/features/backup/providers/backup_sync_notifier.dart';
import 'package:co2diet/features/backup/widgets/passphrase_prompt_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pitfall-7 retry copy, reused verbatim from `BackupRestoreScreen`'s local
/// restore path -- an AEAD tag failure cannot distinguish a wrong
/// passphrase from a damaged file.
const _wrongPassphraseErrorText =
    "That passphrase didn't work. Either it's not the right one, or this "
    'backup file is damaged.';

/// The "Cloud Backup (Beta)" section of `BackupRestoreScreen` (Plan 08-03,
/// AUTH-09) -- push/pull the same encrypted-with-your-passphrase archive
/// Plan 08-01 builds locally, to/from the backend.
///
/// Hidden entirely (`SizedBox.shrink`) unless [backupSyncEnabledProvider]
/// is `true` AND the user is in Account Mode (`authProvider` is
/// `AuthAuthenticated`) -- never a disabled/greyed-out row (mirrors
/// `AccountSection`'s `realmDiscoveryReadyProvider` gating precedent, per
/// 08-RESEARCH.md Pattern 5).
class BackupSyncSection extends ConsumerWidget {
  /// Creates the [BackupSyncSection].
  const BackupSyncSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(backupSyncEnabledProvider);
    final authState = ref.watch(authProvider);

    if (!enabled || authState is! AuthAuthenticated) {
      return const SizedBox.shrink();
    }

    return _BackupSyncSectionBody();
  }
}

class _BackupSyncSectionBody extends ConsumerStatefulWidget {
  @override
  ConsumerState<_BackupSyncSectionBody> createState() =>
      _BackupSyncSectionBodyState();
}

class _BackupSyncSectionBodyState
    extends ConsumerState<_BackupSyncSectionBody> {
  bool _busy = false;

  Future<void> _pushToCloud() async {
    final passphrase = await PassphrasePromptDialog.showCreate(context);
    if (passphrase == null) return;
    if (!mounted) return;

    setState(() => _busy = true);
    try {
      await ref.read(backupSyncProvider.notifier).pushBackup(passphrase);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup pushed to the cloud.')),
        );
      }
    } on NetworkException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't reach the server.")),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pullFromCloud() async {
    String? errorText;
    while (true) {
      if (!mounted) return;
      final passphrase = await PassphrasePromptDialog.showEnter(
        context,
        errorText: errorText,
      );
      if (passphrase == null) return;
      if (!mounted) return;

      setState(() => _busy = true);
      try {
        final restored = await ref
            .read(backupSyncProvider.notifier)
            .pullBackup(passphrase);
        if (!mounted) return;
        if (restored) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Backup restored from the cloud.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No cloud backup found for this account yet.'),
            ),
          );
        }
        return;
      } on WrongBackupPassphraseException {
        errorText = _wrongPassphraseErrorText;
      } on NetworkException {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Couldn't reach the server.")),
          );
        }
        return;
      } finally {
        if (mounted) setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Cloud Backup (Beta)', style: AppTextTheme.titleMd),
        const SizedBox(height: AppSpacing.stackGap),
        Text(
          'Push or pull the same encrypted-with-your-passphrase backup '
          'that "Create backup" builds locally, to or from your account.',
          style: AppTextTheme.bodySm.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.stackGap),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _busy ? null : () => unawaited(_pushToCloud()),
            child: const Text('Push to Cloud'),
          ),
        ),
        const SizedBox(height: AppSpacing.stackGap),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _busy ? null : () => unawaited(_pullFromCloud()),
            child: const Text('Pull from Cloud'),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
