## MODIFIED Requirements

### Requirement: Triggering is verified before a skill is complete

The workflow SHALL verify that a new skill triggers, using at least one prompt that should activate it and one adjacent prompt that should not. Both outcomes SHALL be reported. A skill SHALL NOT be reported as complete until the positive prompt activates it and the negative prompt does not.

The check SHALL be run by an evaluator holding the candidate prompt and the `name` and `description` of every skill **and every agent** in the library, and not holding the conversation in which the skill was authored. Both asset types are included because the harness selects across skills and agents in a single dispatch decision; an evaluator holding only skills cannot test whether a prompt lands on the correct asset when a skill and an agent compete for it.

The evaluator SHALL also hold every skill and command committed to this repository under `.claude/`. These are not library assets and do not ship in the plugin, but they are tracked, reproducible from a clone, and loaded in every session that works in this repository — so they are not the machine-local state the exclusion below is written against, and they compete for prompts that library assets may not. Excluding them can produce a check that passes while testing nothing, when a new asset's plausible competitors are all repository tooling.

A change to the `name` or `description` of any asset the evaluator holds SHALL invalidate the recorded checks that depend on it, whether that asset is a library asset or one committed under `.claude/`. The `.claude/` assets are installed and updated by an external tool rather than authored here, so a recorded check naming one of them can be falsified by an upgrade that no edit in this repository accompanies — a case the existing invalidation rules, which fire on library additions and on edits made here, do not otherwise reach.

The evaluator's scope SHALL be this repository. Assets belonging to other installed plugins SHALL NOT be held by it, because which plugins are installed is machine-local and not under this repository's control, so a check that varied with it would stop being a statement about this repository. The boundary is `committed to this repository` — the same line the machine-local rationale already draws. The boundary is stated rather than inferred, because the reason for widening across asset types — matching the decision the harness actually makes — does not stop on its own. A description SHOULD nevertheless state what distinguishes the skill from published assets that share its canonical trigger, where those are known. `agent-authoring` states this boundary identically.

A check performed inside the authoring context SHALL NOT be treated as evidence, because the skill is already loaded there and would activate regardless of what its description says.

A failure on the positive prompt SHALL be treated as a description too narrow, and a failure on the negative prompt as a description too broad; in both cases the description is revised and the check repeated.

#### Scenario: Check inside the authoring context is not evidence

- **WHEN** the agent that drafted the description judges whether its own prompt activates the skill, without an isolated evaluator
- **THEN** the result is not accepted as a trigger check, because the skill is already in that agent's context and the outcome tests nothing about the description

#### Scenario: Positive prompt fails to trigger

- **WHEN** the prompt that should activate the skill does not activate it
- **THEN** the description is widened and the check is run again, rather than the skill being reported as complete

#### Scenario: Negative prompt triggers wrongly

- **WHEN** an adjacent prompt outside the skill's scope activates the skill
- **THEN** the description is narrowed and the check is run again

#### Scenario: Check result is reported

- **WHEN** the trigger check completes
- **THEN** both prompts and their outcomes are reported, so evidence exists rather than the description merely having been reviewed

#### Scenario: Skill and agent compete for the same prompt

- **WHEN** a candidate prompt is plausibly served by either a skill or an agent in the library
- **THEN** the evaluator holds both assets' descriptions and reports which one it would select, so the routing between them is tested rather than assumed

#### Scenario: Repository tooling competes for the same prompt

- **WHEN** a new asset's plausible competitors are skills or commands committed under `.claude/` rather than assets in the library
- **THEN** the evaluator holds those descriptions alongside the library's, so the check tests the routing that is actually in question rather than passing against assets that could not have taken the prompt

#### Scenario: An upgrade rewrites an asset the evaluator holds

- **WHEN** an external tool updates a skill or command committed under `.claude/` and its description changes
- **THEN** the recorded checks whose expected routing names that asset are re-run, because the evaluator they were recorded against no longer exists

#### Scenario: A third-party asset shares the canonical trigger

- **WHEN** an installed plugin ships an asset whose stated triggers match the new skill's
- **THEN** the evaluator is not widened to hold it, because its presence is machine-local, and the description instead states the distinction that survives — that this skill operates on this repository's library

### Requirement: Trigger check fixtures are recorded; outcomes are not

A skill SHALL record its trigger check's **fixtures** — the positive and negative prompts, and the routing expected of each — in its `SKILL.md`, so a later check re-runs against the same prompts rather than newly invented ones whose difference would be mistaken for a regression.

The outcome of a run and the date it ran SHALL NOT be recorded. A description edit invalidates the trigger check, so a stored result is only ever valid against a description that may no longer exist, and it reads as assurance to anyone who does not reconstruct the edit history.

Reporting an outcome and recording one are distinct obligations, and this requirement forbids only the second. *Triggering is verified before a skill is complete* requires both prompts and their outcomes to be reported in the authoring session, which is evidence offered at the moment the claim is made; what MUST NOT happen is that outcome persisting in `SKILL.md`, where it outlives the description it describes.

A description edit SHALL invalidate a skill's recorded trigger check, which SHALL then be re-run. `agent-authoring` states the same rule for an agent, together with the body edit that invalidates its cold-run check; a skill has only the one surface.

A change to the `name` or `description` of any asset the evaluator holds SHALL invalidate the recorded checks that depend on it, whether that asset is a library asset or one committed under `.claude/`. *Triggering is verified before a skill is complete* states the same rule where the evaluator's composition is defined; it is restated here because this is the requirement a reader consults to learn what invalidates a check, and a rule reachable from only one of the two is a rule that will be missed from the other.

A change to the **set** of assets the evaluator holds SHALL likewise invalidate every recorded check run against the previous composition. Widening the evaluator is not an edit to any asset, so neither the rule above nor *Adding an asset invalidates competing recorded checks* reaches it — yet it changes what every recorded check runs against, which is the whole of what those rules protect.

The expected routing for the negative prompt SHALL name the asset the evaluator holds that should serve it, where one should, rather than only asserting that it reaches nothing. This is what makes a route between two assets a standing regression test instead of a claim made once. The destination may be an asset committed under `.claude/` rather than a library asset, since the evaluator holds both and a prompt routes where it routes.

The routing recorded SHALL be the correct destination as confirmed by a passing run, not whatever a run happened to produce. A run showing the prompt landing on the wrong asset is a description defect to be fixed and the check re-run; recording the observed routing in that case would turn the fixture into a snapshot of current behaviour and destroy its ability to detect the same drift later.

Fixtures stay in `SKILL.md` because a skill's body loads on demand into an existing context. `agent-authoring` places an agent's fixtures in a companion file instead, because an agent's body is a system prompt carried on every dispatch — the principle is shared, the location follows the cost.

#### Scenario: Fixture is recorded without its result

- **WHEN** a skill's trigger check passes
- **THEN** its two prompts and their expected routing are recorded, and the outcome and run date are not

#### Scenario: Negative prompt names its expected destination

- **WHEN** a skill's negative prompt is one that a different asset the evaluator holds should serve
- **THEN** the fixture records that asset by name, so a later run can detect the prompt drifting to a third asset

#### Scenario: Expected routing names repository tooling

- **WHEN** a skill's negative prompt is one that a skill or command committed under `.claude/` should serve
- **THEN** that asset is recorded as the expected routing, because the evaluator holds it and a fixture asserting the prompt reaches nothing would be false

#### Scenario: Widening the evaluator invalidates recorded checks

- **WHEN** the set of assets the evaluator holds is changed, without any asset's own `name` or `description` being edited
- **THEN** every recorded check run against the previous composition is re-run, because each was a claim about a routing decision made among a different set of candidates

#### Scenario: Outcome is reported without being recorded

- **WHEN** a trigger check is run during authoring
- **THEN** both outcomes are stated to the user in that session, and neither is written into `SKILL.md`, because the two obligations serve different readers at different times

#### Scenario: Description edit invalidates the recorded check

- **WHEN** a skill's `description` is edited after its trigger check was recorded
- **THEN** the check is re-run against the recorded fixtures, because the description is the only surface the check tests
