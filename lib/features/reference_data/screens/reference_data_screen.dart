// The dedicated Reference Data download/progress/revert screen
// (09-CONTEXT.md's "Entry Point & Settings Screen Structure" and "Download
// Reliability & Wi-Fi Override" decision blocks) -- mirrors
// BackupRestoreScreen's Scaffold+AppBar shell.

import 'dart:async';

import 'package:co2diet/core/theme/spacing_tokens.dart';
import 'package:co2diet/core/theme/text_tokens.dart';
import 'package:co2diet/domain/entities/reference_pack_manifest.dart';
import 'package:co2diet/domain/entities/reference_pack_status.dart';
import 'package:co2diet/features/reference_data/providers/reference_pack_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// The dedicated screen behind the Settings row's "Download full food
/// database" entry (`ReferenceDataRow`).
class ReferenceDataScreen extends ConsumerStatefulWidget {
  /// Creates the [ReferenceDataScreen].
  const ReferenceDataScreen({super.key});

  @override
  ConsumerState<ReferenceDataScreen> createState() =>
      _ReferenceDataScreenState();
}

class _ReferenceDataScreenState extends ConsumerState<ReferenceDataScreen> {
  int? _localProductCount;
  ReferencePackManifest? _manifest;
  bool _busy = false;
  String? _blockingMessage;
  ReferencePackStatus? _lastStatus;

  @override
  void initState() {
    super.initState();
    unawaited(_loadComparisonCounts());
  }

  Future<void> _loadComparisonCounts() async {
    final notifier = ref.read(referencePackProvider.notifier);
    final local = await notifier.localProductCount();
    ReferencePackManifest? manifest;
    try {
      manifest = await notifier.checkForUpdate();
    } on Exception {
      // Offline / network failure -- the comparison just omits the remote
      // count rather than blocking the screen from rendering at all.
      manifest = null;
    }
    if (mounted) {
      setState(() {
        _localProductCount = local;
        _manifest = manifest;
      });
    }
  }

  Future<void> _handleDownload() async {
    final notifier = ref.read(referencePackProvider.notifier);
    setState(() {
      _busy = true;
      _blockingMessage = null;
    });
    try {
      final manifest = await notifier.checkForUpdate();
      if (mounted) setState(() => _manifest = manifest);

      final hasSpace = await notifier.hasEnoughDiskSpace(manifest);
      if (!hasSpace) {
        final neededMb =
            (notifier.estimatedRequiredDiskSpaceBytes(manifest) /
                    (1024 * 1024))
                .round();
        final freeMb =
            (await notifier.freeDiskSpaceBytes() / (1024 * 1024)).round();
        if (mounted) {
          setState(() {
            _blockingMessage =
                'Not enough storage — need ~${neededMb}MB, only '
                '${freeMb}MB free';
          });
        }
        return;
      }

      final onWifi = await notifier.isOnWifi();
      if (onWifi) {
        await notifier.startFullDownload(allowCellular: false);
        return;
      }

      if (!mounted) return;
      final useCellular = await _confirmCellularOverride();
      if (useCellular ?? false) {
        await notifier.startFullDownload(allowCellular: true);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool?> _confirmCellularOverride() {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Not on Wi-Fi'),
        content: const Text(
          'Not on Wi-Fi — download over cellular anyway?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Use cellular data'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleResume() async {
    setState(() => _busy = true);
    try {
      await ref.read(referencePackProvider.notifier).resumeDownload();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _handleCancel() async {
    await ref.read(referencePackProvider.notifier).cancelDownload();
  }

  Future<void> _handleRevert(int installedSizeBytes) async {
    final installedMb = (installedSizeBytes / (1024 * 1024)).round();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Revert to starter pack?'),
        content: Text(
          'Revert to starter pack? This deletes the full catalog '
          '(${installedMb}MB) and reduces search coverage back to the '
          'starter set.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Revert'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref.read(referencePackProvider.notifier).revertToSeed();
    }
  }

  String _formatCompact(int count) => NumberFormat.compact().format(count);

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(referencePackProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // Brief success confirmation the moment the status transitions from
    // Downloading to Full (09-CONTEXT.md: "Brief success confirmation on
    // completion before settling to the at-rest state").
    final currentStatus = statusAsync.value;
    if (currentStatus != null &&
        _lastStatus is ReferencePackDownloading &&
        currentStatus is ReferencePackFull) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download complete')),
        );
      });
    }
    _lastStatus = currentStatus;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Download full food database',
          style: AppTextTheme.headlineLgMobile,
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: statusAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) =>
              const Center(child: Text('Unable to load reference data status')),
          data: _buildBody,
        ),
      ),
    );
  }

  Widget _buildBody(ReferencePackStatus status) {
    return switch (status) {
      ReferencePackSeed() => _buildDownloadPrompt(
        statusText: 'Using starter pack',
        buttonLabel: 'Download',
        onPressed: _handleDownload,
      ),
      ReferencePackDownloading(:final bytesDownloaded, :final bytesTotal) =>
        _buildDownloading(bytesDownloaded, bytesTotal),
      ReferencePackFull() => _buildFull(),
      ReferencePackUpdateAvailable(:final waitingForWifi) =>
        _buildDownloadPrompt(
          statusText: waitingForWifi
              ? 'Update available — connect to Wi-Fi'
              : 'Update available',
          buttonLabel: 'Download',
          onPressed: _handleDownload,
        ),
      ReferencePackFailed(:final message) => _buildDownloadPrompt(
        statusText: message,
        buttonLabel: 'Resume',
        onPressed: _handleResume,
      ),
    };
  }

  Widget _buildDownloadPrompt({
    required String statusText,
    required String buttonLabel,
    required Future<void> Function() onPressed,
  }) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.containerMargin),
      children: [
        Text(statusText, style: AppTextTheme.titleMd),
        const SizedBox(height: AppSpacing.lg),
        _buildProductCountComparison(),
        const SizedBox(height: AppSpacing.lg),
        if (_blockingMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _blockingMessage!,
              style: AppTextTheme.bodySm.copyWith(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.stackGap),
        ],
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _busy ? null : () => unawaited(onPressed()),
            child: Text(buttonLabel),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCountComparison() {
    final localText = _localProductCount != null
        ? '${_formatCompact(_localProductCount!)} products (starter pack)'
        : null;
    final remoteText = _manifest != null
        ? '${_formatCompact(_manifest!.productCount)} products (full '
              'catalog)'
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (localText != null) Text(localText, style: AppTextTheme.bodyLg),
        if (remoteText != null) Text(remoteText, style: AppTextTheme.bodyLg),
      ],
    );
  }

  Widget _buildDownloading(int bytesDownloaded, int bytesTotal) {
    final progress = bytesTotal > 0 ? bytesDownloaded / bytesTotal : 0.0;
    final percent = (progress * 100).round();
    final downloadedMb = bytesDownloaded ~/ (1024 * 1024);
    final totalMb = bytesTotal ~/ (1024 * 1024);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.containerMargin),
      children: [
        LinearProgressIndicator(value: progress),
        const SizedBox(height: AppSpacing.stackGap),
        Text('$percent% — $downloadedMb/$totalMb MB'),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => unawaited(_handleCancel()),
            child: const Text('Cancel'),
          ),
        ),
      ],
    );
  }

  Widget _buildFull() {
    return Consumer(
      builder: (context, ref, _) {
        final sizeAsync = ref.watch(referencePackInstalledSizeBytesProvider);
        final bytes = sizeAsync.value ?? 0;
        final mb = (bytes / (1024 * 1024)).round();
        final status = ref.watch(referencePackProvider).value;
        final downloading = status is ReferencePackDownloading;
        final installedVersion = status is ReferencePackFull
            ? status.installedVersion
            : null;

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.containerMargin),
          children: [
            if (installedVersion != null)
              Text(
                'Full catalog installed — $installedVersion ($mb MB)',
                style: AppTextTheme.titleMd,
              ),
            const SizedBox(height: AppSpacing.lg),
            _buildProductCountComparison(),
            const SizedBox(height: AppSpacing.lg),
            TextButton(
              onPressed: downloading
                  ? null
                  : () => unawaited(_handleRevert(bytes)),
              child: const Text('Revert to starter pack'),
            ),
          ],
        );
      },
    );
  }
}
