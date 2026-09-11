---
name: testing
description: >
  This skill should be used when the user is writing, reviewing, or debugging
  tests in any language - "write tests for this function", "review my tests",
  "is this test any good", "why does this test pass when it shouldn't". It
  covers language-agnostic discipline: recording a baseline before any claim
  that a test fails, the four states a failing test can be in and what each one
  actually establishes, why an absent target must never be resolved by writing
  the code under test, choosing a test's level, separating assertions that trace
  to a stated requirement from ones the author invented, and never weakening or
  deleting a test to reach green. It carries no framework or runner specifics:
  for those, load python, langgraph, bash or terraform alongside it - this skill
  supplies the standard, those skills supply the idiom and carry its
  version-dated verification. Not for authoring library assets (create-skill,
  create-agent), OpenSpec proposals or reviews, or n8n workflow audits.
metadata:
  tags: [testing]
---

# testing

General-purpose practice for writing, reviewing and debugging tests. Like `bash`, `python` and `terraform`, this is a floor: what holds regardless of language, test runner, or what the code is for. It is not a tutorial on how to write a test, and not a coverage policy.

Nothing here depends on a version of anything, so — unlike this library's language and tool skills — this skill carries no "verified live against version X" line. That is deliberate, not an omission: it makes no claim such a statement would qualify. Anything version-dependent belongs to the skills named under *Language and framework specifics*, which carry that verification.

Where a failure message or command appears below, it is an illustration of a distinction, not a claim about how a named tool behaves.

## Which situation you are in

Three situations, and one central rule reads differently in each. Establish which one applies before anything else.

- **The target does not exist yet.** Tests are written against a stated requirement before there is any implementation to observe.
- **The target already exists.** Tests are written for code that is already there, whether or not it was ever covered.
- **The assertion does not execute the behaviour it asserts.** It is a static read: a configuration file, a workflow, a manifest, a document, the source of a program it never runs, or a module imported only so a constant can be read out of it. The assertion's subject is not something the check exercises, so a pass reports only that the target could be read.

**A test that passes on its first run means different things across the three.** Where no implementation exists, nothing could have satisfied it, so a pass is an alarm — the test asserts nothing, or the behavior was already there. Where the code already exists, a pass is the expected result and establishes that the code currently behaves as asserted. Where the assertion does not execute the behaviour it asserts, a pass establishes nothing at all: a check that read nothing would pass identically.

### Telling the second situation from the third

**One test, not two: whether the assertion executes the behaviour it asserts.** Where it does, a pass reports that behaviour and the second situation applies. Where it does not, the third does. Loading the target is not exercising the asserted behaviour — a module imported so a constant can be read out of it runs on import and exercises nothing the assertion is about. Committedness is not the test in either direction: code that already exists is committed and stays in the second situation, and that same code's source, read statically by an assertion that never calls it, sits in the third.

The three situations read one test at one moment; they do not partition tests. A static check whose file does not exist yet is in the first situation while that holds — its failure establishes the file's absence and nothing about the assertions — and in the third once the file is present. Resolve by what is true when the question is asked, not by the test's history.

### What the third situation obliges

A check that is green — its target carrying the asserted property at the time the suite runs — passes without discriminating, so establishing that it can fail means running it over material the test itself supplies. A test that does this is a **fixture-driven discriminator**. It is what makes such a suite's green result mean anything, and it is not optional rigour. The mechanism the fixture belongs to is the project's: a temporary directory, a string, an in-memory map all serve.

### Reading a discriminator's result

**A discriminator that comes back negative establishes**, because that is the finding this mechanism exists to produce: where the check passes over material chosen to falsify it, the check asserts nothing. That is the fourth failure state's second branch, reached deliberately rather than stumbled on. Repair the check or report it; never leave it standing in the suite as coverage. Where it is reported rather than repaired, the author records the finding — inside the authoring pass, before it ends, wherever the project records the classification and its reasons — saying what was found and why the check was not repaired. A check known to assert nothing, reported only in conversation, is this mechanism's own finding lost at the last step.

### What it assumes, and when it cannot be run

**What the obligation assumes about the check**: that what it reads can be pointed at material the test supplies. Where a check already in scope — one being authored or modified — is not so written, its target path fixed and redirectable only by rewriting how it reads, redirecting it is part of modifying it. That is not a discriminator that could not be run, which is a different fact with a different remedy.

**Where the discriminator can be written but not executed here**, the author records that — inside the authoring pass, before it ends — with the reason, in the form the baseline rule below defines for a baseline that cannot be taken. Neither treating it as discharged nor reporting a run that did not happen will do. Record it wherever the project records the classification and its reasons — not in the baseline: the baseline is about the suite before these tests were written, this is a fact about one test in this pass, and a reader sweeping for outstanding discriminator work does not look there.

### Which checks it reaches

**The obligation attaches to a check as it is authored or modified.** Modifying one means a change to what the check asserts, or to how it reads its target — never an edit to the file that contains it, so a rename, a reformat or an edit to a neighbouring check pulls nothing in. Where reading is delegated to shared machinery, editing that machinery brings a check into scope only where that check's own assertion or its own result changes: a shared edit does not sweep in every check that delegates, and extracting a read into a helper does not take one out of scope. Where an extraction changes neither the assertion nor the result, this sentence governs and the check stays out of scope. A check that predates the rule carries an undischarged obligation, not a violation; no suite is retrofitted.

### Who discharges it

A fixture-driven discriminator supplies its own material, so it does not depend on the target's state: it is written beside a check that is still red, in the same pass, by the same author. The fixture never waits for the check to go green — nothing re-dispatches a test author at that moment, and an obligation falling due after the pass has ended is owed by nobody.

**What an observed failure establishes.** A check written against a property its target does not yet carry is red at authoring and goes green as the change lands, and that transition establishes that the check discriminates — on real content rather than on a fixture. The author records it, inside the authoring pass before it ends, on the surface named above and not in the baseline: that the check is red and on which property. No second record is owed once it goes green; the ordinary suite result is the confirmation, and the later green is read against that record. The fixture is still owed all the same, because the red run leaves nothing in the suite: nothing re-establishes the property afterwards, and a later edit can stop the check asserting with no result changing. Where tests are derived before implementation every check is red at authoring, so an exemption here would exempt every check in such a project.

### Which rules bind where

Rules that presuppose an absent target — the absent-target rule below — bind only in the first situation, and the fixture obligation above binds only in the third. These bind in all three: the baseline, the level rule, the specified/derived classification, and never weakening a test.

None of this is an argument for writing tests first. It records what each situation does and does not establish; which one a project works in is not this skill's concern.

## Take a baseline first

**Before writing any test, run what exists and record what already fails.** Without that, a later report that "the new tests fail" is uninterpretable — the new test's contribution cannot be separated from what was broken beforehand.

A **scoped** baseline — covering the tests that bear on the target, recorded together with its scope — is a first-class option, not a fallback. The purpose is attributability, which a scoped run satisfies. Treating a full-suite run as mandatory on every small request buys nothing and creates a fixed cost whose predictable outcome is skipping the baseline silently.

Where not even a scoped baseline can be taken — no suite exists, no runner is configured, the suite cannot execute here, or it is executable but impractical (prohibitively slow, or needing credentials or services unavailable here) — **state that no baseline was taken, and why, alongside any later claim about failure.** Neither treating the requirement as satisfied nor reporting a baseline that was not run is acceptable.

Record the baseline in the completion report, or alongside the tests, or wherever the project already records such things — but record it somewhere, not nowhere.

## What a failing test establishes

A failing test is not one thing. Four states, each defined by what it establishes — never by the phase, error class, or exit status that produced it, because those differ per language and some languages give no per-test granularity at all.

The enumeration below is stated for the absent-target situation. In the second situation the second and fourth states read differently, per *Which situation you are in*; in the third situation the fourth state reads differently and the second cannot arise at all, there being no target to be absent. State 3 is the same in all three situations. The condition is the situation, not the target's presence — presence spans the second and third situations and reads differently in each.

1. **The code ran and produced a wrong value.** The strongest state: the test executes *and* discriminates between correct and incorrect behavior.
2. **The target does not exist yet.** It establishes that the target is absent and nothing more. The assertions never executed, so whether they are any good is still unverified. Do not report this as though the assertions had been exercised.
3. **The test itself is broken.** The failure comes from a defect in the test rather than from the behavior it covers, so it establishes nothing about the code — in any situation. Repairing the defect does not turn it into evidence; it only moves the test into one of the other states, which is where its result first becomes readable. Reaching this state requires the rule below; it is never assigned on the bare fact that a test failed.
4. **It passed on its first run, before any implementation existed.** An alarm, not a result: either the behavior already exists, or the test asserts nothing. Investigate it. Never record it as coverage.

The fourth state reads differently where the assertion does not execute the behaviour it asserts. There is no implementation to arrive early: a check whose target already carries the asserted property passes on its first run for that reason alone, so the alarm fires on every such check — sound ones included — and discriminates among none of them. Answer the pass with the fixture obligation in *Which situation you are in*, not by investigating the pass itself. A check that is instead red at authoring does not raise the fourth state at all.

### Telling the first state from the third

States 1 and 3 present as the same event — an asserted value that does not match the produced value — and without a rule, state 3 becomes a re-description available for any failure at all. **The assertion's provenance decides**, using the classification under *Specified, derived, deliberately untested*:

- A **specified** assertion that does not match means **the code is wrong**. State 1. The test is not a candidate for repair, whatever it looks like: the value it asserts traces to a stated requirement, not to your judgment.
- Only a **derived** assertion may be reconsidered — and reconsidering it is recorded as a change to a derived assertion, never performed as a repair.
- A defect that is not in the expected value at all — a wrong import, a wrong call, malformed setup or a broken fixture — is state 3 regardless of provenance, because the test never reached the point of asserting anything.

Without this rule, *Never weaken a test to reach green* is satisfiable by relabelling: edit the assertion to the observed value, call it repairing a broken test, and no stated rule has been broken while doing exactly what that rule exists to prevent.

Beyond this provenance rule, working out which state a given failure is in is language-specific — see *Language and framework specifics*.

## An absent target is not a problem to fix

When tests are written first, failing because the code under test does not exist is the expected outcome. **Do not create the missing module, function, type, or an empty stub so the tests can execute.** That is writing implementation, and it is the single most likely point at which a test-writing pass drifts into one — because creating the missing target presents itself as repairing the tests.

This rule has a scope and a lifting condition:

- It binds **while the current task's scope is writing tests**.
- Where the same task also authorises implementation — the ordinary case of "build me this, with tests" — it **lifts once the target-absent failure has been reported**, and the implementation is then written as a distinct, announced step rather than as a repair to the tests.

What stays prohibited throughout is creating a target *in order to make tests execute*. That motive is distinguishable from implementing under an authorised step, and it is what the rule is aimed at.

## Choosing the level

**The level is the smallest unit that can observe the expected outcome.**

Read what the behavior actually requires in order to be visible: if a plain function call can observe it, that is the level; if it needs components wired together, or persistence, or a process boundary, the level rises to meet it — and no further. A level above that minimum buys no additional evidence while costing speed and determinism.

This resolves level questions without appeal to preference or to a target ratio between test kinds.

## Specified, derived, deliberately untested

Every assertion is one of three things, and which one is recorded, not left implicit:

- **Specified** — it traces to a stated requirement.
- **Derived** — you inferred it; no stated requirement covers it.
- **Deliberately untested** — a case you identified and knowingly left uncovered, recorded with the reason.

An unlabelled derived assertion obliges whoever implements the code to satisfy a constraint nobody agreed to. That is the test author quietly designing behavior. Labelling makes each invented assertion visible for review instead of indistinguishable from a stated requirement — and it is what makes the provenance rule above usable at all.

An uncovered case is recorded with its reason rather than omitted, so that the absence of a test is distinguishable from the absence of the thought.

**What a fixture-driven discriminator is for** — the term as *Which situation you are in* defines it — is what bounds how much of one is warranted. Its job is to establish that the check can fail, by falsifying it on the property the check exists to assert. It is not an enumeration of the check's input space. A case added because it is expressible rather than because it discriminates is a derived assertion like any other, and is labelled accordingly. There is no number here, no proportion and no size: the bound is what a case establishes, which is reviewable, rather than how many there are, which is not.

Record these where the project records such things — the completion report, an annotation beside the tests, or an existing convention. The point is that the classification survives past the moment of writing.

## Never weaken a test to reach green

**Do not edit an assertion to match what the code produced. Do not delete or disable a failing test to reach a green suite.**

A test altered to fit the code it was written to constrain records the code's current behavior instead of constraining it — and the suite reports success either way, so nothing in the output says this happened.

Describing such an edit as *repairing a broken test* does not exempt it. For a specified assertion the provenance rule above forecloses that route: a specified assertion that does not match means the code is wrong, and the test is not a repair candidate.

Where a requirement has genuinely changed and an existing test now asserts superseded behavior, **report that test as superseded** rather than quietly rewriting it, so the change is visible instead of absorbed into a routine edit.

## Reviewing or debugging rather than writing

Not every entry into this skill is a request to write a test. Two other entries are common, and the rules above apply to them — some directly, some not at all.

**Reviewing existing tests.** The specified/derived/deliberately-untested classification *is* the review question: does each assertion trace to a stated requirement, or did its author invent it? An unlabelled derived assertion is the most common real finding. The provenance rule and the never-weaken prohibition apply unchanged.

**Debugging a test whose result looks wrong.** The four failure states are the diagnostic vocabulary. A test that passes when it should not is the fourth state — treat it as a defect in the test, not as coverage. A test failing for a reason that is not the behavior under test is the third state, and the provenance rule says whether it really is.

**What does not apply on these entries:** taking a baseline before writing, and choosing a level for a test that already exists. Those presuppose an authoring pass. Do not apply them to a review or a debugging question.

## Read the project's conventions first

This skill is a floor, not an authority. A consuming project's `AGENTS.md`, `CLAUDE.md`, and existing tests override it wherever they conflict — **except as bounded below**. Read those first in an unfamiliar repository, and report a conflict rather than silently resolving it.

Where a question turns on a project decision — which runner is used, where tests live, what the project calls its levels, which stacks it stubs — and the project records no convention at all, say so and ask rather than supplying an answer from assumption. A repository with nothing recorded is the normal case, not an edge case.

**Two rules do not yield to a project convention:**

1. Weakening, deleting, or disabling an existing test **to reach green**.
2. Resolving an absent target by writing the code under test, within the scope stated above.

A convention permitting either does not adapt the practice to local circumstances — it removes what the practice is for, and a floor that defers on those two points asserts nothing at all. This is not licence to act against a project unannounced: the conflict is still **reported**, not silently resolved.

Everything else defers in the ordinary way — level vocabulary and boundaries, where classifications and baselines are recorded, which stacks are stubbed.

## Language and framework specifics

This skill states no framework, runner, or library specifics, and carries no version-dated claims. **Load the matching skill alongside this one, before writing the tests** — each is verified against its own tool's version, which this skill cannot track:

- `python` — pytest structure, fixtures, parametrisation, what makes an assertion meaningful in Python.
- `langgraph` — stubbing a tool-calling model, testing a node as a plain function versus testing routing, checkpointer-backed state across turns.
- `bash` — testing shell scripts, and ShellCheck as a necessary-but-not- sufficient check.
- `terraform` — `terraform test`, plan-time validation, and what can be asserted without applying.
- `ansible` — `ansible-lint`, `--check`/`--diff` as a dry-run with known check-mode gaps, and Molecule as a role-level test harness.

A skill named here may currently carry little on testing. That is a fact about its present state, not about its scope — it is still where that stack's testing material belongs, and still where it should be added.

One further skill belongs in this section for a different reason than the five above: not a runner or framework with a version to pin, but a modeling discipline applied on top of whichever stack is in use.

- `ddd` — testing an aggregate's or value object's invariants with no I/O, as distinct from testing through a repository port. Unlike the skills above, this is not framework- or runner-specific and carries no version-dated claim; it's named here because `testing-practice` requires every domain skill covering a testable artifact to be reachable from this list, not because it fits the "load the matching runner" pattern the rest of this section describes.

## Trigger check fixtures

The prompts this skill's authoring verified against, kept so a later edit to the description can be re-verified against the same set rather than a newly invented one. Only the prompts and their expected routing are recorded — never the outcome or the run date, since a description edit invalidates whatever was last confirmed.

**These fixtures are evaluated under a non-standard pass criterion.** Overlap with a language skill is this skill's intended relationship, not a defect: it supplies the standard, the language skill supplies the idiom. So a prompt routing to **both** this skill and a language skill is a **pass**. Only displacement is a failure — this skill reached where a language skill should have been, or a language skill reached where this one should also have fired. A later run must apply that criterion; read against the ordinary exclusive-routing standard, the first fixture below looks like a regression when it is the intended behaviour.

- **Positive, authoring** — "Write tests for this function in my Python module." → expected routing: `testing` **and** `python` together.
- **Positive, authoring (terraform)** — "How do I test this Terraform module before I apply it?" → expected routing: `testing` **and** `terraform` together, the same co-trigger pattern as the Python fixture above: `terraform` is named explicitly in this skill's own description ("load python, langgraph, bash or terraform alongside it"), so the overlap is the intended relationship, not a defect. Contrast `ansible`, which this skill's description does not name — a testing-shaped Ansible prompt was confirmed to route to `ansible` alone (see `ansible/SKILL.md`'s own trigger fixtures).
- **Positive, review/debug** — "Why does this test pass when it shouldn't?" → expected routing: `testing`. Recorded separately because the description claims three surfaces — write, review, debug — and an authoring prompt alone cannot establish that the other two fire.
- **Negative** — "Our test suite takes 40 minutes in CI. How should we split it across runners?" → expected routing: none. This is CI infrastructure and suite-parallelisation strategy, which this skill's scope excludes, and no asset in this library covers CI pipeline shape — `terraform` explicitly disclaims it. Recorded as a determination, so an asset added later that *does* cover CI falsifies this fixture visibly rather than silently.
- **Displacement probe** — "Review my Python script for bugs." → expected routing: `python`, without `testing`. This exists because the accepted overlap above has a failure mode the other three cannot detect: this skill crowding out the language skill on a prompt that was never about tests.
- **Positive, authoring (ddd) — reversed entry point** — "How do I test that my Order aggregate's invariants hold, without hitting the database?" → expected routing: `ddd` **and** `testing` together, but via the opposite direction from the Python/Terraform fixtures above: this skill's own description does not name `ddd` (unlike `python`, `langgraph`, `bash`, `terraform`), because `ddd` is the entry point here — its domain-specific noun phrase ("aggregate's invariants") matches `ddd`'s description first, and `ddd`'s own "composes with testing" clause is what pulls this skill in, not the reverse. Contrast `ansible`, which absorbs a testing-shaped prompt alone because its description internalizes concrete testing mechanisms; `ddd` names none of its own and instead defers, which is why this prompt co-routes rather than being absorbed by `ddd` alone.

A coverage-target prompt ("what coverage percentage should we aim for?") was considered as the negative and rejected. Coverage policy is outside this skill's scope, but the prompt is a testing question that a description written to counter under-triggering will plausibly reach — so failing on it would drive a narrowing loop against the breadth the positive fixtures require, with nothing to arbitrate between them. CI sharding is outside the subject entirely, which is what a negative prompt needs.
