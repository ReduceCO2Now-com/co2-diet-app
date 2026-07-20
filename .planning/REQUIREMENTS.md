# Requirements: CO₂ Diet

**Defined:** 2026-07-16
**Core Value:** A user must be able to log a meal in under 10 seconds — everything else is secondary to that speed and privacy guarantee.

---

## v1 Requirements

Requirements for initial release. Each maps to a roadmap phase.

### Onboarding & Legal

- [ ] **ONBD-01**: App displays Splash screen (2–3 second load, centered logo + tagline, auto-advances to Welcome)
- [ ] **ONBD-02**: Welcome screen shows equal-weight "Get Started" and "Use Without Account" CTAs (no hierarchy bias between paths)
- [ ] **ONBD-03**: Account / Local Mode choice screen shows two equal-weight cards — no "Recommended" badge on either (design intent; audit against live-build bias before launch)
- [ ] **ONBD-04**: Profile Setup screen: age, gender, height, weight, activity level, dietary preference; all fields optional; auto-saves; no blocking validation; footer adapts to mode (local: "stored only on this device" / account: "synced securely")
- [ ] **ONBD-05**: Onboarding Carousel: 3–4 slides explaining how CO₂ scoring works; swipeable; "Skip intro" link jumps to Dashboard; "Go to Dashboard" sticky button on last slide

- [ ] **LEGAL-01**: Legal Consent screen presents 4 mandatory **separate** checkboxes (Terms of Service, Privacy Policy, not-medical-advice disclaimer, user-responsibility disclaimer); "Accept and Continue" button disabled until all 4 are checked; no pre-checked boxes
- [ ] **LEGAL-02**: 16+ age verification is a 5th checkbox on the Legal Consent screen: "I confirm I am 16 or older" (self-declaration; optional but logged when checked); mechanism: **resolved — self-declaration checkbox**
- [ ] **LEGAL-03**: Each consent event is recorded with: timestamp (UTC), app version, policy version — stored in `consent_records` table; never deletable except on full account deletion
- [ ] **LEGAL-04**: "View Terms", "View Privacy Policy", and "View Disclaimer" links are accessible from the Legal Consent screen before accepting

### Authentication & Accounts

- [ ] **AUTH-01**: User can create an account with email and password (email must be verified before sync is enabled)
- [ ] **AUTH-02**: User can log in with email and password and stay logged in across sessions
- [ ] **AUTH-03**: User can log out from any screen
- [ ] **AUTH-04**: User can reset password via a secure email link
- [ ] **AUTH-05**: Apple Sign-in via Keycloak Identity Provider (mandatory on iOS per App Store Guideline 4.8; Keycloak handles the Apple IdP flow — no native Apple Sign-in SDK on the Flutter client)
- [ ] **AUTH-06**: Google Sign-in via Keycloak Identity Provider
- [ ] **AUTH-07**: Local Mode: full app access with zero server account; all data stored on-device; app never contacts the backend in Local Mode without explicit user action
- [ ] **AUTH-08**: User can upgrade from Local Mode to Account Mode at any time without losing any local data; all local data is synced to the backend on upgrade
- [ ] **AUTH-09**: Account Mode users get cross-device sync via self-hosted backend (Spring Boot + PostgreSQL + Keycloak); sync is background/transparent
- [ ] **AUTH-10**: All auth is implemented via Keycloak OIDC + PKCE — no Firebase Authentication, no Supabase Auth

### Profile & Goals

- [x] **PROF-01**: User can configure profile: age, gender, height, weight, activity level (Low/Medium/High), dietary preference (No preference/Vegetarian/Vegan/Flexitarian/Low meat/Other)
- [x] **PROF-02**: User can select metric or imperial units; default is auto-detected from device locale; overrideable in settings
- [x] **PROF-03**: User can select a goal: Reduce CO₂ / Lose weight / Maintain weight / Gain muscle / Improve health / Balanced lifestyle / Learn & explore
- [x] **PROF-04**: System auto-calculates daily targets from profile: calories (Mifflin-St Jéor formula + activity factor), protein, carbs, fat, estimated daily CO₂ target
- [x] **PROF-05**: User can manually edit any auto-calculated target
- [ ] **PROF-06**: CO₂ profile factors (location/country, food purchasing source, shopping transport method, cooking method, food storage type, household size, estimated food waste level) live in CO₂ Calculation Settings — not Profile Setup; all fields optional; regional averages used as fallback

### Food Logging *(the heart of the app)*

- [x] **LOG-01**: User can search foods by name with <1 second response time against the local bundled food database (FTS5 index)
- [x] **LOG-02**: Food search falls back to the Open Food Facts API when online and local results are fewer than a threshold; API results are cached locally for future offline use
- [ ] **LOG-03**: User can scan a product barcode using the device camera; successful scan autofills food name, nutritional values, and CO₂e estimate; **P0 acceptance criterion: barcode scanning must be tested and verified on at least one real iOS device and one real Android device before launch** (simulator verification alone is not sufficient)
- [ ] **LOG-04**: When barcode scan finds no match (online or offline), user is offered the "Add as custom food" fallback — no dead-end UX
- [ ] **LOG-05**: User can add food to Breakfast, Lunch, Dinner, or Snack meal slots
- [ ] **LOG-06**: User can input portion in g, ml, cups, pieces, or portions; cup/slice/portion sizes are user-configurable via My Foods settings; metric default, imperial from locale
- [ ] **LOG-07**: Recent section shows individually logged food items (not combo/meal entries); one-tap reuse with previously used quantity pre-filled
- [ ] **LOG-08**: User can mark foods as Favorites; Favorites are one-tap re-loggable
- [ ] **LOG-09**: User can edit, delete, and duplicate logged meal entries
- [ ] **LOG-10**: User can create custom foods in My Foods: food identification (name, brand, category), reference amount, nutrition values (calories, protein, carbs, sugar, fat, fiber, salt), CO₂ values (manual or category-estimated), quick serving sizes
- [ ] **LOG-11**: User can create a personal version/override of an existing database food entry; the original database entry is never mutated, overwritten, or deleted — override and original are stored as an independent pair, fully revertible
- [ ] **LOG-12**: All core food logging works fully offline — zero network dependency for the core logging flow
- [ ] **LOG-13**: End-to-end meal logging (from "Add Breakfast" tap to food saved and visible on Dashboard) completes in under 10 seconds on a mid-range device; verified in user testing before launch

### Nutrition Tracking

- [ ] **NUTR-01**: System tracks per-meal and daily totals: calories, protein, carbohydrates, fat, sugar, fiber, sodium
- [ ] **NUTR-02**: Dashboard shows calories consumed vs. target with remaining calories prominently displayed
- [ ] **NUTR-03**: Dashboard shows protein consumed vs. target
- [ ] **NUTR-04**: Macro split (protein/carbs/fat) is viewable from the Dashboard or Data Analysis screen

### CO₂ Tracking

- [ ] **CO2-01**: Each food item has an associated CO₂e estimate (g CO₂e per kg); displayed with a confidence band (High / Medium / Low), never as a single false-precision number
- [ ] **CO2-02**: System calculates CO₂e per meal, daily total, and weekly total entirely on-device — deterministic, offline, no network dependency
- [ ] **CO2-03**: CO₂ Calculation Settings screen: user can optionally configure location (country + region), food purchasing source (supermarket / local farm / mix), shopping transport (car / public / walk/bike), cooking method (electric / gas / induction), food storage (fridge size / freezer), household size, food waste level; regional averages used as fallback for all unconfigured fields
- [x] **CO2-04**: CO₂ values are stored per row with a `co2_methodology_version` field; when methodology is updated, the app surfaces a non-intrusive "CO₂ estimates updated with methodology v2" announcement
- [ ] **CO2-05**: Estimate Transparency screen: for each food, user can see the CO₂e value, confidence level, contributing factors, data source, and a link to the full methodology documentation
- [ ] **CO2-06**: Improvement Opportunities: the app suggests non-judgmental sustainable alternatives with a quantified CO₂ impact delta (e.g., "Replacing today's beef meal with chicken would save approximately 1.2 kg CO₂"); suggestions are optional and never shown unsolicited on every screen

### Dashboard

- [ ] **DASH-01**: Dashboard is the default entry screen after onboarding; shows today's CO₂ total, calories consumed, and protein consumed — each with target comparison
- [ ] **DASH-02**: Dashboard shows quick-log buttons for Breakfast, Lunch, Dinner, and Snack; "+ Quick Add Food" secondary shortcut
- [ ] **DASH-03**: Dashboard shows today's meal list with swipe-to-edit and duplicate actions
- [ ] **DASH-04**: Dashboard shows a 7-day trend chart (lightweight, embedded)
- [ ] **DASH-05**: Dashboard shows a contextual quick insight line (e.g., "Lunch contributed most CO₂ today")
- [ ] **DASH-06**: Dashboard shows mode indicator (Local Mode: "Stored on this device" / Account Mode: "Synced across devices")
- [ ] **DASH-07**: Dashboard empty state: "No meals yet → Start logging"
- [ ] **DASH-08**: Tapping any Dashboard metric (CO₂, Calories, Protein, Weekly Trend) opens the Data Analysis screen for that metric

### Insights

- [ ] **INS-01**: Data Analysis screen accessible by tapping any Dashboard metric; shows: today's breakdown by meal (stacked bar), largest contributors (ranked list), goal comparison (progress bar + dynamic message), 7-day and 30-day switchable rolling trend (30-day rolling trend is the v1 time-range maximum — no separate calendar-month aggregate view is required for v1), Improvement Opportunities, detailed food analysis (expandable, per-serving + per-100g), Estimate Transparency, Insights Timeline
- [ ] **INS-02**: Data Analysis screen shows CO₂ estimate with methodology explanation and confidence band (honest uncertainty, not false precision)
- [ ] **INS-03**: Insights Timeline: chronological feed of observed patterns (e.g., "High-CO₂ evenings noticed", "Low protein on weekdays")
- [ ] **INS-04**: All Insights views work fully offline using locally stored data

### Weight Tracking

- [ ] **WT-01**: User can log weight (value, unit kg/lb, date, optional note); entries stored locally
- [ ] **WT-02**: User can view weight history with an interactive trend chart (7d / 30d / 90d / 1yr / all-time filter)
- [ ] **WT-03**: User can set an optional weight goal (target weight + target date); progress shown on trend chart
- [ ] **WT-04**: User can configure weigh-in reminders (frequency, day)
- [ ] **WT-05**: Weight Tracking is accessible from Profile / Settings (primary location); whether it is also linked or natively rendered under Insights tab is an **open design decision — to be resolved in Phase 3**

### Privacy & Data

- [ ] **PRIV-01**: User can export all personal data (CSV, Excel, JSON) by selectable category; delivered as a single zip archive with a manifest.json
- [ ] **PRIV-02**: User can create a manual backup (save to device, save to cloud/Files, or share)
- [ ] **PRIV-03**: User can configure automatic backups with configurable frequency and destination
- [ ] **PRIV-04**: User can restore from backup with a preview of what will be restored and an explicit confirmation step before any data is overwritten
- [ ] **PRIV-05**: User can permanently delete their account and all associated data; deletion completes within the legally required timeframe; Keycloak user record is deleted in the same operation; required by App Store (since June 2022) and GDPR Art. 17
- [ ] **PRIV-06**: User can exercise full GDPR rights from the Legal & Privacy hub: access data, rectify data, data portability, and consent withdrawal
- [x] **PRIV-07**: Application contains zero third-party analytics SDKs, advertising SDKs, or behavioral tracking SDKs; compliance verified by an automated dependency audit run in CI (hardcoded blocklist) and an Exodus Privacy scan on every release build
- [ ] **PRIV-08**: In Local Mode, no data is ever transmitted to any server without explicit user action
- [ ] **PRIV-09**: User can delete all local data (Danger Zone; requires typed confirmation before executing)

### Notifications

- [ ] **NOTIF-01**: User can enable, disable, and configure meal reminders (time + frequency)
- [ ] **NOTIF-02**: User can enable, disable, and configure weigh-in reminders (frequency + day)
- [ ] **NOTIF-03**: All notifications are delivered via local scheduling (flutter_local_notifications); zero FCM / APNs server push — no server-side notification infrastructure required

### Legal & Transparency

- [ ] **LEG-01**: Legal Hub is accessible within 2 taps from any screen; contains full-document screens for: Terms of Service, Privacy Policy, Health Disclaimer, Impressum
- [ ] **LEG-02**: Health Disclaimer is visible from the Legal Consent screen (before first use) and accessible from Legal Hub at any time; states the app does not provide medical advice and is not a substitute for professional dietary or medical guidance
- [ ] **LEG-03**: Impressum contains: legal entity / operator, address, contact email, responsible person, required legal disclosures under German TMG §5 / MStV §18; accessible within 2 taps
- [ ] **LEG-04**: Open source license disclosure: all third-party library licenses and copyright notices accessible in-app
- [ ] **LEG-05**: CO₂ methodology and data sources are publicly documented; linked from the Estimate Transparency screen and Legal Hub

### Non-Functional Requirements (UX Tone & Behavior)

- [ ] **NFR-01**: Tone is non-judgmental throughout — no "you failed" language, no guilt framing; copy follows positive recovery framing (canonical example: "Yesterday was higher than planned. That's normal. Let's continue today.")
- [ ] **NFR-02**: CO₂ information is presented as informative and useful, never political or preachy; improvements are framed as opportunities, not obligations; no letter-grades or alarm-red indicators on food choices
- [ ] **NFR-03**: App tone is calm, supportive, trustworthy, and motivating — validated via Self-Assessment Manikin (SAM) test in user testing before launch; app must not feel stressful, judgmental, or pressuring
- [ ] **NFR-04**: No manipulative gamification: no streak-shame, no loss-aversion notifications, no aggressive account-creation nudging in Local Mode
- [ ] **NFR-05**: CO₂ data is presented with honest uncertainty — confidence bands and ranges, never false-precision numbers (e.g., display "~4.7 kg CO₂" or "4–5 kg CO₂", not "4.732 kg CO₂")
- [x] **NFR-06**: Food database reliability — two testable acceptance criteria before launch: (a) **Search hit rate:** given a benchmark list of ~200 commonly logged foods in the EU/German market, >90% return a usable result from the local DB without requiring an API fallback; (b) **CO₂ coverage:** >90% of products in the bundled seed DB have at least a category-average CO₂e estimate (not necessarily a product-specific LCA value)
- [ ] **NFR-07**: Eating disorder safety nets: the app refuses to accept daily calorie targets below 1,200 kcal or goals implying BMI below 17.5 without surfacing a warning and a relevant professional resource / helpline link

### Accessibility

- [ ] **ACC-01**: App supports system dark mode on both iOS and Android
- [ ] **ACC-02**: App respects system Dynamic Type / font size settings; all text scales without layout breakage
- [ ] **ACC-03**: All interactive elements have VoiceOver (iOS) and TalkBack (Android) semantic labels; key flows verified with screen reader before launch
- [ ] **ACC-04**: All charts and indicators are color-blind friendly (not relying on red/green alone)
- [ ] **ACC-05**: All tap targets are minimum 44×44 pt throughout

---

## v2 Requirements

Deferred to post-v1. Not in current roadmap.

### Auth
- **AUTH-V2-01**: Passkey support (Flutter ecosystem not mature as of Jan 2026 — reassess for v1.1)

### Food & Logging
- **LOG-V2-01**: Recipe builder and saved recipes
- **LOG-V2-02**: Meal planning (weekly plan, grocery list generation)
- **LOG-V2-03**: Barcode scanning of nutrition label field via camera + AI parsing
- **LOG-V2-04**: Receipt scanning (AI extraction of purchased items)
- **LOG-V2-05**: Voice input for food logging

### Insights & CO₂
- **CO2-V2-01**: AI-based CO₂ estimation for unknown products (no database match)
- **INS-V2-01**: AI coach / conversational assistant for meal ideas, healthy swaps, diet planning
- **INS-V2-02**: 30-day and annual insights and summaries

### Integrations
- **INT-V2-01**: Apple Health integration
- **INT-V2-02**: Google Fit integration
- **INT-V2-03**: Wearable / smart scale integration

### Social & Community
- **SOC-V2-01**: Community food database contributions (user submissions with moderation)
- **SOC-V2-02**: Community recipes and shared meal ideas
- **SOC-V2-03**: Challenges (opt-in, non-shame-based)

### Platform
- **PLAT-V2-01**: Web app
- **PLAT-V2-02**: Multiple language support (English-only for v1)
- **PLAT-V2-03**: Family accounts

### Nutrition
- **NUTR-V2-01**: Advanced micronutrient tracking (vitamins, minerals)
- **NUTR-V2-02**: Hydration tracking

---

## Out of Scope

| Feature | Reason |
|---------|--------|
| Admin Profile / database editing in the mobile app | Web / backoffice tool only — NOT a screen in the Flutter app. FR-010's admin role is explicitly excluded from mobile scope. Building a hidden admin screen in mobile is explicitly prohibited. |
| Firebase Authentication / Supabase Auth / any hosted auth | Self-hosted Keycloak only per core principles |
| Firebase Firestore / Realtime Database | Self-hosted PostgreSQL only |
| Any third-party ad SDK, analytics SDK, or behavioral tracking | Non-negotiable privacy principle |
| GitHub sign-in | Wrong audience for v1 consumer app; conflicts with privacy positioning |
| FCM / APNs server push notifications | All notifications are local-only |
| Augmented Reality food scanning | Long-term vision, out of v1 scope |
| Social network / social sharing features | v2+ |
| AI meal photo recognition | v2+ (accuracy problems at current state of art) |
| Carbon footprint forecasting beyond food | Long-term vision |
| Restaurant menus / CO₂-optimized dining recommendations | Long-term vision |
| Calendar-month aggregate view (monthly CO₂/nutrition summary) | Resolved: 30-day rolling trend on Data Analysis screen is sufficient for v1; true monthly view deferred to v2 |

---

## Traceability

Every v1 requirement is mapped to exactly one roadmap phase. See `.planning/ROADMAP.md` for phase details.

| Requirement | Phase | Status |
|-------------|-------|--------|
| ONBD-01 | Phase 6 | Pending |
| ONBD-02 | Phase 6 | Pending |
| ONBD-03 | Phase 6 | Pending |
| ONBD-04 | Phase 6 | Pending |
| ONBD-05 | Phase 6 | Pending |
| LEGAL-01 | Phase 6 | Pending |
| LEGAL-02 | Phase 6 | Pending |
| LEGAL-03 | Phase 6 | Pending |
| LEGAL-04 | Phase 1 | Pending |
| AUTH-01 | Phase 7 | Pending |
| AUTH-02 | Phase 7 | Pending |
| AUTH-03 | Phase 7 | Pending |
| AUTH-04 | Phase 7 | Pending |
| AUTH-05 | Phase 7 | Pending |
| AUTH-06 | Phase 7 | Pending |
| AUTH-07 | Phase 5 | Pending |
| AUTH-08 | Phase 7 | Pending |
| AUTH-09 | Phase 7 | Pending |
| AUTH-10 | Phase 7 | Pending |
| PROF-01 | Phase 1 | Complete |
| PROF-02 | Phase 1 | Complete |
| PROF-03 | Phase 1 | Complete |
| PROF-04 | Phase 1 | Complete |
| PROF-05 | Phase 1 | Complete |
| PROF-06 | Phase 5 | Pending |
| LOG-01 | Phase 2 | Complete |
| LOG-02 | Phase 2 | Complete |
| LOG-03 | Phase 3 | Pending |
| LOG-04 | Phase 3 | Pending |
| LOG-05 | Phase 4 | Pending |
| LOG-06 | Phase 4 | Pending |
| LOG-07 | Phase 4 | Pending |
| LOG-08 | Phase 4 | Pending |
| LOG-09 | Phase 4 | Pending |
| LOG-10 | Phase 4 | Pending |
| LOG-11 | Phase 4 | Pending |
| LOG-12 | Phase 4 | Pending |
| LOG-13 | Phase 4 | Pending |
| NUTR-01 | Phase 5 | Pending |
| NUTR-02 | Phase 5 | Pending |
| NUTR-03 | Phase 5 | Pending |
| NUTR-04 | Phase 5 | Pending |
| CO2-01 | Phase 3 | Pending |
| CO2-02 | Phase 5 | Pending |
| CO2-03 | Phase 5 | Pending |
| CO2-04 | Phase 1 | Complete |
| CO2-05 | Phase 5 | Pending |
| CO2-06 | Phase 5 | Pending |
| DASH-01 | Phase 5 | Pending |
| DASH-02 | Phase 5 | Pending |
| DASH-03 | Phase 5 | Pending |
| DASH-04 | Phase 5 | Pending |
| DASH-05 | Phase 5 | Pending |
| DASH-06 | Phase 5 | Pending |
| DASH-07 | Phase 5 | Pending |
| DASH-08 | Phase 5 | Pending |
| INS-01 | Phase 5 | Pending |
| INS-02 | Phase 5 | Pending |
| INS-03 | Phase 5 | Pending |
| INS-04 | Phase 5 | Pending |
| WT-01 | Phase 5 | Pending |
| WT-02 | Phase 5 | Pending |
| WT-03 | Phase 5 | Pending |
| WT-04 | Phase 5 | Pending |
| WT-05 | Phase 5 | Pending |
| PRIV-01 | Phase 5 | Pending |
| PRIV-02 | Phase 5 | Pending |
| PRIV-03 | Phase 5 | Pending |
| PRIV-04 | Phase 5 | Pending |
| PRIV-05 | Phase 7 | Pending |
| PRIV-06 | Phase 6 | Pending |
| PRIV-07 | Phase 1 | Complete |
| PRIV-08 | Phase 5 | Pending |
| PRIV-09 | Phase 5 | Pending |
| NOTIF-01 | Phase 5 | Pending |
| NOTIF-02 | Phase 5 | Pending |
| NOTIF-03 | Phase 5 | Pending |
| LEG-01 | Phase 6 | Pending |
| LEG-02 | Phase 6 | Pending |
| LEG-03 | Phase 6 | Pending |
| LEG-04 | Phase 1 | Pending |
| LEG-05 | Phase 3 | Pending |
| NFR-01 | Phase 6 | Pending |
| NFR-02 | Phase 6 | Pending |
| NFR-03 | Phase 6 | Pending |
| NFR-04 | Phase 6 | Pending |
| NFR-05 | Phase 5 | Pending |
| NFR-06 | Phase 2 | Complete |
| NFR-07 | Phase 6 | Pending |
| ACC-01 | Phase 6 | Pending |
| ACC-02 | Phase 6 | Pending |
| ACC-03 | Phase 6 | Pending |
| ACC-04 | Phase 6 | Pending |
| ACC-05 | Phase 6 | Pending |

**Coverage:**
- v1 requirements: 94 total
- Mapped to phases: 94
- Unmapped: 0 ✓
- Duplicated (any requirement in >1 phase): 0 ✓

**Note:** The previous traceability header claimed 75 total v1 requirements — corrected during roadmap creation. Actual v1 REQ-ID count is 94 (ONBD 5 + LEGAL 4 + AUTH 10 + PROF 6 + LOG 13 + NUTR 4 + CO2 6 + DASH 8 + INS 4 + WT 5 + PRIV 9 + NOTIF 3 + LEG 5 + NFR 7 + ACC 5). No CO2-07 requirement is defined in this document; the earlier reference to "CO2-07" in a draft traceability row was stale and has been removed.

---

*Requirements defined: 2026-07-16*
*Traceability rewritten: 2026-07-16 during ROADMAP.md creation*
