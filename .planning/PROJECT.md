# CO₂ Diet

## What This Is

CO₂ Diet is a privacy-first, offline-first Flutter mobile app (iOS + Android) that helps users track both their nutrition (calories, protein, macros) and the estimated CO₂ footprint of their food choices — together in one place. It is free forever, contains no ads, collects no behavioral data, and stores all personal data locally on-device by default. An optional account enables cross-device sync via a self-hosted backend (Spring Boot + PostgreSQL + Keycloak). The app is open source.

## Core Value

A user must be able to log a meal in under 10 seconds — everything else is secondary to that speed and privacy guarantee.

## Requirements

### Validated

(None yet — ship to validate)

### Active

**Onboarding & Legal**
- [ ] Splash screen → Welcome → Legal Consent → Mode Choice → Profile Setup → Carousel → Dashboard flow
- [ ] Legal Consent: 4 mandatory checkboxes (Terms, Privacy, not-medical-advice, user-responsibility) + optional 16+ self-declaration
- [ ] Account/Local Mode choice screen with visually equal-weight cards (design intent — see open decisions)

**Authentication & Accounts**
- [ ] Local Mode: full app access with zero server account, all data on-device
- [ ] Account Mode: email/password signup with Apple and Google social sign-in (GitHub TBD)
- [ ] Passkey support (mechanism: passkey-first vs. password-first is an open decision)
- [ ] Login/logout and password reset
- [ ] Cross-device sync for account users via self-hosted backend

**User Profile & Goals**
- [ ] Profile setup: age, gender, height, weight, activity level, dietary preference, metric/imperial
- [ ] Goal selection: reduce CO₂, lose weight, gain muscle, improve health, balanced lifestyle
- [ ] Auto-calculated daily targets: calories, protein, fat, carbs, CO₂ estimate
- [ ] CO₂ profile factors in CO₂ Calculation Settings (not profile setup): location, food sourcing, transport, cooking method, storage, household size, waste level

**Food Logging (the heart of the app)**
- [ ] Food search: name search against local DB + Open Food Facts API (4.5M products), <1s response
- [ ] Barcode scanning (P0 — must-have for launch): camera scan → product lookup → autofill nutrition
- [ ] Meal logging: add to Breakfast/Lunch/Dinner/Snack; portion input (g/ml/cups/pieces/portions)
- [ ] Recent foods: individual food items (not combo entries, per live build)
- [ ] Favorites: one-click reuse
- [ ] Custom food creation (My Foods): personal food entries + personal overrides of existing items (never overwrites originals)
- [ ] Offline-first: all core logging works with zero network

**Nutrition & CO₂ Tracking**
- [ ] Track per meal and daily: calories, protein, carbs, fat, sugar, fiber, sodium, CO₂e
- [ ] Daily dashboard: consumed vs. target, macro distribution, CO₂ footprint, 7-day trend
- [ ] Meal CO₂ calculation: per-meal + daily + weekly footprint from food CO₂ database
- [ ] CO₂ database: each food item has estimated CO₂e/kg, regional adjustment, source transparency

**Insights**
- [ ] Data Analysis screen: opens contextually from any Dashboard metric tap
- [ ] Today's breakdown by meal, largest contributors, goal comparison, 7/30-day trends
- [ ] Improvement Opportunities: sustainable alternative suggestions with quantified CO₂ delta (non-judgmental wording)
- [ ] Estimate Transparency: methodology explanation, links to CO₂ Calculation Settings

**Weight Tracking**
- [ ] Log weight (daily/weekly entries, kg/lb), history, interactive trend chart (7d/30d/90d/1yr/all)
- [ ] Optional weight goal (target weight + date)

**Privacy & Data**
- [ ] Data export: CSV/Excel/JSON, selectable categories
- [ ] Backup & Restore: device/cloud/share options, preview before restore
- [ ] Automatic backups: configurable frequency and destination
- [ ] Permanent account/data deletion (within legal timeframe)
- [ ] GDPR: right to access, delete, rectify, portability, consent withdrawal
- [ ] No analytics, no ad SDKs, no behavioral profiling

**Notifications & Reminders**
- [ ] Configurable meal reminders, weight-in reminders (optional, minimal)

**Legal & Transparency**
- [ ] Legal hub: Terms, Privacy Policy, Health Disclaimer, Impressum — each full-document screen, reachable within 2 taps
- [ ] Open source license disclosure
- [ ] CO₂ methodology and data sources publicly documented

**Design System (Eco-Minimalist Wellness)**
- [ ] Colors: #005222 primary green, #ffffff background, #1a1c1e text
- [ ] Typography: Plus Jakarta Sans (UI), Inter (Label Caps only)
- [ ] Shape: 8px/16px/24px rounded; ambient depth (glow layers, tonal stacking, micro-shadows)
- [ ] Logging <10s and 3-tap recent-food reuse verified before launch

### Out of Scope (v1)

- AI meal photo recognition — planned P2
- AI coach / conversational assistant — planned P2
- Social features, community recipes, challenges — planned P2
- Recipes, meal planning, grocery list — planned P1
- Wearable/Apple Health/Google Fit integration — planned P1
- Web app — post-mobile
- Multiple languages (English-only for v1)
- Advanced micronutrients, vitamins, minerals — optional post-v1
- Restaurant menus, carbon footprint forecasting — planned P2
- Admin profile / backoffice — out of Flutter mobile scope, separate project
- Firebase / Supabase — explicitly rejected; self-hosted stack only

## Context

- **Flutter dev:** Ali (sole Flutter developer building the app now; architecture doc references Ian/Sid — outdated)
- **Backend:** Tomris (Spring Boot 3 / Java 21 / PostgreSQL / Keycloak) — separate workstream
- **Design:** Lydia, Ilke, Neetha, Dilosi — 16 screens specced and exported from Stitch; DESIGN.md contains full token set
- **Live build exists:** 15 of 16 screens have Stitch exports (code.html + screen.png); some have confirmed behavior that supersedes written spec (e.g. Recent = individual items, not combo)
- **Package name:** `com.reduceco2now.co2diet`
- **Local storage:** Hive (to be finalized during architecture phase)
- **Target audience:** Primary persona: female, mother, 30s (UX team flagged as too narrow — expansion to 3 personas is an open discussion)
- **Data source:** Open Food Facts (primary API), USDA FoodData Central (secondary); custom CO₂ enrichment layer

## Constraints

- **Privacy:** No Firebase, no analytics SDKs, no behavioral tracking — non-negotiable
- **Performance:** Meal logging must complete in <10 seconds; food search <1 second
- **Offline-first:** All core flows (Dashboard, Log, Insights) must work without network
- **Legal (GDPR):** Full data portability, deletion, consent tracking with timestamp + app version + policy version
- **Open source:** MIT or Apache 2.0 — commercial reuse allowed
- **Age:** 16+ minimum (mechanism TBD — see open decisions)
- **Cost:** Free forever — no revenue model dependent on user data

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Flutter over React Native | Single codebase, UI consistency, offline performance, strong ecosystem | — Pending validation |
| Spring Boot + PostgreSQL + Keycloak (not Firebase) | Self-hostable, open source, relational fit for CO₂/catalog data, flat cost | — Pending validation |
| Offline-first architecture | Speed + privacy — core value requires no network dependency for daily use | — Pending validation |
| Hive for local storage | Flutter-native, offline-capable, no SQL overhead for local reads | — To be confirmed in architecture phase |
| Barcode scanning as P0 | Resolved during GSD init — too central to omit from launch | ✓ Confirmed |
| Recent = individual items only | Confirmed via live build; supersedes earlier combo-entry spec draft | ✓ Confirmed |
| CO₂ profile factors in CO₂ Settings (not Profile) | Keeps onboarding Profile Setup lightweight; CO₂ factors optional/advanced | ✓ Confirmed |
| Visual weighting: equal cards (Account vs. Local Mode) | Privacy-first trust positioning — must not favor account creation | Open — live build shows bias, design intent says equal |
| GitHub as social sign-in | Unusual among non-developer target audience; conflicts with privacy positioning | Open |
| Passkey-first vs. password-first | Passkey is more private but has ecosystem maturity gaps | Open |
| 16+ age gate mechanism | Self-declaration checkbox vs. DOB vs. parental consent — each implies different screens | Open |
| Weight Tracking placement | Settings-only vs. also accessible from Insights | Open |

---
*Last updated: 2026-07-16 after initialization*
