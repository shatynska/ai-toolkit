# Test manifest — `add-session-workflow-fragments`

Written by `ai-toolkit:openspec-test-writer` against the delta at
`specs/session-workflow/spec.md` as committed at `182f688`, before any
fragment was written.

This file is **not** an artifact the OpenSpec schema defines. It does not
appear among the context files `openspec instructions apply` surfaces, so
reaching it takes a deliberate look at this change root. `rules/test-manifest.md`
is the standing constraint that says so.

## Baseline

`bash tests/run.sh`, run at the repository root before any case was added:
**28 passed, 0 failed** (full suite, not scoped). Every failure reported
below is therefore attributable to the cases this pass added.

After adding the six cases: **29 passed, 5 failed**. The five failures are
all target-absent — `expected file to exist: rules/<name>.md` — which is the
expected state for a pass written before its target. Their assertions have
not executed and are therefore still unverified against a real fragment; see
*Discrimination check* for what was done about that.

The 28 pre-existing cases are unmoved. This change touches no executable, so
any movement there would be a defect in the change.

## Running an individual case

`tests/run.sh` runs every case; it takes no filter. A single case is selected
by invoking it directly with the four variables `run.sh` exports:

```
TOOLKIT_ROOT=/home/shatynska/projects/ai-toolkit \
TESTLIB=/home/shatynska/projects/ai-toolkit/tests/lib.sh \
PROJECT_INIT=/home/shatynska/projects/ai-toolkit/scripts/project-init \
TESTDIR="$(mktemp -d)" \
bash /home/shatynska/projects/ai-toolkit/tests/cases/<case-name>.sh
```

## Cases added

All six are new files under `tests/cases/`. No existing case, `tests/lib.sh`,
`tests/run.sh`, `tests/README.md` or `tests/coverage.md` was edited, deleted
or disabled — this pass is additive only.

| Case | Must go green when |
|---|---|
| `session-fragment-frontmatter.sh` | all three fragments exist at `rules/<name>.md`, each declaring `kind: standing-constraint` and no `version:`, none in a grouping subdirectory (tasks 1.1, 2.1, 3.1, 4.3, 4.4) |
| `session-fragments-not-inlined.sh` | *already green* — guards the premise the version rule rests on (see below) |
| `session-fragments-name-no-sibling.sh` | no fragment's text names another session-scoped fragment (tasks 1.9, 2.7, 4.2) |
| `session-fragments-name-fixed-paths.sh` | `worktree-isolation.md` names `.claude/worktrees/` and `deferred-work.md` names `docs/deferred-work.md`, both verbatim (tasks 1.3, 3.4) |
| `change-delivery-names-no-working-tree.sh` | `change-delivery.md` states the pull-request route and contains neither `worktree` nor `working tree` (task 2.7) |
| `deferred-work-states-workflow-seam.sh` | `deferred-work.md` names `development-workflow` (task 3.5) |

`session-fragments-not-inlined.sh` **passes at authoring time, by design.**
That is the fourth failure state's alarm only where the target is absent, and
this case's target — `scripts/project-init` — already exists and is
deliberately untouched by this change. It is a regression guard on
Requirement 10's condition ("while nothing inlines them"), not coverage of
new behaviour. Recorded here so a reader does not count it as a fifth
target-absent case.

## Discrimination check

Every case was run twice outside the suite, against fixtures built in a
scratch directory with `TOOLKIT_ROOT` and `PROJECT_INIT` pointed at them:

- Against a **compliant** fixture — three minimal fragments satisfying every
  asserted property — all six exit 0. This establishes that none is broken
  in the third failure state, and that none fails for a reason other than the
  property it asserts.
- Against **twelve violating** fixtures — one per assertion, including both
  vacuity guards — each produced exactly the intended failure message: a
  declared `version:`, a wrong `kind:`, a copy in `rules/session/`,
  `project-init` naming `change-delivery`, a tool naming no fragment at all,
  isolation naming the delivery fragment, deferred-work naming the isolation
  fragment, each fixed path removed, delivery naming a working tree, a
  delivery stub with no pull-request route, and a seam naming no fragment.

`tests/README.md` records this guard as what the suite expects of a case that
reads a fragment's prose, and it is what separates these from cases that
cannot fail.

ShellCheck 0.9.0: clean on all six. The empty-vs-unset guard, `pipefail`, and
the `set -e` suppression contexts were checked by reading — the cases set no
`-e` (matching every existing case), branch on captured command substitutions
explicitly rather than relying on it, and build no destructive path from a
variable.

## Assertion classification

| Case | Assertion | Class |
|---|---|---|
| `session-fragment-frontmatter.sh` | each fragment exists at `rules/<name>.md` | specified (Req 1 names the three files) |
| | `kind: standing-constraint` declared | specified (Req 10) |
| | no `version:` in frontmatter | specified (Req 10) |
| | frontmatter opens with `---` and has a closing `---` | derived — a parse precondition, and the vacuity guard for the two above |
| | no same-named file below `rules/` | derived — from `AGENTS.md`'s flat-layout constraint and task 4.4, not from a scenario |
| `session-fragments-not-inlined.sh` | `project-init` names none of the three | derived — Req 10 states this as fact, explicitly *not* as an obligation; asserted because the version rule is conditioned on it |
| | `project-init` names `development-workflow` | derived — vacuity guard only |
| `session-fragments-name-no-sibling.sh` | no fragment names a sibling | specified (Req 1: "No session-scoped fragment SHALL name another") |
| | `docs/deferred-work.md` scrubbed before the scan | derived — reconciles Req 9's fixed path against Req 1's prohibition; without it the required path reads as the forbidden reference |
| | scrubbed text is non-empty | derived — vacuity guard |
| `session-fragments-name-fixed-paths.sh` | `.claude/worktrees/` appears verbatim | specified (Req 4: "SHALL name the location … as a single fixed path — `.claude/worktrees/`") |
| | `docs/deferred-work.md` appears verbatim | specified (Req 9: "SHALL name the deferred-work file's path as `docs/deferred-work.md`") |
| `change-delivery-names-no-working-tree.sh` | no `worktree` / `working tree` | specified (Req 1 scenario: "the fragment's rules name no working tree") |
| | contains `pull request` | derived — vacuity guard; also entailed by Req 8 |
| `deferred-work-states-workflow-seam.sh` | names `development-workflow` | specified (Req 9: the seam "SHALL be stated against that obligation"; Req 9 also fixes this as the one permitted outside reference) |
| | `rules/development-workflow.md` exists | derived — precondition guard |

**Deliberately untested**, recorded here rather than omitted:

- The `change-delivery.md` adoption preconditions (a remote, and OpenSpec —
  Req 8, task 2.6). Checkable as a bare token presence, but no scenario
  states it, and asserting a token would oblige a wording nobody agreed to.
- That the seam is stated *against the obligation* rather than against a
  quoted sentence (Req 9, task 3.5). Any check strong enough to catch a
  quotation is either pinned to `development-workflow.md`'s present wording —
  the exact failure the delta names — or matches the shared vocabulary both
  fragments legitimately use.
- That no fragment directs releasing, deleting or dropping a shared-service
  namespace (task 4.6). See *Uncovered by design* below; this one was
  considered at length and rejected on a stated ground.
- The containment obligations attached to `.claude/worktrees/` — the ignore
  file, and recursive tools scoped explicitly (Req 4). A lexical proxy
  (`ignore file|\.gitignore|ignore rules`) would pass on a fragment that says
  it and fail on a faithful fragment that words it differently, which is a
  third-state failure wearing a first-state message. Only the path the
  obligations attach to is asserted.

## Scenario accounting — 37 of 37

The delta carries 10 requirements and 37 `#### Scenario:` blocks. Every one
is accounted for below: covered, covered in part, or uncovered with a reason.

**Why so many are uncovered, stated once.** These fragments ship no
executable. A scenario asserting a property of the three files' *text* can be
read by a shell case; a scenario asserting what an agent following the
fragment would *do* — reports verification as not run, does not inherit a
surviving namespace, halts teardown on uncommitted work — describes behaviour
with no program in this repository to run it against. `tests/coverage.md`
already records this class of limit for `project-foundation`'s 14 scenarios
and for 26 of `toolkit-structure`'s. It is a stated limit of this harness,
not an omission, and it is **not** a test-authoring exemption: this change
was not exempt, and six cases were written.

### Requirement: Session-scoped rules are separate fragments cut by applicability

| Scenario | Status |
|---|---|
| A project adopts isolation without delivery | Covered in part — `session-fragments-name-no-sibling.sh` asserts the isolation fragment names no delivery fragment. That every gate it states is checkable within it is a property of the prose; verified by reading, per tasks 1.8 and 1.9 |
| A project adopts delivery without isolation | Covered in part — `change-delivery-names-no-working-tree.sh` for "names no working tree", `session-fragments-name-no-sibling.sh` for the sibling reference. The "no branch-per-session obligation" clause is not asserted: the fragment legitimately says "the branch" throughout, and no lexical rule separates that from "a branch of its own" |
| Setup and teardown are not separated | Uncovered — asserting that creation and teardown are *stated* in one fragment needs a reading of what each passage obliges; a token scan cannot tell a rule from a mention. Verified by reading, per tasks 1.3 and 1.8 |

### Requirement: A rule states an action and a defect appears only as its reason

| Scenario | Status |
|---|---|
| A rule outlives the defect that motivated it | Uncovered — whether a rule's durable half is its instruction is a judgment about phrasing. Task 4.1 directs it by reading |
| An incident does not become a standing entry | Uncovered — same; distinguishing an incident-as-reason from an incident-as-entry is not lexical. Task 4.1 |

### Requirement: A session reports where its change stands before acting

| Scenario | Status |
|---|---|
| A session resumes a working tree left by another session | Uncovered — describes what a session does; no program to run |
| An unprovisioned working tree's green is not reported as a result | Uncovered — same. A grep for "not run" would assert a wording, not the composition clause |
| The report is derived rather than recalled | Uncovered — same |

### Requirement: One session works in one branch and one working tree

| Scenario | Status |
|---|---|
| A working tree carrying no change is not held by these rules | Uncovered — the scope statement's correctness is a property of the prose. Task 4.7 directs it by reading |
| Two sessions do not share a working tree | Uncovered — describes what a session does |
| A recursive tool does not descend into sibling working trees | Covered in part — `session-fragments-name-fixed-paths.sh` asserts `.claude/worktrees/` appears verbatim, which is what makes the containment obligations checkable at all (Req 4 says so in as many words). The obligations themselves are prose; see *Deliberately untested* |

### Requirement: A working tree is provisioned before any verification result is relied on

| Scenario | Status |
|---|---|
| A skipped verification tier is not read as a pass | Uncovered — describes what a session does |
| A namespace surviving from an earlier session is not inherited | Uncovered — same |
| A session provisions a tree it did not provision itself | Uncovered — same; and whether the rule is phrased as a state rather than an act is a reading. Task 4.7 |
| Provisioning is not assumed to be one step | Uncovered — prose property |
| A shared service is checked before being declared absent | Uncovered — describes what a session does |

### Requirement: A session's verification does not share mutable external state with another session's

| Scenario | Status |
|---|---|
| Two sessions verify concurrently against one service | Uncovered — describes runtime behaviour of an adopting project's verification, not of anything in this repository |
| The project imposes its own naming form | Uncovered — same; the fragment deliberately prescribes no form, so there is no string to assert |

### Requirement: A working tree is torn down only against an observable gate

| Scenario | Status |
|---|---|
| Teardown is refused while work is unmerged | Uncovered — describes what a session does |
| The abandonment record does not block the teardown it authorises | Uncovered — same |
| An abandoned change's working tree can be removed | Uncovered — same |
| An abandoned branch that was never pushed is still removable | Uncovered — same |
| Abandonment does not authorise discarding uncommitted work | Uncovered — same |
| A later session can read the abandonment rather than infer it | Uncovered — same |
| The gate is satisfiable in a project with no remote | Uncovered — whether every remote clause is conditioned is a reading of each clause. Task 4.5 directs it by reading |
| The gate is checkable without a delivery fragment | Covered in part — `session-fragments-name-no-sibling.sh` is exactly the guard against Req 7's "The gate SHALL NOT be stated as the completion of a step described in another fragment": a gate cannot name a step in a fragment it may not name. That the gate is *fully* checkable from repository state remains a reading |

### Requirement: A change is delivered through a pull request that carries its own record

| Scenario | Status |
|---|---|
| Delivery does not begin against unverified work | Uncovered — describes what a session does |
| The change's record ships inside the pull request | Uncovered — same |
| A merge is confirmed rather than assumed | Uncovered — same |

### Requirement: A second change surfacing in a session is recorded, not carried

| Scenario | Status |
|---|---|
| A blocking dependency survives the session ending | Uncovered — describes what a session does |
| An unrelated improvement is recorded rather than implemented | Uncovered — same |
| A project carrying both fragments has one rule to follow, not two | Covered in part — `deferred-work-states-workflow-seam.sh` asserts the fragment names the workflow fragment it reconciles against, without which no seam is stated at all. That the seam *reconciles* the two obligations is a reading; see *Deliberately untested* |
| The deferred-work file does not yet exist | Covered in part — `session-fragments-name-fixed-paths.sh` asserts `docs/deferred-work.md` appears verbatim. The "it is created" direction is prose |
| A proposal-only branch does not become the session's working branch | Uncovered — prose property. Note for the implementer: `deferred-work.md` *must* say "working tree" here (task 3.6), and the working-tree ban in `change-delivery-names-no-working-tree.sh` is scoped to `change-delivery.md` only, deliberately |
| A deferral outlives the change that recorded it | Uncovered — describes what happens when a change is archived |

### Requirement: Session-scoped fragments declare a kind and, while nothing inlines them, no version

| Scenario | Status |
|---|---|
| A fragment carries no version claim | **Covered** — `session-fragment-frontmatter.sh`, in full |
| A fragment is adopted without tooling | Covered in part — `session-fragments-not-inlined.sh` asserts the premise (no shipped tool inlines any of the three). The adoption paths themselves are documented by `toolkit-structure` and `rules/README.md`, neither of which this change touches |

**Count:** 37 scenarios. 1 covered in full, 7 covered in part, 29 uncovered
with a reason. 1 + 7 + 29 = 37.

## Uncovered by design: the namespace-release check

Task 4.6 asks for a confirmation that no fragment directs releasing, deleting
or dropping a shared-service namespace. It was considered as a case and
**declined**, on this ground rather than silently:

Requirement 6 obliges `worktree-isolation.md` to *state* that it allocates and
does not release, and to state the consequence inline. So a correct fragment
necessarily contains a sentence carrying both a release verb and the word
*namespace*. Any lexical scan for that pair matches the sentence the
requirement demands, and no shell-reachable rule separates "this fragment
does not direct releasing a namespace" from "release the namespace". The
check would fail on a compliant fragment — a third-state failure presented as
a first-state one, which is the specific thing a test must not do.

Task 4.6 already directs this by reading, and gives its own reason for doing
so ("six review rounds on that rule are the reason to check this by reading
rather than assume it"). That instruction stands; this pass adds nothing to
it.

## Obsolete tests

**Not applicable.** Every delta in this change is `ADDED` — the capability
`session-workflow` is new, and no requirement is `MODIFIED`, `REMOVED` or
`RENAMED`. There is no superseded behaviour, so no existing test can bear on
one, and no entry is offered as a candidate for confirmation.

Stated as a property rather than left to inference: **this pass adds tests and
never subtracts.** No existing case, helper, or documentation file under
`tests/` was edited, deleted or disabled, and nothing outside
`tests/cases/**` was written except this manifest.

## Unresolved project questions

Each is recorded with the assumption taken and the tests that depend on it.
None was resolved silently; none could be asked, as this pass runs with no
channel to ask on.

1. **A red suite on the change branch.** Adding these cases takes
   `bash tests/run.sh` from exit 0 to exit 1 until the fragments are written.
   Neither `AGENTS.md` nor `tests/README.md` records whether a red suite may
   be committed mid-change, nor whether `run.sh` should skip a case whose
   target does not exist. *Assumption:* the cases are added as they are and
   fail in the target-absent state, which is what the change's own task 5.1
   asks for and what `rules/development-workflow.md`'s derive-tests-then-
   implement order implies. *Depends on it:* the five target-absent cases.
   Note that task 5.2 asks for a run confirming the pre-existing suite is
   unaffected — the pre-existing 28 are indeed unmoved, but the suite's
   overall exit code is not 0 until section 1–3 are done.

2. **`tests/coverage.md` is not extended.** That file accounts for scenarios
   per change, and this change's 37 belong in it — but it sits outside the
   dispatched test-path glob (`tests/cases/**`), and no convention says
   whether the test author or the implementer extends it. *Assumption:* this
   manifest is the accounting artifact for this change, and adding
   `coverage.md` rows (which would need a cross-reference back to here) is
   the implementer's call. *Depends on it:* nothing in the cases; it is a
   documentation gap to close during implementation.

3. **No library skill covers the stack actually under test.** The artifacts
   are markdown rule fragments, and the library carries no skill for
   asserting properties of prose. `bash` was loaded for the shell the cases
   are written in, and `testing` supplied the floor. *Assumption:* the floor
   plus this repository's own precedent (`fragment-role-before-tool.sh`,
   `inlined-body-matches-fragment.sh`) governs. *Depends on it:* the choice
   to assert fixed paths and frontmatter keys verbatim while declining every
   wording proxy.

4. **No mechanism exists in this repository for exercising agent behaviour.**
   29 of the 37 scenarios describe what a session following a fragment would
   do. *Assumption:* those are unreachable by this harness and are recorded
   uncovered rather than approximated by a prose grep. *Depends on it:* the
   uncovered rows above, and the declined task-4.6 check.

## What implementation must make pass

Five cases go from failing to passing when sections 1–3 of `tasks.md` are
done. Concretely, and in the form the cases assert:

1. `rules/worktree-isolation.md`, `rules/change-delivery.md` and
   `rules/deferred-work.md` exist directly under `rules/`, each opening with
   a `---` frontmatter block declaring `kind: standing-constraint` and no
   `version:` key.
2. No fragment's text contains the token `worktree-isolation`,
   `change-delivery` or `deferred-work` naming a *sibling*. The one exception
   the cases allow for is `docs/deferred-work.md`, which
   `rules/deferred-work.md` must name.
3. `rules/worktree-isolation.md` contains the literal `.claude/worktrees/`.
4. `rules/deferred-work.md` contains the literals `docs/deferred-work.md` and
   `development-workflow`.
5. `rules/change-delivery.md` contains `pull request` and contains neither
   `worktree` nor `working tree` in any case.

`session-fragments-not-inlined.sh` is already green and must stay so:
`scripts/project-init` keeps naming `development-workflow` and none of the
three new fragments, which is what the change's Impact already promises.
