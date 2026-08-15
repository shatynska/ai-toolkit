# testing-practice Specification

## Purpose
Defines the floor-level, language-agnostic testing practice this library ships: the failure modes that make an agent-authored test suite look rigorous while establishing nothing — an uninterpretable failure claim, a failure misread for what it proves, an assertion the author invented, a test weakened to reach green — and the pointer discipline that routes stack-specific material to the skill that verifies it.

## Requirements

### Requirement: Guidance Is Language-Agnostic and Carries No Version-Dated Claims

The skill SHALL state testing practice in terms that hold for any language, test runner, or project shape. It SHALL NOT assert behavior that depends on a named version of a language, runner, or library, and SHALL NOT carry the dated verification statement this library's `python` and `langgraph` skills are required to carry, because it makes no claim that such a statement would qualify. (`bash` and `terraform` are required to carry none, so the divergence is from two of four domain precedents rather than from a uniform one.)

Where a failure output, command, or assertion is shown as an example, it SHALL be marked as illustrative of a language-agnostic distinction rather than presented as verified behavior of a named tool.

#### Scenario: The same discipline applies across unrelated stacks

- **WHEN** the same question about baseline, failure state, or test level arises in a Python project, a bash project, and a Terraform project
- **THEN** the skill SHALL give the same answer in all three, without a branch conditioned on the language

#### Scenario: No dated verification statement is carried

- **WHEN** the skill's content is checked for version-dependent assertions
- **THEN** it SHALL contain none, and SHALL NOT carry a "verified live against version X on date Y" statement

### Requirement: The Skill States the Two Situations It Can Be Entered In

The skill SHALL distinguish the two situations a test-writing task arrives in, and SHALL state which of its rules bind in each:

- **The target does not exist yet.** Tests are written against a stated requirement before there is any implementation to observe.
- **The target already exists.** Tests are written for code that is already there, whether or not it was ever covered.

It SHALL state that a test passing on first run means opposite things in the two situations: in the first it is an alarm, because no implementation exists that could satisfy it; in the second it is the expected result, and establishes that the code currently behaves as asserted. Rules that presuppose an absent target SHALL be marked as binding only in the first situation. Rules that do not — the baseline requirement, the level rule, the specified/derived/untested classification, and the prohibition on weakening an existing test — SHALL be stated as binding in both.

Stating this SHALL NOT be an argument for writing tests first. The skill records what each situation does and does not establish; which situation a project works in is not its concern.

#### Scenario: A test passing on first run is read correctly in each situation

- **WHEN** a newly written test passes on its first run
- **THEN** the skill SHALL require it to be treated as a defect where no implementation exists yet, and as the expected result where the code under test already exists

#### Scenario: A reader can tell which rules are in force

- **WHEN** tests are written for code that already exists
- **THEN** the skill SHALL make clear which of its rules still bind and which presuppose an absent target, rather than leaving the reader to infer it

### Requirement: A Claim That a Test Fails Is Interpretable Only Against a Recorded Baseline

The skill SHALL require that a baseline be taken and its already-failing tests recorded before any new test is written. A baseline covering the tests that bear on the target, recorded together with its scope, SHALL be a first-class permitted form rather than a fallback for when a full run is impossible: the requirement's purpose is attributability, which a scoped baseline satisfies, and making a full run the default imposes a fixed cost whose predictable adaptation is silent omission. The skill SHALL state why a baseline is needed at all: a suite that was already failing makes a subsequent report of failure uninterpretable, because the new test's contribution cannot be separated from what was broken beforehand.

#### Scenario: Pre-existing failures are separated from the new test's failure

- **WHEN** tests are written against a suite that already had failing tests
- **THEN** the skill SHALL require the pre-existing failures to have been recorded before the new tests ran, so the new tests' result is attributable

#### Scenario: A baseline is required before the claim, not reconstructed after

- **WHEN** a test suite is reported as failing for the expected reason
- **THEN** the skill SHALL treat that report as unsupported unless a baseline was taken beforehand

#### Scenario: An unobtainable baseline is reported rather than assumed or fabricated

- **WHEN** no full baseline can be taken — there is no existing suite, no runner is configured, the suite cannot execute in the current environment, or it is executable but impractical to run in full (prohibitively slow, or requiring credentials or services unavailable here)
- **THEN** the skill SHALL require one of two recorded outcomes: a **scoped** baseline covering the tests bearing on the target, recorded together with its scope; or an explicit statement that no baseline was taken and why, carried alongside any later claim about failure. It SHALL NOT permit treating the requirement as satisfied silently, nor reporting a baseline that was not run

#### Scenario: The recording surface is stated rather than left to the author

- **WHEN** a baseline is recorded
- **THEN** the skill SHALL state where it belongs — the completion report, an annotation alongside the tests, or either at the consuming project's discretion — rather than requiring it to be recorded without saying where

### Requirement: Failure States Are Defined by What They Establish, Not by the Machinery That Produced Them

The skill SHALL distinguish at minimum these four states a test can be in, and SHALL define each by what it establishes rather than by the error, phase, or exit status that produced it. The enumeration is stated for the absent-target situation named in *The Skill States the Two Situations It Can Be Entered In*; where the target already exists, the second and fourth states carry the different readings that requirement fixes, and the skill SHALL say so rather than restating the list. The third state is situation-independent and SHALL be stated as such:

- **The code ran and produced a wrong value.** The strongest state: it establishes both that the test executes and that it discriminates between correct and incorrect behavior.
- **The target does not exist yet.** It establishes that the target is absent, and nothing more — the assertions never executed, so whether they are any good remains unverified.
- **The test itself is broken.** The failure comes from a defect in the test rather than from the behavior it covers, so it establishes nothing about the code under test in either situation. Reaching this state requires the discrimination rule below; it SHALL NOT be assigned on the bare fact that a test failed. Repairing the defect does not turn it into evidence — it only moves the test into one of the other states, which is where its result first becomes readable. The skill SHALL NOT describe the repaired test as yielding a meaningless pass: that claim holds only for a test whose defect is that it asserts nothing, which is the fourth state, not this one.
- **It passed before any implementation existed.** An alarm rather than a result: either the behavior already exists, or the test asserts nothing.

Naming a state after one language's machinery — a collection phase, a compilation failure, a shell's command-not-found — SHALL be treated as a scope violation, because a language without that machinery cannot produce the state as named, and in some languages no per-test granularity is available at all.

The skill SHALL give the rule that separates the first state from the third, because both present as the same observable event — an asserted value that does not match the produced value — and without a rule the third state becomes a re-description available for any failure. The rule turns on the assertion's **provenance**, as classified under *Asserted Behavior Is Separated into Specified, Derived, and Deliberately Untested*:

- A **specified** assertion that does not match means the **code** is wrong. This is the first state. The test is not a candidate for repair, whatever it looks like, because the value it asserts traces to a stated requirement rather than to the author's judgment.
- Only a **derived** assertion may be reconsidered, and reconsidering it SHALL be recorded as a change to a derived assertion rather than performed as a repair.
- A defect that is not in the expected value at all — a wrong import, a wrong call, malformed setup or fixture — is the third state regardless of provenance, because the test never reached the point of asserting anything.

Without this rule, the prohibition in *An Existing Test Is Never Weakened or Deleted to Reach Green* is satisfiable by relabelling: an assertion edited to the observed value and described as repairing a broken test breaks no stated rule while doing exactly what that requirement exists to prevent.

How to determine which state a given failure is in — beyond this provenance rule, which is language-independent — SHALL be routed to the language skill rather than answered here.

#### Scenario: A state name does not presuppose one execution model

- **WHEN** the four states are stated
- **THEN** each SHALL be named by what it establishes, and none SHALL be named for a phase, error class, or exit status specific to one language or runner

#### Scenario: A test that passes before implementation is treated as a defect

- **WHEN** a newly written test passes before the behavior it covers has been implemented
- **THEN** the skill SHALL require this to be investigated as a defect in the test, and SHALL NOT permit it to be recorded as coverage

#### Scenario: A specified assertion that fails is never classified as a broken test

- **WHEN** a test asserting a value that traces to a stated requirement fails because the code produced something else
- **THEN** the skill SHALL require it to be treated as the code being wrong, and SHALL NOT permit it to be classified as a defect in the test and the asserted value repaired

#### Scenario: An absent target does not vouch for the assertions

- **WHEN** tests fail because the code under test does not exist yet
- **THEN** the skill SHALL require the assertions to be reported as unverified, distinctly from assertions that ran and failed

### Requirement: A Target-Absent Failure Is Not Resolved by Writing the Code Under Test

The skill SHALL state that a failure caused by the absence of the code under test is an acceptable and expected outcome when tests are written first, and SHALL prohibit resolving it by creating the missing module, function, type, or stub so that the tests can execute. It SHALL name this as the most likely point at which a test-writing pass drifts into writing implementation, because creating the missing target presents itself as repairing the tests.

The prohibition SHALL be stated with its scope and its lifting condition, not as an unbounded rule. It binds while the current task's scope is writing tests. Where the same task also authorises implementation — the ordinary case of a request to build something *with* tests — it SHALL lift once the target-absent failure has been reported, and the implementation SHALL then be written as a distinct, announced step rather than as a repair to the tests. What remains prohibited in every case is creating a target *in order to make tests execute*, which is a motive distinguishable from implementing under an authorised step, and is what the rule exists to catch.

A prohibition stated without this bound would forbid ordinary work on a common request, and a floor that forbids ordinary work is overridden wholesale — taking the rules stated alongside it down with it.

#### Scenario: The missing target is not created to make tests run

- **WHEN** newly written tests fail because the module or function under test does not exist, and the current task's scope is writing tests
- **THEN** the skill SHALL require that failure to be reported as it stands, and SHALL prohibit creating the target — including as an empty stub — to make the tests execute

#### Scenario: Implementation authorised in the same task proceeds after the failure is reported

- **WHEN** a single task authorises both writing tests and implementing the behavior they cover
- **THEN** the skill SHALL require the target-absent failure to be reported first, and SHALL then permit the implementation to be written as a distinct step, rather than treating the prohibition as blocking the task

### Requirement: Test Level Is Chosen by the Smallest Thing That Can Observe the Outcome

The skill SHALL give a decision rule for choosing a test's level rather than leaving it to preference: the level is the smallest unit that can observe the expected outcome. It SHALL state that a level chosen above that minimum buys no additional evidence while costing speed and determinism.

#### Scenario: The rule resolves a level choice without appeal to preference

- **WHEN** it must be decided whether a given expected outcome is covered by a narrow or a broad test
- **THEN** the skill SHALL resolve it by which is the smallest unit that can observe that outcome, rather than by a convention about proportions between test levels

### Requirement: Asserted Behavior Is Separated into Specified, Derived, and Deliberately Untested

The skill SHALL require every assertion to be classified as **specified** (it traces to a stated requirement), **derived** (the test author inferred it, and no stated requirement covers it), or **deliberately untested** (a case identified and knowingly left uncovered, recorded with the reason).

It SHALL state why: an assertion the author invented obliges whoever implements the code to satisfy a constraint nobody agreed to, which is the test author designing behavior. Labelling makes each invented assertion visible for review instead of indistinguishable from a stated requirement.

A case left uncovered SHALL be recorded with its reason rather than omitted, so that absence of a test is distinguishable from absence of the thought.

The skill SHALL state where the classification and the uncovered-case reasons are recorded — a completion report, an annotation alongside the tests, or either at the consuming project's discretion — because an obligation to record without a stated surface is satisfiable in ways that differ enough to be reviewed differently.

#### Scenario: An invented assertion is visible as invented

- **WHEN** a test asserts behavior that no stated requirement covers
- **THEN** the skill SHALL require it to be labelled as derived, so it is distinguishable from an assertion tracing to a requirement

#### Scenario: An uncovered case is recorded rather than dropped

- **WHEN** a case is identified during test writing and deliberately not covered
- **THEN** the skill SHALL require it to be recorded with the reason, rather than silently omitted from the result

### Requirement: An Existing Test Is Never Weakened or Deleted to Reach Green

The skill SHALL prohibit editing an assertion to match what the code actually produced, and SHALL prohibit deleting or disabling a failing test as a way of reaching a green suite. It SHALL state the consequence: a test altered to fit the code it was written to constrain records the code's current behavior instead of constraining it, and the suite reports success either way.

Where a requirement has genuinely changed and an existing test now asserts superseded behavior, the skill SHALL require that test to be reported as superseded rather than quietly rewritten.

#### Scenario: A failing assertion is not edited to match observed output

- **WHEN** a test fails because the code produced a different value than asserted
- **THEN** the skill SHALL require the discrepancy to be resolved in the code or reported, and SHALL prohibit changing the assertion to the observed value as the means of making it pass — including where the change is described as repairing a defective test, which the provenance rule in *Failure States Are Defined by What They Establish* forecloses for a specified assertion

#### Scenario: A test superseded by a changed requirement is reported, not rewritten silently

- **WHEN** an existing test asserts behavior that a changed requirement has superseded
- **THEN** the skill SHALL require it to be reported as superseded, so the change is visible rather than absorbed into a routine edit

### Requirement: Language and Tool Specifics Are Routed by Pointer, Not Restated

The skill SHALL carry a section naming the library's language and tool skills as the place stack-specific testing material lives, and SHALL direct that the matching skill be loaded before tests are written in that stack. It SHALL NOT restate that material, and SHALL state the reason: those skills carry the dated verification their claims require, which this skill does not.

The section SHALL name **every** domain skill in the library that covers a stack with a testable artifact, not a subset. A domain skill omitted because its testing content is currently thin is omitted on a fact about that skill's present state rather than about its scope, which would leave a request in that stack reaching this floor with no route onward.

#### Scenario: Stack specifics are reachable from the floor

- **WHEN** the skill's content is checked
- **THEN** it SHALL name the language and tool skills that carry stack-specific testing material and direct that the matching one be loaded before tests are written

#### Scenario: No domain skill is omitted for currently having thin testing content

- **WHEN** the pointer list is assembled and a domain skill in the library covers a stack whose artifacts can be tested
- **THEN** that skill SHALL be named, whether or not it presently carries testing material

#### Scenario: Version-dependent material is not absorbed into this skill

- **WHEN** testing guidance is version-dependent on a language, runner, or library
- **THEN** the skill SHALL route it to the skill that verifies that tool rather than carrying it

### Requirement: Triggering Covers Test-Writing Requests and Accepts Overlap with the Language Skills

The skill's description SHALL trigger on requests to write, review, or debug tests — including phrasings that name a specific stack, such as a request to write tests for a given function — and SHALL NOT restrict itself to questions about testing methodology in the abstract. Restricting it that way would leave it dormant on the dominant phrasing.

Overlap with a language or tool skill on such a request SHALL be treated as the intended outcome rather than a defect: this skill supplies the standard and the language skill supplies the idiom. The description SHALL state that relationship explicitly, in the manner `python`'s guidance already establishes toward `langgraph` — which is one-directional, `langgraph` carrying no reciprocal cross-reference — rather than partitioning subject matter to avoid the overlap.

#### Scenario: A stack-specific test request still reaches the skill

- **WHEN** a user asks for tests to be written for a function in a specific language
- **THEN** the skill SHALL trigger, rather than deferring solely to that language's skill

#### Scenario: Co-triggering is not treated as a routing defect

- **WHEN** a trigger check is run for this skill against a request that also legitimately reaches a language skill
- **THEN** both skills triggering SHALL count as a pass, and only this skill displacing the language skill — or being displaced by it — SHALL count as a failure

### Requirement: The Floor States How It Applies on a Review or Debug Entry

The trigger surface this skill claims covers writing, reviewing, and debugging tests. Its rules SHALL therefore be stated so they are usable when no test is being written, rather than framed exclusively around authoring a new one. A skill that fires on a review request and supplies instructions for authoring addresses a task the user is not performing, which is the under-delivery counterpart of the under-triggering this skill's triggering requirement exists to prevent.

The skill SHALL state at minimum which of its rules answer the two non-authoring entries directly:

- **Reviewing an existing test** — the specified/derived/deliberately-untested classification is the review question: does each assertion trace to a stated requirement, or did its author invent it? The provenance rule and the never-weaken prohibition apply unchanged.
- **Debugging a test whose result looks wrong** — the four failure states are the diagnostic vocabulary, and a test that passes when it should not is the fourth state.

Rules whose statement presupposes an authoring pass — taking a baseline before writing, choosing a level for a test not yet written — SHALL be marked as such rather than presented as applying on every entry.

#### Scenario: A review request is answered with review-applicable rules

- **WHEN** the skill is entered by a request to review existing tests rather than write new ones
- **THEN** it SHALL state which of its rules bear on that request, rather than supplying only guidance for authoring a new test

#### Scenario: A debug request reaches the diagnostic vocabulary

- **WHEN** the skill is entered by a request to explain why a test passes or fails unexpectedly
- **THEN** the four failure states SHALL be reachable as the vocabulary for answering it, including the fourth state for a test that passes when it should not

### Requirement: Consuming Project Conventions Take Precedence, Above a Stated Floor

The skill SHALL declare itself a floor rather than an authority: a consuming project's `AGENTS.md`, `CLAUDE.md`, and existing tests override it wherever they conflict, except as bounded below. It SHALL instruct that those be read before test work begins in an unfamiliar repository, and SHALL require that a conflict between its own guidance and a project convention be reported rather than silently resolved.

Where a question turns on a project decision — which runner is used, where tests live, what the project calls its levels, which stacks it stubs — and the project records no convention at all, the skill SHALL state that the answer is project-specific and ask, rather than supplying one from assumption. A repository that has not yet recorded its conventions is the expected case, not an edge case.

Deference SHALL be bounded, and the boundary stated rather than left to be inferred. Two rules SHALL be declared non-negotiable and SHALL NOT be presented as overridable by a project convention: the prohibition on weakening, deleting, or disabling an existing test to reach green, and the prohibition on resolving an absent target by writing the code under test. A convention permitting either does not adjust the practice to local circumstances; it removes what the practice is for, and a floor that defers on those two points asserts nothing. Everything else — level vocabulary and boundaries, where classifications and baselines are recorded, which stacks are stubbed — defers in the ordinary way.

#### Scenario: Project convention wins an ordinary conflict

- **WHEN** a consuming project's recorded convention or established test style contradicts a preference stated in the skill on level selection, recording surface, or stubbing
- **THEN** the project's convention SHALL be followed and the conflict reported rather than silently resolved

#### Scenario: The two non-negotiable rules do not yield to a convention

- **WHEN** a project convention would permit editing an assertion to match observed output, deleting a failing test to reach green, or creating the code under test to make tests execute
- **THEN** the skill SHALL NOT present that as a resolved conflict, and SHALL require the conflict to be reported instead

#### Scenario: Absent conventions produce a question, not an invention

- **WHEN** a project-specific question arises — the runner, test location, level vocabulary, or stubbing approach — in a repository that records no conventions
- **THEN** the skill SHALL state that the answer is project-specific and ask, rather than supplying one from assumption
