---
status: accepted
date: 2026-09-07
supersedes: ONBD-03 "Mode Choice" as specified in Phase 6 SC-1
---

# 1. Mode Choice is a connectivity choice, not an account choice

## Context

Phase 6's success criterion 1 requires a **Mode Choice** screen in onboarding —
two equal-weight cards, Account Mode versus Local Mode, audited against the
live build's bias toward account creation. No such screen exists in `lib/`.
Mode Choice was deferred during the Phase 7/8 split on 2026-08-08, but the
criterion was never amended, so Phase 6 has been unclosable ever since despite
all ten of its plans being complete.

The roadmap also contradicts itself on where it went: the Delivery Principle
assigns Mode Choice to Phase 8, while Phase 10's scope lists "ONBD-03's Mode
Choice screen" as v1.1+ deferred scope.

Resolving this required knowing what an account actually buys, which meant
reading the backend rather than the plan.

## What the backend actually provides

Reviewed at `ReduceCO2Now-com/CO2Diet_Backend@origin/main`, 2026-09-07:

| Module | State |
|---|---|
| `catalog` | Food product query (id, barcode, search) + upsert, over PostgreSQL. Tested |
| `ingestion` | Open Food Facts source, client, mapper, transport. Tested |
| `co2` | **Interfaces only** — `Co2Query.estimate(foodId, grams)` → `Co2Estimate`. No implementation |
| `app` | Spring Boot bootstrap, OAuth2 resource server (Keycloak), `GET /api/v1/me` |

Two facts decide this decision:

**The catalog endpoints are public.** `SecurityConfig` declares
`/api/v1/foods/**` as `permitAll()`. Search, barcode lookup and by-id require
no authentication.

**The backend stores no user data, by design.** Its own architecture document
states the backend "is deliberately thin… it is **not** a store of user
activity," and that personal data lives on the device. An account exists for
contribution attribution, moderation roles, and a *contingent, unresolved*
encrypted backup.

Therefore **online access requires no account, and an account grants no
additional catalog access.**

## Decision

**Split ONBD-03 into two independent concerns.**

### A. Connectivity choice — belongs in onboarding, ships without backend dependency

The user chooses whether the app may use the network at all:

- **Offline only** — the bundled catalog and the user's own foods. No remote
  lookups, ever.
- **Online catalog allowed** — remote lookups for products the bundled pack
  lacks. Still no account; still nothing personal transmitted.

This is a real, honest choice with a real consequence, and both options are
fully functional — which is what the "equal weight, no recommended badge"
requirement was reaching for.

### B. Account sign-in — already shipped, already correctly placed

`/auth` landed in Phase 7 and is reached from Settings. It stays there. An
account is an enhancement, not an onboarding gate. The Local→Account **data
migration** remains Phase 8, contingent on the backend's unresolved
data-ownership question.

## Rationale

**The original framing offered a false choice.** Account versus Local implies
the two differ in capability. They do not: both reach the same public catalog,
both keep all personal data on-device. Presenting them as equal-weight
alternatives would ask users to decide something that changes nothing they can
observe.

**The real axis is network use**, and that axis genuinely matters to this
product's users. Someone who chose this app for privacy may reasonably want it
to make no outbound requests at all. Today that is impossible: the app falls
back to the Open Food Facts API automatically on a local miss, with no way to
prevent it.

**It unblocks Phase 6 with no external dependency.** The connectivity choice
needs nothing from the backend team, so it cannot be blocked by the Phase 8
data-ownership conversation.

**It matches the product's stated positioning.** `PROJECT.md` already flags the
live build as biased toward account creation, against design intent. An app
whose central promise is that no account is needed should not open by asking
about accounts.

## Consequences

- Phase 6 SC-1 is amended: Mode Choice becomes the connectivity choice.
- Phase 10's "ONBD-03's Mode Choice screen" entry is struck as superseded.
- Phase 8 retains the Local→Account upgrade path only.
- A `networkMode` preference, its enforcement points, and a Settings row are
  added now. The onboarding card is a separate, cosmetic follow-up — the
  preference is what makes the guarantee real.
- **Default is `onlineAllowed`**, preserving today's behaviour. Changing the
  default silently would remove food search for most users, since the bundled
  pack is deliberately small. Once the onboarding card ships and the choice is
  explicit, the default stops mattering.

## What this does not decide

Whether remote lookups should also be gated for the reference-pack download.
Current position: **no** — that download is explicitly user-initiated, and a
user who taps "download the full catalog" has already made the choice. Only
*automatic* network use is gated. Revisit if users report surprise.
