## MODIFIED Requirements

### Requirement: Authoring may conclude that no skill is warranted

The Intent checkpoint SHALL evaluate whether a skill is the right artifact at all. When the need is better served by a slash command, a subagent, a rule fragment, or a line in project memory, the workflow SHALL recommend that alternative instead of generating a skill.

When the need is better served by a subagent, the workflow SHALL name `create-agent` as the destination, so the referral is a route to a standard that exists rather than an unaddressed recommendation. `agent-authoring` requires the reciprocal route, making the two skills a two-way router.

#### Scenario: Need is too small for a skill

- **WHEN** the described need amounts to a short standing instruction
- **THEN** the workflow recommends a rule fragment or memory entry, and does not generate a skill

#### Scenario: Need matches a different artifact type

- **WHEN** the described need is a deterministic sequence the user wants to invoke explicitly by name
- **THEN** the workflow raises a slash command as the better fit before proceeding

#### Scenario: Need requires its own execution context

- **WHEN** the described need is work that must run with its own context and report back
- **THEN** the workflow routes to `create-agent` by name, rather than recommending "a subagent" without saying where the standard for one lives

### Requirement: Triggering is verified before a skill is complete

The workflow SHALL verify that a new skill triggers, using at least one prompt that should activate it and one adjacent prompt that should not. Both outcomes SHALL be reported. A skill SHALL NOT be reported as complete until the positive prompt activates it and the negative prompt does not.

The check SHALL be run by an evaluator holding the candidate prompt and the `name` and `description` of every skill **and every agent** in the library, and not holding the conversation in which the skill was authored. Both asset types are included because the harness selects across skills and agents in a single dispatch decision; an evaluator holding only skills cannot test whether a prompt lands on the correct asset when a skill and an agent compete for it.

The evaluator's scope SHALL be this library. Assets belonging to other installed plugins SHALL NOT be held by it, because which plugins are installed is machine-local and not under this repository's control, so a check that varied with it would stop being a statement about this library. The boundary is stated rather than inferred, because the reason for widening across asset types — matching the decision the harness actually makes — does not stop at the library on its own. A description SHOULD nevertheless state what distinguishes the skill from published assets that share its canonical trigger, where those are known. `agent-authoring` states this boundary identically.

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

#### Scenario: A third-party asset shares the canonical trigger

- **WHEN** an installed plugin ships an asset whose stated triggers match the new skill's
- **THEN** the evaluator is not widened to hold it, because its presence is machine-local, and the description instead states the distinction that survives — that this skill operates on this repository's library

### Requirement: Description written for reliable triggering

The `description` field SHALL be written as the sole signal used to decide whether to load the skill. It MUST state what the skill does and when it should be used, and MUST include concrete trigger terms a user would plausibly type.

Descriptions SHALL be written in the third person. They SHALL be written to counter under-triggering: they MUST name adjacent phrasings a user might use rather than only the canonical term, because the observed failure mode is a skill not firing when it would have helped.

The third-person rule governs skills. `agent-authoring` permits an agent's description to open `Use this agent when [conditions]`, because every published source for agents prescribes that opener and it addresses the dispatcher rather than the user. The two rules exclude the same failure — a description addressed to a human, as in `…when you want to…` — and the divergence is in the permitted opener alone, recorded here so the difference is not read as drift between the two capabilities.

A description MUST be distinguishable from the description of every other **asset** in the library — every skill and every agent — not from every other skill alone. The dispatch decision is made across both asset types at once, so a description disambiguated only against skills can satisfy this standard and then fail its own trigger check against an agent it was never required to distinguish itself from. Vague descriptions that omit triggering conditions SHALL be rejected.

#### Scenario: Description includes triggering conditions

- **WHEN** a description is drafted as "Helps with skills"
- **THEN** it is rejected for omitting both the concrete action and the conditions under which the skill should fire

#### Scenario: Description uses third person

- **WHEN** a description is drafted as "Use this skill when you want to create a skill"
- **THEN** it is rewritten in the third person, as "This skill should be used when…"

#### Scenario: Description covers adjacent phrasings

- **WHEN** a skill's canonical trigger term is "create a skill"
- **THEN** the description also names plausible variants such as "add a skill", "write a new skill", or "turn this into a skill"

#### Scenario: Description is disambiguated library-wide

- **WHEN** a new skill overlaps in purpose with any existing skill **or agent** in the library
- **THEN** the description states what distinguishes them, so the correct asset is selected at trigger time

### Requirement: Tags are selected from the existing vocabulary

The authoring workflow SHALL present the tags already in use across `skills/` **and `agents/`** before tags are chosen, and SHALL require a reason before a new tag is coined. Tags SHALL be lowercase kebab-case.

The vocabulary spans both directories because `toolkit-structure` makes tags the single classification carried by every asset regardless of type, and `AGENTS.md` already scopes the check for accumulated synonyms to the repository rather than to one asset directory.

#### Scenario: Existing tag is reused

- **WHEN** a proposed tag names a concept an existing tag already covers under a different word
- **THEN** the existing tag is used instead of coining a synonym

#### Scenario: New tag is justified

- **WHEN** no existing tag fits the asset
- **THEN** a new tag is introduced together with the reason it was needed

#### Scenario: Vocabulary spans both asset types

- **WHEN** a skill is tagged and an agent in the library already carries a tag for the same concept
- **THEN** that tag is reused rather than a synonym coined, because the vocabulary is one library-wide set rather than one per directory

## ADDED Requirements

### Requirement: Trigger check fixtures are recorded; outcomes are not

A skill SHALL record its trigger check's **fixtures** — the positive and negative prompts, and the routing expected of each — in its `SKILL.md`, so a later check re-runs against the same prompts rather than newly invented ones whose difference would be mistaken for a regression.

The outcome of a run and the date it ran SHALL NOT be recorded. A description edit invalidates the trigger check, so a stored result is only ever valid against a description that may no longer exist, and it reads as assurance to anyone who does not reconstruct the edit history.

Reporting an outcome and recording one are distinct obligations, and this requirement forbids only the second. *Triggering is verified before a skill is complete* requires both prompts and their outcomes to be reported in the authoring session, which is evidence offered at the moment the claim is made; what MUST NOT happen is that outcome persisting in `SKILL.md`, where it outlives the description it describes.

A description edit SHALL invalidate a skill's recorded trigger check, which SHALL then be re-run. `agent-authoring` states the same rule for an agent, together with the body edit that invalidates its cold-run check; a skill has only the one surface.

The expected routing for the negative prompt SHALL name the asset in the library that should serve it, where one should, rather than only asserting that it reaches nothing. This is what makes a route between two assets a standing regression test instead of a claim made once.

The routing recorded SHALL be the correct destination as confirmed by a passing run, not whatever a run happened to produce. A run showing the prompt landing on the wrong asset is a description defect to be fixed and the check re-run; recording the observed routing in that case would turn the fixture into a snapshot of current behaviour and destroy its ability to detect the same drift later.

Fixtures stay in `SKILL.md` because a skill's body loads on demand into an existing context. `agent-authoring` places an agent's fixtures in a companion file instead, because an agent's body is a system prompt carried on every dispatch — the principle is shared, the location follows the cost.

#### Scenario: Fixture is recorded without its result

- **WHEN** a skill's trigger check passes
- **THEN** its two prompts and their expected routing are recorded, and the outcome and run date are not

#### Scenario: Negative prompt names its expected destination

- **WHEN** a skill's negative prompt is one that a different asset in the library should serve
- **THEN** the fixture records that asset by name, so a later run can detect the prompt drifting to a third asset

#### Scenario: Outcome is reported without being recorded

- **WHEN** a trigger check is run during authoring
- **THEN** both outcomes are stated to the user in that session, and neither is written into `SKILL.md`, because the two obligations serve different readers at different times

#### Scenario: Description edit invalidates the recorded check

- **WHEN** a skill's `description` is edited after its trigger check was recorded
- **THEN** the check is re-run against the recorded fixtures, because the description is the only surface the check tests

### Requirement: Adding an asset invalidates competing recorded checks

A recorded trigger check SHALL be understood as valid only against the library that existed when it ran. When an asset is added to the library, the recorded checks of the assets it competes with for the same prompts SHALL be re-run and updated as part of the same change.

The library is flat and carries no index, so every asset competes with every other for the same dispatch decision; a recorded check naming a prompt that "activated nothing" is a claim about a library that a later addition can silently falsify.

#### Scenario: A new asset falsifies a recorded negative

- **WHEN** a new asset is added whose purpose matches a prompt recorded as the negative case of an existing asset's trigger check
- **THEN** that recorded check is re-run and updated in the same change, rather than left asserting an outcome that is no longer true

#### Scenario: Unrelated assets are not re-checked

- **WHEN** a new asset is added that competes with no existing asset's recorded prompts
- **THEN** no existing recorded check is re-run, because none of them made a claim the addition affects
