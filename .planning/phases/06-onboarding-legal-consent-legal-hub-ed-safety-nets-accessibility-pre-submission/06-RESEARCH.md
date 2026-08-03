# Phase 6: Onboarding, Legal Consent, Legal Hub, ED Safety Nets, Accessibility & Pre-Submission - Research

**Researched:** 2026-08-03
**Domain:** Flutter onboarding UX, GDPR consent mechanics, in-app markdown legal documents, ED safety-net UX, Flutter accessibility (dark mode / Dynamic Type / Semantics), iOS Privacy Manifest, Play Data Safety
**Confidence:** MEDIUM-HIGH (verified against live pub.dev registry data, Apple's own GitHub source for shipped privacy manifests, and the actual current codebase; GDPR/TMG legal specifics remain MEDIUM per PITFALLS.md's own caveat — a lawyer review is still a tracked pre-launch blocker, not resolved by this research)

## Summary

This phase wraps the already-shippable Local Mode app (Phase 5 complete) in the store-submission shell: onboarding screens, legal consent capture, a Legal Hub, two ED safety-net trigger points, an accessibility pass, and pre-submission artifacts (`PrivacyInfo.xcprivacy`, a drafted Play Data Safety doc). Per `06-CONTEXT.md`, the Mode Choice screen and its equal-weight-card audit (ONBD-03) are explicitly deferred to Phase 7 — the flow is Splash → Welcome (single "Continue" button) → Legal Consent → Profile Setup → 3-slide Carousel → Dashboard.

The codebase is more ready for this phase than the phase description implies: `ConsentRecordsTable`/`ConsentRecordsDao` are fully built and tested (Phase 1), and — a significant find this session — **a complete Material 3 dark theme (`buildDarkTheme()`) already exists and is already wired into `MaterialApp.router`** (`lib/core/theme/app_theme.dart`, `lib/app.dart`), contradicting the STATE.md flag that a dark palette still needed deriving. ACC-01 is therefore mostly a verification/contrast-audit task, not a build-from-scratch task. Conversely, two real gaps were found that CONTEXT.md's additional-context did not flag: (1) there is no runtime app-version-reading package in `pubspec.yaml` at all, which LEGAL-03 requires for every `consent_records` write, and (2) `WeightScreen`'s target-weight field is a raw `onChanged` per-keystroke auto-save, not a dialog — inserting a blocking ED-safety-net modal there naively will fire mid-keystroke unless triggering is moved to blur/submit.

No new markdown-rendering, first-launch-detection, or carousel package needs heavy justification: `flutter_markdown_plus` (official `flutter_markdown`'s community-maintained continuation) for documents, `shared_preferences` for the onboarding-gate boolean, and Flutter's built-in `PageView` for the carousel are all the standard, minimal, zero-analytics choices consistent with this project's established "prefer official/minimal, avoid unnecessary deps" pattern (`file_selector` over `file_picker`, `fl_chart` over `syncfusion_flutter_charts`). Because slopcheck does not support the pub.dev/Dart ecosystem (confirmed this session — `slopcheck install --ecosystem` supports pypi/npm/crates.io/go/rubygems/maven/packagist only, no pub), every new package recommendation below is tagged `[ASSUMED]` per this project's own established precedent (Plans 04-11, 05-08, 05-09, 05-16 all required a blocking `checkpoint:human-verify` for exactly this reason) — the planner must gate each new pubspec addition behind a human-verify checkpoint, not treat pub.dev registry presence alone as sufficient.

**Primary recommendation:** Build onboarding/legal/ED-safety-net/accessibility work almost entirely with packages already in `pubspec.yaml` plus three small additions (`shared_preferences`, `flutter_markdown_plus`, `package_info_plus`) — no custom parsers, no custom carousel engine, no custom crash-prone dialog stack; reuse the existing `ConsentRecordsDao`, existing theme tokens (including the already-built dark theme), and the existing repository/`@riverpod` provider conventions verbatim.

## Architectural Responsibility Map

This app has no active backend/API tier in Local Mode (`AUTH-07`: zero server contact). The only two live tiers this phase touches are the Flutter client and its on-device Drift/SQLite store, plus a third "bundled static assets" analog (markdown files shipped inside the app package, not fetched over network).

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Onboarding flow navigation & first-launch gating | Client (go_router + Riverpod) | Local Storage (SharedPreferences flag) | Gate state must survive app restarts; routing logic lives entirely in the client |
| Splash auto-advance timer | Client | — | Pure UI timer, no persistence |
| Legal Consent checkbox state + validation | Client | Local Storage (Drift `consent_records` write) | UI holds transient checkbox state; DB write is the durable legal-evidence side effect |
| Legal document content (Terms/Privacy/Disclaimer/Impressum) | Bundled Static Assets (`docs/legal/*.md`) | Client (markdown rendering) | Content lives as versioned files shipped in the app package; client only renders |
| Consent history read (`ConsentRecordsDao.watchConsents`) | Local Storage (Drift) | Client (display) | Read-only projection of durable audit data |
| ED safety-net calorie/BMI check | Client (pure Dart logic + dialog) | — | No persistence of trigger events by design (zero-analytics principle) |
| Accessibility (dark mode, Dynamic Type, VoiceOver/TalkBack, tap targets) | Client (Flutter theme + widget tree) | — | Purely a presentation-layer concern; no data model impact |
| `PrivacyInfo.xcprivacy` / Play Data Safety draft | Platform Packaging (iOS build config / docs artifact) | Client (declares what APIs the client code actually calls) | Not a runtime tier — a build-time/store-metadata artifact describing the client's own API usage |

**Why this matters:** every capability in this phase maps to either "client-only" or "client + local DB" — there is no risk of accidentally routing legal/consent logic through a backend tier that doesn't exist yet in this build. The one common misassignment risk to watch for: putting GDPR-rights "action" logic (export/delete) in the Legal Hub as new screens — CONTEXT.md is explicit that PRIV-06 is an *explanatory redirect layer* over Phase 5's already-built Export Data / Danger Zone screens, not new client-tier functionality.

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| ONBD-01 | Splash screen, 2-3s auto-advance | Standard `Future.delayed` + `context.go()` pattern; see Code Examples §1 |
| ONBD-02 | Welcome screen equal-weight CTAs | **Overridden by CONTEXT.md**: collapses to single "Continue" button this phase; equal-weight requirement moot until Phase 7 reintroduces a second path |
| ONBD-03 | Mode Choice equal-weight card audit | **Deferred to Phase 7 per CONTEXT.md** — no screen/route built this phase; do not implement |
| ONBD-04 | Profile Setup — optional fields, auto-save, no blocking validation | Already fully built (Phase 1 `ProfileScreen`/`ProfileForm`); this phase only touches its footer copy (drop mode-conditional branching) and adds the kcal-override ED safety-net hook |
| ONBD-05 | Onboarding Carousel, 3-4 slides, swipeable, Skip/Go-to-Dashboard | **PageView** (built-in, no new dependency) — see Standard Stack + Don't Hand-Roll |
| LEGAL-01 | 4 mandatory separate checkboxes, disabled Accept button | Local `StatefulWidget` checkbox state; see Code Examples §2 |
| LEGAL-02 | 16+ self-declaration 5th checkbox | Same screen, optional checkbox, included in `consentsGiven` JSON array per existing table doc comment |
| LEGAL-03 | Consent event recorded (UTC timestamp, app version, policy version) | `ConsentRecordsDao.insertConsent` already exists; **app version requires a new `package_info_plus` dependency — not currently in pubspec.yaml, a genuine gap** (see Common Pitfalls) |
| LEGAL-04 | View Terms/Privacy/Disclaimer links from Legal Consent | Reuses the same markdown-rendered document screen the Legal Hub uses, per CONTEXT.md decision |
| LEG-01 | Legal Hub within 2 taps | New "Legal & Privacy" `ListTile` in existing `SettingsScreen` (already ≤2 taps from anywhere via bottom nav) |
| LEG-02 | Health Disclaimer visible from Legal Consent + Legal Hub | Same shared markdown-doc-screen pattern as LEGAL-04 |
| LEG-03 | Impressum (TMG §5/MStV §18) within 2 taps | Rendered with honest placeholder text per CONTEXT.md; real entity data blocked on Dr. Thomas decision (tracked pre-launch blocker, not resolved here) |
| ACC-01 | System dark mode both platforms | **Already built** — `buildDarkTheme()` exists and is wired via `MaterialApp.router(theme:, darkTheme:)`; this phase's work is verification/contrast-audit, not construction |
| ACC-02 | Dynamic Type / font scaling without breakage | `MediaQuery.textScalerOf(context).clamp(...)` pattern — see Code Examples §5 |
| ACC-03 | VoiceOver/TalkBack semantic labels | `Semantics`/`ExcludeSemantics`/`mergeSemantics` widgets — standard Flutter a11y API, see Architecture Patterns |
| ACC-04 | Color-blind-friendly charts/indicators | Already partially satisfied — `AppColors.warningAmber` exists specifically for this (see `color_tokens.dart:79-83`); verify remaining chart/indicator surfaces from Phase 5 |
| ACC-05 | ≥44×44pt tap targets | Flutter's default `Material` tap targets (`kMinInteractiveDimension = 48.0` logical px) already exceed 44pt; audit custom `InkWell`/`GestureDetector` usages that opt out of default sizing |
| NFR-01/02/03/04 | Non-judgmental tone, SAM test, no manipulative gamification | Copy-review concern, not a technical one; PITFALLS.md M7/M9 already document the tone patterns to avoid |
| NFR-07 | ED safety nets: refuse <1200kcal / BMI<17.5 without warning | New `EdSafetyNetChecker` shared service + shared dialog widget, two call sites (`ProfileScreen`, `WeightScreen`) — see Architecture Patterns |
| PRIV-06 | GDPR rights exercisable from Legal Hub | Explanatory redirect layer over Phase 5's existing Export Data / Danger Zone screens — no new data-mutation logic this phase |
</phase_requirements>

## Project Constraints (from CLAUDE.md)

No `CLAUDE.md` file exists at the project root. No project-specific directives to enforce beyond what `.planning/STATE.md`'s "Cross-Cutting Invariants" section already documents (no third-party analytics/ad/tracking SDKs; offline-first; non-judgmental copy; honest CO₂ confidence bands; local-data-by-default). No `.claude/skills/` or `.agents/skills/` directory exists either.

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|---------------|
| `flutter_markdown_plus` | `^1.0.12` | Renders `docs/legal/*.md` as in-app document screens | Official `flutter_markdown`'s community-maintained continuation after Google discontinued it (30 May, per GitHub flutter/flutter#162966); maintained by verified publisher `foresightmobile.com`; 160/160 pub score, BSD-3-Clause, zero network dependencies in its own dependency graph (`flutter`, `markdown`, `meta`, `path` only) `[ASSUMED — pub.dev not slopcheck-verifiable]` |
| `shared_preferences` | `^2.5.5` | Persists the "has completed onboarding" boolean flag read by the go_router redirect gate | Official Flutter-team package (`publisher:flutter.dev`, `is:flutter-favorite`), 160/160 pub score; already the de-facto standard for exactly this "first launch" idiom project-wide in the Flutter ecosystem `[ASSUMED — pub.dev not slopcheck-verifiable, but same publisher as this project's own `flutter_local_notifications`/`path_provider` precedent]` |
| `package_info_plus` | `^10.2.1` | Reads the running app's version string (e.g. `"0.1.0+1"`) at runtime for `LEGAL-03`'s `appVersion` column | **New requirement, not previously flagged** — no package in this project currently exposes the app version to Dart code; `pubspec.yaml`'s `version:` field is a build-time constant with no runtime accessor without this package. Same publisher family (`fluttercommunity.dev`) as already-approved `share_plus`/`connectivity_plus`; flutter-favorite, 150/160 score `[ASSUMED — pub.dev not slopcheck-verifiable]` |
| `PageView` + `PageController` | Flutter SDK built-in | 3-slide Onboarding Carousel (ONBD-05) | Zero new dependency; Flutter 3.16+ also ships a Material 3 `CarouselView`, but that widget targets peer-content browsing (galleries/story tiles), not linear step-by-step onboarding with Skip/Done semantics — `PageView` + a hand-rolled 3-dot indicator is the standard pattern for onboarding specifically `[MEDIUM confidence, WebSearch cross-verified]` |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `go_router` | `17.3.0` (existing) | Top-level `redirect:` callback on `GoRouter` gates every route to Splash/onboarding until the SharedPreferences flag is set | Standard go_router idiom for auth/onboarding gating; already the project's router |
| `url_launcher` | `^6.3.1` (existing) | Opens `tel:` links for BZgA/ANAD e.V. helpline numbers from the ED safety-net dialog and the standalone "Concerned about eating?" entry | Already approved and in use (methodology link, Phase 3) |
| `flutter_riverpod` / `riverpod_annotation` | existing pins | New `ConsentNotifier`, `EdSafetyNetChecker`-consuming state in `ProfileScreen`/`WeightScreen` | Same `@riverpod class` codegen convention as every other feature |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `flutter_markdown_plus` | `flutter_markdown_community` (another fork), `markdown_widget`, `gpt_markdown` | `flutter_markdown_plus` has the highest independent-signal score (160/160, verified publisher, most likes/downloads) among the discontinued-`flutter_markdown` successors; the others add TOC/custom-node features this phase doesn't need for 4 static documents |
| `PageView` | `carousel_slider` (community package), `introduction_screen` / `intro_slider` packages | Package-based onboarding libraries add auto-rotation and prebuilt Skip/Done chrome, but bring an extra dependency and CONTEXT.md's copy/behavior (custom "Skip intro" link position, sticky "Go to Dashboard") is bespoke enough that the prebuilt chrome doesn't save real effort |
| Hand-rolled dot indicator | `smooth_page_indicator` package | 3 fixed dots is a ~15-line `AnimatedContainer` row; not worth a new dependency |
| `shared_preferences` for onboarding flag | A new Drift table/column, or inferring "onboarding done" from `consent_records` non-empty | A dedicated boolean survives even if a user aborts mid-Carousel after already consenting (consent-exists ≠ onboarding-finished); a Drift migration for one boolean is disproportionate versus the standard `shared_preferences` idiom |

**Installation:**
```bash
flutter pub add flutter_markdown_plus shared_preferences package_info_plus
```

**Version verification (performed this session):**
- `flutter_markdown_plus` — latest `1.0.12`, published 2026-07-10 (24 days before this research date) — [VERIFIED: pub.dev API]
- `shared_preferences` — latest `2.5.5`, published 2026-03-25 — [VERIFIED: pub.dev API]
- `package_info_plus` — latest `10.2.1`, published 2026-07-15 — [VERIFIED: pub.dev API]

## Package Legitimacy Audit

`slopcheck 0.6.1` is installed and runs, but its `--ecosystem` flag only supports `{pypi, npm, crates.io, go, rubygems, maven, packagist}` — **pub.dev/Dart is not a supported ecosystem** (confirmed by running `slopcheck install --help` this session). Per the graceful-degradation rule, every package below is tagged `[ASSUMED]` rather than `[VERIFIED]`, and per this project's own established precedent (STATE.md: `flutter_slidable` at Plan 04-11, `fl_chart`/`flutter_local_notifications`/`timezone`/`flutter_timezone` at Plan 05-08, `share_plus`/`csv`/`excel` at Plan 05-09, `file_selector` at Plan 05-16 — **every single prior pub.dev addition in this project has required a blocking human-verify checkpoint** for exactly this reason), the planner must add a `checkpoint:human-verify` task before each new pubspec entry below.

| Package | Registry | Age | Downloads | Source Repo | slopcheck | Disposition |
|---------|----------|-----|-----------|-------------|-----------|-------------|
| `flutter_markdown_plus` | pub.dev | v1.0.12 published 2026-07-10 (~24 days old at research time; project itself/predecessor is much older) | 461k/wk, 135 likes | github.com/foresightmobile/flutter_markdown_plus | N/A (unsupported ecosystem) | ASSUMED — planner must add `checkpoint:human-verify` |
| `shared_preferences` | pub.dev | v2.5.5 published 2026-03-25; package itself is a multi-year official Flutter-team plugin | 5.66M/30d, 10,551 likes | github.com/flutter/packages | N/A (unsupported ecosystem) | ASSUMED — planner must add `checkpoint:human-verify` (low practical risk: official `flutter.dev` publisher, flutter-favorite) |
| `package_info_plus` | pub.dev | v10.2.1 published 2026-07-15; package itself is a multi-year `fluttercommunity.dev` plugin (same family as already-approved `share_plus`) | 4.97M/30d, 2,791 likes | github.com/fluttercommunity/plus_plugins | N/A (unsupported ecosystem) | ASSUMED — planner must add `checkpoint:human-verify` |

**Packages removed due to slopcheck `[SLOP]` verdict:** none (slopcheck could not evaluate any of these — the ecosystem gate itself is the finding, not a specific rejection).
**Packages flagged as suspicious `[SUS]`:** none by independent signal review (all three carry official/flutter-favorite/verified-publisher status and >100k weekly downloads) — but all three remain formally `[ASSUMED]` and must be checkpoint-gated per project convention regardless of how low-risk they appear.

## Architecture Patterns

### System Architecture Diagram

```
App cold start
      │
      ▼
 main() / WidgetsFlutterBinding
      │
      ▼
 GoRouter.redirect(context, state)  ──reads──▶ SharedPreferences['hasCompletedOnboarding']
      │
      ├── false (first launch, or onboarding abandoned) ──▶ /splash
      │         │
      │         ▼
      │     Splash (2-3s timer) ──auto-advance──▶ /welcome
      │         │
      │         ▼
      │     Welcome ("Continue" button, single CTA) ──▶ /legal-consent
      │         │
      │         ▼
      │     Legal Consent (4 mandatory + 1 optional checkbox)
      │         │  "View Terms/Privacy/Disclaimer" ──▶ shared MarkdownDocScreen(docs/legal/*.md)
      │         │  "Accept and Continue" (disabled until 4 mandatory checked)
      │         ▼
      │     ConsentRepository.recordConsent()  ──writes──▶  Drift consent_records (append-only)
      │         │
      │         ▼
      │     Profile Setup (existing ProfileScreen, footer copy adjusted; ED safety-net hook on kcal override)
      │         │
      │         ▼
      │     Onboarding Carousel (PageView, 3 slides, "Skip intro" / sticky "Go to Dashboard")
      │         │
      │         ▼
      │     SharedPreferences['hasCompletedOnboarding'] = true
      │         │
      │         ▼
      └── true ──────────────────────────────────────────▶ /dashboard (AppShell bottom-nav)


Settings tab ──▶ "Legal & Privacy" row ──▶ Legal Hub
                                              ├─ About
                                              ├─ Legal Documents ──▶ shared MarkdownDocScreen (Terms/Privacy/HealthDisclaimer/Impressum)
                                              ├─ Your Rights (static explanatory text)
                                              │     ├─ Access & Portability ──▶ existing Export Data screen (Phase 5)
                                              │     └─ Consent withdrawal ──▶ existing Danger Zone screen (Phase 5)
                                              ├─ View my consent history ──▶ ConsentRepository.watchConsents() (read-only list)
                                              └─ Contact email (static)

ProfileScreen kcal-override dialog ──▶ EdSafetyNetChecker.checkCalorieTarget(value) ─┐
                                                                                       ├─▶ shared EdSafetyNetDialog (if triggered & not already-confirmed-for-this-value)
WeightScreen target-weight field (on blur/submit, NOT onChanged) ──▶ EdSafetyNetChecker.checkBmi(weightKg, heightCm) ─┘
```

### Recommended Project Structure

```
lib/
├── features/
│   ├── onboarding/
│   │   ├── screens/
│   │   │   ├── splash_screen.dart
│   │   │   ├── welcome_screen.dart
│   │   │   └── onboarding_carousel_screen.dart
│   │   └── providers/
│   │       └── onboarding_gate_provider.dart   # wraps SharedPreferences flag read/write
│   └── legal/
│       ├── screens/
│       │   ├── legal_consent_screen.dart
│       │   ├── legal_hub_screen.dart
│       │   ├── legal_document_screen.dart      # shared by Consent links AND Legal Hub
│       │   └── consent_history_screen.dart
│       ├── providers/
│       │   └── consent_notifier.dart
│       └── widgets/
│           └── consent_checkbox_tile.dart
├── domain/
│   ├── services/
│   │   ├── ed_safety_net_checker.dart          # pure Dart, framework-free, unit-testable
│   │   └── legal_document_loader.dart          # frontmatter version parser + asset loader
│   └── repositories/
│       └── i_consent_repository.dart
├── data/
│   └── repositories/
│       └── consent_repository.dart             # DriftConsentRepository, mirrors existing repo convention
└── core/
    └── widgets/
        └── ed_safety_net_dialog.dart            # single shared widget, two call sites

docs/
└── legal/
    ├── terms.md
    ├── privacy.md
    ├── health_disclaimer.md
    └── impressum.md

docs/
└── PLAY_DATA_SAFETY_DRAFT.md                    # or docs/store/ — drafted answers, not live-submitted

ios/Runner/
└── PrivacyInfo.xcprivacy
```

### Pattern 1: go_router redirect-based onboarding gate

**What:** A single `redirect:` callback on the top-level `GoRouter` checks a `SharedPreferences` boolean before allowing navigation to any route other than the onboarding stack itself.
**When to use:** Any app that needs a "run once, then never again" pre-app-shell flow.
**Example:**
```dart
// Source: standard go_router redirect idiom, cross-verified against
// pub.dev/packages/go_router docs and community precedent this session.
GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    final hasOnboarded = ref.read(onboardingGateProvider);
    final onOnboardingRoute = state.matchedLocation.startsWith('/splash') ||
        state.matchedLocation.startsWith('/welcome') ||
        state.matchedLocation.startsWith('/legal-consent') ||
        state.matchedLocation.startsWith('/onboarding-carousel');
    if (!hasOnboarded && !onOnboardingRoute) return '/splash';
    if (hasOnboarded && onOnboardingRoute) return '/dashboard';
    return null; // no redirect
  },
  routes: [...],
)
```
Note: `initialLocation` currently is `'/profile'` (`app_router.dart:81`) — this must change to `'/splash'` (or the redirect must fire even from `/profile` as `initialLocation`, since go_router evaluates `redirect` against the initial location too).

### Pattern 2: Legal Consent checkbox gating

**What:** `Accept and Continue` stays disabled until all 4 mandatory booleans are true; no checkbox starts pre-checked (GDPR Planet49/EDPB requirement, PITFALLS.md C5).
**Example:**
```dart
class _LegalConsentScreenState extends State<LegalConsentScreen> {
  bool _termsChecked = false;
  bool _privacyChecked = false;
  bool _notMedicalAdviceChecked = false;
  bool _userResponsibilityChecked = false;
  bool _age16PlusChecked = false; // optional, 5th checkbox

  bool get _canAccept =>
      _termsChecked &&
      _privacyChecked &&
      _notMedicalAdviceChecked &&
      _userResponsibilityChecked;

  Future<void> _onAccept() async {
    final consentsGiven = [
      'terms', 'privacy', 'not_medical_advice', 'user_responsibility',
      if (_age16PlusChecked) 'age_16_plus',
    ];
    await ref.read(consentRepositoryProvider).recordConsent(
      policyVersion: await ref.read(legalDocumentLoaderProvider).versionOf('terms.md'),
      consentsGiven: consentsGiven,
    );
    if (mounted) context.go('/profile');
  }
}
```

### Pattern 3: Hand-rolled frontmatter version parser (no new dependency)

**What:** Extract the `version:` field from a markdown file's `---\n...\n---` frontmatter block without pulling in a `yaml` or `frontmatter` package.
**When to use:** Exactly this project's precedent — `check_privacy_deps.dart` (Plan 01-06, per STATE.md) already deliberately hand-parses simple YAML rather than adding the `yaml` package for a narrow need. Apply the same reasoning here: only one scalar key (`version`) needs extracting.
**Example:**
```dart
/// Extracts the `version:` value from a markdown file's frontmatter block
/// and returns (version, bodyMarkdown) with the frontmatter stripped.
({String version, String body}) parseLegalDocument(String raw) {
  if (!raw.startsWith('---')) return (version: 'unknown', body: raw);
  final endIndex = raw.indexOf('\n---', 3);
  if (endIndex == -1) return (version: 'unknown', body: raw);
  final frontmatter = raw.substring(3, endIndex);
  final versionLine = frontmatter
      .split('\n')
      .firstWhere((l) => l.trim().startsWith('version:'), orElse: () => '');
  final version = versionLine.split(':').skip(1).join(':').trim();
  final body = raw.substring(endIndex + 4).trimLeft();
  return (version: version.isEmpty ? 'unknown' : version, body: body);
}
```

### Pattern 4: Shared ED safety-net checker + dialog (single component, two call sites)

**What:** One pure-Dart checker function pair + one dialog widget, invoked from both `ProfileScreen`'s kcal-override dialog and `WeightScreen`'s target-weight field.
**When to use:** Per CONTEXT.md's locked decision — never duplicate the threshold/copy logic across the two screens.
**Example:**
```dart
// domain/services/ed_safety_net_checker.dart — pure Dart, zero Flutter imports.
abstract final class EdSafetyNetChecker {
  static const double kcalFloor = 1200;
  static const double bmiFloor = 17.5;

  static bool calorieTargetIsUnsafe(double kcalTarget) => kcalTarget < kcalFloor;

  /// Returns null (check skipped) when height is unavailable — CONTEXT.md:
  /// "no blocking validation," silently skip rather than prompt for height.
  static bool? bmiIsUnsafe({required double weightKg, double? heightCm}) {
    if (heightCm == null || heightCm <= 0) return null;
    final heightM = heightCm / 100;
    final bmi = weightKg / (heightM * heightM);
    return bmi < bmiFloor;
  }
}
```
Both call sites track "already confirmed for this exact value" locally (per CONTEXT.md's re-warn rule) rather than persisting it — consistent with the zero-analytics/zero-trigger-logging principle.

### Pattern 5: Dynamic Type clamping (ACC-02)

**What:** Respect system font scaling but clamp to a safe range so layouts don't break at extreme scales.
**Example:**
```dart
// Applied once, at the MaterialApp.router level (app.dart), via MediaQuery.withClampedTextScaling
// or per-screen via MediaQuery.textScalerOf(context).clamp(...).
// [MEDIUM confidence — WebSearch cross-verified against api.flutter.dev MediaQueryData.textScaler docs]
MaterialApp.router(
  builder: (context, child) => MediaQuery.withClampedTextScaling(
    minScaleFactor: 1.0,
    maxScaleFactor: 1.6,
    child: child!,
  ),
  ...
)
```

### Anti-Patterns to Avoid

- **Triggering the ED safety-net dialog on every keystroke:** `WeightScreen`'s target-weight `TextFormField` currently calls `saveGoal` from a raw `onChanged` (`weight_screen.dart:163-170`). Wiring the BMI check into `onChanged` verbatim will pop the modal mid-typing (e.g., typing "17" before "170" briefly reads as BMI<17.5). Trigger only `onEditingComplete`/`onFieldSubmitted`/focus-loss, matching the "only on a new/changed *final* value" intent in CONTEXT.md.
- **Re-declaring API usage that a dependency's own manifest already covers:** `shared_preferences_foundation` ships its own `PrivacyInfo.xcprivacy` declaring `NSPrivacyAccessedAPICategoryUserDefaults` reason `1C8F.1` — verified directly from its GitHub source this session. Don't assume the app's own manifest needs to redeclare UserDefaults; verify via Xcode's merged Privacy Report at archive time instead of guessing.
- **Building new GDPR "action" screens for PRIV-06:** CONTEXT.md is explicit — Legal Hub's "Your Rights" section is a redirect/explanation layer, not new export/delete logic. Do not duplicate Phase 5's Export Data / Danger Zone functionality.
- **Adding a `yaml` or `frontmatter` pub package** for a single scalar frontmatter key — inconsistent with this project's own established "hand-roll trivial parsing, don't add a dependency" precedent (Plan 01-06).

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|--------------|-----|
| Markdown-to-widget rendering (Terms/Privacy/Disclaimer/Impressum) | A custom markdown-subset parser | `flutter_markdown_plus` | Tables, nested lists, links, emphasis, and escaping are all correctness-sensitive; a hand-rolled parser is a maintenance sink for content a lawyer will eventually edit |
| First-launch / onboarding-complete detection | A custom native platform channel or file-based flag | `shared_preferences` | Solved problem, official package, works identically on both platforms |
| Carousel swipe/paging mechanics | Custom `GestureDetector` + manual page-snap animation | `PageView` + `PageController` (built-in) | Flutter's own widget already handles velocity-based snapping, RTL, and accessibility focus traversal correctly |
| ED safety-net threshold logic | Inline `if` checks duplicated in `ProfileScreen` and `WeightScreen` | One `EdSafetyNetChecker` service + one `EdSafetyNetDialog` widget | CONTEXT.md explicitly locks "two independent trigger points, one shared check/warning component" — duplicating the logic risks copy/threshold drift between the two screens |
| GDPR data-subject-rights actions (export/delete) | New "Exercise Your Rights" mutation screens | Existing Phase 5 Export Data / Danger Zone screens, linked from Legal Hub | CONTEXT.md: PRIV-06 is explanatory only this phase |
| Frontmatter YAML parsing | Full YAML parser via the `yaml` package | ~10-line hand-rolled scalar extractor (Pattern 3 above) | Only one key (`version:`) needs extracting; matches this project's own `check_privacy_deps.dart` precedent |

**Key insight:** Every "don't hand-roll" item in this phase already has either a zero-dependency Flutter SDK answer (`PageView`, `MediaQuery.textScaler`) or a well-established, officially-published pub.dev package — the temptation to over-engineer here (a custom markdown parser, a custom onboarding-state machine) would add risk without adding value for a 3-slide carousel and 4 static legal documents.

## Common Pitfalls

### Pitfall 1: GDPR consent must be legally valid, not just visually present (PITFALLS.md C5)

**What goes wrong:** Pre-checked boxes, a single bundled "I agree to everything" checkbox, or consent recorded without timestamp+version make the whole flow legally invalid (CJEU Planet49, EDPB Guidelines 05/2020).
**Why it happens:** Devs treat "checkbox exists" as sufficient without the freely-given/specific/informed/unambiguous/granular/revocable/demonstrable test.
**How to avoid:** This project's schema already enforces most of this (4 separate mandatory booleons, append-only `consent_records`, no update/delete methods on the DAO). The remaining risk is entirely in the UI layer: verify no checkbox defaults to `true`, and verify the write happens with the *actual* policy version shown to the user (not a hardcoded string) — see Pattern 3's frontmatter version wiring.
**Warning signs:** Any `bool _termsChecked = true;` default; any single "Accept all" checkbox; a hardcoded `policyVersion: '1.0'` string instead of reading the markdown frontmatter.

### Pitfall 2: `appVersion` for `consent_records` has no runtime source yet

**What goes wrong:** LEGAL-03 requires every consent write to carry the app version, but no package in this project reads it at runtime — `pubspec.yaml`'s `version: 0.1.0+1` is a build-time constant Dart code cannot see without `package_info_plus` (or equivalent). This was not flagged in CONTEXT.md's "what already exists" section and would otherwise surface as a build error mid-implementation.
**How to avoid:** Add `package_info_plus` (see Standard Stack) and read `PackageInfo.fromPlatform()` once at app start or lazily via a `@riverpod` provider, caching the result.
**Warning signs:** Any placeholder string like `appVersion: 'unknown'` or a hardcoded literal shipped to production.

### Pitfall 3: iOS Required-Reason API declarations — verify per-dependency, don't guess

**What goes wrong:** Assuming the app's own `PrivacyInfo.xcprivacy` must redeclare every API a dependency touches, or conversely assuming a dependency's own manifest covers everything.
**Facts verified this session (not assumed):**
- `shared_preferences_foundation` (the iOS/macOS implementation backing `shared_preferences`) **already ships its own `PrivacyInfo.xcprivacy`** declaring `NSPrivacyAccessedAPICategoryUserDefaults` with reason `1C8F.1` — confirmed by fetching the file directly from `github.com/flutter/packages` this session. The app does not need to redeclare this.
- `path_provider_foundation` (already a transitive dependency via `drift_flutter`/backup export) has **no `Resources/PrivacyInfo.xcprivacy` of its own** in its current source tree — it's implemented via a Dart `ffi`/`objective_c` bridge (`dartPluginClass`), not a compiled native pod with a resource bundle, so any file-timestamp API calls it triggers are attributed to the *main app binary* at Apple's static-analysis time, not to a separate pod manifest.
- This app statically links `sqlite3` (via `drift`/`sqlite3` FFI) — SQLite's own C code calls `fstat`/`stat`-family functions internally for file locking, which **is** one of Apple's tracked "File Timestamp APIs." Since this is FFI-linked into the main binary (not a separate pod), **the app's own `PrivacyInfo.xcprivacy` likely needs to declare `NSPrivacyAccessedAPICategoryFileTimestamp` with reason `C617.1`** ("access file metadata... within the app container") for its own SQLite database files.
**Confidence:** MEDIUM — reason codes verified against multiple independent sources this session (Apple developer forum threads, community blog posts cross-referencing Apple's official reason-code list), but the *exact final set* of declarations should be confirmed against Xcode's own "Privacy Report" (Xcode 15+, `Product > Archive`) at actual build time, since that tool performs the real static analysis Apple's review uses.
**How to avoid:** Draft the app's own manifest with `NSPrivacyTracking: false`, `NSPrivacyTrackingDomains: []`, `NSPrivacyCollectedDataTypes: []` (matches the "no data collected" PRIV-07 story), plus `NSPrivacyAccessedAPICategoryFileTimestamp` reason `C617.1`. Then re-verify via an actual `flutter build ios` + Xcode archive before real submission (outside this phase's scope, but flag as a pre-submission checklist item).

### Pitfall 4: `WeightScreen`'s target-weight field is `onChanged`, not a dialog — naive BMI-check wiring will misfire

**What goes wrong:** CONTEXT.md's additional-context describes `weight_screen.dart`'s "existing override dialog," but the actual code (verified this session, `weight_screen.dart:155-171`) has no dialog at all — it's a `TextFormField` that calls `saveGoal()` directly from `onChanged` on every keystroke. Wiring the BMI check into that raw `onChanged` will show the modal mid-typing.
**How to avoid:** Move the BMI-check trigger to `onEditingComplete`/`onFieldSubmitted`, or debounce, so the check only fires once the user has finished entering a value — consistent with CONTEXT.md's "only on a new/changed value" re-warn rule, which implicitly assumes a discrete "save event," not a per-character one.
**Warning signs:** A modal appearing after typing a single digit.

### Pitfall 5: `WeightScreen` has no existing import path to `UserProfile.heightCm`

**What goes wrong:** The BMI check needs the user's height, which lives in `UserProfile` (`profileProvider`), but `weight_screen.dart` currently imports nothing from the profile feature. A naive implementation might duplicate height storage in `WeightSettings` instead of reading the canonical field.
**How to avoid:** Add `ref.watch(profileProvider)` (or a narrower selector) inside `WeightScreen`/`_GoalFields`. Cross-feature notifier composition is an established, accepted pattern in this codebase already (`FavoriteNotifier.logFromRecent` composing with `mealEntryProvider`, Phase 04-07/04-10) — this is not a new architectural pattern, just a new specific edge crossing from `weight` → `profile`.
**Warning signs:** A second, disconnected height field appearing in Weight Tracking.

### Pitfall 6: Google Play's January 2026 "Medical Device" disclosure line (new since PITFALLS.md was researched)

**What goes wrong:** `PITFALLS.md` (researched 2026-07-16) does not mention Google Play's January 2026 health-app policy update, which now requires apps **without** EU medical-device certification to display a specific disclaimer line prominently: *"This app is not a medical device and does not diagnose, treat, or prevent any condition."*
**Why it matters here:** This app is exactly the "nutrition/CO₂ tracker, no diagnostic claims" case this line is meant for — it should NOT trigger Medical Device classification, but the disclaimer line itself is a new, concrete, dateable requirement to add to the Health Disclaimer text and the Play Store description/Data Safety draft doc.
**How to avoid:** Include this exact sentence (or a close paraphrase preserving "not a medical device," "does not diagnose, treat, or prevent") in the Health Disclaimer markdown and in the drafted Play Store listing copy.
**Confidence:** MEDIUM — sourced from a secondary blog summarizing Google's policy update, not fetched directly from `support.google.com`; recommend the planner re-verify the exact current wording against Play Console's Health Content policy page before the doc is finalized, since Google's own page is the authoritative source. `[ASSUMED — flag in Assumptions Log]`

### Pitfall 7: "ANAD" name collision — German ANAD e.V. vs. US-based ANAD (anad.org)

**What goes wrong:** CONTEXT.md specifies "BZgA / ANAD e.V." as the Germany-specific helpline resource. There are two unrelated organizations sharing this acronym: **ANAD e.V.** (München, Germany — `anad.de`, telephone counseling e.g. 089 2199730) and the **National Association of Anorexia Nervosa and Associated Disorders** (Illinois, USA — `anad.org`, helpline 630-577-1330). Citing the wrong one in the German-market Health Disclaimer/Settings entry would misdirect German users to a US-only line.
**How to avoid:** Link/cite `anad.de` (and its current phone/contact info) explicitly for the Germany-specific resource, and BZgA's own dedicated eating-disorder counseling line (`bzga-essstoerungen.de`, phone 0221 892031, per this session's search) as the other Germany-specific option. For the "international fallback" line CONTEXT.md also calls for, `findahelpline.com` (175+ countries, vetted, free) is a reasonable single link rather than picking one more country-specific number.
**Confidence:** MEDIUM — phone numbers/URLs verified via WebSearch against what appear to be the organizations' own domains, but not independently confirmed by a phone call; flag for a final human check before shipping, since a wrong crisis-line number is a real-world harm vector, not just a copy nit.

### Pitfall 8: Onboarding drop-off is still a risk even after CONTEXT.md's simplification (PITFALLS.md M5)

**What goes wrong:** Even with Mode Choice removed, the flow is still Splash → Welcome → Legal Consent → Profile → Carousel → Dashboard — 5 screens before first value. Industry data (per PITFALLS.md M5) suggests each additional pre-Dashboard screen costs meaningful D1 retention.
**How to avoid:** Nothing to change in scope (Legal Consent and the Carousel are both non-negotiable this phase per CONTEXT.md/REQUIREMENTS.md), but keep "Skip intro" genuinely one tap from any carousel slide straight to `/dashboard` (not "skip to the next slide"), and keep Profile Setup's fields visually optional-looking (no red asterisks, no "required" language) so users don't stall there.

## Runtime State Inventory

Not applicable — this is a greenfield feature-build phase (new screens/tables consumed, not a rename/refactor/migration of existing runtime state). Skipped per the trigger condition in the research protocol.

## Code Examples

### Legal document loader combining asset read + frontmatter parse

```dart
// domain/services/legal_document_loader.dart
class LegalDocumentLoader {
  Future<({String version, String body})> load(String assetFileName) async {
    final raw = await rootBundle.loadString('docs/legal/$assetFileName');
    return parseLegalDocument(raw); // Pattern 3 above
  }
}
```
`pubspec.yaml` needs `docs/legal/` added to the `assets:` list, mirroring the existing `assets/off_reference.sqlite.gz` declaration.

### Consent repository mirroring the project's established repository convention

```dart
// data/repositories/consent_repository.dart
class DriftConsentRepository implements IConsentRepository {
  DriftConsentRepository(this._dao);
  final ConsentRecordsDao _dao;
  static const _uuid = Uuid(); // same v7() convention as every other repo

  @override
  Future<void> recordConsent({
    required String policyVersion,
    required List<String> consentsGiven,
    required String appVersion,
  }) {
    return _dao.insertConsent(
      ConsentRecordsTableCompanion.insert(
        id: _uuid.v7(),
        appVersion: appVersion,
        policyVersion: policyVersion,
        consentsGiven: jsonEncode(consentsGiven),
      ),
    );
  }
}
```
```dart
// core/di/providers.dart (or a new legal-specific providers file)
@riverpod
IConsentRepository consentRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return DriftConsentRepository(db.consentRecordsDao);
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|-------------------|---------------|--------|
| `flutter_markdown` (Google-maintained) | `flutter_markdown_plus` (foresightmobile.com-maintained fork) | Google discontinued `flutter_markdown` (per flutter/flutter#162966); community fork is the actively-maintained successor | Any RESEARCH.md or training-data reference to "just use flutter_markdown" is stale — use the fork |
| `textScaleFactor` (deprecated double) | `MediaQueryData.textScaler` (`TextScaler` object, `.clamp(...)`) | Deprecated several Flutter versions ago, now the only supported API | Any code still reading `MediaQuery.of(context).textScaleFactor` should migrate to `textScalerOf(context)` |
| Google Play health apps: generic "Health & Fitness" scrutiny only | January 2026 Medical Device labeling system + mandatory non-medical-device disclaimer line for uncertified apps | January 2026 policy update (per secondary source, not yet independently confirmed against Google's own page) | New, specific disclaimer sentence needed in Health Disclaimer + Play listing copy — see Pitfall 6 |

**Deprecated/outdated:**
- `flutter_markdown` on pub.dev — discontinued, do not add to `pubspec.yaml`.
- `textScaleFactor` — deprecated Flutter API, avoid in new code.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|----------------|
| A1 | `flutter_markdown_plus`, `shared_preferences`, `package_info_plus` are safe to add (pub.dev registry existence + independent signals, not slopcheck-verified since pub.dev is unsupported) | Standard Stack, Package Legitimacy Audit | Low — all three are official/flutter-favorite packages with long track records; still requires the planner's `checkpoint:human-verify` gate per project convention |
| A2 | Google Play's January 2026 "Medical Device" disclaimer line requirement and its exact wording | Common Pitfalls #6 | Medium — sourced from a secondary blog, not Google's own policy page directly; if wrong/outdated, the Play Data Safety draft doc includes a line that isn't actually required (harmless) or misses updated exact wording (needs a final check before real submission) |
| A3 | Exact iOS Required-Reason API codes needed in the app's own `PrivacyInfo.xcprivacy` (`C617.1` for File Timestamp via statically-linked SQLite) | Common Pitfalls #3 | Medium — if wrong, Xcode's own Privacy Report at real archive time will surface the discrepancy before submission; not a silent failure, but adds a rework cycle |
| A4 | BZgA/ANAD e.V. contact numbers and URLs cited (0221 892031, 089 2199730, bzga-essstoerungen.de, anad.de) are current and correct | Common Pitfalls #7 | High-consequence-if-wrong (a stale crisis-line number is a real-world harm), though low-probability of being wrong (Trusted, current-looking sources) — must be human-verified before shipping regardless of confidence level, since this is exactly the kind of claim that should never ship on "probably right" |
| A5 | The Health Disclaimer / Terms / Privacy draft text Claude will produce satisfies GDPR/TMG requirements well enough to be store-submittable in draft form | (out of this doc's scope, per CONTEXT.md) | High — CONTEXT.md already tracks this explicitly as a pre-launch blocker requiring a real Fachanwalt IT-Recht review; not resolved by this research or this phase |

## Open Questions

1. **Where does the Privacy Policy live for Google Play Console's "Privacy policy URL" field?**
   - What we know: Play Console requires a publicly-hosted URL (not a PDF, not in-app-only text) that must match the in-app copy and any website copy verbatim (per the January 2026 policy update found this session).
   - What's unclear: This project currently has no public website/hosting target mentioned anywhere in `.planning/` for legal documents — `docs/legal/*.md` will be bundled in-app only.
   - Recommendation: Flag as a pre-submission blocker for whoever owns the actual store listing (same owner as the Impressum entity decision) — this phase can produce the markdown content, but the *hosted URL* requirement is outside a mobile-app-only codebase's reach. Track this explicitly, don't silently assume it's solved.

2. **Exact wording/placement of the Google Play "not a medical device" disclaimer**
   - What we know: A disclaimer sentence is newly required (Pitfall 6) for apps without EU medical-device certification.
   - What's unclear: Whether it must appear in the app's Play Store *description* specifically, the in-app Health Disclaimer, both, or wherever "prominently" is defined by Google.
   - Recommendation: Include the sentence in both the Health Disclaimer markdown and the drafted Play Store listing copy in this phase's Data Safety draft doc; re-verify exact placement rules against Google's own Health Content policy page before real submission.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter SDK | All Dart/Flutter code this phase | ✓ | 3.44.6 (matches `pubspec.yaml` pin exactly) | — |
| Dart SDK | All Dart/Flutter code this phase | ✓ | 3.12.2 (matches pin) | — |
| Xcode | Building/validating `PrivacyInfo.xcprivacy` via the real Privacy Report | ✓ | 26.2 (build 17C52) | — |
| Android SDK / toolchain | Verifying dark mode / Dynamic Type / TalkBack on Android | ✓ | SDK 36.1.0 | — |
| CocoaPods (`pod`) | iOS dependency resolution for manifest auditing | ✓ | present at `/opt/homebrew/lib/ruby/gems/4.0.0/bin/pod` | — |
| `adb` on PATH | Direct ADB device inspection | ✗ (not on PATH; Android toolchain itself reports fine via `flutter doctor`) | — | Use `flutter` CLI's own device/run commands, which don't require `adb` directly on PATH |

**Missing dependencies with no fallback:** none.
**Missing dependencies with fallback:** `adb` not directly on PATH — `flutter doctor` reports no issues and the Android toolchain is otherwise fully available, so this doesn't block any phase-6 work.

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | `flutter_test` (SDK) + `mocktail 1.0.5` — both already pinned in `pubspec.yaml` |
| Config file | none dedicated — standard `flutter test` discovers `test/**/*_test.dart` |
| Quick run command | `flutter test test/domain/services/ed_safety_net_checker_test.dart` (or any single new file) |
| Full suite command | `flutter test` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|---------------------|--------------|
| LEGAL-01/02 | Accept button stays disabled until 4 mandatory checkboxes ticked | widget | `flutter test test/features/legal/legal_consent_screen_test.dart` | ❌ Wave 0 |
| LEGAL-03 | `recordConsent` writes correct id/timestamp/appVersion/policyVersion/consentsGiven | unit (repository, mocktail on `ConsentRecordsDao`) | `flutter test test/data/repositories/consent_repository_test.dart` | ❌ Wave 0 |
| LEGAL-03 (DAO layer) | Append-only insert/retrieve round trip, no `dirty` column | unit (Drift, in-memory) | `flutter test test/data/local/consent_records_dao_test.dart` | ✅ already exists (Phase 1 Wave 0) |
| NFR-07 (calorie) | `EdSafetyNetChecker.calorieTargetIsUnsafe` returns true only below 1200 | unit | `flutter test test/domain/services/ed_safety_net_checker_test.dart` | ❌ Wave 0 |
| NFR-07 (BMI) | `EdSafetyNetChecker.bmiIsUnsafe` returns null when height missing, correct bool otherwise | unit | same file as above | ❌ Wave 0 |
| ONBD-01/05 | Onboarding gate redirect: first launch → Splash; post-onboarding → Dashboard | widget/integration | `flutter test test/features/onboarding/onboarding_gate_test.dart` | ❌ Wave 0 |
| ACC-02 | Text scaling clamp does not overflow key screens at max scale | widget (golden or overflow-assertion) | `flutter test test/features/onboarding/legal_consent_screen_test.dart` (parameterized `MediaQuery` override) | ❌ Wave 0 |
| ACC-03 | Key interactive elements expose `Semantics` labels | widget (`find.bySemanticsLabel`) | included in each new screen's widget test | ❌ Wave 0 |
| ACC-01/04/05 | Dark mode contrast, color-blind-safe indicators, tap target sizing | manual-only | N/A — visual/manual QA checklist item, not economically automatable this phase | manual, justified: requires real-device visual/contrast judgment beyond a golden-file diff's practical value here |

### Sampling Rate

- **Per task commit:** the specific new/changed test file(s) for that task.
- **Per wave merge:** `flutter test` (full suite).
- **Phase gate:** Full suite green before `/gsd-verify-work`, plus the manual accessibility checklist (dark mode/contrast/tap-target spot check, SAM test, screen-reader pass) signed off outside the automated suite.

### Wave 0 Gaps

- [ ] `test/domain/services/ed_safety_net_checker_test.dart` — covers NFR-07
- [ ] `test/data/repositories/consent_repository_test.dart` — covers LEGAL-03 (mocktail on `ConsentRecordsDao`, mirroring existing repo test conventions e.g. `test/data/repositories/`)
- [ ] `test/features/legal/legal_consent_screen_test.dart` — covers LEGAL-01/02, ACC-02/03 on this screen
- [ ] `test/features/legal/consent_history_screen_test.dart` — covers PRIV-06's consent-history read path
- [ ] `test/features/onboarding/onboarding_gate_test.dart` — covers ONBD-01/05's redirect gating
- [ ] `test/domain/services/legal_document_loader_test.dart` — covers the frontmatter parser (Pattern 3) round-trip and malformed-input handling
- [ ] No new test framework/dependency install needed — `flutter_test`/`mocktail` already present

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|----------------|---------|--------------------|
| V2 Authentication | No | No login exists in Local Mode this phase (Phase 7 concern) |
| V3 Session Management | No | No sessions this phase |
| V4 Access Control | No | Single-user on-device app, no multi-tenant access boundary |
| V5 Input Validation | Yes (narrow) | Consent checkbox state is a closed boolean set, not free text — no injection surface; the one free-text-adjacent input is the markdown *content* itself, which is developer-authored (not user-supplied), so standard markdown-widget escaping (handled internally by `flutter_markdown_plus`) is sufficient, not a custom sanitizer |
| V6 Cryptography | No new requirement | Consent records are plaintext in the existing unencrypted local SQLite DB, consistent with every other table in this project (no new crypto surface introduced) |

### Known Threat Patterns for this stack

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|------------------------|
| Consent record tampering/backdating (a user or malicious actor editing the local DB to fake an earlier consent timestamp) | Tampering | Out of scope to fully prevent on a local-only unencrypted SQLite file (same threat model as every other local table); mitigated in practice by the DAO having no update/delete methods, so the *application layer* never offers a tamper path — device-level tampering (root/jailbreak DB editing) is an accepted residual risk consistent with the rest of this local-first app |
| Markdown content injection via a compromised bundled asset (supply-chain risk if `docs/legal/*.md` were ever fetched remotely instead of bundled) | Tampering / Spoofing | Not applicable this phase — documents are bundled at build time, not fetched at runtime, so there's no remote-content injection surface to mitigate |
| Deep-link/redirect abuse of the onboarding gate (e.g., a crafted deep link attempting to skip Legal Consent) | Elevation of Privilege (bypassing mandatory consent) | The `redirect:` callback must be evaluated on every navigation attempt, not just at app start, so a deep link into `/dashboard` before onboarding completion is still redirected back to `/splash` — verify the go_router `redirect` function is registered at the top-level `GoRouter`, not per-route, so it can't be bypassed by a route that lacks its own guard |

## Sources

### Primary (HIGH confidence)
- `github.com/flutter/packages` (fetched directly this session) — confirmed `shared_preferences_foundation`'s bundled `PrivacyInfo.xcprivacy` content and `path_provider_foundation`'s FFI/objective_c-bridge implementation (no bundled manifest)
- `pub.dev/api/packages/*` (fetched directly this session) — confirmed exact current versions/publish dates/scores for `flutter_markdown_plus`, `shared_preferences`, `package_info_plus`
- Direct codebase reads this session — `consent_records_table.dart`, `consent_records_dao.dart`, `target_calculator.dart`, `profile_screen.dart`, `weight_screen.dart`, `settings_screen.dart`, `app_router.dart`, `main.dart`, `app.dart`, `app_theme.dart`, `color_tokens.dart`, `pubspec.yaml`, `.privacy-blocklist.yaml`, existing `consent_records_dao_test.dart`

### Secondary (MEDIUM confidence)
- `github.com/flutter/flutter` issue #162966 — `flutter_markdown` discontinuation (WebSearch, cross-referenced against the fork's own pub.dev listing)
- Apple developer forum threads + community blog posts (WebSearch) — Required Reason API reason codes (`1C8F.1`, `C617.1`, `3B52.1`, `8FFB.1`) for File Timestamp / UserDefaults categories
- WebSearch results on BZgA/ANAD e.V. German helpline contact details, and the US/German ANAD name collision
- `myappmonitor.com` blog post (WebFetch) — January 2026 Google Play health-app Medical Device labeling policy change

### Tertiary (LOW confidence)
- None used without at least one cross-check this session; the one deliberately-flagged LOW/MEDIUM item (Google Play Medical Device wording, Pitfall 6/Assumption A2) is explicitly logged rather than presented as settled fact

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH for `PageView`/built-in Flutter APIs; MEDIUM for the three new pub.dev packages (registry-verified but not slopcheck-verifiable, consistent with this project's own established `[ASSUMED]` handling of every prior pub.dev addition)
- Architecture: HIGH — directly grounded in the actual current codebase read this session, not assumed
- Pitfalls: MEDIUM-HIGH — GDPR/TMG substance carried over from PITFALLS.md (already flagged MEDIUM there, unresolved by a lawyer review); the two newly-found codebase-specific pitfalls (WeightScreen onChanged, missing package_info_plus) are HIGH confidence since they're verified directly against the current source

**Research date:** 2026-08-03
**Valid until:** ~30 days for the codebase-specific findings (stable); ~7-14 days for the Google Play January 2026 policy claim specifically, since that is the single fastest-moving, least-directly-verified claim in this document — recommend a quick re-check against Google's own Health Content policy page immediately before the Play Data Safety draft doc is finalized.
