# Next session — execution plan

**Written:** 2026-09-08, end of session
**Purpose:** so tomorrow is execution, not deciding. Everything below is settled
except where it says otherwise.

---

## State as of now

All 602 tests pass, `flutter analyze` is at its 66-issue baseline, the working
tree is clean, no pending todos, everything pushed to `main` at `736fe15`.

Roadmap audit — every phase directory has plans == summaries, so there are **no
execution gaps** anywhere in 1–10:

| Phase | Plans | Summaries | Verification | Checkbox |
|---|---|---|---|---|
| 01 Foundations | 7 | 7 | ✓ | `[x]` |
| 02 Catalog | 7 | 7 | — | `[x]` |
| 03 Barcode | 5 | 5 | ✓ | `[x]` |
| 04 Meal logging | 13 | 13 | — | `[x]` |
| 05 Full local app | 19 | 19 | ✓ | `[x]` |
| **06 Onboarding/Legal** | **10** | **10** | **✓** | **`[ ]` ← wrong** |
| 06.1 Onboarding reorder | 2 | 2 | ✓ | complete |
| 07 Keycloak auth | 8 | 8 | ✓ | `[x]` |
| 08 Encrypted backup | 0 | 0 | — | `[ ]` |
| 09 Reference data | 8 | 8 | — | `[x]` |
| 10 Post-launch | 0 | 0 | — | `[ ]` |

---

## Task 1 — Close Phase 6 (do this first)

**It is finished and the record says otherwise.** All ten plans complete, its
`06-10` accessibility summary records completion on 2026-08-05, and Phase 06.1's
device checkpoint passed 8/8 on 2026-09-07. Only the bookkeeping is stale.

Three edits in `ROADMAP.md`:

1. Line 23 — tick the phase: `- [ ]` → `- [x]`, and append `(completed 2026-09-07)`.
2. Line 327 — the status row currently reads
   `| 6. Onboarding, Legal & Pre-Submission | 10/10 | Code complete; awaiting 06.1-02 device pass |  |`
   → `| 6. Onboarding, Legal & Pre-Submission | 10/10 | Complete | 2026-09-07 |`
3. Line 23's summary text still says *"Mode Choice"* and *"equal-weight Mode
   Choice audit"*. ONBD-03a superseded that on 2026-09-07 — replace both with
   *"connectivity choice"*. The amendment note in the Phase 6 detail section
   already explains it; the summary line just never caught up.

**Why first:** this is what actually gates "v1 complete". Phase 8's status is
irrelevant while Phase 6 reads unfinished for a reason that isn't true.

---

## Task 2 — Phase 8: build what can be built

**Decision (2026-09-08): Phase 8 proceeds.** My recommendation had been to
cancel it as superseded by PRIV-01–04; Ali chose to keep it. Recorded so the
reasoning on both sides survives.

### The constraint that shapes the plan

There is no backend to build against. Tomris's `origin/main` has `catalog`,
`ingestion`, a stub `co2` module and the Spring bootstrap — **no backup module,
no endpoint, no user-data storage**, and `docs/backend-architecture.md` §13
still leans toward user-cloud export instead. So the server half cannot be
written, let alone verified.

What *can* be built is everything on the client side of the boundary, plus a
written contract for the half that can't.

### Proposed plan split

**08-01 — Client-side encryption of the backup blob.** Encrypt the existing
export zip (PRIV-01/02 already produce it) with a key derived from the user's
credentials, so the artifact is opaque before it goes anywhere. Fully buildable
and fully testable today, with no backend involved. Delivers AUTH-09's actual
privacy property — "the server cannot read it" — independent of whether a
server ever exists.

**08-02 — Backend contract specification.** A written API proposal for push and
pull of the opaque blob, in the same shape and tone as
`docs/backend-contracts/gdpr-account-deletion.md`: `[ASSUMED]` frontmatter,
endpoint, method, auth, request/response, error cases, and the explicit note
that it is a proposal for Tomris to confirm or reject, not an agreed contract.

**08-03 — Client push/pull behind a flag, default off.** Implemented against
08-02's contract, using `BackendConfig.baseUrl`. Cannot be end-to-end verified
until a server exists — the plan must say so, and the flag must default off so
nothing ships enabled against a nonexistent endpoint.

### Honest limits to write into the phase context

- **08-03 cannot be device-verified.** Every other phase in this project was.
  Three defects tonight survived precisely because they weren't verified against
  reality; a phase that structurally cannot be is a known risk, not an oversight.
- **The contract may be rejected.** If Tomris confirms user-cloud export,
  08-02 and 08-03 become documentation of a road not taken, and 08-01 remains
  valuable on its own.
- **08-01 is the piece that survives either outcome** — encrypt-before-export is
  useful whether the blob ever reaches a server or only ever reaches the user's
  own iCloud.

### To raise with Tomas

Not permission — information: Phase 8 is proceeding client-first, and a written
backend contract will follow for Tomris. Ask whether the encrypted-blob-vs-
user-cloud decision has moved, because it determines whether 08-03 has a future.

---

## Task 3 — Phase 10

Leave as-is: a v1.1+ placeholder with no v1 requirements, deliberately unplanned.
Nothing to decide. It is correctly `[ ]` because it is genuinely not started, not
because it is stalled.

If the milestone is concluded, Phase 10 carries forward into the next one rather
than closing with this one.

---

## Task 4 — Milestone conclusion (only after 1–3)

Once Phase 6 is ticked and Phase 8 has a plan directory, `/gsd:complete-milestone`
has a clean run. Before invoking it, the roadmap should read:

> 9 of 10 phases delivered; Phase 8 in progress client-first pending a backend
> contract; Phase 10 deferred as post-launch scope.

---

## Not roadmap work, but due this week

- **Video** — script drafted at `co2diet-video-script-v1.md`; blocked on the
  Project 2042 channel invitation being reissued (expired; Editor-limited cannot
  reissue it, so it needs the channel owner).
- **Drive artifacts** — survey responses, interview notes and the prioritised
  change list. These are the evidence for the research phase and are still
  uncollected.
- **Portfolio** — 6,000 words, due 18 September. The largest remaining item by
  far, and the only one with an external deadline.
