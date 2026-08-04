import 'package:co2diet/core/theme/color_tokens.dart';
import 'package:co2diet/core/theme/spacing_tokens.dart';
import 'package:co2diet/core/theme/text_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Second onboarding screen, shown after the Splash screen auto-advances.
///
/// Deliberately renders exactly ONE primary CTA ("Continue") rather than
/// the original spec's equal-weight "Get Started" / "Use Without Account"
/// pair (ONBD-02). Per `06-CONTEXT.md`'s locked decision for this phase,
/// there is no Account Mode yet (ONBD-03 is deferred to Phase 7), so a
/// second, equal-weight path has nothing to be equal to — the
/// equal-weight-CTA requirement is moot until Phase 7 reintroduces
/// Account Mode and a real second path exists to weigh against it.
class WelcomeScreen extends StatelessWidget {
  /// Creates [WelcomeScreen].
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.eco, size: 56, color: AppColors.primary),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'CO₂ Diet',
                style: AppTextTheme.headlineLg.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Track calories, protein, and estimated CO₂ — '
                'privately, offline.',
                textAlign: TextAlign.center,
                style: AppTextTheme.bodyLg.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Private. Offline-first. No ads.',
                textAlign: TextAlign.center,
                style: AppTextTheme.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.go('/legal-consent'),
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
