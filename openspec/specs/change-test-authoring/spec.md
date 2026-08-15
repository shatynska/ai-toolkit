# change-test-authoring Specification

## Purpose
Defines what a test-authoring pass over an OpenSpec change must do and where it stops: the dispatch contract that supplies the change, the scenario enumeration that makes coverage countable rather than a judgment, the distinct handling of the four delta operations, the additive-only boundary that keeps the pass from ever subtracting, deference to the library's testing floor rather than a second copy of it, and the manifest that carries the result to whoever implements next.

## Requirements

### Requirement: The Change Is Supplied by Dispatch, Not Discovered

The agent SHALL work on what its dispatcher names and SHALL NOT search for a change to act on or infer the repository from where it was dispatched.

**Essential inputs**, without which there is nothing to act on: the change name, the absolute `changeRoot`, the resolved artifact paths, the absolute path to the change's `.openspec.yaml`, the absolute paths of the project's convention files (`AGENTS.md`, `CLAUDE.md`, or their absence stated explicitly), the project's test command, and the **test-path glob** identifying where tests may be written.

`specsRoot` is **conditionally** essential, stated separately so the qualification cannot be read as binding the inputs around it. It is required where the change carries a `MODIFIED`, `REMOVED` or `RENAMED` delta, because establishing what was superseded means reading the requirement as it currently stands. Where every delta is `ADDED` there is nothing to compare against and the agent SHALL NOT block on its absence, whether or not the project records specifications elsewhere.

The dispatch MAY additionally supply the absolute path of an earlier `test-manifest.md`. This is optional: its absence changes what the obsolete search can draw on, not whether the pass can proceed.

The `.openspec.yaml` path is essential rather than derived because this specification forbids constructing paths, and the specs-exemption below is read from that file — an exemption reachable only by guessing a conventional location would not be the file read it is described as.

The convention-file paths are essential because the testing floor this agent loads obliges it to read a project's recorded conventions before test work. An agent that cannot reach them cannot discharge an obligation it has inherited, and would satisfy it by assumption instead. Missing any of the inputs enumerated above, the agent SHALL report itself blocked on what is absent and stop, rather than guessing a conventional path. This blocking rule reaches the enumerated essential inputs only; the conditional and optional inputs described below are governed by their own paragraphs.

Every file SHALL be addressed by the absolute path supplied. A conclusion resting on a file nobody named rests on ground the dispatcher cannot reproduce.

#### Scenario: A missing essential input blocks rather than defaults

- **WHEN** a dispatch omits the test command or the test-path glob
- **THEN** the agent SHALL report itself blocked naming what is missing, and SHALL NOT infer a runner from the repository's contents or write tests to a path it chose itself

#### Scenario: Paths are not guessed from convention

- **WHEN** the agent needs the change's artifacts
- **THEN** it SHALL use the supplied absolute paths, and SHALL NOT construct a path such as `openspec/changes/<name>/` or assume the working directory is the repository

### Requirement: What the Agent May Read Is Bounded

The reason this work runs in its own context is that its author has not seen the implementation and therefore cannot shape assertions to match it. That property is secured by dispatch ordering for an `ADDED` requirement — there is nothing to read — but not for a `MODIFIED` one, where the pre-change implementation exists and matching tests to superseded behaviour invites reading it. Left unstated, the agent could satisfy every other requirement here while deriving its assertions from the code it is meant to constrain.

The agent SHALL read only: the change's artifacts at the paths supplied; the specifications under `specsRoot`; the project's dispatched convention files; an earlier `test-manifest.md` where its path is supplied; and files within the dispatched test-path glob. It SHALL NOT read the implementation of the behaviour under test, and SHALL NOT do so in order to establish what a `MODIFIED` delta supersedes — the delta and the existing requirement state that, which is what `specsRoot` is for.

Reading a source file outside the test-path glob to determine what an assertion should say SHALL be reported as a departure from this bound, not resolved silently.

#### Scenario: Superseded behaviour is established from specifications, not from code

- **WHEN** the agent must determine what a `MODIFIED` delta supersedes
- **THEN** it SHALL do so by comparing the delta with the existing requirement under `specsRoot`, and SHALL NOT read the implementation to find out

#### Scenario: The read bound is reported rather than crossed silently

- **WHEN** the agent cannot proceed without reading implementation source
- **THEN** it SHALL report that it is blocked on the bound rather than crossing it, so the property the separate context exists to secure is not lost unrecorded

### Requirement: The Testing Standard Is Invoked, Not Restated

The agent SHALL load the library's testing skill before writing any test, and SHALL defer to it for every question the testing floor answers — what a baseline establishes, what each failure state establishes, how an assertion's provenance is classified, and why an existing test is never weakened. It SHALL additionally load the skill matching the stack under test **where the library carries one**. Where it does not — which is the ordinary case for most stacks — the agent SHALL record the absence in the manifest as an unresolved project question and proceed on the floor alone, rather than stalling or loading a near-miss skill.

The agent's own body SHALL carry only what is specific to operating on an OpenSpec change. Restating the testing floor SHALL be treated as a defect: two copies of one standard drift, and the skill is the copy that is maintained.

What "restating" reaches SHALL be stated, because this requirement and *The Pass Is Additive Only* otherwise bind the same body text in opposite directions. It reaches the floor's **rationale, classifications and diagnostic procedures** — why a baseline makes a failure claim interpretable, what distinguishes one failure state from another, how an assertion's provenance is determined, why weakening a test destroys what it was written to do. Those are the parts that drift, and the parts an agent can look up at runtime because it has already loaded the skill.

It does **not** reach the agent's own **standing prohibitions**, which SHALL be stated in the body outright even where the floor also states them. Two of them — never edit, delete or disable an existing test, and never write the code under test to make tests execute — are what a dispatcher relies on without reading the agent's reasoning, and a guarantee that resolves only once a skill has loaded at runtime is not one a dispatcher can rely on when assembling a payload.

#### Scenario: The floor is loaded before tests are written

- **WHEN** the agent begins a test-authoring pass
- **THEN** it SHALL load the testing skill, and the matching language or tool skill, before writing any test rather than after

#### Scenario: A rule the floor owns is not duplicated into the agent

- **WHEN** the agent's body would state the floor's rationale for a rule, its classification scheme, or how a determination under it is made — for baselines, failure states, assertion provenance, or why weakening a test destroys it
- **THEN** that material SHALL be referenced from the skill that owns it rather than restated

#### Scenario: A standing prohibition is stated outright, not referenced

- **WHEN** the body states that the agent never edits an existing test or never writes the code under test
- **THEN** that prohibition SHALL be carried in the body itself, and SHALL NOT be treated as a restatement to be replaced by a reference, because a dispatcher relies on it before any skill has loaded

### Requirement: Inherited Project-Convention Obligations Are Discharged Non-Interactively

The testing floor this agent loads obliges any consumer to read a project's recorded conventions before test work, and — where a project-specific question has no recorded answer — to ask rather than answer from assumption. A dispatched subagent has no channel on which to ask and no session to ask into, so that obligation SHALL be translated into a form this agent can discharge rather than inherited unchanged and then quietly skipped.

The agent SHALL read the convention files its dispatch names. Where a project-specific question arises that those files do not answer — which runner is used, what the project calls its levels, which stacks it stubs — the agent SHALL record it in the manifest as an **unresolved project question**, together with the assumption it proceeded on and which tests depend on that assumption, and SHALL surface it in its report. It SHALL NOT resolve such a question silently, and SHALL NOT treat the absence of a channel as making the floor's obligation inapplicable.

This is an OpenSpec-flow translation of a floor rule, not a restatement of it: the floor states that an unanswered project question must not be answered from assumption, and this requirement states where that question goes when there is nobody to ask.

#### Scenario: An unanswerable project question is recorded rather than assumed away

- **WHEN** a project-specific question arises that the dispatched convention files do not answer
- **THEN** the agent SHALL record it in the manifest as an unresolved project question with the assumption taken and the tests depending on it, and surface it in the report

#### Scenario: The absence of a channel does not void the obligation

- **WHEN** the floor directs that a question be asked and the agent has no interactive channel
- **THEN** the obligation SHALL be discharged by recording and surfacing, and SHALL NOT be treated as inapplicable because asking is impossible

### Requirement: Every Scenario in the Delta Specs Is Accounted For

The agent SHALL enumerate every `#### Scenario:` block in the change's delta specs and SHALL account for each one exactly once: covered by at least one named test, or recorded as uncovered together with the reason it was not covered.

Scenarios reached through a `REMOVED` or `RENAMED` delta are accounted for as **uncovered, with the operation as the reason** — removed behavior is not to be tested, and a rename changes no behavior — so the count reconciles across all four operations rather than only the two that produce tests.

This makes coverage of the change's stated behavior a **count** rather than a judgment. A scenario omitted from the manifest SHALL be treated as a defect in the pass, not as an implicit decision that it needed no test.

#### Scenario: Coverage is checkable by counting

- **WHEN** a test-authoring pass reports itself complete
- **THEN** the number of scenarios in the delta specs SHALL equal the number accounted for in the manifest, whether as covered or as uncovered-with-reason

#### Scenario: An untested scenario is recorded rather than dropped

- **WHEN** the agent judges that a scenario should not have a test
- **THEN** it SHALL record the scenario and the reason, and SHALL NOT omit it, so that the absence of a test is distinguishable from the absence of the thought

### Requirement: The Four Delta Operations Are Handled Distinctly

The agent SHALL read each delta's operation and act on it according to that operation:

- `ADDED` — write new tests for the requirement's scenarios.
- `MODIFIED` — the requirement's behavior has changed, which produces **two** outcomes, not one. The agent SHALL write new tests for the requirement's scenarios **as revised**, exactly as it would for an `ADDED` requirement: those scenarios state behavior the change introduces, and a delta operation is not a reason to leave them uncovered. It SHALL **also** establish what was superseded, by reading the existing requirement the delta names under `specsRoot` and comparing it with the delta — this is what `specsRoot` is an essential input for — and record the tests bearing on the superseded behavior in the manifest's obsolete list, following the identification rule below. It SHALL NOT edit or delete those tests.

  Writing a new test for a revised scenario is additive: it creates a file inside the test-path glob and touches no existing test, so it does not reopen the path to rewriting one. Producing only the obsolete list would leave the operation that carries changed behavior as the one operation for which no coverage is written, while the scenario accounting below could still be satisfied by recording each revised scenario as uncovered.
- `REMOVED` — tests covering the removed behavior SHALL likewise be recorded as obsolete. The agent SHALL NOT delete them.
- `RENAMED` — recorded as a rename, with no test change implied.

A change whose `.openspec.yaml` sets `skip_specs: true` carries no delta specs and therefore no scenarios to derive from. **Absent delta specs together with `skip_specs: true` SHALL route to this exempt report and not to the blocked-and-stop path of the dispatch-contract requirement**, which governs a dispatch that is malformed rather than a change that is legitimately specs-exempt. Absent delta specs *without* that marker remains blocked. The agent SHALL report that no new tests are owed and that the existing suite must stay green through the change, and stop. This is a file read, not a judgment, and SHALL NOT be reached by deciding that tests seem unnecessary.

#### Scenario: A modified requirement yields new tests as well as an obsolete list

- **WHEN** a `MODIFIED` delta revises a requirement's scenarios
- **THEN** the agent SHALL write new tests covering those scenarios as revised, **and** record the tests bearing on the superseded behavior as obsolete — not the obsolete list alone

#### Scenario: A modified requirement produces a list, not an edit

- **WHEN** a `MODIFIED` delta means an existing test asserts behavior the change supersedes
- **THEN** the agent SHALL record that test as obsolete with the delta that supersedes it, and SHALL NOT edit or delete it

#### Scenario: An exempt change is distinguishable from a malformed dispatch

- **WHEN** no delta-spec artifact path is supplied and the change's `.openspec.yaml` sets `skip_specs: true`
- **THEN** the agent SHALL produce the exempt report rather than reporting itself blocked, so a dispatcher can tell a legitimately specs-exempt change from a dispatch missing an essential input

#### Scenario: A specs-exempt change stops on a file read

- **WHEN** the change's `.openspec.yaml` sets `skip_specs: true`
- **THEN** the agent SHALL report that no new tests are owed and that the existing suite must stay green, and stop — rather than inferring from the change's content that testing is unnecessary

### Requirement: Obsolete-Test Entries Are Identified by a Stated Procedure and Carry Their Basis

An obsolete-test entry is the input to a human's **destructive** action — deleting or rewriting a test. The agent's additive-only guarantee does not extend to what happens after it reports, so an entry made on grounds the reader cannot see moves the loss one step downstream rather than preventing it. The search SHALL therefore be specified, and every entry SHALL carry the evidence for it.

The agent SHALL search for bearing tests **within the dispatched test-path glob and nowhere else**. Where the dispatch supplies the absolute path of an earlier `test-manifest.md` — an optional input, not an essential one — the agent SHALL also use it as a scenario-to-test mapping. It SHALL NOT go looking for one: the useful referent is the manifest of the change that introduced the now-superseded requirement, which lives in an archived change directory, and constructing that path is what the dispatch-contract requirement forbids. It has never seen the implementation and holds no requirement-to-test index, so an unbounded search would be guesswork presented as a finding.

Every entry SHALL record: the test's runner-selectable identifier; the delta that supersedes it; and **the evidence linking the two** — the assertion, name, or referenced behavior on which the agent matched it. Every entry SHALL be marked a **candidate for human confirmation**, never a conclusion.

Where the agent finds no bearing test for a superseded requirement, it SHALL record that explicitly, distinguishing **"no such test exists"** from **"none was found by this search"**. An empty list SHALL NOT be produced, because an empty list reads as the first while usually meaning the second, and the gap this pass exists to surface would close silently on exactly the operation it was written for.

Where the change carries no `MODIFIED` or `REMOVED` delta at all, the manifest SHALL record the obsolete list as **not applicable, with that reason** — distinguishing a change that supersedes nothing from one whose search found nothing, for the same reason the two outcomes above are distinguished.

#### Scenario: An entry carries the evidence for itself

- **WHEN** the agent records a test as obsoleted by a `MODIFIED` or `REMOVED` delta
- **THEN** the entry SHALL name the evidence on which it was matched and SHALL be marked a candidate for confirmation, so the human who acts on it can disagree on grounds rather than on trust

#### Scenario: Finding nothing is recorded, not left empty

- **WHEN** no bearing test is found for a superseded requirement
- **THEN** the agent SHALL state that no test was found by a search of the dispatched glob, distinguishing it from an assertion that none exists

### Requirement: The Pass Is Additive Only

The agent SHALL NOT edit, delete, or disable any existing test file, under any delta operation and for any stated reason. It SHALL NOT write outside the test-path glob its dispatch supplies, **with exactly one exception: the manifest**, which is written to the change root and is named in this specification rather than left to the agent's judgment. Any other write that would fall outside the glob SHALL stop the pass and be reported.

This binds writes **the agent performs**. Files produced as a side effect of running the dispatched test command — caches, coverage output, compiled artifacts — are not writes by the agent and SHALL NOT stop the pass. Without this bound the agent halts on its own runner's incidental output and reports a boundary violation it did not commit, on the ordinary path of taking a baseline.

The exception is stated as a single named path rather than as a general permission to write where the dispatcher allows. A boundary with one enumerated hole is still checkable; one that admits a judgment about which locations are legitimate reintroduces exactly the reasoning this requirement exists to remove.

It SHALL NOT write implementation. Where tests fail because the code under test does not exist, that is the expected outcome and SHALL be reported as such — creating the module, function, type, or a stub so the tests can execute is writing implementation, and SHALL NOT be done.

The additive-only property SHALL be stated so a dispatcher can rely on it without reading the agent's reasoning: this pass adds tests and never subtracts.

#### Scenario: A write outside the declared test paths halts the pass

- **WHEN** the agent would write to a path outside the test-path glob it was given
- **THEN** it SHALL stop and report the attempted path, rather than deciding for itself whether that location is legitimate

#### Scenario: An absent target is reported, not created

- **WHEN** newly written tests fail because the code under test does not exist
- **THEN** the agent SHALL report that outcome and SHALL NOT create the target — including as an empty stub — to make the tests execute

### Requirement: The Pass Produces a Manifest at a Named Path

Where the pass proceeds past both stop-routes — the blocked report and the specs-exempt report, neither of which writes one — the agent SHALL write a manifest to **`<changeRoot>/test-manifest.md`** — that exact name, so the `rules/` fragment and any later reader can name it — recording, at minimum: each scenario and the tests covering it; each uncovered scenario with its reason; each assertion's classification under the testing floor's specified/derived/deliberately-untested rule; the obsolete-tests list, each entry carrying the superseding delta, the evidence it was matched on, and its candidate-for-confirmation marking; any unresolved project questions with the assumptions taken and the tests depending on them; and the baseline, recorded in whichever form the testing floor permits — including a scoped baseline together with its scope, which that floor makes a first-class form rather than a fallback. The manifest SHALL NOT restate or narrow the floor's baseline rule; it records the result in the forms that rule defines.

The manifest SHALL name tests in a form the test runner can select, so that whoever implements next can run exactly the tests a given task must satisfy.

The agent SHALL state in its report that the manifest is not an artifact the OpenSpec schema knows about, so it is not surfaced by `openspec instructions apply` and must be read deliberately.

#### Scenario: The manifest carries runnable test identifiers

- **WHEN** the manifest records that a scenario is covered
- **THEN** the tests SHALL be named in a form the project's runner can select individually, not described in prose

#### Scenario: The baseline is carried into the manifest

- **WHEN** the pass completes
- **THEN** the manifest SHALL record the baseline taken before the tests were written — full, or scoped together with its scope — or state that none could be taken and why, matching the forms the testing floor defines rather than a narrower pair

### Requirement: The Description Carries the Dispatch Contract and Points to Worked Detail

The agent's `description` SHALL name the inputs a dispatch must supply. The body loads as the subprocess's system prompt only after the payload is fixed, so the description is the only surface a dispatcher reads while it can still act on the contract — a contract stated only in the body is read by the agent and never by what feeds it.

This binds with more force here than on a reviewer of the same flow: this agent's contract carries more inputs, and two of them — the project's test command and the test-path glob — cannot be derived from the change at all. A dispatcher working from a description that omits them supplies a well-motivated dispatch that blocks, which would make blocking the ordinary outcome rather than the exceptional one.

The description SHALL additionally satisfy this library's agent-description standard for trigger summary and worked detail, which `agent-authoring` states and which this requirement does not restate — one numeric rule held in two capabilities is one an edit to either silently falsifies. The `## When to invoke` section it points to SHALL exist in the body.

#### Scenario: A dispatcher can satisfy the contract from the description alone

- **WHEN** a dispatching agent reads only the description before assembling a payload
- **THEN** every essential input is nameable from it, including the test command and the test-path glob, which no reading of the change itself would supply

#### Scenario: The section the description points to exists

- **WHEN** the description refers the reader to `## When to invoke`
- **THEN** that section SHALL be present in the body, carrying the worked dispatch scenarios, as `agent-authoring` requires of every agent in this library

### Requirement: The Manifest Is Reachable by Whoever Implements Next

The manifest is not an artifact the OpenSpec schema defines, so it is not surfaced among the context files an implementation step is handed. The library SHALL therefore carry a rule fragment directing that a change's `test-manifest.md` be read before implementing, and stating why it is not surfaced automatically.

The agent's own report SHALL name the manifest's path as well. The fragment's import path is machine-local, resolving only where this library is checked out at that path, so a fragment alone would leave the manifest unreachable on any other machine. Two independent pointers are deliberate rather than redundant.

#### Scenario: The manifest is pointed to twice

- **WHEN** the pass completes
- **THEN** the manifest's location SHALL be reachable both from the rule fragment and from the agent's own report, so a machine without this library checked out at the imported path still learns where it is

### Requirement: A Repeat Pass Is Specified Rather Than Left to Judgment

A change may be dispatched to this agent more than once — its specs revised after a first pass, or the first pass having stopped early. The agent SHALL therefore be told what a repeat pass does, rather than inferring it.

The agent SHALL **replace** `test-manifest.md` wholesale, because a manifest is a statement about the change as it now stands and a merged one would carry entries whose basis no longer holds. Tests it wrote on an earlier pass are, on a later one, ordinary existing test files: the additive-only rule binds them exactly as it binds any other, so they are never edited or deleted, and any that a revised spec has superseded are recorded in the obsolete list like any other superseded test.

#### Scenario: A second pass replaces the manifest and treats its own prior output as existing tests

- **WHEN** the agent is dispatched onto a change that already carries a `test-manifest.md` and tests from an earlier pass
- **THEN** it SHALL write a fresh manifest replacing the previous one, and SHALL treat the earlier pass's test files as existing tests subject to the additive-only rule rather than as its own work to revise

### Requirement: The Agent Reports and Does Not Implement

The agent's report SHALL state what it wrote, what it could not cover, what it found obsolete, and what the implementation step must make pass. It SHALL NOT mark tasks complete, edit the change's planning artifacts, or implement any part of the change.

Asked to implement, it SHALL say so and stop; that is the apply step's work. Asked to revise the change's artifacts, it SHALL say so and stop; that is a different action on the change.

#### Scenario: A dispatch asking for implementation is declined

- **WHEN** the agent is dispatched with instructions to implement the change as well as write its tests
- **THEN** it SHALL write the tests, report, and state that implementation is not its work, rather than proceeding into it

#### Scenario: Planning artifacts are left untouched

- **WHEN** the agent finds a defect in the change's specs while deriving tests from them
- **THEN** it SHALL report the defect and SHALL NOT edit `proposal.md`, `design.md`, `tasks.md`, or the delta specs
