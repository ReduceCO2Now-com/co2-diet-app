import 'package:co2diet/core/theme/color_tokens.dart';
import 'package:co2diet/core/theme/spacing_tokens.dart';
import 'package:co2diet/core/theme/text_tokens.dart';
import 'package:co2diet/domain/entities/network_mode.dart';
import 'package:co2diet/features/settings/providers/network_mode_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Onboarding step where the user chooses whether the app may make outbound
/// requests for food data (ONBD-03a).
///
/// Sits immediately after Legal Consent and before the Carousel: the user has
/// just read and accepted the privacy commitments, so a privacy-shaped choice
/// is contextually adjacent there, and placing it here leaves Phase 06.1's
/// verified Carousel → Profile Setup → Dashboard leg untouched.
///
/// Replaces the deferred Account/Local "Mode Choice" (ONBD-03). The backend's
/// catalog endpoints are public and it stores no user data, so *account* was
/// never the axis that changed anything a user could observe — *network use*
/// is. See `docs/decisions/0001-connectivity-choice-not-account-mode.md`.
///
/// Both options are fully functional and neither is recommended: no badge, no
/// visual hierarchy, identical card treatment. That is the equal-weight
/// requirement ONBD-03 was reaching for, honoured on an axis where the two
/// options genuinely differ.
class ConnectivityChoiceScreen extends ConsumerStatefulWidget {
  /// Creates [ConnectivityChoiceScreen].
  const ConnectivityChoiceScreen({super.key});

  @override
  ConsumerState<ConnectivityChoiceScreen> createState() =>
      _ConnectivityChoiceScreenState();
}

class _ConnectivityChoiceScreenState
    extends ConsumerState<ConnectivityChoiceScreen> {
  /// Null until the user picks. Deliberately unset rather than pre-selected —
  /// a default selection is a recommendation, which this screen must not make.
  NetworkMode? _selected;

  Future<void> _continue() async {
    final choice = _selected;
    if (choice == null) return;
    await ref.read(networkModeProvider.notifier).setMode(choice);
    if (mounted) context.go('/onboarding-carousel');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      // Scrollable rather than a bare centred Column: this screen carries two
      // description-bearing cards, and ACC-02 clamps text scaling at 1.6x
      // precisely because layouts break before that. A fixed Column overflows
      // at default size on an 800x600 surface, and worse at large type.
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.tune, size: 48, color: AppColors.primary),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Looking up foods',
                      style: AppTextTheme.headlineLg.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Your meals, weight and profile always stay on '
                      'this device. This is only about finding foods '
                      'you log.',
                      textAlign: TextAlign.center,
                      style: AppTextTheme.bodyLg.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _ChoiceCard(
                      icon: Icons.cloud_outlined,
                      title: 'Look up foods online',
                      body:
                          'Searches the online catalog for foods this '
                          "device doesn't already have. No account, and "
                          'nothing about you is sent.',
                      selected: _selected == NetworkMode.onlineAllowed,
                      onTap: () =>
                          setState(() => _selected = NetworkMode.onlineAllowed),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _ChoiceCard(
                      icon: Icons.cloud_off_outlined,
                      title: 'Stay offline',
                      body:
                          'Uses only the foods stored on this device. The app '
                          'makes no outbound requests at all.',
                      selected: _selected == NetworkMode.offlineOnly,
                      onTap: () =>
                          setState(() => _selected = NetworkMode.offlineOnly),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'You can change this any time in Settings.',
                      textAlign: TextAlign.center,
                      style: AppTextTheme.bodySm.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _selected == null ? null : _continue,
                        child: const Text('Continue'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One of the two equal-weight options.
///
/// Both cards share identical treatment — same icon size, same typography,
/// same border weight. Only the selected state differs, and that reflects the
/// user's choice rather than any preference of ours.
class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primary : colorScheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
            color: selected
                ? AppColors.primaryContainer.withValues(alpha: 0.12)
                : colorScheme.surfaceContainerLowest,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 28, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextTheme.bodyLg.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    Text(
                      body,
                      style: AppTextTheme.bodySm.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
