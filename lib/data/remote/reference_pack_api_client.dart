import 'dart:async';
import 'dart:convert';

import 'package:co2diet/data/repositories/food_catalog_repository.dart'
    show NetworkException;
import 'package:co2diet/domain/entities/reference_pack_manifest.dart';
import 'package:flutter/foundation.dart' show debugPrint;
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
  /// Throws [NetworkException] on a non-200 response, or when the request
  /// doesn't complete within [_timeout] -- an unreachable host (e.g. a
  /// misconfigured/stale [manifestUrl]) would otherwise hang this call
  /// indefinitely, since a bare `http.Client.get` has no timeout of its
  /// own (T-09-08-diagnostic: this is exactly what a real-device
  /// connection-level failure looked like before this fix -- no error,
  /// no progress, nothing in logcat).
  ///
  /// Throws [FormatException] -- propagated straight out of
  /// [ReferencePackManifest.fromJson], never caught here -- when the
  /// response body fails the manifest entity's own https-only or
  /// sanity-bound-size validation. This client performs no additional
  /// validation of its own; [ReferencePackManifest] is the sole source of
  /// truth for what a valid manifest looks like (Plan 09-02).
  Future<ReferencePackManifest> fetchManifest() async {
    debugPrint('ReferencePackApiClient: fetching $manifestUrl');
    final http.Response response;
    try {
      response = await _client.get(Uri.parse(manifestUrl)).timeout(_timeout);
    } on TimeoutException {
      debugPrint(
        'ReferencePackApiClient: fetch timed out after $_timeout -- '
        '$manifestUrl is unreachable',
      );
      throw NetworkException(
        'Manifest fetch timed out after $_timeout: $manifestUrl',
      );
    }
    if (response.statusCode != 200) {
      debugPrint(
        'ReferencePackApiClient: fetch failed, HTTP ${response.statusCode}',
      );
      throw NetworkException(
        'Manifest fetch failed: HTTP ${response.statusCode}',
      );
    }
    final manifest = ReferencePackManifest.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
    debugPrint(
      'ReferencePackApiClient: fetched manifest '
      '${manifest.currentVersion} (${manifest.productCount} products)',
    );
    return manifest;
  }

  static const Duration _timeout = Duration(seconds: 15);
}
