/// Sanity-bound maximum for any artifact size (compressed pack or delta)
/// advertised by a fetched manifest, in bytes (2GB).
///
/// Well above the documented 300-800MB full-pack range but low enough to
/// reject an obviously-malicious or corrupted `pack_size_bytes`/
/// `delta_from.*.size_bytes` value before it ever feeds
/// `DiskSpaceChecker`'s preflight calculation — guards against the
/// DoS-via-implausible-size threat (`09-RESEARCH.md` Known Threat Patterns
/// table; `T-09-02-02` in this plan's threat model).
const int maxPlausiblePackSizeBytes = 2 * 1024 * 1024 * 1024;

/// Validates that [url] is present and uses the `https` scheme.
///
/// T-09-02-01 mitigation: rejects a plain-`http` (or malformed) URL before
/// it is ever trusted as a download source — see
/// `docs/data-contracts/reference-pack-manifest.md` Section 2.
void _requireHttpsUrl(String? url, String fieldName) {
  if (url == null || url.isEmpty) {
    throw FormatException('$fieldName is required');
  }
  final uri = Uri.tryParse(url);
  if (uri == null || uri.scheme != 'https') {
    throw FormatException('$fieldName must be an https:// URL, got: $url');
  }
}

/// Validates that [sizeBytes] is a positive integer at or below
/// [maxPlausiblePackSizeBytes].
///
/// T-09-02-01/T-09-02-02 mitigation: rejects an implausible or negative
/// size before it ever feeds a disk-space calculation.
void _requirePlausibleSize(int? sizeBytes, String fieldName) {
  if (sizeBytes == null) {
    throw FormatException('$fieldName is required');
  }
  if (sizeBytes <= 0 || sizeBytes > maxPlausiblePackSizeBytes) {
    throw FormatException(
      '$fieldName is implausible: $sizeBytes bytes '
      '(must be > 0 and <= $maxPlausiblePackSizeBytes)',
    );
  }
}

/// Describes a delta artifact that upgrades an installed pack from some
/// prior version to the manifest's `current_version`.
///
/// See `docs/data-contracts/reference-pack-manifest.md` Section 1 — the
/// `delta_from.<old_version>` object shape.
class ReferencePackDeltaInfo {
  /// Creates a [ReferencePackDeltaInfo].
  const ReferencePackDeltaInfo({
    required this.url,
    required this.sizeBytes,
    required this.sha256,
  });

  /// Parses a `delta_from.<old_version>` JSON object.
  ///
  /// Throws [FormatException] when [json]'s `url` is not `https://`, or
  /// when `size_bytes` exceeds [maxPlausiblePackSizeBytes].
  factory ReferencePackDeltaInfo.fromJson(Map<String, dynamic> json) {
    final url = json['url'] as String?;
    final sizeBytes = json['size_bytes'] as int?;
    final sha256 = json['sha256'] as String?;

    _requireHttpsUrl(url, 'delta_from.*.url');
    _requirePlausibleSize(sizeBytes, 'delta_from.*.size_bytes');
    if (sha256 == null || sha256.isEmpty) {
      throw const FormatException('delta_from.*.sha256 is required');
    }

    return ReferencePackDeltaInfo(
      url: url!,
      sizeBytes: sizeBytes!,
      sha256: sha256,
    );
  }

  /// Absolute HTTPS URL to the delta artifact
  /// (`delta_v<old>_to_v<new>.sqlite`, uncompressed).
  final String url;

  /// Size in bytes of the uncompressed delta artifact.
  final int sizeBytes;

  /// SHA-256 digest (64 lowercase hex chars) of the delta artifact's exact
  /// bytes.
  final String sha256;
}

/// Parses and validates the CDN's `manifest.json` response — the sole place
/// this JSON shape is trusted (see
/// `docs/data-contracts/reference-pack-manifest.md`, Section 1: shape,
/// Section 2: client-side validation).
class ReferencePackManifest {
  /// Creates a [ReferencePackManifest].
  const ReferencePackManifest({
    required this.currentVersion,
    required this.packUrl,
    required this.packSizeBytes,
    required this.packSha256,
    required this.productCount,
    required this.deltaFrom,
  });

  /// Parses a `manifest.json` response body into a
  /// [ReferencePackManifest].
  ///
  /// Throws [FormatException] when `pack_url` (or any `delta_from.*.url`)
  /// is not `https://`, or when `pack_size_bytes` (or any
  /// `delta_from.*.size_bytes`) exceeds [maxPlausiblePackSizeBytes] —
  /// T-09-02-01 mitigation, mirroring the data contract's Section 2
  /// validation rules exactly.
  factory ReferencePackManifest.fromJson(Map<String, dynamic> json) {
    final currentVersion = json['current_version'] as String?;
    final packUrl = json['pack_url'] as String?;
    final packSizeBytes = json['pack_size_bytes'] as int?;
    final packSha256 = json['pack_sha256'] as String?;
    final productCount = json['product_count'] as int?;
    final deltaFromJson = json['delta_from'] as Map<String, dynamic>?;

    if (currentVersion == null || currentVersion.isEmpty) {
      throw const FormatException('current_version is required');
    }
    _requireHttpsUrl(packUrl, 'pack_url');
    _requirePlausibleSize(packSizeBytes, 'pack_size_bytes');
    if (packSha256 == null || packSha256.isEmpty) {
      throw const FormatException('pack_sha256 is required');
    }
    if (productCount == null || productCount < 0) {
      throw const FormatException('product_count is required');
    }

    final deltaFrom = <String, ReferencePackDeltaInfo>{
      if (deltaFromJson != null)
        for (final entry in deltaFromJson.entries)
          entry.key: ReferencePackDeltaInfo.fromJson(
            entry.value as Map<String, dynamic>,
          ),
    };

    return ReferencePackManifest(
      currentVersion: currentVersion,
      packUrl: packUrl!,
      packSizeBytes: packSizeBytes!,
      packSha256: packSha256,
      productCount: productCount,
      deltaFrom: deltaFrom,
    );
  }

  /// Opaque version tag for the latest published full pack. Never parsed
  /// for ordering — only used for equality/lookup.
  final String currentVersion;

  /// Absolute HTTPS URL to the current full-pack release artifact
  /// (`full_v<version>.sqlite.gz`, gzip-compressed).
  final String packUrl;

  /// Size in bytes of the compressed `.sqlite.gz` artifact at [packUrl].
  /// Never the decompressed/installed footprint.
  final int packSizeBytes;

  /// SHA-256 digest (64 lowercase hex chars) of the compressed artifact's
  /// exact bytes.
  final String packSha256;

  /// `SELECT COUNT(*) FROM products` in the full pack this manifest
  /// describes.
  final int productCount;

  /// Maps a prior `current_version` string the client might already have
  /// installed to the delta artifact that upgrades from that version to
  /// [currentVersion]. Empty when no delta path exists yet.
  final Map<String, ReferencePackDeltaInfo> deltaFrom;
}
