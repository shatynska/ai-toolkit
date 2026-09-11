# Test plan — state-the-committed-artifact-situation

Derived from this change's delta spec before any implementation exists, by an author who wrote none of it. This file is not an artifact the OpenSpec schema knows about: it does not appear among `openspec instructions apply`'s context files and must be read on purpose before implementing.

The pass is additive only. Four case files were added under `tests/cases/`; no existing test was edited, deleted or disabled, and no implementation was written.

## Baseline

Full suite, taken before any case was written: `bash tests/run.sh` from the repository root at commit `2dcdca6`, working tree clean — **51 passed, 0 failed**.

After this pass: **51 passed, 4 failed**. The 51 are the same 51; the 4 are the cases below, each failing on the real file for the property it exists to assert. That is the expected state of a pass that precedes implementation.

## The tests, and how to run one

The suite has no per-case selector. `bash tests/run.sh` runs everything; a single case is run directly, with the four variables `run.sh` exports supplied by hand:

```
TOOLKIT_ROOT="$PWD" TESTLIB="$PWD/tests/lib.sh" \
  PROJECT_INIT="$PWD/scripts/project-init" TESTDIR="$(mktemp -d)" \
  bash tests/cases/<name>.sh
```

| Case | Asserts |
|---|---|
| `tests/cases/testing-skill-three-situations.sh` | The situations section enumerates three situations, draws the line on whether the assertion executes the behaviour it asserts, does not draw it on what the target can do, and leaves no two-way phrasing behind anywhere in the file |
| `tests/cases/testing-skill-discriminator-obligation-placement.sh` | `fixture-driven discriminator` is named in the situations section; the negative result's repair-or-report routing is stated there too; the baseline section does not carry the discriminator record |
| `tests/cases/testing-skill-failure-states-situation-conditioned.sh` | The failure-states section names the third situation and no longer routes by the target's presence or states two-way claims |
| `tests/cases/testing-skill-discriminator-bound.sh` | The classification section states what a fixture-driven discriminator is for, states it by what a case falsifies, and states no numeral or percentage |

Each case reads `skills/testing/SKILL.md` under a root it is given, so it can be pointed at material the test supplies. Each runs its own check twice: once over `$TOOLKIT_ROOT`, and once over a falsifying fixture written into `$TESTDIR`. A case whose check passes over the falsifying fixture fails with that as its message.

## What each case is red on, at authoring

Recorded now, while an author is present, so the later green is readable as a transition rather than as a check that was always green. Every one of these is a property the committed file does not yet carry; none is red for a reason unrelated to the change.

- `testing-skill-three-situations.sh` — the section enumerates 2 situations, not 3; neither half of the separator is stated; all three superseded two-way phrasings survive.
- `testing-skill-discriminator-obligation-placement.sh` — the situations section names no fixture-driven discriminator and states no repair-or-report routing. The baseline-section negative is **green already**, and vacuously so: the term appears nowhere in the file. Its discrimination comes from the fixture half, not from the real-file half.
- `testing-skill-failure-states-situation-conditioned.sh` — the section names no third situation, and all three superseded phrases survive.
- `testing-skill-discriminator-bound.sh` — the classification section states neither the term nor the bound. The no-quantity negative is **green already** and vacuous for the same reason, and likewise rests on the fixture half.

## What this suite establishes, and what it does not

**Corrected after the third code review, against mutation evidence rather than against this pass's reasoning.** An earlier version of this section justified one fixture per case on the delta's own bound. Mutation falsifies that justification: deleting a scan and re-running detects **4 of 13**. The nine survivors are masked by their neighbours in the same `check()`, because one fixture trips several scans at once and the attribution names only one.

So, stated plainly: each case establishes that its check can fail **on the one property its attribution names**, and establishes nothing about its other scans. Two scans — the baseline-section negative and the no-quantity negative — are green vacuously and were green vacuously at authoring; their deletion is invisible. They are recorded here as **deliberately untested by this pass**, not as covered.

The unsettled question underneath it, which no artifact of this change answers: the bound says a discriminator falsifies *the check* once. If a **case** is the check, one fixture is right. If a **scan** is the check, thirteen are owed. `docs/change-queue.md` carries this as `discriminate-every-scan-in-the-static-suite`, with the mutation table.

## The fixture-driven discriminators, and their bound

Each case supplies one falsifying fixture, and one only. Each was run and observed to reject the check: with `TOOLKIT_ROOT` pointed at a compliant stub, all four cases exit 0, which is reachable only if the check returned non-zero over the fixture.

A second fixture case per check was considered and **not** added. Under a check weakened to scan the whole file rather than the named section, each existing fixture already falsifies — so an additional case isolating the placement property falsifies nothing the existing one does not. By the bound this change itself states, such a case would be a derived assertion added because it is expressible, and the cheaper answer is not to add it.

No discriminator here was unrunnable. Nothing is owed on that account.

## Scenario accounting

Twenty-two `#### Scenario:` blocks across the delta's three MODIFIED requirements. Ten covered, twelve uncovered with reasons. The `RENAMED` operation carries no scenarios of its own — the renamed requirement's thirteen are the first block below — and implies no test change.

### Requirement: The Skill States the Situations It Can Be Entered In (13)

| Scenario | Status |
|---|---|
| A test passing on first run is read correctly in each situation | Covered (mechanical half) — `testing-skill-three-situations.sh`, which asserts the three-way enumeration and that the two-way reading of the first-run pass does not survive. That each of the three readings is stated *correctly* is prose |
| A reader can tell which rules are in force | Covered (mechanical half) — `testing-skill-three-situations.sh`, via the closing "binds in both" phrase, which cannot be true of three situations |
| A static read is not mistaken for a covered behaviour | Covered — `testing-skill-discriminator-obligation-placement.sh` |
| A discriminator that fails to falsify says the check asserts nothing | Covered (mechanical half) — same case, via the repair-or-report routing being stated in the third situation's own text. That the skill treats the result as establishing the check asserts nothing is prose |
| A negative finding reported rather than repaired is still recorded | Covered (negative half only) — same case asserts the record is not filed in the baseline. That it *is* filed where the project records the classification is prose with no token to key on |
| A check that cannot be pointed at supplied material is redirected, not excused | Uncovered — a proposition the requirement obliges without fixing any token. A case matching one author's phrasing of it would fail a compliant rewording. Verified by reading |
| A check red at authoring discriminates once and still owes a fixture | Uncovered — same reason. The longest and most conditional of the delta's paragraphs, and the one with the least mechanical surface |
| The third situation is distinguished from the second by what the assertion executes | Covered — `testing-skill-three-situations.sh`, both halves of the separator plus the rejected `can behave` criterion |
| A check written before the rule is undischarged rather than in breach | Uncovered — prose; no token. Verified by reading |
| A discriminator that cannot be run here is recorded rather than assumed | Covered (negative half only) — `testing-skill-discriminator-obligation-placement.sh` asserts the record is not in the baseline, which is the half the requirement states twice with reasons. The positive surface is prose |
| An edit to shared machinery does not sweep in every check that delegates | Uncovered — prose; no token. Verified by reading |
| A read extracted into shared machinery does not move a check in or out of scope | Uncovered — prose; no token. Verified by reading |
| A static check whose target is absent is read as the first situation | Uncovered — prose; no token. Verified by reading |

### Requirement: Failure States Are Defined by What They Establish (5)

| Scenario | Status |
|---|---|
| A state name does not presuppose one execution model | Uncovered — carried through verbatim by the MODIFIED operation; it states behaviour this change does not alter, no existing case covers it, and the change's own scope owes no retrofit |
| A test that passes before implementation is treated as a defect | Uncovered — carried verbatim; same reason |
| The first-run alarm is not relied on where it cannot discriminate | Covered (mechanical half) — `testing-skill-failure-states-situation-conditioned.sh`. That the alarm is stated to fire on every such check, sound ones included, is prose |
| A specified assertion that fails is never classified as a broken test | Uncovered — carried verbatim; same reason |
| An absent target does not vouch for the assertions | Uncovered — carried verbatim; same reason |

### Requirement: Asserted Behavior Is Separated into Specified, Derived, and Deliberately Untested (4)

| Scenario | Status |
|---|---|
| An invented assertion is visible as invented | Uncovered — carried verbatim; same reason as above |
| An uncovered case is recorded rather than dropped | Uncovered — carried verbatim; same reason |
| A discriminating case that falsifies nothing further is labelled | Covered (mechanical half) — `testing-skill-discriminator-bound.sh`, via the term and the `falsif` root being stated in the classification section. That such a case is required to be *labelled derived* is prose |
| The bound is stated without a quantity | Covered (partially) — same case scans the section for a numeral or a percent sign. A quantity written in words is not reachable: no scan separates a counted bound from the ordinary English numbers the section already uses |

## Assertion provenance

**Specified** — traces to a sentence of the delta:

- Three situations enumerated in the situations section.
- `does not execute the behaviou?r it asserts` and `executes the behaviou?r it asserts` in that section — the delta fixes this wording as one test rather than two.
- `fixture-driven discriminator` present in the situations section (the delta's "SHALL name it there") and in the classification section (the delta's "the term as *The Skill States the Situations…* defines it").
- Repair-or-report routing in the situations section (the delta's "SHALL say this in the third situation's own text").
- The discriminator record absent from the baseline section (the delta states this twice, with reasons).
- `falsif` present in the classification section — the bound's own content.
- No numeral or percent in the classification section (the delta's "SHALL NOT state a number of cases, a proportion, or a size").
- The failure-states section naming the third situation (the delta's "The fourth state SHALL carry its third-situation reading explicitly" and "The condition SHALL be the situation rather than the target's presence").

**Derived** — the test author's choice, with no stated requirement fixing it:

- Every *token* chosen as the mechanical proxy for a stated proposition: `repair` as the proxy for repair-or-report, `falsif` for the bound, `discriminates among none` for the fourth state's reading, `[0-9%]` for a quantity. The requirement fixes the proposition, not the word.
- The three superseded phrases in `testing-skill-three-situations.sh` and the three in `testing-skill-failure-states-situation-conditioned.sh`. Each is quoted from the change's own task list, not from the delta; the delta obliges the corrected claim, and the surviving phrase is a proxy for its absence.
- `can behave` as the rejected criterion. It traces to `design.md`'s Decision 1 and to task 1.6, not to a delta sentence.
- Anchoring every scan on a `## ` heading, and the heading strings themselves. The delta fixes no heading name; `tasks.md` says the situations heading is left alone. A renamed heading makes the case fail loudly rather than pass vacuously, which is the safe direction but is a maintenance coupling worth knowing about.
- Accepting both spellings of "behaviour". The delta is British, the skill American; the requirement does not choose.
- The lower bound of three bulleted situations rather than exactly three.

**Deliberately untested** — identified and left uncovered:

- The twelve scenarios recorded as uncovered above, each with its reason.
- ~~That the skill does not present the fixture obligation as optional rigour. It is a prohibition on a tone, with no token.~~ **Superseded:** the third code review's mutation showed the obligation paragraph deletable with the suite green, so a token was found after all — `not optional rigou?r`, scanned in `testing-skill-discriminator-obligation-placement.sh`. Classified **specified**: it traces to the delta's "SHALL NOT present it as optional rigour". Added after this pass and folded back here rather than left unclassified.
- That the obligation is scoped to a check as authored or modified, and the shared-machinery clause in either direction. These are the delta's most carefully argued paragraphs and its least mechanical; a case asserting them would be asserting one author's sentences.
- The ordering of the bound within the classification section. `tasks.md` 3.4 fixes it as a reading; the delta does not, and a case anchored on an unamended paragraph would fail on a reword the requirement does not care about.

## Obsolete tests

**No bearing test exists.** This is not "none was found" — the search was exhaustive over the dispatched glob, and the glob is 55 files.

Evidence: `grep -rn "SKILL.md\|skills/" tests/cases/` returns exactly one hit outside the four cases added here, in `tools-passthrough.sh`, and it asserts a generated `.agents/skills/` tree in the temporary working directory, not the library's own. `grep -rlni "situation\|discriminat\|failure state\|first run" tests/cases/` returns three files, all unrelated on inspection: two match `first run` in a `project-init` invocation, and `workflow-fragment-trunk-return.sh` matches `discriminating` in a comment about a `rebase` token.

No case under `tests/cases/` read `skills/` before this pass, so the three `MODIFIED` requirements and the one `RENAMED` one supersede nothing any existing test asserts. Nothing is proposed for deletion or rewriting, and no entry is offered for human confirmation because there is none to offer.

No earlier `test-plan.md` exists for this change, so none was available as a scenario-to-test mapping.

## Unresolved project questions

**Whether a case may read `skills/`.** `AGENTS.md` records that `tests/` "holds a dependency-free harness exercising `scripts/`", which read literally says no case is owed here. The practice disagrees: twenty-six of the fifty-one existing cases assert statically over a path under `agents/` or `rules/`, reading a committed library asset without running anything. `tasks.md` 4.2 names this drift and asks for a determination.

The assumption taken: **the practice governs, and the convention line has drifted.** A case reading `skills/testing/SKILL.md` is owed and is the same kind of case as the twenty-six. All four cases above depend on this; if the determination goes the other way, all four are misplaced and this change's delta has no test surface anywhere in the repository. The convention line is worth correcting, but correcting it is an edit to `AGENTS.md` and outside both this pass and, on the proposal's own *Impact*, this change.

**Whether this suite's cases carry a safety preamble.** The `bash` floor calls for `set -euo pipefail`; no existing case under `tests/cases/` sets any shell option, relying instead on assertions that exit on failure. The assumption taken: match the suite. All four cases are written without a preamble and check every status explicitly. ShellCheck runs clean over all four.

## Notes for whoever implements

- The four cases are the acceptance surface for tasks 1.0–1.3, 1.6, 1.13, 2.1–2.3 and 3.1–3.3. Every other task in sections 1–3 is prose the suite does not reach, and sections 4 and 5 are determinations rather than edits.
- The failure messages name the property, not the wording, so a compliant amendment in any phrasing turns them green. Where a case fails on a phrasing you consider compliant, that is a defect in the case — report it rather than weakening the case to pass.
- Task 4.1's regression run is unaffected: the 51 pre-existing cases pass unchanged with these four added.
