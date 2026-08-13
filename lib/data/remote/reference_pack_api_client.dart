import 'dart:convert';

import 'package:co2diet/data/repositories/food_catalog_repository.dart'
    show NetworkException;
import 'package:co2diet/domain/entities/reference_pack_manifest.dart';
import 'package:http/http.dart' as http;

/// Fetches and parses the reference-pack CDN's `manifest.json` -- the tiny,
/// any-connection version-check ping described in `09-CONTEXT.md` ("runs
/// regardless of connection type... tiny payload"). Never gated behind a
/// Wi-Fi check here, unlike the pack/delta download itself (that gating
/// lives in `DownloadManager`).
///
/// Mirrors this app's established injectable-`http.Client` + mocktail
/// convention (see `test/features/auth/providers/auth_provider_test.dart`'s
/// `_MockHttpClient extends Mock implements http.Client`).
class ReferencePackApiClient {
  /// Creates a [ReferencePackApiClient] bound to an injected `http.Client`,
  /// fetching from [manifestUrl].
  const ReferencePackApiClient(this._client, {required this.manifestUrl});

  final http.Client _client;

  /// Absolute HTTPS URL to the CDN's `manifest.json`.
  final String manifestUrl;

  /// Fetches and parses `manifest.json`.
  ///
  /// Throws [NetworkException] (reusing the existing network-failure type
  /// from `food_catalog_repository.dart`, matching this app's
  /// one-exception-type-per-network-failure convention) on a non-200
  /// response.
  ///
  /// Throws [FormatException] -- propagated straight out of
  /// [ReferencePackManifest.fromJson], never caught here -- when the
  /// response body fails the manifest entity's own https-only or
  /// sanity-bound-size validation. This client performs no additional
  /// validation of its own; [ReferencePackManifest] is the sole source of
  /// truth for what a valid manifest looks like (Plan 09-02).
  Future<ReferencePackManifest> fetchManifest() async {
    final response = await _client.get(Uri.parse(manifestUrl));
    if (response.statusCode != 200) {
      throw NetworkException(
        'Manifest fetch failed: HTTP ${response.statusCode}',
      );
    }
    return ReferencePackManifest.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
