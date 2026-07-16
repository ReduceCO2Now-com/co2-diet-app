# CO₂ Diet — Full Reference Document
**Purpose:** Detailed source material for GSD's research/planning phases. Not meant to be loaded in full every session — reference on demand.
**Companion to:** `docs/Diet-Mobile-app ReduceCO2Now.pdf` (the primary PRD)

---

## 1. UI/UX Design Documentation (Kick-off Doc)

**Stakeholders:**
- Dr. Thomas Buro — Product Owner
- Ian — Developer (Flutter frontend, per architecture doc)
- Sid — Developer (Flutter frontend, per architecture doc)
- Tomris — Backend developer
- Design team: Lydia, Ilke, Neetha, Dilosi (UX/UI Designers)

**Project scope — 3 parts:**
1. Research & analysis: user interviews, competitive analysis (Yazio, MyFitnessPal), persona definition, information architecture, user flow
2. Style guide: typography, color palette, spacing, component library, iconography, voice/tone, data visualization style, platform specifics, accessibility
3. Mid-fi wireframes → prototypes → design discussion/revision → usability testing (3+ users) → final design (all states, edge cases) → handoff

**Persona note (open discussion point):** Original PRD specifies a single persona — female, mother, 30 years old. UX team flagged this as too narrow given the feature set, proposed expanding to a primary persona + two validator personas.

**Tools:** Figma (wireframes/prototypes/handoff), FigJam (research artifacts, personas, user flow, journey maps), Google Docs/Sheets (documentation), Stitch (AI design tool, role TBD with dev team).

**Pre-launch success metrics:**
- Logging takes <10 seconds
- 3 taps for recent-food logging
- Onboarding completed without assistance
- CO₂ information correctly interpreted
- Self-Assessment Manikin (SAM) test — confirms app doesn't feel judgmental, stressful, or pressuring

**Open questions raised by UX team (unresolved as of last review):**
1. Are there existing communities for recruiting research participants?
2. How to enforce 16+ age gate — self-declaration, date of birth, or parental consent each imply different onboarding screens
3. Are all three social sign-ins (Apple/Google/GitHub) needed for v1, or only for account mode? GitHub flagged as unusual among users
4. Does social sign-in conflict with the anonymous local-only privacy positioning?
5. What format does the developer need the design spec in during handoff?
6. Barcode scanning — v1 or v2? Listed as P1 in backlog but mentioned as core function in main PRD section
7. What exactly counts as "mid-fidelity" for design discussion — prototypes or polished designs?

---

## 2. Confirmed Navigation Architecture

**Core principle:** 3 layers only — Core Action (daily use), Insight (analysis/understanding), Settings (control/data/legal/advanced).

**Bottom navigation — 4 tabs, fixed:**

1. **Dashboard** (default landing screen)
   - Daily summary: CO₂ impact, calories, protein (with targets)
   - Quick log buttons: Breakfast / Lunch / Dinner / Snack
   - "+ Quick Add Food" secondary shortcut
   - Today's meals list (editable, swipe/duplicate actions)
   - Quick insights (lightweight, e.g. "Lunch contributed most CO₂ today")
   - 7-day trend chart
   - Local mode: "Stored on this device" label / Account mode: "Synced across devices"

2. **Log** (Fast Entry Hub)
   - Meal-type tabs: Breakfast/Lunch/Dinner/Snack
   - Instant local search + Open Food Facts API (4.5M products)
   - Barcode scanning (camera via getUserMedia, graceful fallback confirmed working)
   - Quantity + unit selector (g/ml/cups/portions/pieces), smart context-aware hotkeys (½ glass, 1 portion, etc.)
   - Recent section — **individual food items only**, not combo entries (confirmed via live build, this superseded an earlier spec draft)
   - "Add to Meal" button
   - Offline-first, no network dependency for core flow

3. **Insights**
   - **Data Analysis screen** (contextual — opens from tapping any Dashboard metric: CO₂/Calories/Protein/Daily Score/Weekly Trend/Weight)
     - Today's Breakdown (by meal, stacked bar)
     - Largest Contributors (ranked list)
     - Goal Comparison (progress bar + dynamic message)
     - Trend Analysis (7/30 day, switchable metric)
     - **Improvement Opportunities** — sustainable alternative suggestions with quantified impact (e.g. "Replacing today's beef meal with chicken would reduce impact by 1.2 kg CO₂") — this is the FR-042/US-032 "Sustainable Alternatives" feature
     - Detailed Food Analysis (expandable, per-serving + per-100g values)
     - Estimate Transparency (methodology explanation, links to CO2 Calculation Settings)
     - Insights Timeline (chronological observations feed)

4. **Profile / Settings** — grouped sections:
   - **Account & Mode:** account creation/login, local mode status, sync settings
   - **Personal Data:** profile setup, weight tracking, goals
   - **Food System:** My Foods (custom database), Advanced Features (community contribution)
   - **Data Management:** Backup & Restore, export data, delete local data
   - **CO₂ System:** CO2 Calculation Settings, methodology explanation, data sources
   - **Support & Community:** FAQ/Help, Discord community, diet book download
   - **Legal:** About, Terms of Use, Privacy Policy, Health Disclaimer, Impressum

**Global navigation rules:**
- Dashboard always the default entry point
- Logging reachable in ≤1 tap
- Max nav depth: 3 levels
- Offline-first: Dashboard, Log, Insights all work offline; sync only enhances, never blocks
- Local Mode and Account Mode have identical navigation — only sync indicators differ, no feature-locking

**Onboarding flow (pre-nav):**
Splash → Welcome → Legal Consent → Account/Local Mode Choice → Profile Setup → Onboarding Carousel → Dashboard

---

## 3. Screen-by-Screen Specifications

### Splash Screen
2-3 second load, centered logo, tagline ("Lose Weight. Improve Health. Reduce CO₂." per live build, differs slightly from original spec's "Track calories..."), small loading indicator, no buttons, no navigation. Auto-advances to Welcome.

### Welcome Screen
Logo + app name, tagline, "Private. Offline-first. No ads." supporting line. Two primary buttons: "Get Started" (→ Legal Consent) and "Use Without Account" (→ Local Mode onboarding, skips Legal Consent... **note: verify this, since local-mode users are still bound by Terms/Disclaimer even without an account** — flagged inconsistency). No scroll, single screen. **Design intent: both buttons should be visually near-equal weight** — this is stated explicitly to preserve privacy-first trust positioning.

### Legal Consent Screen
"Before you start" / "We need your consent to continue." Single scrollable card. 4 mandatory checkboxes (Terms of Use, Privacy Policy, not-medical-advice disclaimer, user-responsibility disclaimer) + 1 optional (16+ age, self-declaration). "Accept and Continue" disabled until all mandatory boxes checked. Links to View Terms/Privacy/Disclaimer. Footer includes "Environmental Wellness © 2024" (confirmed via live screenshot, not in original written spec).

### Account or Local Mode Choice Screen
"How would you like to continue?" Two cards: **Create Account** (benefits: sync, save preferences, personalized insights; email required) and **Local Mode** (benefits: no signup, offline, data on-device; plus "Export & Restore your data anytime" — including optional secure cloud backup *without* email). CTA changes based on selection: "Continue" or "Start Using App." "Already have an account? Sign in" link below.
**Known discrepancy:** written design intent says both cards should be visually equal; live build shows Create Account with a "Recommended" badge and emphasized border — unresolved as of last review.

### User Profile Setup
"Tell us about you." All fields optional except possibly age. Sections: Basic Info (age, gender dropdown, height, weight, metric/imperial toggle — metric default), Dietary Preference (chips: No preference/Vegetarian/Vegan/Flexitarian/Low meat/Other), Goal Selection (single-select: Reduce CO₂/Lose weight/Improve health/Balanced lifestyle/Learn & explore), Activity Level (Low/Medium/High), Personalization toggle (default ON). "Continue" always active, no blocking validation. Auto-saves as user types. Footer note varies by mode (local: "stored only on this device" / account: "synced securely").
**Note:** CO₂-specific profile factors (purchase habits, transport, cooking method, storage, household size) do NOT live here — see CO2 Calculation Settings below.

### Onboarding Carousel ("How CO₂ Diet Works")
3-4 slide swipeable carousel. Slide 1: food choices have impact. Slide 2: how CO₂ scoring works (production/transport/processing factors). Slide 3: what you can do (log, compare, track progress). Slide 4 (optional): data/control (local vs. account mode). "Go to Dashboard" sticky button (last slide), "Skip intro" link (jumps straight to Dashboard regardless of current slide).

### Dashboard
See Navigation Architecture section above for full breakdown. Empty state: "No meals yet → Start logging."

### Log Meal (Fast Meal Logging)
See Navigation Architecture section above. **Confirmed current behavior (via live build): Recent section shows individual food items with quantity, not combo entries.** Quick preset quantity buttons (e.g. 100/150/250/300ml) are user-defined via My Foods → Quick Serving Sizes, not hardcoded.

### CO2 Calculation Settings
"Help us estimate the environmental impact of your food choices more accurately." All fields optional, regional averages used as fallback. Sections: Location (country + optional region), Food Purchasing Habits (source type + % local), Shopping Frequency (trips/week + transport method), Food Storage (fridge size, freezer), Household (people sharing purchases), Food Waste (estimated level), Calculation Transparency (methodology explanation + links), Data Quality Indicator (dynamic completeness score: Basic/Good/Detailed Estimate). Buttons: "Save Settings," "Use Regional Defaults," "Reset to Defaults."
**This is where FR-010's CO₂ profile factors actually live** — confirmed intentional, not a gap.

### Data Analysis Screen
See Navigation Architecture section above (under Insights tab). Opens contextually from any Dashboard metric tap.

### Backup & Restore
"Your data belongs to you." Sections: Current Storage Status (mode, size, last backup, record counts), Create Backup (device/cloud/share options), Automatic Backups (frequency, destination), Restore Data (source selection, preview before restore, confirmation required), Export Data (CSV/Excel/JSON, selectable data categories), Privacy & Ownership statement, Danger Zone (delete all local data, requires confirmation).

### Weight Tracking
"Track your progress over time." Sections: Record Weight (numeric input, kg/lb toggle, optional note), Weight History & Trend (current/change since last/change 30-day, interactive chart with 7d/30d/90d/1yr/all-time filters), Reminder Settings (Never/Weekly/2-Weekly/Monthly/Custom), Best Practices (measurement consistency tips), Learn More (guide, diet book, Discord), optional Weight Goal (target weight/date, progress display).

### My Foods (Custom Food Database)
Two modes: New Custom Food or Personal Version of existing food. Sections: Food Identification (name, brand, category), Reference Amount (100g/100ml/serving/portion/piece), Nutrition Values (calories, protein, carbs, sugar, fat, fiber, salt), CO₂ Values (manual entry or "Estimate CO₂ Automatically" using category averages), Quick Serving Sizes (user-defined portions → become quick-log buttons), Package Information (optional), Search Behavior preferences, Source Information, Validation Summary. Buttons: Save Food / Save and Log Food / Cancel.
**Important data model requirement:** personal versions must never overwrite original database entries — override/original pair, fully revertible.

### Advanced Features (CO₂ Data & Calculation Feedback)
For advanced users/researchers. Sections: Submit Food Data Feedback (report inaccuracies, categorized feedback types, optional image upload), Add Scientific Reference (URL + notes, for LCA studies/datasets), Calculation Transparency Reminder, Community Discussion (Discord links), Contribution Status (submission counts, review status, "Trusted Contributor" badge), Data Integrity statement (all submissions reviewed before affecting global database).

### Legal & Privacy Hub
Central hub, government-style clarity, no inline long text. Sections: About, Legal Documents (Terms/Privacy/Health Disclaimer/Impressum — each a full document screen), Data & Transparency (CO₂ methodology, data sources, user data control), Your Rights summary, Support (FAQ, Discord, contact email).

---

## 4. Design System — "Eco-Minimalist Wellness"

**Source:** Separate `DESIGN.md` token file (not part of the PRD PDF).

**Brand identity:** "Environmental Wellness" — personal health + ecological responsibility. Soft Minimalism with Ambient Depth. Feels like "a high-end health clinic meets a sustainable lifestyle boutique."

**Core colors:**
- Primary: `#005222` (buttons, primary actions)
- Primary container/tint: `#006d2f` (icon backgrounds, tonal fills, glows)
- Secondary (blue): `#0155c7` (links, informational accents)
- Background/surface: `#ffffff` (pure white canvas)
- Text (on-surface): `#1a1c1e` (dark charcoal, not pure black)
- Error: `#ba1a1a`
- Full color token set available in `DESIGN.md` (not duplicated here — see that file directly)

**Typography:**
- Plus Jakarta Sans — nearly all UI levels (headlines use negative letter-spacing, -0.02em)
- Inter — "Label Caps" style (uppercase, 12px, weight 600, letter-spacing 0.05em) for functional/technical metadata and section labels only

**Shape language:** Consistently rounded.
- Standard buttons/cards: 8px (0.5rem)
- Larger containers: 16px (1rem) or 24px (1.5rem)
- Status indicators/loading dots: fully rounded (circles)

**Elevation — "Ambient Depth" (no traditional heavy shadows):**
1. Glow Layers: high-radius (80-100px) blurs at 3-5% opacity behind brand elements
2. Tonal Stacking: surface color steps instead of shadow-based elevation
3. Dynamic Micro-shadows: barely-visible 2px blur at 5% opacity for interactive "lift" only

**Components:**
- Buttons: high-contrast primary (green fill, white text); secondary as ghost/outline OR soft tonal background
- Input fields: subtle outline-variant border, no fill; focus state = 2px primary-color stroke
- Cards: no borders, use surface-container-low for distinction against white background
- Micro-interactions: fade in with 10px vertical translation ("rising" into view)

**Layout:** Fluid Margin Model — 20px container margin on mobile. Base-4 spacing scale (24px/48px as primary section-break drivers). Max content width 600px on larger screens.

**Logo:** CO₂ Diet brand logo — leaf + fork + CO₂ molecule icon motif, green primary color. [Actual logo image file to be placed at `docs/assets/logo.png` or equivalent — not reproducible as text, must be added as an image asset directly.]

---

## 5. Confirmed Live-Build Screen Inventory (16 Stitch exports, audited)

Cross-referenced against actual `code.html` + `screen.png` exports, not just written specs:

1. Splash
2. Welcome
3. Legal Consent
4. Account/Local Mode Choice
5. User Profile Setup
6. Dashboard
7. Log Meal (current version — individual items in Recent, meal-type tabs, "Add to Meal" above quantity)
8. General Settings *(confirmed screen, not in original written spec — units, notifications, local mode status, export/clear data, account info)*
9. CO2 Calculation Settings
10. Backup & Restore
11. Weight Tracking
12. My Food
13. Advanced Features
14. Legal & Privacy
15. Onboarding Carousel

**Note:** An earlier Log Meal export (combo-entry "Recent" section, no meal-type tabs) exists but is superseded by the current version listed above.

---

## 6. Known Open Decisions (as of last review — confirm current status before assuming)

| Decision | Status |
|---|---|
| Barcode scanning priority | **Resolved during GSD initialization: P0, must-have for launch** |
| Visual weighting: Create Account vs. Local Mode | Open — design intent says equal, live build shows bias |
| GitHub as sign-in option | Open |
| Passkey-first vs. password-first signup | Open |
| 16+ age gate mechanism | Open — checkbox vs. DOB vs. parental consent |
| Log Meal Recent — combo vs. individual | **Resolved: individual items only, per live build** |
| Admin Profile scope | Open — likely web/backoffice, needs confirmation, out of Flutter mobile scope |
| Weight Tracking placement (Settings vs. also in Insights) | Open — unclear if link/shortcut or native rendering |
| Persona scope (1 → 3 personas) | Open |

---

## 7. System Architecture (from PRD, confirmed)

**Frontend:** Flutter — single codebase for iOS + Android. Local storage: Hive (to be finalized).

**Backend:** Modular monolith, Java 21 / Spring Boot 3. Extract to separate services only when load demands it (ingestion or search likely first candidates).

**Database:** Self-hosted PostgreSQL — explicitly NOT Firebase/Firestore. Chosen for open-source self-hostability, relational fit for catalog/CO₂ tables/version-based delta sync, predictable flat cost, and DuckDB compatibility for processing Open Food Facts data dumps.

**Authentication:** Spring Security (OAuth2/OIDC) + Keycloak — self-hostable, open source. Supports Apple/Google/GitHub social login + passkeys. Local-only mode requires zero server account. (Supabase noted as a fallback alternative if a bundled DB+auth+storage solution is ever preferred — still Postgres underneath.)

**Nutrition data sources:** Open Food Facts (primary, 4.5M products), USDA FoodData Central. Enriched with custom CO₂ data, sustainability scores, regional adjustments.

**CO₂ Engine:** Planned as a dedicated microservice. Inputs: food item, quantity, region. Outputs: CO₂e estimate, sustainability score.
