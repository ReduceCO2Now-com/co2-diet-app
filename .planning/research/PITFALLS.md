# Domain Pitfalls

**Domain:** Flutter offline-first nutrition + CO₂ tracking mobile app (iOS + Android, EU/German market, self-hosted backend)
**Researched:** 2026-07-16
**Overall confidence:** MEDIUM (training-data-only — external verification tools were unavailable during this research; recommend spot-checking with Context7 / official docs during Phase 1 architecture and Phase 3 compliance work)

> **Reading this doc:** Every pitfall lists (1) what goes wrong, (2) why, (3) how to detect it early, (4) prevention strategy, and (5) which roadmap phase should address it. Phase numbers refer to conventional GSD phase ordering — P0 = MVP core, P1 = post-launch enhancements, P2 = future.

---

## Critical Pitfalls

_Mistakes that cause rewrites, App Store rejections, legal liability, or a total loss of user trust._

### C1. Offline-first sync built as an afterthought (last-write-wins conflict resolution)

**What goes wrong:** Team ships local-first (Hive) with sync tacked on later. First multi-device user logs breakfast on their phone at 08:00, then adds a snack from their tablet at 08:05 while offline. Server naively overwrites with "latest timestamp" — the snack (or the whole day) disappears. Users lose data silently, then leave 1-star reviews.

**Why it happens:** Sync appears deceptively simple ("just POST the local DB"). The real hard problems — clock drift between devices, tombstones for deletes, partial-sync interruption, schema versioning across devices on different app versions — surface only when real users have real data on multiple devices.

**Consequences:** Silent data loss (worst kind — users don't trust the app anymore even after a fix), corrupted daily totals, CO₂ numbers that don't reproduce, complete rewrite of the persistence + sync layer around v1.2.

**Prevention:**
- Design sync BEFORE building the local schema. Choose a strategy up front:
  - **CRDT-based** (e.g., logs of add/delete/edit events) — best for logs of independent entries like meals.
  - **Last-writer-wins per-field with vector clocks or hybrid logical clocks** — acceptable for profile / goals which are edit-heavy.
- Model every user-owned record with `id (UUID v7 generated on device)`, `updated_at (server-authoritative ms)`, `client_updated_at (device HLC)`, `deleted_at (tombstone)`, `origin_device_id`, `schema_version`.
- Never delete rows locally — soft-delete with tombstones that survive at least 90 days.
- Test sync with **clock-skew scenarios**: device A set to +2h future, device B offline for 3 days, then both sync.

**Detection (warning signs):**
- Any code path that does `DELETE FROM meals WHERE …` without writing a tombstone.
- Sync code that uses `DateTime.now()` on the client as the primary conflict resolver.
- No integration test that runs "device A offline → 5 edits → device B online → 5 edits → both sync".

**Phase:** **P0 Architecture / Phase 1** — cannot be retrofitted safely. Even if Account Mode ships in a later phase, the local schema shape (UUIDs, tombstones, HLCs) must be laid down in the MVP so early Local Mode users can migrate their data when they later create an account.

---

### C2. Hive box schema evolution with no migration story

**What goes wrong:** v1.0 ships with a `Meal` HiveObject that has fields `{id, calories, foods[]}`. v1.1 renames `foods` to `entries` and adds `co2eGrams`. Users who skip v1.0→v1.1 and jump straight to v1.2 get `HiveError: Cannot read null as int` on cold start. App won't open. 1-star reviews. Users lose all history.

**Why it happens:** Hive's `@HiveField(index)` model is forgiving on the write side (new fields default to null) but brutally unforgiving if you (a) reuse a field index, (b) remove a required field, (c) change a field's type, or (d) change a `TypeAdapter`'s registered typeId. Compounded by the fact that many devs test only "clean install → upgrade" but not "upgrade from vN-2 → vN".

**Consequences:** App crashes on launch for a subset of users, forced reinstall = total local data loss, App Store review can flag repeated crashes.

**Prevention:**
- **Never reuse a `@HiveField(index)`** — treat indexes as append-only.
- **Never remove a field** — mark deprecated but keep the annotation for at least two major versions.
- Adopt a **schema versioning table**: `Box<int>('meta').put('schemaVersion', 3)` and run explicit migrations on app start.
- Build a **replay-migration test matrix**: install every historical version's box on device, upgrade to current, assert no data loss. Automate this in CI.
- **Serious alternative to weigh in Phase 1:** Drift (SQLite) has first-class schema migrations, testable with `drift_dev`'s migration verifier. For a nutrition app that will grow schema over years, Drift's migration story is materially safer than Hive's — the tradeoff is more boilerplate up front. **Recommend at least prototyping both** before committing to Hive.

**Detection:**
- No file named `migrations.dart` or equivalent in the persistence layer.
- No test that upgrades from a saved box snapshot of a prior version.
- Any git commit that changes a `@HiveField` index or removes a field without a migration.

**Phase:** **P0 / Phase 1** for the versioning scaffold; migration tests added as part of every release checklist from **v1.0 onward**.

---

### C3. CO₂ numbers presented as precise facts when they are order-of-magnitude estimates

**What goes wrong:** Dashboard shows "You emitted 4.73 kg CO₂e today." A journalist, climate scientist, or eco-influencer downloads the app, notices that logging "1 apple" produces a number to two decimals, and publicly shreds the app's methodology on social media. Reddit thread hits 5000 upvotes on r/environment titled "This app is greenwashing." App Store rating drops from 4.6 to 3.1 in 72 hours.

**Why it happens:** LCA (Life Cycle Assessment) data for foods carries **uncertainty ranges of ±30–200%** depending on food type, sourcing, transport, farming method, and land-use assumptions. Data from Poore & Nemecek 2018, Agribalyse, and Open Food Facts' Eco-Score are aggregates with wide error bars. Displaying `4.73 kg` implies four significant figures of precision — the actual credible range is more like `3–7 kg`.

**Consequences:** Loss of scientific credibility (impossible to regain once lost), viral bad PR, potential legal exposure in the EU under **Directive (EU) 2024/825** (the Empowering Consumers for the Green Transition Directive) and the **Green Claims Directive** proposal — both actively hostile to unsubstantiated environmental claims, in force / entering force in 2026.

**Prevention:**
- **Round to one or two significant figures** in the primary display: "~5 kg CO₂e today" not "4.73 kg". Show precision on tap/expand only.
- Always render **uncertainty bands** in the Insights / Data Analysis screen (e.g., "5 kg, likely range 3–7 kg").
- Every food item must have a **`co2_confidence` field** (`high | medium | low | estimated_by_category`) and the UI must visibly downweight low-confidence items ("estimated from category average").
- **Publish the methodology as a versioned document** shipped with the app AND on the website. Include data sources, formula, assumptions, and known limitations. Link from every CO₂ number in the UI.
- Have the methodology **peer-reviewed by an external LCA specialist** before v1.0 launch. This is worth paying for; €2–5k of expert review buys immunity from the "your numbers are fake" attack.
- Never claim absolute values in marketing copy ("save X kg CO₂"). Use relative framing ("this alternative is ~40% lower footprint").

**Detection:**
- Any string in the codebase like `"${co2.toStringAsFixed(2)} kg CO₂"` — should be a helper `formatCO2ForDisplay(value, confidence)` that handles rounding + uncertainty.
- Marketing copy or App Store description containing precise numeric environmental claims without qualifiers.
- No `CO2_METHODOLOGY.md` in the repo before v1.0.

**Phase:** **P0 / Phase 1** for the confidence field in the schema and display formatter. Peer review in **P0 / pre-launch** (Phase 5-ish). Methodology doc is a **launch blocker**.

---

### C4. "Privacy-first" claim breaks because of a transitive dependency

**What goes wrong:** App is marketed as "no analytics, no tracking." A user runs it through **Exodus Privacy** or **AppCensus** and discovers that `firebase_crashlytics` was pulled in transitively via `some_ui_package`, or that Google Play Services beacons out on startup, or that a Flutter package includes a `google_mobile_ads` transitive dep. Screenshot goes viral. "Privacy-first app secretly tracks you." Refund requests, class-action-in-Germany-tier headline risk.

**Why it happens:** Flutter's pub.dev ecosystem is generous with dependencies. UI packages routinely pull Firebase or Sentry or GA transitively. Sentry alone (even self-hosted) can leak IP + device model. Even without any SDK, the **iOS App Store's IDFA prompt** implies tracking is possible — if you skip the ATT prompt entirely but a transitive dep tries to read IDFA, you fail Apple's review. Android's Play Services on startup phones home even for apps that don't use them.

**Consequences:** Public trust collapse (privacy-first apps live and die by trust), removal from privacy-focused directories (F-Droid, PrivacyGuides), potential GDPR complaint to the Bavarian/Berlin DPA.

**Prevention:**
- **Set up automated dependency auditing in CI from day one:**
  - `dart pub deps --json` piped through a script that fails the build on a hardcoded blocklist (firebase_*, sentry_flutter, google_mobile_ads, facebook_*, mixpanel, amplitude, segment, appsflyer, adjust, branch_io).
  - For every new dependency, require a PR checklist item: "This dep does not add any network-calling transitive dependency."
- **Run Exodus Privacy analysis on every release APK** in CI (they have an API). Fail the release if any tracker is detected.
- **Publish an SBOM** (Software Bill of Materials) with each release — CycloneDX or SPDX format. Users can audit it.
- **Ship an F-Droid build** without Google Play Services. This forces you to notice any GMS dependency because the build breaks. Sell F-Droid availability as a privacy credential.
- Explicitly state in Privacy Policy: "This app makes network requests to (1) Open Food Facts API, (2) our self-hosted sync server, (3) Keycloak for auth. It makes NO requests to any other service." — and mean it.
- **Do not integrate Sentry, Crashlytics, or any hosted crash reporter.** Use `flutter_logs` writing to a local file that the user can optionally share via the OS share sheet.

**Detection:**
- Run `dart pub deps` — grep for `firebase`, `google_`, `sentry`, `analytics`, `tracker`.
- Run app on a network sniffer (mitmproxy) on first launch and every core flow. Log every hostname contacted. Anything not on your allowlist is a bug.
- Check `AndroidManifest.xml` for `INTERNET` permission usage and any `<meta-data>` from unexpected packages.

**Phase:** **P0 / Phase 1** for CI dependency auditing scaffold. **Every phase** must run the audit — new features tend to sneak in new deps.

---

### C5. GDPR consent flow is nominally there but legally invalid

**What goes wrong:** Onboarding shows the 4 mandatory checkboxes as pre-checked, OR bundles them into a single "I agree to everything" checkbox, OR doesn't record consent with a timestamp + policy version, OR doesn't let the user withdraw consent as easily as they gave it. A user files a complaint with the **BfDI** (German federal data protection authority) or their **Landesdatenschutzbeauftragter**. Fine risk under GDPR Art. 83 is up to **€20M or 4% of global turnover** — for a free app, still a devastating administrative burden.

**Why it happens:** Devs treat "checkbox = consent" without understanding GDPR's consent requirements: **freely given, specific, informed, unambiguous, granular, revocable, and demonstrable** (Art. 4(11), Art. 7). Pre-checked boxes and bundled consent are explicitly invalid per **CJEU Planet49 (C-673/17, 2019)** and the **EDPB Guidelines 05/2020**.

**Consequences:** DPA investigation, mandatory audit, forced re-consent of entire user base (destroys UX), fine.

**Prevention:**
- **Never pre-check any consent box.** Users must actively tick each one.
- **Never bundle consents.** Terms, Privacy Policy, "not medical advice", "user responsibility" — each is a separate acceptance because they concern different legal bases.
- **Record consent to durable storage** on device (and sync to backend for Account Mode) with:
  - Timestamp (UTC, ISO 8601)
  - App version (e.g., "1.0.3+45")
  - Policy version (e.g., "privacy-v2.1")
  - Terms version, Health Disclaimer version
  - The exact checkbox states (which were ticked, which were skipped if optional)
  - A hash of the actual document text the user was shown
- **Withdrawal must be as easy as granting** (Art. 7(3)): a "Withdraw consent / Delete account" button reachable in ≤2 taps from Settings.
- The 16+ self-declaration checkbox: understand this is **weak protection**. Under GDPR Art. 8, the minimum age for consent to information society services in Germany is **16** (Germany did NOT lower to 13 or 14; check current status because member states have adjusted). A checkbox does not satisfy "reasonable efforts to verify" for children. If you serve a mixed audience, consider parental consent flow.
- **Do not process any personal data before consent is granted.** No pre-loading OFF API, no device fingerprinting, no crash log with IP. The Splash → Welcome → Legal Consent flow must be data-inert until the consent screen is passed.
- **Impressum is mandatory for German-market apps** under §5 TMG / §18 MStV. Must include name, address, contact, and (if applicable) commercial register info. Missing or incomplete Impressum is a common cause of **Abmahnung** (cease-and-desist) letters from German competitors or law firms.

**Detection:**
- No `consent_records` table/box in the schema.
- Consent screen with any pre-checked box.
- No mechanism to show users "when did I consent to what version of the policy?"
- Any network call before the consent screen is passed.

**Phase:** **P0 / Phase 1** for the consent recording schema. **P0 / Phase 3** (compliance/legal review) — do NOT ship v1.0 without a lawyer familiar with GDPR + TMG reviewing the flow. Budget €1–3k for a Fachanwalt IT-Recht review.

---

### C6. App Store rejection: health claims without disclaimer or missing "not medical advice"

**What goes wrong:** App submitted to Apple. Rejected under App Store Review Guideline **1.4.1 (Safety – Physical Harm)** or **5.1.1(ix)** (health data). Or Google Play rejects under the **Health apps** policy. Delay: 1–4 weeks per rejection cycle. Launch date slips.

**Why it happens:** Apple and Google are increasingly strict on:
- Any calorie/macro tracking that could enable eating disorders (ED). Apple has rejected apps that let users set unrealistic calorie targets (<1200 kcal/day for adults) without warnings.
- Any nutrition advice that could be construed as medical (BMR/TDEE calculations, dietary recommendations).
- Any weight tracking without an ED safety net.
- CO₂ / sustainability claims that could be construed as scientific advice — less well-trod but increasingly scrutinised in EU markets after the Green Claims Directive.

**Consequences:** Rejection cycle burns weeks. If rejected on medical grounds, may require adding **health disclaimer screens, safety net UX, and evidence of consultation with a nutritionist**.

**Prevention:**
- **Include a mandatory Health Disclaimer screen in onboarding** (already planned per PROJECT.md — good).
- **Set safety-net floors:**
  - Refuse to accept a daily calorie target below **1200 kcal for adults** without a warning modal referencing the user to consult a doctor.
  - Refuse to accept a target weight that implies **BMI <17.5** without an ED helpline screen.
  - Include a **"Concerned about eating?" link** in Settings with regional helpline (Germany: **BZgA / ANAD e.V.** hotline).
- **Never use the word "diagnose", "treat", "cure", or "medical" in UI or App Store copy.**
- **App Store description language:** Use "helps you track" not "helps you lose weight." Use "estimated CO₂" not "your CO₂ footprint" (implies precision).
- **App Store Connect metadata:**
  - Age rating: **12+ or 17+** (not 4+) because of the ED risk classification.
  - Category: **Health & Fitness** — expect stricter review.
  - Privacy nutrition label: **Data Not Collected** — but you must be able to prove it (see C4).
- **Google Play Data Safety form:** Every field must match reality. Google audits.
- **Rehearse the review** by having a colleague submit a test build 2 weeks before the real launch to burn any surprise rejections.

**Detection:**
- No health disclaimer in the onboarding flow spec.
- No safety-net check on calorie or weight target entry.
- App Store description drafts that use medical language.

**Phase:** **P0 / Phase 4** (pre-launch polish) for safety nets. **P0 / Phase 5** (submission) for App Store copy and Data Safety forms.

---

### C7. Backend not designed for GDPR data subject rights from day one

**What goes wrong:** User in Account Mode requests full data export (Art. 15) or deletion (Art. 17). Backend team hacks together a Postgres dump script that takes 3 days per request. Or worse: deletion leaves foreign-key orphans in `sync_events`, `audit_logs`, `keycloak_users`. User complains to DPA. Six months later, a GDPR audit reveals that "deleted" users' meal data still exists in analytics tables.

**Why it happens:** Data subject rights (**access, rectification, erasure, portability, objection, restriction**) are afterthoughts if not baked into the schema. Keycloak stores its own copy of user email — often forgotten in deletion flows.

**Consequences:** DPA complaint, forced re-architecture, fine risk.

**Prevention:**
- **Design data model with a `user_id` FK on every user-owned table** and a cascade or scripted deletion path documented in an `ADR: Data Erasure`.
- Build an **API endpoint from day one** for `GET /me/export` (returns JSON + CSV zip, machine-readable per Art. 20) and `DELETE /me/account` (hard-delete + Keycloak user delete + tombstone in an anonymized `deleted_accounts_audit` table).
- **Legal retention exceptions must be explicit**: e.g., "consent records retained 3 years post-deletion for legal defense per Art. 17(3)(e)."
- **Test deletion end-to-end** on staging: create user, log 100 meals across 2 devices, request deletion, confirm zero rows remain in every table (except audit).
- **Keycloak: delete the user in Keycloak too**, and confirm the SSO session is invalidated.
- **Sync server logs:** ensure IP logs are rotated ≤14 days and are excluded from long-term backups.

**Detection:**
- No `DELETE /me/account` endpoint in the API spec.
- No test scenario for "user deletes account and re-registers with same email" (must be a clean slate).
- Backup strategy that would restore a deleted user's data.

**Phase:** **P0 / Phase 1** (backend schema) — coordinate with Tomris. Cannot be added later without painful backfill.

---

## Moderate Pitfalls

_Cause pain, rework, or partial user loss. Not existential but should be planned around._

### M1. Open Food Facts API — barcode returns unexpected/wrong/missing product

**What goes wrong:** User scans a Rewe-branded milk. Barcode matches a Portuguese generic product because the OFF DB has a collision, or the barcode is missing entirely, or the product exists but has no nutrition data, or the nutrition data is user-contributed and wildly wrong. User adds "500ml milk" and gets "3200 kcal, 0.02 kg CO₂" — obviously broken.

**Why it happens:** OFF is crowdsourced. Coverage is excellent for France, Germany, UK, Belgium; sparse elsewhere. Nutrition fields are often per-100g, per-serving, or missing. Barcodes can be re-used across regions. CO₂ data (`ecoscore_data`) is available for only a subset (~30–50% of products, mostly EU).

**Prevention:**
- **Validate every returned product** before displaying: nutrition sanity check (calories vs. macros: `9*fat + 4*carbs + 4*protein` should approximate calories within ±20%). If sanity fails, mark as `data_quality: low` and show a warning.
- **Provide a manual correction flow**: "This doesn't look right — edit values" that saves as a personal override (already in scope per PROJECT.md, good).
- **Cache aggressively locally** to avoid burning OFF's rate limits and to satisfy the offline-first requirement.
- **Respect OFF's rate limits and User-Agent policy**: OFF requires a `User-Agent` string identifying your app (`CO2Diet/1.0.3 (contact@example.com)`). Failing to send this can get your IP blocked. Their [documented rate limits](https://openfoodfacts.github.io/openfoodfacts-server/api/) are on the order of 100 req/min for product endpoints, stricter for search — verify current limits during Phase 1.
- **For missing CO₂ data**, fall back to a **category-based estimate** (e.g., "generic yogurt: ~1.5 kg CO₂/kg") and clearly mark `co2_confidence: estimated_by_category`.
- **Ship a curated seed database** (~5000–10,000 most common German products) inside the APK so the app works without any API call for the top ~80% of scans. This addresses cold-start, offline, and rate-limit issues in one move.
- **Never trust user-contributed nutrition without a sanity check.** OFF quality field: `nutriments.quality` — if `bad`, flag it.

**Detection:**
- Any code path that displays OFF data without validation.
- No `User-Agent` header on OFF requests.
- No offline fallback path when OFF is unreachable.

**Phase:** **P0 / Phase 2** (food search feature build). Curated seed DB can be a Phase 1 side track.

---

### M2. Barcode scan UX pitfalls — camera permission denial, poor lighting, wrong format

**What goes wrong:** User denies camera permission on first ask (iOS shows one shot at this — deny = you must guide them to Settings). Or barcode is EAN-8 but scanner is configured for EAN-13 only. Or the scan works but the frame guide is too small and users struggle in dim lighting. Or on Android 14+ the camera permission grant is "one time only" and the app breaks the next day.

**Prevention:**
- **Never request camera permission on cold start.** Request it contextually the first time the user taps "Scan Barcode". Show a pre-permission explainer sheet ("We use the camera only to scan barcodes. Nothing is uploaded.").
- If denied, show a **"Grant in Settings" screen with a deep link** (`openAppSettings()` via `permission_handler`).
- **Support multiple barcode formats**: EAN-13, EAN-8, UPC-A, UPC-E, QR (some OFF products use QR).
- Use **`mobile_scanner` package** (well-maintained, uses MLKit on Android and AVFoundation on iOS) — not the older `flutter_barcode_scanner` which is abandoned.
- **Torch/flashlight toggle** in the scanner UI for low light.
- **Manual barcode entry fallback** — critical for damaged or unusual barcodes.
- **Test on real devices, including low-end Android** (mid-range Samsung, cheap Xiaomi) — barcode scanning is dramatically slower on old cameras.
- **iOS 17+ Privacy Manifest**: declare camera usage in `PrivacyInfo.xcprivacy` with reason code `NSPrivacyAccessedAPICategoryUserDefaults` etc.
- **Android 14 (API 34) partial photo access** does not apply to camera but do note: `READ_MEDIA_IMAGES` for gallery-based scanning has changed.

**Detection:**
- Camera permission request in `main()` or `initState()` of the first screen.
- No pre-permission explainer.
- No fallback to manual entry.
- No torch button in the scanner.

**Phase:** **P0 / Phase 2** (food logging feature).

---

### M3. Search latency and cold-start pain from bundling large food databases

**What goes wrong:** Team decides to bundle a 200MB SQLite of the entire OFF DB in the APK. App Store install size balloons past **200MB (Google Play warns), 500MB (App Store cellular download blocked)**. Cold start takes 8 seconds because Hive is decrypting a 50MB box. Search takes 2 seconds because it's a `LIKE '%query%'` full scan.

**Prevention:**
- **Ship a curated seed of ~10–20k products (top German/EU market)** — target <15MB additional APK size.
- **Download extended DB on first launch** with clear UX ("Downloading food database, one-time 45MB…"). Cache locally.
- **Use FTS5 (SQLite full-text search) via Drift** — dramatically faster than Hive for text search. Even if primary storage is Hive, consider a **separate SQLite database just for food catalog search**.
- **Async, non-blocking cold start**: main app renders instantly; database opens in background with a spinner only in the food-search UI.
- **Isolate expensive work in Flutter Isolates** — do not decrypt/scan on the main thread.
- **Measure with Flutter DevTools** — set a budget: cold start <2s on mid-range Android (e.g., Samsung A54), search response <500ms for 3-char prefix.
- **Split food catalog from user data** in storage — different lifecycles, different sync semantics, different backup implications (user data must be backed up; food catalog is re-downloadable).

**Detection:**
- APK size >100MB.
- Cold start >3s on a physical mid-range device.
- Search implementation uses `LIKE '%…%'` on Hive.

**Phase:** **P0 / Phase 1** (architecture split: catalog vs. user data) + **P0 / Phase 2** (search implementation).

---

### M4. Keycloak + Flutter OAuth2 — refresh token expiry, offline access, PKCE traps

**What goes wrong:** User signs in via Keycloak. Refresh token expires after 30 days of inactivity (Keycloak default). User opens app on day 31, gets logged out silently, and thinks they lost their data. Or: PKCE flow uses `AppAuth` on iOS but a browser tab handoff breaks the callback. Or: offline access is not requested, so token can't be refreshed after a week offline.

**Prevention:**
- **Use `appauth`** (`flutter_appauth`) as the OAuth2 client — handles PKCE, custom URL schemes, iOS ASWebAuthenticationSession, Android Chrome Custom Tabs. Do NOT roll your own.
- **Configure Keycloak for mobile:**
  - `Access Type: public` (not confidential — mobile can't keep a client secret).
  - `Standard Flow Enabled: ON` (authorization code + PKCE).
  - `Direct Access Grants: OFF` (password grant is deprecated and insecure for mobile).
  - **Request `offline_access` scope** so refresh tokens are long-lived (Keycloak offline tokens don't expire — controlled by `Offline Session Idle` and `Offline Session Max` in realm settings). Recommend setting **Offline Session Idle ≥ 60 days** for a monthly-active-user pattern.
- **Redirect URI**: use a custom scheme like `com.reduceco2now.co2diet:/oauth2callback` — register both in Keycloak client config AND in `iOS Info.plist` (`CFBundleURLTypes`) and `AndroidManifest.xml` (`intent-filter`).
- **Store tokens in secure storage**: iOS Keychain / Android Keystore via `flutter_secure_storage`. NEVER SharedPreferences or Hive (unencrypted).
- **Handle token refresh proactively**: refresh 5 min before expiry, not on 401.
- **Silent re-auth path** when refresh token is expired: prompt user to sign in again, but do NOT log them out of Local Mode data. Their local data is intact.
- **Test the "offline for 60 days" scenario** — this is the case that breaks in production.
- **Apple sign-in specific**: must be offered if any other social sign-in is offered (Apple Guideline 4.8) — this is likely already the plan, but verify.
- **Google sign-in on Android**: consider using the **`google_sign_in`** package's server-auth-code flow to get a code Keycloak can exchange, rather than direct Google OIDC — avoids duplicating provider configs.

**Detection:**
- Any code that logs the access token or refresh token.
- Tokens stored in `SharedPreferences` or plain Hive.
- No offline_access scope requested.
- No test for token refresh after long inactivity.

**Phase:** **P0 / Phase 2 or 3** when Account Mode is built. Coordinate with Tomris on realm config.

---

### M5. Onboarding drop-off — too many screens between install and first "aha" moment

**What goes wrong:** Splash → Welcome → Legal Consent (4 mandatory + 1 optional checkbox) → Mode Choice → Profile Setup (7 fields) → Carousel (3 slides) → Dashboard. Industry benchmark: **each additional onboarding screen reduces D1 retention by ~5–15%**. This flow has 6 pre-Dashboard screens plus consent. Drop-off before first meal log will likely be 60–80% of installs.

**Why it happens:** Product owners want to "front-load value clarity." Users want the app to work in 15 seconds. The gap is where installs die.

**Prevention:**
- **Legal consent is non-negotiable** — cannot be trimmed. But make it visually calm and copy-tight (one screen, scannable).
- **Move Profile Setup to "later"**: allow users to skip and use defaults (average adult targets). Prompt for profile completion on Day 2 or after 3 logs.
- **Compress Carousel**: 3 slides is already the upper limit. Consider making it dismissible with "Skip" that goes straight to Dashboard.
- **Show the Dashboard immediately with sample/demo data** and a "Log your first meal" primary CTA. This is a proven pattern (MyFitnessPal, Yazio).
- **Measure funnel** — but you can't use analytics per the privacy constraint. Alternative: **anonymous, opt-in, aggregated milestone counters** ("did user reach Dashboard? Y/N — one bit, no ID, no timestamp") — even this is questionable for a privacy-first app. **Realistic answer: use user testing (10–20 users watching them install and use the app) as the funnel measurement**. Budget 2 rounds pre-launch.
- **A/B test onboarding variants** is not available without analytics. Ship the leanest possible flow and iterate on qualitative feedback.

**Detection:**
- >5 mandatory screens between install and first Dashboard view.
- No skip option for Profile Setup.
- Carousel that auto-advances or has no skip button.

**Phase:** **P0 / Phase 4** (UX polish before launch).

---

### M6. iOS Privacy Manifest (`PrivacyInfo.xcprivacy`) and Google Play Data Safety missing or wrong

**What goes wrong:** Since **May 2024**, Apple requires a `PrivacyInfo.xcprivacy` file in every app AND in every third-party SDK using "required reason APIs" (UserDefaults, file timestamps, disk space, active keyboards, system boot time). Missing manifest → **App Store rejection**. Wrong manifest (claims no data collection but a dep collects data) → **App Store removal**.

Similarly, Google Play **Data Safety** form must accurately describe what data is collected and shared. Auditing exists and mismatches result in removal.

**Prevention:**
- **Generate `PrivacyInfo.xcprivacy` for CO₂ Diet app itself** — declare API usage reasons and (empty) data collection.
- **Audit every third-party Flutter package** for its own privacy manifest. Packages without one break iOS 17+ submission. Check `ios/Runner/PrivacyInfo.xcprivacy` and every pod's `.xcprivacy`.
- **Google Play Data Safety**: fill it as "no data collected, no data shared." This must be verifiable by Google's automated scanning — see C4.
- **Update on every release** if new packages are added.
- **Documented example**: [Apple's Privacy Manifest docs](https://developer.apple.com/documentation/bundleresources/privacy_manifest_files).

**Detection:**
- No `PrivacyInfo.xcprivacy` in the iOS project.
- Empty Data Safety form or "not answered" in Play Console.

**Phase:** **P0 / Phase 5** (submission).

---

### M7. Anti-eco backlash: "You're calling me a bad person for eating meat"

**What goes wrong:** User logs a steak. App shows "🔴 High CO₂ impact: consider chicken instead (60% lower)." User feels judged, uninstalls, posts a bad review: "This app is preachy vegan propaganda." Common failure mode for sustainability apps — the tone is a make-or-break UX decision.

**Prevention:**
- **Non-judgmental language** everywhere. "Higher footprint" not "bad choice." "Alternative that's lower footprint" not "you should eat X."
- **Never use emoji faces (🙁, 🎉, 😱) for eco results.** Use neutral bars, colors (with sufficient contrast for colorblind users).
- **Frame it as information, not prescription.** "For reference: chicken is ~60% lower CO₂ per gram of protein" not "Try chicken instead."
- **Never gate features on eco behavior.** No "gold star for going vegan" — that's virtue signaling and turns off the mainstream audience the app needs.
- **Have a diverse test panel** (meat-eaters, vegans, flexitarians, sceptics) review copy before launch.
- **Consider a "sensitivity" setting**: user chooses "show me alternatives" vs. "just show me numbers."

**Detection:**
- Any copy in the app that uses words like "should", "must", "avoid", "bad", "unhealthy" in the context of eco/CO₂.
- Suggestions that appear unsolicited (should appear only on tap into Insights).

**Phase:** **P0 / Phase 4** (copy review).

---

### M8. Sync happens in foreground and drains battery / consumes data

**What goes wrong:** App syncs on every screen change. User has 5000 logged meals. Every foreground sync uploads 20MB. Battery drains, mobile data bill spikes, Android battery optimizer kills the app.

**Prevention:**
- **Delta sync only** — upload only records with `client_updated_at > last_sync_at`.
- **Batch and debounce**: sync every 5 min max, or on app foreground after ≥15 min gap, or on explicit user action.
- **Respect connection type**: default "sync on Wi-Fi only" as an option in Settings.
- **WorkManager (Android) / BGProcessingTask (iOS)** for background sync — but keep it rare (once/day is enough for a nutrition app).
- **Compress payloads** (gzip) and use efficient serialization (JSON is fine at this scale; protobuf overkill).
- **Show sync status honestly** in Settings: "Last synced: 2h ago" — not a fake spinner.

**Detection:**
- Sync triggered in `initState` of any commonly-visited screen.
- No delta filter — full user data POSTed every sync.
- No Wi-Fi-only option.

**Phase:** **P0 / Phase 3** (Account Mode / sync build).

---

### M9. Weight tracking triggers ED (Eating Disorder) safety review — no weight-focused framing

**What goes wrong:** App tracks weight prominently. Journalists / mental health advocates / App Store reviewers flag it as ED-triggering. Apple has been increasingly strict on weight-focused apps since ~2022.

**Prevention:**
- **Do NOT make weight the primary metric on Dashboard.** Nutrition + CO₂ are primary; weight is a secondary tab.
- **Do NOT display "weight to lose" in aggressive ways** ("You need to lose 8kg!"). Use "target weight" neutrally.
- **Provide the ED safety net** described in C6.
- **Do not celebrate weight loss with confetti / big animations.** Neutral tone.
- **Never require weight input** — it must be genuinely optional throughout the app.

**Phase:** **P0 / Phase 2** when Weight Tracking is built. Coordinate with Design.

---

### M10. Time zone and date-boundary bugs in daily totals

**What goes wrong:** User in Berlin logs dinner at 23:45 CET. Flies to Tokyo (UTC+9). App shows the dinner as being on a different day than they remember. Or: user's daily total resets at UTC midnight instead of their local midnight. Or: DST transition causes 25-hour or 23-hour days.

**Prevention:**
- **Store timestamps as UTC ISO 8601** in the DB.
- **Compute "day" from the user's current local time zone** at query time. Do NOT store "day" as a truncated date — recompute per user's tz.
- **Store the user's tz at time of logging** (`iana_tz` field) — for historical accuracy if they travel.
- **Use `timezone` package** for tz handling; `intl` for formatting.
- **DST test**: log 5 meals on the day of a DST transition. Assert the daily total is correct.
- **Travel scenario test**: log meals in Berlin, change device tz to Tokyo, verify day boundaries.

**Phase:** **P0 / Phase 1** (data model) + **P0 / Phase 2** (dashboard aggregation).

---

## Minor Pitfalls

_Annoyances, small polish gaps, one-day fixes if caught early._

### m1. Not internationalizing units from day one

**What:** Metric-only in v1 is fine per scope, but hard-coding "g", "kg", "kcal", "L" in strings makes i18n a nightmare later.
**Prevention:** Use `intl` with `MeasureFormat` from day one. Even English-only, structure strings for i18n.
**Phase:** P0 / Phase 1.

### m2. Not versioning API responses

**What:** Backend endpoint returns raw JSON without a version wrapper. v2 changes shape, old app clients crash.
**Prevention:** Include `apiVersion` in every response; client tolerates unknown fields.
**Phase:** P0 / Phase 1 (backend API design).

### m3. Push notifications set up "just in case"

**What:** APNs / FCM added because "we'll want it later." FCM = Google phones home. Breaks privacy claim.
**Prevention:** Do not add push notifications in v1. Local notifications via `flutter_local_notifications` are sufficient for meal reminders and don't require FCM/APNs.
**Phase:** P0 / Phase 4.

### m4. Emoji in CO₂ display

**What:** Using 🌱 or 🌍 as decoration is fine, but using 🔴/🟢 as the primary signal fails colorblind accessibility.
**Prevention:** Always pair color/emoji with text label ("Low", "Medium", "High"). WCAG AA compliance.
**Phase:** P0 / Phase 4.

### m5. Not testing on iPhone SE / small screens

**What:** Design done at iPhone 15 dimensions. On SE (small screen), consent checkboxes overflow, food search results cut off.
**Prevention:** Test on iPhone SE (2020), Pixel 4a, Samsung A54 as the "small / mid" reference devices.
**Phase:** P0 / Phase 4.

### m6. Deep linking not planned — no path to sharing a food or import from web

**What:** No support for `https://co2diet.app/food/abc123` deep links means no shareable food entries, no "add from web" flow.
**Prevention:** Set up universal links (iOS) / app links (Android) from day one — even if not used in v1, the manifest is easier to add now than later.
**Phase:** P0 / Phase 1 (manifest) — usage in P1.

### m7. Not planning for accessibility screen reader

**What:** VoiceOver / TalkBack reads "Chart" instead of "Today: 1200 of 2000 calories consumed."
**Prevention:** Semantic labels on all data displays. Test with screen reader at least once per feature.
**Phase:** P0 / Phase 4.

### m8. Font loading blocks first frame

**What:** Plus Jakarta Sans + Inter are loaded from network on first launch → blank white screen for 800ms.
**Prevention:** Bundle fonts in the APK (`pubspec.yaml` fonts declaration). Do not use `google_fonts` at runtime for primary UI fonts.
**Phase:** P0 / Phase 1.

### m9. Building own crash reporting even without third-party SDK

**What:** Trying to build a "privacy-preserving crash reporter" that still phones home. Any transmitted crash log contains stack + device model = fingerprintable.
**Prevention:** Log crashes to a local file. Add a "Share diagnostics" button in Settings that lets the user manually attach via OS share sheet. User is always in control.
**Phase:** P0 / Phase 3.

### m10. Assuming Open Food Facts will always be available

**What:** OFF is a nonprofit. Their API had outages in the past. Building the app so it degrades gracefully is required.
**Prevention:** Every OFF call has a timeout (3s), a retry (once), and a graceful fallback ("Product not found — add manually?"). App must NEVER be blocked waiting for OFF.
**Phase:** P0 / Phase 2.

---

## Phase-Specific Warnings

| Phase / Topic | Likely Pitfall | Mitigation | Ref |
|---|---|---|---|
| **Phase 1: Architecture** | Choosing Hive without evaluating migration story | Prototype Drift alternative; document ADR | C2 |
| **Phase 1: Data model** | No UUID/tombstone/HLC fields on user data | Add them now — cannot retrofit | C1 |
| **Phase 1: Backend schema** | User FK cascades not designed for deletion | ADR on data erasure | C7 |
| **Phase 1: CI** | No dependency auditing / Exodus scan | Set up on first commit | C4 |
| **Phase 2: Food search** | LIKE-scan on Hive, slow search | Use FTS5 via Drift for catalog | M3 |
| **Phase 2: Barcode** | Camera permission on cold start | Contextual permission with explainer | M2 |
| **Phase 2: Weight tracking** | Prominent, weight-focused framing | De-emphasize; add ED safety net | M9 |
| **Phase 3: Account Mode / sync** | Last-write-wins conflicts | CRDT or event-log sync | C1 |
| **Phase 3: Keycloak OAuth** | Missing offline_access scope | Configure with Tomris up front | M4 |
| **Phase 3: Compliance review** | GDPR consent not legally valid | External Fachanwalt IT-Recht review | C5 |
| **Phase 4: Copy & UX** | Preachy eco language | Diverse test panel review | M7 |
| **Phase 4: Onboarding** | Too many pre-Dashboard screens | Compress; allow profile skip | M5 |
| **Phase 4: Accessibility** | No VoiceOver labels | Semantic audit per screen | m7 |
| **Phase 5: Submission** | Missing Privacy Manifest | Generate `PrivacyInfo.xcprivacy` | M6 |
| **Phase 5: App Store copy** | Medical / precise CO₂ claims | Copy review by legal | C3, C6 |
| **Every phase** | Silent CO₂ display precision creep | Formatter helper enforces rounding | C3 |
| **Every phase** | New dep adds a tracker | CI auditing fails the build | C4 |

---

## Sources & Confidence

**Confidence:** MEDIUM overall. This document draws on standard mobile-development, GDPR, and sustainability-tech knowledge from training data. External verification tools (Context7, WebSearch, WebFetch) were unavailable during this research session — recommend verifying the following high-stakes claims with primary sources during Phase 1:

**Claims to independently verify:**

- **HIGH-STAKES / verify with lawyer:** GDPR Art. 8 age of consent in Germany (currently 16, but member state laws have been amended); TMG/Impressum requirements; Health Disclaimer wording.
- **HIGH-STAKES / verify with docs:** Open Food Facts current rate limits, `User-Agent` policy, `ecoscore_data` field structure — [openfoodfacts.github.io/openfoodfacts-server/api/](https://openfoodfacts.github.io/openfoodfacts-server/api/).
- **HIGH-STAKES / verify with docs:** Apple Privacy Manifest requirements (`PrivacyInfo.xcprivacy`) — [developer.apple.com/documentation/bundleresources/privacy_manifest_files](https://developer.apple.com/documentation/bundleresources/privacy_manifest_files).
- **HIGH-STAKES / verify with docs:** Apple App Store Guideline 1.4.1, 5.1.1, 4.8 current text.
- **HIGH-STAKES / verify with docs:** Google Play Health apps policy, Data Safety form requirements.
- **HIGH-STAKES / verify with docs:** Keycloak `offline_access` scope + Offline Session settings — [keycloak.org/docs](https://www.keycloak.org/docs/).
- **MEDIUM:** Poore & Nemecek 2018 LCA uncertainty ranges (widely cited but check specifics); EU Green Claims Directive 2024/825 current status.
- **MEDIUM:** Flutter package recommendations (`mobile_scanner`, `flutter_appauth`, `flutter_secure_storage`, `flutter_local_notifications`) — check pub.dev for current maintenance status and any newer alternatives.

**Recommended:** Before Phase 4 (pre-launch), commission (1) a **Fachanwalt IT-Recht** review (€1–3k) for GDPR + TMG + Impressum, and (2) an **external LCA methodology review** (€2–5k) for CO₂ credibility. These are the two highest-leverage risk mitigations for this app.
