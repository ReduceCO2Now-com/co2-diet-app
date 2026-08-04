<!-- PENDING LEGAL REVIEW: this document is a drafted copy-in reference for whoever owns the
     real Google Play Console submission. It is NOT filled into any live console form. -->

# Google Play Data Safety and Age Rating — Draft Answers

**Status:** Draft, for manual copy-in at real submission time. Not a live submission.
**Drafted:** Phase 6 (pre-submission), 06-06-PLAN.md
**Owner at real submission time:** Whoever owns the actual Play Console listing — the same
person/entity who owns the Impressum identity decision (see `STATE.md` Pre-Launch Blockers).

This document mirrors the actual structure of Play Console's Data Safety form and the age
rating questionnaire so the answers can be copied in directly, question by question, when the
real submission happens.

---

## 1. Data Safety Form Answers

### "Does your app collect or share any of the required user data types?"

**Answer: Partially — see breakdown below.**

In **Local Mode** (the only mode that exists as of Phase 6 — Account Mode / backend sync is a
Phase 7+ feature), all personal data entered by the user stays on-device and is never
transmitted to any server the app or its developer controls:

- Profile fields (age, sex, height, weight, activity level, dietary preferences)
- Meal logs (food entries, portions, timestamps)
- Weight tracking entries
- CO2 calculation settings and personal multiplier factors
- Consent records / legal document acceptance history

None of the above is collected by the developer, shared with the developer, or transmitted off
the device in Local Mode. There is no backend account, no analytics SDK, and no ad SDK in this
app (CI-enforced dependency blocklist, see `PRIV-07`).

### "Third-party data sharing" — **Answer: YES**

Even though the app has no account/backend contact in Local Mode, it makes network requests
directly to the **Open Food Facts (OFF) API** for barcode lookups and food search:

- **Data shared:** search terms the user types into the food search box, and barcodes the user
  scans with the camera.
- **Recipient:** Open Food Facts (a third-party, non-profit, open-data food database — not an
  entity controlled by this app's developer).
- **Purpose:** app functionality (food/nutrition lookup) — not advertising, not analytics, not
  sold or shared for any other purpose.
- **User control:** this is core app functionality; it occurs whenever the user searches for a
  food or scans a barcode, in both Local Mode and (in future) Account Mode. There is no
  opt-out, since disabling it would remove the food-lookup feature entirely.

This disclosure is required per Play Console's Data Safety guidance: any network request to a
third-party API counts as "sharing" for this form's purposes, regardless of whether the app
itself has its own backend. (06-RESEARCH.md / PITFALLS.md item C4: the app makes network
requests only to the Open Food Facts API and no other external service.)

### "Is data encrypted in transit?"

**Answer: YES**, for the one external data flow that exists (OFF API queries). The Open Food
Facts API is served over HTTPS; all requests from this app use HTTPS transport, consistent
with OFF's own published API access requirements. No other network endpoint exists in Local
Mode.

### "Can users request that their data is deleted?"

**Answer: YES**, via the in-app **Danger Zone** (Settings > Danger Zone, `PRIV-09`), which lets
the user permanently erase all locally-stored personal data (profile, meal logs, weight
entries, CO2 settings) from the device.

**Caveat to note in the form's free-text field:** this is a **local-only deletion**. Since
Local Mode has no backend account, there is no server-side copy of this data to also delete —
the Danger Zone wipe is complete and final for this app's own data footprint. (When Account
Mode / backend sync ships in a later phase, this answer must be revisited to describe the
`DELETE /me/account` server-side deletion path as well.)

---

## 2. Age Rating Questionnaire Draft

**Target rating: 16+**

**Content descriptor: "Frequent/Intense Medical/Treatment Information"**

This follows the locked decision in `06-CONTEXT.md`, based on the MyFitnessPal precedent
(nutrition/calorie-tracking apps of this kind are rated 16+ by both Apple and Google, not
"Everyone" — the "health app = Everyone" assumption is explicitly rejected). The app displays
ongoing nutritional/dietary tracking data and calorie/macro targets, which both platforms'
rating systems classify under medical/treatment-adjacent content at a frequency warranting the
16+ / Teen-plus band rather than a blanket "Everyone" rating.

### "Is this app directed at children / Made for Kids?"

**Answer: NO**, for both Google Play's "Target age and content" questionnaire and Apple App
Store Connect's equivalent age-rating question.

This is deliberate and consistent with the 16+ positioning above: nutrition/calorie tracking
with numeric targets, weight tracking, and (per `docs/legal/health_disclaimer.md`) explicit
eating-disorder safety-net language is not appropriate for a child-directed app, and marking
the app as child-directed would trigger COPPA (US) and equivalent child-data-protection
compliance obligations this app does not currently implement (no parental consent flow, no
child-specific data minimization beyond what's already required for all users).

---

## 3. "Not a Medical Device" Disclaimer — Store Listing Placement

Google Play's health-app policy (per a January 2026 policy update — see confidence note below)
requires apps without EU medical-device certification to prominently display a specific
disclaimer. This app already carries the required sentence verbatim in
`docs/legal/health_disclaimer.md` (drafted in Plan 06-02):

> **This app is not a medical device and does not diagnose, treat, or prevent any condition.**

**Action for real submission:** this same sentence (or a close paraphrase preserving "not a
medical device," "does not diagnose, treat, or prevent") should also appear in the **Play
Store listing description** itself, not just the in-app disclaimer screen.

**Confidence: MEDIUM.** This requirement is sourced from a secondary blog post summarizing
Google's January 2026 health-content policy update, not fetched directly from
`support.google.com` (06-RESEARCH.md Pitfall 6 / Assumption A2). **Recommend re-verifying the
exact current wording against Play Console's own Health Content policy page before the Play
Store description is finalized at real submission time** — Google's own policy page is the
authoritative source, this draft is a best-effort placeholder.

---

## 4. Open Questions Carried Forward (Pre-Submission Blockers)

- **Privacy Policy public URL.** Play Console's Data Safety form requires a public URL where
  the Privacy Policy is hosted. This codebase currently has no public website / hosting target
  — `docs/legal/privacy.md` exists only as an in-repo/in-app document. **Whoever owns the real
  store listing must resolve where this policy will be publicly hosted** (e.g., a GitHub Pages
  site, a marketing site, or a hosted-in-app deep link Google accepts) before submission can
  proceed. This is the same open decision as the Impressum entity/address placeholder tracked
  in `STATE.md`'s Pre-Launch Blockers — both need a decision from whoever formally owns
  ReduceCO2Now.
- **External legal review.** Per `06-CONTEXT.md`, all drafted legal text (Terms, Privacy,
  Health Disclaimer, and this Data Safety draft) is pending Fachanwalt IT-Recht sign-off. This
  document should be re-reviewed alongside that legal pass before real submission, not treated
  as final copy.
