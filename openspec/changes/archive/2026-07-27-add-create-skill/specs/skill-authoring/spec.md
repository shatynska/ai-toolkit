## ADDED Requirements

### Requirement: Skill frontmatter contract

Every `SKILL.md` SHALL begin with YAML frontmatter declaring `name` and `description`, which are the only required fields.

Fields defined by the Agent Skills schema MAY be declared at the top level when needed. Fields not defined by that schema SHALL be nested under `metadata` rather than invented as new top-level keys.

Because the schema is versioned outside this repository, the authoring standard SHALL record the schema-defined field list as a dated snapshot naming where it was read, rather than asserting a closed enumeration. As of 2026-07-27, verified against the validation script shipped with the official `skill-creator` plugin, that list is `allowed-tools`, `license`, and `compatibility`; `version` is not schema-defined despite appearing in some hand-written examples.

`allowed-tools` SHALL be omitted unless the skill is a thin wrapper around a single command, in which case it SHALL be scoped to that command.

#### Scenario: Minimal valid frontmatter

- **WHEN** a skill is generated
- **THEN** its frontmatter declares at least `name` and `description`

#### Scenario: Schema-defined field at top level

- **WHEN** a skill needs to state a dependency on an external CLI or record a licensing term
- **THEN** `compatibility` or `license` is declared at the top level, because both are schema-defined fields

#### Scenario: Non-schema field placement

- **WHEN** a skill needs to record a field the schema does not define, such as an authoring date or a version number
- **THEN** the field is nested under `metadata` rather than added as a new top-level key

#### Scenario: Tool restriction is omitted by default

- **WHEN** a skill's work is open-ended rather than a wrapper around one command
- **THEN** `allowed-tools` is not declared, so the skill is not blocked in ways that surface far from their cause

### Requirement: Directory name determines invocation name

A skill's containing directory name SHALL be treated as its invocation name. The `name` field in frontmatter MUST be identical to the directory name. A mismatch SHALL be treated as a defect, because the directory name wins at load time and the declared `name` is ignored without an error.

#### Scenario: Name matches directory

- **WHEN** a skill lives at `skills/create-skill/SKILL.md`
- **THEN** its frontmatter declares `name: create-skill`

#### Scenario: Mismatch is caught at authoring time

- **WHEN** a proposed skill's frontmatter `name` differs from its directory name
- **THEN** the mismatch is reported as a defect and corrected before completion, rather than left to resolve silently at load time

### Requirement: Skill names are unique across the library

A skill's directory name SHALL be unique within `skills/`. `toolkit-structure` already requires asset names to be unique within a flat directory; this requirement adds the obligation to verify it at the Intent checkpoint, before any file exists to collide.

#### Scenario: Proposed name is already taken

- **WHEN** a new skill is proposed with a name matching an existing directory under `skills/`
- **THEN** the collision is reported and a different name is chosen before any file is written

### Requirement: Skills are authored into the toolkit library

The authoring workflow SHALL write skills into this repository's `skills/` directory. It MUST NOT write into the project it was invoked from, and MUST NOT silently resolve a different target such as a project-level or personal skills directory.

The skill's own `description` SHALL state this scope, so the target is visible before the workflow is loaded rather than discovered partway through it.

#### Scenario: Invoked from a consuming project

- **WHEN** the workflow is invoked from a project that installed this library as a plugin
- **THEN** it states that it authors into the toolkit repository and confirms that is the intent, rather than writing a skill into the current project

#### Scenario: Library-scoped checks are meaningful

- **WHEN** name uniqueness, tag vocabulary, and description disambiguation are evaluated
- **THEN** they are evaluated against this library's existing skills, because those checks are statements about this library and would pass without meaning anything against an unrelated project

### Requirement: Description written for reliable triggering

The `description` field SHALL be written as the sole signal used to decide whether to load the skill. It MUST state what the skill does and when it should be used, and MUST include concrete trigger terms a user would plausibly type.

Descriptions SHALL be written in the third person. They SHALL be written to counter under-triggering: they MUST name adjacent phrasings a user might use rather than only the canonical term, because the observed failure mode is a skill not firing when it would have helped.

A description MUST be distinguishable from the description of every other skill in the library. Vague descriptions that omit triggering conditions SHALL be rejected.

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

- **WHEN** a new skill overlaps in purpose with any existing skill in the library
- **THEN** the description states what distinguishes the two, so the correct skill is selected at trigger time

### Requirement: Tags are selected from the existing vocabulary

The authoring workflow SHALL present the tags already in use across `skills/` before tags are chosen, and SHALL require a reason before a new tag is coined. Tags SHALL be lowercase kebab-case.

#### Scenario: Existing tag is reused

- **WHEN** a proposed tag names a concept an existing tag already covers under a different word
- **THEN** the existing tag is used instead of coining a synonym

#### Scenario: New tag is justified

- **WHEN** no existing tag fits the asset
- **THEN** a new tag is introduced together with the reason it was needed

### Requirement: Structure selection between flat and bundled skills

A skill SHALL default to a single flat `SKILL.md`. When instructions exceed what is useful to load at once, the skill SHALL use progressive disclosure: a concise `SKILL.md` plus bundled resources in the skill's own directory, referenced by relative path.

Bundled resources SHALL follow the conventional directories: `references/` for material loaded into context on demand, `scripts/` for code that must run deterministically, and `assets/` for files used in the skill's output rather than read into context.

#### Scenario: Simple skill stays flat

- **WHEN** a skill's full instructions fit comfortably in a single readable document
- **THEN** it is authored as a lone `SKILL.md` with no bundled resources

#### Scenario: Detailed skill uses progressive disclosure

- **WHEN** a skill requires extended reference material
- **THEN** `SKILL.md` stays concise and links to files under `references/` in the same skill directory, read only when needed

#### Scenario: Resource is placed by kind

- **WHEN** a skill needs a template that ends up in the output it produces
- **THEN** the template is placed under `assets/` rather than `references/`, because it is not intended to be read into context

### Requirement: Human-in-the-loop checkpoint sequence

The authoring workflow SHALL pause for human confirmation before authoring proceeds:

1. **Intent** — the workflow SHALL confirm the skill's name, that the name is unused under `skills/`, its tags, purpose, and triggering conditions.
2. **Shape** — the workflow SHOULD confirm flat versus bundled structure and any `allowed-tools` when the structure is not obviously a single flat file, and MAY skip this checkpoint when it is.
3. **Draft** — the workflow SHALL present the proposed frontmatter and a body outline for approval before the full body is written.

The workflow MUST NOT write any file before the Draft checkpoint is approved.

#### Scenario: Intent checkpoint precedes all authoring

- **WHEN** a user asks for a new skill
- **THEN** the workflow confirms name, name availability, tags, purpose, and triggers before any file is created

#### Scenario: Shape checkpoint is skipped for an obviously flat skill

- **WHEN** a skill's instructions plainly fit one document and it wraps no single command
- **THEN** the Shape checkpoint is not raised, because a gate whose answer is not in question is friction that makes the workflow likelier to be bypassed

#### Scenario: Draft is approved before the body is written

- **WHEN** the frontmatter and outline are presented
- **THEN** no file is written until the user approves, and requested revisions are applied to the draft first

### Requirement: Authoring may conclude that no skill is warranted

The Intent checkpoint SHALL evaluate whether a skill is the right artifact at all. When the need is better served by a slash command, a subagent, a rule fragment, or a line in project memory, the workflow SHALL recommend that alternative instead of generating a skill.

#### Scenario: Need is too small for a skill

- **WHEN** the described need amounts to a short standing instruction
- **THEN** the workflow recommends a rule fragment or memory entry, and does not generate a skill

#### Scenario: Need matches a different artifact type

- **WHEN** the described need is a deterministic sequence the user wants to invoke explicitly by name
- **THEN** the workflow raises a slash command as the better fit before proceeding

### Requirement: Post-write validation

After writing a skill, the workflow SHALL verify and report that: frontmatter parses as valid YAML; `name` matches the directory name; the skill sits at `skills/<skill-name>/SKILL.md` in the toolkit repository with no intervening directory; any declared tags are lowercase kebab-case; the description states both action and triggering conditions; and every referenced bundled resource exists. Any failure SHALL be reported explicitly rather than silently corrected.

#### Scenario: Validation passes

- **WHEN** a generated skill satisfies every check
- **THEN** the workflow reports the checks that ran and the file paths written

#### Scenario: Broken reference is caught

- **WHEN** `SKILL.md` links to a bundled resource that was never created
- **THEN** validation reports the missing file rather than reporting success

#### Scenario: Misplaced skill is caught

- **WHEN** a generated skill is written to a path with a directory between `skills/` and the skill's own directory
- **THEN** validation reports the path as undiscoverable rather than reporting success

### Requirement: Triggering is verified before a skill is complete

The workflow SHALL verify that a new skill triggers, using at least one prompt that should activate it and one adjacent prompt that should not. Both outcomes SHALL be reported. A skill SHALL NOT be reported as complete until the positive prompt activates it and the negative prompt does not.

The check SHALL be run by an evaluator holding the candidate prompt and the `name` and `description` of every skill in the library, and not holding the conversation in which the skill was authored. A check performed inside the authoring context SHALL NOT be treated as evidence, because the skill is already loaded there and would activate regardless of what its description says.

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

### Requirement: Authoring standard is referenced, not duplicated

`AGENTS.md` SHALL point to the authoring skill as the source of the authoring standard, and MUST NOT restate its contents. `toolkit-structure` already bars `AGENTS.md` from carrying authoring standards and permits it to reference the authoring skill by path; this requirement makes that reference mandatory now that the authoring skill exists.

The authoring skill SHALL reference published external guidance for ground it does not need to restate, rather than copying that guidance into the repository.

#### Scenario: Conventions point at the standard

- **WHEN** a reader consults `AGENTS.md` for how to write a skill's frontmatter
- **THEN** it points to `skills/create-skill/SKILL.md` instead of restating the contract

#### Scenario: External guidance is referenced

- **WHEN** the authoring standard covers ground already documented by published skill-authoring guidance
- **THEN** it references that guidance by name rather than copying its text, so the two cannot drift into disagreement
