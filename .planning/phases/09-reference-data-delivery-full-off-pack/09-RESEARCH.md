# Phase 9: Reference Data Delivery (Full OFF Pack) - Research

**Researched:** 2026-08-12
**Domain:** Resumable/pausable large-file downloads in Flutter, Open Food Facts data distribution, SQLite delta/incremental update patterns
**Confidence:** MEDIUM (client-side download mechanics: HIGH; CDN/delta-pipeline design: MEDIUM — this phase's server-side/build-side half is explicitly out of scope and flagged as a coordination point, not directly verifiable)

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Entry Point & Settings Screen Structure**
- Grouped near **Backup & Restore** in Settings (data-lifecycle/storage family), not near Search foods/My Foods.
- Its own dedicated screen (matches Backup & Restore, CO2 Calculation Settings, Weight Tracking precedent).
- Settings row shows a label + current catalog status as the subtitle at rest: "Using starter pack" / "Full catalog installed — 650 MB" / "Downloading… 340/650 MB" / "Update available — connect to Wi-Fi".
- Dedicated screen during an active download: determinate progress bar with %, bytes downloaded/total, and a Cancel button (CDN content-length is known upfront). Brief success confirmation on completion before settling to the at-rest state.
- Tapping "Download" starts immediately — no confirmation dialog first.
- Pre-flight disk-space check before starting: if insufficient free space, block with a clear message ("Not enough storage — need ~650MB, only 200MB free") rather than starting a download that will fail partway through.
- Screen shows a product-count comparison (e.g., "50,000 products (starter pack)" vs "2.5M products (full catalog)") — concrete, honest numbers.
- Download continues running in the background if the user navigates away from the screen or backgrounds the app. Settings row subtitle reflects live progress from anywhere in Settings.
- Food search keeps working normally on the existing starter pack throughout the download. Atomic swap to the full pack only happens after it finishes downloading and verifying, mirroring `first_launch_extractor.dart`'s existing version-checked swap pattern.

**Delta Refresh: Schedule & Prompting**
- Schedule options: **Manual only** (default), **Weekly**, **Monthly** — mirrors `autoBackupFrequency` (Phase 5).
- Once automatic refresh is enabled, refreshes run quietly on Wi-Fi without a per-refresh confirmation dialog. Still visible via the Settings row's subtitle/last-updated timestamp.
- **No true background scheduler exists in this app** (confirmed via codebase scan — no `workmanager`/`background_fetch`/`Timer.periodic` anywhere). "Weekly/Monthly" is implemented as a check on app open/resume, throttled to fire at most once per the configured interval — same pattern as Phase 5's weigh-in reminder re-arm (`AppLifecycleState.resumed` observer).
- The lightweight "is there an update" version-check ping runs regardless of connection type (tiny payload); only the actual multi-MB delta payload waits for Wi-Fi. If an update is found while off Wi-Fi, the Settings row subtitle shows "Update available — connect to Wi-Fi".
- **No Dashboard-level banner** on delta-refresh completion — considered and explicitly rejected.
- Reverting to the starter pack resets the schedule setting back to "Manual only."

**Download Reliability & Wi-Fi Override**
- Wi-Fi-only is the default but not mandatory — an explicit opt-in override is available ("Use cellular data") when no Wi-Fi is detected.
- Interrupted downloads (connection drop, Wi-Fi lost, app killed) **resume from where they left off** via HTTP range requests, not a full restart.
- Failed/interrupted downloads require a **manual "Resume" tap** — no automatic background retry loop, consistent with this app's no-auto-retry convention (Phase 2's search API fallback precedent).
- **Exception:** a momentary Wi-Fi drop during an already-running background download **auto-pauses and auto-resumes silently** once Wi-Fi returns.
- Explicit **Cancel deletes the partial file** immediately. An **interruption** (app killed, connection lost) **keeps the partial file** so "Resume" has something to resume from.

**Revert-to-Seed Behavior**
- Reverting **deletes the downloaded full-catalog database from disk** (reclaiming ~300–800MB) and falls back to querying the bundled starter seed — same swap pattern as `first_launch_extractor.dart`, reversed.
- Requires a **confirmation dialog**: "Revert to starter pack? This deletes the full catalog (650MB) and reduces search coverage back to the starter set."
- Revert is available at any time **except while a download/refresh is actively in progress**.
- Reverting resets the automatic delta-refresh schedule setting back to "Manual only."

### Claude's Discretion
- Exact copy/wording throughout (button labels, error messages, confirmation dialog phrasing) beyond the content direction given above
- CDN choice/hosting (S3, Cloudflare R2, Bunny, GitHub Releases, or backend-team-owned infra) — an infrastructure decision, flagged as a coordination point but not blocking this phase's planning
- Resumable-download implementation approach (`dio` vs. bare `http` with manual Range requests) — technical implementation detail
- Manifest/version-check endpoint shape and delta-diff format
- Exact progress bar / row visual design within existing DESIGN.md tokens
- Product-count numbers' exact source (CDN manifest metadata vs. computed client-side after download)

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope throughout. (A Dashboard-level banner on delta-refresh completion was considered and explicitly rejected, not deferred.)
</user_constraints>

## Summary

Phase 9 has two halves with very different research maturity. The **client-side download mechanics** (resumable/pausable transfer, Wi-Fi gating, background continuation, progress UI, checksum verification, disk-space preflight) are a well-solved problem in the Flutter ecosystem — a single actively-maintained plugin, `background_downloader`, natively implements almost every locked decision in CONTEXT.md (Range-based pause/resume, `requiresWiFi`, native background continuation via `URLSession`/`WorkManager`, persistent cross-restart task tracking) and is the community-recommended replacement for the now-unmaintained `flutter_downloader`. Hand-rolling this on top of bare `dio`/`http` would mean re-implementing Range-header resume logic, Android's 9-minute background-execution limit, and iOS's 4-hour background-session limit — exactly the kind of "don't hand-roll" problem this research flags.

The **server-side/build-side half** (what a "delta" actually contains, how it's generated, how it's hosted) is genuinely under-specified by design — CDN hosting is explicitly a coordination point outside this phase's scope. Open Food Facts itself publishes MongoDB/JSONL/CSV/Parquet full dumps plus 14-day rolling **delta exports** (JSON snapshots keyed by UNIX timestamp range, applied via `mongoimport`, with the documented limitation that they **cannot represent deletions** — those only surface via a fresh full-dump diff). None of these formats map 1:1 onto this app's existing `off_reference.sqlite` schema (`products` + `products_fts` FTS5 + `co2_factors` + `food_co2_overrides`, built by `tools/ingest_off.py` from the OFF JSONL dump plus an AGRIBALYSE join). This means the "OFF pack" is — and must remain — a project-owned artifact, not a raw OFF export. The realistic delta strategy is therefore a **project-generated row-level delta** (added/changed rows + a tombstone list of removed barcodes) produced by a build-side pipeline that itself consumes OFF's own dumps/deltas, published as small versioned artifacts alongside a manifest.json the client polls.

**Primary recommendation:** Use `background_downloader` (not bare `dio`/`http` with manual Range logic) for the transfer itself; keep the existing `http` package for the tiny manifest/version-check ping (already a direct dependency); use the `crypto` package for SHA-256 verification of every downloaded artifact before it is treated as trustworthy; design the delta artifact as a small companion SQLite file (or JSON) carrying only changed/added `products` rows plus a `deleted_barcodes` list, applied via a SQL transaction that explicitly re-syncs `products_fts` (which has **no automatic sync trigger** in the current schema — a concrete, codebase-verified pitfall, not a generic one). Treat "delta" and "full pack" as two sizes of the *same* atomic-swap-on-disk mechanism `first_launch_extractor.dart` already established, extended to also support an in-place (not startup-only) `DETACH`/re-`ATTACH` cycle, since this phase's swap can happen while the app is already running.

## Architectural Responsibility Map

This app has no browser/SSR/backend-API tier for this feature — it is a pure Flutter client talking directly to a static CDN, consistent with CONTEXT.md's explicit "no auth/Account Mode/backend-sync coupling" boundary. Tiers below are adapted accordingly.

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Manifest/version-check ping | Client (Flutter app) | CDN/Static (serves `manifest.json`) | Tiny GET, works over any connection per CONTEXT.md; client owns the "is there an update" comparison logic |
| Full-pack / delta download (resumable, pausable) | Client (Flutter app, via `background_downloader`) | CDN/Static (must support HTTP Range + a stable strong validator) | All download-state machine logic (pause/resume/cancel/Wi-Fi-gating) lives in the client; the CDN only needs to be a correctly-configured static file host |
| Wi-Fi vs. cellular detection & override | Client (`connectivity_plus`, already a dependency) | — | Pure device-local capability, no server involvement |
| Disk-space preflight check | Client (OS filesystem via a disk-space plugin) | — | Device-local; must run before any network call starts |
| Checksum/integrity verification | Client (`crypto` package, SHA-256) | CDN/Static (must publish the checksum in the manifest) | Verification computation is local; the CDN is the source of truth for the expected hash |
| Atomic pack swap / `ATTACH`-`DETACH` cycle | Database/Storage tier (local SQLite via Drift's `AppDatabase`) | Client (orchestrates the swap timing) | Extends the existing `off_reference.sqlite` ATTACH mechanism; must not corrupt in-flight food-search queries |
| Delta artifact generation (row diff + tombstones) | CDN/Static (build-side pipeline, off-app) | — | Out of this phase's client-code scope, but the **contract shape** (manifest + delta format) must be designed now so the client can consume it — flagged as a written-spec hand-off, mirroring `docs/backend-contracts/` |
| Foreground-triggered schedule check (Weekly/Monthly) | Client (`AppLifecycleState.resumed` observer, extending `lib/app.dart`) | — | No true background scheduler exists in this app (confirmed, see CONTEXT.md); this is an honest constraint, not a gap |
| Settings UI (status subtitle, progress screen, revert dialog) | Client (Flutter widgets) | — | Standard UI layer |

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| `background_downloader` | 9.5.7 (verified via pub.dev, 2026-08-12) | Resumable/pausable/background-continuing HTTP downloads with `requiresWiFi` support | Purpose-built for exactly this problem: native `URLSession` (iOS) / `WorkManager`-backed `DownloadWorker` (Android) background continuation, Range-based pause/resume, persistent cross-app-restart task database, `requiresWiFi` flag, progress + status streams. Community-recommended, actively-maintained successor to the now-unmaintained `flutter_downloader` (see State of the Art below). [ASSUMED — see Package Legitimacy Audit] |
| `crypto` | 3.0.7 (verified via pub.dev, 2026-08-12) | SHA-256 checksum verification of downloaded pack/delta files | Official Dart-team package (`dart.dev` publisher), zero-dependency, chunked-read API suitable for 300–800MB files without loading the whole file into memory. [ASSUMED — see Package Legitimacy Audit, though publisher is the Dart team itself] |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `http` | ^1.6.0 (already a direct dependency) | Tiny manifest/version-check GET request | Already installed for the OFF API fallback / Keycloak realm-discovery check; reuse for the lightweight version ping rather than adding a second HTTP client dependency for a single small request |
| `storage_space` | 1.2.0 (verified via pub.dev, 2026-08-12) | Free-disk-space preflight check before starting a download | Verified publisher (`oodavid.com`), 150/160 pub score, returns bytes + a configurable low-space threshold — matches CONTEXT.md's "block with a clear message" requirement directly. [ASSUMED — see Package Legitimacy Audit] |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `background_downloader` | `dio` + hand-rolled `Range` header logic | `dio` has no native resumable-download support (confirmed via pub.dev docs — `Dio.download()` gives progress/cancellation but not Range-based resume); would require hand-building the resume state machine, Android's 9-minute background timeout handling, and iOS's background-session lifecycle — exactly the "don't hand-roll" trap this domain has a mature library for |
| `background_downloader` | `flutter_downloader` | Explicitly unmaintained ("no maintainer" per its own GitHub issue tracker); its own community has been pointed toward `background_downloader` as the direct replacement |
| `storage_space` | `disk_space_plus` | Also viable (0.2.6, MIT, 47.7k downloads) but unverified uploader and 135/160 score vs. `storage_space`'s verified publisher and 150/160 — weaker legitimacy signal for a package that gates a user-facing "not enough storage" decision |
| Project-generated row-level delta artifact | Consuming OFF's own MongoDB delta exports directly | OFF's delta exports are MongoDB-JSON snapshots keyed by change timestamp, applied via `mongoimport`, and **do not represent deletions** — they don't map onto this app's custom SQLite+FTS5+AGRIBALYSE schema at all. This app must own its own delta-generation pipeline that consumes OFF's dumps as an upstream input, not distribute OFF's raw delta files to clients |

**Installation:**
```bash
flutter pub add background_downloader crypto storage_space
```

**Version verification:** Verified via direct WebFetch of each package's live pub.dev page (2026-08-12) — the official Dart/Flutter package registry, treated per this project's own established convention (see `pubspec.yaml` comments throughout) as the authoritative version/score/publisher source. Training-data package names were treated as hypotheses and re-checked against this source before inclusion.

## Package Legitimacy Audit

`slopcheck` supports `pypi`, `npm`, `crates.io`, `go`, `rubygems`, `maven`, and `packagist` — **it does not support pub.dev/Dart** (confirmed by running `slopcheck install --help`, which lists its `--ecosystem` choices explicitly). This is consistent with this project's own repeated precedent (STATE.md: "pub.dev/Dart isn't a slopcheck-supported ecosystem" — noted at Plans 04-11, 05-08, 05-09, 05-16, 06-02, 07-02). Per the Package Legitimacy Gate's graceful-degradation rule, **every package below is tagged `[ASSUMED]`**, verified only by direct inspection of its live pub.dev page (score, publisher, download/like counts, last-publish date) — not by an automated slop-detector. The planner must gate each install behind a `checkpoint:human-verify` task, exactly mirroring every prior phase's pub.dev package additions in this codebase.

| Package | Registry | Age | Downloads/Likes | Source Repo | slopcheck | Disposition |
|---------|----------|-----|------------------|--------------|-----------|-------------|
| `background_downloader` | pub.dev | latest release 2026-08 (6 days old at check time); package itself long-established, `bbflight.com` verified publisher | 165k downloads, 499 likes, 160/160 score | github.com/781flyingdutchman/background_downloader | N/A (unsupported ecosystem) | `[ASSUMED]` — Approved for planner, gate behind checkpoint:human-verify |
| `crypto` | pub.dev | mature, `dart.dev` official publisher | 10.4M downloads, 160/160 score | github.com/dart-lang/core (crypto package) | N/A (unsupported ecosystem) | `[ASSUMED]` — Approved for planner, gate behind checkpoint:human-verify (lowest-risk of the three: official Dart team package) |
| `storage_space` | pub.dev | latest release ~12 months old, verified publisher `oodavid.com` | 150/160 score | (publisher-linked repo, not independently re-crawled this session) | N/A (unsupported ecosystem) | `[ASSUMED]` — Approved for planner, gate behind checkpoint:human-verify |

**Packages removed due to slopcheck `[SLOP]` verdict:** none (slopcheck did not run against this ecosystem)
**Packages flagged as suspicious `[SUS]`:** none flagged by an automated tool; all three are `[ASSUMED]` pending human review per the ecosystem-unsupported degradation path — this is the same review bar every other pub.dev dependency in this codebase has passed

## Architecture Patterns

### System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Flutter App (Client)                         │
│                                                                        │
│  Settings Screen ──tap "Download"──▶ ReferenceDataScreen              │
│                                            │                          │
│                                            ▼                          │
│                              [1] Disk-space preflight check           │
│                              (storage_space: free bytes ≥ pack size?) │
│                                            │ pass                     │
│                                            ▼                          │
│                              [2] Lightweight manifest GET             │
│                              (http.Client → CDN /manifest.json)       │
│                              — runs on ANY connection (tiny payload)  │
│                                            │                          │
│                                            ▼                          │
│                              [3] Wi-Fi check (connectivity_plus)      │
│                              on-Wi-Fi? ──no──▶ prompt "Use cellular?" │
│                                            │ yes / overridden         │
│                                            ▼                          │
│                        [4] background_downloader.enqueue(             │
│                              DownloadTask(requiresWiFi, allowPause))  │
│                              ├─ progress stream → Settings row        │
│                              │   subtitle + ReferenceDataScreen bar   │
│                              ├─ Wi-Fi drop → auto-pause/auto-resume   │
│                              ├─ user Cancel → delete partial file     │
│                              └─ app-killed / interruption → partial   │
│                                  file persists (native task DB)       │
│                                            │ complete                 │
│                                            ▼                          │
│                        [5] Checksum verify (crypto: SHA-256)          │
│                              mismatch ──▶ discard, surface error      │
│                                            │ match                    │
│                                            ▼                          │
│                        [6] Atomic swap (extends                      │
│                              first_launch_extractor.dart pattern):    │
│                              DETACH DATABASE off_ref                  │
│                              → replace off_reference.sqlite file      │
│                              → ATTACH DATABASE ... AS off_ref         │
│                              → write new .version marker              │
│                                            │                          │
│                                            ▼                          │
│                        FoodCatalogDao queries now see full catalog    │
└─────────────────────────────────────────────────────────────────────┘
                                            ▲
                                            │ HTTPS (Range-capable, ETag/
                                            │ strong-validator required
                                            │ for resume)
                                            │
┌─────────────────────────────────────────────────────────────────────┐
│                   CDN / Static Host (out of phase scope)              │
│  manifest.json  { current_version, pack_url, pack_sha256,             │
│                    pack_size_bytes, product_count,                    │
│                    delta_from: { "<old_version>": {url, sha256,       │
│                                   size_bytes} } }                     │
│  full_pack_vN.sqlite.gz                                               │
│  delta_vM_to_vN.sqlite (or .json) — changed/added rows + tombstones   │
└─────────────────────────────────────────────────────────────────────┘
        ▲
        │ (build-side, off-app — not this phase's client code)
┌─────────────────────────────────────────────────────────────────────┐
│  Build pipeline (extends tools/ingest_off.py):                        │
│  OFF JSONL dump + daily deltas + AGRIBALYSE join                      │
│  → new full off_reference.sqlite version                              │
│  → diff against previous version → delta artifact + manifest update   │
└─────────────────────────────────────────────────────────────────────┘
```

### Recommended Project Structure

```
lib/
├── data/
│   ├── local/
│   │   └── reference_pack/
│   │       ├── reference_pack_extractor.dart   # atomic swap + DETACH/ATTACH cycle
│   │       └── reference_pack_version_store.dart # on-disk .version marker (full pack, distinct from bundled seed's)
│   ├── remote/
│   │   └── reference_pack_api_client.dart      # manifest GET via http.Client (mockable, mocktail precedent)
│   └── repositories/
│       └── reference_pack_repository.dart      # orchestrates: preflight → manifest → download → verify → swap
├── domain/
│   ├── entities/
│   │   └── reference_pack_status.dart          # sealed class: seed/downloading/full/updateAvailable/failed
│   └── repositories/
│       └── i_reference_pack_repository.dart
├── features/
│   └── reference_data/
│       ├── providers/
│       │   └── reference_pack_notifier.dart
│       ├── screens/
│       │   └── reference_data_screen.dart      # mirrors backup_restore_screen.dart structure
│       └── widgets/
│           └── reference_pack_progress_bar.dart
```

### Pattern 1: DownloadTask with resumability + Wi-Fi gating

**What:** Configure `background_downloader`'s `DownloadTask` to natively express two of CONTEXT.md's locked decisions (Wi-Fi-default, resumable) instead of hand-rolling either.

**When to use:** Both the full-pack download and any delta-artifact download.

**Example:**
```dart
// Source: pub.dev/packages/background_downloader (2026-08-12) — verified
final task = DownloadTask(
  url: manifestEntry.packUrl,
  filename: 'off_reference_full_v${manifestEntry.version}.sqlite.gz',
  directory: 'reference_pack',
  baseDirectory: BaseDirectory.applicationDocuments,
  requiresWiFi: !userAllowedCellularOverride,
  allowPause: true, // enables Range-based resume + absorbs Android's
                     // 9-minute background execution limit automatically
  updates: Updates.statusAndProgress,
  retries: 0, // CONTEXT.md: no auto-retry loop — manual "Resume" only
);

await FileDownloader().enqueue(task);

FileDownloader().updates.listen((update) {
  if (update is TaskProgressUpdate) {
    // update.progress (0.0-1.0); byte counts available via task metadata
    // + update.expectedFileSize for the "340/650 MB" subtitle text.
  } else if (update is TaskStatusUpdate) {
    switch (update.status) {
      case TaskStatus.complete: /* → checksum verify step */
      case TaskStatus.paused: /* Wi-Fi drop mid-download → auto-resume */
      case TaskStatus.failed: /* → manual "Resume" tap required */
      case TaskStatus.canceled: /* → partial file already deleted */
      default:
    }
  }
});
```

### Pattern 2: Checksum verification before trusting a downloaded file

**What:** Never treat a completed download as valid until its SHA-256 matches the manifest's published hash.

**When to use:** After every full-pack or delta download completes, before the atomic swap.

**Example:**
```dart
// Source: crypto package (dart.dev) — chunked read avoids loading a
// 300-800MB file fully into memory
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

Future<bool> verifyChecksum(File file, String expectedSha256Hex) async {
  final digest = await sha256.bind(file.openRead()).first;
  return digest.toString() == expectedSha256Hex;
}
```

### Pattern 3: Runtime DETACH/re-ATTACH swap (extends `first_launch_extractor.dart`)

**What:** `first_launch_extractor.dart`'s atomic-swap pattern only ever runs at app startup, *before* `AppDatabase` connects and issues its one-time idempotent `ATTACH DATABASE`. Phase 9's swap happens **while the app is already running** (a background download can complete while the user is on the Dashboard) — a materially different lifecycle that the existing code has never needed to handle.

**When to use:** After a verified full-pack download or delta application, to make `FoodCatalogDao` see the new data without requiring an app restart.

**Example:**
```dart
// New pattern this phase must introduce — not present anywhere in the
// current codebase (grep-verified: 'ATTACH' only ever runs once, in
// migration_strategy.dart's beforeOpen).
Future<void> swapReferencePack(AppDatabase db, String newDbPath) async {
  // 1. DETACH the currently-attached off_ref schema. Must not be holding
  //    an open cursor/transaction against it at this moment.
  await db.customStatement("DETACH DATABASE off_ref");
  // 2. Replace the file on disk (old file → new file), mirroring
  //    first_launch_extractor.dart's delete-then-write sequence.
  // 3. Re-ATTACH under the same alias so FoodCatalogDao's existing SQL
  //    (which always references 'off_ref.products' etc.) needs no changes.
  await db.customStatement("ATTACH DATABASE '$newDbPath' AS off_ref");
  // 4. Persist the new version marker (separate file from the bundled
  //    seed's off_reference.version — this pack has its own lifecycle).
}
```

### Pattern 4: Manifest-driven update check (tiny payload, any connection)

**What:** A cheap version-comparison GET that can run regardless of Wi-Fi state, per CONTEXT.md's explicit "tiny payload, just a version number" requirement.

**Example:**
```dart
// Source: reuses this app's existing http.Client + mocktail-mock
// convention (see test/features/auth/providers/auth_provider_test.dart's
// `_MockHttpClient extends Mock implements http.Client`)
class ReferencePackApiClient {
  ReferencePackApiClient(this._client);
  final http.Client _client;

  Future<ReferencePackManifest> fetchManifest() async {
    final response = await _client.get(Uri.parse(manifestUrl));
    if (response.statusCode != 200) {
      throw NetworkException('Manifest fetch failed: ${response.statusCode}');
    }
    return ReferencePackManifest.fromJson(jsonDecode(response.body));
  }
}
```

### Anti-Patterns to Avoid

- **Hand-rolling Range-header resume logic on top of `dio`/`http`:** `dio` has no native resumable-download support; building pause/resume/Android-9-minute-limit/iOS-4-hour-limit handling from scratch is a large, error-prone surface for a problem `background_downloader` already solves.
- **Treating OFF's own MongoDB delta exports as directly consumable:** they don't represent deletions and don't match this app's custom SQLite+FTS5+AGRIBALYSE schema — they are, at best, an *upstream input* to this project's own build pipeline, never something the Flutter client parses directly.
- **Applying delta row changes to `products` without also updating `products_fts`:** the FTS5 table is `content='products'` with **no sync trigger** in the current schema (verified: `tools/ingest_off.py`'s DDL has no `CREATE TRIGGER`, only a one-time bulk `INSERT INTO products_fts(rowid, ...)` at initial ingest). Any client-side delta-apply code that writes to `products` and skips `products_fts` will leave search silently stale.
- **Assuming the in-memory Riverpod "is a download in progress" flag is authoritative for the revert-availability check:** the download can outlive the screen and even the app process (native background task); the "in progress" check must consult `background_downloader`'s persistent task state, not just widget-scoped state.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Resumable/pausable HTTP download with Range headers | A custom `dio`/`http` wrapper that tracks byte offsets, sets `Range:` headers, and re-issues requests on failure | `background_downloader`'s `DownloadTask(allowPause: true)` | Native Range-based resume, plus platform-specific background execution limits (Android 9-min, iOS 4-hr) are already handled — this is a large, easy-to-get-subtly-wrong state machine |
| Wi-Fi-only download gating | Manually check `connectivity_plus` before every chunk and pause/resume the transfer loop by hand | `DownloadTask(requiresWiFi: true)` | The plugin ties Wi-Fi state directly into the native download engine's lifecycle, matching CONTEXT.md's "momentary Wi-Fi drop auto-pauses/auto-resumes silently" requirement out of the box |
| Large-file SHA-256 verification | A hand-rolled chunked-read hashing loop | `crypto`'s `sha256.bind(file.openRead())` | Official Dart-team package, already handles streaming without loading the whole file into memory |
| Free-disk-space query | Platform channel + native code per OS | `storage_space` (or `disk_space_plus`) | Both platforms' free-space APIs are already wrapped; writing native iOS/Android code for this is unnecessary |

**Key insight:** Every "don't hand-roll" item above maps to a specific CONTEXT.md locked decision (resumable, Wi-Fi-gated, pre-flight disk check). The temptation in this domain is to reach for `dio` (already familiar from most Flutter tutorials) and manually add Range headers — that path re-implements roughly a dozen edge cases (partial-content responses, 416 range-not-satisfiable, ETag/If-Range validation, OS background-execution limits) that a dedicated, actively-maintained plugin already covers.

## Common Pitfalls

### Pitfall 1: `products_fts` goes silently stale after a delta apply
**What goes wrong:** Search results stop reflecting newly-added or updated products even though the `products` table was correctly updated.
**Why it happens:** `products_fts` is declared `content='products'` with `content_rowid='rowid'` but the schema (per `tools/ingest_off.py`, grep-verified) has **no `CREATE TRIGGER`** keeping it in sync — the original ingest pipeline populates it once via a bulk `INSERT INTO products_fts(rowid, ...)` after loading `products`, not via ongoing triggers.
**How to avoid:** Any client-side or build-side code that inserts/updates/deletes rows in `products` must explicitly mirror the change into `products_fts` (matching FTS5's external-content-table update conventions: `INSERT INTO products_fts(products_fts, rowid, ...) VALUES('delete', ...)` before an update/delete, then a fresh insert) — or, simpler for this phase's cadence (weekly/monthly, not real-time), issue `INSERT INTO products_fts(products_fts) VALUES('rebuild')` once after every delta apply completes.
**Warning signs:** Newly-downloaded products are queryable by exact barcode lookup but don't appear in FTS5 text search.

### Pitfall 2: Swapping `off_reference.sqlite` while `AppDatabase` is mid-query
**What goes wrong:** Corrupted reads, `SQLITE_BUSY`/`SQLITE_LOCKED` errors, or a crash if the underlying file is replaced while an attached-schema query is in flight.
**Why it happens:** `first_launch_extractor.dart`'s existing swap pattern only ever runs before `AppDatabase.connect()` is first called — it has never had to coexist with a live, already-open connection with an active `ATTACH`. Phase 9's swap can happen while the user is actively searching food on the Dashboard.
**How to avoid:** `DETACH DATABASE off_ref` before replacing the file, then re-`ATTACH` after — and ensure no in-flight `FoodCatalogDao` query holds a reference during that window (e.g., serialize the swap through the same Riverpod provider that owns `AppDatabase`, or briefly queue/reject searches during the swap). CONTEXT.md's own locked decision ("food search keeps working normally on the existing starter pack throughout the download") implies the swap itself must be near-instantaneous and must not leave a window where neither DB is attached.
**Warning signs:** Intermittent search failures or empty results immediately after a download completes.

### Pitfall 3: CDN doesn't return a stable strong validator (ETag) → resume silently degrades to full restart
**What goes wrong:** "Resume" appears to work in testing (same CDN session) but starts over from zero in production after any CDN cache/edge-node change.
**Why it happens:** `background_downloader`'s pause/resume is documented as requiring the server's `ETag` to be a *strong* validator and unchanged between pause and resume (or entirely absent) — some CDNs and object-storage services generate weak or non-deterministic ETags across edge nodes.
**How to avoid:** This is a CDN-configuration requirement, not just a client concern — flag it explicitly in whatever coordination hand-off documents the CDN choice (mirroring `docs/backend-contracts/`'s existing pattern for Tomris hand-offs). Test resume against the actual chosen CDN/edge config before relying on it in production, not just against a local dev server.
**Warning signs:** Resume works on a local test server but not against the real CDN once deployed.

### Pitfall 4: Disk-space preflight check doesn't account for transient 2x space during decompression
**What goes wrong:** Preflight check passes ("650MB needed, 700MB free"), download succeeds, but decompression of a `.sqlite.gz` artifact then fails because the compressed download *and* the decompressed output must coexist on disk briefly (mirrors `first_launch_extractor.dart`'s existing gzip-decompress-to-documents-dir step).
**Why it happens:** The check only validated the final installed size, not the peak transient disk usage during download+decompress+old-file-still-present.
**How to avoid:** Size the preflight check against (compressed download size) + (decompressed final size) + a safety margin, not just the advertised "~650MB" final footprint — and delete the old pack (or the old bundled-seed reference) only after the new one is verified and swapped in, per CONTEXT.md's existing atomic-swap intent.
**Warning signs:** Downloads that complete successfully but fail during the "verifying" step specifically on lower-storage devices.

### Pitfall 5: "Is a download in progress" check reads stale/wrong state for the revert-availability rule
**What goes wrong:** Revert is enabled/disabled based on in-memory app state, but the actual download (native background task) is running independently of the widget tree or even the Dart isolate's lifecycle.
**Why it happens:** `background_downloader` intentionally persists task state natively so downloads survive navigation and backgrounding — but that means the single source of truth for "is anything in progress" is the plugin's own task registry/database, not a locally-held Riverpod flag that could desync (e.g., after an app restart mid-download).
**How to avoid:** Query `FileDownloader()`'s task-status API (or its persistent database) directly when deciding whether to show/enable the Revert action, rather than trusting a provider-scoped boolean alone.
**Warning signs:** Revert button briefly enabled/tappable right after an app restart while a download is actually still active in the background.

## Code Examples

Verified patterns from official sources:

### Manifest JSON shape (proposed contract — needs a written spec hand-off)
```json
// This is a design proposal for the CDN-side contract, not a verified
// external API — flag for a docs/data-contracts/ written spec mirroring
// docs/backend-contracts/gdpr-account-deletion.md's existing pattern.
{
  "current_version": "2026-09-off-pack-v3",
  "pack_url": "https://cdn.example.com/off-pack/full_v3.sqlite.gz",
  "pack_size_bytes": 681574912,
  "pack_sha256": "…",
  "product_count": 2500000,
  "delta_from": {
    "2026-08-off-pack-v2": {
      "url": "https://cdn.example.com/off-pack/delta_v2_to_v3.sqlite.gz",
      "size_bytes": 18874368,
      "sha256": "…"
    }
  }
}
```

### Delta artifact shape (proposed — companion SQLite file)
```sql
-- Delta artifact: a small standalone SQLite file, decompressed and
-- ATTACHed temporarily during apply, then discarded after the
-- transaction commits against the real off_reference.sqlite.
CREATE TABLE products_delta (
  -- same columns as the existing `products` table (tools/ingest_off.py's
  -- DDL) — every row here is an insert-or-replace against `products`.
  barcode TEXT PRIMARY KEY,
  product_name TEXT NOT NULL,
  product_name_en TEXT,
  brand TEXT,
  calories_100g REAL,
  protein_100g REAL,
  carbs_100g REAL,
  fat_100g REAL,
  categories_tags TEXT,
  agribalyse_food_code TEXT
);
CREATE TABLE deleted_barcodes (
  barcode TEXT PRIMARY KEY
  -- rows in `products` matching these barcodes must be removed, and
  -- their products_fts rowid entries removed too.
);
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|---------------|--------|
| `flutter_downloader` for background file transfers | `background_downloader` | `flutter_downloader` has been unmaintained for an extended period (its own GitHub issue tracker states "no maintainer"); community discussion explicitly names `background_downloader` as the direct replacement | Should not be added to this project even as a familiar/legacy choice — it was never a dependency here, so there's no migration cost, only a "don't pick the deprecated one" awareness gap |

**Deprecated/outdated:**
- `flutter_downloader`: unmaintained, explicitly superseded by `background_downloader` per its own community.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | `background_downloader` 9.5.7 is the correct package name/version and behaves as documented (Range-based resume, `requiresWiFi`, native background continuation) | Standard Stack, Architecture Patterns | If the plugin's actual pause/resume behavior differs from docs on a specific OS version, the planner's task breakdown (which assumes native resume "just works") would need a fallback design; mitigated by requiring real-device verification (see Validation Architecture) before shipping |
| A2 | `crypto` 3.0.7 and `storage_space` 1.2.0 are current/correct package names and versions | Standard Stack | Low risk — both independently confirmed via live pub.dev pages, not training data alone; `crypto` is an official Dart-team package |
| A3 | The proposed manifest.json / delta-artifact shapes are a reasonable, implementable design — not a verified external contract | Code Examples, Architecture Patterns | CDN hosting is explicitly out of this phase's scope; whoever ultimately builds the build-side pipeline may choose a different shape. This design should be written up as a docs/data-contracts/ spec and confirmed before the client-side parsing code is finalized, mirroring how `docs/backend-contracts/gdpr-account-deletion.md` was handled for Tomris |
| A4 | The chosen (unspecified) CDN will support HTTP Range requests and a stable strong ETag or Last-Modified validator sufficient for resume | Common Pitfalls (Pitfall 3) | If the eventual CDN doesn't meet this bar, resume silently degrades to a full restart on every interruption — directly undermining CONTEXT.md's locked "resume from where they left off" decision. Must be explicitly verified once a CDN is chosen |
| A5 | `products_fts` has no existing sync trigger and must be manually re-synced after any delta write | Common Pitfalls (Pitfall 1) | HIGH confidence — directly grep-verified against `tools/ingest_off.py`'s DDL in this session, not training-data speculation. Low risk of being wrong, but flagged since it materially changes the delta-apply implementation |

**If this table is empty:** N/A — see rows above.

## Open Questions (RESOLVED — see per-question markers below)

1. **What does the eventual CDN choice mean for resume reliability and cost?**
   - What we know: CONTEXT.md explicitly defers CDN hosting as a coordination point, not blocking this phase's planning.
   - What's unclear: Whether the eventual host (S3, Cloudflare R2, Bunny, GitHub Releases, backend-team infra) reliably supports Range requests + stable ETags, and what the egress-cost implications of "multi-hundred-MB downloads for every opted-in user" are.
   - Recommendation: Plan the client-side download/resume logic against the generic HTTP Range contract (works with any Range-capable static host); treat actual CDN selection + a resume-reliability smoke test against it as a pre-launch/human-verification gate, not a client-code blocker.
   - **RESOLVED — deferred by design:** CDN choice is explicitly out of this phase's scope per CONTEXT.md's "Claude's Discretion" section (a flagged, non-blocking coordination point, not a client-code blocker). The client-side logic is planned against the generic HTTP Range contract regardless of eventual host, so no plan is blocked on this question.

2. **Who owns and runs the build-side delta-generation pipeline, and on what cadence?**
   - What we know: `tools/ingest_off.py` already exists and could be extended to also emit a diff against the previous published version; OFF's own dumps regenerate nightly with 14-day rolling deltas.
   - What's unclear: Whether this pipeline runs on Ali's machine manually (like the current Phase 2 seed-generation process), or needs CI/scheduled infra — and how often new full-pack versions are actually cut (weekly? monthly? tied to app releases?).
   - Recommendation: Out of this phase's Flutter-client scope by design, but the planner should still produce/extend `tools/ingest_off.py` (or a sibling script) as part of this phase's deliverables, since the client can't be meaningfully tested end-to-end without at least one real manifest + pack + delta artifact to point at.
   - **RESOLVED:** addressed by Plan 09-07's `tools/build_reference_pack_release.py`, a sibling script to `tools/ingest_off.py` that produces a versioned full-pack release, `manifest.json`, and a delta artifact against a prior version — run manually today (same pattern as the existing Phase 2 seed-generation process), with CI/scheduled infra explicitly left as a future decision, not a blocker for this phase.

3. **Exact bytes-remaining / speed / ETA display source**
   - What we know: CONTEXT.md requires bytes downloaded/total and a determinate percentage.
   - What's unclear: Whether `background_downloader`'s `TaskProgressUpdate` exposes raw byte counts directly or only a 0.0–1.0 fraction (multiple docs excerpts referenced fraction-based progress plus a separate `DownloadProgressIndicator` widget showing speed/time-remaining, but didn't show the exact byte-count field name).
   - Recommendation: Confirm the exact `TaskProgressUpdate` field names during implementation (quick pub.dev API-reference check, not a planning blocker) — worst case, compute bytes-downloaded as `progress * expectedFileSize` from the manifest's already-known `pack_size_bytes`.
   - **RESOLVED:** the documented fallback is specified directly in Plan 09-03 Task 2's DownloadManager action — if raw byte counts are not exposed on `TaskProgressUpdate`, bytesDownloaded is computed via a dedicated, unit-tested `estimateBytesDownloaded(progressFraction, expectedFileSize)` helper using `progress * expectedFileSize`. The exact field-name check itself remains a routine implementation-time detail, not a planning blocker.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter/Dart SDK | All client code | ✓ | Flutter ≥3.44.6 / Dart ≥3.12.2 (per pubspec.yaml) | — |
| pub.dev network access | Installing `background_downloader`/`crypto`/`storage_space` | Not verifiable from this research session (no live `flutter pub get` run) | — | Standard `flutter pub add` at implementation time; no fallback needed, this is a routine dependency add |
| A live CDN serving `manifest.json` + pack/delta files | End-to-end testing of the real download flow | ✗ — does not exist yet (CDN hosting is an explicit coordination point, out of this phase's scope) | — | Client-side unit/widget tests must mock `http.Client` (manifest) per this project's existing mocktail convention; true resumable-download behavior against a real Range-capable server needs either a throwaway local test server (`dart:io HttpServer`) or a real-device checkpoint once a CDN exists — flag as a pre-launch human-verification item, mirroring Phase 3's barcode-scanning and Phase 7's Keycloak real-device gates |
| A build-side pipeline emitting versioned packs + deltas | Producing test fixtures for the client | ✗ — `tools/ingest_off.py` currently only produces a single filtered starter-seed pack, not a delta-capable versioned series | Extend `tools/ingest_off.py` (or add a sibling script) as part of this phase's own deliverables — not purely external |

**Missing dependencies with no fallback:**
- A real CDN with confirmed Range/ETag support — genuinely blocks true end-to-end verification of resumable downloads (not blocking planning or most implementation, only the final real-network verification step).

**Missing dependencies with fallback:**
- pub.dev network access — routine, always available in practice, no special handling needed.
- Build-side pipeline — this phase should build the minimum version of it itself (extending `tools/ingest_off.py`) rather than treating it as purely external.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | `flutter_test` + `mocktail` (existing project standard, used consistently since Phase 1) |
| Config file | none — no dedicated test-runner config exists in this project; tests run via `flutter test` |
| Quick run command | `flutter test test/features/reference_data/ test/data/local/reference_pack/` (new test dirs this phase creates) |
| Full suite command | `flutter test` |

### Phase Requirement Requirements → Test Map

This phase has no assigned v1 REQ-IDs (per ROADMAP.md — v1.0.x enrichment kept in-roadmap for continuity, served by Phase 2's bundled seed for launch). The success criteria below are this phase's own testable behaviors, mapped from CONTEXT.md's locked decisions.

| Behavior | Test Type | Automated Command | File Exists? |
|----------|-----------|--------------------|-------------|
| Manifest fetch + version comparison logic | unit | `flutter test test/data/local/reference_pack/reference_pack_repository_test.dart -x` | ❌ Wave 0 |
| Disk-space preflight blocks download when insufficient | unit | `flutter test test/data/local/reference_pack/disk_space_check_test.dart -x` | ❌ Wave 0 |
| Checksum verification accepts matching / rejects mismatched hash | unit | `flutter test test/data/local/reference_pack/checksum_verifier_test.dart -x` | ❌ Wave 0 |
| Settings row subtitle reflects each status state (seed/downloading/full/update-available) | widget | `flutter test test/features/settings/reference_data_row_test.dart -x` | ❌ Wave 0 |
| Revert confirmation dialog + disk reclaim + schedule reset to Manual | widget | `flutter test test/features/reference_data/reference_data_screen_test.dart -x` | ❌ Wave 0 |
| Foreground-triggered Weekly/Monthly throttle check (extends `lib/app.dart` observer) | unit | `flutter test test/app_lifecycle_reference_pack_test.dart -x` | ❌ Wave 0 |
| Actual resumable download (pause/resume/Wi-Fi-drop/background-continuation) against a real network | manual / real-device | N/A — cannot be meaningfully automated against `background_downloader`'s native platform channels, same class of requirement as Phase 3's barcode-scanning P0 and Phase 7's Keycloak real-device gates | manual-only, justified |
| `products_fts` stays in sync after a delta apply | integration | `flutter test integration_test/reference_pack_delta_apply_test.dart -x` (requires an in-memory or on-disk SQLite fixture, not a widget test) | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** `flutter test test/data/local/reference_pack/ test/features/reference_data/`
- **Per wave merge:** `flutter test`
- **Phase gate:** Full suite green before `/gsd-verify-work`

### Wave 0 Gaps
- [ ] `test/data/local/reference_pack/reference_pack_repository_test.dart` — manifest parsing, version comparison
- [ ] `test/data/local/reference_pack/disk_space_check_test.dart` — preflight logic
- [ ] `test/data/local/reference_pack/checksum_verifier_test.dart` — SHA-256 match/mismatch
- [ ] `test/features/settings/reference_data_row_test.dart` — subtitle state rendering
- [ ] `test/features/reference_data/reference_data_screen_test.dart` — download screen, revert dialog
- [ ] `integration_test/reference_pack_delta_apply_test.dart` — real SQLite fixture proving `products_fts` sync after delta apply (this is the single highest-value new test this phase needs, given Pitfall 1 above)
- [ ] Mock HTTP client for manifest tests: reuse the existing `_MockHttpClient extends Mock implements http.Client` convention (see `test/features/auth/providers/auth_provider_test.dart`) rather than inventing a new mocking approach

## Security Domain

`security_enforcement` is absent from `.planning/config.json` — treated as enabled per the default rule.

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-------------------|
| V2 Authentication | No | This phase has zero auth/Account Mode coupling (confirmed, CONTEXT.md) |
| V3 Session Management | No | No session concept involved |
| V4 Access Control | No | No server-side access control — CDN serves public static reference data |
| V5 Input Validation | Yes | The manifest.json response and delta artifact must be treated as untrusted input: validate JSON shape before use, validate the SHA-256 checksum before applying any downloaded file, and never construct file paths from any server-supplied string (mirrors the existing `T-02-03-02` mitigation already documented in `first_launch_extractor.dart` — "output path is always derived from `getApplicationDocumentsDirectory`, never from user input" — the same discipline applies to any server-supplied filename/version string here) |
| V6 Cryptography | Yes | SHA-256 checksum verification via the official `crypto` package, never hand-rolled — see Don't Hand-Roll |

### Known Threat Patterns for this stack

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|----------------------|
| Compromised/spoofed CDN response serving a malicious `off_reference.sqlite` (path traversal via a crafted filename, or a corrupted/tampered pack silently accepted) | Tampering | Mandatory SHA-256 checksum verification before any downloaded file is swapped in; never derive on-disk file paths from server-supplied strings (extend the existing `T-02-03-02` mitigation) |
| Man-in-the-middle downgrade of the manifest response (attacker serves a stale/malicious manifest over an insecure channel) | Tampering / Spoofing | HTTPS-only CDN URL (never allow plain HTTP); this is a CDN-configuration requirement to flag alongside Pitfall 3/A4 |
| Denial of service via a manifest that advertises an implausible pack size, exhausting device storage | Tampering | Disk-space preflight check already locked in CONTEXT.md; additionally sanity-bound the manifest's advertised size against a reasonable maximum before trusting it for the preflight calculation |

## Sources

### Primary (HIGH confidence)
- pub.dev live package pages (fetched 2026-08-12): `background_downloader` (9.5.7), `dio` (5.11.0), `crypto` (3.0.7), `storage_space` (1.2.0), `disk_space_plus` (0.2.6) — version, publisher, score, license, download/like counts
- Codebase inspection (this session): `lib/core/assets/first_launch_extractor.dart`, `lib/data/local/app_database.dart`, `lib/data/local/migrations/migration_strategy.dart`, `lib/app.dart`, `lib/domain/entities/backup_metadata.dart`, `tools/ingest_off.py`, `tools/README.md`, `test/features/auth/providers/auth_provider_test.dart`, `pubspec.yaml`
- GitHub repo README (WebFetch, 2026-08-12): `github.com/781flyingdutchman/background_downloader` — API examples, pause/resume/background-continuation behavior, ETag resume requirement, persistent task database

### Secondary (MEDIUM confidence)
- WebFetch of `https://world.openfoodfacts.org/data` (2026-08-12) — export formats (MongoDB dump, JSONL, Parquet, CSV, RDF), sizes, and the delta-export mechanism (14-day rolling, timestamp-keyed, `mongoimport`-based, cannot represent deletions)
- WebSearch cross-verification of `flutter_downloader`'s unmaintained status and community-recommended migration to `background_downloader` (GitHub issues)
- WebSearch on SQLite/mobile delta-patching literature (bsdiff/HDiffPatch, row-level delta sync) — general pattern knowledge, not a specific verified library recommendation for this project

### Tertiary (LOW confidence)
- Exact `TaskProgressUpdate` field names for byte-level progress (see Open Question 3) — pieced together from partial doc excerpts, not a full API reference read
- Manifest.json / delta-artifact JSON shapes proposed in this document are original design proposals (A3), not verified against any existing external contract

## Metadata

**Confidence breakdown:**
- Standard stack (client-side download library choice): HIGH — `background_downloader` vs. `dio`/`flutter_downloader` tradeoffs are well-documented and directly verified against live pub.dev pages and the plugin's own README
- Architecture (atomic swap, delta design): MEDIUM — the DETACH/re-ATTACH pattern and delta-artifact shape are sound engineering designs grounded in this codebase's real schema, but are original proposals (not verified against an existing external spec) since CDN/build-pipeline ownership is explicitly out of this phase's scope
- Pitfalls: HIGH for the two codebase-specific pitfalls (`products_fts` sync gap, live-swap-while-querying) since both were grep-verified against actual project source; MEDIUM for the CDN-configuration-dependent pitfalls (ETag/Range support) since no CDN has been chosen yet

**Research date:** 2026-08-12
**Valid until:** ~30 days for the client-side package recommendations (stable ecosystem, low churn); Open Food Facts export format details should be re-checked if research is reused after a longer gap, since OFF's own data-export tooling has changed format offerings before (e.g., Parquet is noted as "beta")
