import 'dart:async';

import 'package:co2diet/core/theme/spacing_tokens.dart';
import 'package:co2diet/core/theme/text_tokens.dart';
import 'package:co2diet/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The post-signup, pre-verification "Check your email" screen
/// (07-CONTEXT.md) -- shown immediately after `AuthScreen`'s
/// create-account submit completes, rather than dumping the user back on
/// the login form.
class CheckEmailScreen extends ConsumerWidget {
  /// Creates a [CheckEmailScreen] for [email].
  const CheckEmailScreen({required this.email, super.key});

  /// The email address the verification link was sent to.
  final String email;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.containerMargin),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.mark_email_unread_outlined,
                size: 64,
                color: colorScheme.primary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'We sent a verification link to $email. Verify, then come '
                'back and sign in.',
                textAlign: TextAlign.center,
                style: AppTextTheme.bodyLg.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextButton(
                onPressed: () => unawaited(_resend(ref)),
                child: const Text('Resend email'),
              ),
              const SizedBox(height: AppSpacing.stackGap),
              TextButton(
                // Pops back to AuthScreen, which switches itself to
                // sign-in mode on receiving `true` (07-CONTEXT.md: "Back
                // to Sign In" link).
                onPressed: () => context.pop(true),
                child: const Text('Back to Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Re-opens Keycloak's hosted create-account page by reusing
  /// `AuthNotifier.signUp` -- keeps `AuthNotifier` the single owner of the
  /// `authorizeAndExchangeCode` call (Plan 07-03's design: this screen
  /// never reaches into `appAuthProvider` directly). `recordConsent:
  /// false` guarantees a repeat tap never writes a second
  /// `account_mode_terms` consent_records row for what is still the same
  /// signup session (07-CONTEXT.md's audit-trail decision).
  Future<void> _resend(WidgetRef ref) => ref
      .read(authProvider.notifier)
      .signUp(loginHint: email, recordConsent: false);
}
