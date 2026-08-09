// Account Mode's day-to-day management surface (AUTH-02, AUTH-03, PRIV-05).
//
// Embedded directly into SettingsScreen once realmDiscoveryReadyProvider
// resolves true (07-CONTEXT.md's locked "Backend-readiness gate" +
// placement decisions) -- Plan 07-06 owns everything a signed-in user can
// do to their Account Mode session: view their email, change their
// password, log out, and delete their account.

import 'dart:async';

import 'package:co2diet/core/theme/color_tokens.dart';
import 'package:co2diet/core/theme/spacing_tokens.dart';
import 'package:co2diet/core/theme/text_tokens.dart';
import 'package:co2diet/domain/entities/auth_state.dart';
import 'package:co2diet/domain/services/keycloak_config.dart';
import 'package:co2diet/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

/// The realm-discovery-gated "Account" section of Settings.
///
/// Signed-out (`AuthUnauthenticated`): a single row inviting the user into
/// Account Mode. Signed-in (`AuthAuthenticated`): email display,
/// change-password, log-out, and delete-account rows.
///
/// A one-time "You've been signed out" notice is shown (and immediately
/// acknowledged) when the auth state carries `sessionExpired: true`, so it
/// never reappears on rebuild.
class AccountSection extends ConsumerWidget {
  /// Creates the [AccountSection].
  const AccountSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState is AuthUnauthenticated && authState.sessionExpired) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("You've been signed out")));
        ref.read(authProvider.notifier).acknowledgeSessionExpired();
      });
    }

    return switch (authState) {
      AuthUnauthenticated() => ListTile(
        leading: const Icon(Icons.login),
        title: const Text('Sign in / Create account'),
        subtitle: const Text(
          'Access Account Mode -- your local data stays put',
        ),
        onTap: () => context.push('/auth'),
      ),
      AuthAuthenticated(:final email) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.xs,
            ),
            child: Text('Account', style: AppTextTheme.titleMd),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle_outlined),
            title: Text(email),
          ),
          ListTile(
            leading: const Icon(Icons.password_outlined),
            title: const Text('Change password'),
            onTap: () => unawaited(
              launchUrl(
                Uri.parse(
                  '${KeycloakConfig.issuer}'
                  '/account/account-security/signing-in',
                ),
                mode: LaunchMode.externalApplication,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log out'),
            onTap: () => unawaited(ref.read(authProvider.notifier).logout()),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            iconColor: AppColors.error,
            textColor: AppColors.error,
            title: const Text('Delete account'),
            onTap: () => unawaited(_handleDeleteAccount(context, ref)),
          ),
        ],
      ),
    };
  }

  Future<void> _handleDeleteAccount(BuildContext context, WidgetRef ref) async {
    final confirmed = await _showDeleteAccountDialog(context);
    if (!confirmed) return;

    try {
      await ref.read(authProvider.notifier).deleteAccount();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your account has been deleted.')),
        );
      }
    } on AccountDeletionException {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Couldn't delete your account -- please try again.",
            ),
          ),
        );
      }
    }
  }

  Future<bool> _showDeleteAccountDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete your account?'),
        content: const Text(
          'Your account will be permanently deleted. Your local data on '
          'this device will NOT be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete account'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
