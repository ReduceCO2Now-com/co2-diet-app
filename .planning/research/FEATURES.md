# Feature Landscape

**Domain:** Privacy-first, offline-first nutrition + CO₂ footprint tracking (Flutter mobile)
**Researched:** 2026-07-16
**Research mode:** Ecosystem (competitor analysis)
**Overall confidence:** MEDIUM
**Sources note:** WebSearch/WebFetch/Context7 access was denied in this research session; findings are synthesized from prior training knowledge of the named competitor apps (MyFitnessPal, Yazio, Cronometer, Lifesum, Klimato, Evocco, My Emissions, Ecolabel/Foodprint) and Open Food Facts. Confidence is marked per-item. Roadmap consumers should validate the flagged LOW/MEDIUM items with a fresh pass against App Store listings and current changelogs before locking scope.

---

## Executive Framing

Nutrition trackers are a mature, crowded category dominated by MyFitnessPal (freemium, ~200M downloads), Yazio (freemium, EU-strong), Cronometer (freemium, micronutrient-first, science-audience), and Lifesum (freemium, lifestyle/coaching angle). All four converge on the same core loop: **onboarding quiz → daily target → log meals against target → weekly trend**. Differentiation lives in secondary loops (coaching, micronutrients, recipes, integrations).

The CO₂-diet category is early and fragmented. Klimato (B2B/restaurant-facing), Evocco (photo-of-receipt UK app, sunset for individual users at various points), My Emissions (label + calculator), and features inside Oda / Lidl Plus in some EU markets are the current signals. **No dominant consumer CO₂ food tracker has emerged** — this is the opening CO₂ Diet is targeting.

The single biggest failure mode across all nutrition apps is **drop-off after week 2**, driven by logging friction, portion-guessing fatigue, and dark-pattern paywalls. The single biggest failure mode across CO₂ apps is **numbers users don't trust or understand** (opaque methodology, no regional adjustment, unit confusion between kg CO₂e per meal vs per kg of food).

For CO₂ Diet, the strategic implication is clear: **win on logging speed + methodology transparency + genuine no-tracking privacy**, and don't try to out-feature MyFitnessPal on breadth. The <10s log target and offline-first stance are the moat.

---

## Table Stakes

Features users expect. Missing = product feels incomplete or gets uninstalled in the first session.

| Feature | Why Expected | Complexity | Notes |
|---|---|---|---|
| Onboarding quiz → auto-calculated calorie/macro target | Every major app does this; users arrive expecting "tell me my number" | Low | Mifflin-St Jeor or Harris-Benedict + activity factor is the standard. CO₂ Diet already specs this. |
| Meal buckets (Breakfast/Lunch/Dinner/Snacks) | Universal mental model since MyFitnessPal 2005 | Low | Custom meal names are a Cronometer/Lifesum extra. |
| Food search with typeahead | Users expect Google-fast results | Medium | Sub-1s is table stakes; sub-300ms wins. |
| Barcode scanning | Every top-5 app has it; scanning packaged food is the fastest log path | Medium | CO₂ Diet already P0. Camera permission UX matters — see anti-features. |
| Portion units (g, ml, oz, cups, pieces, "1 serving") | Users think in cups and pieces, not grams | Medium | Multi-unit conversion table per food is where quality apps differ from bad ones. |
| Recently-eaten shortcut | Repeat-meal reuse is the #1 speed lever | Low | CO₂ Diet specs "Recent = individual items" — confirmed correct. Combos come later. |
| Favorites / one-tap re-log | Same repeat-meal insight | Low | |
| Custom food creation | Users have their own recipes and regional foods missing from any DB | Medium | CO₂ Diet's "personal override never overwrites original" is the right model. |
| Daily dashboard: consumed vs target for calories + macros | This IS the product for most users | Medium | Ring / bar / progress-arc are all acceptable. Cronometer uses bars, MFP uses a summary card, Lifesum uses a plate metaphor. |
| Water tracking | Universal expectation; low effort to include | Low | Often just a +/- widget on the dashboard. Consider for v1.1 if not in v1. |
| Weight logging + trend chart | Every fitness tracker has it | Low | CO₂ Diet already specs. |
| Meal reminders | User-requested; must be opt-in and easy to silence | Low | CO₂ Diet specs. |
| Offline access to your own log history | Users assume their diary just works | Medium | Most competitors fail here (MFP requires network for most actions) — CO₂ Diet turns this into a differentiator. |
| Data export (CSV/JSON) | GDPR-mandated in EU; requested by power users everywhere | Low | CO₂ Diet already specs. |
| Account deletion within-app (not email-support-only) | GDPR + Apple App Store rule since 2022 | Low | This is a REJECTION reason in App Store review if missing. |
| Password reset + login/logout | Basic auth hygiene | Low | Only applies to Account Mode. |
| Free tier that is actually usable | Every serious competitor has one; a paywall in first session gets 1-star reviews | Low (business decision) | CO₂ Diet's "free forever" is stronger than any competitor here. |
| Clear privacy policy accessible in-app | App Store requirement + user expectation | Low | CO₂ Diet specs "Legal hub, 2 taps." |
| Search returns branded/packaged foods with nutrition | If a user scans a Coke and it says "not found," they churn | High (data) | Open Food Facts + USDA covers this. See Open Food Facts caveats below. |
| Portion memory ("last time you ate this it was 150g") | Yazio and Lifesum both do this; big speed win | Medium | Strongly recommend for v1. |

**Confidence:** HIGH on the list (based on well-established competitor patterns). MEDIUM on "sub-1s search" being table stakes vs differentiator — MFP and Yazio are often slower than 1s and users tolerate it, so CO₂ Diet's <1s spec is actually already a differentiator.

---

## Differentiators

Features that set CO₂ Diet apart. Not universally expected, but where the product can win.

| Feature | Value Proposition | Complexity | Notes |
|---|---|---|---|
| Per-meal + daily CO₂e footprint alongside calories | No mainstream nutrition tracker does this natively. My Emissions and Klimato do CO₂ but not calorie tracking. The combined view is the wedge. | High (data layer) | Requires curated CO₂/kg dataset + product-to-CO₂ mapping. Poseidon Principles / Agribalyse / Poore & Nemecek 2018 are the standard reference datasets. |
| Transparent CO₂ methodology (source per food, regional adjustment, cooking/transport modifiers) | Every CO₂ app users complain about is opaque; trust is the wedge, not the number itself | High | CO₂ Diet already specs "Estimate Transparency" screen — this is the single most important differentiator. Show ranges, not false-precision decimals. |
| Genuinely no analytics, no ads, no tracking | Competitors ALL do behavioral tracking (MFP owned by Under Armour then Francisco Partners — data monetization is core; Yazio uses Firebase + AppsFlyer; Lifesum sends events to multiple SDKs). "No third-party SDKs" is a real, uncommon, defensible position. | Low (a discipline, not a build) | Verifiable via exodus-privacy.eu.org public reports — CO₂ Diet should aim to be listed with 0 trackers. |
| Local Mode (fully functional zero-account) | Competitors gate features behind account. Free-tier without account is rare and privacy-genuine. | Medium | Design bias flagged in PROJECT.md ("visually equal cards") is the right call — the anti-pattern is nudging toward account creation. |
| Self-hosted sync backend (Spring Boot + PostgreSQL + Keycloak) instead of Firebase/Supabase | Users who care about privacy DO notice Firebase in mobsf/exodus scans | Medium (backend workstream) | Marketing this ("your data lives on infrastructure we operate, not Google's") converts a certain segment. |
| Non-judgmental "Improvement Opportunities" (sustainable swap suggestions with quantified delta) | Every diet app that shames users churns them. Positive-framing swaps ("swap beef → chicken, save 12kg CO₂e/week") is under-served. | Medium | Tone matters: "consider" not "you should." Lifesum's tone gets close; MFP's shaming ("You've eaten 800 more calories than planned") is the anti-pattern. |
| Offline-first for ALL core flows | MFP, Yazio, Lifesum all degrade badly offline. Cronometer is partial. True offline-first is genuinely rare. | High (architecture) | Hive + local-first CO₂ DB + cached OFF product images = the moat. |
| Portion input in the units the user actually thinks in (household units per food) | Yazio does this well; MFP and Cronometer are grams-heavy | Medium | CO₂ Diet already specs g/ml/cups/pieces/portions — implementation quality is the differentiator. |
| CO₂ contextualization ("your meal = X km driving in an average car") | Numbers alone (2.4 kg CO₂e) mean nothing; comparisons make them tangible | Low | Standard equivalences: km driving, hours of a lightbulb, liters of jet fuel. Also common: "trees needed to offset for a year." Use sparingly — over-use feels gimmicky. |
| Weekly CO₂ streak / momentum (not a shaming streak) | Yazio's streaks work; MFP's guilt-streaks don't. Non-punitive framing is under-served. | Low | "You reduced your average by 8% this week" > "You broke your 5-day streak." |
| Open-source app (auditable privacy claims) | Rare in this category. F-Droid + GitHub visibility appeals to privacy-conscious users and creates trust proof. | Low (licensing decision) | MIT/Apache 2.0 already in PROJECT.md. |
| Passkey support (if shipped) | Modern, private, distinguishes from competitors still on email+password only | Medium | Ecosystem maturity note in PROJECT.md is correct — iOS 16+ / Android 14+ is fine but fallback required. |
| CO₂ profile customization (location, sourcing, transport, cooking, storage, waste) | No competitor does this depth. Klimato does it for restaurants B2B, not consumer. | Medium | Correctly placed in "CO₂ Settings" not "Profile Setup" per PROJECT.md — this is right. Advanced users only. |
| Data Analysis screen accessible via contextual tap from any dashboard metric | Most apps bury insights in a separate tab; contextual drill-down is a UX win | Medium | CO₂ Diet already specs. |
| Export in multiple formats (CSV/Excel/JSON) with category selection | Most competitors export one format, everything-or-nothing | Low | Already specs. Solid trust signal. |

**Confidence:** HIGH on the "no third-party SDK" claim being uncommon (verifiable via public tracker-scan reports). MEDIUM on "no competitor combines nutrition + CO₂ well" — a fresh App Store scan should confirm the current state before public messaging locks in.

---

## Anti-Features

Features to explicitly NOT build, or patterns to avoid. These erode trust, drive churn, or contradict the product's positioning.

| Anti-Feature | Why Avoid | What to Do Instead |
|---|---|---|
| "No ads" claim while embedding third-party SDKs | Users can and do check with Exodus Privacy, ClassyShark, PCAP inspection. A single Firebase Analytics call detected = credibility gone. | Zero third-party SDKs. Period. No Sentry, no Crashlytics, no Firebase, no AppsFlyer, no Amplitude, no Mixpanel. Use local-only crash logs that the user opts into sending manually. |
| Streak shame ("You broke your 12-day streak!") | MyFitnessPal-era pattern that causes anxiety and disordered-eating feedback in users; documented in academic literature and App Store reviews | Positive framing: "You logged 5 days this week." No punishment for gaps. |
| Calorie shaming / red-yellow-green judgment on meals | Same reason — nutritional shaming is a known driver of disordered eating; multiple lawsuits/press against MFP | Neutral numbers. Let users interpret. |
| Aggressive paywall in first session | MFP and Lifesum both do "trial expires in 24h, subscribe now" in onboarding. #1 App Store 1-star complaint. | Free forever, per PROJECT.md. Correct call. |
| Dark pattern account-creation nudging | Live-build design bias flagged in PROJECT.md — Account card visually heavier than Local card | Enforce the "visually equal cards" design intent. Screenshot compare before shipping. |
| Auto-subscribe / trial-to-paid without clear disclosure | Apple/Google are cracking down but many apps still do it. Yazio was sued in Germany in 2023 over this. | Not applicable — free forever. But if a paid tier is ever added: full disclosure, one-tap cancel. |
| Weight or CO₂ goals that can be set unrealistically low | Weight goals below BMI 18.5 = eating disorder risk. CO₂ goals of "zero" = impossible, discouraging. | Soft warning at unhealthy weights (link to resources). CO₂ targets clamped to realistic reduction (e.g., 2.5 kg CO₂e/day floor). |
| "AI meal photo recognition" over-promised accuracy | Every AI-photo-log feature ships at ~60% accuracy and gets savaged in reviews. Correctly out of scope in PROJECT.md | Ship without it in v1. If added later, position as "assist" not "authoritative." |
| Social feed / community | Adds moderation burden, PII exposure, contradicts privacy positioning | Correctly out of scope. If ever added, opt-in with pseudonyms. |
| Behavioral push notifications ("You haven't logged in 2 days!") | Growth-hacking pattern that erodes trust; requires tracking to trigger | Meal reminders only, user-configured schedule, no engagement re-hooks. |
| Sync required for logging | MFP does this — offline logs eventually sync but many flows require network | Full offline-first, per PROJECT.md. Correct. |
| CO₂ numbers presented with false precision ("2.437 kg CO₂e") | LCA data is inherently ±30% at best; false precision damages trust when users notice | Present as ranges ("~2.4 kg" or "2.0–2.8 kg CO₂e") with methodology link. |
| "Verified" / "Green" / "Sustainable" food badges without clear criteria | Every green-badge system in food apps has been accused of greenwashing (Yuka is a partial exception because it publishes methodology) | Show numbers + methodology. No badges. If badges are ever added, publish the exact threshold criteria. |
| Hidden or buried account deletion | Apple App Store REJECTS apps for this since 2022; also GDPR violation in EU | Deletion in Settings, one screen deep, per PROJECT.md. Correct. |
| Silent data upload on WiFi | Some competitors do this "for backup." Users perceive as spyware. | Explicit sync trigger for Account Mode; nothing for Local Mode. |
| Requiring email verification before first meal log | Kills activation. Yazio and Lifesum both do this. | Local Mode requires nothing. Account Mode: allow first log, verify email later. |
| Mandatory age or DOB before first log | Kills activation for privacy-conscious users | Self-declaration checkbox during Legal Consent is the lightest-touch option consistent with 16+ requirement. Per PROJECT.md, this is one of the three options being evaluated — pick this one. |
| Onboarding quiz that asks 20+ questions before showing the app | Cronometer's onboarding is notably long; users abandon | Ship the app first (Dashboard visible), profile completion progressive. CO₂ Diet's current flow is close to right — audit for total screens (splash + welcome + legal + mode + profile + carousel = 6 screens, that's the upper acceptable limit). |
| GitHub sign-in for a non-developer audience | Flagged in PROJECT.md open decisions — correct concern | Drop GitHub for v1. Apple + Google + email is the standard non-developer set. Add back post-launch only if users ask. |

**Confidence:** HIGH — these are well-documented patterns from App Store reviews, GDPR case law (Yazio 2023), and app-privacy public reports (Exodus, Mobsf).

---

## Feature Dependencies

```
Legal Consent → Mode Choice → (Local | Account) → Profile Setup → Dashboard
                                    ↓
                              Account: Auth → Backend Sync

Food DB (local + OFF + USDA) → Food Search → Meal Log → Dashboard Totals
                                    ↓                        ↓
                              Barcode Scan            Data Analysis
                                    ↓
                              Recent / Favorites (requires log history)

CO₂ Database → CO₂ Enrichment (product-to-CO₂ mapping) → Meal CO₂
       ↓                                                       ↓
CO₂ Profile Settings (location, sourcing, etc.) → CO₂ Adjustment → Daily/Weekly CO₂
                                                                          ↓
                                                            Improvement Opportunities

Weight Log → Weight History → Trend Chart
              ↓
        (optional) Weight Goal

All Data → Export (CSV/JSON) + Backup/Restore + Account Deletion
```

Critical dependency: **CO₂ enrichment layer** (product-to-CO₂ mapping table joined to OFF's barcode DB) is the single hardest build and blocks the CO₂ features. Recommend prototyping this in Phase 1 to de-risk.

---

## MVP Recommendation

**Ship v1 with:**

1. **Onboarding + Legal Consent + Mode Choice + Profile Setup** — table stakes; PROJECT.md flow is correct
2. **Local Mode fully functional** — differentiator; more valuable than Account Mode for launch trust
3. **Food logging: search + barcode + recent + favorites + custom** — the heart of the app, must land <10s
4. **Daily dashboard: calories + macros + CO₂** — the differentiator view; can't ship without the CO₂ integration
5. **CO₂ methodology transparency screen** — the trust wedge; do NOT ship CO₂ numbers without it
6. **Weight tracking** — low complexity, high user expectation
7. **Data export + account deletion** — legal + trust requirement
8. **One differentiator: non-judgmental Improvement Opportunities** — the "positive framing" wedge

**Defer to v1.1 / v2:**
- Sync/Account Mode backend integration — can ship Local Mode first, add Account Mode when backend is production-ready (per PROJECT.md, this is a separate workstream)
- Water tracking — low complexity, but not critical
- Meal reminders — nice-to-have, not activation-critical
- CO₂ profile factors (location/transport/cooking modifiers) — ship with generic averages first; add customization once base is validated
- Passkey support — ship password + Apple + Google first; add passkeys once ecosystem matures further (2027 realistic)
- 30-day / annual insights — 7-day trend is enough for v1

**Never ship:**
- Any of the anti-features above
- GitHub sign-in for this audience
- Behavioral push notifications
- Third-party SDKs

---

## Competitor-Specific Observations

### MyFitnessPal (Under Armour → Francisco Partners, now standalone)
- **Strength:** Largest food database (14M+ items, mostly user-submitted). Massive barcode DB.
- **Weakness:** Ad-heavy free tier; aggressive paywall (Premium at $19.99/month); requires account; data quality is uneven (many duplicate/inaccurate user entries); heavy tracking (Facebook SDK, Firebase, multiple ad SDKs per Exodus scans). 2018 data breach affected 150M users.
- **Learn from:** Search UX and database breadth. Ignore: business model, tracking stack, paywall aggression.
- **UX pattern to steal:** "Copy meal from yesterday" one-tap — this is faster than any Recent/Favorites flow.

### Yazio (German, private, freemium)
- **Strength:** Clean UI, strong EU market, good portion memory ("last logged 150g"), decent recipes.
- **Weakness:** Aggressive trial-to-paid conversion (sued in Germany 2023 for subscription dark patterns); requires account; Firebase + AppsFlyer tracking; food DB weaker outside EU.
- **Learn from:** Onboarding polish, portion memory, meal cards visual design. Ignore: subscription UX, tracking.
- **UX pattern to steal:** Meal-time-of-day suggestions ("It's 12:30, log lunch?") — but implement locally, not server-side.

### Cronometer (Canadian, freemium, science-audience)
- **Strength:** Best-in-class micronutrient tracking (84+ nutrients), NCCDB + USDA + manual data curation (not user-submitted), scientific credibility, good export.
- **Weakness:** Onboarding is long and dense; UI feels dated; steep learning curve; barcode DB smaller than MFP.
- **Learn from:** Data quality discipline (curated > user-submitted for base foods), export UX, methodology transparency (they publish nutrient database sources). Ignore: onboarding length.
- **UX pattern to steal:** "Data source shown per food" — small "USDA" or "OFF" badge on each food. Consumers who care will see it; those who don't will ignore it.

### Lifesum (Swedish, freemium, lifestyle angle)
- **Strength:** Best visual design in category ("plate" metaphor for daily balance), strong onboarding conversion, personality-driven tone.
- **Weakness:** Paywall gates most features; tracking heavy; food DB weaker than MFP; "life score" is opaque.
- **Learn from:** Visual design polish, tone (mostly non-judgmental), plate metaphor. Ignore: paywall, opaque scoring.
- **UX pattern to steal:** Weekly "review" screen with 2-3 highlights — better than an infinite scroll of stats.

### CO₂-specific apps

**Klimato** — B2B (restaurants); shows CO₂ per menu item. Consumer-facing version limited/regional. **Learn:** methodology publication, restaurant-friendly UI. **Skip:** wrong market segment.

**Evocco (Irish, mostly-defunct)** — Photo-of-receipt CO₂ calculation for grocery hauls. Interesting UX but low accuracy (receipts don't have brand info, so mapping to CO₂ estimates was rough). **Learn:** the "shopping-basket" mental model is powerful. **Skip:** receipt-photo approach — accuracy issues doomed it.

**My Emissions** — Web-first, provides A-E CO₂ labels for recipes. Consumer education angle. **Learn:** the A-E letter grading is intuitive for consumers, but critics call it greenwashing when applied without regional context. **Cautious:** letter grades hide detail — CO₂ Diet's transparent-number approach is more defensible.

**Yuka (food/cosmetics scanner, French)** — Not CO₂-focused (nutrition + additives), but the barcode-scan → letter-grade UX is the reference implementation. 30M+ users. Business model: paid Nutrition subscription + partnerships. **Learn:** barcode scan speed (<2s from open-camera to result is the benchmark), score explanation depth (tap to see why), methodology transparency (published). **Cautious:** letter-grading nutrition is controversial and has been called reductive; CO₂ Diet should show numbers not badges.

**Ecolabel apps / Foodprint / Giki** — Fragmented, mostly UK/EU, not widely adopted. Signal: category is open.

**Confidence:** HIGH on the specific patterns (from published App Store reviews, press coverage of Yazio 2023 lawsuit, Exodus Privacy public reports). MEDIUM on current market share numbers — check fresh sources before public messaging.

---

## CO₂ Tracking Landscape (Specifically)

**The state of the market:**
- No dominant consumer nutrition + CO₂ combined tracker exists as of research date
- CO₂-only apps are fragmented, mostly EU, mostly small (<1M downloads)
- Users interested in CO₂ tracking currently use a mix: nutrition app + spreadsheet, or Yuka + guess, or an EU-national footprint calculator (like Klima or Capture)

**What competitors get wrong (opportunity for CO₂ Diet):**

1. **Opaque methodology.** Most CO₂ apps show a number with no explanation. Users don't trust what they can't understand. → Ship the "Estimate Transparency" screen from day 1.
2. **False precision.** "2.437 kg CO₂e" implies accuracy the underlying LCA data can't support. → Present as ranges or rounded.
3. **No regional adjustment.** Beef in Argentina ≠ beef in Ireland ≠ beef in a US feedlot; but most apps use one global number. → CO₂ Diet's regional adjustment is a genuine differentiator.
4. **No transport/cooking/storage modifiers.** Airfreighted asparagus in January is 10× the CO₂ of local. → CO₂ Diet's CO₂ Settings modifiers address this.
5. **Judgmental framing.** "Your meal was BAD." → Non-judgmental framing per PROJECT.md is correct.
6. **Product-to-CO₂ mapping gaps.** OFF has 4.5M products; the CO₂ layer will have ~200 base foods with regional multipliers. Mapping "Kellogg's Corn Flakes 500g" → "corn/cereal base + packaging + transport" is where the work is. → Prototype this in Phase 1.
7. **No offset or context.** A user sees "2 kg CO₂e" and doesn't know if that's good or bad. → Contextual equivalences ("= 8 km in an average car") make it tangible without being preachy.

**Standard datasets to consider:**
- **Poore & Nemecek 2018 (Science journal)** — foundational meta-analysis, ~40 food categories, widely cited. Public.
- **Agribalyse 3.1 (ADEME, French)** — 2,500+ products with detailed LCA. Public, French/EU-biased.
- **SU-EATABLE Life database** — Mediterranean-biased LCA data. Public.
- **CarbonCloud CFDB** — commercial, more granular. Paid.
- **Open Food Facts's own ecoscore** — controversial (accused of greenwashing methodology). Available but should be treated as one input, not the answer.

**Recommendation:** Base layer on Poore & Nemecek + Agribalyse, publish exact sources per food category, allow user to see and understand the number. Do NOT use OFF ecoscore directly (methodology criticism will haunt you); use OFF for product identification and nutrition, use your own curated CO₂ layer.

**Confidence:** HIGH on dataset names and methodology issues (established LCA field). MEDIUM on OFF ecoscore criticism specifics — worth a fresh literature check.

---

## Logging UX Patterns (What the Best Apps Do)

The <10-second log target requires optimizing these paths:

| Log Path | Fastest Time | Pattern | Notes |
|---|---|---|---|
| Barcode scan → confirm portion → save | 4–8s | Camera opens with scanner active by default; product resolves in <2s; portion pre-filled from last time; one-tap Save | Yuka nails this. MFP is slower (~10s). |
| Search → select → confirm portion → save | 6–12s | Typeahead with debounce ~150ms; results ranked by user's history first, then popularity; portion pre-filled from last time | Yazio does portion memory well; MFP doesn't. |
| Recent / Favorites → tap → tap Save | 3–5s | Two-tap re-log; portion carried over from previous log | This is the winning path for repeat meals — optimize hardest here. |
| "Copy yesterday's meal" → confirm | 4–6s | Whole-meal copy; user can edit before saving | MFP's killer feature; consider for v1.1. |
| Custom quick-add (calories + CO₂ only, no food name) | 3–4s | For users who know their numbers and want to log fast | MFP has this; polarizing but effective for power users. Consider for v2. |

**Design decisions that break <10s:**
- Requiring account creation before first log (breaks activation)
- Modal dialogs that block after each tap
- Confirmation screens for every save
- Server round-trips for portion save (must be local-write, sync-later)
- Loading spinners over 500ms on the log flow (users tap-tap-tap and lose their place)

**Design decisions that support <10s:**
- Portion memory per food per user
- Recent foods on the Log screen by default (not behind a tab)
- Barcode scanner in the log button's long-press or a dedicated FAB
- Optimistic UI: show "Saved" before backend confirms
- Predictive meal-slot ("It's 12:30, defaulting to Lunch") — but not intrusive

---

## Barcode Scanning UX (What Works on Mobile)

**The reference implementation is Yuka.** Camera opens in scanner mode, product resolves in <2s, result screen shows nutrition + score, one tap to log/save.

**Best practices:**
- **Auto-focus + auto-scan** (no "press to capture" button). ML Kit and MLKit-based scanners handle this.
- **Continuous scan mode** — user can scan multiple items in sequence for batch logging (grocery haul mental model).
- **Haptic feedback on successful scan** — critical UX signal.
- **Torch button** for low-light shelves (grocery stores are often dim).
- **Manual barcode entry fallback** for damaged/curved barcodes.
- **Not-found screen with "Add this product" CTA** — feeds back to Open Food Facts if user consents.
- **Camera permission wording matters:** "Scan food barcodes to log meals faster" > "Allow camera access." Permission-denied fallback must exist (manual search).
- **Cache last N scans locally** so recent items resolve instantly.

**Common failures to avoid:**
- Requiring network for lookup with no cache (breaks in grocery basement)
- Slow scan-to-result (over 3s → users tap away)
- No haptic/audio feedback → users unsure if it scanned
- Camera opens then user has to tap "Start scanning" (breaks flow)

**Flutter-specific note:** `mobile_scanner` (v3+, MLKit-based) is the current best-in-class Flutter barcode package. `google_mlkit_barcode_scanning` is the fallback. Confirm current maintenance status before locking. Confidence: MEDIUM (based on training-cutoff knowledge; verify current state).

---

## Open Food Facts Integration (Data Quality Reality Check)

**What OFF is:** Community-crowdsourced product database, 4.5M+ products (2026 estimate), free API, ODbL license. The de facto standard for barcode-based food lookup outside the US.

**Strengths:**
- Massive coverage in EU, growing in US
- Free forever, no API key required for reasonable volumes
- Structured nutrition data + ingredient lists + allergens + Nutri-Score + Eco-Score
- Product images crowdsourced
- Public dumps available (JSON, CSV) for offline caching

**Data quality issues users encounter:**
1. **Missing products** (~30–40% of scans in some regions). Fallback to manual entry required.
2. **Incomplete nutrition data** — many products have name + barcode but blank calorie/macro fields. UI must handle gracefully (show what's known, prompt user to fill).
3. **Duplicate entries** for the same product (multiple contributors submit same UPC differently). App should deduplicate on display.
4. **Regional product variants collapsed into one entry** (US Coca-Cola vs EU Coca-Cola have different sugar content; OFF sometimes has one entry). Show region if known.
5. **Stale data** — reformulations aren't always caught. Trust newer contributions more.
6. **Eco-Score methodology criticized** — Open Food Facts' own eco-score has been called out for greenwashing (rewards packaging over ingredient CO₂). **Do NOT surface OFF's eco-score as your CO₂ number.** Use OFF for identification only; compute your own CO₂ from your curated layer.
7. **Non-food items** (cosmetics, pet food) return from barcode scans. Filter by category.

**How other apps use OFF:**
- **Yuka**: uses OFF as primary data source, adds its own scoring layer on top
- **MyFitnessPal**: does NOT use OFF (has its own crowdsourced DB)
- **Cronometer**: uses curated USDA + NCCDB, not OFF (rejects crowdsourced quality)
- **Yazio, Lifesum**: partially use OFF + their own DBs

**Recommendation for CO₂ Diet:**
- Use OFF as primary barcode lookup
- Cache heavily (bundle a "top 10K EU + top 10K US products" seed DB in the app for offline first-launch)
- Refresh cache periodically (weekly diff) when online
- Fallback to USDA FoodData Central for base-food nutrition (curated, higher quality)
- Do NOT surface OFF Eco-Score; use your own CO₂ layer
- Show data source per food (small "OFF" / "USDA" / "You" badge — trust signal)
- Allow user to submit corrections back to OFF ONLY with explicit per-submission consent (privacy)

**Confidence:** HIGH on OFF strengths/weaknesses (widely reported). MEDIUM on specific coverage percentages (regional).

---

## Onboarding Patterns That Convert (While Respecting Privacy)

**High-conversion patterns:**
- **Progressive disclosure**: minimum viable data upfront (age or goal), rest as user engages
- **Show the app early**: Dashboard glimpsed before profile is complete
- **Skip options on every non-legal screen**: never trap the user
- **Visual/emoji-driven goal selection**: "Lose weight," "Gain muscle" as cards, not radio buttons
- **Immediate first-log CTA**: onboarding ends on Log screen, not Dashboard

**Privacy-respecting patterns (rarer, but distinctive):**
- **Local Mode as first-class**: not hidden behind "Skip account" — presented as a legitimate choice (per PROJECT.md, correct call)
- **No email required for local**: literally zero PII collection possible
- **Explicit consent per data category**: don't bundle "I agree to everything" — separate Terms, Privacy, Health Disclaimer, Age
- **Consent versioning**: timestamp + policy version stored locally so user can see what they agreed to
- **No third-party SDKs in the onboarding flow itself**: Firebase Auth, Google Analytics onboarding funnels — all forbidden

**What breaks conversion:**
- Requiring email + verification before Dashboard
- More than 5 profile-questions before first use
- Interstitial paywall after signup
- Permission prompts (camera, notifications) before user has context for why
- Legal consent as a wall of text with one checkbox at the bottom (breaks readability and GDPR "specific consent" requirement)

**CO₂ Diet's flow assessment:**
Splash → Welcome → Legal Consent → Mode Choice → Profile Setup → Carousel → Dashboard = **6 screens before first log**. This is at the upper edge of acceptable. Consider:
- Merging Splash → Welcome (or auto-progress splash after 1s)
- Making the Carousel skippable / dismissible on tap
- Progressive profile: ask only 3 essentials (age, gender, goal) upfront; height/weight/activity later on first log

**Confidence:** HIGH on general patterns. MEDIUM on the specific CO₂ Diet flow assessment — final call belongs to the design team.

---

## Why Nutrition Apps Fail (Why Users Quit)

Documented churn drivers from App Store reviews, published research on tracking-app adherence, and competitor teardowns:

1. **Logging friction** — the #1 driver. Every second over ~15s to log a meal doubles the drop-off rate at week 2. → CO₂ Diet's <10s target directly attacks this.
2. **Portion-guessing fatigue** — "how many grams is one banana?" gets old fast. → Portion memory + household units + reasonable defaults.
3. **Paywall shock** — free-trial ends, subscription hits, user churns and leaves 1-star review. → Free forever eliminates this.
4. **Guilt/shame loops** — daily "you exceeded your calories" notifications drive uninstalls after ~10 days. → Non-judgmental framing.
5. **Data doesn't feel private** — user sees Facebook ad for a food they logged; correctly assumes tracking; deletes app. → No third-party SDKs, ever.
6. **Numbers users don't understand or trust** — CO₂ especially. "2.4 kg CO₂e" means nothing without context. → Methodology + comparisons + ranges.
7. **Sync/backup loss** — user changes phones, loses log history, never returns. → Export + backup + restore, tested end-to-end. CO₂ Diet already specs.
8. **App feels unfinished** — bugs, slow search, missing foods on first scan. First week must feel polished.
9. **No positive reinforcement** — logging feels like a chore with no payoff. → Weekly wins summary; progress framing; sustainable-swap opportunities.
10. **Notification spam** — engagement re-hooks feel needy. → Meal reminders only, opt-in, no growth notifications.

**Retention benchmark:** typical nutrition apps see ~10–15% D30 retention. Best-in-class (Cronometer for its niche) sees ~25%. If CO₂ Diet can crack 20% by not doing the anti-patterns above, that's a category-leading result.

**Confidence:** HIGH on the general drivers. LOW on specific retention numbers (varies wildly by report/methodology).

---

## Privacy Red Flags Users Actually Notice

Documented from Reddit r/privacy, Hacker News threads, App Store reviews, and Exodus Privacy report comments:

1. **App has "no ads" in App Store description but shows ads or has ad SDKs** — instant credibility loss
2. **"We don't sell your data" but has Google Analytics** — users don't accept the distinction
3. **Facebook SDK detected in app** — near-universal red flag for privacy-focused users
4. **Firebase Analytics / Crashlytics** — increasingly recognized as tracking
5. **Requires account for basic features** — inconsistent with "your data is yours"
6. **Privacy Policy that says "we may collect... share with partners... for marketing purposes"** — boilerplate language that signals "we do collect and share"
7. **Account deletion buried or requires email support** — GDPR concern + trust concern
8. **Third-party login (Google/Apple/Facebook) as ONLY option** — no email/password = data-hoovering suspicion
9. **App size >100 MB with unclear reason** — often means bundled SDKs
10. **Vague Data Safety card on Google Play** ("May collect location, purchases, browsing history") with no specifics
11. **App uses your calendar / contacts / location without clear feature reason**
12. **In-app browser opens for external links** (often to track click-throughs)
13. **Push notification prompt on first launch** without context

**CO₂ Diet passes all these tests IF:**
- Zero third-party SDKs (verifiable via Exodus scan post-launch)
- Local Mode requires no email
- Account Mode uses self-hosted Keycloak (not Google/Apple Auth for the identity, though social login can chain through Keycloak)
- Privacy Policy uses plain language and specific claims
- In-app deletion is one tap deep in Settings
- Data Safety card on Play Store is minimal and specific
- No push notifications beyond user-configured meal reminders

Recommend running Exodus Privacy scan + a MobSF scan pre-launch and publishing the results in the app's About screen. This is a rare and powerful trust move.

**Confidence:** HIGH — these patterns are well-documented in privacy communities.

---

## Sources

Access to WebSearch, WebFetch, and Context7 was denied in this research session. Findings above are synthesized from prior training-data knowledge of:

- MyFitnessPal, Yazio, Cronometer, Lifesum (App Store listings, press coverage, published teardowns)
- Yuka, Klimato, Evocco, My Emissions (published coverage, App Store)
- Open Food Facts (openfoodfacts.org public documentation)
- Poore & Nemecek 2018, Science journal
- Agribalyse (ADEME public database)
- Yazio 2023 German subscription lawsuit (press coverage)
- MyFitnessPal 2018 data breach (press coverage)
- Exodus Privacy public tracker reports (reports.exodus-privacy.eu.org)
- App Store review common complaints (patterns from Reddit r/privacy, r/MyFitnessPal, HN threads)
- Apple App Store Guideline 5.1.1(v) — account deletion requirement, effective June 2022

**Verification recommended before locking scope:**
1. Fresh Exodus Privacy scans of MFP, Yazio, Lifesum, Cronometer to confirm current tracker stacks
2. Current App Store listing text for competitor paywall/subscription pricing
3. Fresh literature scan on OFF Eco-Score methodology critique
4. Current maintenance status of Flutter `mobile_scanner` package
5. Poore & Nemecek 2018 vs newer meta-analyses (2023–2025 papers may exist)
6. Klimato / Evocco / My Emissions current status (Evocco especially — status uncertain at cutoff)
7. Yuka current CO₂-related features (was adding sustainability angle at cutoff)

**Overall confidence: MEDIUM** — patterns and category structure are HIGH confidence; specific competitor details and current market state should be verified with fresh sources before public messaging or roadmap-locking decisions.
