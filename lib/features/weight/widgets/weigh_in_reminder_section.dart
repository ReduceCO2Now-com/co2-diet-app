import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:co2diet/core/di/notification_providers.dart';
import 'package:co2diet/core/theme/color_tokens.dart';
import 'package:co2diet/core/theme/spacing_tokens.dart';
import 'package:co2diet/core/theme/text_tokens.dart';
import 'package:co2diet/domain/entities/weight_settings.dart';
import 'package:co2diet/features/weight/providers/weight_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Weekday dropdown labels, ISO-8601 numbering (1 = Monday .. 7 = Sunday),
/// matching [WeightSettings.reminderWeekday]'s documented convention.
const Map<int, String> _weekdayLabels = {
  DateTime.monday: 'Monday',
  DateTime.tuesday: 'Tuesday',
  DateTime.wednesday: 'Wednesday',
  DateTime.thursday: 'Thursday',
  DateTime.friday: 'Friday',
  DateTime.saturday: 'Saturday',
  DateTime.sunday: 'Sunday',
};

/// Default reminder time used for every non-Custom frequency (Weekly,
/// 2-Weekly, Monthly) -- only the Custom frequency exposes a day + time
/// picker per this widget's spec.
const _defaultReminderTime = '09:00';

/// Weigh-in reminder configuration section (WT-04 / NOTIF-02): frequency
/// (Never/Weekly/2-Weekly/Monthly/Custom), a conditional weekday + time
/// picker shown only for Custom, and an enable toggle.
///
/// Enabling the reminder for the first time calls
/// `NotificationService.requestPermissionIfNeeded` before
/// `scheduleWeighInReminder` -- denial reverts the toggle to off and shows
/// an inline "Open Settings" recovery link (no full-screen block, per
/// CONTEXT.md's lightweight permission-denied pattern).
///
/// `NotificationService` is obtained via
/// `ref.read(notificationServiceProvider)` -- the single provider
/// registered by Plan 05-08 (`lib/core/di/notification_providers.dart`);
/// this widget never declares a competing provider for it.
class WeighInReminderSection extends ConsumerStatefulWidget {
  /// Creates a [WeighInReminderSection] reflecting the current [settings].
  const WeighInReminderSection({required this.settings, super.key});

  /// The current goal/reminder settings, owned by `WeightScreen` (which
  /// watches `weightProvider`).
  final WeightSettings settings;

  @override
  ConsumerState<WeighInReminderSection> createState() =>
      _WeighInReminderSectionState();
}

class _WeighInReminderSectionState
    extends ConsumerState<WeighInReminderSection> {
  late String _frequency;
  late bool _enabled;
  late int _weekday;
  late String _time;
  String? _permissionDeniedMessage;

  @override
  void initState() {
    super.initState();
    _syncFromSettings(widget.settings);
  }

  @override
  void didUpdateWidget(covariant WeighInReminderSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings != widget.settings) {
      _syncFromSettings(widget.settings);
    }
  }

  void _syncFromSettings(WeightSettings settings) {
    _frequency = settings.reminderFrequency ?? 'never';
    _enabled = settings.reminderEnabled;
    _weekday = settings.reminderWeekday ?? DateTime.monday;
    _time = settings.reminderTime ?? _defaultReminderTime;
  }

  Future<void> _onFrequencyChanged(String? value) async {
    if (value == null) return;
    setState(() => _frequency = value);

    if (value == 'never') {
      await _disable();
    } else if (_enabled) {
      await _reschedule();
    }
  }

  Future<void> _onToggleChanged(bool value) async {
    if (!value) {
      await _disable();
      return;
    }

    final notificationService = ref.read(notificationServiceProvider);
    final granted = await notificationService.requestPermissionIfNeeded();
    if (!granted) {
      if (!mounted) return;
      setState(() {
        _enabled = false;
        _permissionDeniedMessage =
            'Notification permission denied -- open Settings to allow it.';
      });
      return;
    }

    setState(() {
      _enabled = true;
      _permissionDeniedMessage = null;
    });
    await _reschedule();
  }

  Future<void> _reschedule() async {
    final notificationService = ref.read(notificationServiceProvider);
    final scheduled = await notificationService.scheduleWeighInReminder(
      frequency: _frequency,
      time: _time,
      weekday: _frequency == 'custom' ? _weekday : null,
    );

    if (!scheduled) {
      if (!mounted) return;
      setState(() {
        _enabled = false;
        _permissionDeniedMessage = 'Could not schedule the reminder.';
      });
      return;
    }

    await ref
        .read(weightProvider.notifier)
        .saveReminderSettings(
          frequency: _frequency,
          enabled: true,
          weekday: _frequency == 'custom' ? _weekday : null,
          time: _time,
        );
  }

  Future<void> _disable() async {
    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.cancelWeighInReminder();
    if (mounted) setState(() => _enabled = false);
    await ref
        .read(weightProvider.notifier)
        .saveReminderSettings(
          frequency: _frequency,
          enabled: false,
          weekday: _frequency == 'custom' ? _weekday : null,
          time: _time,
        );
  }

  Future<void> _pickTime() async {
    final parts = _time.split(':');
    final initial = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;

    setState(() {
      _time =
          '${picked.hour.toString().padLeft(2, '0')}:'
          '${picked.minute.toString().padLeft(2, '0')}';
    });
    if (_enabled) await _reschedule();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Weigh-in Reminder', style: AppTextTheme.titleMd),
        const SizedBox(height: AppSpacing.stackGap),
        DropdownButtonFormField<String>(
          initialValue: _frequency,
          decoration: const InputDecoration(labelText: 'Frequency'),
          items: const [
            DropdownMenuItem(value: 'never', child: Text('Never')),
            DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
            DropdownMenuItem(value: 'biweekly', child: Text('2-Weekly')),
            DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
            DropdownMenuItem(value: 'custom', child: Text('Custom')),
          ],
          onChanged: (value) => unawaited(_onFrequencyChanged(value)),
        ),
        if (_frequency == 'custom') ...[
          const SizedBox(height: AppSpacing.stackGap),
          DropdownButtonFormField<int>(
            initialValue: _weekday,
            decoration: const InputDecoration(labelText: 'Day of week'),
            items: [
              for (final entry in _weekdayLabels.entries)
                DropdownMenuItem(value: entry.key, child: Text(entry.value)),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _weekday = value);
              if (_enabled) unawaited(_reschedule());
            },
          ),
          const SizedBox(height: AppSpacing.stackGap),
          InkWell(
            onTap: () => unawaited(_pickTime()),
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Time'),
              child: Text(_time),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.stackGap),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Enable reminder'),
          value: _enabled,
          onChanged: _frequency == 'never'
              ? null
              : (value) => unawaited(_onToggleChanged(value)),
        ),
        if (_permissionDeniedMessage != null) ...[
          Text(
            _permissionDeniedMessage!,
            style: AppTextTheme.bodySm.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: AppSpacing.base),
          const TextButton(
            onPressed: AppSettings.openAppSettings,
            child: Text('Open Settings'),
          ),
        ],
      ],
    );
  }
}
