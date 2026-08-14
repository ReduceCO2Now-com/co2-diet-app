// The Settings row for the Reference Data (full OFF catalog) download
// feature (09-CONTEXT.md's "Entry Point & Settings Screen Structure"):
// mirrors every existing SettingsScreen row's ListTile shape, showing a
// live status subtitle sourced from `referencePackProvider` and
// navigating to the dedicated `/reference-data` screen on tap regardless
// of status.

import 'package:co2diet/domain/entities/reference_pack_status.dart';
import 'package:co2diet/features/reference_data/providers/reference_pack_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The "Download full food database" Settings row.
///
/// Subtitle mirrors `09-CONTEXT.md`'s locked copy examples exactly:
/// "Using starter pack" / "Downloading… X/Y MB" / "Full catalog installed
/// — N MB" / "Update available — connect to Wi-Fi" / "Update available" /
/// "Download paused — tap to resume".
class ReferenceDataRow extends ConsumerWidget {
  /// Creates the [ReferenceDataRow].
  const ReferenceDataRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(referencePackProvider);
    return ListTile(
      leading: const Icon(Icons.cloud_download_outlined),
      title: const Text('Download full food database'),
      subtitle: _ReferenceDataSubtitle(statusAsync: statusAsync),
      onTap: () => context.push('/reference-data'),
    );
  }
}

/// Renders the row's subtitle from [statusAsync] -- a separate
/// [ConsumerWidget] (rather than a plain string-returning function) since
/// the [ReferencePackFull] case needs to `ref.watch` the installed size
/// reactively (`referencePackInstalledSizeBytesProvider`), which a
/// synchronous string builder can't do.
class _ReferenceDataSubtitle extends ConsumerWidget {
  const _ReferenceDataSubtitle({required this.statusAsync});

  final AsyncValue<ReferencePackStatus> statusAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = statusAsync.value;
    if (status == null) {
      return Text(
        statusAsync.hasError ? 'Unable to load status' : 'Checking status…',
      );
    }

    return switch (status) {
      ReferencePackSeed() => const Text('Using starter pack'),
      ReferencePackDownloading(:final bytesDownloaded, :final bytesTotal) =>
        Text(
          'Downloading… ${bytesDownloaded ~/ (1024 * 1024)}/'
          '${bytesTotal ~/ (1024 * 1024)} MB',
        ),
      ReferencePackFull() => const _InstalledSizeText(),
      ReferencePackUpdateAvailable(:final waitingForWifi) => Text(
        waitingForWifi
            ? 'Update available — connect to Wi-Fi'
            : 'Update available',
      ),
      ReferencePackFailed() => const Text('Download paused — tap to resume'),
    };
  }
}

/// Renders "Full catalog installed — N MB" from the real, measured
/// installed file size (`referencePackInstalledSizeBytesProvider`) --
/// never a hardcoded number.
class _InstalledSizeText extends ConsumerWidget {
  const _InstalledSizeText();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sizeAsync = ref.watch(referencePackInstalledSizeBytesProvider);
    final bytes = sizeAsync.value;
    if (bytes == null) {
      return const Text('Full catalog installed');
    }
    final mb = (bytes / (1024 * 1024)).round();
    return Text('Full catalog installed — $mb MB');
  }
}
