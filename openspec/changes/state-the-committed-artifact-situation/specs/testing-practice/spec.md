## RENAMED Requirements

- FROM: `### Requirement: The Skill States the Two Situations It Can Be Entered In`
- TO: `### Requirement: The Skill States the Situations It Can Be Entered In`

## MODIFIED Requirements

### Requirement: The Skill States the Situations It Can Be Entered In

The skill SHALL distinguish the situations a test-writing task arrives in, and SHALL state which of its rules bind in each:

- **The target does not exist yet.** Tests are written against a stated requirement before there is any implementation to observe.
- **The target already exists.** Tests are written for code that is already there, whether or not it was ever covered.
- **The assertion does not execute the behaviour it asserts.** It is a static read: a configuration file, a workflow, a manifest, a document, the source of a program it never runs, or a module imported only so a constant can be read out of it. The assertion's subject is not something the check exercises, so a pass reports only that the target could be read.

It SHALL state that a test passing on first run means different things across the three: in the first it is an alarm, because no implementation exists that could satisfy it; in the second it is the expected result, and establishes that the code currently behaves as asserted; in the third it establishes nothing at all, because a check that read nothing would pass identically.

For the third situation the skill SHALL state the obligation that follows: a check that is green — its target carrying the asserted property at the time the suite runs — passes without discriminating, so establishing that it can fail requires running it over material the test itself supplies. A test that does this is a **fixture-driven discriminator**, and the skill SHALL name it there so the term is defined where the obligation is. It SHALL state that this is what makes such a suite's green result mean anything, and SHALL NOT present it as optional rigour.

The skill SHALL state what a discriminator that comes back **negative** establishes, because that is the one finding this mechanism exists to produce and an obligation whose result is unstated is not yet a mechanism. Where the check passes over material chosen to falsify it, the check asserts nothing: that is the fourth state's second branch, reached deliberately rather than stumbled on. The skill SHALL require such a check to be repaired or reported, and SHALL NOT permit it to stand in the suite as coverage. Where it is reported rather than repaired, the **author** SHALL record the finding, inside the authoring pass and before it ends, on the same surface as the records below and in the same form — what was found, and why the check was not repaired — a check known to assert nothing, reported only in conversation, is the failure this whole mechanism exists to produce, lost at the last step. It SHALL say this in the third situation's own text rather than leaving it to be inferred from the fourth state — the reading below tells a third-situation author that the fourth state's alarm does not discriminate for them, which closes the route an inference would otherwise take.

The skill SHALL scope the obligation to a check **as it is authored or modified**, and SHALL say what modifying one means: a change to what the check asserts, or to how it reads its target — not an edit to the file that contains it, so a rename, a reformat or an edit to a neighbouring check does not pull an untouched check into scope. Where reading is delegated to shared machinery, editing that machinery brings a check into scope only where the check's own assertion or its own result changes; otherwise it does not, in either direction — a shared edit SHALL NOT sweep in every check that delegates, and extracting a read into a helper SHALL NOT take a check out of scope. Where an extraction changes neither the check's assertion nor its result, the skill SHALL state that this sentence governs and the check stays out of scope: read against the general wording alone, moving a read into a helper is a change to how the check reads its target, so the two give opposite answers on exactly the refactor a shared-arrangement change performs. It SHALL state what follows for a check that predates the rule: such a check is read as carrying an undischarged obligation, not as a violation, and nothing here requires a suite to be retrofitted. Without that scope the requirement makes every already-green static check in every consuming project non-conformant on the day it lands, which would raise test volume in the name of bounding it.

The skill SHALL state what the obligation assumes about the check, because its performability rests on it: a check in this situation is written so that what it reads can be pointed at material the test supplies. Where a check already in scope — one being authored or modified — is not so written, its target path fixed and redirectable only by rewriting how it reads, the skill SHALL state that redirecting it is part of modifying it, and SHALL NOT let that case be reported as a discriminator that could not be run, which is a different fact with a different remedy.

The skill SHALL give the unrunnable case an explicit outcome, in the form the baseline rule already defines for a baseline that cannot be taken: where the discriminator can be written but not executed in the authoring environment, the **author** SHALL record that, inside the authoring pass and before it ends, with the reason rather than leaving the obligation reading as unmet. Neither treating it as discharged nor reporting a run that did not happen is acceptable.

The skill SHALL name that record's **surface** as well as its form, because *Asserted Behavior Is Separated into Specified, Derived, and Deliberately Untested* states that an obligation to record without a stated surface is satisfiable in ways that differ enough to be reviewed differently. It is recorded wherever the project records the classification and its reasons, and SHALL NOT be filed as part of the baseline record: the baseline is about the state of the suite before the tests were written, an unexecuted discriminator is about one test in this pass, and a reader sweeping for outstanding discriminator work does not look in the baseline. The form the baseline rule defines is borrowed; its location is not.

The skill SHALL state who discharges the obligation and when, because a rule owed by nobody is not a rule: **a fixture-driven discriminator does not depend on the target's state.** It supplies its own material, so it can be written beside a check that is still red, in the same pass, by the same author — and ordinarily is. The skill SHALL NOT state or imply that the fixture waits until the check goes green.

The skill SHALL state what an observed failure establishes, because it is the common case wherever tests are written before the change they cover lands: a check written against a property the target does not yet carry is **red** at authoring and goes green as the change lands, and that transition establishes that the check discriminates, on real content rather than on a fixture. The skill SHALL name the actor, the moment and the surface for that record, and SHALL put the first two inside the authoring pass: the **author** records, inside the authoring pass and before it ends, that the check is red and on which property — that is what is knowable while an author is present, and it is what makes the later green readable as a transition. The surface is the one the paragraph above names, wherever the project records the classification and its reasons, and SHALL NOT be the baseline record: the reasons given there hold here unchanged — the baseline is about the suite before these tests were written, this is a fact about one test in this pass, and a reader sweeping for outstanding discriminator work does not look in the baseline. Filing it in the baseline would also grow what that record is specified to carry, which is not this requirement's to change. The skill SHALL NOT oblige a second record once the check goes green: the ordinary suite result is the confirmation, and an obligation falling due after the pass has ended would be owed by nobody, which this requirement names as a defect two paragraphs on.

The skill SHALL state that the transition does not discharge the obligation above, and SHALL state why rather than asserting it: the red run leaves nothing in the suite, so once the check is green nothing re-establishes the property and a later edit can stop the check asserting with no result changing. The fixture is therefore owed all the same, and — per the paragraph above — is written in the same pass rather than deferred to whoever makes the check green. Where tests are derived before implementation every check is red at authoring, so a rule that exempted this case would exempt every check in such a project — the skill SHALL NOT be readable as granting that exemption, and SHALL NOT state that every check over a static target passes on its first run.

The skill SHALL state what separates the second situation from the third, because both concern a target that is already present, and SHALL state it as one test rather than two: whether the assertion executes **the behaviour it asserts**. Where it does, a pass reports that behaviour and the second situation applies. Where it does not, the pass reports only that the target could be read, and the third applies. Loading the target SHALL NOT be confused with exercising the asserted behaviour — a module imported so a constant can be read out of it runs on import and exercises nothing the assertion is about. Committedness SHALL NOT be the test, in either direction: code that already exists is committed and sits in the second situation, and the source of that same code, read statically by an assertion that never calls it, sits in the third.

The skill SHALL state that the three situations are not a partition of tests but a reading of one test at one moment, and SHALL arbitrate the case that follows from it: a static check whose target file does not exist yet is in the first situation for as long as that holds — its failure establishes the target's absence and nothing about the assertions — and passes into the third once the file is present, whether or not it was ever absent. Which situation governs SHALL be resolved by what is true when the question is asked, not by the test's history.

Rules that presuppose an absent target SHALL be marked as binding only in the first situation. Rules that do not — the baseline requirement, the level rule, the specified/derived/untested classification, and the prohibition on weakening an existing test — SHALL be stated as binding in all three.

Stating this SHALL NOT be an argument for writing tests first. The skill records what each situation does and does not establish; which situation a project works in is not its concern.

#### Scenario: A test passing on first run is read correctly in each situation

- **WHEN** a newly written test passes on its first run
- **THEN** the skill SHALL require it to be treated as a defect where no implementation exists yet to execute, as the expected result where the assertion executes the behaviour it asserts, and as establishing nothing where it does not

#### Scenario: A reader can tell which rules are in force

- **WHEN** tests are written for code that already exists
- **THEN** the skill SHALL make clear which of its rules still bind and which presuppose an absent target, rather than leaving the reader to infer it

#### Scenario: A static read is not mistaken for a covered behaviour

- **WHEN** a suite is green and none of its assertions executes the behaviour it asserts
- **THEN** the skill SHALL state that the green result establishes nothing about those checks until each has been run over a fixture the test supplies, and SHALL NOT permit the pass to be recorded as coverage

#### Scenario: A discriminator that fails to falsify says the check asserts nothing

- **WHEN** a check is run over material chosen to falsify it and passes anyway
- **THEN** the skill SHALL treat this as establishing that the check asserts nothing, SHALL require it to be repaired or reported, and SHALL NOT permit it to stand in the suite as coverage

#### Scenario: A negative finding reported rather than repaired is still recorded

- **WHEN** a discriminator establishes that a check asserts nothing and the check is reported rather than repaired
- **THEN** the skill SHALL require the finding recorded where the project records the classification and its reasons, and SHALL NOT treat reporting it in conversation as discharging the obligation

#### Scenario: A check that cannot be pointed at supplied material is redirected, not excused

- **WHEN** a check already in scope, being authored or modified, cannot be pointed at material the test supplies without rewriting how it reads
- **THEN** the skill SHALL treat redirecting it as part of modifying the check, and SHALL NOT permit it to be reported as a discriminator that could not be run

#### Scenario: A check red at authoring discriminates once and still owes a fixture

- **WHEN** a check is red because its target does not yet carry the asserted property, and goes green as the change lands
- **THEN** the skill SHALL treat the transition as establishing that the check discriminates, SHALL require the author to record the red state and its property where the project records the classification and its reasons — inside the authoring pass before it ends, and not in the baseline — rather than obliging a second record once the check is green, and SHALL require the fixture in the same pass rather than once the check is green, because the transition leaves nothing in the suite to re-establish the property and the fixture needs nothing the pass does not already have

#### Scenario: The third situation is distinguished from the second by what the assertion executes

- **WHEN** a reader asks which situation applies to a test whose target is already present
- **THEN** the skill SHALL resolve it by whether the assertion executes the behaviour it asserts, and SHALL NOT resolve it by whether the target is committed, by what kind of thing the target is, or by whether the target was loaded at all

#### Scenario: A check written before the rule is undischarged rather than in breach

- **WHEN** a suite already holds green checks, authored before this rule, whose assertions do not execute the behaviour they assert and which carry no discriminator
- **THEN** the skill SHALL read each as carrying an undischarged obligation rather than as a violation, and SHALL NOT require the suite to be retrofitted

#### Scenario: A discriminator that cannot be run here is recorded rather than assumed

- **WHEN** a discriminator is written but cannot be executed in the authoring environment
- **THEN** the skill SHALL require the non-execution and its reason to be recorded where the project records the classification and its reasons, SHALL NOT permit it to be treated as discharging the obligation, and SHALL NOT place the record in the baseline

#### Scenario: An edit to shared machinery does not sweep in every check that delegates

- **WHEN** machinery several checks delegate their target-reading to is edited, and some of those checks' assertions and results are unchanged by it
- **THEN** the skill SHALL keep the unaffected checks out of scope, and SHALL NOT bring every delegating check into scope because the shared code changed

#### Scenario: A read extracted into shared machinery does not move a check in or out of scope

- **WHEN** a check's target-reading is moved into a helper other checks also use, and neither that check's assertion nor its result changes
- **THEN** the skill SHALL keep the check out of scope, and SHALL NOT read the extraction as a change to how the check reads its target

#### Scenario: A static check whose target is absent is read as the first situation

- **WHEN** a static check fails because the file it reads does not exist yet
- **THEN** the skill SHALL place it in the first situation for as long as that holds, and in the third once the file is present, resolving by what is true when the question is asked rather than by the test's history


### Requirement: Failure States Are Defined by What They Establish, Not by the Machinery That Produced Them

The skill SHALL distinguish at minimum these four states a test can be in, and SHALL define each by what it establishes rather than by the error, phase, or exit status that produced it. The enumeration is stated for the absent-target situation named in *The Skill States the Situations It Can Be Entered In*; in each of the other two situations the second and fourth states carry the different readings that requirement fixes, and the skill SHALL say so rather than restating the list. The condition SHALL be the situation rather than the target's presence, which spans both of them and reads differently in each. The third state is situation-independent and SHALL be stated as such:

- **The code ran and produced a wrong value.** The strongest state: it establishes both that the test executes and that it discriminates between correct and incorrect behavior.
- **The target does not exist yet.** It establishes that the target is absent, and nothing more — the assertions never executed, so whether they are any good remains unverified.
- **The test itself is broken.** The failure comes from a defect in the test rather than from the behavior it covers, so it establishes nothing about the code under test in any situation. Reaching this state requires the discrimination rule below; it SHALL NOT be assigned on the bare fact that a test failed. Repairing the defect does not turn it into evidence — it only moves the test into one of the other states, which is where its result first becomes readable. The skill SHALL NOT describe the repaired test as yielding a meaningless pass: that claim holds only for a test whose defect is that it asserts nothing, which is the fourth state, not this one.
- **It passed before any implementation existed.** An alarm rather than a result: either the behavior already exists, or the test asserts nothing.

The fourth state SHALL carry its third-situation reading explicitly. Where the assertion does not execute the behaviour it asserts, the state is not reached by an implementation arriving early, because there is no implementation to arrive; a check whose target already carries the asserted property passes on its first run for that reason alone. The skill SHALL state that the alarm does not discriminate there — it fires on every such check, including every sound one — so a pass is answered by the fixture obligation rather than by investigating the pass itself. Where the check is instead red at authoring, the fourth state is not in question at all.

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

#### Scenario: The first-run alarm is not relied on where it cannot discriminate

- **WHEN** a check passes on its first run because its target already carries the asserted property and the assertion never executes that target
- **THEN** the skill SHALL state that the fourth state's alarm fires on every such check, sound or not, and SHALL direct the author to the fixture obligation rather than to investigating the pass

#### Scenario: A specified assertion that fails is never classified as a broken test

- **WHEN** a test asserting a value that traces to a stated requirement fails because the code produced something else
- **THEN** the skill SHALL require it to be treated as the code being wrong, and SHALL NOT permit it to be classified as a defect in the test and the asserted value repaired

#### Scenario: An absent target does not vouch for the assertions

- **WHEN** tests fail because the code under test does not exist yet
- **THEN** the skill SHALL require the assertions to be reported as unverified, distinctly from assertions that ran and failed


### Requirement: Asserted Behavior Is Separated into Specified, Derived, and Deliberately Untested

The skill SHALL require every assertion to be classified as **specified** (it traces to a stated requirement), **derived** (the test author inferred it, and no stated requirement covers it), or **deliberately untested** (a case identified and knowingly left uncovered, recorded with the reason).

It SHALL state why: an assertion the author invented obliges whoever implements the code to satisfy a constraint nobody agreed to, which is the test author designing behavior. Labelling makes each invented assertion visible for review instead of indistinguishable from a stated requirement.

A case left uncovered SHALL be recorded with its reason rather than omitted, so that absence of a test is distinguishable from absence of the thought.

The skill SHALL state where the classification and the uncovered-case reasons are recorded — a completion report, an annotation alongside the tests, or either at the consuming project's discretion — because an obligation to record without a stated surface is satisfiable in ways that differ enough to be reviewed differently.

The skill SHALL state what a fixture-driven discriminator is for — the term as *The Skill States the Situations It Can Be Entered In* defines it — and SHALL state it as the bound on how much of one is warranted: its job is to establish that the check can fail, by falsifying it on the property the check exists to assert. It SHALL state that this is not an enumeration of the check's input space, and that a case added because it is expressible rather than because it discriminates is a derived assertion like any other and SHALL be labelled accordingly. The skill SHALL NOT state a number of cases, a proportion, or a size — the bound is what the case establishes, which is reviewable, rather than how many there are, which is not.

#### Scenario: An invented assertion is visible as invented

- **WHEN** a test asserts behavior that no stated requirement covers
- **THEN** the skill SHALL require it to be labelled as derived, so it is distinguishable from an assertion tracing to a requirement

#### Scenario: An uncovered case is recorded rather than dropped

- **WHEN** a case is identified during test writing and deliberately not covered
- **THEN** the skill SHALL require it to be recorded with the reason, rather than silently omitted from the result

#### Scenario: A discriminating case that falsifies nothing further is labelled

- **WHEN** an author adds a case to a fixture-driven discriminator and the case falsifies nothing the existing cases do not already falsify
- **THEN** the skill SHALL require it to be classified as derived, and SHALL NOT permit the discriminator's purpose to stand as its justification

#### Scenario: The bound is stated without a quantity

- **WHEN** an author asks how much of a discriminator a check is owed
- **THEN** the skill SHALL answer by what each case establishes, and SHALL NOT answer with a count, a proportion, or a size
