## MODIFIED Requirements

### Requirement: One directory level for every asset type

Assets SHALL be placed at exactly one directory level, with no grouping directories:

- `skills/<skill-name>/SKILL.md`
- `agents/<agent-name>.md`
- `rules/<rule-name>.md`

A skill's `SKILL.md` MUST reside directly inside the skill's own directory, which MUST reside directly inside `skills/`. Agent and rule files MUST reside directly inside `agents/` and `rules/` respectively.

`rules/` SHALL hold reusable markdown fragments consumed by reference or by a shipped tool reading them. A fragment SHALL declare its kind in YAML frontmatter at the top of the file, and a fragment that is inlined into a consuming project SHALL additionally declare its version:

```yaml
---
kind: standing-constraint    # or: procedural-checklist
version: 1                   # inlined fragments only
---
```

The two kinds are:

- a **standing constraint**, intended to reach a consuming project's `CLAUDE.md` or `AGENTS.md` and remain in force there; or
- a **procedural checklist**, describing a one-time procedure, read on demand and NOT intended for a project's conventions file.

`version` is the fragment's own and increments when its text changes; it is unrelated to any package or plugin version. The form is fixed here rather than in a design document because this requirement outlives the change that introduces it, and a normative obligation deferred to an archived file cannot be checked afterwards.

The distinction is behavioral rather than cosmetic: inlining a one-time procedure into a project's conventions file would leave permanent instructions for work already finished, while leaving a standing constraint unimported would mean it never takes effect.

A placeholder document standing in for an unpopulated directory MUST NOT be discoverable as an asset. Since every `.md` file directly inside `agents/` is read as an agent definition — including one whose name begins with a dot — a placeholder there SHALL take a non-`.md` extension, which is the form discovery ignores.

#### Scenario: Placing a new skill

- **WHEN** a skill named `create-skill` is added
- **THEN** its definition resides at `skills/create-skill/SKILL.md`

#### Scenario: Skill placed too deep is undiscoverable

- **WHEN** a `SKILL.md` is placed with any directory between `skills/` and the skill's own directory
- **THEN** the layout is invalid, because discovery does not descend that far and the skill would fail to load with no error reported

#### Scenario: Agent invocation name carries no grouping

- **WHEN** an agent named `commit-message` is added
- **THEN** its definition resides at `agents/commit-message.md` and it is invoked as `ai-toolkit:commit-message`, so reclassifying it later does not rename it

#### Scenario: Names are unique per directory

- **WHEN** an asset is proposed with a name already used in the same directory
- **THEN** the name collision is resolved before the asset is added, since a flat directory cannot hold two assets of the same name

#### Scenario: Placeholders for unpopulated directories

- **WHEN** `skills/`, `agents/`, and `rules/` exist but contain no assets
- **THEN** each contains a short placeholder document stating what belongs in it, so the documented layout is true from the first commit

#### Scenario: A placeholder is not mistaken for an asset

- **WHEN** the plugin carrying an `agents/` placeholder is installed
- **THEN** no agent originating from that placeholder is exposed, and no parse failure is reported for it

#### Scenario: A non-`.md` file beside an agent is not an asset

- **WHEN** a file that is not a `.md` document sits directly inside `agents/` beside an agent definition
- **THEN** it is neither discovered as an agent nor reported as a parse failure, because the extension rather than the depth is what discovery selects on

#### Scenario: A procedural fragment is not inlined into a project

- **WHEN** a fragment describing a one-time procedure is added to `rules/`
- **THEN** it states that it is a procedural checklist, and nothing inlines it into a consuming project's conventions file

### Requirement: Rules are consumable by import path

`rules/` fragments SHALL be consumable by either of two paths, and documentation SHALL state both:

- **By `@` import** — a project's `CLAUDE.md` or `AGENTS.md` references the fragment's path in this repository. This requires no tooling and no copying.
- **By a shipped tool reading it** — an executable this repository ships locates the fragment relative to its own installed location and reads it. This path is available because installation copies the entire repository tree, not only the directories backing an agent-harness primitive; `rules/` is therefore present wherever the tool is.

Documentation SHALL NOT state that `rules/` is absent from a distributed copy. The accurate statement is that no harness primitive loads `rules/` automatically, while the files themselves are present and readable.

The import path SHALL be confirmed to resolve before it is documented. Documentation SHALL also state that the path is machine-local, so an import committed to a repository shared with other people resolves only on machines where this library is checked out at that path.

Where a tool inlines a fragment into a consuming project, it SHALL record which version of the fragment it inlined, so that a copy's provenance is readable without comparing file contents.

#### Scenario: Project imports a rule fragment

- **WHEN** a project wants to adopt a rule fragment from this repository
- **THEN** its `CLAUDE.md` imports the fragment by path, and the fragment remains a single source of truth rather than being duplicated into the project

#### Scenario: Import resolution is verified before it is documented

- **WHEN** the `@` import mechanism is written into `README.md` and `AGENTS.md`
- **THEN** the path form has already been observed to resolve, rather than being documented on the assumption that it does

#### Scenario: Import path is machine-local

- **WHEN** a project whose `CLAUDE.md` imports a fragment from this repository is cloned on a machine without this library
- **THEN** the import does not resolve, and the documentation has stated this limitation rather than presenting the import as portable

#### Scenario: A shipped tool reads a fragment from an installed copy

- **WHEN** an executable this repository ships runs from an installed copy and needs a rule fragment
- **THEN** it locates the fragment relative to its own location and reads it, without an `@` import and without any harness having loaded `rules/`

#### Scenario: An inlined fragment records its version

- **WHEN** a tool writes a fragment's contents into a consuming project
- **THEN** the version inlined is recorded alongside the content, so the project's adopted version is readable later

### Requirement: Repository is browsable without an index

The repository MUST NOT maintain an asset index. `README.md` SHALL instead document how to list the available assets from the repository itself, using the names and `description` fields the assets already carry.

Asset loading MUST NOT depend on any catalogue file.

The repository SHALL carry no dependency to install and no build step: the library SHALL remain usable from a clone with nothing installed, and no dependency manifest SHALL exist.

Executable code SHALL be admitted in exactly two forms, both of which ship to consumers rather than maintaining this repository:

- **Shipped tooling** at `scripts/`, where the operation is genuinely deterministic and is meant to be run by a consumer, a shell, or an agent of any harness. It is placed at the repository root rather than inside an asset because a path under `skills/` is unreachable by a harness that does not implement skills.
- **Asset-internal code** under an individual skill's own `scripts/` directory, where the code is a resource that one skill carries and no other consumer invokes.

A dependency-free test harness for shipped tooling SHALL be admitted at `tests/`, and SHALL introduce no dependency manifest and no build step. A test that exercises shipped tooling MAY require the external commands that tooling drives; that requirement belongs to running the tests, not to using the library.

What remains forbidden is machinery this repository runs on *itself*: a build step, a packaging step, a generated catalogue, or a script whose purpose is maintaining this repository rather than shipping to a consumer. Tooling used only for working on this repository belongs in `.claude/`.

#### Scenario: Adding an asset requires no catalogue update

- **WHEN** a new asset is added
- **THEN** no index or listing file needs editing, and the asset is complete once its own file is written

#### Scenario: README documents how to browse

- **WHEN** a reader wants to know what the library contains
- **THEN** `README.md` gives them the means to list it from the current contents of the repository

#### Scenario: No build step

- **WHEN** the repository is cloned and an asset is used
- **THEN** no build step runs, no dependency manifest exists, and nothing must be installed for the library's assets to be usable

#### Scenario: Shipped tooling is admitted, repository machinery is not

- **WHEN** the repository is inspected for executable code
- **THEN** what exists ships to consumers — tooling at `scripts/`, code inside an individual skill, and a harness at `tests/` covering them — and nothing exists whose purpose is to build, package, or catalogue this repository

#### Scenario: A skill bundles a script

- **WHEN** a skill requires a step to run deterministically and no consumer outside that skill invokes it
- **THEN** the code lives under that skill's own `scripts/` directory, while a deterministic operation meant to be run directly by a consumer or by another harness belongs at `scripts/` instead

#### Scenario: Running the tests may need more than using the library

- **WHEN** the harness exercises shipped tooling that drives external commands
- **THEN** those commands are required to run the tests and are not required to use the library, and no dependency manifest is introduced by either

### Requirement: Documentation separation of concerns

Repo-level conventions SHALL live in `AGENTS.md`, and `CLAUDE.md` SHALL consist of a single `@AGENTS.md` import so the conventions have exactly one source of truth.

`AGENTS.md` SHALL state the layout, the constraint that makes each asset type flat, the tags convention, and the naming rules. It MUST NOT carry authoring standards for producing an asset; those belong with the asset type's authoring skill, which `AGENTS.md` MAY reference by path.

`AGENTS.md` SHALL distinguish three categories:

- **Library assets** — `skills/`, `agents/`, and `rules/`, which ship in the plugin and are the library's substance.
- **Shipped tooling** — `scripts/`, holding executables that ship with the library and are runnable directly, without any agent harness. These are not assets: nothing discovers them, they carry no frontmatter, and they are reached by path or by `--help` rather than by description.
- **Repository tooling** — `.claude/`, holding configuration for working in this repository, which is not part of the library.

`AGENTS.md` SHALL state what belongs in `scripts/`: the deterministic half of a workflow, where an operation has exactly one correct outcome and therefore should not be re-derived by a model. A capability requiring judgment belongs in a skill or agent, not in `scripts/`.

Because `scripts/` conventionally names a repository's internal helpers, `AGENTS.md` SHALL state explicitly that its contents ship with the library and are intended to be run by its consumers. Tooling used only for working *on* this repository belongs in `.claude/`, not here.

#### Scenario: Claude Code picks up conventions

- **WHEN** Claude Code loads project memory for this repository
- **THEN** `CLAUDE.md` imports `AGENTS.md`, and the conventions take effect without a second copy existing

#### Scenario: Layout constraint is explained, not just stated

- **WHEN** a reader asks why no asset type uses grouping directories
- **THEN** `AGENTS.md` gives the discovery and naming constraints as the reason, so the rule is not mistaken for arbitrary preference

#### Scenario: Library assets are distinguished from repository tooling

- **WHEN** an agent working in this repository needs to place a new library skill, and `.claude/skills/` already exists holding this repository's own tooling
- **THEN** `AGENTS.md` makes `skills/` the destination for library assets, so an asset meant to ship in the plugin is not written into `.claude/` where it would work locally and never ship

#### Scenario: Authoring guidance is not duplicated into conventions

- **WHEN** a reader looks for the rules on writing a skill's frontmatter well
- **THEN** `AGENTS.md` does not restate them, and points to the authoring standard instead

#### Scenario: A deterministic operation is placed in shipped tooling

- **WHEN** a capability is added whose steps have exactly one correct outcome and require no judgment
- **THEN** `AGENTS.md` makes `scripts/` its destination, and any skill wrapping it calls it rather than restating what it does

#### Scenario: Shipped tooling is distinguished from repository helpers

- **WHEN** a reader familiar with the common use of `scripts/` assumes its contents are internal development helpers
- **THEN** `AGENTS.md` states that these executables ship with the library and are meant to be run by consumers, and names `.claude/` as the home for tooling used only to work on this repository

#### Scenario: Shipped tooling is not mistaken for an asset

- **WHEN** a reader enumerates the library's assets
- **THEN** `scripts/` is excluded, because nothing discovers its contents by description and they carry no asset frontmatter
