// Dev-only diagnostic script: stdout output is the whole point of this
// tool (usage instructions, LAN URLs), so avoid_print is disabled outright.
// ignore_for_file: avoid_print
/// DEVELOPMENT/TESTING-ONLY TOOL. Never imported by, bundled with, or
/// otherwise reachable from the shipping app -- lives under tool/dev/
/// alongside this project's other non-shipping developer scripts (see
/// tool/generate_schema_v1.dart for the existing convention).
///
/// A minimal, standalone `dart:io` `HttpServer` that serves a single local
/// file with HTTP Range request support (RFC 7233), so Plan 09-08's
/// real-device checkpoints can exercise `background_downloader`'s
/// resumable-download mechanics (pause/resume, Wi-Fi-drop auto-pause/
/// resume, background continuation, manual Resume after app-kill) against
/// something Range-capable, without depending on a real CDN that does not
/// exist yet (09-RESEARCH.md's Environment Availability table).
///
/// The server computes one stable, strong ETag for the served file at
/// startup (SHA-256 of the file's bytes, via `package:crypto` -- already a
/// project dependency for reference-pack checksum verification) and never
/// recomputes or changes it for the life of the process -- satisfying
/// 09-RESEARCH.md Pitfall 3's "stable strong validator" requirement that
/// some real CDNs fail to provide, which `background_downloader`'s resume
/// logic depends on to confirm a paused download's partial file still
/// matches the remote resource before continuing from a byte offset.
///
/// It also serves `manifest.json` from the same directory as the served
/// file, when one exists there, so a device can point its manifestUrl
/// config directly at this server for an end-to-end checkpoint run.
///
/// Usage:
///   `dart run tool/dev/range_test_server.dart <file-to-serve> [port]`
///
/// Default port: 8095.
///
/// A physical device cannot reach the dev machine's `localhost` -- point it
/// at this machine's LAN IP instead (printed on startup) while both are on
/// the same Wi-Fi network.
library;

import 'dart:io';

import 'package:crypto/crypto.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.isEmpty) {
    stderr.writeln(
      'Usage: dart run tool/dev/range_test_server.dart <file-to-serve> [port]',
    );
    exitCode = 64; // EX_USAGE
    return;
  }

  final filePath = arguments[0];
  final port = arguments.length > 1 ? int.parse(arguments[1]) : 8095;

  final file = File(filePath);
  if (!file.existsSync()) {
    stderr.writeln('File not found: $filePath');
    exitCode = 66; // EX_NOINPUT
    return;
  }

  final fileBytes = await file.readAsBytes();
  final fileLength = fileBytes.length;
  // Computed once at startup and never changed for the process lifetime --
  // a stable strong validator, per 09-RESEARCH.md Pitfall 3.
  final etag = '"${sha256.convert(fileBytes)}"';
  final fileName = file.uri.pathSegments.isNotEmpty
      ? file.uri.pathSegments.last
      : filePath;

  final manifestFile = File('${file.parent.path}/manifest.json');

  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  print('range_test_server: serving $filePath ($fileLength bytes)');
  print('range_test_server: ETag $etag');
  print('range_test_server: listening on port $port');
  print('');
  print('Local URLs (device on the same machine / simulator only):');
  print('  http://localhost:$port/$fileName');
  print('  http://localhost:$port/manifest.json');
  print('');
  print(
    "A physical device cannot reach 'localhost' on the dev machine -- use "
    "this machine's LAN IP instead, with the device on the same Wi-Fi "
    'network:',
  );
  for (final ip in await _lanAddresses()) {
    print('  http://$ip:$port/$fileName');
    print('  http://$ip:$port/manifest.json');
  }
  print('');
  print('Press Ctrl+C to stop.');

  await for (final request in server) {
    await _handleRequest(
      request: request,
      fileBytes: fileBytes,
      fileName: fileName,
      etag: etag,
      manifestFile: manifestFile,
    );
  }
}

Future<void> _handleRequest({
  required HttpRequest request,
  required List<int> fileBytes,
  required String fileName,
  required String etag,
  required File manifestFile,
}) async {
  final path = request.uri.path;

  if (path == '/manifest.json') {
    await _serveManifest(request, manifestFile);
    return;
  }

  if (path == '/$fileName' || path == '/') {
    await _serveFileWithRangeSupport(
      request: request,
      fileBytes: fileBytes,
      etag: etag,
    );
    return;
  }

  request.response.statusCode = HttpStatus.notFound;
  await request.response.close();
}

Future<void> _serveManifest(HttpRequest request, File manifestFile) async {
  if (!manifestFile.existsSync()) {
    request.response.statusCode = HttpStatus.notFound;
    await request.response.close();
    return;
  }
  final bytes = await manifestFile.readAsBytes();
  request.response
    ..statusCode = HttpStatus.ok
    ..headers.contentType = ContentType(
      'application',
      'json',
      charset: 'utf-8',
    )
    ..headers.contentLength = bytes.length;
  request.response.add(bytes);
  await request.response.close();
}

Future<void> _serveFileWithRangeSupport({
  required HttpRequest request,
  required List<int> fileBytes,
  required String etag,
}) async {
  final totalLength = fileBytes.length;
  final response = request.response;

  response.headers
    ..set(HttpHeaders.acceptRangesHeader, 'bytes')
    ..set(HttpHeaders.etagHeader, etag)
    ..contentType = ContentType('application', 'octet-stream');

  final rangeHeader = request.headers.value(HttpHeaders.rangeHeader);

  if (rangeHeader == null) {
    response.statusCode = HttpStatus.ok;
    response.headers.contentLength = totalLength;
    response.add(fileBytes);
    await response.close();
    return;
  }

  final parsedRange = _parseRangeHeader(rangeHeader, totalLength);
  if (parsedRange == null) {
    response.statusCode = HttpStatus.requestedRangeNotSatisfiable;
    response.headers.set(
      HttpHeaders.contentRangeHeader,
      'bytes */$totalLength',
    );
    await response.close();
    return;
  }

  final (start, end) = parsedRange;
  final chunk = fileBytes.sublist(start, end + 1);

  response.statusCode = HttpStatus.partialContent;
  response.headers
    ..contentLength = chunk.length
    ..set(HttpHeaders.contentRangeHeader, 'bytes $start-$end/$totalLength');
  response.add(chunk);
  await response.close();
}

/// Parses a `Range: bytes=X-Y` header (only the single-range `bytes=X-` and
/// `bytes=X-Y` forms are supported -- sufficient for
/// `background_downloader`'s resume requests). Returns `(start, end)`
/// inclusive, or `null` when the header is malformed or unsatisfiable.
(int, int)? _parseRangeHeader(String header, int totalLength) {
  final match = RegExp(r'^bytes=(\d*)-(\d*)$').firstMatch(header.trim());
  if (match == null) return null;

  final startStr = match.group(1) ?? '';
  final endStr = match.group(2) ?? '';

  if (startStr.isEmpty && endStr.isEmpty) return null;

  int start;
  int end;

  if (startStr.isEmpty) {
    // Suffix range: bytes=-N means the last N bytes.
    final suffixLength = int.parse(endStr);
    start = totalLength - suffixLength;
    if (start < 0) start = 0;
    end = totalLength - 1;
  } else {
    start = int.parse(startStr);
    end = endStr.isEmpty ? totalLength - 1 : int.parse(endStr);
  }

  if (start < 0 || end >= totalLength || start > end) return null;
  return (start, end);
}

/// Returns this machine's non-loopback IPv4 addresses, for printing
/// LAN-reachable URLs a physical device can actually connect to.
Future<List<String>> _lanAddresses() async {
  // includeLoopback: false is already the default; filtering to IPv4 keeps
  // the printed LAN URLs short and unambiguous (IPv6 link-local addresses
  // are noisy and rarely what a physical test device needs here).
  final interfaces = await NetworkInterface.list(
    type: InternetAddressType.IPv4,
  );
  return [
    for (final interface in interfaces)
      for (final addr in interface.addresses) addr.address,
  ];
}
