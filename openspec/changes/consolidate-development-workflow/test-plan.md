# Test manifest — consolidate-development-workflow

Written by `ai-toolkit:change-test-writer` against the change's delta
specs, before implementation. Not an artifact the OpenSpec schema defines,
so `openspec instructions apply` does not surface it — see
`rules/test-plan.md`.

Test command: `bash tests/run.sh`. Test-path glob: `tests/cases/**`.

## Baseline

Full suite, taken before any case was written:

```
bash tests/run.sh
34 passed, 0 failed
```

After the eleven new cases were added, the same command reports
`34 passed, 11 failed`. Every one of the eleven fails in the
target-does-not-exist state: `rules/development-workflow.md` is still at
version 2 and `rules/development-workflow-database.md` does not exist. No
pre-existing case changed state. No case passed on its first run.

Because a target-absent failure establishes only that the target is absent —
the assertions never executed — each new case was additionally run twice
against fixtures in a scratch directory outside the repository, with
`TOOLKIT_ROOT` pointed at a synthetic `rules/`:

- against a **satisfying** fixture (a stand-in v3 carrying the tokens the
  delta fixes, plus a stand-in binding fragment): all eleven pass, so none
  is unsatisfiable;
- against **violating** fixtures, one per assertion of substance: all
  fourteen probes failed as expected, and the one probe written to confirm a
  non-violation (`container build context` is not a service name) passed.
  So no case is vacuous.

ShellCheck 0.9.0 ran clean over all eleven. The bash floor's checks that
ShellCheck does not report were read through: no `local x=$(cmd)`, no
`while read` on the right of a pipe, every expansion quoted except two
deliberate word-split `for` lists matching the suite's existing idiom, no
`cd`, no destructive command, every arithmetic and `sed` range guarded
against an empty extraction.

## Scope of this pass

This pass is additive. It adds eleven cases under `tests/cases/` and this
manifest. It edits, deletes and disables nothing, and writes no
implementation — neither fragment named below was created or modified.

## What the harness can and cannot reach

`tests/` is a dependency-free bash harness whose only executable subject is
`scripts/project-init`. This change ships no executable: its deliverables
are two markdown fragments under `rules/`. So the delta's scenarios divide
three ways, and the division decides the ledger below.

1. **A property of a finished file.** A path, a name, an ordering, an
   absence. Mechanically checkable, and every such property the delta fixes
   is covered below.
2. **A property of the fragment's prose.** Whether a rule's durable half is
   its instruction, whether a report is stated as a row rather than a
   paragraph, whether an exemption is stated in advance. A token scan cannot
   tell a rule from a mention, and one built to try fails on a faithful
   wording. Verified by reading.
3. **A description of what a session does.** Declines to inherit a surviving
   namespace, halts teardown on uncommitted work, waits for an operator's
   confirmation. There is no program in this repository to run these
   against.

Kinds 2 and 3 are recorded as uncovered with that reason, per this suite's
existing practice in `tests/coverage.md`. Where a scenario's outcome names a
fixed artifact — `gate-log.md`, `docs/change-queue.md`, `.claude/worktrees/`
— its **mechanical half** is covered: asserting the name verbatim is what
gives the prose obligation attached to it a checkable subject, which is the
reason the specification fixes those names at all.

## New cases

Each is run by the suite. To run one on its own the three variables
`tests/run.sh` exports must be supplied by hand — see *Unresolved project
questions*:

```
TOOLKIT_ROOT="$PWD" TESTLIB="$PWD/tests/lib.sh" TESTDIR="$(mktemp -d)" \
  bash tests/cases/<name>.sh
```

| Case | Asserts | Task |
|---|---|---|
| `tests/cases/workflow-fragment-publication-set.sh` | `rules/development-workflow.md` and `rules/development-workflow-database.md` both exist, directly under `rules/`; `worktree-isolation.md`, `change-delivery.md` and `deferred-work.md` are absent | 2.1, 3.1 |
| `tests/cases/workflow-fragment-no-dangling-reference.sh` | Neither fragment's body names a `rules/` path, a fragment filename, or an `@` import; `docs/deferred-work.md` scrubbed first as a project file the fragment is obliged to name | 1.16, 2.4 |
| `tests/cases/workflow-fragment-states-assumptions.sh` | The workflow fragment names the remote, the forge, continuous integration and the deploy, and states the delivery route; the two predecessor conditionals do not reappear verbatim | 1.2 |
| `tests/cases/workflow-fragment-stage-vocabulary.sh` | All nineteen stage names are stated; `plan:verify` and `build:tests` appear nowhere | 1.8 |
| `tests/cases/workflow-fragment-gate-log.sh` | The fragment names `gate-log.md` and `test-plan.md` | 1.8, 1.9 |
| `tests/cases/workflow-fragment-fixed-paths.sh` | The fragment names `.claude/worktrees/`, `docs/change-queue.md` and `docs/deferred-work.md` | 1.4, 1.14 |
| `tests/cases/workflow-fragment-names-test-inputs.sh` | The fragment states the test-design gate and asks the project for a `test command` and a `test-path glob` | 1.15 |
| `tests/cases/workflow-fragment-service-neutral.sh` | The fragment states the namespace obligation and names no concrete engine or container runtime | 1.6 |
| `tests/cases/database-fragment-affordance-before-obligation.sh` | The binding fragment names the container, and its first affordance line precedes its first provisioning line | 2.2, 2.3 |
| `tests/cases/database-fragment-per-working-tree.sh` | The binding fragment names the working tree the database is named after, and the development database a session works in neither of | 2.3 |
| `tests/cases/database-fragment-frontmatter.sh` | The binding fragment sits directly under `rules/`, opens with a terminated frontmatter block of keys, declares `kind: standing-constraint` and a numeric `version` | 2.1 |

`database-fragment-frontmatter.sh` accounts for **no scenario**. It traces to
the removed version requirement's own migration text ("The database binding
fragment declares `kind: standing-constraint` and a `version`") and to task
2.1, not to a `#### Scenario:` block. Recorded here so its absence from the
ledger below is a stated fact rather than a gap.

## Assertion provenance

**Specified** — traces to a stated requirement, a migration clause, or a
task:

- every path, filename and stage name asserted verbatim: the delta fixes
  each one, and fixes them for the stated reason that an obligation
  referencing an unfixed path cannot be checked against the fragment
  afterwards;
- the absence of the three replaced fragments (publication requirement:
  "published in two places and no more");
- the `rules/`-path, fragment-filename and import prohibition (publication
  requirement: "Neither fragment SHALL name a `rules/` path, a sibling
  fragment, or an import");
- the affordance-before-obligation ordering in the binding fragment (the
  requirement states "The ordering is normative");
- the four named assumptions;
- `kind` and `version` on the binding fragment;
- the flat `rules/` layout (`AGENTS.md`, and the same check in the existing
  `session-fragment-frontmatter.sh`).

**Derived** — inferred; no stated requirement fixes the exact form. Each is
labelled in the case's own header comment as well:

- `workflow-fragment-states-assumptions.sh` scans for the two conditional
  phrasings the predecessor fragments used verbatim (`where the project has
  a remote`, `where the project has one`). The requirement forbids "a
  conditional", which no lexical rule identifies; this catches a
  resurrection of the specific text the design names as the cost being
  removed, and nothing wider.
- `workflow-fragment-service-neutral.sh`'s list of forbidden engine and
  runtime names is an enumeration, not a rule. The requirement says "no
  concrete service"; the case can only name the ones it knows.
- `workflow-fragment-names-test-inputs.sh` uses the section heading `Test
  design before implementation` as its vacuity guard. Task 1.3 keeps that
  section, so the pin is cheap, but a rename would break the case for a
  reason unrelated to what it tests.
- `database-fragment-affordance-before-obligation.sh` anchors the obligation
  half on the token `provision`. A binding fragment that mentions
  provisioning in an opening sentence, before the affordance, fails — which
  is the strictness the requirement asks for, but it is an anchor the
  requirement does not name.
- `database-fragment-per-working-tree.sh` pins the phrase `development
  database`. The requirement states the exclusion in those words; a
  faithful paraphrase ("the shared database everyone develops against")
  would fail.

**Deliberately untested** — identified and knowingly left uncovered:

- **The plan-review and code-review bounds.** The delivery requirement fixes
  the code-review loop at three rounds. The fragment already states a
  different bound — an initial review and five automatic re-reviews — for
  the plan-review loop, and no scan can tell which loop a number belongs to.
  `tests/coverage.md` already records the equivalent `project-bootstrap`
  scenarios as prose.
- **The namespace-release clause.** A compliant fragment necessarily
  contains a sentence carrying both a release verb and the word "namespace"
  (it must *state* that it allocates and does not release), so any lexical
  test for that pair fails on the fragment it was written to accept. The
  same reasoning `tests/coverage.md` records for the predecessor.
- **The report row's cells.** The requirement fixes the cells and their
  order but not their rendering, and every cell name — "committed",
  "verification", "stage" — occurs freely in prose. A case pinning a table
  syntax would design the fragment's formatting rather than test it.

## Scenario ledger

66 `#### Scenario:` blocks across the delta's 5 MODIFIED and 8 ADDED
requirements. The 5 REMOVED requirements carry no scenarios in the delta.
Every one is accounted for exactly once.

### MODIFIED — A rule states an action and a defect appears only as its reason (2)

| Scenario | Status |
|---|---|
| A rule outlives the defect that motivated it | Uncovered — prose property; a scan cannot tell a rule's durable half from its perishable one. Task 6.6 directs it by reading |
| An incident does not become a standing entry | Uncovered — prose property; verified by reading (task 6.6) |

### MODIFIED — A session reports where its change stands before acting (5)

| Scenario | Status |
|---|---|
| A session resumes a working tree left by another session | Uncovered — session behavior; no program to run it against |
| The report is a row, not a paragraph | Uncovered — prose property; see *Deliberately untested*, the report row's cells |
| A session reports on the way out as well as the way in | Uncovered — prose property; verified by reading (task 1.7) |
| An unprovisioned working tree's green is not reported as a result | Uncovered — session behavior |
| The report is derived rather than recalled | Uncovered — session behavior |

### MODIFIED — One session works in one branch and one working tree (3)

| Scenario | Status |
|---|---|
| A working tree carrying no change is not held by these rules | Uncovered — prose property (the scope exclusion); verified by reading (task 1.4) |
| Two sessions do not share a working tree | Uncovered — session behavior |
| A recursive tool does not descend into sibling working trees | Covered in part — `workflow-fragment-fixed-paths.sh` asserts `.claude/worktrees/` verbatim. The containment obligations attached to that path are prose |

### MODIFIED — A working tree is provisioned before any verification result is relied on (5)

| Scenario | Status |
|---|---|
| A skipped verification tier is not read as a pass | Uncovered — session behavior |
| A namespace surviving from an earlier session is not inherited | Uncovered — session behavior |
| A session provisions a tree it did not provision itself | Uncovered — session behavior |
| Provisioning is not assumed to be one step | Uncovered — prose property (provisioning stated as an end state); verified by reading (task 1.5) |
| A shared service is checked before being declared absent | Uncovered — session behavior |

### MODIFIED — A session's verification does not share mutable external state (2)

| Scenario | Status |
|---|---|
| Two sessions verify concurrently against one service | Uncovered — session behavior |
| The project imposes its own naming form | Covered in part — `workflow-fragment-service-neutral.sh` asserts the workflow fragment states the namespace obligation and prescribes no concrete service. That a name can be expressed in the project's form is prose |

### ADDED — The session obligations are published in the workflow fragment and one binding fragment (4)

| Scenario | Status |
|---|---|
| A session obligation is stated once | Covered in part — `workflow-fragment-publication-set.sh` fixes the set at two and asserts the three replaced fragments are gone. That a future amendment lands in one text is not observable here; it is what the set being this size buys |
| A reader of a project's conventions finds no dangling reference | Covered in part — `workflow-fragment-no-dangling-reference.sh`. The positive half — that the workflow fragment refers to the binding as an adjacent section of the same conventions file, conditioned on the project carrying it — is prose (tasks 1.16, 2.4) |
| A project without a deploy is not served by a conditional | Covered in part — `workflow-fragment-states-assumptions.sh` asserts the four assumptions are named and the two predecessor conditionals absent. That a project of another shape gets its own publication is prose |
| A second publication does not arrive unowned | Uncovered — **not testable by this harness at all**: it constrains what this capability's specification must own when a publication that does not exist is written. There is no artifact to assert against |

### ADDED — A change's stage is named from a fixed vocabulary, and every stage is derivable (7)

| Scenario | Status |
|---|---|
| A resuming session names the stage without interpreting prose | Covered in part — `workflow-fragment-stage-vocabulary.sh` asserts the closed set is stated. The reading of it is session behavior |
| A dispatched review survives the session that dispatched it | Covered in part — `workflow-fragment-gate-log.sh` asserts the artifact the verdict is written to is named. That the verdict is recorded is prose (task 1.9) |
| A review still in flight survives the session that dispatched it | Covered in part — `workflow-fragment-gate-log.sh`. That the dispatch is recorded when made rather than when it returns is prose |
| An operator's confirmation is not lost with the conversation | Covered in part — `workflow-fragment-gate-log.sh` |
| A transient stage is re-entered rather than recovered | Uncovered — prose property; the transient/persistent classification is verified by reading (tasks 1.8, 6.7) |
| Writing tests and running tests are not one word | Covered in part — `workflow-fragment-stage-vocabulary.sh` asserts both names exist and neither crossed form (`plan:verify`, `build:tests`) appears. What each name *means* is prose |
| A change waiting on a deploy is distinguishable from one waiting on a merge | Covered in part — `workflow-fragment-stage-vocabulary.sh` asserts `ship:merged`, `ship:pr-open`, `ship:deployed` and `build:cleared` are distinct stated names |

### ADDED — A change is delivered through at least two pull requests, the last carrying its record (11)

| Scenario | Status |
|---|---|
| Delivery does not begin against unverified work | Uncovered — session behavior |
| The code-review loop does not run unbounded | Uncovered — see *Deliberately untested*, the review bounds |
| A merge and its deploy are confirmed rather than assumed | Uncovered — session behavior |
| A healthy deploy is not confirmation the change worked | Uncovered — session behavior |
| A change with no observable effect reaches its record | Covered in part — `workflow-fragment-gate-log.sh` asserts the artifact the waiver is recorded in is named. The exemption, its classes and the disclosure are prose (task 1.10) |
| The record follows the confirmed effect | Uncovered — session behavior |
| A remedial cycle adds a pull request rather than reusing one | Uncovered — session behavior |
| A failed deploy does not produce a record | Uncovered — session behavior |
| Production is not reached from a local machine | Uncovered — prose property; verified by reading (task 1.10) |
| A deployed change that does not do what it was for | Uncovered — session behavior |
| The wrong change reaches its record rather than stalling | Covered in part — `workflow-fragment-gate-log.sh` (the waiver's artifact). The second waivable class and its successor pointer are prose (task 1.11) |

### ADDED — A change's branches are cut from the trunk, and its post-merge commits have one home (3)

| Scenario | Status |
|---|---|
| The merge confirmation is committed on the change's branch | Uncovered — session behavior |
| A record branch does not re-present the work's diff | Uncovered — session behavior |
| A later session can enumerate a change's branches | Covered in part — `workflow-fragment-gate-log.sh` asserts the enumeration's artifact is named. That each branch and pull request is recorded is prose (task 1.12) |

### ADDED — A session's branch and working tree are removed only against an observable gate (9)

| Scenario | Status |
|---|---|
| Teardown is refused while work is unmerged | Uncovered — session behavior |
| A merged work pull request does not by itself satisfy the gate | Uncovered — prose property (the record's pull request as its own conjunct); verified by reading (task 1.13) |
| A squash-merged change is still removable | Uncovered — prose property (the merge clause read against pull-request state, not ancestry); verified by reading (task 1.13) |
| The abandonment record does not block the teardown it authorises | Uncovered — session behavior |
| An abandoned change's working tree can be removed | Covered in part — `workflow-fragment-gate-log.sh` asserts the abandonment record's artifact is named. Which clauses the record displaces is prose |
| An abandoned branch that was never pushed is still removable | Uncovered — prose property; verified by reading (task 1.13) |
| Abandonment does not authorise discarding uncommitted work | Uncovered — prose property; verified by reading (task 1.13) |
| A later session can read the abandonment rather than infer it | Covered in part — `workflow-fragment-gate-log.sh` |
| Teardown follows the record's pull request, not the work's | Uncovered — session behavior |

### ADDED — A second change surfacing in a session is recorded in the change queue (7)

| Scenario | Status |
|---|---|
| A blocking dependency survives the session ending | Uncovered — session behavior |
| An unrelated improvement is recorded rather than implemented | Uncovered — session behavior |
| An identified change is not filed as deferred work | Covered in part — `workflow-fragment-fixed-paths.sh` asserts both `docs/change-queue.md` and `docs/deferred-work.md` are named, which is what the fragment needs in order to state the distinction. Which one an entry goes to is prose |
| The scope rule and the queue are one obligation | Uncovered — prose property (the seam is stated against an obligation, not a quoted string, precisely so no case can pin it); verified by reading (task 1.14) |
| The change queue does not yet exist | Covered in part — `workflow-fragment-fixed-paths.sh` asserts the path verbatim. The create-it-if-absent direction attached to it is prose |
| A proposal-only branch does not become the session's working branch | Uncovered — session behavior |
| A deferral outlives the change that recorded it | Uncovered — session behavior |

### ADDED — A gate that did not run does not pass, and the project names what runs it (4)

| Scenario | Status |
|---|---|
| A tier that skipped does not report a pass | Uncovered — the obligation is on a consuming project's continuous integration, which this repository's harness cannot observe |
| A claim resting on an uninstalled hook | Uncovered — session behavior |
| A secret takes an override to commit, not an oversight | Uncovered — the obligation is on a consuming project's ignore file |
| The test-authoring dispatch has the inputs it requires | Covered in part — `workflow-fragment-names-test-inputs.sh` asserts the fragment asks the project for both values by name. Whether a given project states them is that project's property |

### ADDED — The database binding fragment states the shared database as an affordance before an obligation (4)

| Scenario | Status |
|---|---|
| A session does not substitute a reachable double for the real database | Covered in part — `database-fragment-affordance-before-obligation.sh` asserts the normative ordering, which is what closes the substitution route. The substitution itself is session behavior |
| Absence is asserted only after looking | Covered in part — the same case asserts the fragment names the container, giving the check-before-concluding rule its subject. The rule's phrasing is prose |
| A skipped tier is not reported as a pass | Uncovered — session behavior. Note this scenario's outcome duplicates one the workflow fragment states, and the same requirement forbids the binding fragment restating it; whether the binding respects that is prose (task 2.5) |
| Two sessions do not share one database | Covered in part — `database-fragment-per-working-tree.sh` asserts the two named subjects. The concurrency itself is session behavior |

### Ledger totals

- 66 scenarios accounted for.
- 22 covered in part by a named case; 0 covered in full.
- 44 uncovered, each with a reason: 27 session behavior, 13 prose property,
  1 deliberately untested (the review bound), 2 a consuming project's
  configuration, 1 not testable by any harness (a property of a
  specification).

No scenario is covered in full, and that is a statement about this harness
rather than about the cases: every scenario in this delta has a prose or
behavioral half, because the capability governs what a document must say.

## Obsolete tests

Every entry below is a **candidate for human confirmation**, not a
conclusion. This pass edited and deleted nothing. Task 5.4 applies these.

Search bound: `tests/cases/**`, the dispatched glob, and nowhere else. No
earlier `test-plan.md` was supplied to this pass, so the mapping from
requirement to case was reconstructed from each case's own header comment
and from `tests/coverage.md`'s `session-workflow` section. A case whose
header names no scenario would not have been found by this search.

### Cases asserting a fragment this change deletes

Each reads a file under `rules/` that task 3.1 removes, so each fails at its
first `assert_file` once the deletion lands.

| Case | Superseded by | Evidence |
|---|---|---|
| `tests/cases/session-fragments-name-fixed-paths.sh` | REMOVED "Session-scoped rules are separate fragments cut by applicability" — its migration deletes both files this case reads | Reads `$TOOLKIT_ROOT/rules/worktree-isolation.md` and `$TOOLKIT_ROOT/rules/deferred-work.md`, asserting each exists and names a fixed path. Replaced by `workflow-fragment-fixed-paths.sh`, which makes the same assertions against the workflow fragment |
| `tests/cases/session-fragments-name-no-sibling.sh` | REMOVED "Session-scoped rules are separate fragments cut by applicability" — the independence property the case enforces is what the requirement's reason gives up | `names="worktree-isolation change-delivery deferred-work"`, `assert_file` on each, then a cross-reference scan among them. Its header names the two adoptability scenarios and "The gate is checkable without a delivery fragment", none of which survives. Replaced by `workflow-fragment-no-dangling-reference.sh`, which enforces the narrower rule that does survive |
| `tests/cases/session-fragment-frontmatter.sh` | REMOVED "Session-scoped fragments declare a kind and, while nothing inlines them, no version" | Loops the three deleted names and asserts `version:` is **absent** — the exact clause the removal lifts. Replaced by `database-fragment-frontmatter.sh`, which asserts a version is present on the new fragment |
| `tests/cases/deferred-work-states-workflow-seam.sh` | REMOVED "A second change surfacing in a session is recorded, not carried" — its reason states the reconciliation scenario is written for a project carrying a separate deferred-work fragment, a pairing consolidation removes | `fragment="$TOOLKIT_ROOT/rules/deferred-work.md"`, then asserts that file names `development-workflow`. Both the subject and the cross-fragment seam are gone; the seam is internal in v3 |
| `tests/cases/change-delivery-names-no-working-tree.sh` | REMOVED "A change is delivered through a pull request that carries its own record", and the new delivery and teardown requirements, which name a working tree throughout | `fragment="$TOOLKIT_ROOT/rules/change-delivery.md"`, then fails if the fragment matches `worktree|working[- ]tree`. In v3 that scan would fail on a compliant fragment — the case asserts the inverse of what the change requires |

### A case that will keep passing and is obsolete anyway

| Case | Superseded by | Evidence |
|---|---|---|
| `tests/cases/session-fragments-not-inlined.sh` | REMOVED "Session-scoped fragments declare a kind and, while nothing inlines them, no version" — this case exists solely to guard that requirement's premise | Its header: "Scenario: A fragment is adopted without tooling (premise half). The absent-`version:` rule holds only 'while nothing inlines them'." It reads only `scripts/project-init`, never the fragments, so **it will still pass after the three files are deleted** — it becomes a green case guarding a requirement that no longer exists. Flagged because the suite reports nothing about it either way; deleting it is a judgment, and leaving it is a silent one |

### Cases coupled to the workflow fragment's version — judged to survive

Examined per task 5.2. No obsolete entry is made for any of these:

- `tests/cases/inlined-body-matches-fragment.sh` — reads the version through
  `fragment_version()` and extracts the fragment's body from the second
  `^---$` onward, then diffs it against what `project-init` inlined. Both
  sides move together with a version bump. Its extraction anchor
  (`Project-specific conventions belong below the closing marker. -->`) is
  `project-init`'s own generated notice, not fragment text, so v3's content
  does not reach it.
- `tests/cases/managed-block-current-version.sh` — builds its fixture from
  `fragment_version()`, so the fixture is v3 the moment the fragment is.
- `tests/cases/managed-block-older-version.sh` — pins `v0` in its fixture
  only, and reads the tool's own version through `fragment_version()`. v0
  remains older than 3.

### A case at risk from v3's new text — not obsolete, but named

`tests/cases/fragment-role-before-tool.sh` scans the whole workflow fragment
for harness-specific tokens (`ai-toolkit:`, `PROCEED`, `CHANGES REQUIRED`,
`REJECT`, `[MINOR]`, `openspec-`, a backtick-quoted slash command) outside a
`_Claude Code binding:_` paragraph, and its awk resets the binding state on
the **first blank line**. v3 adds delivery, teardown and archive text with
bindings of its own (task 1.10 requires the archive step be a role with the
specification tooling named beneath it). A binding written as more than one
paragraph will leak its second paragraph into the scan and fail this case.

That failure would be a real finding under `project-bootstrap`, not a defect
in the case, so it is **not** an obsolete entry. It is recorded here because
it is the most likely way this change turns a green case red for a reason
the implementer will otherwise read as unrelated.

### Where no bearing test was found

For the two MODIFIED requirements that gain substance rather than retarget —
the report's fixed row, and the one-branch rule's reconciliation with
delivery's further branches — **no existing case bears on the superseded
text**. This is "no such test exists", not "none was found": the suite's
only cases reading the workflow fragment are
`fragment-role-before-tool.sh` and `inlined-body-matches-fragment.sh`,
neither of which asserts anything about the report or the branch rule, and
`tests/coverage.md` records the predecessor's report scenarios as uncovered.

## Unresolved project questions

Each records the assumption taken and which tests depend on it.

1. **The runner has no single-case selector.** `bash tests/run.sh`
   discovers and runs every file in `tests/cases/*.sh`; nothing accepts a
   filter, and `tests/README.md` documents no per-case invocation.
   *Assumption taken*: a single case is run by supplying the three
   variables `run.sh` exports (`TOOLKIT_ROOT`, `TESTLIB`, `TESTDIR`) by
   hand, as shown under *New cases*. *Depends on it*: nothing in the cases
   themselves — only the ability to satisfy this manifest's obligation to
   name tests in a runner-selectable form. Verified working for all eleven
   new cases.

2. **The suite omits `set -euo pipefail`, which the `bash` skill's floor
   requires.** No case in `tests/cases/` sets any shell option; `run.sh`
   sets `-u` alone. Reporting the conflict rather than resolving it, per
   that skill's own rule. *Assumption taken*: the established style is the
   project's convention and the eleven new cases follow it, relying on
   `lib.sh`'s helpers and explicit `exit 1` guards instead. *Depends on
   it*: all eleven. Every guard was written so that a missing or empty
   extraction fails the case rather than skipping past it, which is what
   `set -e` would otherwise have been asked to cover.

3. **Whether an obsolete case is deleted or rewritten is not recorded
   anywhere.** `tests/README.md` and `AGENTS.md` state no convention for
   retiring a case, and `tests/coverage.md` keeps a row per case rather than
   per requirement. *Assumption taken*: none — the six entries above are
   left as candidates and this pass performed no deletion. *Depends on it*:
   task 5.4's execution, not any test.

4. **`tests/coverage.md` is outside the dispatched test-path glob.** Task
   5.3 owns rewriting its `session-workflow` section. This manifest does not
   write it. What that rewrite must now say: the section's present count of
   37 scenarios and its three-fragment framing are both false; the new count
   is 66, the ledger above supplies each row, and the six rows for the
   obsolete cases come out.
