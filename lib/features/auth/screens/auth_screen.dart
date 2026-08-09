import 'dart:async';
import 'dart:io' show Platform;

import 'package:co2diet/core/theme/spacing_tokens.dart';
import 'package:co2diet/core/theme/text_tokens.dart';
import 'package:co2diet/domain/services/keycloak_config.dart';
import 'package:co2diet/features/auth/providers/auth_provider.dart';
import 'package:co2diet/features/auth/widgets/apple_sign_in_button.dart';
import 'package:co2diet/features/auth/widgets/google_sign_in_button.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

/// Which sub-mode [AuthScreen] is currently showing.
enum _AuthMode { createAccount, signIn }

/// The combined sign-in / create-account screen — social buttons, an "or"
/// divider, email/password fields, the honesty note, and (create-account
/// mode only) the Account Mode terms checkbox.
///
/// This is the only screen Local Mode users ever see if they choose to
/// explore Account Mode (07-CONTEXT.md). No route params — pushed from
/// Settings' "Sign in / Create account" row.
class AuthScreen extends ConsumerStatefulWidget {
  /// Creates an [AuthScreen].
  ///
  /// [showAppleButton] defaults to `null`, which resolves to
  /// `Platform.isIOS` at build time. A non-null value overrides the
  /// platform check — used by widget tests to deterministically exercise
  /// both the iOS and non-iOS layouts on any host platform (`Platform
  /// .isIOS` cannot be overridden from a Flutter widget test the way
  /// `debugDefaultTargetPlatformOverride` can, since it reads the real
  /// host OS via `dart:io`).
  const AuthScreen({super.key, this.showAppleButton});

  /// Overrides the platform-derived Apple-button visibility. `null` means
  /// "use `Platform.isIOS`".
  final bool? showAppleButton;

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  _AuthMode _mode = _AuthMode.createAccount;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _termsChecked = false;
  bool _isSubmitting = false;

  String? _passwordError;
  String? _termsError;
  String? _connectivityError;

  bool get _showAppleButton => widget.showAppleButton ?? Platform.isIOS;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _mode = _mode == _AuthMode.createAccount
          ? _AuthMode.signIn
          : _AuthMode.createAccount;
      _passwordError = null;
      _termsError = null;
      _connectivityError = null;
    });
  }

  /// `true` when the device currently has network connectivity.
  ///
  /// connectivity_plus 7.x returns `List<ConnectivityResult>`; an empty
  /// list or a list containing `ConnectivityResult.none` means offline
  /// (matches `food_search_notifier.dart`'s established pattern).
  Future<bool> _hasConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    return !(result.isEmpty || result.contains(ConnectivityResult.none));
  }

  Future<void> _launchForgotPassword() async {
    final uri = Uri.parse(
      '${KeycloakConfig.issuer}/login-actions/reset-credentials'
      '?client_id=${KeycloakConfig.clientId}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _submitEmailPassword() async {
    setState(() {
      _passwordError = null;
      _termsError = null;
      _connectivityError = null;
    });

    // Client-side pre-checks (create-account mode only) -- fast feedback
    // shown only on submit attempt; never opens the browser on this path
    // (07-CONTEXT.md).
    if (_mode == _AuthMode.createAccount) {
      if (_passwordController.text.length < 8) {
        setState(
          () => _passwordError = 'Password must be at least 8 characters',
        );
        return;
      }
      if (!_termsChecked) {
        setState(
          () => _termsError =
              'You must agree to the Terms for Account Mode to continue',
        );
        return;
      }
    }

    if (!await _hasConnectivity()) {
      if (!mounted) return;
      setState(
        () => _connectivityError = 'Sign-in requires an internet connection',
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final email = _emailController.text.trim();
    final loginHint = email.isEmpty ? null : email;

    try {
      if (_mode == _AuthMode.createAccount) {
        await ref.read(authProvider.notifier).signUp(loginHint: loginHint);
        if (!mounted) return;
        final switchToSignIn = await context.push<bool>(
          '/check-email?email=${Uri.encodeQueryComponent(email)}',
        );
        if (switchToSignIn ?? false) {
          if (!mounted) return;
          setState(() => _mode = _AuthMode.signIn);
        }
      } else {
        await ref.read(authProvider.notifier).signIn(loginHint: loginHint);
        if (!mounted) return;
        if (context.canPop()) context.pop();
      }
    } on Exception catch (_) {
      // Defensive only -- AuthNotifier already swallows every failure
      // (cancellation-flavored or otherwise) internally (Plan 07-03).
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitIdp(String idpAlias) async {
    if (_isSubmitting) return;

    setState(() => _connectivityError = null);
    if (!await _hasConnectivity()) {
      if (!mounted) return;
      setState(
        () => _connectivityError = 'Sign-in requires an internet connection',
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref.read(authProvider.notifier).signInWithIdp(idpAlias);
      if (!mounted) return;
      if (context.canPop()) context.pop();
    } on Exception catch (_) {
      // Defensive only -- see [_submitEmailPassword].
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCreateAccount = _mode == _AuthMode.createAccount;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(isCreateAccount ? 'Create account' : 'Sign in'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.containerMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Social buttons FIRST -- Apple above Google, per
              // 07-CONTEXT.md's locked ordering. Apple never renders below
              // Google regardless of platform: on Android it simply does
              // not render at all.
              if (_showAppleButton) ...[
                AppleSignInButton(
                  key: const Key('appleSignInButton'),
                  onPressed: () => unawaited(
                    _submitIdp(KeycloakConfig.appleIdpAlias),
                  ),
                ),
                const SizedBox(height: AppSpacing.stackGap),
              ],
              GoogleSignInButton(
                key: const Key('googleSignInButton'),
                onPressed: () => unawaited(
                  _submitIdp(KeycloakConfig.googleIdpAlias),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _OrDivider(colorScheme: colorScheme),
              const SizedBox(height: AppSpacing.md),
              AutofillGroup(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Email',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.stackGap),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      autofillHints: [
                        if (isCreateAccount)
                          AutofillHints.newPassword
                        else
                          AutofillHints.password,
                      ],
                      decoration: InputDecoration(
                        labelText: 'Password',
                        errorText: _passwordError,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isCreateAccount)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => unawaited(_launchForgotPassword()),
                    child: const Text('Forgot password?'),
                  ),
                ),
              const SizedBox(height: AppSpacing.stackGap),
              // Honesty note -- always visible on BOTH create-account and
              // sign-in modes (07-CONTEXT.md).
              Text(
                'Your existing local data stays on this device — '
                'cross-device sync is coming soon.',
                style: AppTextTheme.bodySm.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (isCreateAccount) ...[
                const SizedBox(height: AppSpacing.stackGap),
                CheckboxListTile(
                  key: const Key('accountModeTermsCheckbox'),
                  value: _termsChecked,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (v) => setState(() {
                    _termsChecked = v ?? false;
                    _termsError = null;
                  }),
                  title: const Text(
                    'I agree to the Terms for Account Mode',
                  ),
                  subtitle: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () =>
                          context.push('/legal-hub/document?doc=terms'),
                      child: const Text('View Terms'),
                    ),
                  ),
                ),
                if (_termsError != null)
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.sm),
                    child: Text(
                      _termsError!,
                      style: AppTextTheme.bodySm.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ),
              ],
              if (_connectivityError != null) ...[
                const SizedBox(height: AppSpacing.stackGap),
                Text(
                  _connectivityError!,
                  style: AppTextTheme.bodySm.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: _isSubmitting
                    ? null
                    : () => unawaited(_submitEmailPassword()),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isCreateAccount ? 'Create account' : 'Sign in'),
              ),
              const SizedBox(height: AppSpacing.stackGap),
              Center(
                child: TextButton(
                  onPressed: _toggleMode,
                  child: Text(
                    isCreateAccount
                        ? 'Already have an account? Sign in'
                        : 'New here? Create account',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: colorScheme.outlineVariant)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Text(
            'or',
            style: AppTextTheme.bodySm.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(child: Divider(color: colorScheme.outlineVariant)),
      ],
    );
  }
}
