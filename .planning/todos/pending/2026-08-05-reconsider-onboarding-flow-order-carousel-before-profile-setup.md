---
created: 2026-08-05T08:39:12.833Z
title: Reconsider onboarding flow order — Carousel before Profile Setup
area: ui
files:
  - lib/features/onboarding/screens/onboarding_carousel_screen.dart
  - lib/features/profile/screens/profile_screen.dart
  - lib/core/router/app_router.dart
  - .planning/phases/06-onboarding-legal-consent-legal-hub-ed-safety-nets-accessibility-pre-submission/06-CONTEXT.md:26
---

## Problem

Currently-shipped, locked flow (06-CONTEXT.md:26): Splash → Welcome →
Legal Consent → Profile Setup → Onboarding Carousel (3 slides) →
Dashboard. This was confirmed working exactly as spec'd during 06-10
real-device manual verification (both platforms) — not a bug.

While verifying that flow end-to-end on-device, the user raised a
genuine UX preference: Profile Setup (age/height/weight/goal — a form
requiring real input) currently comes *before* the Carousel (which
explains what the app does and why CO₂ scoring works the way it does).
The user's instinct is that explaining the app's purpose first, then
asking for personal data, might read better than asking for data before
the user understands why it's needed.

Explicitly NOT changed ad hoc mid-execution — the user asked to log this
as a flagged discussion item and finish verifying the currently-spec'd
flow first (06-10's remaining checkpoints 2/3), then revisit ordering as
its own deliberate decision if the preference still holds after seeing
the whole thing work end to end.

## Solution

TBD — if revisited, this is a real flow-order change requiring:
- Updating 06-CONTEXT.md's locked decision (or a new phase/plan context)
- Reordering routes in app_router.dart's redirect allowlist/route tree
- Checking whether Profile Setup's "Continue to Carousel" button copy/
  placement and Carousel's Skip/Finish→completeOnboarding() call sites
  still make sense with Carousel running first
- Re-verifying the bottom-nav-hiding fix (06-10, AppShell) still applies
  correctly regardless of which pre-onboarding screen comes first
