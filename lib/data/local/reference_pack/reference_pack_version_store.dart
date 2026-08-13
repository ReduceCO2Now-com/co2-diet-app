import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// On-disk `.version` marker for the downloaded full reference pack —
/// independent of `first_launch_extractor.dart`'s `off_reference.version`
/// marker for the bundled seed.
///
/// Mirrors `first_launch_extractor.dart`'s version-marker pattern. T-02-03-02
/// mitigation extended: the output path is always derived from
/// `getApplicationDocumentsDirectory`, never from a server-supplied string
/// (e.g. the manifest's `current_version` is written as file *contents*,
/// never used to construct the file *path* itself).
class ReferencePackVersionStore {
  /// Creates a [ReferencePackVersionStore].
  const ReferencePackVersionStore();

  static const _fileName = 'reference_pack_full.version';

  Future<File> _versionFile() async {
    final docsDir = await getApplicationDocumentsDirectory();
    return File(p.join(docsDir.path, _fileName));
  }

  /// Returns the installed full pack's version tag, or `null` when no full
  /// pack has ever been installed (marker file absent).
  Future<String?> read() async {
    final file = await _versionFile();
    if (!file.existsSync()) return null;
    final contents = await file.readAsString();
    final trimmed = contents.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  /// Writes [version] as the installed full pack's version marker,
  /// overwriting any previous value.
  Future<void> write(String version) async {
    final file = await _versionFile();
    await file.writeAsString(version);
  }

  /// Deletes the version marker file — called by `revertToSeed()` so
  /// [read] once again returns `null` (only the bundled seed is
  /// installed).
  Future<void> clear() async {
    final file = await _versionFile();
    if (file.existsSync()) {
      await file.delete();
    }
  }
}
