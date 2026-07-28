import 'package:co2diet/core/theme/color_tokens.dart';
import 'package:co2diet/core/theme/spacing_tokens.dart';
import 'package:co2diet/core/theme/text_tokens.dart';
import 'package:co2diet/domain/entities/user_profile.dart';
import 'package:flutter/material.dart';

/// Stateless form displaying all 7 profile fields.
///
/// Auto-saves on every field change by calling [onChanged] with an updated
/// [UserProfile]. There is no submit button — every mutation is immediate.
///
/// Unit-aware: height and weight fields switch between metric (cm/kg) and
/// imperial (ft+in / lb) based on [profile] units. Internal storage is
/// always cm/kg.
class ProfileForm extends StatelessWidget {
  /// Creates a [ProfileForm].
  const ProfileForm({
    required this.onChanged,
    this.profile,
    super.key,
  });

  /// The current profile state. May be null for a brand-new user.
  final UserProfile? profile;

  /// Called whenever any field changes with the updated [UserProfile].
  final void Function(UserProfile) onChanged;

  @override
  Widget build(BuildContext context) {
    final p = profile;
    final units = p?.units ?? 'metric';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Body Measurements ───────────────────────────────────────────
        const _SectionHeader('Body Measurements'),
        const SizedBox(height: AppSpacing.stackGap),

        // Age
        //
        // No value-derived key here (deliberately) -- keying a TextFormField
        // by its own current value causes Flutter to treat it as a brand
        // new widget on every keystroke (auto-save -> provider rebuild ->
        // key changes -> Element destroyed/recreated), which drops focus
        // and dismisses the keyboard after every character. This screen
        // only ever mounts once `profile` has already loaded (behind
        // `profileAsync.when(data: ...)`), so `initialValue` is correct at
        // first build and never needs a forced remount afterward.
        TextFormField(
          initialValue: p?.age?.toString() ?? '',
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Age',
            suffixText: 'years',
          ),
          onChanged: (raw) {
            final parsed = int.tryParse(raw);
            onChanged(_current(p).copyWith(age: parsed));
          },
        ),
        const SizedBox(height: AppSpacing.stackGap),

        // Gender
        DropdownButtonFormField<String>(
          initialValue: p?.gender,
          decoration: const InputDecoration(labelText: 'Gender'),
          items: const [
            DropdownMenuItem(value: 'male', child: Text('Male')),
            DropdownMenuItem(value: 'female', child: Text('Female')),
            DropdownMenuItem(value: 'other', child: Text('Other')),
          ],
          onChanged: (value) {
            if (value == null) return;
            onChanged(_current(p).copyWith(gender: value));
          },
        ),
        const SizedBox(height: AppSpacing.stackGap),

        // Units toggle
        _UnitsToggle(
          units: units,
          onChanged: (selected) =>
              onChanged(_current(p).copyWith(units: selected)),
        ),
        const SizedBox(height: AppSpacing.stackGap),

        // Height (unit-aware)
        _HeightField(
          units: units,
          heightCm: p?.heightCm,
          onChanged: (cm) =>
              onChanged(_current(p).copyWith(heightCm: cm)),
        ),
        const SizedBox(height: AppSpacing.stackGap),

        // Weight (unit-aware)
        _WeightField(
          units: units,
          weightKg: p?.weightKg,
          onChanged: (kg) =>
              onChanged(_current(p).copyWith(weightKg: kg)),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Lifestyle ───────────────────────────────────────────────────
        const _SectionHeader('Lifestyle'),
        const SizedBox(height: AppSpacing.stackGap),

        // Activity level
        DropdownButtonFormField<String>(
          initialValue: p?.activityLevel,
          decoration: const InputDecoration(labelText: 'Activity Level'),
          items: const [
            DropdownMenuItem(
              value: 'low',
              child: Text('Low (1–3 days/week)'),
            ),
            DropdownMenuItem(
              value: 'medium',
              child: Text('Medium (3–5 days/week)'),
            ),
            DropdownMenuItem(
              value: 'high',
              child: Text('High (6–7 days/week)'),
            ),
          ],
          onChanged: (value) {
            if (value == null) return;
            onChanged(_current(p).copyWith(activityLevel: value));
          },
        ),
        const SizedBox(height: AppSpacing.stackGap),

        // Dietary preference
        DropdownButtonFormField<String>(
          initialValue: p?.dietaryPreference,
          decoration:
              const InputDecoration(labelText: 'Dietary Preference'),
          items: const [
            DropdownMenuItem(
              value: 'no_preference',
              child: Text('No preference'),
            ),
            DropdownMenuItem(
              value: 'vegetarian',
              child: Text('Vegetarian'),
            ),
            DropdownMenuItem(value: 'vegan', child: Text('Vegan')),
            DropdownMenuItem(
              value: 'flexitarian',
              child: Text('Flexitarian'),
            ),
            DropdownMenuItem(
              value: 'low_meat',
              child: Text('Low meat'),
            ),
            DropdownMenuItem(value: 'other', child: Text('Other')),
          ],
          onChanged: (value) {
            if (value == null) return;
            onChanged(_current(p).copyWith(dietaryPreference: value));
          },
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Goal ────────────────────────────────────────────────────────
        const _SectionHeader('Goal'),
        const SizedBox(height: AppSpacing.stackGap),

        DropdownButtonFormField<String>(
          initialValue: p?.goal,
          decoration: const InputDecoration(labelText: 'Goal'),
          items: const [
            DropdownMenuItem(
              value: 'reduce_co2',
              child: Text('Reduce CO₂ footprint'),
            ),
            DropdownMenuItem(
              value: 'lose_weight',
              child: Text('Lose weight'),
            ),
            DropdownMenuItem(
              value: 'maintain_weight',
              child: Text('Maintain weight'),
            ),
            DropdownMenuItem(
              value: 'gain_muscle',
              child: Text('Gain muscle'),
            ),
            DropdownMenuItem(
              value: 'improve_health',
              child: Text('Improve health'),
            ),
            DropdownMenuItem(
              value: 'balanced_lifestyle',
              child: Text('Balanced lifestyle'),
            ),
            DropdownMenuItem(
              value: 'learn_and_explore',
              child: Text('Learn & explore'),
            ),
          ],
          onChanged: (value) {
            if (value == null) return;
            onChanged(_current(p).copyWith(goal: value));
          },
        ),
      ],
    );
  }

  /// Returns the current profile or a blank placeholder for new users.
  UserProfile _current(UserProfile? p) =>
      p ?? const UserProfile(id: '');
}

// ── Private helper widgets ─────────────────────────────────────────────────

/// Section heading rendered in labelCaps style (Inter, 12px, uppercase).
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

/// Metric/Imperial toggle using a [SegmentedButton].
class _UnitsToggle extends StatelessWidget {
  const _UnitsToggle({required this.units, required this.onChanged});

  final String units;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Units',
          style: AppTextTheme.bodySm.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: 'metric',
              label: Text('Metric (kg, cm)'),
            ),
            ButtonSegment(
              value: 'imperial',
              label: Text('Imperial (lb, ft+in)'),
            ),
          ],
          selected: {units},
          onSelectionChanged: (selected) => onChanged(selected.first),
          showSelectedIcon: false,
        ),
      ],
    );
  }
}

/// Unit-aware height input field.
///
/// Metric: single cm field.
/// Imperial: two fields (feet + inches) that combine to cm for storage.
class _HeightField extends StatelessWidget {
  const _HeightField({
    required this.units,
    required this.onChanged,
    this.heightCm,
  });

  final String units;
  final double? heightCm;
  final void Function(double?) onChanged;

  @override
  Widget build(BuildContext context) {
    if (units == 'imperial') {
      final totalInches = heightCm != null ? heightCm! / 2.54 : null;
      final feet = totalInches != null ? (totalInches ~/ 12) : null;
      final inches =
          totalInches != null ? (totalInches % 12).round() : null;

      return Row(
        children: [
          Expanded(
            child: TextFormField(
              initialValue: feet?.toString() ?? '',
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Height',
                suffixText: 'ft',
              ),
              onChanged: (raw) {
                final parsedFt = int.tryParse(raw);
                if (parsedFt == null) {
                  onChanged(null);
                  return;
                }
                final currentIn = inches ?? 0;
                onChanged((parsedFt * 12 + currentIn) * 2.54);
              },
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextFormField(
              initialValue: inches?.toString() ?? '',
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: ' ',
                suffixText: 'in',
              ),
              onChanged: (raw) {
                final parsedIn = int.tryParse(raw);
                if (parsedIn == null) {
                  onChanged(null);
                  return;
                }
                final currentFt = feet ?? 0;
                onChanged((currentFt * 12 + parsedIn) * 2.54);
              },
            ),
          ),
        ],
      );
    }

    // Metric
    return TextFormField(
      initialValue: heightCm?.toStringAsFixed(0) ?? '',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
        labelText: 'Height',
        suffixText: 'cm',
      ),
      onChanged: (raw) {
        onChanged(double.tryParse(raw));
      },
    );
  }
}

/// Unit-aware weight input field.
///
/// Metric: kg field.
/// Imperial: lb field — converts to kg for internal storage.
class _WeightField extends StatelessWidget {
  const _WeightField({
    required this.units,
    required this.onChanged,
    this.weightKg,
  });

  final String units;
  final double? weightKg;
  final void Function(double?) onChanged;

  @override
  Widget build(BuildContext context) {
    if (units == 'imperial') {
      final weightLb = weightKg != null ? weightKg! / 0.453592 : null;
      return TextFormField(
        initialValue: weightLb?.toStringAsFixed(1) ?? '',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: 'Weight',
          suffixText: 'lb',
        ),
        onChanged: (raw) {
          final parsed = double.tryParse(raw);
          onChanged(parsed != null ? parsed * 0.453592 : null);
        },
      );
    }

    // Metric
    return TextFormField(
      initialValue: weightKg?.toStringAsFixed(1) ?? '',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
        labelText: 'Weight',
        suffixText: 'kg',
      ),
      onChanged: (raw) {
        onChanged(double.tryParse(raw));
      },
    );
  }
}
