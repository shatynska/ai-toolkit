## Why

A session that runs a project's verification against a shared service takes
its own namespace within it — its own database, typically — so that two
parallel sessions do not write over each other. `add-session-workflow-fragments`
specifies that allocation and deliberately stops there: `worktree-isolation.md`
allocates and does not release. This change owns the release.

The gap is not theoretical. Seven `commerce_ops*` databases sit on that
project's container and three are orphans whose worktrees are gone. Nothing
drops them, because nothing was ever told to: the harness primitives that
create and remove a worktree know nothing about databases, so there is no
seam inside teardown for a release to attach to.

**This change exists as a separate change because of what six review rounds
established, and that history is the substance of the proposal rather than a
footnote.** Reclamation was specified in full inside
`add-session-workflow-fragments` and reviewed six times. Every critical and
major finding across those rounds landed in that one requirement; the other
ten requirements in the change produced none between them.

| Round | What the reclamation rule did wrong |
|---|---|
| 1 | Released every namespace no worktree claimed — including the project's own `commerce_ops` development database, named in its `docker-compose.yml`. Data loss, by an agent following the rule correctly. |
| 2 | Did not say *whose* worktrees the claim set was drawn from. |
| 3 | Made a sibling checkout's namespace *recognizable* but left it *eligible*; the rule still directed releasing a live one mid-run. |
| 4 | Fail-safed the name input and not the worktree enumeration; an empty claim set made every eligible namespace unclaimed, releasing every parallel session's live namespace at once. |
| 5 | Keyed a guard to what the repository was "known" to hold — knowledge no session can check — which on a reachable reading blocked release at the ordinary single-session teardown. |
| 6 | Recomputed "this checkout's identity" from a name, but never required that identity to be invariant across the checkout's own worktrees. A worktree carries tracked files only, so the recommended binding was unreadable from one; the natural repair gives every worktree a distinct identity, and reconciliation then collects only the current session's namespace while passing every check and reading as though it collects more. |

Read as six mistakes, that is an argument for a seventh round. Read as a
pattern, it is an argument for a different artifact. Reclamation is an
algorithm, and every predicate it turns on — *eligible*, *claims*,
*enumeration succeeded*, *this checkout's identity* — was left to an adopting
project's binding. Prose can require that those predicates exist. It cannot
make them agree with each other, and each round discovered exactly one
disagreement between two of them. The failure mode is consistent: a rule that
passes every stated check and silently does the wrong thing.

An operation that deletes data, whose correctness is a property of how four
predicates compose, belongs in an artifact that can be executed and tested.

## What Changes

- **Reclamation becomes shipped tooling under `scripts/`, not a rule
  fragment.** It computes the predicates rather than asking a project to
  supply them consistently, and `tests/` exercises it against the failure
  cases six review rounds enumerated — which is the value that history
  carries forward: they are a ready-made test matrix, not a list of
  embarrassments.

- **The design constraints already established are carried in, not
  rediscovered.** These survived review and are inputs to this change rather
  than open questions:
  - Reconciliation, not a remembered release step. A release step is correct
    only for sessions that perform it; three orphans measure how often that
    is. Reconciliation's correctness does not depend on sessions that have
    already ended.
  - Eligibility and the claim comparison are separate conditions, both
    required before a release. Scoping by naming form alone releases a
    sibling checkout's live namespace.
  - Eligibility is a property of the *name*, never "derived from a worktree
    that exists" — an orphan's worktree is gone by definition, so that
    phrasing makes the two conditions jointly unsatisfiable and nothing is
    ever released.
  - Every failure branch keys on an observable — whether an enumeration
    reported success — never on what the repository is "known" to hold.
  - Both enumerations fail safe, and so does an undeterminable name; a name
    determinably outside the scheme is retained silently, because an
    ambiguity reported for every namespace at every teardown trains a reader
    to ignore the report.
  - The worktree is removed before reconciliation runs, or the reclaiming
    session still claims its own namespace.

- **A namespace's identity component becomes computable rather than
  described.** This is round 6's hole and the reason a script answers where
  prose did not: the identity must be invariant across a checkout's worktrees
  and stable over time, and a linked worktree carries tracked files only. A
  tool resolves this once — the same value at allocation and at reclamation —
  instead of each project inventing a binding that may not.

- **Allocation may come with it.** `worktree-isolation.md` leaves
  provisioning to the project. A tool owning both ends is what makes the
  names it reclaims the names it created, which is the property the whole
  scheme rests on.

## Capabilities

### New Capabilities

- `namespace-reclamation` — allocating and reclaiming a session's namespace
  in a shared service: what the tool guarantees, what it refuses to touch,
  what it reports, and how it fails. Separate from `session-workflow`, which
  owns what the session-scoped *fragments* say and which explicitly stops at
  allocation.

### Modified Capabilities

None yet. `toolkit-structure` already admits shipped tooling at `scripts/`
and a dependency-free harness at `tests/`, so nothing there needs amending;
whether `session-workflow` needs a clause pointing at this capability is a
question for the design, not the proposal.

## Impact

- `scripts/` — the reclamation tool. Its `--help` is its portable interface,
  per `project-bootstrap`'s standing requirement for shipped executables.
- `tests/` — cases derived from the six rounds' failure matrix above.
- `openspec/specs/namespace-reclamation/spec.md` — new, via this change's
  deltas.
- `rules/worktree-isolation.md` — possibly one clause naming the tool, once
  it exists. Not this change's to write if `add-session-workflow-fragments`
  has not landed.
- `commerce-ops` — the first consumer, and the place the three existing
  orphans are. Whether the tool collects them or whether they are the stated
  manual cleanup is an open question below.

## Open questions

1. **One tool or two.** Allocation and reclamation in one executable, or a
   reclaimer alone that reads names a project's own provisioning created?
   One tool guarantees the names match; two lets a project keep its existing
   provisioning.
2. **What the identity component actually is.** It must be invariant across a
   checkout's worktrees, stable across a move or remount, and derivable from
   inside a linked worktree that carries tracked files only. A value recorded
   in the main checkout and read through the worktree's `.git` link is the
   obvious candidate and needs verifying, not assuming.
3. **Whether the tool is service-agnostic.** Postgres databases are the case
   at hand. A tool that shells out to a project-supplied list-and-drop pair
   is general and pushes the dangerous part back to a binding; one that
   speaks Postgres is safe and narrow.
4. **The three existing orphans.** Collected by the tool once it can
   recognize them, or declared a one-time manual cleanup? They predate any
   naming scheme, so recognizing them means matching on something looser than
   the scheme — which is the round-1 defect wearing a friendlier face.

## Status

Proposal only. `design.md`, the delta specs and `tasks.md` are absent pending
the questions above — each changes what the tool is, and answering them by
inference is what six rounds of this exact subject argue against.

This change does not block `add-session-workflow-fragments`, and that change
does not block this one. `worktree-isolation.md` is complete and adoptable
without reclamation; what an adopting project carries in the interval is
namespace accumulation, which is today's state in every project already.
