import 'dart:async';

import 'package:co2diet/core/theme/spacing_tokens.dart';
import 'package:co2diet/core/theme/text_tokens.dart';
import 'package:co2diet/core/widgets/ed_safety_net_dialog.dart';
import 'package:co2diet/domain/entities/weight_settings.dart';
import 'package:co2diet/domain/services/ed_safety_net_checker.dart';
import 'package:co2diet/features/profile/providers/profile_notifier.dart';
import 'package:co2diet/features/weight/providers/weight_notifier.dart';
import 'package:co2diet/features/weight/widgets/weigh_in_reminder_section.dart';
import 'package:co2diet/features/weight/widgets/weight_chart.dart';
import 'package:co2diet/features/weight/widgets/weight_entry_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The Weight Tracking screen (WT-01 through WT-04): Record (log a
/// weigh-in), History + interactive chart, Goal (target weight + date,
/// static dashed reference line only), and Reminders.
///
/// Deliberately excludes any "Learn More" section (guide/diet book/
/// Discord) per CONTEXT.md's Deferred Ideas -- Record/History+Chart/Goal/
/// Reminders are the only sections.
///
/// Not yet wired into `app_router.dart` or linked from Settings -- Plan
/// 05-18 adds the route and Settings entry point once every Wave 5 screen
/// exists (mirrors `Co2SettingsScreen`'s Plan 05-12 precedent).
class WeightScreen extends ConsumerWidget {
  /// Creates the [WeightScreen].
  const WeightScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weightAsync = ref.watch(weightProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Weight Tracking',
          style: AppTextTheme.headlineLgMobile,
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: weightAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) =>
              const Center(child: Text('Error loading weight data')),
          data: (state) => _WeightScreenBody(settings: state.settings),
        ),
      ),
    );
  }
}

/// Displays the Chart, Log-weight action, Goal, Reminders, and a static
/// Best Practices tips section.
class _WeightScreenBody extends ConsumerWidget {
  const _WeightScreenBody({required this.settings});

  final WeightSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.containerMargin),
      children: [
        const WeightChart(),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (_) => const WeightEntryForm(),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Log weight'),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Goal ──────────────────────────────────────────────────────
        const Text('Goal', style: AppTextTheme.titleMd),
        const SizedBox(height: AppSpacing.stackGap),
        _GoalFields(settings: settings),
        const SizedBox(height: AppSpacing.lg),

        // ── Reminders ─────────────────────────────────────────────────
        WeighInReminderSection(settings: settings),
        const SizedBox(height: AppSpacing.lg),

        // ── Best Practices ────────────────────────────────────────────
        const Text('Best Practices', style: AppTextTheme.titleMd),
        const SizedBox(height: AppSpacing.stackGap),
        Text(
          'Weigh yourself at the same time of day, ideally right after '
          'waking up and before eating or drinking, for the most '
          'consistent readings. Day-to-day fluctuations are normal -- '
          'focus on the overall trend over several weeks rather than any '
          'single weigh-in.',
          style: AppTextTheme.bodySm.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Target weight + target date fields (WT-03). Target date auto-saves on
/// every change via `WeightNotifier.saveGoal`, mirroring `ProfileForm`/
/// `Co2SettingsScreen`'s established no-blocking-validation convention.
/// Target weight instead saves on submit/blur (not every keystroke) since
/// it's gated by the ED safety-net BMI check (NFR-07).
class _GoalFields extends ConsumerStatefulWidget {
  const _GoalFields({required this.settings});

  final WeightSettings settings;

  @override
  ConsumerState<_GoalFields> createState() => _GoalFieldsState();
}

class _GoalFieldsState extends ConsumerState<_GoalFields> {
  late DateTime? _targetDate = widget.settings.targetDate;
  late final TextEditingController _targetWeightController =
      TextEditingController(
        text: widget.settings.targetWeightKg?.toStringAsFixed(1) ?? '',
      );

  /// The most recent target-weight value the user explicitly confirmed past
  /// the ED safety-net BMI warning. Re-saving this exact same value does not
  /// re-trigger the modal; a different unsafe value does (06-CONTEXT.md
  /// re-warn rule). In-memory only — never persisted.
  double? _lastConfirmedUnsafeWeightKg;

  // Guards against double-invocation: Flutter's EditableText fires BOTH
  // onEditingComplete and onFieldSubmitted for the same "Done" keyboard
  // action (editable_text.dart's _finalizeEditing calls both), which would
  // otherwise show the safety-net modal twice for one submit event.
  bool _submitInFlight = false;

  @override
  void dispose() {
    _targetWeightController.dispose();
    super.dispose();
  }

  Future<void> _handleTargetWeightSubmit() async {
    if (_submitInFlight) return;
    _submitInFlight = true;
    try {
      await _doHandleTargetWeightSubmit();
    } finally {
      _submitInFlight = false;
    }
  }

  Future<void> _doHandleTargetWeightSubmit() async {
    final parsed = double.tryParse(_targetWeightController.text);

    if (parsed != null) {
      final heightCm = ref.read(profileProvider).value?.heightCm;
      final isUnsafe = EdSafetyNetChecker.bmiIsUnsafe(
        weightKg: parsed,
        heightCm: heightCm,
      );

      if (isUnsafe == true && parsed != _lastConfirmedUnsafeWeightKg) {
        final confirmed = await showEdSafetyNetDialog(
          context,
          type: EdSafetyNetTriggerType.bmi,
        );
        if (!mounted || !confirmed) return;
        _lastConfirmedUnsafeWeightKg = parsed;
      }
    }

    await ref
        .read(weightProvider.notifier)
        .saveGoal(targetWeightKg: parsed, targetDate: _targetDate);
  }

  Future<void> _pickTargetDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked == null) return;

    setState(() => _targetDate = picked);
    await ref
        .read(weightProvider.notifier)
        .saveGoal(
          targetWeightKg: widget.settings.targetWeightKg,
          targetDate: picked,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // A TextEditingController (not initialValue) so the field's text
        // survives provider rebuilds without losing focus/cursor position.
        // The ED safety-net BMI check must only fire on a discrete "save
        // event" (submit/blur), never on every keystroke (RESEARCH.md
        // Pitfall 4) -- onChanged below only updates the controller's own
        // buffer, it never saves or checks.
        TextFormField(
          controller: _targetWeightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Target weight',
            suffixText: 'kg',
          ),
          onChanged: (_) {},
          onEditingComplete: () => unawaited(_handleTargetWeightSubmit()),
          onFieldSubmitted: (_) => unawaited(_handleTargetWeightSubmit()),
          onTapOutside: (_) {
            FocusScope.of(context).unfocus();
            unawaited(_handleTargetWeightSubmit());
          },
        ),
        const SizedBox(height: AppSpacing.stackGap),
        InkWell(
          onTap: () => unawaited(_pickTargetDate()),
          child: InputDecorator(
            decoration: const InputDecoration(labelText: 'Target date'),
            child: Text(
              _targetDate == null
                  ? 'Not set'
                  : '${_targetDate!.year}-'
                        '${_targetDate!.month.toString().padLeft(2, '0')}-'
                        '${_targetDate!.day.toString().padLeft(2, '0')}',
            ),
          ),
        ),
      ],
    );
  }
}
