## 1. Groundwork

- [x] 1.1 Confirm `bootstrap-toolkit-repo` has landed and the library loads — installed plugin or `claude --plugin-dir <repo path>` — so the skill can be exercised end to end
- [x] 1.2 Read the prior art before writing: `skill-creator` and `plugin-dev/skills/skill-development` in the installed official marketplace. Note what this skill will reference rather than restate
- [x] 1.3 Read the published Agent Skills schema and record its top-level field list together with where it was read and on what date, so the frontmatter contract carries provenance rather than an unsourced enumeration
- [x] 1.4 Create `skills/create-skill/`

## 2. Frontmatter and the standard it documents

- [x] 2.1 Write the frontmatter for `skills/create-skill/SKILL.md`: `name: create-skill`, `metadata.tags`, and a third-person description that states the action, names adjacent phrasings a user might type, and is scoped to explicit skill-authoring language rather than general "help me build" phrasing
- [x] 2.2 Write the frontmatter contract section: `name` and `description` required; schema-defined fields allowed at top level, listed as the dated snapshot from 1.3 rather than as a closed enumeration; non-schema fields nested under `metadata`; `name` must match the directory name; `allowed-tools` omitted unless the skill wraps a single command
- [x] 2.3 Write the description-quality section: third-person phrasing, deliberately over-eager coverage of adjacent phrasings, library-wide disambiguation, and rejection examples
- [x] 2.4 Write the structure-selection section: flat `SKILL.md` by default; `references/`, `scripts/`, and `assets/` when it outgrows one document, with the loading budget that motivates the split
- [x] 2.5 Write the tag-selection section: present the tags already in use across `skills/` and require a reason before coining a new one
- [x] 2.6 Write the target-scope section: the workflow authors into this repository's `skills/`, never into the project it was invoked from, and says so when invoked elsewhere — because uniqueness, tag vocabulary, and disambiguation are checks against this library

## 3. The workflow

- [x] 3.1 Write the HITL checkpoint flow: mandatory Intent gate (name, verification that the name is unused under `skills/`, tags, purpose, triggers), Shape gate raised only when the structure is not obviously flat, mandatory Draft gate, and the rule that no file is written before Draft approval
- [x] 3.2 Write the Intent-gate alternatives guidance: when to recommend a slash command, subagent, rule fragment, or memory entry instead of a skill, and that concluding "no skill" is a valid outcome
- [x] 3.3 Write the post-write validation checklist: YAML parses, `name` matches directory, path is `skills/<name>/SKILL.md` with no intervening directory, tags are lowercase kebab-case, description states action and triggers, bundled references exist — with failures reported explicitly rather than silently fixed
- [x] 3.4 Write the trigger-check step: one prompt that should activate the skill, one adjacent prompt that should not, both outcomes reported; widen the description on a positive-prompt failure, narrow it on a negative-prompt failure, and repeat
- [x] 3.5 Write how the check is run: each prompt goes to a fresh-context evaluator given the prompt and every skill's `name` and `description`, and nothing from the authoring conversation. State that a check made inside the authoring context is not evidence, since the skill is already loaded there
- [x] 3.6 Add the pointer to `skill-creator` for the eval-heavy path, so the two-prompt check reads as a floor rather than the ceiling
- [x] 3.7 Split the body into `references/` if it has outgrown a single readable document by this point — applying the skill's own structure rule to itself rather than exempting it (1782 words; stays flat)

## 4. Dogfooding

- [x] 4.1 Validate `skills/create-skill/SKILL.md` against its own post-write checklist from 3.3, and fix what it reports (caught and fixed a misleading reference that read as a broken bundled-resource link)
- [x] 4.2 Run the trigger check against `create-skill` itself through a fresh-context evaluator: a skill-authoring prompt activates it, and a genuinely adjacent prompt — "write a subagent that reviews commit messages" — does not. Revise the description and repeat until both hold. A negative prompt that could not plausibly misfire measures nothing (both held on first pass; see 4.3 for recorded transcript)
- [x] 4.3 Record the two prompts and their outcomes, deciding at this point whether they live in the skill for later re-verification — the open question in `design.md` (resolved: yes, recorded in a `## Recorded trigger check` section)

## 5. Conventions and verification

- [x] 5.1 Delete `skills/README.md`, the placeholder from `bootstrap-toolkit-repo` whose stated lifetime ends with the first skill
- [x] 5.2 Add the pointer line in `AGENTS.md` to `skills/create-skill/SKILL.md` as the authoring standard, without restating its contents
- [x] 5.3 Verify `AGENTS.md` and the skill do not restate each other — conventions in one, authoring standard in the other, connected by the pointer (found and fixed one restatement: the directory-name/invocation explanation was duplicated in both; the skill now points at `AGENTS.md` for the *why* and keeps only the authoring-time check)
- [x] 5.4 Confirm the skill contains no `metadata.category` and adds no index, so it stays consistent with the conventions from `bootstrap-toolkit-repo`
- [x] 5.5 Run `openspec validate add-create-skill` and resolve any reported issues (valid, no issues)
