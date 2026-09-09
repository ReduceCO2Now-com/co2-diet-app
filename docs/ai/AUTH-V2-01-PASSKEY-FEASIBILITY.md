---
status: EVALUATION — reassessment complete, no implementation
requirement: AUTH-V2-01 (Passkey support)
phase: 10 (Post-Launch Enhancements) — satisfies SC-2
author: Ali (Flutter client)
date: 2026-09-09
supersedes: the "Flutter ecosystem not mature as of Jan 2026" note in REQUIREMENTS.md
---

# AUTH-V2-01 — Passkey feasibility, reassessed

> Phase 10's success criterion 2 asks that passkey feasibility be re-evaluated
> against the current Flutter ecosystem before implementation is scheduled.
> This is that reassessment. It recommends no Flutter work.

---

## Summary

**The January 2026 verdict — "Flutter ecosystem not mature" — is no longer the
right question.**

It assumed passkeys would be implemented *in the app*, via a Flutter plugin
wrapping the platform WebAuthn APIs. Under this project's actual auth
architecture they would not be. Authentication happens through the **system
browser** via OIDC Authorization Code + PKCE (`flutter_appauth`, Phase 7), so
the WebAuthn ceremony belongs to the browser and to Keycloak — the Flutter app
never touches it.

Consequently:

- **No Flutter package is needed.** Not `passkeys`, not `flutter_passkey_service`,
  not any of them. The client is already passkey-compatible because it delegates
  to the browser.
- **Keycloak 26.4 ships passkeys natively**, and explicitly states *"there is no
  need to modify default browser flow to use passkeys."*
- **AUTH-V2-01 is therefore a realm-configuration task**, not a client
  implementation task — two settings in the Keycloak admin console.
- **It is nonetheless blocked**, but on infrastructure rather than ecosystem
  maturity: passkeys are domain-bound, and this project has no deployed domain.

---

## Why the original assessment pointed the wrong way

The requirement reads: *"Passkey support (Flutter ecosystem not mature as of
Jan 2026 — reassess for v1.1)."* That framing presumes the client implements
WebAuthn. Two things make that false here.

**Phase 7 locked browser-based OIDC.** `AuthNotifier` calls
`flutter_appauth`'s `authorizeAndExchangeCode` with the Keycloak issuer, client
id and redirect URI. The login UI is a Keycloak page rendered in the system
browser — deliberately not a webview, which cannot observe credentials.

**WebAuthn is a browser capability.** When Keycloak's login page offers a
passkey, the browser performs the ceremony with the platform authenticator. The
app sees only the authorization code that comes back. It cannot tell whether the
user typed a password, used Face ID, or tapped a YubiKey — and it does not need
to.

So the maturity of Flutter's passkey plugins is irrelevant to whether *this*
app can support passkeys. It would matter only if the app authenticated
in-process, which it deliberately does not.

---

## The Flutter ecosystem, assessed anyway

Recorded for completeness, and in case a future phase moves auth in-process
(it should not — see Risks).

| Package | State (Sept 2026) | Verdict here |
|---|---|---|
| `passkeys` (corbado.com) | v2.22.3, released 22 days ago, verified publisher, BSD-3, 150 pub points, 112 likes, **167k weekly downloads**, iOS/Android/macOS/Web/Windows | Genuinely mature now — the Jan 2026 judgement would not survive today. **Still not needed.** |
| `flutter_passkey_service` | Updated April 2026; unifies iOS AuthenticationServices and Android Credential Manager | Not needed |
| `web_authn_web` | Web-only, Feb 2026 | Not applicable |
| `passkeys_windows` | Windows implementation, July 2026 | Not applicable |

The ecosystem question has resolved in the affirmative since January. It simply
no longer decides anything for this architecture.

**Every one of these requires a WebAuthn-compliant relying-party server.** This
project has no auth server of its own; Keycloak is the identity provider. So
adopting a Flutter package would mean either standing up a second WebAuthn
server beside Keycloak, or using a hosted service such as Corbado — both of
which contradict `AUTH-10` ("all auth via Keycloak OIDC + PKCE") and
`PROJECT.md`'s self-hosted-only constraint.

---

## What Keycloak 26.4 provides

Passkeys were preview from v23.0 and became official in 26.4 (announced
September 2025). Two modes:

- **Conditional UI** — the passkey prompt integrates into the login form where
  the platform supports it.
- **Modal UI** — a "Sign in with Passkey" button, works across all major
  browsers, and covers hardware keys needing a PIN or biometric.

Configuration is two steps, both in the admin console:

1. Enable **Authentication → Policies → WebAuthn Passwordless Policy**
2. Optionally set **Authentication → Required Actions → WebAuthn Register
   Passwordless** as a default

Users can also register a passkey themselves from the Account Console. Keycloak
supports passkeys either as passwordless first factor or as a phishing-resistant
second factor.

---

## The real blocker: no domain

Passkeys are bound to a domain. That is the property that makes them
phishing-resistant, and it is not optional.

| Requirement | Status here |
|---|---|
| An HTTPS domain the organisation controls | **Absent.** `KeycloakConfig.issuer` is `[ASSUMED] http://localhost:8081`; `BackendConfig.baseUrl` is `[ASSUMED] http://localhost:8080`. Neither is deployed |
| Apple App Site Association at `/.well-known/apple-app-site-association` | Not hosted — no domain to host it on |
| Digital Asset Links at `/.well-known/assetlinks.json` | Not hosted |
| iOS Associated Domains entitlement (`webcredentials:`) | **No `.entitlements` file exists in `ios/Runner/` at all** |
| A deployed Keycloak realm | Absent — the realm export is still outstanding from the backend owner |

Note the asymmetry with the ecosystem question. Flutter's plugin maturity
resolved itself by waiting. **This will not.** No amount of elapsed time
produces a deployed domain; someone has to deploy one.

The entitlements gap is worth calling out separately: even the
browser-delegated flow benefits from Associated Domains for credential
autofill, and adding it later is an Xcode signing change, not a code change —
so it should be scheduled alongside the first real deployment rather than
discovered during it.

---

## Recommendation

**Do not schedule Flutter work for AUTH-V2-01. Reclassify it as an
infrastructure and configuration item owned by the backend workstream.**

Sequence, once a domain exists:

1. Deploy Keycloak on a real HTTPS domain (already required for Phase 7's
   `[ASSUMED]` values to become real — this is not extra work)
2. Enable the WebAuthn Passwordless Policy in the realm
3. Host `assetlinks.json` and the AASA file at that domain
4. Add the iOS Associated Domains entitlement and re-sign
5. Test the existing login flow — **no client code should need changing.** If it
   does, that is the finding, and it belongs in a new phase

Step 5 is the whole test. If passkey login works through the unmodified
`flutter_appauth` flow, AUTH-V2-01 is met with zero Flutter changes and the
requirement can close.

**Estimated Flutter effort: zero.** Estimated verification effort: one device
session against a deployed realm.

---

## Risks and caveats

**Keycloak asks for compatibility feedback.** The 26.4 announcement explicitly
requests reports across "different combinations of operating systems, browsers,
password managers and hardware keys", which is a maintainer's way of saying the
matrix is not fully proven. Budget a real device pass rather than assuming it
works — consistent with this project's experience that device testing finds
what nothing else does.

**Do not move auth in-process to "get passkeys".** It would mean a second
WebAuthn server or a hosted third party, contradicting `AUTH-10` and the
self-hosted-only constraint, and would replace a browser-delegated flow that
cannot see credentials with one that can. The current architecture is the
reason passkeys are nearly free here; abandoning it to adopt a passkey plugin
would be backwards.

**iOS 18+ / macOS 15+** apply to the `passkeys` package's PRF extension. Not
binding on this project, since no package is being adopted — recorded so the
number is not mistaken for a platform floor on the Keycloak route.

**This is untested.** Every claim about the client needing no changes follows
from the architecture and from Keycloak's own documentation. Nothing here has
been run against a live passkey-enabled realm, because none exists. Treat the
recommendation as well-grounded but unverified.

---

## Effect on Phase 10

This satisfies **SC-2**. **SC-1** — a prioritised v1.1 shortlist derived from
post-launch user feedback and store review signal — remains unmet and cannot be
met before launch: there is no store listing, no users and no reviews. The
19 requirements under `## v2 Requirements` are the raw material, but the
criterion asks for prioritisation *signal*, which only shipping produces.

Phase 10 therefore stays open, correctly, waiting on launch rather than on
effort.

---

## Sources

- [pub.dev — passkeys (corbado.com)](https://pub.dev/packages/passkeys)
- [Keycloak — Passkeys support in 26.4](https://www.keycloak.org/2025/09/passkeys-support-26-4)
- [Keycloak — Configuring authentication (WebAuthn policies and required actions)](https://docs.redhat.com/en/documentation/red_hat_build_of_keycloak/24.0/html/server_administration_guide/configuring-authentication_server_administration_guide)
- [Keycloak Passkeys & WebAuthn guide](https://skycloak.io/blog/keycloak-passkeys-webauthn-complete-guide/)
- [pub.dev — flutter_passkey_service](https://pub.dev/packages/flutter_passkey_service)
