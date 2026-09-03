## Why

The library says how a change proceeds and is silent on where it runs.
`rules/development-workflow.md` describes a change's lifecycle — propose,
review, commit the plan, derive tests, implement, verify, review the diff —
and says nothing about which branch that happens on, which working tree, or
what becomes of anything the session learned when the session ends. That was
adequate while work happened one session at a time. It is not adequate now:
`commerce-ops` carries four live worktrees under `.claude/worktrees/`, each a
parallel session, and every rule governing them was written into that
project's own `AGENTS.md` rather than into the library.

Those rules were paid for. Recorded in `commerce-ops` itself:

- A session reported "Docker isn't available in this WSL setup" while
  `commerce-ops-postgres-1` was up and serving on `127.0.0.1:5432`.
- A worktree that had never been given a `.env.test` made the integration
  tier skip in its entirety; `pre-push` reported `Passed`; a pull request
  merged claiming a tier that had not run.
- A database with migrations applied but no seed failed four tests, each of
  which said so in its own assertion message, and the failures were reported
  as pre-existing.
- Seven `commerce_ops*` databases now sit on the container; three are orphans
  whose worktrees are gone. Two live worktrees carry no `.env.test` at all,
  so the tier fails open in both as of today.

Every one of those is a general hazard wearing project-specific clothes. The
first is "check the shared service before concluding it is absent"; the
second is "a green that ran nothing is worse than a red"; the third is
"provisioning is not one step"; the fourth is "what a session allocates,
something must reclaim." None is reusable where it currently lives, so the
next project this library initializes will pay for them again.

The first three are this change's. The fourth is `add-namespace-reclamation`'s
— see Decision 5 for why it is a separate change rather than a section of
this one — and it is named here because it is part of the same evidence and
because a reader should not have to infer that its absence was deliberate.

The same applies to what `commerce-ops` got right and cannot share: that
`openspec archive` is the last commit before the merge, that two sessions
writing to one database produce failures that read as defects and are not,
and that `docs/deferred-work.md` exists because *"a deferral recorded only
inside a change moves to `openspec/changes/archive/` when that change ships,
and stops being findable."* That reason is better than the one usually given
for such a file — it is the change *succeeding*, not the session dying, that
hides the deferral — and it is currently reachable only by reading one
project's README.

## What Changes

Three new fragments under `rules/`, cut by **applicability** rather than by
time. A cut by time — "session start", "session end" — would put unrelated
concerns in each fragment: tearing down a worktree is the other half of
setting one up, while opening a pull request is a separate axis entirely.
Cut that way, a fragment cannot be attached without dragging in a concern the
project does not have. Cut by applicability, each can:

```
                              isolate  deliver  defer
ai-toolkit                       ✓        ✓       ✓
a project run serially           ·        ✓       ✓
a project with no remote         ✓        ·       ✓
a project not using OpenSpec     ✓        ·       ✓
```

`change-delivery.md` carries two preconditions, not one: a remote, and
OpenSpec. Decision 2 names OpenSpec directly instead of stating a
tool-neutral role with the tool bound beneath it, so the fragment is
un-adoptable by a project that has a remote and different specification
tooling. That is a narrowing of its axis, taken deliberately — and stated in
the fragment itself as an adoption precondition, not merely recorded here.
Recorded only here it would be archived with this change, and a project with
a remote and different specification tooling would meet the narrowing at the
archive step instead of before adopting.

- **`rules/worktree-isolation.md`** — one session, one branch, one worktree,
  created from the trunk, freshly fetched where the project has a remote to
  fetch from; the orientation a session
  owes on entering one; and the teardown that closes it.

  *Orientation* opens the fragment: before acting, a session reports where
  its change stands — its stage, whether its tests pass, and what is
  committed — derived from the repository rather than from recalled context.
  Where the worktree is not yet provisioned, the verification half is
  reported as not run and why, never as a pass: an unprovisioned tree's run
  skips and reports success, so an orientation that took it at face value
  would open the fragment with the very false green the next rule exists to
  reject.
  It lives here rather than in a fragment of its own because the reason it
  matters is the isolation: a session entering a worktree is resuming work
  some other session left there, and the working tree is the only thing that
  knows how far it got.

  The fragment scopes its rules before stating them: they govern a worktree
  in which a session is doing a change's work, not one whose lifetime is
  bounded by the single act of tooling that created it and which carries no
  trunk-bound branch. The discriminator is the branch and the lifetime rather
  than the contents — a worktree made from a committed ref carries that
  commit's change artifacts, so "holds no change" would exclude nothing. Unscoped they would bind a cold-run check's throwaway
  worktree — which `agent-authoring` in this very repository mandates — and
  that worktree holds no change, so it satisfies neither route of the
  teardown gate and becomes unremovable under a rule written to prevent
  exactly that. It is the same two-rules-on-one-act collision the
  deferred-work fragment cures against `development-workflow.md`, and the
  charitable reading that a scratch tree obviously is not a session's is the
  one this change refuses everywhere else.

  Creation and teardown stay together because they are two ends of one
  invariant: a project that adopts creation alone accumulates worktrees and
  branches with nothing reporting it. The namespace a session allocates is
  the part teardown here does not reclaim — that is Decision 5's subject —
  and the three orphaned databases on the `commerce-ops` container are what
  that separate change is for.

  The fragment also owns what `git worktree add` does not give you. A
  worktree carries tracked files only — no `.env`, no installed dependencies,
  no build cache — and no share of any external state the project's
  verification touches. Where the project runs a shared service, a session
  takes its own namespace within it, named deterministically after its
  worktree, in whatever form the project's own naming constraint requires.
  The obligation is general; the service, the naming shape and the
  provisioning commands are the project's binding.

  **This fragment allocates and does not release.** Reclaiming a namespace
  once its worktree is gone is specified by a separate change — see
  Decision 5 — and the fragment says so rather than leaving the gap to be
  read as an oversight.

  Provisioning's reason is attached rather than assumed: the false green, not
  convenience. An unprovisioned worktree does not fail loudly, it skips,
  reports success, and gets merged.

- **`rules/change-delivery.md`** — begin only where the change's verification
  has run and passed against the branch head; then archive, commit, push,
  open a pull request, let CI run, and wait for the operator's confirmation
  of the merge before treating anything as delivered. The entry gate is not
  decoration: the fragment is adoptable alone, so a sequence opening with the
  archive commit and stating no precondition sanctions delivering work
  nothing verified. The archive is the last commit before
  the merge, so the change's record ships inside the pull request reviewing it
  rather than being written to `main` outside any review. The fragment names
  no worktree and works from any branch; where `worktree-isolation` is also
  attached, the merge confirmed here is what satisfies that fragment's
  teardown gate.

- **`rules/deferred-work.md`** — one change per session, and what to do when
  a second one surfaces. Where the current change is blocked on it: record
  the dependency and the wait in the current change's own artifacts, offer a
  proposal-only branch for the dependency and nothing more, and recommend
  continuing in a parallel session. Where it is independent: a proposal-only
  branch, or an entry in `docs/deferred-work.md`. The load-bearing clause is
  the recording, not the branching — a dependency held only in conversation
  is indistinguishable, to the next session, from a change that is merely
  unfinished.

### How the fragments are phrased

`commerce-ops` derived a selection principle while revising its own worktree
rules, and it applies here: **a rule states an action; a defect appears only
as the reason that action matters; and the rule is phrased so the durable
half is the instruction and the perishable half is the consequence.** A rule
built around today's damage goes stale when the damage is fixed, and then
competes with the fix. A rule built around the action survives being enforced
harder. Each fragment is written to that shape.

### Two decisions the fragments make about themselves

- **None is inlined by `scripts/project-init`.** They reach a project by `@`
  import or by hand. `project-init` hard-codes one fragment path and one
  marker (`ai-toolkit:development-workflow`); teaching it to manage N blocks
  is `update-managed-block`'s territory, and that change is itself blocked on
  three open questions. Coupling a new fragment set to a blocked tooling
  change would strand both.

- **None declares `version:`.** `toolkit-structure` requires a version of a
  fragment "that is inlined into a consuming project", and `project-bootstrap`
  owns when it increments — an obligation scoped to inlining. A version on a
  fragment nothing inlines is a number no requirement obliges anyone to
  increment, which is how it goes stale. Adding one later, if a fragment is
  ever inlined, is a frontmatter edit `rules/README.md` already says does not
  itself constitute a body change.

## Decisions

Resolved from the proposal's first round of open questions.

1. **Worktrees live inside the repository, at one fixed path.** Adopting
   `commerce-ops`' `.claude/worktrees/` rather than a sibling directory: a
   session's working directory is the project, so a path outside it is
   awkward for exactly the tooling that creates these worktrees. Verified:
   `git status` does not surface a registered worktree as untracked, so the
   arrangement works today.

   It carries two guards the fragment states, because `commerce-ops` meets
   one of them by luck and not the other:

   - **The worktree root is ignored.** `commerce-ops` does not ignore
     `.claude/worktrees/`. Ignoring it costs one line and buys three things:
     protection from `git clean -xdff`, and automatic exclusion from every
     tool that reads the ignore file — ripgrep and ruff among them.
   - **Every recursive tool that does not read the ignore file is scoped
     explicitly.** `commerce-ops`' pytest is safe, but by having
     `testpaths` set for unrelated reasons; its `.dockerignore` does not
     exist, so `docker build .` from the root would send four copies of the
     source tree as build context. The failure this prevents is one
     worktree's run silently including every other worktree's copy of the
     project.

2. **`change-delivery.md` names OpenSpec directly.** Archiving is an OpenSpec
   act and the fragment says so, rather than stating a general obligation and
   binding archiving beneath it.

   The cost is a second precondition on the fragment's axis — it needs a
   remote *and* OpenSpec — and the applicability table above now shows it.
   The alternative was not a fourth fragment, as an earlier draft of this
   decision claimed, but the role-then-binding shape `development-workflow.md`
   already uses and `project-bootstrap` requires of it: one fragment, the
   obligation stated as a role, the tool named beneath. It is refused here
   because every project this library serves uses OpenSpec, and a role
   sentence whose binding is the only binding that will ever be written is
   indirection bought with nothing. Should a second specification tool ever
   appear, this is the decision to revisit, and the fragment is one paragraph
   from the other shape.

3. **Orientation does not get its own fragment.** Folded into
   `worktree-isolation.md` as its opening rule, for the reason given above.

4. **The overlapping `commerce-ops` work is finished and its findings are
   folded in.** `restore-the-skipped-integration-tests` (#149) and
   `close-out-the-skip-guard-findings` (#150) both merged; their selection
   principle and their orphan-database survey are used above.

5. **Reclamation is split into its own change, `add-namespace-reclamation`.**
   It is not deferred for lack of importance — it is the fourth hazard Why
   names, and three orphaned databases already exist. It is split because six
   review rounds established that it is the wrong *kind* of thing for this
   change to carry.

   Every critical and major finding across those six rounds landed in the
   reclamation requirement; the other ten produced none. The rule grew to a
   two-condition eligibility test, three failure branches, an ordering
   constraint and two classes of permanently uncollectable namespace — and
   the sixth round still found a hole: eligibility works by recomputing "this
   checkout's identity" from a name, but nothing required that identity to be
   *invariant across the checkout's own worktrees*, which is the property
   reconciliation depends on. A worktree carries tracked files only, so the
   recommended binding is unreadable from one; the natural repair gives every
   worktree its own identity, and reconciliation then collects only the
   current session's namespace while passing every check and reading as
   though it collects more.

   That is the shape of the problem, not an instance of it. Every predicate
   the rule turns on — eligible, claims, enumeration succeeded, this
   checkout's identity — is left to a project's binding, and prose can
   require that the predicates exist without making them agree with each
   other. An algorithm belongs in an artifact that can be executed and
   tested.

   `design.md` refused a provisioning script *for this change* on two grounds
   — it would make a documentation-only change depend on an executable that
   does not exist, and `scripts/` is outside this change's Impact — and then
   recorded that the script "is the right eventual answer and belongs in a
   separate change". Neither ground survives the move: a change scoped to
   `scripts/` has its own Impact, and `toolkit-structure` already admits
   shipped tooling there with a dependency-free harness to exercise it. The
   split is that refusal's own stated successor, brought forward.

   **What it costs, stated rather than waved.** `worktree-isolation.md` ships
   allocating without releasing, so an adopting project accumulates
   namespaces in the interval — which is what every project does today, so it
   is not a regression. And the scenario asserting that a project cannot
   adopt allocation without reclamation was part of why creation and teardown
   live in one fragment; it is restated as creation and its *gate*, which is
   the half this fragment still owns.

## Capabilities

### New Capabilities

- `session-workflow` — what the three fragments must say, and the seam
  between an obligation stated generally and the project-specific binding
  that satisfies it. A new capability rather than an extension of
  `project-bootstrap`, which is about a bootstrapping tool and owns the
  workflow fragment's content only as a consequence of inlining it. Nothing
  here is inlined and nothing here is bootstrap.

### Modified Capabilities

None. `toolkit-structure` already permits any number of fragments under
`rules/` and already fixes their frontmatter form; declining to declare
`version:` on a non-inlined fragment is that requirement's plain reading, not
an amendment to it. `project-bootstrap` is untouched because `project-init`
is untouched.

That claim constrains the delta, and the delta is written to hold it. The
frontmatter requirement governs what a session-scoped fragment declares — the
part this capability owns — and states no obligation on what any tool may
inline, because that question is `project-bootstrap`'s and an obligation with
two owners is the defect `toolkit-structure` already legislates against.

## Impact

- `rules/` — three new files. `rules/README.md` describes fragments as a
  class and enumerates none, so it needs no change.
- `openspec/specs/session-workflow/spec.md` — new, via the change's deltas.
- `rules/development-workflow.md` — **unchanged**, deliberately. It is
  stranded at `v1` in `commerce-ops` (verified) and reported so in two other
  projects; adding to its body would make `update-managed-block` reconcile a
  larger diff than it was scoped against.

  `deferred-work.md` nonetheless *references* it, and must. Its "Incremental
  development and scope control" rule requires out-of-scope work to become a
  separate proposed change, and every bootstrapped project already carries
  that inlined. Left unreconciled, such a project would hold two standing
  constraints on one act — one permitting a deferred-work entry, the other
  requiring a proposal — and no session could satisfy both. The fragment
  therefore states the seam: a deferred-work entry *is* that separate
  proposed change, recorded rather than opened. Stating a seam is not editing
  the fragment on the other side of it, so the unchanged claim holds.
- `scripts/` — unchanged. Nothing here is executable.
- `tests/` — no existing case or helper is modified; new cases are added
  under `tests/cases/` by the test author task 5.1 dispatches.
- `docs/deferred-work.md` — created. This repository has none, and task 6.1
  needs one so that this change's own deferrals are not archived out of sight
  along with the change that recorded them.
- `openspec/changes/add-namespace-reclamation/` — a sibling change carrying
  reclamation, proposed alongside this one. This change does not depend on
  it: `worktree-isolation.md` is complete and adoptable without it.
- `commerce-ops` — the evidence base and the first consumer. Its `AGENTS.md`
  "Working in a git worktree" section and its README's "Local Postgres"
  section become the *binding* for `worktree-isolation` rather than the only
  place the knowledge exists. Whether that section is then trimmed to the
  binding is that project's change, not this one.

## Open questions

None. All five are resolved above.

## Status

Complete package: `proposal.md`, `design.md`, `specs/session-workflow/spec.md`
and `tasks.md`. Ready for review.

Test authoring is **not** exempt. The delta below states properties of three
files that a shell case can check by reading them — that each declares
`kind: standing-constraint` and no `version:`, and that no fragment's text
requires a sibling fragment to be present — so the circumstance
`tests/README.md` records for its two prior exemptions does not apply here.
`openspec-test-writer` is dispatched normally, after the review verdict
permits proceeding and the approved plan is committed.
