## MODIFIED Requirements

### Requirement: Trigger check precedes and gates the cold-run check

The workflow SHALL verify that a new agent triggers, using at least one prompt that should dispatch it and one adjacent prompt that should not, with both outcomes reported.

The check SHALL be run by an evaluator holding the candidate prompt and the `name` and `description` of every skill **and every agent** in the library, and not holding the conversation in which the agent was authored. This is the same evaluator composition `skill-authoring` requires, for the same reason: the harness selects across both asset types in a single dispatch decision, so an evaluator scoped to one type cannot test whether a prompt lands on the correct asset.

The evaluator SHALL also hold every skill and command committed to this repository under `.claude/`. These are not library assets and do not ship in the plugin, but they are tracked, reproducible from a clone, and loaded in every session that works in this repository — so they are not the machine-local state the exclusion below is written against, and they compete for prompts that library assets may not. Excluding them can produce a check that passes while testing nothing, when a new agent's plausible competitors are all repository tooling.

A change to the `name` or `description` of any asset the evaluator holds SHALL invalidate the recorded checks that depend on it, whether that asset is a library asset or one committed under `.claude/`. The `.claude/` assets are installed and updated by an external tool rather than authored here, so a recorded check naming one of them can be falsified by an upgrade that no edit in this repository accompanies. `skill-authoring` states this identically, for the same reason the evaluator composition is stated identically.

The evaluator's scope SHALL be this repository. Assets belonging to other installed plugins SHALL NOT be held by it, because which plugins are installed is machine-local and not under this repository's control, so a check that varied with it would stop being a statement about this repository. The boundary is `committed to this repository` — the same line the machine-local rationale already draws. The standard SHALL state this boundary rather than leaving it to be inferred from the widenings above. A description SHOULD nevertheless state what distinguishes the agent from published assets that share its canonical trigger, where those are known — for an agent in this library, that it is authored into this repository's `agents/` is the distinction that holds regardless of what else is installed.

The trigger check SHALL run before the cold-run check, and the cold-run check SHALL NOT be run until the trigger check passes.

#### Scenario: Evaluator spans both asset types

- **WHEN** a new agent's trigger check is run and the library contains skills whose purpose is adjacent to it
- **THEN** the evaluator holds those skills' descriptions alongside every agent's, and reports which single asset it would select

#### Scenario: Repository tooling competes for the same prompt

- **WHEN** a new agent's plausible competitors are skills or commands committed under `.claude/` rather than assets in the library
- **THEN** the evaluator holds those descriptions alongside the library's, so the check tests the routing that is actually in question rather than passing against assets that could not have taken the prompt

#### Scenario: An upgrade rewrites an asset the evaluator holds

- **WHEN** an external tool updates a skill or command committed under `.claude/` and its description changes
- **THEN** the recorded checks whose expected routing names that asset are re-run, because the evaluator they were recorded against no longer exists

#### Scenario: Trigger check gates the expensive check

- **WHEN** the positive prompt fails to dispatch the agent
- **THEN** the description is widened and the trigger check repeated, and the cold-run check is not run until it passes

#### Scenario: A third-party asset shares the canonical trigger

- **WHEN** an installed plugin ships an asset whose stated triggers match the new agent's, such as published guidance on authoring agents
- **THEN** the evaluator is not widened to hold it, because its presence is machine-local, and the description instead states the distinction that survives — that this agent is authored into and operates on this repository's library

### Requirement: Check fixtures are recorded; outcomes are not

Both checks SHALL have their **fixtures** recorded — the trigger check's positive and negative prompts with the routing expected of each, and the cold-run payload — so a later check re-runs against the same inputs rather than newly invented ones whose difference would be mistaken for a regression.

The outcome of a run and the date it ran SHALL NOT be recorded. A body edit invalidates the cold-run check, so a stored result is only ever valid against a body that may no longer exist, and it reads as assurance to anyone who does not reconstruct the edit history. The standard SHALL state this reasoning, so a later reader does not restore the results as an apparent improvement.

Fixtures SHALL be recorded in a companion file at `agents/<agent-name>.checks.yaml`. They MUST NOT be placed in the agent's frontmatter or body: the body is a system prompt carried on every dispatch, and frontmatter is parsed at every load, so either location puts a record no consumer wants onto the dispatch path. Shipping SHALL NOT be given as the reason — a companion file ships with the plugin exactly as frontmatter does; what separates them is that the companion file is never read into a context. Only `.md` files are read as agent definitions, so a `.yaml` companion is not exposed as an asset — the extension, not the depth at which the file sits, is what keeps it invisible to discovery.

An agent SHALL NOT be reported complete until its fixtures file records the prompts and the payload the checks were actually run against. The file is therefore written after the checks, not at the time the agent is written, and post-write validation does not check for it.

The recorded consumer of a fixture SHALL be understood as a later authoring session re-running the check after the library changed. No repository tooling reads it, because `toolkit-structure` bars this repository from carrying any.

A description edit SHALL invalidate the trigger check. A body edit SHALL invalidate the cold-run check. An edit to both SHALL invalidate both. Adding an asset to the library SHALL invalidate the checks of the assets it competes with, as `skill-authoring` requires.

A change to the `name` or `description` of any asset the evaluator holds SHALL invalidate the recorded checks that depend on it, whether that asset is a library asset or one committed under `.claude/`. *Trigger check precedes and gates the cold-run check* states the same rule where the evaluator's composition is defined; it is restated here because this is the requirement a reader consults to learn what invalidates a check, and a rule reachable from only one of the two is a rule that will be missed from the other.

A change to the **set** of assets the evaluator holds SHALL likewise invalidate every recorded check run against the previous composition. Widening the evaluator is not an edit to any asset, so neither the rule above nor the library-addition rule reaches it — yet it changes what every recorded check runs against, which is the whole of what those rules protect. `skill-authoring` states both cases identically.

#### Scenario: Body edit re-runs only the cold-run check

- **WHEN** an agent's system prompt is revised and its description is untouched
- **THEN** the cold-run check is re-run against the recorded payload and the trigger check is not

#### Scenario: A passing result is not stored

- **WHEN** a cold-run check passes
- **THEN** the payload it ran against is recorded and the outcome is not, because the next body edit would make a stored pass a claim about an agent that no longer exists

#### Scenario: Widening the evaluator invalidates recorded checks

- **WHEN** the set of assets the evaluator holds is changed, without any asset's own `name` or `description` being edited
- **THEN** every recorded check run against the previous composition is re-run, because each was a claim about a routing decision made among a different set of candidates

#### Scenario: Fixtures stay off the dispatch path

- **WHEN** an agent's fixtures are recorded
- **THEN** they are written to `agents/<agent-name>.checks.yaml`, and neither the agent's system prompt nor its frontmatter grows as a result
