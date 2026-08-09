---
status: ASSUMED -- not yet confirmed with Tomris
requested_by: Ali (Flutter client)
owner: Tomris (Backend -- Spring Boot + PostgreSQL + Keycloak)
related_requirement: PRIV-05
last_updated: 2026-08-10
---

# GDPR Account Deletion — API Contract Spec

This document specifies the backend contract the Flutter client (`AuthNotifier.deleteAccount()`
in `lib/features/auth/providers/auth_provider.dart`) currently assumes for permanently deleting
an Account Mode user's backend account. **Every field below is `[ASSUMED -- not yet confirmed
with Tomris]`** — this is a concrete written proposal for review, not a description of an
already-agreed contract. Per `07-RESEARCH.md` Open Question #1, this doc exists specifically so
Tomris has something concrete to confirm, adjust, or reject, rather than the client silently
guessing at runtime.

## Legal requirements driving this contract

- **PRIV-05 / GDPR Art. 17 ("Right to erasure")**: an Account Mode user must be able to
  permanently and irreversibly delete their account and any backend-held personal data
  associated with it, on request, without undue delay.
- **Apple App Store account-deletion requirement (in effect since June 2022, App Store Review
  Guideline 5.1.1(v))**: any app that supports account creation must also offer in-app account
  deletion — this is a hard App Store submission blocker if unmet, not just a GDPR nicety.

## Assumed request contract

| Field | Value | Status |
|---|---|---|
| Method | `DELETE` | `[ASSUMED]` |
| Path | `{baseUrl}/me/account` | `[ASSUMED]` — `baseUrl` per `BackendConfig.baseUrl` |
| Headers | `Authorization: Bearer <access_token>` | `[ASSUMED]` — the caller's current OIDC access token, no other auth mechanism |
| Request body | none | `[ASSUMED]` — deletion target is implied by the bearer token's subject claim, not a request parameter |
| Idempotency | not assumed idempotent — a second call after successful deletion is expected to fail (the account no longer exists / token no longer valid) | `[ASSUMED]` |

## Assumed response contract

| Scenario | Expected status | Status |
|---|---|---|
| Successful deletion | Any `2xx` (client currently accepts the full `2xx` range, does not special-case `200` vs `204`) | `[ASSUMED]` |
| Any other outcome (auth failure, server error, account not found, etc.) | Any non-`2xx` — the client treats every non-`2xx` response identically, surfacing a generic `AccountDeletionException` with the raw status code; no error-body parsing is assumed or attempted | `[ASSUMED]` |

**Critical assumption — synchronous, same-operation, hard delete:** a `2xx` response is assumed
to mean the deletion is already fully complete by the time the response is returned — both:

1. the Keycloak user record (identity/login credential), **and**
2. any backend-side account data associated with that user (e.g. a linked PostgreSQL user row,
   any account-scoped backend state)

...are hard-deleted in the same operation, synchronously, before the `2xx` response is sent.
`[ASSUMED]` — not yet confirmed whether Keycloak-side and backend-side deletion are actually
coupled in one atomic operation, or whether this needs to be two separate calls / an
async job with a distinct completion signal.

**No grace period, no recovery, no soft-delete.** The client's UX (`AccountSection`'s delete
confirmation dialog, Plan 07-06) presents this as immediate and irreversible — there is no
"your account will be deleted in 30 days, cancel anytime" grace window on the client side.
`[ASSUMED]` — if the backend actually implements a grace/recovery period, or a soft-delete
(tombstone) pattern instead of a hard delete, the client's copy and confirmation flow would need
to change to avoid misleading the user about irreversibility.

## Client-side isolation point

The entire client-side implementation of this contract lives in one method:
`AuthNotifier.deleteAccount()` in `lib/features/auth/providers/auth_provider.dart`. If any
assumption above turns out to be wrong once Tomris confirms the real contract, updating the
client to match is a one-file change — no other file constructs this request or interprets its
response.

On a confirmed `2xx`, the client currently:

1. Clears the in-memory `_idToken`.
2. Deletes the persisted refresh token and cached email from secure storage.
3. Transitions `AuthState` to `AuthState.unauthenticated()`.
4. Records an `account_deletion` consent-history entry (local-only, `consent_records` table —
   this is unrelated to whatever the backend does, and always happens regardless of what the
   backend's deletion actually entailed).

On any non-`2xx`, the client throws `AccountDeletionException(statusCode)` and leaves all local
state (session, secure storage) completely untouched — the caller (`AccountSection`) catches
this and shows an inline error, keeping the user signed in.

## Open questions for Tomris

1. Is Keycloak-user-deletion and backend-account-data-deletion actually one atomic
   operation today, or two? If two, does the client need to call two endpoints, or does the
   backend already orchestrate both from this single `DELETE /me/account` call?
2. Is there any backend-side grace/recovery period today (even if the client doesn't currently
   expose it)? If so, the client's "immediate and irreversible" copy needs to change.
3. Does a successful deletion return `200` with a body, or a bare `204`? (Client currently
   doesn't care, but worth confirming for API-doc completeness.)
4. What does a `401`/`403` actually mean here in practice — expired/revoked token, or something
   else? Should the client attempt a token refresh before treating it as a hard failure?
