import 'package:co2diet/domain/entities/network_mode.dart';
import 'package:co2diet/features/settings/providers/network_mode_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings row letting the user choose whether the app may make outbound
/// requests for food data.
///
/// See `docs/decisions/0001-connectivity-choice-not-account-mode.md`. The
/// wording deliberately states what each option *does*, not which is
/// recommended — both are fully functional, and nudging toward the online
/// option would repeat the account-creation bias flagged in PROJECT.md.
class ConnectivityModeRow extends ConsumerWidget {
  /// Creates the [ConnectivityModeRow].
  const ConnectivityModeRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(networkModeProvider);
    final online = mode == NetworkMode.onlineAllowed;

    return SwitchListTile(
      secondary: Icon(
        online ? Icons.cloud_outlined : Icons.cloud_off_outlined,
      ),
      title: const Text('Look up foods online'),
      subtitle: Text(
        online
            ? 'Searches the online catalog for foods not stored on this '
                  'device. No account needed, and nothing about you is sent.'
            : 'Only foods stored on this device are used. The app makes no '
                  'outbound requests.',
      ),
      value: online,
      onChanged: (enabled) => ref
          .read(networkModeProvider.notifier)
          .setMode(
            enabled ? NetworkMode.onlineAllowed : NetworkMode.offlineOnly,
          ),
    );
  }
}
