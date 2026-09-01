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

`version` is the fragment's own and is unrelated to any package or plugin version. The form is fixed here rather than in a design document because this requirement outlives the change that introduces it, and a normative obligation deferred to an archived file cannot be checked afterwards. When it increments is NOT fixed here: that obligation belongs to `project-bootstrap`'s requirement "The fragment's version increments when its body changes", which owns it because the increment exists to make a project's inlined copy distinguishable from a current one, and only the capability that inlines the fragment can say which part of it a project actually carries. The deferral covers every fragment this repository inlines, not only the workflow rule fragment that occasions it: an inlined fragment's increment condition is the body-scoped one `project-bootstrap` states, whatever the fragment. This clause states where the rule lives so that an author checking a fragment edit reaches one answer rather than two.

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

#### Scenario: The increment rule has exactly one owner

- **WHEN** an author editing a rule fragment needs to know whether to increment its `version`
- **THEN** this requirement names `project-bootstrap` as the owner of that obligation and states no competing condition of its own, so the two capabilities cannot give divergent answers for the same edit
