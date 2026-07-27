## Why

`ai-toolkit` is a library of reusable agent assets — skills, subagents, and rule fragments — kept in one place so they survive past the session that produced them and can be pulled into any project later. The asset formats are portable: `SKILL.md` follows the Agent Skills format, which is documented independently of any single tool, and rule fragments are plain markdown any agent can be pointed at. Claude Code is the first consumer, not the point.

Right now the repository holds only OpenSpec scaffolding, and two things are missing before any asset is worth writing. It has no shape a consuming project can load, so an asset written today reaches a project only by copy-paste. And it has no stated conventions — no README, no `.gitignore`, nothing saying where assets go, how they are named, or how they are classified — so every asset is an ad-hoc decision and the repo accretes inconsistency faster than it accretes value.

This change establishes both, and nothing else. The authoring skill that generates assets to a fixed standard is a separate change built on these conventions.

## What Changes

- **Package the repository as a Claude Code plugin**, which is what makes it loadable today:
  - `.claude-plugin/plugin.json` — the plugin manifest (`name`, `description`, `version`, `author`)
  - `.claude-plugin/marketplace.json` — a single-plugin marketplace manifest so the repo can be added by local path, carrying the plugin's own `category` and `tags`
  - Installed with `/plugin marketplace add ~/projects/ai-toolkit` then `/plugin install`; developed against with `claude --plugin-dir` for a no-install loop
  - The packaging is one consumer's delivery format, not the library's identity. A second consumer wanting a different format is an additive change.
- Adopt a **flat layout for every asset type**, one directory level, no grouping directories:
  - `skills/<skill-name>/SKILL.md`
  - `agents/<agent-name>.md`
  - `rules/<rule-name>.md`
- Adopt **tags as the only classification**: `metadata.tags`, a list of free-form lowercase kebab-case labels, multi-valued and structurally inert.
- Add `README.md` — what the repo is, how to install it, the layout, the tags convention, and how to list what's available.
- Add `.gitignore` covering OS cruft, editor directories, and machine-local Claude Code state (`.claude/settings.local.json`).
- Add `AGENTS.md` holding repo-level conventions for agents working *in* this repo: the layout and the constraint behind it, the tags convention, naming rules, and the rule that a skill's directory name determines its invocation name.
- Add `CLAUDE.md` as a one-line `@AGENTS.md` import, so Claude Code picks up the conventions without duplicating them.
- Install the plugin into its own repository and confirm a component loads from it, proving the packaging works before any asset depends on it. A throwaway smoke skill supplies that component and is deleted within the same change, since an empty plugin installs cleanly whether or not its wiring is correct.
- Create `skills/`, `agents/`, and `rules/` with a short placeholder explaining what belongs in each; do not populate them. The `agents/` placeholder takes a form agent discovery ignores, because every file directly inside `agents/` is otherwise read as an agent definition.

Non-goals for this change:

- **No assets.** No skills, agents, or rules content — packaging and conventions only. `skills/` holds only its placeholder until the next change fills it. The smoke skill is not an exception: it exists inside the verification step and is deleted before the change lands, so nothing ships.
- **No authoring standard.** How a skill is written well — frontmatter contract, description criteria, review checkpoints — belongs with the skill that enforces it, in the follow-up change. `AGENTS.md` states conventions, not authoring guidance.
- **No asset index.** The directory listing plus each asset's own `description` is the catalogue; `README.md` documents how to list them rather than maintaining a second copy that drifts.
- No generator script of any kind. The repo stays free of executable code.
- No publishing to a public marketplace, and no support for anyone else installing it.

## Capabilities

### New Capabilities

- `toolkit-structure`: How the repository is organized and consumed — the plugin manifests that make it installable, the flat layout for every asset type and the constraint behind each, the tags-only classification, naming rules, how assets are browsed without an index, how rule fragments are consumed by import path, and which documentation file carries which kind of knowledge so the two do not drift into duplicating each other.

### Modified Capabilities

<!-- None. openspec/specs/ is empty; this is the first change in the repo. -->

## Impact

- **New files**: `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `README.md`, `.gitignore`, `AGENTS.md`, `CLAUDE.md`, placeholders under `skills/`, `agents/`, and `rules/`.
- **Distribution model**: the repository is the unit of distribution. Assets reach a project by installing the plugin, which is a per-machine step rather than a per-project commit — trade-off recorded in `design.md`.
- **Naming constraint**: with every directory flat, an asset's name must be unique within its own directory. That is structural rather than a convention nothing checks.
- **Follow-up**: a separate change adds `skills/create-skill/SKILL.md` and the authoring standard it enforces, including a pointer to it from `AGENTS.md`. That pointer plus deleting the `skills/` placeholder are the only things the follow-up changes in files this change writes.
- **No code, no dependencies, no build step** — the repo stays markdown plus two manifests.
