## MODIFIED Requirements

### Requirement: One directory level for every asset type

Assets SHALL be placed at exactly one directory level, with no grouping directories:

- `skills/<skill-name>/SKILL.md`
- `agents/<agent-name>.md`
- `rules/<rule-name>.md`

A skill's `SKILL.md` MUST reside directly inside the skill's own directory, which MUST reside directly inside `skills/`. Agent and rule files MUST reside directly inside `agents/` and `rules/` respectively.

`rules/` SHALL hold reusable memory fragments intended to be `@import`ed into a consuming project's `CLAUDE.md` or `AGENTS.md`.

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
