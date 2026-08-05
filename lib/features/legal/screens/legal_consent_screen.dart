import 'dart:async';

import 'package:co2diet/core/theme/spacing_tokens.dart';
import 'package:co2diet/core/theme/text_tokens.dart';
import 'package:co2diet/features/legal/providers/consent_notifier.dart';
import 'package:co2diet/features/legal/widgets/consent_checkbox_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The Legal Consent screen every onboarding path (and, per Phase 7's
/// planned Account Mode, every future account path too) must pass
/// through before reaching Profile Setup.
///
/// 4 mandatory checkboxes (Terms, Privacy, not-medical-advice,
/// user-responsibility) + 1 optional 16+ self-declaration checkbox.
/// "Accept and Continue" stays disabled until the 4 mandatory boxes are
/// checked — the optional box never gates the button (LEGAL-01/02).
///
/// All 5 checkbox booleans are hard-coded to `false` at construction,
/// never derived from a stored value — PITFALLS.md C5's hard
/// "no pre-checked boxes" requirement, since a pre-checked or restored
/// value would make consent legally invalid under GDPR Art. 4(11)/7.
class LegalConsentScreen extends ConsumerStatefulWidget {
  /// Creates a [LegalConsentScreen].
  const LegalConsentScreen({super.key});

  @override
  ConsumerState<LegalConsentScreen> createState() =>
      _LegalConsentScreenState();
}

class _LegalConsentScreenState extends ConsumerState<LegalConsentScreen> {
  bool _termsChecked = false;
  bool _privacyChecked = false;
  bool _notMedicalAdviceChecked = false;
  bool _userResponsibilityChecked = false;
  bool _age16PlusChecked = false;

  bool _isAccepting = false;

  // Only the 4 mandatory checkboxes gate the button — the optional 16+
  // box never substitutes for a mandatory one and never gates it.
  bool get _canAccept =>
      _termsChecked &&
      _privacyChecked &&
      _notMedicalAdviceChecked &&
      _userResponsibilityChecked;

  Future<void> _onAccept() async {
    if (_isAccepting) return;
    setState(() => _isAccepting = true);

    final consentsGiven = [
      'terms',
      'privacy',
      'not_medical_advice',
      'user_responsibility',
      if (_age16PlusChecked) 'age_16_plus',
    ];

    try {
      await ref
          .read(consentProvider.notifier)
          .acceptConsent(consentsGiven: consentsGiven);
      if (mounted) context.go('/profile');
    } finally {
      if (mounted) setState(() => _isAccepting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keeps consentProvider (autoDispose) alive for the duration of this
    // screen's lifetime -- without an active watch, Riverpod disposes it
    // as soon as _onAccept's `ref.read(consentProvider.notifier)` call
    // returns, crashing mid-flight on the first `await` inside
    // acceptConsent (mirrors the [Phase 04-09] mealEntryProvider fix).
    ref.watch(consentProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.containerMargin,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              Text(
                'Before you start',
                style: AppTextTheme.headlineLgMobile.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'We need your consent to continue.',
                style: AppTextTheme.bodyLg.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ConsentCheckboxTile(
                value: _termsChecked,
                onChanged: (v) =>
                    setState(() => _termsChecked = v ?? false),
                label: 'I have read and agree to the Terms of Service',
                trailingLink: TextButton(
                  onPressed: () =>
                      context.push('/legal-hub/document?doc=terms'),
                  child: const Text('View Terms'),
                ),
              ),
              ConsentCheckboxTile(
                value: _privacyChecked,
                onChanged: (v) =>
                    setState(() => _privacyChecked = v ?? false),
                label: 'I have read and agree to the Privacy Policy',
                trailingLink: TextButton(
                  onPressed: () =>
                      context.push('/legal-hub/document?doc=privacy'),
                  child: const Text('View Privacy Policy'),
                ),
              ),
              ConsentCheckboxTile(
                value: _notMedicalAdviceChecked,
                onChanged: (v) => setState(
                  () => _notMedicalAdviceChecked = v ?? false,
                ),
                label:
                    'I understand this app does not provide medical advice',
                trailingLink: TextButton(
                  onPressed: () => context.push(
                    '/legal-hub/document?doc=health_disclaimer',
                  ),
                  child: const Text('View Disclaimer'),
                ),
              ),
              ConsentCheckboxTile(
                value: _userResponsibilityChecked,
                onChanged: (v) => setState(
                  () => _userResponsibilityChecked = v ?? false,
                ),
                label:
                    'I am responsible for decisions I make based on '
                    'information in this app',
                trailingLink: TextButton(
                  onPressed: () => context.push(
                    '/legal-hub/document?doc=health_disclaimer',
                  ),
                  child: const Text('View Disclaimer'),
                ),
              ),
              ConsentCheckboxTile(
                value: _age16PlusChecked,
                onChanged: (v) =>
                    setState(() => _age16PlusChecked = v ?? false),
                label: 'I confirm I am 16 or older',
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.containerMargin),
          child: FilledButton(
            onPressed: _canAccept && !_isAccepting
                ? () => unawaited(_onAccept())
                : null,
            child: const Text('Accept and Continue'),
          ),
        ),
      ),
    );
  }
}
