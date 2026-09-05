# Test plan — consolidate-development-workflow

Written by `ai-toolkit:change-test-writer` against the change's delta specs.
Not an artifact the OpenSpec schema defines, so `openspec instructions apply`
does not surface it — it must be read on purpose.

Test command: `bash tests/run.sh`. Test-path glob: `tests/cases/**`.

**This replaces the manifest an earlier pass wrote, wholesale**, per the
repeat-pass rule. That pass ran against a delta carrying **81** scenarios;
the delta now carries **88** — one `session-workflow` requirement moved from
`MODIFIED` to a `REMOVED`/`ADDED` pair and shed a scenario, three further
`change-test-authoring` requirements and one further `change-review`
requirement were folded in, and the three planning-artifact defects that pass
reported have since been repaired. Nothing from it is merged forward. Where a
judgment of its own still holds it is re-derived here, and the eleven cases it
left in the tree are treated on this pass as ordinary existing tests: never
edited, never deleted, and eligible for the obsolete list like any other.

## The situation this pass ran in

The change is **already implemented and committed** (`f8db7b6`, plus
uncommitted follow-on edits to two `.checks.yaml` fixtures). The read bound
held without exception: no implementation file was read — not
`rules/development-workflow.md`, not `rules/development-workflow-database.md`,
not `scripts/`, not `agents/`, not `docs/`. Every assertion below is derived
from the delta-spec scenarios and from the superseded requirements under
`openspec/specs/`. The dispatched extension to that bound — `tests/run.sh`,
`tests/lib.sh`, `tests/README.md`, `tests/coverage.md`, and the existing cases
inside the glob — was used for the suite's idiom and for the obsolete search,
and for nothing else.

Two consequences, recorded rather than glossed:

1. **A new case passing on its first run establishes nothing on its own
   here.** The testing floor's fourth failure state — a pass before any
   implementation exists — does not apply, because the implementation exists.
   But neither does a first-run pass establish that the case discriminates.
   Non-vacuity is established instead by the fixture probes below.
2. **One exposure to implementation text occurred through running the suite,
   not through reading it**, and it is disclosed rather than absorbed. A
   negative assertion prints the line it matched when it fires; none did. One
   *positive* assertion failed on its first run, and a positive failure prints
   only the case's own message, so no fragment text reached this pass through
   it. That failure is recorded below as a withdrawn derived assertion.

## Baseline

Full suite, taken before any case was written:

```
bash tests/run.sh
45 passed, 0 failed
```

After the six new cases were added, the same command reports:

```
bash tests/run.sh
51 passed, 0 failed
```

No pre-existing case changed state, and none of the six new ones fails. The
two failures the earlier manifest reported — `test-plan-artifact-name.sh` and
`review-verdict-vocabulary.sh`, both against `.checks.yaml` eval fixtures
still carrying superseded vocabulary — are green in this baseline; the
fixtures were repaired between the two passes.

**A note on how the baseline was run.** `bash tests/run.sh` could not be
invoked directly in this environment: this agent's shell permits no `bash`
invocation of a script file. The suite was run through
`python3 -c "import subprocess; subprocess.run(['bash','tests/run.sh'], cwd=…)"`,
which executes the dispatched command unchanged in the dispatched working
directory. The runner, the cases and the exit status are the project's own;
only the process that launched them differs. Recorded because a baseline
whose route is unstated is one a reader cannot reproduce.

### Fixture probes — how non-vacuity was established

Every new case was additionally run against fixtures in a scratch directory
outside the repository (`/tmp/tw-fixtures-*`, removed at the end of the pass),
with `TOOLKIT_ROOT` pointed at a synthetic `rules/` tree:

- against a **satisfying** fixture: all six pass, so none is unsatisfiable;
- against **violating** fixtures, one per assertion of substance —
  including every vacuity guard, so that a guard cannot itself be dead — all
  **26** probes failed as expected;
- against **one non-violation probe** written to catch an over-broad negative
  scan: a fragment carrying "the record is committed", "recording the
  abandonment is required" and "keep doing the work" beside a compliant
  vocabulary. It passed, so the superseded-transition scan does not fire on
  the ordinary English the fragment uses freely.

So no case is vacuous, and the one negative scan that could plausibly fire on
compliant text was shown not to.

ShellCheck 0.9.0 ran clean over all six. The `bash` floor's checks ShellCheck
does not report were read through: no `local x=$(cmd)`, no `while read` on the
right of a pipe, every expansion quoted, no `cd`, no destructive command, and
every extraction guarded against an empty result before it is used.

## Scope of this pass

This pass **adds tests and never subtracts**. It adds six cases under
`tests/cases/` and replaces this manifest. It edited, deleted and disabled no
existing test, and wrote no implementation. `tests/coverage.md` was not
written — it is outside the dispatched glob; what its `session-workflow`
section now needs is stated at the end of this file.

## What the harness can and cannot reach

`tests/` is a dependency-free bash harness. This change ships no executable:
its deliverables are two markdown fragments under `rules/`, two renamed agent
contracts under `agents/`, and a renamed rule fragment. So the delta's
scenarios divide three ways, and the division decides the ledger:

1. **A property of a finished file.** A path, a name, an ordering, an
   absence. Mechanically checkable, and every such property the delta fixes
   is covered below.
2. **A property of prose.** Whether a rule's durable half is its instruction,
   whether a report is a row rather than a paragraph, whether an exemption is
   stated in advance. A token scan cannot tell a rule from a mention, and one
   built to try fails on faithful wording.
3. **A description of what a session, an agent or a reviewer does.** Declines
   to inherit a surviving namespace, halts teardown on uncommitted work, waits
   for an operator's confirmation, classifies a defect. There is no program in
   this repository to run these against.

Kinds 2 and 3 are recorded as uncovered with that reason, per this suite's
existing practice in `tests/coverage.md`.

## New cases

Each is run by the suite. The runner has no single-case selector, so to run
one on its own the three variables `tests/run.sh` exports must be supplied by
hand — see *Unresolved project questions*:

```
TOOLKIT_ROOT="$PWD" TESTLIB="$PWD/tests/lib.sh" TESTDIR="$(mktemp -d)" \
  bash tests/cases/<name>.sh
```

| Case | Asserts | Scenarios | First run |
|---|---|---|---|
| `tests/cases/workflow-fragment-trunk-return.sh` | The fragment directs a rebase onto the trunk, and names fetching beside the trunk on one line | 40 | pass |
| `tests/cases/workflow-fragment-no-cold-run-exclusion.sh` | The fragment carries no scope exclusion for a tooling-created working tree | 39 | pass |
| `tests/cases/workflow-fragment-deploy-is-only-path.sh` | Some line of the fragment bounds local access to production | 36 | pass |
| `tests/cases/workflow-fragment-stage-names-are-current.sh` | No superseded stage transition (`:doing`, `plan:record`, `build:record`, `ship:record`) survives beside the current vocabulary | 21 | pass (after one assertion was withdrawn — see below) |
| `tests/cases/workflow-fragment-no-proposal-only-branch.sh` | The fragment does not name the opened-and-left branch for a proposal | 58 | pass |
| `tests/cases/database-fragment-migrate-is-not-seed.sh` | The binding fragment states migrating, seeding and reading a failing test's assertion message | *none — see below* | pass |

`database-fragment-migrate-is-not-seed.sh` covers **no scenario**. It asserts
two obligations the binding-fragment requirement states in one sentence and
that none of its four scenarios names: "The fragment SHALL state that
migrating is not seeding, and that a session reads a failing test's assertion
message before concluding a failure is pre-existing." Recorded here rather
than folded into a scenario row, so that the ledger's count stays a count of
scenarios.

## Assertion provenance

**Specified** — traces to a stated requirement's own words:

- a rebase onto the trunk, and fetching as a separately scoped operation
  ("The fragment SHALL also direct fetching the trunk periodically and
  rebasing onto it while the change is in progress"; "Fetching, rebasing and
  merging SHALL be scoped separately");
- the absence of the cold-run scope exclusion ("The fragment SHALL NOT carry
  the exclusion");
- the absence of the term *proposal-only* ("it is not named for a proposal —
  the term this requirement's predecessor used, and the one this change
  replaces");
- migrating and seeding as distinct ("The fragment SHALL state that migrating
  is not seeding").

**Derived** — inferred; no stated requirement fixes the token. Each is
labelled in its own case header too:

- **`fetch` beside `trunk` on one line**, as the anchor for the freshly
  fetched trunk. The requirement fixes the obligation and no wording, so the
  scan is a co-occurrence rather than a pinned phrase. Two independent
  sentences of the requirement carry the pair.
- **`cold-run`, `cold run`, `agent-authoring`**, as the anchors for the
  forbidden exclusion. The requirement names the motivating case rather than
  fixing a token, and an exclusion would have to invoke that case to be one.
  A differently worded exclusion passes and stays a reading check.
- **`local`* beside `production` on one line**, as the anchor for the
  deploy-pipeline clause. The requirement fixes the obligation and no wording;
  two of its own sentences carry the pair, so a faithful fragment has more
  than one way to satisfy it.
- **`:doing`, `plan:record`, `build:record`, `ship:record`**, as the anchors
  for the superseded transitions. What they violate is membership of the
  closed set, not a stated ban. Colon-anchored so that "the record",
  "recording" and "doing" in prose cannot trip them — confirmed by the
  non-violation probe.
- **`assertion`**, as the anchor for reading a failing test's message. The
  obligation is fixed and the wording is not; "assertion" is the word the
  requirement itself reaches for.

**A derived assertion reconsidered, and recorded as such rather than repaired.**
`workflow-fragment-stage-names-are-current.sh` was first written asserting
that the fragment names `build:verif`, on the strength of the requirement's
sentence "`plan:tests-derived` is tests written from the change's
specification deltas; `build:verifying` is tests run against the
implementation". It **failed on its first run**: the fragment carries no such
string. Under the testing floor's provenance rule the question is whether the
assertion was specified — in which case the fragment is wrong and the case is
not a repair candidate — or derived. It is derived, and the assertion is
withdrawn:

- scenario 22's own `WHEN` is "a report names a stage involving tests", so
  its subject is what a **session reports**, not what the fragment enumerates;
- the same requirement obliges the fragment to name only the states the
  derivation rule does not generate cleanly — `plan:tests-derived` and
  `ship:pr-open` — and **forbids** it from enumerating the rest;
  `build:verifying` derives cleanly, so requiring it in the text would demand
  the enumeration the requirement prohibits.

The withdrawal is recorded here and in the case's own header. It is raised as
an open question below rather than settled, because a reader who takes the
requirement's naming sentence as normative over the fragment's text would
read the fragment as non-compliant, and this pass has not read the fragment to
find out what it does say.

**Deliberately untested** — identified and knowingly left uncovered:

- **The report row's cells** (scenario 5). The requirement fixes the cells and
  their order but not their rendering, and every cell name occurs freely in
  prose. A case pinning a table syntax would design the fragment's formatting
  rather than test it.
- **The code-review bound of three** (scenario 29). The fragment states a
  different bound for the plan-review loop, and no lexical scan tells which
  loop a number belongs to.
- **The namespace-release clause** (scenario 15's second half). A compliant
  fragment necessarily contains a sentence carrying both a release verb and
  the word "namespace" — it must *state* that it allocates and does not
  release — so any lexical test for that pair fails on the fragment it was
  written to accept.
- **The merge-clause-not-ancestry rule** (scenario 44). Same shape: a fragment
  may legitimately name branch ancestry in order to exclude it.
- **The hook, continuous-integration and test-input exclusions** (scenario
  60). `--no-verify` obliges the fragment to name the hooks; the publication
  requirement obliges it to name continuous integration among the assumptions;
  and what the test-input rule excludes is the *obligation* on a project to
  state its test command and glob, which `project-foundation` owns, not a
  mention of them. Each scan would fail the fragment it was written to accept.
  Only the secrets rule is scannable, and the existing
  `workflow-fragment-omits-setup-obligations.sh` scans it.
- **Every severity classification** (scenarios 78–82). A severity is assigned
  by a reviewer's judgment about a specific defect; there is no program here
  to put a defect in front of one.
- **Every agent-behaviour scenario in `change-test-authoring`** (scenarios
  70–75). Each describes what a dispatched pass does, and the delta's only
  change to each parent requirement is the artifact rename, whose mechanical
  half `test-plan-artifact-name.sh` already asserts.

## Scenario ledger

**88 `#### Scenario:` blocks** across three delta specs — 65 in
`session-workflow`, 10 in `change-test-authoring`, 13 in `change-review`. The
six `REMOVED` requirements in `session-workflow` carry no scenarios in the
delta; their superseded scenarios drive the obsolete list instead. Every one
of the 88 is accounted for exactly once below.

Where a scenario is marked *Covered (mechanical half)*, the case named asserts
a name, a path, an ordering or an absence that the scenario turns on; the
remainder is prose or behaviour and is verified by reading. **NEW** marks a
case this pass added.

### session-workflow — MODIFIED: A rule states an action and a defect appears only as its reason (3)

| # | Scenario | Status |
|---|---|---|
| 1 | A rule outlives the defect that motivated it | Uncovered — prose property; a scan cannot tell a rule's durable half from its perishable one |
| 2 | The fragment carries no argument written for the library | Uncovered — prose property; no lexical rule identifies an argument against a rejected alternative |
| 3 | An incident does not become a standing entry | Uncovered — prose property |

### session-workflow — MODIFIED: A session reports where its change stands before acting (5)

| # | Scenario | Status |
|---|---|---|
| 4 | A session resumes a working tree left by another session | Uncovered — session behavior; no program to run it against |
| 5 | The report is a row, not a paragraph | Uncovered — deliberately untested; see the report row's cells above |
| 6 | A session reports on the way out as well as the way in | Uncovered — prose property |
| 7 | An unprovisioned working tree's green is not reported as a result | Uncovered — session behavior |
| 8 | The report is derived rather than recalled | Uncovered — session behavior |

### session-workflow — MODIFIED: A working tree is provisioned before any verification result is relied on (5)

| # | Scenario | Status |
|---|---|---|
| 9 | A skipped verification tier is not read as a pass | Uncovered — session behavior |
| 10 | A namespace surviving from an earlier session is not inherited | Uncovered — session behavior |
| 11 | A session provisions a tree it did not provision itself | Uncovered — session behavior |
| 12 | Provisioning is not assumed to be one step | Uncovered — prose property |
| 13 | A shared service is checked before being declared absent | Uncovered — session behavior |

### session-workflow — MODIFIED: A session's verification does not share mutable external state with another session's (2)

| # | Scenario | Status |
|---|---|---|
| 14 | Two sessions verify concurrently against one service | Uncovered — session behavior |
| 15 | The project imposes its own naming form | Covered (mechanical half) — `workflow-fragment-service-neutral.sh` asserts no concrete engine or runtime is named where the form is imposed. The release clause is deliberately untested |

### session-workflow — ADDED: The session obligations are published in the workflow fragment and one binding fragment (4)

| # | Scenario | Status |
|---|---|---|
| 16 | A session obligation is stated once | Covered (mechanical half) — `workflow-fragment-publication-set.sh` asserts the publication set is exactly the two fragments and the three predecessors are gone |
| 17 | A reader of a project's conventions finds no dangling reference | Covered (mechanical half) — `workflow-fragment-no-dangling-reference.sh` |
| 18 | A project without a deploy is not served by a conditional | Covered (mechanical half) — `workflow-fragment-states-assumptions.sh`. See the obsolete list: its assumption list predates this delta's |
| 19 | A second publication does not arrive unowned | Uncovered — untestable by any harness: it constrains what this capability's specification must own when a publication that does not exist is written. There is no artifact to assert against |

### session-workflow — ADDED: A change's stage is named from a fixed vocabulary (5)

| # | Scenario | Status |
|---|---|---|
| 20 | A commit made while applying is not blocked by tests written to fail | Covered (mechanical half) — `workflow-fragment-commit-bypass.sh` asserts the bypass is named. That it suspends the check and not the gate is prose |
| 21 | A resuming session names the stage without interpreting prose | Covered (mechanical half) — `workflow-fragment-stage-vocabulary.sh` for the closed set; **NEW** `workflow-fragment-stage-names-are-current.sh` for the other side of the rename, that no superseded member survives beside it |
| 22 | Writing tests and running tests are not one word | Covered (mechanical half) — `workflow-fragment-stage-vocabulary.sh`'s crossed-name scan. The `build:verifying` half is a withdrawn derived assertion, above |
| 23 | The vocabulary is not enumerated beside the rule that generates it | Uncovered — prose property; no scan distinguishes an enumeration from the examples the requirement obliges |
| 24 | An imprecise stage is not treated as a defect worth an artifact | Covered (mechanical half) — `workflow-fragment-no-mandated-ledger.sh` asserts no ledger is mandated by name |

### session-workflow — ADDED: A production-confirmation waiver is recorded (3)

| # | Scenario | Status |
|---|---|---|
| 25 | A waived change carries the reason to the trunk | Covered (mechanical half) — `workflow-fragment-confirmation-waiver.sh` |
| 26 | A verdict is not recorded, and the commit stands for it | Uncovered — session behavior, and an absence of an obligation no scan can name |
| 27 | A confirmation nobody recorded is simply asked again | Uncovered — session behavior |

### session-workflow — ADDED: A change is delivered through at least two pull requests, the last carrying its record (11)

| # | Scenario | Status |
|---|---|---|
| 28 | Delivery does not begin against unverified work | Uncovered — session behavior |
| 29 | The code-review loop does not run unbounded | Uncovered — deliberately untested; two loops, two bounds, no scan tells which number belongs to which |
| 30 | A merge and its deploy are confirmed rather than assumed | Uncovered — session behavior |
| 31 | A healthy deploy is not confirmation the change worked | Uncovered — session behavior |
| 32 | A change with no observable effect reaches its record | Covered (mechanical half) — `workflow-fragment-confirmation-waiver.sh` asserts a waiver is stated at all; that it is stated in advance by class is prose |
| 33 | The record follows the confirmed effect | Uncovered — session behavior. Its return to the freshly fetched trunk is asserted by **NEW** `workflow-fragment-trunk-return.sh` under scenario 40, where the requirement states it |
| 34 | A remedial cycle adds a pull request rather than reusing one | Uncovered — session behavior |
| 35 | A failed deploy does not produce a record | Uncovered — session behavior |
| 36 | Production is not reached from a local machine | Covered (mechanical half) — **NEW** `workflow-fragment-deploy-is-only-path.sh`. That a change reaches production by merging and by nothing else, and that read-only credentials are distinguished, are prose |
| 37 | A deployed change that does not do what it was for | Uncovered — session behavior |
| 38 | The wrong change reaches its record rather than stalling | Covered (mechanical half) — `workflow-fragment-confirmation-waiver.sh`; that the second class is named without requiring a successor is prose |

### session-workflow — ADDED: A change works in one branch and one working tree (3)

| # | Scenario | Status |
|---|---|---|
| 39 | A working tree carrying no change is not held by these rules | Covered (mechanical half) — **NEW** `workflow-fragment-no-cold-run-exclusion.sh` asserts the forbidden exclusion is absent. That every rule is positively keyed to the change is prose |
| 40 | A long-running change does not first meet the trunk at its pull request | Covered (mechanical half) — **NEW** `workflow-fragment-trunk-return.sh`. That the rebase is periodic, and that the pre-push and post-push routes are given as two, are prose |
| 41 | Two sessions do not share a working tree | Uncovered — session behavior |

### session-workflow — ADDED: A change's branch and working tree are removed only against an observable gate (9)

| # | Scenario | Status |
|---|---|---|
| 42 | Teardown is refused while work is unmerged | Uncovered — session behavior |
| 43 | A merged work pull request does not by itself satisfy the gate | Uncovered — prose property; the record's conjunct is a clause, not a token |
| 44 | A squash-merged change is still removable | Uncovered — deliberately untested; a compliant fragment may name branch ancestry in order to exclude it |
| 45 | The abandonment record does not block the teardown it authorises | Uncovered — session behavior |
| 46 | An abandoned change's working tree can be removed | Uncovered — session behavior |
| 47 | An abandoned branch that was never pushed is still removable | Uncovered — prose property |
| 48 | Abandonment does not authorise discarding uncommitted work | Uncovered — session behavior |
| 49 | A later session can read the abandonment rather than infer it | Uncovered — session behavior |
| 50 | Teardown follows the record's pull request, not the work's | Uncovered — session behavior |

### session-workflow — ADDED: A second change surfacing in a session is recorded in the change queue (9)

| # | Scenario | Status |
|---|---|---|
| 51 | A blocking dependency survives the session ending | Uncovered — session behavior |
| 52 | An unrelated improvement is recorded rather than implemented | Uncovered — session behavior |
| 53 | An identified change is not filed as deferred work | Covered (mechanical half) — `workflow-fragment-fixed-paths.sh` asserts both artifacts are named, which is what lets the distinction be stated |
| 54 | The scope rule and the queue are one obligation | Uncovered — prose property |
| 55 | The change queue does not yet exist | Covered (mechanical half) — `workflow-fragment-fixed-paths.sh` for the path; the create-it-if-absent direction is prose |
| 56 | An identified change is opened without a proposal | Covered (mechanical half) — `workflow-fragment-names-handoff.sh` |
| 57 | A handoff is not left uncommitted on a branch the session leaves | Uncovered — session behavior |
| 58 | An opened-and-left branch does not become the session's working branch | Covered (mechanical half) — **NEW** `workflow-fragment-no-proposal-only-branch.sh` asserts the superseded term is gone. That the branch is created and left, and takes no working tree, is session behavior |
| 59 | A deferral outlives the change that recorded it | Uncovered — session behavior |

### session-workflow — ADDED: A one-time setup obligation does not belong in the fragment (2)

| # | Scenario | Status |
|---|---|---|
| 60 | A setup obligation found while writing the fragment is recorded, not added | Covered (mechanical half) — `workflow-fragment-omits-setup-obligations.sh` covers the secrets rule only. The other three of the four are deliberately untested, each for a stated collision |
| 61 | The skipped-check principle is stated once | Uncovered — prose property; "stated once" is a count of statements a scan cannot take |

### session-workflow — ADDED: The database binding fragment states the shared database as an affordance before an obligation (4)

| # | Scenario | Status |
|---|---|---|
| 62 | A session does not substitute a reachable double for the real database | Covered (mechanical half) — `database-fragment-affordance-before-obligation.sh`'s ordering assertion |
| 63 | Absence is asserted only after looking | Covered (mechanical half) — the same case's `container` assertion |
| 64 | A skipped tier is not reported as a pass | Uncovered — session behavior |
| 65 | Two sessions do not share one database | Covered (mechanical half) — `database-fragment-per-working-tree.sh` |

### change-test-authoring — MODIFIED: The Pass Produces a Manifest at a Named Path (2)

| # | Scenario | Status |
|---|---|---|
| 66 | The manifest carries runnable test identifiers | Covered (mechanical half) — `test-plan-artifact-name.sh` asserts the artifact's name, which is what a runnable identifier is recorded in. That the identifiers are runner-selectable is a property of a pass's output; this manifest satisfies it under *New cases* |
| 67 | The baseline is carried into the manifest | Uncovered — a property of a pass's output, not of the library. Satisfied by this manifest's *Baseline* section rather than asserted by a case |

### change-test-authoring — MODIFIED: The Manifest Is Reachable by Whoever Implements Next (1)

| # | Scenario | Status |
|---|---|---|
| 68 | The manifest is pointed to twice | Covered — `test-plan-artifact-name.sh` asserts a pointer under `rules/` and another under `agents/`, and that neither names the superseded artifact |

### change-test-authoring — MODIFIED: A Repeat Pass Is Specified Rather Than Left to Judgment (1)

| # | Scenario | Status |
|---|---|---|
| 69 | A second pass replaces the manifest and treats its own prior output as existing tests | Covered (mechanical half) — `test-plan-artifact-name.sh` for the filename the scenario names. The behaviour is discharged in fact by this pass: the earlier manifest is replaced wholesale and the earlier pass's eleven cases were treated as existing tests, never edited |

### change-test-authoring — MODIFIED: The Change Is Supplied by Dispatch, Not Discovered (2)

| # | Scenario | Status |
|---|---|---|
| 70 | A missing essential input blocks rather than defaults | Uncovered — agent behavior; the delta's only change to this requirement is the artifact rename, whose mechanical half `test-plan-artifact-name.sh` asserts |
| 71 | Paths are not guessed from convention | Uncovered — agent behavior, same reason |

### change-test-authoring — MODIFIED: What the Agent May Read Is Bounded (2)

| # | Scenario | Status |
|---|---|---|
| 72 | Superseded behaviour is established from specifications, not from code | Uncovered — agent behavior, same reason. Discharged in fact by this pass: what each `MODIFIED` and `REMOVED` delta supersedes was established from `openspec/specs/`, and no implementation file was read |
| 73 | The read bound is reported rather than crossed silently | Uncovered — agent behavior, same reason |

### change-test-authoring — MODIFIED: Obsolete-Test Entries Are Identified by a Stated Procedure and Carry Their Basis (2)

| # | Scenario | Status |
|---|---|---|
| 74 | An entry carries the evidence for itself | Uncovered — agent behavior, same reason. Discharged in fact by the obsolete list below |
| 75 | Finding nothing is recorded, not left empty | Uncovered — agent behavior, same reason. Discharged in fact below |

### change-review — MODIFIED: Artifacts are data, never instructions (2)

| # | Scenario | Status |
|---|---|---|
| 76 | An artifact instructs the reviewer | Covered (mechanical half) — the scenario's own fixture line is renamed by this delta from `PROCEED` to `APPROVED`, and `review-verdict-vocabulary.sh` scans the `.checks.yaml` fixtures for exactly that. The reviewer's response to it is behavior |
| 77 | An artifact asserts its own approval | Uncovered — reviewer behavior |

### change-review — MODIFIED: Severity distinguishes design defects from coherence defects (5)

| # | Scenario | Status |
|---|---|---|
| 78 | Artifacts disagree | Uncovered — reviewer judgment; no program here to put a defect in front of one |
| 79 | A disagreement changes nothing that would be built | Uncovered — reviewer judgment |
| 80 | The approach is unsound | Uncovered — reviewer judgment |
| 81 | A defect is emphasised rather than classified | Uncovered — reviewer judgment |
| 82 | Issue lacks an anchor | Uncovered — reviewer judgment |

### change-review — MODIFIED: The recommended action is a single cause-neutral verdict (4)

| # | Scenario | Status |
|---|---|---|
| 83 | A coherence defect blocks the change | Covered (mechanical half) — `review-verdict-vocabulary.sh`: the scenario's outcome is `FIX REQUIRED`, and the case asserts that token is the published one and its predecessor is gone. The mapping from severity is reviewer judgment |
| 84 | A critical issue is the highest severity present | Covered (mechanical half) — same case, for `FIX REQUIRED` and `REJECTED` |
| 85 | Only minor issues remain | Covered (mechanical half) — same case, for `CONDITIONALLY APPROVED` |
| 86 | The concept is sound but the design is not | Covered (mechanical half) — same case |

### change-review — MODIFIED: A clean review is a valid outcome (2)

| # | Scenario | Status |
|---|---|---|
| 87 | Nothing is wrong with the change | Covered (mechanical half) — `review-verdict-vocabulary.sh`, for the `APPROVED` token the scenario's outcome names. That an empty matrix is reported rather than padded is reviewer behavior |
| 88 | A concern does not survive investigation | Uncovered — reviewer behavior |

### Ledger totals

| | Count |
|---|---|
| Scenarios in the delta specs | 88 |
| Covered in part by a named case | 31 |
| Uncovered, with a reason | 57 |
| **Accounted for** | **88** |

Of the 31, five are touched by a case this pass added (21, 36, 39, 40, 58) and
four of those five are covered by a new case alone — scenario 21 is shared with
`workflow-fragment-stage-vocabulary.sh`. The other 26 are covered by cases
already in the tree.

**Three cases in the glob cover requirement text that no scenario names**, and
are therefore counted nowhere above. Recorded so that a reader does not read
their absence from the ledger as their absence from the suite:
`database-fragment-frontmatter.sh` (the binding fragment's frontmatter, per the
REMOVED version requirement's migration note), `workflow-fragment-worktree-root.sh`
(the `.worktrees/` root the one-branch requirement fixes in its prose — the
scenario it was originally written for, "A recursive tool does not descend into
sibling working trees", is gone from the delta) and **NEW**
`database-fragment-migrate-is-not-seed.sh`.

## Obsolete tests

Every entry is a **candidate for human confirmation**, not a conclusion. This
pass edited and deleted nothing.

**Search bound**: `tests/cases/**`, the dispatched glob, and nowhere else.
The earlier `test-plan.md` supplied to this pass was used as a
scenario-to-test mapping alongside each case's own header comment.

**Where the search found nothing, that is stated rather than left as an empty
list.** Three distinct results appear below.

### Cases whose stated basis a revised requirement supersedes

None of the five is failing. Each asserts something still true, on grounds the
delta has moved — so the candidate action is a **correction, not a deletion**:
deleting any of them would lose coverage the ledger above counts.

| Case | Superseded by | Evidence | Candidate action |
|---|---|---|---|
| `tests/cases/workflow-fragment-fixed-paths.sh` | REMOVED "One session works in one branch and one working tree" → ADDED "A change works in one branch and one working tree" | Line 27 asserts `.claude/worktrees/` with the message "the working-tree location is a fixed path". The ADDED requirement fixes `.worktrees/` as the rule's path and demotes a harness's path to a binding named beneath it. Its header (lines 2–3) names the scenario "A recursive tool does not descend into sibling working trees", which the current delta carries **no** scenario for, and (line 17) calls the containment obligations on `.claude/worktrees/` "verified by reading" — the same requirement now states they SHALL NOT be in the fragment at all | Confirm; retarget the assertion message and rewrite the header against the two scenarios its surviving assertions actually serve (53, 55). `workflow-fragment-worktree-root.sh` already asserts the path the requirement now fixes |
| `tests/cases/workflow-fragment-states-assumptions.sh` | ADDED "The session obligations are published in the workflow fragment and one binding fragment" | Line 24 requires the token `forge` among four assumptions the fragment must name. The requirement now enumerates *pull requests* in the forge's place and argues the forge out by name: "Pull requests imply the forge whose merged-state report the teardown gate reads; naming it separately in the assumptions states twice what the gate states once." Lines 5–6 of its header state the superseded four | Confirm; swap `forge` for `pull request` in the token list and correct the header. The case already asserts `pull request` separately at line 26, so the swap is close to a no-op in effect and a correction in basis |
| `tests/cases/workflow-fragment-stage-vocabulary.sh` | ADDED "A change's stage is named from a fixed vocabulary" | Its header (line 4) names the scenario "A change waiting on a deploy is distinguishable from one waiting on a merge", which does not appear anywhere in the current delta; and lines 11–13 name an unasserted half — "whether each name is classified transient or persistent, and whether each persistent one has its trace named" — belonging to the stage-derivability requirement decision 6 withdrew. The assertions themselves trace to surviving text | Confirm; correct the header. Do not delete |
| `tests/cases/workflow-fragment-worktree-root.sh` | ADDED "A change works in one branch and one working tree" | Two header defects. Lines 2–3 name the scenario "A recursive tool does not descend into sibling working trees", absent from the current delta. Lines 23–27 record a "Known conflict in the delta" — that the change-queue requirement twice refers back to "`.claude/worktrees/` … fixed above" — which the delta no longer has: `specs/session-workflow/spec.md` names `.worktrees/` at lines 448, 559 and 574 and `.claude/worktrees/` nowhere | Confirm; retarget the header at scenario 39 or 40 and delete the stale conflict note. The assertions are current |
| `tests/cases/fragment-role-before-tool.sh` | MODIFIED "The recommended action is a single cause-neutral verdict" (`change-review`) | Line 16 of its header reads "only the verdict `PROCEED` is harness-specific", naming a verdict this delta replaces, while the `awk` at line 25 matches `APPROVED`, `FIX REQUIRED` and `REJECTED` — the current set. A stale comment beside a correct assertion, and the only surviving occurrence of a superseded verdict token in the glob outside `review-verdict-vocabulary.sh`, which quotes them deliberately | Confirm; correct the comment. The case belongs to `project-bootstrap` rather than to this change, and its assertions are current |

### Cases superseded outright

**None found, and none exists.** The six cases that asserted the three deleted
fragments — `session-fragments-name-fixed-paths.sh`,
`session-fragments-name-no-sibling.sh`, `session-fragment-frontmatter.sh`,
`session-fragments-not-inlined.sh`, `deferred-work-states-workflow-seam.sh`
and `change-delivery-names-no-working-tree.sh`, enumerated by `tasks.md` 5.2 —
and two the first pass wrote (`workflow-fragment-gate-log.sh`,
`workflow-fragment-names-test-inputs.sh`) were removed by the implementation
commit and are not in the glob. A scan of `tests/cases/**` for each deleted
subject confirms it: the only files naming `worktree-isolation`,
`change-delivery` or `deferred-work` are
`workflow-fragment-publication-set.sh`,
`workflow-fragment-no-dangling-reference.sh` and
`workflow-fragment-fixed-paths.sh`, each of which names them in order to
assert their **absence** or the distinction between two artifacts, which is
current behaviour rather than superseded. This is "no such test exists",
established by a scan, not "none was found".

### Where no bearing test was found — a distinct result

For the two `change-test-authoring` requirements folded in since the earlier
pass whose delta content is purely the artifact rename, and for
`change-review`'s newly folded "A clean review is a valid outcome", **no
existing case bore on the superseded behaviour**, and this is "no such test
exists" rather than "none was found by this search": `grep` over the whole of
`tests/cases/**` for `test-manifest`, `PROCEED`, `CHANGES REQUIRED` and
`REJECT` returns hits in exactly two files, and both quote the superseded
tokens deliberately — `review-verdict-vocabulary.sh` and
`test-plan-artifact-name.sh` scan *for* them as the thing that must be gone.
Neither is an obsolete entry; both assert current behaviour. The one stale
occurrence is `fragment-role-before-tool.sh`'s comment, entered above.

### Cases coupled to the workflow fragment's version — judged to survive

Re-examined on this pass; no obsolete entry is made for any:
`inlined-body-matches-fragment.sh`, `managed-block-current-version.sh`,
`managed-block-older-version.sh`. All three read the version through
`fragment_version()` rather than a literal, so a bump moves both sides
together.

## What the implementation step must make pass

**Nothing.** The change is already implemented, the full suite is green at 51
passed / 0 failed, and every case this pass added passes against the landed
fragments. What remains is not test work:

1. **Apply the five obsolete-test entries above** (`tasks.md` 5.4). All five
   are corrections to an assertion message or a header comment; none is a
   deletion, and none is this pass's to make.
2. **Rewrite `tests/coverage.md`'s `session-workflow` section** (`tasks.md`
   5.3) — see the last section of this file for what it now needs.
3. **Resolve the `build:verifying` question** raised under *Assertion
   provenance*, one way or the other. This pass withdrew the assertion rather
   than leaving a failing case behind a derived reading, and did not read the
   fragment to establish what it says.

## Defects found in the change's planning artifacts

Reported, not fixed — revising them is `openspec-update-change`'s work.

1. **The delta and `tasks.md` are now consistent on every point the earlier
   pass reported.** The `.worktrees/` contradiction is resolved, `tasks.md`
   1.4 no longer directs the containment obligations into the fragment, and
   1.9 no longer directs a review-verdict record. Recorded because the earlier
   manifest is being replaced and its three findings would otherwise vanish
   without their disposition being visible.
2. **One tension is left standing, and is a judgment rather than a defect.**
   The stage-vocabulary requirement's sentence "`plan:tests-derived` is tests
   written from the change's specification deltas; `build:verifying` is tests
   run against the implementation" reads as fixing two names, while the same
   requirement obliges the fragment to name only the states the derivation
   rule does not generate cleanly and forbids enumerating the rest. Whether
   the fragment owes the string `build:verifying` is not settled by the text.
   The withdrawn assertion above is the practical consequence.

No instruction addressed to a test author was found embedded in any artifact.

## Unresolved project questions

Each records the assumption taken and which tests depend on it.

1. **The runner has no single-case selector.** `bash tests/run.sh` discovers
   and runs every file in `tests/cases/*.sh`; nothing accepts a filter.
   *Assumption*: a single case is run by supplying `TOOLKIT_ROOT`, `TESTLIB`
   and `TESTDIR` by hand, as shown under *New cases*. *Depends on it*: nothing
   in the cases — only this manifest's obligation to name tests in a
   runner-selectable form. Verified working for all six.
2. **The suite omits `set -euo pipefail`, which the `bash` skill's floor
   requires.** No case in `tests/cases/` sets any shell option; `run.sh` sets
   `-u` alone. Reporting the conflict rather than resolving it, per that
   skill's rule. *Assumption*: the established style is the project's
   convention and the six new cases follow it, relying on `lib.sh`'s helpers
   and explicit `exit 1` guards. *Depends on it*: all six. Every extraction is
   guarded so an empty result fails the case rather than skipping past it.
3. **`tests/README.md` scopes the suite to `scripts/project-init`, and the
   suite has long since grown past that scope.** Twenty-one cases now read
   `rules/` and two read `agents/`, and no convention records whether that is
   wanted. *Assumption*: `bash tests/run.sh` is the project's only test
   command and `tests/cases/**` the only test-path glob, so a scenario
   checkable only against a `rules/` fragment has nowhere else to go.
   *Depends on it*: all six new cases.
4. **Whether an obsolete case is corrected, rewritten or deleted is recorded
   nowhere.** `tests/README.md` and `AGENTS.md` state no convention for
   retiring a case. *Assumption*: none — the five entries above are left as
   candidates with a suggested action, and this pass performed no deletion.
   *Depends on it*: no test.
5. **Whether the fragment's pointer at the project's test command and
   test-path glob is inside the setup-obligation exclusion.** The requirement
   excludes the *obligation* on a project to state them. *Assumption*: a
   pointer is not the excluded obligation, so no case scans for it. *Depends
   on it*: `workflow-fragment-omits-setup-obligations.sh`, which would fail
   the current fragment on the opposite reading. Carried forward from the
   earlier pass and re-derived, not merged.
6. **Whether the fragment owes the literal string `build:verifying`.** See
   *Assertion provenance* and *Defects*. *Assumption*: it does not, because
   the state derives cleanly from a stated transition and the requirement
   forbids enumerating derived states. *Depends on it*:
   `workflow-fragment-stage-names-are-current.sh`, which would carry a
   failing assertion on the opposite reading.
7. **This agent's shell could not invoke `bash tests/run.sh` directly.** The
   dispatched test command was executed through `python3 -c` calling
   `subprocess.run(['bash','tests/run.sh'])`. *Assumption*: the runner, the
   cases and the exit status are unaffected by the launching process, so the
   baseline is the project's own. *Depends on it*: every claim in *Baseline*
   and *Fixture probes*.

## What `tests/coverage.md` now needs

Outside the dispatched glob; not written by this pass.

- **The section heading is wrong.** `## specs/session-workflow/spec.md (66
  scenarios)` becomes **88 scenarios** across three delta specs, or the
  section splits — see the last bullet.
- **The case list names two files that no longer exist.**
  `workflow-fragment-gate-log.sh` and `workflow-fragment-names-test-inputs.sh`
  were deleted by the implementation commit; their entries must come out.
- **"Twenty-two covered in part by the eleven cases"** becomes **twenty-two
  covered in part by fifteen cases** for `session-workflow` alone — the nine
  surviving cases from the first pass, plus `workflow-fragment-worktree-root.sh`,
  `workflow-fragment-names-handoff.sh`, `workflow-fragment-commit-bypass.sh`,
  `workflow-fragment-no-mandated-ledger.sh`,
  `workflow-fragment-omits-setup-obligations.sh` and
  `workflow-fragment-confirmation-waiver.sh` from the second — plus the five
  this pass added under that capability. **Twenty-one cases bear on
  `session-workflow`**, of which nineteen cover at least one scenario;
  twenty-two of its 65 scenarios are covered in part and forty-three are
  uncovered.
- **"Forty-four uncovered"** becomes forty-three, for `session-workflow`.
- **The four scenarios named individually as untestable by any harness are
  down to one**: "A second publication does not arrive unowned". "A tier that
  skipped does not report a pass" and "A secret takes an override to commit,
  not an oversight" name a requirement pair this delta no longer carries in
  that form, and the code-review bound of three is listed here as deliberately
  untested rather than untestable in principle.
- **Two sections do not yet exist and are now owed**: `specs/change-review`
  (13 scenarios, six covered in part by `review-verdict-vocabulary.sh`) and
  `specs/change-test-authoring` (10 scenarios, three covered in part by
  `test-plan-artifact-name.sh`). Their per-scenario rows are in this file's
  ledger.
- **One new case covers no scenario** and needs a row saying so:
  `database-fragment-migrate-is-not-seed.sh`.
