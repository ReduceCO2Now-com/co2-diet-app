import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/daos/backup_metadata_dao.dart';
import 'package:co2diet/data/local/daos/co2_settings_dao.dart';
import 'package:co2diet/data/local/daos/meal_entry_dao.dart';
import 'package:co2diet/data/local/daos/notification_prefs_dao.dart';
import 'package:co2diet/data/local/daos/user_food_dao.dart';
import 'package:co2diet/data/local/daos/user_profile_dao.dart';
import 'package:co2diet/data/local/daos/weight_dao.dart';
import 'package:co2diet/data/local/mixins/sync_safe_table.dart';
import 'package:csv/csv.dart' hide excel;
import 'package:drift/drift.dart' show Value, ValueSerializer;
import 'package:excel/excel.dart' as xls;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

/// Every category of locally stored data that can be exported/backed up
/// (PRIV-01 through PRIV-04). Each value is used verbatim (via `.name`) as
/// both the manifest's `category` field and the per-category file's base
/// name, so it must never be renamed without a `formatVersion` bump.
enum ExportCategory {
  /// The single-row user profile (`UserProfileTable`).
  profile,

  /// Every non-deleted logged meal entry (`MealEntryTable`).
  mealEntries,

  /// Every favorited food (`FavoriteTable`).
  favorites,

  /// Every custom food and personal override (`UserFoodTable`).
  customFoods,

  /// Every non-deleted logged weigh-in (`WeightEntryTable`).
  weightEntries,

  /// The single-row personal CO2 footprint settings (`Co2SettingsTable`).
  co2Settings,

  /// The single-row per-meal-slot reminder configuration
  /// (`NotificationPrefsTable`).
  notificationPrefs,
}

/// File formats [BackupExportService.exportData] can encode a category
/// into.
enum ExportFormat {
  /// `ListToCsvConverter`-equivalent (`CsvEncoder` in `csv` 8.0.0).
  csv,

  /// Genuine `.xlsx` via the `excel` package.
  excel,

  /// `dart:convert`'s `jsonEncode`. The only format
  /// [BackupExportService.applyRestore] parses back — `createBackup`
  /// always writes JSON-only zips for this reason.
  json,
}

/// Thrown by [BackupExportService.applyRestore] when a zip entry's
/// normalized path would resolve outside the target extraction directory
/// (zip-slip / path traversal, T-05-09-01). The entire restore is aborted
/// before any database write when this is thrown.
class ZipSlipException implements Exception {
  /// Creates a [ZipSlipException] for the offending [entryName].
  ZipSlipException(this.entryName);

  /// The raw, untrusted archive entry name that failed validation.
  final String entryName;

  @override
  String toString() =>
      'ZipSlipException: archive entry "$entryName" resolves outside the '
      'target extraction directory';
}

/// Thrown when a backup zip's `manifest.json` declares a `formatVersion`
/// this app build does not know how to restore. A future encryption or
/// restructured backup format bump is detected here rather than silently
/// misparsed (05-CONTEXT.md Planning Addendum).
class UnsupportedBackupFormatException implements Exception {
  /// Creates an [UnsupportedBackupFormatException] for the offending
  /// [formatVersion].
  UnsupportedBackupFormatException(this.formatVersion);

  /// The unrecognized `formatVersion` value found in the manifest.
  final int formatVersion;

  @override
  String toString() =>
      'UnsupportedBackupFormatException: manifest formatVersion '
      '$formatVersion is not supported by this app version';
}

/// Thrown when a zip cannot be parsed as a valid backup archive (missing
/// or malformed `manifest.json`, or a manifest referencing a file that
/// isn't actually present in the zip).
class InvalidBackupArchiveException implements Exception {
  /// Creates an [InvalidBackupArchiveException] with a human-readable
  /// [reason].
  InvalidBackupArchiveException(this.reason);

  /// Why the archive was rejected.
  final String reason;

  @override
  String toString() => 'InvalidBackupArchiveException: $reason';
}

/// Summary of a backup zip's contents, returned by
/// [BackupExportService.previewRestore] without writing anything to disk
/// (PRIV-04 — "preview of what will be restored... explicit confirmation
/// before any data is overwritten").
@immutable
class RestorePreview {
  /// Creates an immutable [RestorePreview].
  const RestorePreview({
    required this.formatVersion,
    required this.backupDate,
    required this.categoryRowCounts,
  });

  /// The manifest's `formatVersion` value (currently always `1`).
  final int formatVersion;

  /// When the backup was created, parsed from the manifest's `createdAt`
  /// field, or `null` if the manifest omitted it.
  final DateTime? backupDate;

  /// How many rows each included [ExportCategory] contains.
  final Map<ExportCategory, int> categoryRowCounts;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RestorePreview &&
          runtimeType == other.runtimeType &&
          formatVersion == other.formatVersion &&
          backupDate == other.backupDate &&
          mapEquals(categoryRowCounts, other.categoryRowCounts);

  @override
  int get hashCode =>
      Object.hash(formatVersion, backupDate, Object.hashAll(
        categoryRowCounts.entries.map((e) => Object.hash(e.key, e.value)),
      ));

  @override
  String toString() => 'RestorePreview('
      'formatVersion: $formatVersion, '
      'backupDate: $backupDate, '
      'categoryRowCounts: $categoryRowCounts)';
}

/// A [ValueSerializer] used for every Drift row's `toJson`/`fromJson` call
/// in this file. Drift's own [ValueSerializer.defaults] passes `BigInt`
/// values through untouched, which `dart:convert`'s `jsonEncode` cannot
/// encode (it isn't a `num`/`String`/`bool`/`List`/`Map`/`null`) — every
/// sync-safe row's `hlcMillis` column is a `BigInt`. This serializer
/// stringifies `BigInt` and ISO-8601-encodes `DateTime` instead, so every
/// row round-trips cleanly through `jsonEncode`/`jsonDecode`.
class _BackupValueSerializer extends ValueSerializer {
  const _BackupValueSerializer();

  @override
  T fromJson<T>(dynamic json) {
    if (json == null) return null as T;

    final typeList = <T>[];
    if (typeList is List<DateTime?>) {
      return DateTime.parse(json.toString()) as T;
    }
    if (typeList is List<BigInt?>) {
      return BigInt.parse(json.toString()) as T;
    }
    if (typeList is List<double?> && json is int) {
      return json.toDouble() as T;
    }

    return json as T;
  }

  @override
  dynamic toJson<T>(T value) {
    if (value is DateTime) return value.toIso8601String();
    if (value is BigInt) return value.toString();
    return value;
  }
}

/// Local domain service that generates export/backup zips (CSV/Excel/JSON
/// + `manifest.json`), previews and applies restores with zip-slip
/// protection, and tracks automatic-backup scheduling metadata
/// (PRIV-01 through PRIV-04, PRIV-08).
///
/// Fully offline: this service never instantiates `OffApiClient` or checks
/// `Connectivity` — every read/write here is local Drift DAO access and
/// local file I/O.
///
/// The `documentsDir` constructor parameter (rather than calling
/// `path_provider` internally) is what makes this class testable without
/// a platform channel — tests pass a `Directory.systemTemp.createTempSync()`
/// directory instead.
class BackupExportService {
  /// Creates a [BackupExportService] backed by every DAO it reads from and
  /// writes to, plus the app's documents directory.
  BackupExportService({
    required this.mealEntryDao,
    required this.userFoodDao,
    required this.weightDao,
    required this.co2SettingsDao,
    required this.notificationPrefsDao,
    required this.userProfileDao,
    required this.backupMetadataDao,
    required this.documentsDir,
  });

  /// Reads/writes logged meal entries and favorites.
  final MealEntryDao mealEntryDao;

  /// Reads/writes custom foods and personal overrides.
  final UserFoodDao userFoodDao;

  /// Reads/writes logged weigh-ins.
  final WeightDao weightDao;

  /// Reads/writes the personal CO2 footprint settings.
  final Co2SettingsDao co2SettingsDao;

  /// Reads/writes per-meal-slot reminder configuration.
  final NotificationPrefsDao notificationPrefsDao;

  /// Reads/writes the single-row user profile.
  final UserProfileDao userProfileDao;

  /// Reads/writes `autoBackupFrequency`/`lastBackupAt`/`lastBackupPath`.
  final BackupMetadataDao backupMetadataDao;

  /// The app's documents directory — every export/backup zip is written
  /// here, never to a user-chosen external path.
  final Directory documentsDir;

  static const _uuid = Uuid();
  static const _serializer = _BackupValueSerializer();

  /// `manifest.json`'s `formatVersion` produced by this build. Locked at
  /// `1` per 05-CONTEXT.md's Planning Addendum — a future encryption or
  /// restructured backup format bumps this, and [previewRestore]/
  /// [applyRestore] reject any other value with a clear typed exception
  /// rather than silently misparsing an incompatible archive.
  static const currentFormatVersion = 1;

  /// Generates a single zip containing `manifest.json` plus one encoded
  /// file per requested `category` x `format` combination.
  ///
  /// [fileNamePrefix] controls the output zip's base filename (before the
  /// timestamp + `.zip` suffix) — [createBackup] uses a different prefix
  /// than a plain user-initiated export.
  ///
  /// [includeInternalFields] controls whether each row's
  /// [_internalFieldNames] (the [SyncSafeTable]-injected sync-machinery
  /// columns) are included in the encoded output. [createBackup] passes
  /// `true` — [applyRestore] reconstructs a full [ExportCategory] row via
  /// `fromJson`, which requires every column to be present. A plain
  /// human-facing export (the default, `false`) strips them: they're
  /// meaningless to a person reading a CSV/Excel/JSON export of their own
  /// data, and were previously leaking into every category's export file.
  Future<File> exportData({
    required Set<ExportCategory> categories,
    required Set<ExportFormat> formats,
    String fileNamePrefix = 'co2diet_export',
    bool includeInternalFields = false,
  }) async {
    final zipPath = p.join(
      documentsDir.path,
      '${fileNamePrefix}_${DateTime.now().millisecondsSinceEpoch}.zip',
    );
    final encoder = ZipFileEncoder()..create(zipPath);

    final manifestFiles = <Map<String, dynamic>>[];

    for (final category in categories) {
      final rawRows = await _readCategoryRows(category);
      final rows = includeInternalFields
          ? rawRows
          : _stripInternalFields(rawRows);
      for (final format in formats) {
        final fileName = '${category.name}.${_extensionFor(format)}';
        final bytes = _encodeRows(rows, format);
        encoder.addArchiveFile(ArchiveFile(fileName, bytes.length, bytes));
        manifestFiles.add({
          'category': category.name,
          'format': format.name,
          'fileName': fileName,
          'rowCount': rows.length,
        });
      }
    }

    final manifest = <String, dynamic>{
      'formatVersion': currentFormatVersion,
      'createdAt': DateTime.now().toIso8601String(),
      'files': manifestFiles,
    };
    encoder.addArchiveFile(
      ArchiveFile.string('manifest.json', jsonEncode(manifest)),
    );

    await encoder.close();
    return File(zipPath);
  }

  /// Writes a full-data zip (every category, JSON format only — a backup
  /// is a full-fidelity restore source, not a human-readable export) to
  /// the app documents directory, then records `lastBackupAt`/
  /// `lastBackupPath` via [backupMetadataDao].
  Future<File> createBackup() async {
    final zipFile = await exportData(
      categories: ExportCategory.values.toSet(),
      formats: const {ExportFormat.json},
      fileNamePrefix: 'co2diet_backup',
      includeInternalFields: true,
    );

    final existing = await backupMetadataDao.getMetadata();
    final id = existing?.id ?? _uuid.v7();
    await backupMetadataDao.saveMetadata(
      BackupMetadataTableCompanion(
        id: Value(id),
        autoBackupFrequency: existing != null
            ? Value(existing.autoBackupFrequency)
            : const Value('off'),
        lastBackupAt: Value(DateTime.now()),
        lastBackupPath: Value(zipFile.path),
        // HLC Phase-1 placeholders — Phase 7 replaces with full HLC clock.
        hlcMillis: Value(BigInt.from(DateTime.now().millisecondsSinceEpoch)),
        hlcCounter: const Value(0),
        hlcNodeId: const Value('local'),
        dirty: const Value(true),
      ),
    );
    return zipFile;
  }

  /// Parses [zip] and returns a summary of what it contains (categories,
  /// row counts, backup date, `formatVersion`) without writing anything.
  ///
  /// Throws [InvalidBackupArchiveException] if `manifest.json` is missing
  /// or malformed, or [UnsupportedBackupFormatException] if the
  /// manifest's `formatVersion` isn't one this build understands.
  Future<RestorePreview> previewRestore(File zip) async {
    final archive = await _decodeZip(zip);
    final manifest = _readManifest(archive);
    return _restorePreviewFromManifest(manifest);
  }

  /// Returns the current row count per [ExportCategory] (Current Storage
  /// Status card). Reuses [_readCategoryRows] — acceptable cost for a
  /// settings screen, not a hot path.
  Future<Map<ExportCategory, int>> storageStatus() async {
    final counts = <ExportCategory, int>{};
    for (final category in ExportCategory.values) {
      final rows = await _readCategoryRows(category);
      counts[category] = rows.length;
    }
    return counts;
  }

  /// Permanently deletes every row of the user's own personal data
  /// (Danger Zone, PRIV-09) inside a single transaction.
  ///
  /// Deliberately excludes two tables:
  ///   - `UserFoodCacheTable` — a shared Open Food Facts API-response
  ///     cache, not personal data; wiping it would only force redundant
  ///     re-fetches, not protect privacy.
  ///   - `ConsentRecordsTable` — an append-only legal consent audit
  ///     trail; deleting it would destroy the record that consent was
  ///     ever given/withdrawn, which this app needs to retain independent
  ///     of a data wipe.
  ///
  /// Every other locally-stored personal-data table is truncated:
  /// profile, meal entries, favorites, custom foods/overrides, weigh-ins,
  /// weight goal/reminder settings, CO2 settings, notification
  /// preferences, and backup metadata.
  Future<void> clearAllLocalData() async {
    final db = mealEntryDao.attachedDatabase;
    await db.transaction(() async {
      await db.delete(db.mealEntryTable).go();
      await db.delete(db.favoriteTable).go();
      await db.delete(db.userFoodTable).go();
      await db.delete(db.weightEntryTable).go();
      await db.delete(db.weightSettingsTable).go();
      await db.delete(db.co2SettingsTable).go();
      await db.delete(db.notificationPrefsTable).go();
      await db.delete(db.backupMetadataTable).go();
      await db.delete(db.userProfileTable).go();
    });
  }

  /// Restores every category referenced by [zip]'s manifest.
  ///
  /// Every `ArchiveFile.name` in the zip is validated to resolve within
  /// [documentsDir] (zip-slip guard, T-05-09-01) BEFORE any entry is
  /// read or any database row is written — a single malicious/malformed
  /// entry throws [ZipSlipException] and aborts the entire restore,
  /// all-or-nothing. Only `format: 'json'` manifest entries are restored
  /// (CSV/Excel are export-only formats; [createBackup] always writes
  /// JSON-only zips).
  Future<void> applyRestore(File zip) async {
    final archive = await _decodeZip(zip);

    // Validate every entry's path before touching any of them.
    for (final entry in archive.files) {
      if (!_isPathSafe(entry.name, documentsDir)) {
        throw ZipSlipException(entry.name);
      }
    }

    final manifest = _readManifest(archive);
    // Fails fast on an unsupported formatVersion before any DAO write.
    _restorePreviewFromManifest(manifest);

    final filesList = (manifest['files'] as List<dynamic>)
        .cast<Map<String, dynamic>>();

    for (final fileEntry in filesList) {
      final formatName = fileEntry['format'] as String;
      if (formatName != ExportFormat.json.name) {
        continue;
      }

      final category = ExportCategory.values.byName(
        fileEntry['category'] as String,
      );
      final fileName = fileEntry['fileName'] as String;
      final dataFile = archive.findFile(fileName);
      if (dataFile == null) {
        throw InvalidBackupArchiveException(
          '$fileName referenced by manifest but missing from archive',
        );
      }

      final decoded = jsonDecode(_contentAsString(dataFile));
      final rows = (decoded as List<dynamic>).cast<Map<String, dynamic>>();
      await _restoreCategory(category, rows);
    }
  }

  // ---------------------------------------------------------------------
  // Reading categories (export)
  // ---------------------------------------------------------------------

  /// The columns [SyncSafeTable] injects onto every export category's
  /// backing table (`lib/data/local/mixins/sync_safe_table.dart`) —
  /// internal sync machinery, not user-meaningful data. Stripped from
  /// every human-facing export by [exportData] unless
  /// `includeInternalFields` is set (as [createBackup] does, since
  /// [applyRestore] needs the full row shape to reconstruct it).
  static const _internalFieldNames = {
    'id',
    'hlcMillis',
    'hlcCounter',
    'hlcNodeId',
    'dirty',
    'deletedAt',
  };

  List<Map<String, dynamic>> _stripInternalFields(
    List<Map<String, dynamic>> rows,
  ) {
    return [
      for (final row in rows)
        {
          for (final entry in row.entries)
            if (!_internalFieldNames.contains(entry.key))
              entry.key: entry.value,
        },
    ];
  }

  Future<List<Map<String, dynamic>>> _readCategoryRows(
    ExportCategory category,
  ) async {
    switch (category) {
      case ExportCategory.profile:
        final row = await userProfileDao.getProfile();
        return row == null ? [] : [row.toJson(serializer: _serializer)];
      case ExportCategory.mealEntries:
        final rows = await mealEntryDao.getAllEntries();
        return rows.map((r) => r.toJson(serializer: _serializer)).toList();
      case ExportCategory.favorites:
        final rows = await mealEntryDao.getFavorites();
        return rows.map((r) => r.toJson(serializer: _serializer)).toList();
      case ExportCategory.customFoods:
        final rows = await userFoodDao.getAllAlphabetical();
        return rows.map((r) => r.toJson(serializer: _serializer)).toList();
      case ExportCategory.weightEntries:
        final rows = await weightDao.getEntriesInRange();
        return rows.map((r) => r.toJson(serializer: _serializer)).toList();
      case ExportCategory.co2Settings:
        final row = await co2SettingsDao.getSettings();
        return row == null ? [] : [row.toJson(serializer: _serializer)];
      case ExportCategory.notificationPrefs:
        final row = await notificationPrefsDao.getPrefs();
        return row == null ? [] : [row.toJson(serializer: _serializer)];
    }
  }

  // ---------------------------------------------------------------------
  // Restoring categories (restore)
  // ---------------------------------------------------------------------

  Future<void> _restoreCategory(
    ExportCategory category,
    List<Map<String, dynamic>> rows,
  ) async {
    switch (category) {
      case ExportCategory.profile:
        if (rows.isEmpty) return;
        final row = UserProfileRow.fromJson(
          rows.first,
          serializer: _serializer,
        );
        await userProfileDao.upsertProfile(row.toCompanion(false));
      case ExportCategory.mealEntries:
        final entries = rows
            .map((m) => MealEntryRow.fromJson(m, serializer: _serializer))
            .toList();
        await mealEntryDao.restoreEntries(entries);
      case ExportCategory.favorites:
        final favorites = rows
            .map((m) => FavoriteRow.fromJson(m, serializer: _serializer))
            .toList();
        await mealEntryDao.restoreFavorites(favorites);
      case ExportCategory.customFoods:
        final foods = rows
            .map((m) => UserFoodRow.fromJson(m, serializer: _serializer))
            .toList();
        await userFoodDao.restoreCustomFoods(foods);
      case ExportCategory.weightEntries:
        final entries = rows
            .map((m) => WeightEntryRow.fromJson(m, serializer: _serializer))
            .toList();
        await weightDao.restoreEntries(entries);
      case ExportCategory.co2Settings:
        if (rows.isEmpty) return;
        final row = Co2SettingsRow.fromJson(
          rows.first,
          serializer: _serializer,
        );
        await co2SettingsDao.upsertSettings(row.toCompanion(false));
      case ExportCategory.notificationPrefs:
        if (rows.isEmpty) return;
        final row = NotificationPrefsRow.fromJson(
          rows.first,
          serializer: _serializer,
        );
        await notificationPrefsDao.savePrefs(row.toCompanion(false));
    }
  }

  // ---------------------------------------------------------------------
  // Encoding (CSV / Excel / JSON)
  // ---------------------------------------------------------------------

  String _extensionFor(ExportFormat format) => switch (format) {
    ExportFormat.csv => 'csv',
    ExportFormat.excel => 'xlsx',
    ExportFormat.json => 'json',
  };

  List<int> _encodeRows(List<Map<String, dynamic>> rows, ExportFormat format) {
    return switch (format) {
      ExportFormat.csv => utf8.encode(_encodeCsv(rows)),
      ExportFormat.excel => _encodeExcel(rows),
      ExportFormat.json => utf8.encode(jsonEncode(rows)),
    };
  }

  String _encodeCsv(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return '';
    final headers = rows.first.keys.toList();
    final table = <List<dynamic>>[
      headers,
      for (final row in rows) [for (final header in headers) row[header]],
    ];
    return const CsvEncoder().convert(table);
  }

  List<int> _encodeExcel(List<Map<String, dynamic>> rows) {
    final excelDoc = xls.Excel.createExcel();
    final defaultSheetName = excelDoc.getDefaultSheet()!;
    const sheetName = 'data';
    excelDoc.rename(defaultSheetName, sheetName);

    if (rows.isNotEmpty) {
      final headers = rows.first.keys.toList();
      excelDoc.appendRow(
        sheetName,
        [for (final header in headers) xls.TextCellValue(header)],
      );
      for (final row in rows) {
        excelDoc.appendRow(
          sheetName,
          [
            for (final header in headers)
              xls.TextCellValue(row[header]?.toString() ?? ''),
          ],
        );
      }
    }

    final bytes = excelDoc.encode();
    if (bytes == null) {
      throw StateError('excel package failed to encode a valid .xlsx file');
    }
    return bytes;
  }

  // ---------------------------------------------------------------------
  // Zip helpers
  // ---------------------------------------------------------------------

  Future<Archive> _decodeZip(File zip) async {
    final bytes = await zip.readAsBytes();
    return ZipDecoder().decodeBytes(bytes);
  }

  String _contentAsString(ArchiveFile file) {
    final content = file.content;
    return content is String ? content : utf8.decode(content as List<int>);
  }

  Map<String, dynamic> _readManifest(Archive archive) {
    final manifestFile = archive.findFile('manifest.json');
    if (manifestFile == null) {
      throw InvalidBackupArchiveException('manifest.json not found in archive');
    }
    final decoded = jsonDecode(_contentAsString(manifestFile));
    if (decoded is! Map<String, dynamic>) {
      throw InvalidBackupArchiveException('manifest.json is not a JSON object');
    }
    return decoded;
  }

  RestorePreview _restorePreviewFromManifest(Map<String, dynamic> manifest) {
    final formatVersion = manifest['formatVersion'] as int?;
    if (formatVersion != currentFormatVersion) {
      throw UnsupportedBackupFormatException(formatVersion ?? -1);
    }

    final createdAtRaw = manifest['createdAt'] as String?;
    final backupDate = createdAtRaw == null
        ? null
        : DateTime.parse(createdAtRaw);

    final filesList = (manifest['files'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final categoryRowCounts = <ExportCategory, int>{};
    for (final fileEntry in filesList) {
      final category = ExportCategory.values.byName(
        fileEntry['category'] as String,
      );
      final rowCount = fileEntry['rowCount'] as int;
      categoryRowCounts[category] = rowCount;
    }

    return RestorePreview(
      // Safe: the guard above already threw for any other value.
      formatVersion: currentFormatVersion,
      backupDate: backupDate,
      categoryRowCounts: categoryRowCounts,
    );
  }

  /// Validates that [entryName] normalizes to a path that remains within
  /// [targetDir] — rejects any entry whose path escapes it (absolute
  /// paths, or `..`-traversal), before a single byte is read from it.
  bool _isPathSafe(String entryName, Directory targetDir) {
    final targetPath = p.normalize(targetDir.absolute.path);
    final candidatePath = p.normalize(p.join(targetPath, entryName));
    return candidatePath == targetPath || p.isWithin(targetPath, candidatePath);
  }
}
