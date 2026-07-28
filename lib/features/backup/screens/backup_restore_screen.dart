import 'dart:async';

import 'package:co2diet/core/di/backup_providers.dart';
import 'package:co2diet/core/theme/color_tokens.dart';
import 'package:co2diet/core/theme/spacing_tokens.dart';
import 'package:co2diet/core/theme/text_tokens.dart';
import 'package:co2diet/domain/entities/backup_metadata.dart';
import 'package:co2diet/domain/services/backup_export_service.dart';
import 'package:co2diet/features/backup/providers/backup_notifier.dart';
import 'package:co2diet/features/backup/widgets/danger_zone_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Human-readable label for each [ExportCategory], used in the Storage
/// Status card and the Export Data category multi-select.
const Map<ExportCategory, String> _categoryLabels = {
  ExportCategory.profile: 'Profile',
  ExportCategory.mealEntries: 'Meal entries',
  ExportCategory.favorites: 'Favorites',
  ExportCategory.customFoods: 'Custom foods',
  ExportCategory.weightEntries: 'Weigh-ins',
  ExportCategory.co2Settings: 'CO2 settings',
  ExportCategory.notificationPrefs: 'Notification preferences',
};

/// Human-readable label for each [ExportFormat], used in Export Data's
/// format multi-select.
const Map<ExportFormat, String> _formatLabels = {
  ExportFormat.csv: 'CSV',
  ExportFormat.excel: 'Excel (.xlsx)',
  ExportFormat.json: 'JSON',
};

/// Exact Privacy & Ownership disclosure copy (RESEARCH.md Open Question 1,
/// 05-CONTEXT.md Planning Addendum) -- shared backups/exports are not
/// encrypted by this app.
const _privacyStatement =
    'Exports and backups are not encrypted by this app. Anyone with '
    'access to a shared file can read its contents — you are '
    'responsible for the security of wherever you send it (e.g. use a '
    'private cloud folder, not a public share link).';

/// The Backup & Restore screen (PRIV-01 through PRIV-04, PRIV-08, PRIV-09):
/// Current Storage Status, Create Backup, Automatic Backups, Export Data,
/// Restore Data (via a real OS file picker), Privacy & Ownership
/// statement, and a typed-confirmation Danger Zone.
///
/// Not yet wired into `app_router.dart` or linked from `SettingsScreen` --
/// Plan 05-18 adds both once every Wave 5 screen exists (mirrors
/// `Co2SettingsScreen`'s Plan 05-12 precedent).
class BackupRestoreScreen extends ConsumerWidget {
  /// Creates the [BackupRestoreScreen].
  const BackupRestoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metadataAsync = ref.watch(backupProvider);
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Backup & Restore',
          style: AppTextTheme.headlineLgMobile,
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: metadataAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) =>
              const Center(child: Text('Error loading backup settings')),
          data: (metadata) => _BackupRestoreBody(metadata: metadata),
        ),
      ),
    );
  }
}

/// Assembles every section, in order: Current Storage Status, Create
/// Backup, Automatic Backups, Export Data, Restore Data, Privacy &
/// Ownership statement, Danger Zone.
class _BackupRestoreBody extends ConsumerStatefulWidget {
  const _BackupRestoreBody({required this.metadata});

  final BackupMetadata metadata;

  @override
  ConsumerState<_BackupRestoreBody> createState() =>
      _BackupRestoreBodyState();
}

class _BackupRestoreBodyState extends ConsumerState<_BackupRestoreBody> {
  Map<ExportCategory, int>? _storageStatus;
  final Set<ExportCategory> _exportCategories = {};
  final Set<ExportFormat> _exportFormats = {ExportFormat.csv};
  RestorePreview? _restorePreview;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadStorageStatus());
  }

  Future<void> _loadStorageStatus() async {
    final service = await ref.read(backupExportServiceProvider.future);
    final status = await service.storageStatus();
    if (mounted) setState(() => _storageStatus = status);
  }

  Future<void> _createBackup() async {
    setState(() => _busy = true);
    try {
      await ref.read(backupProvider.notifier).createAndShareBackup();
      await _loadStorageStatus();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _shareExport() async {
    if (_exportCategories.isEmpty || _exportFormats.isEmpty) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(backupProvider.notifier)
          .shareExport(categories: _exportCategories, formats: _exportFormats);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _chooseRestoreFile() async {
    setState(() => _busy = true);
    try {
      final preview = await ref
          .read(backupProvider.notifier)
          .pickAndPreviewRestoreFile();
      // A null preview means the picker was cancelled -- leave the
      // screen unchanged, no error shown.
      if (mounted) setState(() => _restorePreview = preview);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmRestore() async {
    final notifier = ref.read(backupProvider.notifier);
    final zip = notifier.pendingRestoreFile;
    if (zip == null) return;

    setState(() => _busy = true);
    try {
      await notifier.applyRestore(zip);
      await _loadStorageStatus();
      if (mounted) setState(() => _restorePreview = null);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _clearAllLocalData() async {
    final service = await ref.read(backupExportServiceProvider.future);
    await service.clearAllLocalData();
    await _loadStorageStatus();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.containerMargin),
      children: [
        // ── Current Storage Status ─────────────────────────────────────
        const Text('Current Storage Status', style: AppTextTheme.titleMd),
        const SizedBox(height: AppSpacing.stackGap),
        if (_storageStatus == null)
          const Center(child: CircularProgressIndicator())
        else
          for (final category in ExportCategory.values)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.base),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_categoryLabels[category]!),
                  Text('${_storageStatus![category] ?? 0}'),
                ],
              ),
            ),
        const SizedBox(height: AppSpacing.lg),

        // ── Create Backup ────────────────────────────────────────────
        const Text('Create Backup', style: AppTextTheme.titleMd),
        const SizedBox(height: AppSpacing.stackGap),
        if (widget.metadata.lastBackupAt != null)
          Text(
            'Last backup: ${widget.metadata.lastBackupAt}',
            style: AppTextTheme.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        const SizedBox(height: AppSpacing.stackGap),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _busy ? null : () => unawaited(_createBackup()),
            child: const Text('Create backup'),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Automatic Backups ─────────────────────────────────────────
        const Text('Automatic Backups', style: AppTextTheme.titleMd),
        const SizedBox(height: AppSpacing.stackGap),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'off', label: Text('Off')),
            ButtonSegment(value: 'daily', label: Text('Daily')),
            ButtonSegment(value: 'weekly', label: Text('Weekly')),
          ],
          selected: {widget.metadata.autoBackupFrequency},
          onSelectionChanged: (selected) => unawaited(
            ref
                .read(backupProvider.notifier)
                .saveAutoBackupFrequency(selected.first),
          ),
          showSelectedIcon: false,
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Export Data ───────────────────────────────────────────────
        const Text('Export Data', style: AppTextTheme.titleMd),
        const SizedBox(height: AppSpacing.stackGap),
        Wrap(
          spacing: AppSpacing.base,
          children: [
            for (final category in ExportCategory.values)
              FilterChip(
                label: Text(_categoryLabels[category]!),
                selected: _exportCategories.contains(category),
                onSelected: (selected) => setState(() {
                  if (selected) {
                    _exportCategories.add(category);
                  } else {
                    _exportCategories.remove(category);
                  }
                }),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.stackGap),
        Wrap(
          spacing: AppSpacing.base,
          children: [
            for (final format in ExportFormat.values)
              FilterChip(
                label: Text(_formatLabels[format]!),
                selected: _exportFormats.contains(format),
                onSelected: (selected) => setState(() {
                  if (selected) {
                    _exportFormats.add(format);
                  } else {
                    _exportFormats.remove(format);
                  }
                }),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.stackGap),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed:
                _busy ||
                    _exportCategories.isEmpty ||
                    _exportFormats.isEmpty
                ? null
                : () => unawaited(_shareExport()),
            child: const Text('Share export'),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Restore Data ──────────────────────────────────────────────
        const Text('Restore Data', style: AppTextTheme.titleMd),
        const SizedBox(height: AppSpacing.stackGap),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _busy ? null : () => unawaited(_chooseRestoreFile()),
            child: const Text('Choose backup file'),
          ),
        ),
        if (_restorePreview != null) ...[
          const SizedBox(height: AppSpacing.stackGap),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('This backup will restore:'),
                const SizedBox(height: AppSpacing.base),
                for (final entry in _restorePreview!.categoryRowCounts.entries)
                  Text(
                    '${_categoryLabels[entry.key] ?? entry.key.name}: '
                    '${entry.value} row(s)',
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.stackGap),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _busy ? null : () => unawaited(_confirmRestore()),
              child: const Text('Confirm Restore'),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),

        // ── Privacy & Ownership ───────────────────────────────────────
        const Text('Privacy & Ownership', style: AppTextTheme.titleMd),
        const SizedBox(height: AppSpacing.stackGap),
        Text(
          _privacyStatement,
          style: AppTextTheme.bodySm.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Danger Zone ───────────────────────────────────────────────
        DangerZoneSection(onConfirmedDelete: _clearAllLocalData),
      ],
    );
  }
}
