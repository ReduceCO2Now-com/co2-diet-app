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
/// config directly at this server for an end-to-end checkpoint run. Since
/// `ReferencePackManifest.fromJson` (Plan 09-02, `T-09-02-01`) rejects any
/// `pack_url`/`delta_from.*.url` that isn't `https://`, and
/// `tools/build_reference_pack_release.py`'s generated `manifest.json`
/// ships a non-resolvable `https://REPLACE_WITH_CDN_HOST/...` placeholder
/// for exactly that field, this server rewrites `pack_url` in the response
/// body (never on disk) to point at its own HTTPS listener before serving
/// it -- otherwise a real device could never get past manifest parsing,
/// let alone reach the Range-request mechanics this tool exists to prove.
///
/// HTTPS is served on `port + 1` using a self-signed certificate this
/// script generates fresh on every run via the system `openssl` binary
/// (SAN covers every LAN IPv4 address printed at startup, plus
/// `127.0.0.1`/`localhost`). A physical device must install and fully
/// trust this certificate before `background_downloader`'s real
/// `URLSession`/`WorkManager` HTTPS request will succeed -- the
/// certificate itself is served at `/dev-ca.pem` over plain HTTP so a
/// device can fetch and install it directly. See the startup banner for
/// exact per-platform trust steps.
///
/// Usage:
///   `dart run tool/dev/range_test_server.dart <file-to-serve> [port]`
///
/// Default HTTP port: 8095 (HTTPS listens on `port + 1`, e.g. 8096).
///
/// A physical device cannot reach the dev machine's `localhost` -- point it
/// at this machine's LAN IP instead (printed on startup) while both are on
/// the same Wi-Fi network.
library;

import 'dart:convert';
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
  final httpPort = arguments.length > 1 ? int.parse(arguments[1]) : 8095;
  final httpsPort = httpPort + 1;

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
  final lanAddresses = await _lanAddresses();
  final canonicalHost = lanAddresses.isNotEmpty
      ? lanAddresses.first
      : '127.0.0.1';

  final cert = await _generateSelfSignedCert(
    sanHosts: [
      'localhost',
      '127.0.0.1',
      ...lanAddresses,
    ],
  );

  final securityContext = SecurityContext()
    ..useCertificateChain(cert.certPath)
    ..usePrivateKey(cert.keyPath);

  final httpServer = await _bindWithRetry(
    () => HttpServer.bind(InternetAddress.anyIPv4, httpPort),
    port: httpPort,
  );
  final httpsServer = await _bindWithRetry(
    () => HttpServer.bindSecure(
      InternetAddress.anyIPv4,
      httpsPort,
      securityContext,
    ),
    port: httpsPort,
  );

  final httpsPackUrl = 'https://$canonicalHost:$httpsPort/$fileName';

  print('range_test_server: serving $filePath ($fileLength bytes)');
  print('range_test_server: ETag $etag');
  print('range_test_server: HTTP listening on port $httpPort');
  print('range_test_server: HTTPS listening on port $httpsPort (self-signed)');
  print('');
  print('Local URLs (device on the same machine / simulator only):');
  print('  http://localhost:$httpPort/$fileName');
  print('  http://localhost:$httpPort/manifest.json');
  print('  https://localhost:$httpsPort/$fileName');
  print('');
  print(
    "A physical device cannot reach 'localhost' on the dev machine -- use "
    "this machine's LAN IP instead, with the device on the same Wi-Fi "
    'network:',
  );
  for (final ip in lanAddresses) {
    print('  http://$ip:$httpPort/$fileName   (plain HTTP -- Range/ETag only)');
    print('  http://$ip:$httpPort/manifest.json');
    print(
      '  https://$ip:$httpsPort/$fileName  (HTTPS -- what the real app must use)',
    );
  }
  print('');
  print(
    'The served /manifest.json always reports pack_url as:\n'
    '  $httpsPackUrl\n'
    "(rewritten in-memory from the build script's placeholder host --\n"
    'never edited on disk) so ReferencePackConfig.manifestUrl can point at\n'
    'either the http:// or https:// manifest.json URL above -- manifestUrl\n'
    "itself has no https-only check, only the manifest body's pack_url does.",
  );
  print('');
  print(
    'REQUIRED before a real device can complete a download: install and\n'
    "FULLY TRUST this run's self-signed certificate on the test device.\n"
    "The client's native URLSession/WorkManager HTTPS stack will refuse\n"
    'the connection otherwise, regardless of app-level config. Fetch/install:',
  );
  for (final ip in lanAddresses) {
    print('  http://$ip:$httpPort/dev-ca.pem');
  }
  print(
    '  iOS: open that URL in Safari on the device -> "Allow" the profile\n'
    '       download -> Settings -> General -> VPN & Device Management ->\n'
    '       install the downloaded profile -> Settings -> General -> About\n'
    '       -> Certificate Trust Settings -> enable full trust for it.\n'
    '  Android: open that URL in the device browser -> follow the\n'
    '       "install certificate" prompt (Settings -> Security -> more\n'
    '       cert options on older OS versions). A `flutter run` debug\n'
    '       build trusts user-installed CAs by default (debuggable apps\n'
    '       only) -- no extra app config needed.',
  );
  print('');
  print(
    'This certificate is regenerated every time this script starts and is\n'
    'never written anywhere inside the git repository.',
  );
  print('');
  print('Press Ctrl+C to stop.');

  Future<void> handler(HttpRequest request) => _handleRequest(
    request: request,
    fileBytes: fileBytes,
    fileName: fileName,
    etag: etag,
    manifestFile: manifestFile,
    httpsPackUrl: httpsPackUrl,
    certFile: File(cert.certPath),
  );

  // Each HttpServer is a single-subscription Stream<HttpRequest> --
  // forEach() below both listens to it and keeps this Future (and thus the
  // whole process) alive for as long as the server runs, since forEach's
  // returned Future only completes once the stream closes (i.e. never,
  // until Ctrl+C).
  await Future.wait<void>([
    httpServer.forEach(handler),
    httpsServer.forEach(handler),
  ]);
}

Future<void> _handleRequest({
  required HttpRequest request,
  required List<int> fileBytes,
  required String fileName,
  required String etag,
  required File manifestFile,
  required String httpsPackUrl,
  required File certFile,
}) async {
  final path = request.uri.path;

  if (path == '/dev-ca.pem') {
    await _serveCert(request, certFile);
    return;
  }

  if (path == '/manifest.json') {
    await _serveManifest(request, manifestFile, httpsPackUrl);
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

Future<void> _serveCert(HttpRequest request, File certFile) async {
  if (!certFile.existsSync()) {
    request.response.statusCode = HttpStatus.notFound;
    await request.response.close();
    return;
  }
  final bytes = await certFile.readAsBytes();
  request.response
    ..statusCode = HttpStatus.ok
    ..headers.contentType = ContentType(
      'application',
      'x-x509-ca-cert',
    )
    ..headers.contentLength = bytes.length;
  request.response.add(bytes);
  await request.response.close();
}

Future<void> _serveManifest(
  HttpRequest request,
  File manifestFile,
  String httpsPackUrl,
) async {
  if (!manifestFile.existsSync()) {
    request.response.statusCode = HttpStatus.notFound;
    await request.response.close();
    return;
  }
  final raw = await manifestFile.readAsString();
  final json = jsonDecode(raw) as Map<String, dynamic>;
  // Rewrite in-memory only -- tools/build_reference_pack_release.py's
  // on-disk manifest.json keeps its documented REPLACE_WITH_CDN_HOST
  // placeholder unchanged; this substitution exists purely so a real
  // device fetching this endpoint gets an immediately-downloadable,
  // https-validating pack_url.
  json['pack_url'] = httpsPackUrl;
  final bytes = utf8.encode(const JsonEncoder.withIndent('  ').convert(json));

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

/// Paths to a freshly-generated self-signed certificate/key pair.
class _SelfSignedCert {
  const _SelfSignedCert({required this.certPath, required this.keyPath});

  final String certPath;
  final String keyPath;
}

/// Generates a fresh self-signed certificate (RSA 2048, 7-day validity)
/// covering every host in [sanHosts] via the system `openssl` binary,
/// written under a per-run temp directory -- never inside the git repo, and
/// never reused across runs (today's LAN IP may not be tomorrow's).
///
/// Requires `openssl` on PATH (standard on macOS/Linux dev machines this
/// project's tooling already assumes -- see
/// `tools/build_reference_pack_release.py`'s Python-stdlib-only
/// convention for the equivalent assumption on that script's side).
Future<_SelfSignedCert> _generateSelfSignedCert({
  required List<String> sanHosts,
}) async {
  final dir = await Directory.systemTemp.createTemp('range_test_server_cert_');
  final certPath = '${dir.path}/cert.pem';
  final keyPath = '${dir.path}/key.pem';

  final sanEntries = <String>{
    for (final host in sanHosts) _looksLikeIp(host) ? 'IP:$host' : 'DNS:$host',
  }.join(',');

  final result = await Process.run('openssl', [
    'req',
    '-x509',
    '-newkey',
    'rsa:2048',
    '-keyout',
    keyPath,
    '-out',
    certPath,
    '-days',
    '7',
    '-nodes',
    '-subj',
    '/CN=range-test-server',
    '-addext',
    'subjectAltName=$sanEntries',
  ]);

  if (result.exitCode != 0) {
    stderr.writeln('openssl cert generation failed:\n${result.stderr}');
    exit(70); // EX_SOFTWARE
  }

  return _SelfSignedCert(certPath: certPath, keyPath: keyPath);
}

bool _looksLikeIp(String host) =>
    RegExp(r'^\d+\.\d+\.\d+\.\d+$').hasMatch(host);

/// Retries [bind] up to 5 times (300ms apart) when it fails with "address
/// already in use" -- absorbs the brief window where the OS has not yet
/// fully released a just-killed prior instance's listening socket, which
/// otherwise surfaces as an immediate, confusing fatal error even though
/// nothing is genuinely still holding the port (this is a dev-loop
/// annoyance specific to rapid Ctrl+C-then-rerun cycles, not something
/// `lsof`/`netstat` will ever show since there is no live occupier once
/// the retry succeeds). Any other [SocketException], or the same failure
/// on the final attempt, is rethrown unchanged so a genuinely-occupied
/// port still fails loudly and immediately.
Future<T> _bindWithRetry<T>(
  Future<T> Function() bind, {
  required int port,
  int maxAttempts = 5,
  Duration delay = const Duration(milliseconds: 300),
}) async {
  for (var attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await bind();
    } on SocketException catch (e) {
      final inUse = (e.osError?.message ?? e.message).toLowerCase().contains(
        'address already in use',
      );
      if (!inUse || attempt == maxAttempts) rethrow;
      stderr.writeln(
        'range_test_server: port $port still in use, retrying '
        '($attempt/$maxAttempts)...',
      );
      await Future<void>.delayed(delay);
    }
  }
  // Unreachable: the loop above always either returns or rethrows on the
  // final attempt.
  throw StateError('unreachable');
}
