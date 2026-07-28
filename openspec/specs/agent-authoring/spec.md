# agent-authoring Specification

## Purpose

Defines the standard an agent definition in this repository must meet, and the workflow that produces one: the routing gate that must justify an independent execution context before authoring begins, the frontmatter contract reconciled across two disagreeing published sources and the shipped agent corpus, the flat-file rule and its effect on invocation names, tool selection including scoped grants, the description standard for dispatch triggering, the system-prompt standard for a fresh-context subprocess including the dispatch contract, the human-in-the-loop checkpoints, post-write validation, and the two-stage verification of a trigger check followed by a cold-run check.

## Requirements

### Requirement: Authoring begins with a routing gate

The authoring workflow SHALL, before any other step, establish that the work requires its own execution context. When it does not, the workflow SHALL recommend the artifact that fits and stop, rather than producing an agent.

Work belonging in the caller's context SHALL be routed to `create-skill`. A deterministic sequence the user wants to invoke by name SHALL be routed to a slash command. A short standing instruction SHALL be routed to a rule fragment in `rules/` or to project memory.

Recommending an alternative and stopping SHALL be treated as a complete and successful outcome of the workflow, not as a failure to produce an asset.

#### Scenario: Work belongs in the caller's context

- **WHEN** the described need is procedural knowledge that the assistant should apply within the current conversation
- **THEN** the workflow recommends authoring a skill via `create-skill` and does not generate an agent

#### Scenario: Independent context is justified

- **WHEN** the described need is work that must run with its own context, its own tool grant, and report back a result
- **THEN** the routing gate passes and authoring proceeds

#### Scenario: Referral without a receiving standard

- **WHEN** the described need amounts to a short standing instruction and the correct destination is `rules/`, which has no authoring standard
- **THEN** the workflow still makes the referral, because the recommendation does not depend on a workflow existing to receive it

### Requirement: Agent frontmatter contract

Every agent definition SHALL begin with YAML frontmatter declaring `name` and `description`, which are the only fields required for an agent to load.

`model`, `color`, `tools`, and `effort` SHALL be treated as optional at load time. The standard SHALL nevertheless direct that `model` and `color` be declared by default, and SHALL state plainly that this is compatibility with the shipped `validate-agent.sh`, which errors without them, rather than a loader constraint.

The contract SHALL record the constraints that script places on the values, not only on which fields are present: `name` SHALL start and end with an alphanumeric character, contain only letters, numbers and hyphens, and be between 3 and 50 characters, which the script enforces as a hard error; and a declared `color` SHALL be drawn from the set it accepts, which it enforces as a warning. A contract recording which fields are required while leaving what may be written in them unstated produces agents that fail the tool it was reconciled against, which is the friction the compatibility direction above exists to avoid.

`effort` SHALL be recorded as a field neither published source documents. The snapshot SHALL name the values observed in the reconciled corpus and SHALL state that the accepted set is unverified, because no published document enumerates it and `validate-agent.sh` does not check it. The standard MUST NOT present an enumeration of accepted values it cannot source, and the Shape checkpoint's confirmation of `effort` SHALL be understood as a choice made against that recorded uncertainty.

Where no specific model is called for, the declared value SHALL be `model: inherit`, which the validator accepts. Declaring a concrete model to satisfy a validator would pin a model on every consuming project for a reason the standard itself records as a tool defect.

`metadata.tags` MAY be declared, as `toolkit-structure` permits for every asset. Tags SHALL be lowercase kebab-case and SHALL be chosen from the vocabulary already in use across `skills/` and `agents/`, with a stated reason required before a new tag is coined. The standard SHALL record that no agent in the reconciled corpus declares `metadata`, so the loader's acceptance of it had no external evidence behind it; this was confirmed directly rather than left assumed — a throwaway agent declaring `metadata: { tags: [...] }` loaded and dispatched normally under `claude -p --plugin-dir`, confirmed 2026-07-28.

Because the published sources disagree with one another and with shipped practice, the contract SHALL be recorded as a dated snapshot naming every source it was reconciled from — the validation script, the `agent-development` skill, and the shipped agent corpus — together with the points on which they conflict. It SHALL NOT be presented as a closed enumeration derived from a single authority.

#### Scenario: Minimal valid frontmatter

- **WHEN** an agent is generated
- **THEN** its frontmatter declares at least `name` and `description`

#### Scenario: Optional fields are declared for validator compatibility

- **WHEN** an agent is generated and no specific model or colour is called for
- **THEN** `model: inherit` and a colour are still declared, and the standard records that the reason is `validate-agent.sh` compatibility rather than a requirement of the loader, and that `inherit` is chosen so the compatibility measure imposes no model on a consuming project

#### Scenario: Tags follow the library vocabulary

- **WHEN** an agent declares `metadata.tags`
- **THEN** every tag is lowercase kebab-case and drawn from the vocabulary already in use across the library, and any new tag is introduced with a stated reason

#### Scenario: Conflicting sources are recorded as conflicts

- **WHEN** the standard states whether `color` is required
- **THEN** it records that the validation script errors without it while shipped agents omit it and load, rather than asserting one source as authoritative

#### Scenario: A value constraint is recorded alongside the field

- **WHEN** the contract states that `color` should be declared
- **THEN** it also states the set of values the validation script accepts, so an agent conforming to the contract does not earn a warning for a colour the standard never ruled out

#### Scenario: An undocumented field is recorded as undocumented

- **WHEN** the contract covers `effort`
- **THEN** it records the values observed in the corpus, that neither published source mentions the field at all, and that the accepted set is therefore unverified, rather than presenting an enumeration it has no source for

### Requirement: Agent placement and name agreement

An agent definition SHALL reside directly inside `agents/` as `agents/<agent-name>.md`, with no intervening directory. The frontmatter `name` and the file's base name MUST be identical.

Where the two differ, the frontmatter `name` SHALL be treated as the one that wins at load time. This is now a verified finding, not an open question: a throwaway agent with a deliberately mismatched `name` and file base name was dispatched under `claude -p --plugin-dir`, and it registered and was invoked by its frontmatter `name`, confirmed 2026-07-28. The requirement that the two agree stands regardless of which one wins — a mismatch is confusing to a reader even though the loader resolves it consistently.

The standard SHALL state the reason: agent discovery walks subdirectories but folds them into the invocation name as `plugin:subdir:agent-name`, so a grouping directory makes a grouping decision part of the agent's name and renames the agent if the grouping is later revised.

A companion file belonging to an agent MAY sit beside it in `agents/`, provided its extension is not `.md`, since only `.md` files are read as agent definitions. Such a file is not an asset: it ships with the plugin and is never exposed as an agent. `toolkit-structure` constrains where assets are placed and requires that a placeholder standing in for an unpopulated directory not be discoverable; it places no restriction on non-`.md` files, so a companion file needs no exception from it, and it names the same `.md` criterion this requirement relies on.

#### Scenario: Agent is placed flat

- **WHEN** an agent named `commit-reviewer` is authored
- **THEN** its definition is written to `agents/commit-reviewer.md` and its frontmatter declares `name: commit-reviewer`

#### Scenario: Grouping directory is rejected

- **WHEN** a proposed agent would be placed in a grouping subdirectory under `agents/`
- **THEN** the placement is reported as a defect, because it encodes the grouping into the invocation name

### Requirement: Agents are authored into the toolkit library

The authoring workflow SHALL write agents into this repository's `agents/` directory. It MUST NOT write into the project it was invoked from, and MUST NOT silently resolve a different target such as a project-level or personal agents directory.

The skill's own `description` SHALL state this scope.

#### Scenario: Invoked from a consuming project

- **WHEN** the workflow is invoked from a project that installed this library as a plugin
- **THEN** it states that it authors into the toolkit repository and confirms that is the intent, rather than writing an agent into the current project

### Requirement: Description written for reliable dispatch

The `description` SHALL be written as the signal the harness uses to decide whether to dispatch the agent. It SHALL state the conditions under which the agent is dispatched, SHALL name adjacent phrasings rather than only the canonical term, and MUST be distinguishable from the description of every other asset in the library.

The description MUST NOT address the user in the second person. The opener `Use this agent when [conditions]` SHALL be permitted, because it addresses the dispatcher rather than the user and is prescribed by both published sources; the form ruled out is `Use this agent when you want to…`, which reads as instructions to a human instead of as a dispatch signal.

The description SHALL carry a prose summary of two to four trigger scenarios and SHALL point to a `## When to invoke` section in the agent body for worked detail. It SHALL NOT carry `<example>` blocks, because the description is always resident in context while the body loads only on dispatch.

The standard SHALL record that an agent conforming to it still produces one `validate-agent.sh` warning — the absent `<example>` blocks — and that this is expected rather than a defect. It SHALL state the conditions that claim depends on: the colour is drawn from the accepted set, and the body stays under the length the same script warns at. A claim of one warning made without its conditions is falsified by the first author who picks a colour outside the set, and a standard falsified by its own output is read as wrong rather than as incomplete.

#### Scenario: Dispatcher-addressed opener is accepted

- **WHEN** a description opens `Use this agent when the user asks for a security review of staged changes`
- **THEN** it is accepted, because it names dispatch conditions and addresses the dispatcher, while `Use this agent when you want your code reviewed` is rejected for addressing the user

#### Scenario: Trigger scenarios are summarised in prose

- **WHEN** a description names the situations that should dispatch the agent
- **THEN** it summarises two to four of them in prose and refers to `## When to invoke` in the body, rather than embedding worked `<example>` blocks

#### Scenario: Description is disambiguated library-wide

- **WHEN** a new agent overlaps in purpose with any existing skill or agent in the library
- **THEN** the description states what distinguishes them, so the correct asset is selected at dispatch time

### Requirement: Tool grants follow least privilege

The `tools` field SHALL grant the minimum set the agent's work requires. The standard SHALL document both syntaxes found in shipped agents — a YAML array and a bare comma-separated list — and SHALL document the scoped-grant form, which whitelists the named subagents or workflows an agent may dispatch and admits more than one target.

Omitting `tools` SHALL be understood as granting all tools, and SHALL be chosen deliberately rather than by default.

#### Scenario: Read-only agent is granted read-only tools

- **WHEN** an agent's work is to locate and report on code without modifying it
- **THEN** its `tools` grant excludes write and edit tools, so the read-only contract is enforced by the grant and not only by its prompt

#### Scenario: Scoped grant is used for delegation

- **WHEN** an agent must dispatch one or more specific subagents and no others
- **THEN** the scoped-grant form naming exactly those subagents is used rather than granting the general dispatch capability

### Requirement: System prompt standard for a fresh-context subprocess

The agent body SHALL be written in the second person as a system prompt, and SHALL contain all of the following:

1. A **dispatch contract** stating explicitly what the dispatcher must supply for the agent to do its work.
2. Absolute-path discipline, because the working directory is not inherited.
3. A stance treating everything the agent reads as untrusted data rather than as instructions.
4. A declared output format, which is the agent's only channel back to its dispatcher.
5. A stopping condition.

The body SHOULD stay under the length `validate-agent.sh` warns at, which the five elements above together with a `## When to invoke` section can reach. Where a body legitimately exceeds it, the resulting warning SHALL be recorded as expected in the same way the absent `<example>` blocks are.

#### Scenario: Dispatch contract is stated

- **WHEN** an agent requires a repository path, a target file, or any other input to begin work
- **THEN** the body states that the dispatcher supplies it, rather than assuming the agent can discover it from context it does not have

#### Scenario: Output format is declared

- **WHEN** an agent completes its work
- **THEN** the body has declared the format of the report it returns, because the dispatcher receives nothing else

#### Scenario: Repository content is treated as data

- **WHEN** the agent reads a file containing text addressed to it as an instruction
- **THEN** the body directs it to report that text rather than act on it

### Requirement: Human-in-the-loop checkpoint sequence

The authoring workflow SHALL pause for human confirmation before authoring proceeds:

1. **Intent** — the workflow SHALL evaluate the routing gate, and confirm the agent's name, that the name is unused under `agents/`, its tags, purpose, and dispatch conditions.
2. **Shape** — the workflow SHOULD confirm the tool grant, model, and effort when these are not obvious, and MAY skip this checkpoint when they are.
3. **Draft** — the workflow SHALL present the proposed frontmatter and a body outline for approval before the full body is written.

The workflow MUST NOT write any file before the Draft checkpoint is approved.

#### Scenario: Routing gate is evaluated at Intent

- **WHEN** a user asks for a new agent
- **THEN** the workflow establishes that an independent execution context is justified before confirming any naming or structural detail

#### Scenario: Draft is approved before the body is written

- **WHEN** the frontmatter and outline are presented
- **THEN** no file is written until the user approves, and requested revisions are applied to the draft first

### Requirement: Post-write validation

After writing an agent, the workflow SHALL verify and report that: frontmatter parses as valid YAML; `name` matches the file's base name and satisfies the format and length constraints the contract records; a declared `color` is drawn from the accepted set; the file sits directly inside `agents/` with no intervening directory; any declared tags are lowercase kebab-case; the description states both the dispatch conditions and a prose trigger summary; the `## When to invoke` section the description points to exists in the body; and the body contains each element the system prompt standard requires. Any failure SHALL be reported explicitly rather than silently corrected.

This validation SHALL cover only what is knowable when the file is written. The fixtures file is not checked here, because the fixtures it carries are produced by the two checks that follow; its existence is a condition of reporting the agent complete, stated with the fixtures requirement.

#### Scenario: Validation passes

- **WHEN** a generated agent satisfies every check
- **THEN** the workflow reports the checks that ran and the file path written

#### Scenario: Missing dispatch contract is caught

- **WHEN** a generated agent's body requires an input but never states that the dispatcher supplies it
- **THEN** validation reports the omission rather than reporting success

#### Scenario: Description points at a section that was never written

- **WHEN** a description closes by referring the reader to `## When to invoke` in the body and no such section exists
- **THEN** validation reports the dangling reference rather than reporting success, because the pointer is part of the description form this standard requires

### Requirement: Trigger check precedes and gates the cold-run check

The workflow SHALL verify that a new agent triggers, using at least one prompt that should dispatch it and one adjacent prompt that should not, with both outcomes reported.

The check SHALL be run by an evaluator holding the candidate prompt and the `name` and `description` of every skill **and every agent** in the library, and not holding the conversation in which the agent was authored. This is the same evaluator composition `skill-authoring` requires, for the same reason: the harness selects across both asset types in a single dispatch decision, so an evaluator scoped to one type cannot test whether a prompt lands on the correct asset.

The evaluator's scope SHALL be this library. Assets belonging to other installed plugins SHALL NOT be held by it, because which plugins are installed is machine-local and not under this repository's control, so a check that varied with it would stop being a statement about this library. The standard SHALL state this boundary rather than leaving it to be inferred from the widening above. A description SHOULD nevertheless state what distinguishes the agent from published assets that share its canonical trigger, where those are known — for an agent in this library, that it is authored into this repository's `agents/` is the distinction that holds regardless of what else is installed.

The trigger check SHALL run before the cold-run check, and the cold-run check SHALL NOT be run until the trigger check passes.

#### Scenario: Evaluator spans both asset types

- **WHEN** a new agent's trigger check is run and the library contains skills whose purpose is adjacent to it
- **THEN** the evaluator holds those skills' descriptions alongside every agent's, and reports which single asset it would select

#### Scenario: Trigger check gates the expensive check

- **WHEN** the positive prompt fails to dispatch the agent
- **THEN** the description is widened and the trigger check repeated, and the cold-run check is not run until it passes

#### Scenario: A third-party asset shares the canonical trigger

- **WHEN** an installed plugin ships an asset whose stated triggers match the new agent's, such as published guidance on authoring agents
- **THEN** the evaluator is not widened to hold it, because its presence is machine-local, and the description instead states the distinction that survives — that this agent is authored into and operates on this repository's library

### Requirement: Cold-run check verifies the system prompt in isolation

The workflow SHALL verify that the agent body functions as a system prompt in a context that holds nothing from the authoring conversation. This check SHALL be mandatory, and SHALL have a floor of one representative task rather than a suite.

The **live half** SHALL run the drafted agent against one payload containing only what its dispatch contract names, and nothing from the authoring conversation. It SHALL take whichever of two forms the harness supports:

- **Real dispatch, preferred** — the repository is loaded so the drafted agent is registered, and the agent is dispatched by name. This form SHALL be used when available, because it enforces the `tools` grant and honours `model` and `effort`, which the fallback cannot. Every registration mechanism the standard records SHALL be tried before this form is declared unavailable, so the preferred form is not retired on the failure of one of them.
- **Simulation, fallback** — a subagent is spawned whose entire instruction set is the drafted body verbatim.

The standard SHALL record which form was verified to work, and SHALL state the fallback's two limits: it grants all tools, and it delivers the body as a prompt rather than as a system prompt, which is a weaker position in the instruction hierarchy.

The live half SHALL evaluate the agent's own report. A dispatch form that cannot surface that report verbatim — because what returns is the dispatching session's summary of the agent's work rather than the agent's own output — SHALL be treated as unavailable, and the fallback used in its place. Every pass criterion but the tool grant is a judgment about what the agent returned, so a relayed or paraphrased report tests the dispatcher rather than the agent.

The **static half** — reconciling every tool the body instructs the agent to use against the `tools` field — SHALL be run whenever the live half is a simulation, because it covers the tool-enforcement gap the simulation leaves, and SHALL also be run alongside a real dispatch, where it is a cheap redundancy rather than coverage. A real dispatch catches a tool reach only on the branch the run happens to exercise.

Pass criteria SHALL be bound to properties the body declares — the output format it declares, the inputs its dispatch contract names, the lane it sets, and whether it concluded on its own.

Both criteria that describe the agent's behaviour rather than its output SHALL be stated as something the run can show. The dispatch contract SHALL be treated as incomplete when the returned report evidences context the payload did not supply in **any** of three forms: the agent asked for it, the agent declared itself blocked on it, or the agent proceeded on an assumption not derivable from the payload — an invented path, an assumed working directory, or a reference to a discussion it never had. A criterion written as asking alone tests an event that cannot occur, because neither live form is interactive, and it would omit the form that actually occurs.

Termination SHALL be judged by why the run ended, not by whether it ended. A run that concluded because the body told it to satisfies the criterion; a run that ended because the harness's turn or time budget ran out SHALL be reported as a missing stopping condition, because an unbounded agent returns a truncated report rather than visibly running forever.

The check SHALL NOT grade the quality of the agent's output.

An agent SHALL NOT be reported complete until the check passes, and each failure SHALL be mapped to the body revision that addresses it.

#### Scenario: Real dispatch is preferred over simulation

- **WHEN** the harness can load the drafted agent so that it is dispatchable by name
- **THEN** the live half dispatches it for real rather than simulating it, so the tool grant is enforced by the harness instead of reconciled by inspection

#### Scenario: Fallback is used and its gap is covered

- **WHEN** the drafted agent cannot be registered for a real dispatch
- **THEN** a subagent is spawned carrying the drafted body verbatim, and the static half is run, because a simulated dispatch grants all tools

#### Scenario: The agent's report is not recoverable from a real dispatch

- **WHEN** a real dispatch returns only the dispatching session's summary rather than the drafted agent's own report
- **THEN** that form is treated as unavailable and the simulation fallback is used, because criteria applied to a summary test the dispatcher rather than the agent

#### Scenario: Agent does not terminate

- **WHEN** the cold-run agent's run ends because the harness's turn or time budget ran out rather than because its body directed it to conclude
- **THEN** the failure is reported as a missing stopping condition and the body is revised, rather than the truncated report being read as a short answer

#### Scenario: Agent assumes context it never received

- **WHEN** the cold-run agent's report rests on an input the dispatch payload did not contain — a path it invented, a working directory it assumed, or a discussion it refers to
- **THEN** the dispatch contract is reported incomplete and the body is revised, rather than the payload being widened to make the run pass

#### Scenario: Silent assumption counts as a failure, not only a request

- **WHEN** the cold-run agent needs context the contract did not name and, having no channel on which to ask for it, proceeds on a guess and returns a plausible report
- **THEN** the criterion is failed on the evidence in the report, because a criterion satisfied only by the agent asking would be unfalsifiable in a non-interactive dispatch

#### Scenario: Tool reach is caught statically

- **WHEN** the body instructs the agent to edit a file but `tools` grants no edit capability
- **THEN** the static half reports the mismatch, which the live half cannot catch because a simulated dispatch grants all tools

#### Scenario: Output drifts from its declaration

- **WHEN** the agent returns prose while its body declared a structured report
- **THEN** the output format is reported underspecified and the body is revised

#### Scenario: Quality is not the criterion

- **WHEN** the cold-run agent honours its declared format, contract, and lane but produces a mediocre result
- **THEN** the check passes, because it tests whether the agent did what its body said it would and not whether the result was good

### Requirement: Cold runs are isolated when the agent can write

When the drafted agent's tool grant includes write, edit, or shell capability, the live half of the cold-run check SHALL run in an isolated git worktree, so that the run's path-directed writes land beside the repository the agent was authored in rather than in it.

The worktree SHALL be populated with the drafted agent before the run: the definition at `agents/<agent-name>.md`, together with any file its body references, SHALL be copied into it, and the real dispatch SHALL register the plugin from the worktree rather than from the authoring checkout. A worktree is created from a committed ref, while the agent under authoring is untracked at the moment the check runs — so a worktree left unpopulated does not contain the agent, and a dispatch by name finds nothing to dispatch. Without this step the preferred form of the check is unexecutable in exactly the case where isolation is required. The simulation fallback needs no such step, because it carries the body verbatim rather than loading it from disk.

Every path the dispatch payload carries that the agent may write to SHALL be rewritten to the worktree root before the run, and a payload naming a writable path outside the worktree SHALL abort the run rather than proceed. Without this the isolation is nominal: the standard requires absolute-path discipline, so the natural payload names the repository the agent was authored in, and an agent given that path writes to the original checkout from inside its worktree.

The abort SHALL bind writable paths only. A payload MAY name a path outside the worktree that the agent only reads, because a worktree contains writes and a rule wider than that makes the check unsatisfiable for any agent whose work legitimately reads a plugin cache, a home-directory configuration, or a sibling checkout.

The run SHALL additionally be launched with its working directory set to the worktree root, and the authoring checkout MUST NOT be made available to it as a writable directory. Rewriting the payload is not sufficient on its own: a body lacking the absolute-path discipline the system prompt standard requires resolves relative paths against the launch directory, so the very defect this check exists to detect is the one that escapes the isolation, and it escapes it before the check can report it. The mechanism differs by form — a real dispatch is started from inside the populated worktree, loads the plugin from it, and is given no additional writable directory naming the authoring checkout, while the simulation's worktree isolation already sets the subagent's working directory to the isolated root.

The standard SHALL state what the worktree does and does not contain. It redirects writes addressed by path; it is not a sandbox. An agent granted network or external-service tools reaches past it, and so does an agent granted shell capability — the same grant that makes isolation mandatory — which can address any path the process can reach. For both, the standard SHALL direct that the payload and the permission mode the run is launched under be reviewed before the run, rather than presenting the worktree as sufficient containment.

#### Scenario: Drafted agent is copied into the worktree before the run

- **WHEN** a write-capable agent is cold-run by real dispatch and the isolation worktree has just been created
- **THEN** the uncommitted definition is copied into the worktree and the plugin is loaded from there, because a worktree created from a committed ref does not contain a file that has never been committed

#### Scenario: Write-capable agent is cold-run in a worktree

- **WHEN** a drafted agent's `tools` grant includes `Write` or `Edit`
- **THEN** the live half runs in an isolated worktree rather than in the working repository

#### Scenario: Payload path is rewritten to the isolated root

- **WHEN** a dispatch contract names a repository path and the live half runs in a worktree
- **THEN** the payload carries the worktree's path rather than the authoring repository's, so the agent's writes land inside the isolation rather than beside it

#### Scenario: A body without absolute-path discipline cannot escape the isolation

- **WHEN** a write-capable agent's body names a relative output path and the live half runs in a worktree
- **THEN** the run's working directory is the worktree root, so the write lands inside the isolation and is then reported as the missing absolute-path discipline it is, rather than landing in the authoring checkout before the check reports anything

#### Scenario: Read-only path outside the worktree does not abort

- **WHEN** a write-capable agent's dispatch contract names a path it only reads, such as an installed plugin's directory, and that path lies outside the worktree
- **THEN** the run proceeds, because the abort binds writable paths and a wider rule would make the check unsatisfiable rather than protective

#### Scenario: Isolation limits are stated

- **WHEN** a drafted agent is granted a tool that reaches an external service, or a shell it could use to address a path outside the worktree
- **THEN** the standard directs that the payload and the run's permission mode be reviewed before the run, rather than treating the worktree as sufficient containment

### Requirement: Check fixtures are recorded; outcomes are not

Both checks SHALL have their **fixtures** recorded — the trigger check's positive and negative prompts with the routing expected of each, and the cold-run payload — so a later check re-runs against the same inputs rather than newly invented ones whose difference would be mistaken for a regression.

The outcome of a run and the date it ran SHALL NOT be recorded. A body edit invalidates the cold-run check, so a stored result is only ever valid against a body that may no longer exist, and it reads as assurance to anyone who does not reconstruct the edit history. The standard SHALL state this reasoning, so a later reader does not restore the results as an apparent improvement.

Fixtures SHALL be recorded in a companion file at `agents/<agent-name>.checks.yaml`. They MUST NOT be placed in the agent's frontmatter or body: the body is a system prompt carried on every dispatch, and frontmatter is parsed at every load, so either location puts a record no consumer wants onto the dispatch path. Shipping SHALL NOT be given as the reason — a companion file ships with the plugin exactly as frontmatter does; what separates them is that the companion file is never read into a context. Only `.md` files are read as agent definitions, so a `.yaml` companion is not exposed as an asset — the extension, not the depth at which the file sits, is what keeps it invisible to discovery.

An agent SHALL NOT be reported complete until its fixtures file records the prompts and the payload the checks were actually run against. The file is therefore written after the checks, not at the time the agent is written, and post-write validation does not check for it.

The recorded consumer of a fixture SHALL be understood as a later authoring session re-running the check after the library changed. No repository tooling reads it, because `toolkit-structure` bars this repository from carrying any.

A description edit SHALL invalidate the trigger check. A body edit SHALL invalidate the cold-run check. An edit to both SHALL invalidate both. Adding an asset to the library SHALL invalidate the checks of the assets it competes with, as `skill-authoring` requires.

#### Scenario: Body edit re-runs only the cold-run check

- **WHEN** an agent's system prompt is revised and its description is untouched
- **THEN** the cold-run check is re-run against the recorded payload and the trigger check is not

#### Scenario: A passing result is not stored

- **WHEN** a cold-run check passes
- **THEN** the payload it ran against is recorded and the outcome is not, because the next body edit would make a stored pass a claim about an agent that no longer exists

#### Scenario: Fixtures stay off the dispatch path

- **WHEN** an agent's fixtures are recorded
- **THEN** they are written to `agents/<agent-name>.checks.yaml`, and neither the agent's system prompt nor its frontmatter grows as a result

### Requirement: The agent authoring standard is a skill, referenced not duplicated

The agent authoring standard SHALL be authored as a skill at `skills/create-agent/SKILL.md`, not as an agent, because the workflow is an interactive sequence of human checkpoints that belongs in the caller's context — the outcome its own routing gate produces when applied to itself.

`AGENTS.md` SHALL point to it as the source of the agent authoring standard and MUST NOT restate its contents. The standard SHALL reference the published `plugin-dev` guidance for ground it does not need to restate rather than copying that guidance into the repository.

#### Scenario: Conventions point at the standard

- **WHEN** a reader consults `AGENTS.md` for how to write an agent's frontmatter
- **THEN** it points to `skills/create-agent/SKILL.md` instead of restating the contract

#### Scenario: Standard is subject to the skill standard

- **WHEN** `create-agent` is authored
- **THEN** it passes `create-skill`'s standard including a trigger check, and does not receive a cold-run check, because it is a skill and loads into an existing context
