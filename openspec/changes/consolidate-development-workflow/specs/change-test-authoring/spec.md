## MODIFIED Requirements

### Requirement: The Pass Produces a Manifest at a Named Path

The artifact's filename is `test-plan.md`, renamed from `test-manifest.md` by `consolidate-development-workflow`. The name is the one the wider OpenSpec ecosystem uses for an artifact of this shape, so a project forking a schema that declares `id: test-plan` gets this artifact unchanged rather than renaming it at the moment that is least wanted. What the artifact is and what it must carry are unchanged.

Where the pass proceeds past both stop-routes — the blocked report and the specs-exempt report, neither of which writes one — the agent SHALL write a manifest to **`<changeRoot>/test-plan.md`** — that exact name, so the `rules/` fragment and any later reader can name it — recording, at minimum: each scenario and the tests covering it; each uncovered scenario with its reason; each assertion's classification under the testing floor's specified/derived/deliberately-untested rule; the obsolete-tests list, each entry carrying the superseding delta, the evidence it was matched on, and its candidate-for-confirmation marking; any unresolved project questions with the assumptions taken and the tests depending on them; and the baseline, recorded in whichever form the testing floor permits — including a scoped baseline together with its scope, which that floor makes a first-class form rather than a fallback. The manifest SHALL NOT restate or narrow the floor's baseline rule; it records the result in the forms that rule defines.

The manifest SHALL name tests in a form the test runner can select, so that whoever implements next can run exactly the tests a given task must satisfy.

The agent SHALL state in its report that the manifest is not an artifact the OpenSpec schema knows about, so it is not surfaced by `openspec instructions apply` and must be read deliberately.

#### Scenario: The manifest carries runnable test identifiers

- **WHEN** the manifest records that a scenario is covered
- **THEN** the tests SHALL be named in a form the project's runner can select individually, not described in prose

#### Scenario: The baseline is carried into the manifest

- **WHEN** the pass completes
- **THEN** the manifest SHALL record the baseline taken before the tests were written — full, or scoped together with its scope — or state that none could be taken and why, matching the forms the testing floor defines rather than a narrower pair


### Requirement: The Manifest Is Reachable by Whoever Implements Next

The manifest is not an artifact the OpenSpec schema defines, so it is not surfaced among the context files an implementation step is handed. The library SHALL therefore carry a rule fragment directing that a change's `test-plan.md` be read before implementing, and stating why it is not surfaced automatically.

The agent's own report SHALL name the manifest's path as well. The fragment's import path is machine-local, resolving only where this library is checked out at that path, so a fragment alone would leave the manifest unreachable on any other machine. Two independent pointers are deliberate rather than redundant.

#### Scenario: The manifest is pointed to twice

- **WHEN** the pass completes
- **THEN** the manifest's location SHALL be reachable both from the rule fragment and from the agent's own report, so a machine without this library checked out at the imported path still learns where it is


### Requirement: A Repeat Pass Is Specified Rather Than Left to Judgment

A change may be dispatched to this agent more than once — its specs revised after a first pass, or the first pass having stopped early. The agent SHALL therefore be told what a repeat pass does, rather than inferring it.

The agent SHALL **replace** `test-plan.md` wholesale, because a manifest is a statement about the change as it now stands and a merged one would carry entries whose basis no longer holds. Tests it wrote on an earlier pass are, on a later one, ordinary existing test files: the additive-only rule binds them exactly as it binds any other, so they are never edited or deleted, and any that a revised spec has superseded are recorded in the obsolete list like any other superseded test.

#### Scenario: A second pass replaces the manifest and treats its own prior output as existing tests

- **WHEN** the agent is dispatched onto a change that already carries a `test-plan.md` and tests from an earlier pass
- **THEN** it SHALL write a fresh manifest replacing the previous one, and SHALL treat the earlier pass's test files as existing tests subject to the additive-only rule rather than as its own work to revise



### Requirement: The Change Is Supplied by Dispatch, Not Discovered

The agent SHALL work on what its dispatcher names and SHALL NOT search for a change to act on or infer the repository from where it was dispatched.

**Essential inputs**, without which there is nothing to act on: the change name, the absolute `changeRoot`, the resolved artifact paths, the absolute path to the change's `.openspec.yaml`, the absolute paths of the project's convention files (`AGENTS.md`, `CLAUDE.md`, or their absence stated explicitly), the project's test command, and the **test-path glob** identifying where tests may be written.

`specsRoot` is **conditionally** essential, stated separately so the qualification cannot be read as binding the inputs around it. It is required where the change carries a `MODIFIED`, `REMOVED` or `RENAMED` delta, because establishing what was superseded means reading the requirement as it currently stands. Where every delta is `ADDED` there is nothing to compare against and the agent SHALL NOT block on its absence, whether or not the project records specifications elsewhere.

The dispatch MAY additionally supply the absolute path of an earlier `test-plan.md`. This is optional: its absence changes what the obsolete search can draw on, not whether the pass can proceed.

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

The agent SHALL read only: the change's artifacts at the paths supplied; the specifications under `specsRoot`; the project's dispatched convention files; an earlier `test-plan.md` where its path is supplied; and files within the dispatched test-path glob. It SHALL NOT read the implementation of the behaviour under test, and SHALL NOT do so in order to establish what a `MODIFIED` delta supersedes — the delta and the existing requirement state that, which is what `specsRoot` is for.

Reading a source file outside the test-path glob to determine what an assertion should say SHALL be reported as a departure from this bound, not resolved silently.

#### Scenario: Superseded behaviour is established from specifications, not from code

- **WHEN** the agent must determine what a `MODIFIED` delta supersedes
- **THEN** it SHALL do so by comparing the delta with the existing requirement under `specsRoot`, and SHALL NOT read the implementation to find out

#### Scenario: The read bound is reported rather than crossed silently

- **WHEN** the agent cannot proceed without reading implementation source
- **THEN** it SHALL report that it is blocked on the bound rather than crossing it, so the property the separate context exists to secure is not lost unrecorded

### Requirement: Obsolete-Test Entries Are Identified by a Stated Procedure and Carry Their Basis

An obsolete-test entry is the input to a human's **destructive** action — deleting or rewriting a test. The agent's additive-only guarantee does not extend to what happens after it reports, so an entry made on grounds the reader cannot see moves the loss one step downstream rather than preventing it. The search SHALL therefore be specified, and every entry SHALL carry the evidence for it.

The agent SHALL search for bearing tests **within the dispatched test-path glob and nowhere else**. Where the dispatch supplies the absolute path of an earlier `test-plan.md` — an optional input, not an essential one — the agent SHALL also use it as a scenario-to-test mapping. It SHALL NOT go looking for one: the useful referent is the manifest of the change that introduced the now-superseded requirement, which lives in an archived change directory, and constructing that path is what the dispatch-contract requirement forbids. It has never seen the implementation and holds no requirement-to-test index, so an unbounded search would be guesswork presented as a finding.

Every entry SHALL record: the test's runner-selectable identifier; the delta that supersedes it; and **the evidence linking the two** — the assertion, name, or referenced behavior on which the agent matched it. Every entry SHALL be marked a **candidate for human confirmation**, never a conclusion.

Where the agent finds no bearing test for a superseded requirement, it SHALL record that explicitly, distinguishing **"no such test exists"** from **"none was found by this search"**. An empty list SHALL NOT be produced, because an empty list reads as the first while usually meaning the second, and the gap this pass exists to surface would close silently on exactly the operation it was written for.

Where the change carries no `MODIFIED` or `REMOVED` delta at all, the manifest SHALL record the obsolete list as **not applicable, with that reason** — distinguishing a change that supersedes nothing from one whose search found nothing, for the same reason the two outcomes above are distinguished.

#### Scenario: An entry carries the evidence for itself

- **WHEN** the agent records a test as obsoleted by a `MODIFIED` or `REMOVED` delta
- **THEN** the entry SHALL name the evidence on which it was matched and SHALL be marked a candidate for confirmation, so the human who acts on it can disagree on grounds rather than on trust

#### Scenario: Finding nothing is recorded, not left empty

- **WHEN** no bearing test is found for a superseded requirement
- **THEN** the agent SHALL state that no test was found by a search of the dispatched glob, distinguishing it from an assertion that none exists
