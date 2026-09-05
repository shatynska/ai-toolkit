## Why

The library publishes its session obligations as three fragments —
`worktree-isolation.md`, `change-delivery.md`, `deferred-work.md` — and they
are in force in no project.

That is the delivery path, not neglect. `rules/` has no loader; the
`@`-import path is machine-local and, being expanded eagerly at load, costs
exactly what inlining costs while resolving only where this repository sits at
one particular path. The one mechanism that puts a fragment into a project is
`scripts/project-init`, which inlines a fragment's body into `AGENTS.md` under
a managed block and reads one hardcoded path:

```
FRAGMENT="$TOOLKIT_ROOT/rules/development-workflow.md"
```

So the workflow fragment reaches projects and the session fragments do not.
`commerce-ops` shows what follows: it re-derived the same obligations by hand,
below the managed block — worktree provisioning, the `.env` a worktree does not
inherit, the skipped tier that reports success, a database per worktree. The
same rules, written twice, already disagreeing.

**Reading the two copies against each other turned up three defects in what the
library currently says.**

*The delivery sequence is wrong for a project that deploys.* `change-delivery.md`
places the archive commit last on the work branch, inside the pull request that
carries the work. Where merging to the trunk triggers a deploy, that writes
"this change shipped" at the moment the work was merely merged, and writes it
identically where the deploy that followed failed.

*A change's stage is not derivable.* The rules require a session to report where
its change stands, derived from the repository rather than from recalled
conversation. But three gates leave no trace: dispatching a plan review,
receiving its verdict, and receiving a code review's findings all end in the
conversation. A session that dispatched a review and then ended is
indistinguishable from one that never dispatched, so the next session either
re-dispatches a review that already passed or proceeds on a verdict that never
existed.

*Identified work is routed to the wrong file.* `deferred-work.md` directs an
independently identified change to `docs/deferred-work.md`. That file exists in
this repository and in `commerce-ops`, and in both it holds something else: what
the project has deliberately **not** done, deleted when it stops being true. An
identified change is deleted when it is archived. `commerce-ops` grew the second
artifact separately rather than conflating them.

**And the separation itself is what costs the most.** `session-workflow`
requires each of the three to be adoptable without the others, with every gate
checkable inside the fragment stating it and no fragment naming a sibling. That
property is bought with conditionals — *where the project has a remote*, *a
project that runs sessions serially*, route-one-or-route-two teardown, a
paragraph excluding throwaway checkouts, a clause reconciling two fragments that
may not refer to each other — and it costs roughly 20 KB across three files that
still cannot be adopted together without repeating themselves.

The expensive property was never universality. It was independence.

## What Changes

- **`rules/development-workflow.md` reaches version 3, absorbing the session
  obligations.** One document, inlined by the mechanism that already works. It
  states a session's branch and working tree, provisioning, the report of where
  a change stands, the stage vocabulary that report names, delivery through pull
  requests, teardown, and the recording of work that outlives the session —
  alongside the spec-driven gates it already carries.

- **The three session fragments are removed.** Their obligations survive in v3;
  their conditionals do not. Keeping them would mean every future rule change
  made twice, in texts that already disagree about where the archive commit
  goes.

- **A change's stage is named from a fixed vocabulary of three families**, and
  every stage is derivable from the repository. `plan:` and `build:` each carry
  their own review and their own relation to tests — `plan:tests` is tests being
  written from the delta specs, `build:verify` is tests being run against the
  implementation. `ship:` is where a session waits, and is a family of its own
  because the only actionable content of a waiting state is which one it is.

- **A review's verdict, and what was done about it, is recorded in the change's
  artifacts.** This is what makes the middle of the vocabulary derivable. The
  recording is the dispatching session's obligation; `change-review` owns the
  reviewer's output contract and is not amended.

- **Delivery is at least two pull requests, unconditionally.** The work merges
  and deploys; the deploy is confirmed healthy; the change's intended effect is
  confirmed in production or the gate waived; then the record is archived through
  a pull request of its own. Two is a floor: a failed deploy, or a deployed change
  whose effect is absent through a defect in it, produces a fix that reaches the
  trunk the same way any work does — its own pull request, its own review, its own deploy — so the record's
  is the *last* of a change's pull requests rather than the second. A healthy deploy reports that new code is running and reports nothing
  about whether the change did what it existed to do, and those fail separately.

- **The production-confirmation gate carries two waivable classes, stated in
  advance.** A gate asking what to look at cannot be answered by a change with
  no externally observable effect — a refactor, a dependency bump — nor by one
  whose observation was made and whose effect turned out absent because the
  change was the wrong change. Neither is a defect to re-fix, and neither can
  use the abandonment route, whose record must assert that work is unwanted when
  this work is merged and running. So each is a named class the operator waives,
  the waiver is recorded, and the record proceeds on it. Without them a
  compliant session stalls holding a branch set and a working tree that no route
  can remove — and a change can be archived as shipped with its effect confirmed
  absent, which the waiver is what records.

- **The report of where a change stands is a fixed row, not a paragraph**, given
  on entering a working tree and again as the last thing said before stopping.

- **Identified work is routed to `docs/change-queue.md`**, distinct from
  `docs/deferred-work.md`, with each artifact's deletion condition stated.

- **Four rules are taken from the two projects already running this workflow**,
  where they were found by hand and are absent from the library: a check that
  did not run is never counted as one that passed, so continuous integration is
  configured to fail on a dependency it cannot reach rather than skip; a commit
  or push hook that was never installed is not an authority a completion claim
  may rest on; a secret is kept out of version control by the ignore file rather
  than by vigilance at commit time; and **the project states its test command and
  its test-path glob** in its own conventions, because the fragment's own
  test-authoring step dispatches an author that requires both and the fragment
  never asked for them.

  Two of these reach past the fragment's own text: adopting v3 obliges a project
  to configure its continuous integration and to state two values in its
  conventions file. That is a wider obligation than the other bullets carry, and
  it is named here rather than left to be discovered at adoption.

- **One thing does not go into v3: the database.** `rules/development-workflow-database.md`
  binds v3's service-neutral provisioning and namespace obligations to a
  containerized Postgres — the running container, a database per working tree,
  migrate-is-not-seed, and that integration tests run against the real engine
  rather than a double. v3 states the obligation; the fragment states the
  binding, exactly as v3 already states a role and names its Claude Code binding
  beneath it.

- **v3 assumes a remote, a forge that reports a pull request's merged state,
  CI, and a deploy triggered by merging to the trunk, and states no conditional
  for their absence.** Every project this library is written for has all four,
  and teardown's merge clause rests on the forge by name. This
  repository does not deploy and is deliberately not a consumer of its own
  workflow fragment; should a library-shaped consumer need one, it gets a
  publication of its own rather than a conditional in this one. The conditionals
  removed here are the same ones that made the three fragments expensive.

- **The tooling that installs any of this is a separate change and follows.**
  `scripts/project-init` will gain a workflow-variant selection so the database
  fragment can be written as a second managed block. In the interval v3 reaches
  projects exactly as v2 does, and the database fragment is pasted by hand.

## Capabilities

### Modified Capabilities

- `session-workflow` — its subject changes from three independent fragments to
  the session content of one inlined workflow fragment plus one binding
  fragment. Most requirements survive with their subject retargeted and their
  independence conditionals dropped; the requirement fixing the set at three is
  removed, as is the one forbidding a version on a fragment nothing inlines.
  Eight requirements are ADDED. Three — teardown, delivery and the change queue
  — are renamed replacements for REMOVED ones, replaced rather than modified
  because their existing scenarios encode properties this change drops. Five are
  genuinely new: the publication shape, the stage vocabulary, the branch
  topology and post-merge commit placement, the gates-that-did-not-run rules,
  and the database binding. Of the five MODIFIED requirements, three
  retarget their subject from the three fragments to the workflow fragment and
  drop the independence conditionals with their substance otherwise unchanged.
  Two gain substance: the report requirement adds the fixed row, the departure
  report and two cells, and the one-branch requirement adds a paragraph
  reconciling its rule with the further branches delivery creates.

`project-bootstrap` owns how the workflow fragment reaches a project — the
managed block, the version, the ordered sequence and the dispatch bound. Those
requirements hold over v3 unchanged, and the seam between the two capabilities
is stated in this change's design rather than left to be inferred. The second
managed block the database fragment needs belongs to the follow-up change.

## Impact

- `rules/development-workflow.md` — version 3.
- `rules/development-workflow-database.md` — new.
- `rules/worktree-isolation.md`, `rules/change-delivery.md`,
  `rules/deferred-work.md` — removed.
- `openspec/specs/session-workflow/spec.md` — substantially rewritten.
- `docs/change-queue.md` — new here, seeded with the follow-up change.
- `AGENTS.md` — its "Reaching a project" section carries the same two-path
  account as `rules/README.md`, and is made incomplete by the same fact.
- `rules/README.md` — its two-path account of how a fragment reaches a project
  (an `@` import, or a shipped tool reading it) covers neither route the
  database binding fragment takes: hand-pasting until the tooling change lands,
  and a second managed block after it.
- `openspec/changes/add-namespace-reclamation/proposal.md` — an active change
  whose text names `rules/worktree-isolation.md`.
- `tests/coverage.md` — names all three fragments being removed.
- `docs/deferred-work.md` — gains a cross-reference to the change queue, and its
  two entries argued from `add-session-workflow-fragments` name a fragment this
  change deletes.
- A `gate-log.md` at every change's root — the artifact the recording rules
  write to.
- `tests/` — the cases asserting the three fragments' content, their frontmatter
  and their fixed paths, plus the inlined-body and version-coupled cases that
  now cover a changed fragment.
- **Every project adopting v3** — its continuous-integration configuration must
  fail rather than skip on an unreachable dependency, and its conventions file
  must state a test command and a test-path glob. This is the only obligation in
  this change that reaches outside the library's own files.
- `commerce-ops` — first consumer. Adopting v3 means deleting its hand-written
  session rules and reconciling `docs/proposed-change-order.md` against
  `docs/change-queue.md`. That project's work, not this change's.
- `update-managed-block` (active, unstarted) — three projects hold the `v1`
  block and v3 widens the gap it exists to close. Not blocked by this change;
  made more valuable by it.

## Open questions

None blocking. Two things this change decides that are cheap to reverse before
it is applied: the database fragment's filename, and `docs/change-queue.md`
over adopting `commerce-ops`'s existing `docs/proposed-change-order.md`.

## Follow-up

`add-session-workflow-tooling` — `scripts/project-init` learns a workflow
variant, writes the database fragment as a second managed block, and reports
version skew per block. Recorded in `docs/change-queue.md` by this change.
