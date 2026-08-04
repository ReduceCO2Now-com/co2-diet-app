import 'dart:async';

import 'package:co2diet/core/theme/color_tokens.dart';
import 'package:co2diet/core/theme/spacing_tokens.dart';
import 'package:co2diet/core/theme/text_tokens.dart';
import 'package:co2diet/core/widgets/ed_safety_net_dialog.dart';
import 'package:co2diet/domain/entities/calc_targets.dart';
import 'package:co2diet/domain/entities/user_profile.dart';
import 'package:co2diet/domain/services/ed_safety_net_checker.dart';
import 'package:co2diet/features/onboarding/providers/onboarding_gate_provider.dart';
import 'package:co2diet/features/profile/providers/profile_notifier.dart';
import 'package:co2diet/features/profile/widgets/profile_form.dart';
import 'package:co2diet/features/profile/widgets/target_display_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Full styled Profile screen — the vertical slice entry point for Phase 1.
///
/// Displays all 7 form fields (auto-save on change), a targets section with
/// computed kcal/protein/carbs/fat values (or — dash when inputs are missing),
/// and an override dialog for manual target adjustments.
///
/// CO2 target is intentionally hidden per D-08. It will be shown from Phase 3
/// onward when the CO2 factor table exists.
class ProfileScreen extends ConsumerStatefulWidget {
  /// Creates the [ProfileScreen].
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  /// The most recent kcal override value the user explicitly confirmed past
  /// the ED safety-net warning. Re-saving this exact same value does not
  /// re-trigger the modal; a different unsafe value does (06-CONTEXT.md
  /// re-warn rule). Deliberately in-memory only — never persisted, per the
  /// zero-analytics principle.
  double? _lastConfirmedUnsafeKcal;

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    return profileAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => const Scaffold(
        body: Center(child: Text('Error loading profile')),
      ),
      data: _buildBody,
    );
  }

  Widget _buildBody(UserProfile? profile) {
    // Detect locale on first build — apply imperial default for US users.
    //
    // Only fires for a genuinely brand-new profile (`profile == null`, no
    // row exists in the DB yet) -- NOT `profile.units == 'metric'`, which
    // was the original (buggy) condition. `'metric'` is UserProfile's own
    // default value, so once any field is saved (creating a real row with
    // units: 'metric'), that condition is permanently true: every build
    // scheduled another updateField write, which triggered a rebuild,
    // which scheduled another write -- an infinite auto-save loop for any
    // non-US-locale user (this app's entire target market is EU/Germany).
    // Real-device testing traced a Profile-screen crash
    // (`_dependents.isEmpty` framework assertion when opening the target-
    // override dialog) back to this: the dialog's `showDialog(context:
    // context, ...)` anchors on ProfileScreen's own Element, which this
    // loop was tearing down and rebuilding at high frequency underneath
    // it.
    if (profile == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final detectedUnits = ProfileNotifier.setLocaleUnits(context);
        unawaited(
          ref
              .read(profileProvider.notifier)
              .updateField((p) => p.copyWith(units: detectedUnits)),
        );
      });
    }

    final hasOnboarded = ref.watch(onboardingGateProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: AppTextTheme.headlineLgMobile,
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.containerMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileForm(
                profile: profile,
                onChanged: (updated) {
                  unawaited(
                    ref
                        .read(profileProvider.notifier)
                        .saveProfile(updated),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              _TargetsSection(
                profile: profile,
                onOverrideTap: (fieldName) =>
                    _showOverrideDialog(fieldName, profile),
              ),
              const SizedBox(height: AppSpacing.md),
              // Unconditional per 06-CONTEXT.md: no mode branching this
              // phase, since only Local Mode exists. Phase 7 makes this
              // conditional again once Account Mode is introduced.
              Text(
                'Your profile is stored only on this device.',
                style: AppTextTheme.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              // Onboarding-only "Continue" button (ONBD-01/05) — absent
              // once onboarding is complete, restoring this screen's
              // exact prior-phase behavior.
              if (!hasOnboarded) ...[
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => context.go('/onboarding-carousel'),
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showOverrideDialog(
    String fieldName,
    UserProfile? profile,
  ) async {
    final targets = profile?.targets;
    double? currentValue;
    switch (fieldName) {
      case 'kcalTarget':
        currentValue = targets?.kcalTarget;
      case 'proteinTarget':
        currentValue = targets?.proteinGTarget;
      case 'carbsTarget':
        currentValue = targets?.carbsGTarget;
      case 'fatTarget':
        currentValue = targets?.fatGTarget;
    }

    final controller = TextEditingController(
      text: currentValue?.toStringAsFixed(0) ?? '',
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Set custom target'),
        content: TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Value'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Reset to calculated — clear override flag and value
              unawaited(
                ref.read(profileProvider.notifier).updateField(
                      (p) => p.copyWith(
                        targets: _clearOverride(p.targets, fieldName),
                      ),
                    ),
              );
            },
            child: const Text('Reset to calculated'),
          ),
          FilledButton(
            onPressed: () async {
              final entered = double.tryParse(controller.text);
              if (entered == null) {
                Navigator.of(dialogContext).pop();
                return;
              }

              final isUnsafeKcalTarget =
                  fieldName == 'kcalTarget' &&
                  EdSafetyNetChecker.calorieTargetIsUnsafe(entered) &&
                  entered != _lastConfirmedUnsafeKcal;

              if (isUnsafeKcalTarget) {
                Navigator.of(dialogContext).pop();
                final confirmed = await showEdSafetyNetDialog(
                  context,
                  type: EdSafetyNetTriggerType.calorieTarget,
                );
                if (!mounted || !confirmed) return;
                _lastConfirmedUnsafeKcal = entered;
              } else {
                Navigator.of(dialogContext).pop();
              }

              unawaited(
                ref.read(profileProvider.notifier).updateField(
                      (p) => p.copyWith(
                        targets: _applyOverride(p.targets, fieldName, entered),
                      ),
                    ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  CalcTargets _applyOverride(
    CalcTargets? targets,
    String fieldName,
    double value,
  ) {
    final t = targets ?? const CalcTargets();
    switch (fieldName) {
      case 'kcalTarget':
        return t.copyWith(kcalTarget: value, kcalIsOverridden: true);
      case 'proteinTarget':
        return t.copyWith(proteinGTarget: value, proteinIsOverridden: true);
      case 'carbsTarget':
        return t.copyWith(carbsGTarget: value, carbsIsOverridden: true);
      case 'fatTarget':
        return t.copyWith(fatGTarget: value, fatIsOverridden: true);
      default:
        return t;
    }
  }

  CalcTargets _clearOverride(CalcTargets? targets, String fieldName) {
    final t = targets ?? const CalcTargets();
    switch (fieldName) {
      case 'kcalTarget':
        return t.copyWith(kcalTarget: null, kcalIsOverridden: false);
      case 'proteinTarget':
        return t.copyWith(proteinGTarget: null, proteinIsOverridden: false);
      case 'carbsTarget':
        return t.copyWith(carbsGTarget: null, carbsIsOverridden: false);
      case 'fatTarget':
        return t.copyWith(fatGTarget: null, fatIsOverridden: false);
      default:
        return t;
    }
  }
}

// ── Private helpers ────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: AppTextTheme.labelCaps.copyWith(
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
}

class _TargetsSection extends StatelessWidget {
  const _TargetsSection({
    required this.onOverrideTap,
    this.profile,
  });

  final UserProfile? profile;
  final void Function(String fieldName) onOverrideTap;

  bool get _isMissingInputs {
    final p = profile;
    if (p == null) return true;
    return p.age == null ||
        p.gender == null ||
        p.heightCm == null ||
        p.weightKg == null;
  }

  @override
  Widget build(BuildContext context) {
    final targets = profile?.targets;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('Daily Targets'),
        const SizedBox(height: AppSpacing.stackGap),
        if (_isMissingInputs)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.stackGap),
            child: Text(
              'Add height and weight to see targets.',
              style: AppTextTheme.bodySm.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        GridView.extent(
          maxCrossAxisExtent: 160,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.stackGap,
          crossAxisSpacing: AppSpacing.stackGap,
          childAspectRatio: 1.1,
          children: [
            TargetDisplayCard(
              label: 'Calories',
              unit: 'kcal',
              value: targets?.kcalTarget,
              isOverridden: targets?.kcalIsOverridden ?? false,
              onTap: () => onOverrideTap('kcalTarget'),
            ),
            TargetDisplayCard(
              label: 'Protein',
              unit: 'g',
              value: targets?.proteinGTarget,
              isOverridden: targets?.proteinIsOverridden ?? false,
              onTap: () => onOverrideTap('proteinTarget'),
            ),
            TargetDisplayCard(
              label: 'Carbs',
              unit: 'g',
              value: targets?.carbsGTarget,
              isOverridden: targets?.carbsIsOverridden ?? false,
              onTap: () => onOverrideTap('carbsTarget'),
            ),
            TargetDisplayCard(
              label: 'Fat',
              unit: 'g',
              value: targets?.fatGTarget,
              isOverridden: targets?.fatIsOverridden ?? false,
              onTap: () => onOverrideTap('fatTarget'),
            ),
            // CO2 target card: intentionally absent per D-08.
            // Will be added in Phase 3 when CO2 factor table exists.
          ],
        ),
      ],
    );
  }
}
