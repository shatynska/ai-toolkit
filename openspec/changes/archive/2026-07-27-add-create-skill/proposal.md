## Why

`bootstrap-toolkit-repo` makes the repository installable and states where assets go, how they are named, and how they are classified. It deliberately says nothing about what makes a skill *good*, and leaves `skills/` empty.

That gap matters more here than it would elsewhere, because a badly written skill fails silently. A skill whose `description` never matches how anyone phrases the request is indistinguishable from a skill that was never written — no error, no warning, just a tool that sits unused while the work is done by hand. The same text is also the only way a human finds the asset, since the library has no index by design.

So the first skill in the library should be the one that governs the rest: a `create-skill` skill that walks the decisions in order, gates the expensive ones on human confirmation, and refuses to call a skill finished until it has been observed to trigger.

## What Changes

- Add `skills/create-skill/SKILL.md`, covering:
  - **Frontmatter contract** — `name` and `description` required; `allowed-tools`, `license`, and `compatibility` allowed at the top level because the Agent Skills schema defines them (per `skill-creator`'s shipped validation script — notably `version` is not schema-defined, despite appearing in some hand-written examples); anything outside that schema nested under `metadata`; `allowed-tools` omitted unless the skill wraps a single command.
  - **The directory-name rule** — a skill's directory name is its invocation name, and `name` in frontmatter must match it. A mismatch is a defect that resolves silently at load time, so it has to be caught at authoring time.
  - **Description standard** — third person, written to counter under-triggering rather than to sound measured, naming adjacent phrasings a user might actually type, and distinguishable from every other skill in the library.
  - **Structure selection** — a flat `SKILL.md` by default; bundled `references/`, `scripts/`, and `assets/` when instructions outgrow one readable document.
  - **Tag selection** — choose `metadata.tags` from the vocabulary already in use, and justify coining a new one.
  - **HITL checkpoints** — mandatory Intent gate (name, tags, purpose, triggers, and whether a skill is the right artifact at all), Shape gate raised only when the structure is not obviously flat, mandatory Draft gate. No files are written before Draft approval.
  - **Post-write validation** — frontmatter parses, `name` matches the directory, the path is discoverable, bundled references exist, with failures reported rather than silently fixed.
  - **Trigger check** — one prompt that should fire the skill and one adjacent prompt that should not, put to a fresh-context evaluator that holds the library's descriptions but not the authoring conversation, both outcomes reported, description revised and rechecked on either failure.
  - **Target scope** — the skill authors into this repository's `skills/`, not into whatever project it happens to be invoked from, because uniqueness, tag vocabulary, and disambiguation are all statements about this library.
- Add the `AGENTS.md` pointer to `skills/create-skill/SKILL.md` as the authoring standard, so repo conventions reference the standard without restating it.
- Author `create-skill` to its own standard, including running the trigger check against itself, so the skill is the worked example of what it asks for.
- Reference `skill-creator` and `plugin-dev/skills/skill-development` for the ground they already cover rather than restating it.

Non-goals for this change:

- **No scripted eval harness.** `skill-creator` already does test-prompt runs and variance analysis. This change adopts the cheap end — a two-prompt check — and points at the scripted path instead of reproducing it, which keeps this change free of executable code.
- **No `review-skill`** that audits skills already written.
- **No authoring skills for agents or rules.** Both are single files with small frontmatter, and `plugin-dev` documents the agent format already.
- **No asset index**, and no change to the layout or classification conventions set by `bootstrap-toolkit-repo`.

## Capabilities

### New Capabilities

- `skill-authoring`: The standard a skill in this repository must meet, and the workflow that produces one — the frontmatter contract against the Agent Skills schema, the rule that directory name determines invocation name, name uniqueness, description criteria written against the under-triggering bias, structure selection between a flat `SKILL.md` and bundled resources, the library as the authoring target, the human-in-the-loop checkpoint sequence including the option to conclude no skill is warranted, post-write validation, and the trigger check that turns a reviewed description into an observed one.

### Modified Capabilities

- `toolkit-structure`: the requirement that the repository contain no executable code is narrowed to repository-level tooling — no build step, no scripts driving the repo — so that the `scripts/` directory a skill may bundle under the structure-selection standard does not contradict it.

## Impact

- **New files**: `skills/create-skill/SKILL.md`, plus files under `skills/create-skill/references/` if the body outgrows one document.
- **Deleted files**: `skills/README.md` — the placeholder `bootstrap-toolkit-repo` put in the empty directory, whose stated lifetime ends with the first skill.
- **Modified files**: `AGENTS.md` — one pointer line to the authoring standard.
- **Depends on** `bootstrap-toolkit-repo`: the flat layout, `metadata.tags` as the only classification, and the plugin packaging. The two files this change shares with it are `AGENTS.md` and the `skills/` placeholder it removes.
- **Ongoing effect**: `create-skill` becomes the sanctioned route to a new skill. Skills written by hand are still discovered and still work — nothing enforces the route — but they carry no evidence that they trigger.
- **No dependencies, no build step.** Markdown only.
