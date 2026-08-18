# project-bootstrap Specification

## Purpose

Defines what initializing a project into this development workflow must do and where it stops: a standalone tool that performs only deterministic setup, resolves the toolkit it belongs to without depending on any single agent harness, reports an outcome a machine can act on, refuses to overwrite what a project already owns, and hands the next step to a human rather than taking it.

Requirements below say "repository" and "specification tooling" where the behavior does not depend on which tool provides them; the concrete instances this change implements against are **Git** (`git init`) and **OpenSpec** (`openspec init`). The generic phrasing marks which requirements would survive substituting a different tool, not a refusal to name the ones in use.

## Requirements

### Requirement: Bootstrap is a standalone executable, not an agent's implementation detail

The deterministic half of initialization SHALL be a shell script at `scripts/project-init`, runnable by a human, a shell, a CI job, or any agent in any harness, without requiring a skill, plugin, or model to be present.

The script SHALL document its modes, arguments, flags, outcomes, and exit codes in its own `--help` output. `--help` is the tool's portable interface: a `SKILL.md` is readable only by a harness that implements skills, whereas `--help` is readable by anything that can run a shell.

The tool SHALL operate on the current working directory, and SHALL accept an optional path argument naming a different target. It SHALL state the target directory in its report before making any change, so that a run against the wrong tree is visible rather than discovered afterwards. The never-overwrite guarantee protects a project's files; it does not protect against initializing the right files in the wrong place, which only the stated target can.

A target that does not exist, is not a directory, or is not writable SHALL be a precondition failure producing `BLOCKED`, not a directory the tool creates.

The script SHALL document its arguments alongside its flags in `--help`. An argument that decides where the tool writes, omitted from the interface a wrapper is written against, would defeat the purpose of that interface being self-sufficient.

A skill MAY wrap the tool, but SHALL NOT be the only way to reach it, and SHALL NOT reimplement what it does.

#### Scenario: A non-skill-aware tool can use it

- **WHEN** an agent or developer with no skills primitive works in a repository and needs to initialize it
- **THEN** `scripts/project-init --help` states what the tool does and how to run it, and running it requires nothing that only a skills-aware harness provides

#### Scenario: An explicit target is acted on and stated

- **WHEN** the tool is given a path argument naming a directory other than the current one
- **THEN** it initializes that directory, and its report states which directory it acted on before any change was made

#### Scenario: An unusable target blocks

- **WHEN** the target path does not exist, is not a directory, or is not writable
- **THEN** the tool reports `BLOCKED`, creates nothing, and exits non-zero

#### Scenario: The entry point is not buried inside a skill

- **WHEN** the library's layout is inspected
- **THEN** the executable resides at `scripts/project-init` rather than under `skills/`, because a path under `skills/` is unreachable by a harness that never loads a `SKILL.md` and reads as inapplicable to one that does not implement skills

### Requirement: A caller locating the tool resolves the toolkit root by an ordered chain

This requirement governs a **caller** — a skill, agent, or wrapper that must find the script before running it. A person who types the script's path has already resolved it and is subject to none of this.

A caller SHALL locate the toolkit by trying, in order:

1. `$AI_TOOLKIT_ROOT` — explicit and portable across any harness
2. `$CLAUDE_PLUGIN_ROOT` — zero-setup when running as an installed Claude Code plugin
3. the machine-local default path at which this repository is conventionally checked out

No single entry SHALL be required. Claude Code appears as one option, never as a precondition.

Where no entry resolves, the caller SHALL report itself blocked, invoke nothing, and stop.

The caller SHALL invoke the script through its interpreter (`bash <root>/scripts/project-init`) rather than as an executable path, so that the executable permission bit surviving distribution is not a precondition for running it.

#### Scenario: No Claude Code environment is present

- **WHEN** a caller runs from a plain shell with `$CLAUDE_PLUGIN_ROOT` unset and `$AI_TOOLKIT_ROOT` set
- **THEN** the toolkit root resolves from `$AI_TOOLKIT_ROOT` and the script is invoked from there

#### Scenario: A caller cannot resolve any root

- **WHEN** no entry in the chain yields a toolkit root
- **THEN** the caller reports itself blocked naming what it looked for, invokes nothing, and no filesystem change is made

#### Scenario: The executable bit is not relied upon

- **WHEN** distribution strips the executable permission from the script
- **THEN** the tool still runs, because it is invoked through `bash` rather than executed directly

### Requirement: The running script locates its own resources

Once running, the script SHALL derive its own directory from its invocation path and SHALL locate the rule fragments it reads relative to that. It SHALL NOT consult `$AI_TOOLKIT_ROOT`, `$CLAUDE_PLUGIN_ROOT`, or any other environment variable to find them.

Resolution therefore happens exactly once, in the caller. A script that re-resolved could read fragments from a different copy than the one it was invoked from, making the version it stamps into a project's marker untrue of the text it inlined.

#### Scenario: Fragments come from the copy the script belongs to

- **WHEN** the script runs from an installed copy while an environment variable names a different toolkit root
- **THEN** it reads the fragments belonging to the copy it was invoked from, and the version it stamps describes the text it actually inlined

#### Scenario: Explicit root reaches the working tree through the caller

- **WHEN** `$AI_TOOLKIT_ROOT` names a working tree while an older version is also installed as a plugin
- **THEN** the caller resolves to the working tree and invokes the script there, so a toolkit developer exercises the fragments they are editing rather than a pinned installed copy

### Requirement: Every run ends in one of three outcomes, and the exit code agrees

Each run SHALL terminate in exactly one of:

- `SUCCESS` — every applicable concern was completed or was already satisfied. Exit code SHALL be zero.
- `BLOCKED` — a precondition was unmet and no filesystem change was attempted. Exit code SHALL be non-zero.
- `ERROR` — a step was attempted and failed. Exit code SHALL be non-zero and distinct from the code used for `BLOCKED`.

The outcome SHALL be stated in the report, and the exit code SHALL never contradict it. A run that reports `BLOCKED` and exits zero is a defect, because shell and CI callers act on the exit code rather than the text.

Unmet preconditions that SHALL produce `BLOCKED` include: a required rule fragment absent from the script's own copy, and a required external command (`git`, or the specification tooling the script drives) unavailable.

**The rule fragment is read unconditionally, before anything else, and its absence always blocks.** It is not scoped to whether the conventions-file concern is outstanding, because the report requirement below (*Workflow rules reach a project as a versioned managed block*) obliges the tool to state its own carried version even when a managed block already exists and nothing will be written — a case where the concern is satisfied but the fragment must still be read to produce that report. Treating the fragment as scoped like a command precondition would leave that report field unproducible in exactly the case it exists to cover.

**External-command preconditions SHALL be computed from the concerns that are actually outstanding, and SHALL be validated in full before any write.** Determining which concerns are outstanding is a set of filesystem reads, not attempts, so it precedes validation without violating the no-change guarantee.

Scoping commands this way is required, not merely economical: validating every command precondition unconditionally would make the tool report `BLOCKED` when a command is missing for a concern that is already satisfied — refusing to run because some concerns are complete, which a separate requirement forbids. Validating lazily instead, at each concern's point of use, would report `BLOCKED` after earlier concerns had already written, making the outcome's own definition false. Only the scoped-then-eager order satisfies both, and it is why the fragment — read once, up front, for reasons unrelated to any single concern's completion — is carved out of it rather than folded in.

Root resolution is not among the preconditions. A script that is running was found, so an unresolvable root is a condition its caller reports before invoking anything.

#### Scenario: A machine consumer can branch on the result

- **WHEN** a CI job runs the tool and checks its exit status
- **THEN** a zero status means initialization succeeded, and any non-zero status means it did not, without the caller parsing report text

#### Scenario: A command missing for an already-satisfied concern does not block

- **WHEN** the tool runs where specification tooling is already present but the command that would initialize it is unavailable
- **THEN** that command is not among the preconditions validated, the run proceeds with the remaining concerns, and the satisfied concern is reported as already present

#### Scenario: The fragment is read even when nothing will be written

- **WHEN** the tool runs where a managed block is already present and the fragment is absent from the script's own copy
- **THEN** the tool reports `BLOCKED`, because the version it would need to report as "the version the tool carries" cannot be produced without reading the fragment, regardless of the conventions-file concern being satisfied

#### Scenario: Missing fragment blocks rather than degrades

- **WHEN** the toolkit root resolves but the workflow rule fragment is absent from it
- **THEN** the tool reports `BLOCKED` and exits non-zero, rather than writing a conventions file without the workflow rules

### Requirement: Neither the caller nor the script substitutes an improvised equivalent

A caller that cannot locate the script SHALL report itself blocked and stop. A script that cannot locate its own resources SHALL report `BLOCKED` and stop, and its caller SHALL relay that outcome rather than reinterpreting it. Neither SHALL fall back to performing the underlying operations itself — running `git init` and `openspec init` directly, or writing the workflow rules from memory.

An improvised fallback produces a project initialized differently from every other one (no managed block, no marker, no version stamp) while reporting success, which is the silent divergence this workflow exists to prevent.

#### Scenario: A wrapper cannot find the tool

- **WHEN** a skill or agent wrapping the tool cannot resolve a toolkit root
- **THEN** it reports itself blocked and stops, and does not initialize the project by running the underlying commands itself

### Requirement: Bootstrap distinguishes a new project from an adoption

The repository concern SHALL be evaluated as "the target directory is itself the root of a repository", not as "the target lies somewhere inside one". A fresh subdirectory of an existing repository is a new project, and treating the enclosing repository as satisfying the concern would report it initialized and route it to the adoption ending.

The tool SHALL determine its mode from the target directory rather than from a flag the caller must remember, and SHALL split on a single observable — whether the repository rooted at the target has at least one commit:

- **New project** — no commit exists, whether or not a repository has been initialized. The run ends by naming foundation discovery as the next step.
- **Adoption** — at least one commit exists. The run ends at the managed workflow block.

A single observable is required because plausible states sit between the intuitive descriptions: a directory where `git init` has been run but nothing committed is neither "no repository" nor "a repository with existing code", and a rule phrased on those terms would leave it unclassified.

Adoption SHALL NOT create a foundation change. An existing repository's architecture, stack, and testing approach are already embodied in its code, so a discovery phase for them would re-derive decisions that are no longer open. The adoption report SHALL nonetheless name foundation discovery as available, so recording those decisions retroactively remains a discoverable option rather than an undocumented one.

#### Scenario: Empty directory takes the new-project path

- **WHEN** the tool runs in a directory where no commit exists, whether or not a repository has been initialized
- **THEN** it initializes every unsatisfied concern and its report names foundation discovery as the next step

#### Scenario: Existing repository takes the adoption path

- **WHEN** the tool runs where the target is the root of a repository with at least one commit
- **THEN** it completes only the concerns that are unsatisfied, does not create a foundation change, and its report states that foundation discovery is available if the project's decisions should be recorded retroactively

#### Scenario: A subdirectory of an existing repository is not treated as already initialized

- **WHEN** the tool runs in a directory that has no repository of its own but sits inside one that does
- **THEN** the repository concern is reported unsatisfied, a repository is initialized rooted at the target rather than reusing the enclosing one, and mode is derived from the new repository's own commit history rather than the enclosing repository's

### Requirement: Each concern is checked independently and is safe to repeat

The tool SHALL evaluate each concern on its own — repository initialized, specification tooling initialized, ignore file present, conventions file present, managed block present — completing what is absent and skipping what is satisfied.

The tool SHALL NOT refuse to run because some concerns are already satisfied. Repeated execution SHALL be safe: a second run against an unchanged directory SHALL make no destructive change and SHALL alter no file the first run already brought to its target state.

#### Scenario: Repeated execution is not destructive

- **WHEN** the tool is run twice in succession against the same directory
- **THEN** the second run completes reporting every concern as already satisfied, and no file written by the first run is modified, truncated, or duplicated

#### Scenario: A partially initialized directory is completed, not refused

- **WHEN** the tool runs where a repository exists but specification tooling does not
- **THEN** it skips repository initialization, completes specification tooling, and reports each concern's outcome separately

#### Scenario: Existing specification tooling is skipped, not reinitialized

- **WHEN** the tool runs where both a repository and specification tooling are already present
- **THEN** both are reported as already satisfied, neither is reinitialized, and no file either of them owns is modified

### Requirement: A partial run is recoverable by re-running

Where a run fails partway, the tool SHALL NOT attempt to roll back completed steps. It SHALL report which concerns were completed before the failure and which were not.

Re-running SHALL be the documented recovery path, which is sound only because each concern is checked independently: a second run completes what the first did not reach.

#### Scenario: Failure midway leaves a reported, recoverable state

- **WHEN** repository initialization succeeds and specification tooling initialization then fails
- **THEN** the tool reports `ERROR`, states that the repository was initialized and specification tooling was not, exits non-zero, and leaves the completed step in place

### Requirement: Files the project already owns are never overwritten

The tool SHALL create what is absent and report what is present. It SHALL NOT itself modify, merge into, extend, or truncate a file it did not create, with exactly one exception: appending the managed block to the conventions file.

A script cannot distinguish a deliberate project decision from an oversight, so editing a file it did not write risks discarding an intentional choice with no way to detect it.

**The guarantee is bounded to the tool's own writes.** The tool delegates specification-tooling initialization to an external command, whose writes it does not control and SHALL NOT claim to prevent. What that command creates or modifies SHALL be established before implementation and recorded, and the report SHALL attribute those changes to it rather than presenting the run as having touched only the files the tool wrote itself.

An unbounded guarantee would be false on the adoption path — the path this tool exists to serve — precisely where a project has files worth protecting.

#### Scenario: A delegated command's writes are attributed, not concealed

- **WHEN** the tool initializes specification tooling in a project that already has files, and that command writes files of its own
- **THEN** the report attributes those changes to the delegated command, and the tool's own never-overwrite guarantee is stated as covering the files it writes itself

#### Scenario: An existing ignore file is preserved exactly

- **WHEN** the target directory already contains an ignore file
- **THEN** its contents are left byte-for-byte unchanged, its presence is reported, and no entry is appended or merged

#### Scenario: An existing conventions file receives only the managed block

- **WHEN** the target directory already contains a conventions file with project content
- **THEN** the managed block is added and every line outside the block is left unchanged

### Requirement: The minimal ignore file is enumerated, not described

Where no ignore file exists, the tool SHALL create one containing exactly these entries and no others:

```
# Environment
.env
.env.*
!.env.example

# OS
.DS_Store
Thumbs.db

# Editors
.idea/
.vscode/
```

The entries are enumerated here, in the specification, rather than characterized as "minimal" or "generic". An adjective invites growth that each addition can justify individually; an enumeration does not. They are enumerated *here* rather than in a design document because a design document is archived with its change, while this requirement outlives it — a durable constraint that pointed at a transient file could not be checked later.

The tool SHALL NOT include stack-specific entries. It cannot know the project's language, and a wrong entry asserts something false about the project. Stack-specific exclusions belong to foundation discovery as a deliverable.

#### Scenario: Created ignore file carries no stack assumption

- **WHEN** an ignore file is created in a directory whose language is not yet decided
- **THEN** it contains only the three enumerated categories, and no entry naming a language's dependency directory, build output, or cache

### Requirement: Workflow rules reach a project as a versioned managed block

The project's conventions file SHALL be `AGENTS.md` at the project root. It is named here rather than left to the implementer because it is the file every targeted harness reads, and because a project may hold more than one candidate.

The tool SHALL apply the following, in order:

- `AGENTS.md` exists — the block is appended to it.
- `AGENTS.md` is absent and `CLAUDE.md` exists — `AGENTS.md` is created with the block, and `CLAUDE.md` is left untouched. The tool SHALL NOT write into `CLAUDE.md`, whose contents are the project's own and may be a single import of another file.
- Neither exists — `AGENTS.md` is created with the block.

**Writing the file is not the same as the rules taking effect, and the tool SHALL NOT conflate them.** Whether a harness loads `AGENTS.md` without an explicit import SHALL be established before implementation and recorded. Where a harness reaches its conventions only through a different file — as this repository's own arrangement happens to be, its `CLAUDE.md` consisting of a single `@AGENTS.md` import — the report SHALL state the one line the user must add for the rules to load, and SHALL still write nothing into that file.

This condition is a property of the harness, not of which branch above fired: it holds whenever `CLAUDE.md` does not already contain the import, whether `CLAUDE.md` is absent entirely, present without the import, or present importing something else. The report obligation therefore applies identically whether `AGENTS.md` was appended to, created fresh alongside an existing `CLAUDE.md`, or created where neither file existed — it is not confined to the case where `CLAUDE.md` already exists.

Reporting `SUCCESS` and stamping a version while the rules are inert would be the silent divergence this workflow exists to prevent, and it would be worse than an obvious failure: the marker's whole purpose is to answer "is this workflow adopted here", and it would answer yes.

The tool SHALL write the workflow rule fragment into that file between delimiters that name the fragment and the version inlined, and SHALL include a notice inside the block stating that its contents are generated and that project-specific rules belong outside it.

Where a managed block for the same fragment is already present, the concern is satisfied and the block SHALL NOT be rewritten. The report SHALL then state both the version recorded in the existing block and the version the tool carries, and SHALL state that reconciling a difference is out of scope for this tool. Reporting a version as "inlined" when nothing was inlined would make the report untrue in the one case where version skew is visible.

Content between the delimiters SHALL be defined as generated and replaceable. Content outside them SHALL belong to the project and SHALL never be modified by this tool or any future update to it.

The delimiters SHALL be greppable and SHALL carry the version, so that a later update can locate and replace the block without parsing hand-written text, and so that a project's adopted workflow version is readable without comparing file contents.

#### Scenario: A project's adopted version is readable

- **WHEN** a reader needs to know whether a project uses this workflow and at which version
- **THEN** the delimiters in the conventions file state both, without any separate state file being consulted

#### Scenario: Project content below the block survives

- **WHEN** a project has added its own conventions beneath the managed block and the tool runs again
- **THEN** those conventions are unchanged

#### Scenario: A project with only a CLAUDE.md

- **WHEN** the tool runs where `CLAUDE.md` exists and `AGENTS.md` does not
- **THEN** `AGENTS.md` is created carrying the managed block, and `CLAUDE.md` is not read into, written to, or modified

#### Scenario: Rules written but not yet loadable are reported as such

- **WHEN** the tool writes the managed block into `AGENTS.md` for a harness that reaches its conventions only through another file
- **THEN** the report states the import line the user must add for the rules to take effect, and does not present the rules as being in force merely because the file was written

#### Scenario: An existing block at a different version is reported, not rewritten

- **WHEN** the tool runs where a managed block for the same fragment already exists at an earlier version
- **THEN** the block is left unchanged, and the report states both versions and that reconciling them is out of scope

### Requirement: The workflow rules name a role before naming a tool

The workflow rule fragment SHALL state each obligation as a role to be filled, and MAY name a specific agent or command beneath it as one harness's binding for that role.

A rule that names only a tool becomes a dangling reference in any project where that tool is absent, which makes a single harness a hard dependency of the methodology rather than its first adapter.

#### Scenario: Rules remain meaningful without the toolkit installed

- **WHEN** a project's conventions file carries the managed block but the library is not installed in that project
- **THEN** each rule still states what must happen and why, and the named agents read as one harness's bindings rather than as required references

### Requirement: Specification tooling targets are not hardcoded to one harness

Where the tool initializes specification tooling that supports multiple agent targets, the target SHALL be caller-controlled through a flag with a documented default, and SHALL NOT be fixed to a single harness in the script.

Hardcoding one harness would make every initialized project shaped for that harness regardless of what its developer uses, contradicting the portability the tool otherwise establishes.

#### Scenario: A non-default harness is selected

- **WHEN** a developer initializes a project for a harness other than the default
- **THEN** the flag selects it, and the generated specification tooling targets that harness

### Requirement: The report enumerates outcomes and names the next step without taking it

The report SHALL state, at minimum: the target directory; each concern with its outcome; the terminal outcome; and the next step. It SHALL additionally carry the obligations other requirements place on it — the workflow version where a block was inlined, both versions where a block was already present, any import line still needed for the rules to load, and attribution of files written by a delegated command.

This enumeration is a minimum rather than a closed list, so that an obligation stated in the requirement that creates it is not silently dropped by a requirement that enumerates elsewhere.

The tool SHALL NOT take the next step. Where a wrapper offers to create an initial commit, it SHALL wait for confirmation rather than committing, and SHALL NOT begin foundation discovery automatically — starting an open-ended discovery conversation decides that this is the right moment for it, which belongs to the person running the tool.

"Successful initialization" SHALL be defined as this enumerated report rather than as a claim, so that a reader can verify it.

#### Scenario: Completion is verifiable rather than asserted

- **WHEN** a run finishes
- **THEN** the report names each concern and whether it was created, skipped as already present, or failed, together with the workflow version inlined

#### Scenario: Nothing is committed without confirmation

- **WHEN** a wrapper offers to create an initial commit after a successful run
- **THEN** no commit exists until the user confirms

#### Scenario: Discovery is named, not started

- **WHEN** a new-project run completes successfully
- **THEN** the report names foundation discovery as the next step and the run ends, rather than continuing into it

### Requirement: The tool is portable across the shells its users run

The script SHALL declare `bash` via `#!/usr/bin/env bash` and SHALL NOT use constructs unavailable in bash 3.2, so that behavior is identical on macOS, Linux, and Git Bash on Windows.

The script SHALL pass ShellCheck cleanly, which the library's existing shell standard already establishes as necessary but not sufficient for completion.

#### Scenario: Behavior is identical on a system shipping an older bash

- **WHEN** the tool runs on a system whose default bash is 3.2
- **THEN** it behaves identically to a run on a newer bash, because no construct introduced after 3.2 is used
