## MODIFIED Requirements

### Requirement: The Pass Produces a Manifest at a Named Path

The artifact's filename is `test-plan.md`, renamed from `test-manifest.md` by `consolidate-development-workflow`. The name is the one the wider OpenSpec ecosystem uses for an artifact of this shape, so a project forking a schema that declares `id: test-plan` gets this artifact unchanged rather than renaming it at the moment that is least wanted. What the artifact is and what it must carry are unchanged.

Where the pass proceeds past both stop-routes — the blocked report and the specs-exempt report, neither of which writes one — the agent SHALL write a test plan to **`<changeRoot>/test-plan.md`** — that exact name, so the `rules/` fragment and any later reader can name it — recording, at minimum: each scenario and the tests covering it; each uncovered scenario with its reason; each assertion's classification under the testing floor's specified/derived/deliberately-untested rule; the obsolete-tests list, each entry carrying the superseding delta, the evidence it was matched on, and its candidate-for-confirmation marking; any unresolved project questions with the assumptions taken and the tests depending on them; and the baseline, recorded in whichever form the testing floor permits — including a scoped baseline together with its scope, which that floor makes a first-class form rather than a fallback. The manifest SHALL NOT restate or narrow the floor's baseline rule; it records the result in the forms that rule defines.

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

