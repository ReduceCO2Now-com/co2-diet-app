import 'dart:async';
import 'dart:typed_data';

import 'package:co2diet/data/repositories/food_catalog_repository.dart'
    show NetworkException;
import 'package:co2diet/domain/services/backup_sync_config.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;

/// Pushes and pulls the single opaque, client-encrypted backup blob per
/// account (Plan 08-03, AUTH-09) against
/// `docs/backend-contracts/encrypted-backup-blob.md`'s proposed
/// `POST`/`GET {baseUrl}${BackupSyncConfig.pushPath/pullPath}` contract.
///
/// Mirrors `ReferencePackApiClient`'s exact structure and doc-comment style
/// (injectable `http.Client`, `const` constructor, module-level `_timeout`,
/// `debugPrint` breadcrumbs on failure paths, `NetworkException` imported
/// the same way from `food_catalog_repository.dart`). Reachable only when
/// [BackupSyncConfig.enabled] is `true` -- callers gate on that separately;
/// this class does not check it itself.
class BackupApiClient {
  /// Creates a [BackupApiClient] bound to an injected `http.Client` and
  /// [baseUrl] (per `BackendConfig.baseUrl`).
  const BackupApiClient(this._client, {required this.baseUrl});

  final http.Client _client;

  /// The backend's base URL -- request paths are built as
  /// `'$baseUrl${BackupSyncConfig.pushPath}'` / `'...pullPath'`.
  final String baseUrl;

  /// 30 seconds -- longer than `ReferencePackApiClient`'s 15s manifest
  /// timeout, since this uploads/downloads an archive body rather than a
  /// small JSON manifest.
  static const _timeout = Duration(seconds: 30);

  /// Pushes [blob] (the already-encrypted archive bytes -- see
  /// `BackupSyncNotifier.pushBackup`, which guarantees an unencrypted
  /// archive can never reach this method) as the raw request body of a
  /// `POST {baseUrl}${BackupSyncConfig.pushPath}` call, authenticated with
  /// [accessToken] as a bearer token.
  ///
  /// Throws [NetworkException] on any non-2xx response, or when the
  /// request doesn't complete within [_timeout].
  Future<void> push(Uint8List blob, String accessToken) async {
    final uri = Uri.parse('$baseUrl${BackupSyncConfig.pushPath}');
    debugPrint('BackupApiClient: pushing ${blob.length} bytes to $uri');
    final http.Response response;
    try {
      response = await _client
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/octet-stream',
            },
            body: blob,
          )
          .timeout(_timeout);
    } on TimeoutException {
      debugPrint(
        'BackupApiClient: push timed out after $_timeout -- $uri is '
        'unreachable',
      );
      throw NetworkException('Backup push timed out after $_timeout: $uri');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      debugPrint(
        'BackupApiClient: push failed, HTTP ${response.statusCode}',
      );
      throw NetworkException(
        'Backup push failed: HTTP ${response.statusCode}',
      );
    }
    debugPrint('BackupApiClient: push succeeded');
  }

  /// Pulls the stored backup blob via `GET
  /// {baseUrl}${BackupSyncConfig.pullPath}`, authenticated with
  /// [accessToken] as a bearer token.
  ///
  /// Returns the raw response body bytes on a `200` response, or `null` on
  /// a `404` -- an expected "no backup exists yet for this account" state,
  /// never surfaced as an error. Throws [NetworkException] on any other
  /// non-2xx response, or when the request doesn't complete within
  /// [_timeout].
  Future<Uint8List?> pull(String accessToken) async {
    final uri = Uri.parse('$baseUrl${BackupSyncConfig.pullPath}');
    debugPrint('BackupApiClient: pulling from $uri');
    final http.Response response;
    try {
      response = await _client
          .get(uri, headers: {'Authorization': 'Bearer $accessToken'})
          .timeout(_timeout);
    } on TimeoutException {
      debugPrint(
        'BackupApiClient: pull timed out after $_timeout -- $uri is '
        'unreachable',
      );
      throw NetworkException('Backup pull timed out after $_timeout: $uri');
    }
    if (response.statusCode == 404) {
      debugPrint('BackupApiClient: pull found no backup for this account');
      return null;
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      debugPrint(
        'BackupApiClient: pull failed, HTTP ${response.statusCode}',
      );
      throw NetworkException(
        'Backup pull failed: HTTP ${response.statusCode}',
      );
    }
    debugPrint(
      'BackupApiClient: pull succeeded, ${response.bodyBytes.length} bytes',
    );
    return response.bodyBytes;
  }
}
