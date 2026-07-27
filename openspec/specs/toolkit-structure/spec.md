# toolkit-structure Specification

## Purpose

Defines the repository's shape as an installable Claude Code plugin: how it is packaged, how assets (skills, agents, rules) are laid out and discovered, how they are classified, how the repository is browsed and documented, and what state is and is not committed.

## Requirements

### Requirement: Repository is an installable plugin

The repository SHALL be a Claude Code plugin. It SHALL contain `.claude-plugin/plugin.json` declaring at least `name`, and SHALL contain `.claude-plugin/marketplace.json` describing a single-plugin marketplace so the repository can be added by local path.

Component directories SHALL reside at the plugin root — the directory containing `.claude-plugin/` — and MUST NOT be placed inside `.claude-plugin/`. The plugin root SHALL be the repository root if a marketplace entry sourced at `"./"` is accepted; otherwise the plugin root is the subdirectory the marketplace entry points at, and the shape actually used SHALL be recorded in `design.md`.

#### Scenario: Repository is installed as a plugin

- **WHEN** a user adds this repository's local path as a marketplace and installs the plugin
- **THEN** the plugin's skills and agents become available in the consuming project without any file being copied into that project

#### Scenario: Manifest placement

- **WHEN** the repository is inspected
- **THEN** `plugin.json` and `marketplace.json` are inside `.claude-plugin/`, while `skills/`, `agents/`, and `rules/` sit beside `.claude-plugin/` at the plugin root rather than inside it

#### Scenario: Development without installing

- **WHEN** an asset is being edited and needs testing before commit
- **THEN** the repository can be loaded directly with `claude --plugin-dir <repo path>`, requiring no install step

#### Scenario: Packaging is verified, not assumed

- **WHEN** the manifests are written
- **THEN** the plugin is installed and a component is confirmed to load from it before any asset is authored against the layout

#### Scenario: Verification observes a component, not just the plugin

- **WHEN** the packaging is checked and the library ships no assets of its own
- **THEN** a throwaway asset is added, observed to load as a component of this plugin, and removed — because a structurally wrong manifest installs without error and simply carries nothing, which an "the plugin appears" check cannot distinguish from success

### Requirement: One directory level for every asset type

Assets SHALL be placed at exactly one directory level, with no grouping directories:

- `skills/<skill-name>/SKILL.md`
- `agents/<agent-name>.md`
- `rules/<rule-name>.md`

A skill's `SKILL.md` MUST reside directly inside the skill's own directory, which MUST reside directly inside `skills/`. Agent and rule files MUST reside directly inside `agents/` and `rules/` respectively.

`rules/` SHALL hold reusable memory fragments intended to be `@import`ed into a consuming project's `CLAUDE.md` or `AGENTS.md`.

A placeholder document standing in for an unpopulated directory MUST NOT be discoverable as an asset. Since every file directly inside `agents/` is read as an agent definition, a placeholder there SHALL take a form discovery ignores.

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

### Requirement: Skills are discovered without manifest enumeration

Skills SHALL be discoverable by auto-discovery alone. The marketplace entry MUST NOT rely on an explicit `skills` path array to make skills loadable, so that adding a skill requires no manifest edit and omitting one cannot silently remove it.

#### Scenario: New skill needs no manifest change

- **WHEN** a new skill directory containing `SKILL.md` is added under `skills/`
- **THEN** it is discovered in the next session with no edit to `plugin.json` or `marketplace.json`

#### Scenario: Enumeration is not used

- **WHEN** the marketplace entry for this plugin is inspected
- **THEN** it contains no `skills` array enumerating individual skill paths

### Requirement: Tags are the only asset classification

Every asset MAY declare `metadata.tags` as a list of free-form, lowercase kebab-case labels. Tags are multi-valued, carry no structural meaning, and MUST NOT affect an asset's location or name.

No other classification field SHALL be required of an asset. In particular, assets MUST NOT be required to declare a single-valued `category`.

Before a new tag is introduced, the vocabulary already in use SHALL be checked, so that synonyms do not accumulate.

#### Scenario: Asset declares tags

- **WHEN** an asset concerns skill authoring and human review
- **THEN** those concerns appear as `metadata.tags: [authoring, hitl]`

#### Scenario: Multiple domains need no primary choice

- **WHEN** an asset legitimately belongs to more than one domain
- **THEN** every applicable tag is listed, and no single-valued classification forces one of them to be chosen as primary

#### Scenario: Existing vocabulary is reused

- **WHEN** a tag is proposed for a concept already covered by an existing tag under a different name
- **THEN** the existing tag is used instead of coining a synonym

### Requirement: Repository is browsable without an index

The repository MUST NOT maintain an asset index. `README.md` SHALL instead document how to list the available assets from the repository itself, using the names and `description` fields the assets already carry.

Asset loading MUST NOT depend on any catalogue file.

#### Scenario: Adding an asset requires no catalogue update

- **WHEN** a new asset is added
- **THEN** no index or listing file needs editing, and the asset is complete once its own file is written

#### Scenario: README documents how to browse

- **WHEN** a reader wants to know what the library contains
- **THEN** `README.md` gives them the means to list it from the current contents of the repository

#### Scenario: No build step

- **WHEN** the repository is inspected for tooling
- **THEN** no script or build step exists, and the repository contains no executable code

### Requirement: Rules are consumable by import path

Documentation SHALL state that `rules/` fragments are consumed by referencing them from a project's `CLAUDE.md` or `AGENTS.md` with an `@` import naming the fragment's path in this repository, and that this requires no tooling or copying.

The import path SHALL be confirmed to resolve before it is documented. Documentation SHALL also state that the path is machine-local, so an import committed to a repository shared with other people resolves only on machines where this library is checked out at that path.

#### Scenario: Project imports a rule fragment

- **WHEN** a project wants to adopt a rule fragment from this repository
- **THEN** its `CLAUDE.md` imports the fragment by path, and the fragment remains a single source of truth rather than being duplicated into the project

#### Scenario: Import resolution is verified before it is documented

- **WHEN** the `@` import mechanism is written into `README.md` and `AGENTS.md`
- **THEN** the path form has already been observed to resolve, rather than being documented on the assumption that it does

#### Scenario: Import path is machine-local

- **WHEN** a project whose `CLAUDE.md` imports a fragment from this repository is cloned on a machine without this library
- **THEN** the import does not resolve, and the documentation has stated this limitation rather than presenting the import as portable

### Requirement: Documentation separation of concerns

Repo-level conventions SHALL live in `AGENTS.md`, and `CLAUDE.md` SHALL consist of a single `@AGENTS.md` import so the conventions have exactly one source of truth.

`AGENTS.md` SHALL state the layout, the constraint that makes each asset type flat, the tags convention, and the naming rules. It MUST NOT carry authoring standards for producing an asset; those belong with the asset type's authoring skill, which `AGENTS.md` MAY reference by path.

`AGENTS.md` SHALL distinguish the library from the repository's own tooling: `skills/`, `agents/`, and `rules/` hold library assets that ship in the plugin, while `.claude/` holds configuration for working in this repository and is not part of the library.

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

### Requirement: Machine-local state is not committed

The repository SHALL ignore operating-system cruft, editor directories, and machine-local Claude Code state including `.claude/settings.local.json`. Shared configuration under `.claude/` that defines repo behavior SHALL remain tracked.

#### Scenario: Local settings stay out of version control

- **WHEN** Claude Code writes `.claude/settings.local.json` during a session
- **THEN** the file is ignored by Git and does not appear in `git status`

#### Scenario: Shared configuration remains tracked

- **WHEN** the repository defines skills or commands under `.claude/`
- **THEN** those files remain tracked so the repo's own behavior is reproducible from a clone
</content>
</invoke>
