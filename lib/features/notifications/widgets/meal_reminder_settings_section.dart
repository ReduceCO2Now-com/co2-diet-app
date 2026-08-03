import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:co2diet/core/theme/color_tokens.dart';
import 'package:co2diet/core/theme/spacing_tokens.dart';
import 'package:co2diet/core/theme/text_tokens.dart';
import 'package:co2diet/domain/entities/meal_slot.dart';
import 'package:co2diet/domain/entities/notification_prefs.dart';
import 'package:co2diet/features/notifications/providers/notification_prefs_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fallback reminder time shown/used for a slot that has never had a time
/// configured -- only the Custom-style per-row time picker below ever
/// changes it thereafter.
const _defaultReminderTime = '08:00';

/// Standalone, embeddable meal-reminder settings section (NOTIF-01): one
/// independently configurable enable-toggle + time-picker pair per
/// [MealSlot].
///
/// This widget is NOT wired into `SettingsScreen` by this plan -- Plan
/// 05-18 embeds it into General Settings once every Wave 5 output exists,
/// avoiding a `settings_screen.dart` file conflict with sibling Wave 5
/// plans.
///
/// Thin UI layer over `notificationPrefsProvider`
/// (`NotificationPrefsNotifier`) -- this widget never talks to
/// `INotificationPrefsRepository`/`NotificationService` directly.
class MealReminderSettingsSection extends ConsumerWidget {
  /// Creates a [MealReminderSettingsSection].
  const MealReminderSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(notificationPrefsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Meal Reminders', style: AppTextTheme.titleMd),
        const SizedBox(height: AppSpacing.stackGap),
        switch (prefsAsync) {
          AsyncData(:final value) => Column(
            children: [
              for (final slot in MealSlot.values)
                _MealSlotRow(slot: slot, prefs: value),
            ],
          ),
          AsyncError() => const Text('Could not load reminder settings.'),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ],
    );
  }
}

/// A single meal slot's independent row: label, time picker, enable
/// switch, and (on permission denial) an inline row-scoped recovery link.
///
/// A `ConsumerStatefulWidget` (rather than folding this into the parent
/// `ConsumerWidget`) because each row needs its own local
/// permission-denied-message state and pending-time-selection state,
/// independent of its siblings -- mirrors `WeighInReminderSection`'s
/// (Plan 05-13) local-state pattern for the same permission-denied UX.
class _MealSlotRow extends ConsumerStatefulWidget {
  const _MealSlotRow({required this.slot, required this.prefs});

  /// Which meal slot this row configures.
  final MealSlot slot;

  /// The current [NotificationPrefs] snapshot, owned by the parent (which
  /// watches `notificationPrefsProvider`).
  final NotificationPrefs prefs;

  @override
  ConsumerState<_MealSlotRow> createState() => _MealSlotRowState();
}

class _MealSlotRowState extends ConsumerState<_MealSlotRow> {
  late String _time;
  String? _permissionDeniedMessage;

  @override
  void initState() {
    super.initState();
    _syncTime();
  }

  @override
  void didUpdateWidget(covariant _MealSlotRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.prefs != widget.prefs) {
      _syncTime();
    }
  }

  void _syncTime() {
    _time = widget.prefs.timeFor(widget.slot) ?? _defaultReminderTime;
  }

  Future<void> _pickTime() async {
    final parts = _time.split(':');
    final initial = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;

    final formatted =
        '${picked.hour.toString().padLeft(2, '0')}:'
        '${picked.minute.toString().padLeft(2, '0')}';
    if (mounted) setState(() => _time = formatted);

    // Only re-schedule immediately if this slot's reminder is already on;
    // otherwise the picked time is simply remembered for when the switch
    // is turned on (mirrors WeighInReminderSection's `_pickTime`).
    if (widget.prefs.enabledFor(widget.slot)) {
      await _apply(enabled: true);
    }
  }

  Future<void> _onToggleChanged(bool value) => _apply(enabled: value);

  Future<void> _apply({required bool enabled}) async {
    final succeeded = await ref
        .read(notificationPrefsProvider.notifier)
        .setSlotEnabled(widget.slot, enabled, time: _time);

    if (!succeeded) {
      // Defensive re-read: setSlotEnabled's denial path never calls
      // ref.invalidateSelf() (nothing changed), so build() isn't re-run.
      // Re-reading here ensures this row (and its siblings) reflect the
      // authoritative, unchanged (still-off) state rather than relying on
      // stale widget.prefs.
      ref.invalidate(notificationPrefsProvider);
      if (!mounted) return;
      setState(() {
        _permissionDeniedMessage =
            'Notifications or exact-alarm scheduling are disabled -- '
            'open Settings to allow reminders to fire on time.';
      });
      return;
    }

    if (mounted) setState(() => _permissionDeniedMessage = null);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.prefs.enabledFor(widget.slot);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.slot.displayLabel,
                  style: AppTextTheme.bodyLg,
                ),
              ),
              TextButton(
                onPressed: () => unawaited(_pickTime()),
                child: Text(_time),
              ),
              Switch(
                value: enabled,
                onChanged: (value) => unawaited(_onToggleChanged(value)),
              ),
            ],
          ),
          if (_permissionDeniedMessage != null) ...[
            Text(
              _permissionDeniedMessage!,
              style: AppTextTheme.bodySm.copyWith(color: AppColors.error),
            ),
            const TextButton(
              onPressed: AppSettings.openAppSettings,
              child: Text('Open Settings'),
            ),
          ],
        ],
      ),
    );
  }
}
