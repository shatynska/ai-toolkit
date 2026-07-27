## 1. Plugin packaging

- [x] 1.1 Add `.gitignore` covering OS cruft (`.DS_Store`, `Thumbs.db`), editor directories (`.vscode/`, `.idea/`), and `.claude/settings.local.json`, while leaving the rest of `.claude/` tracked
- [x] 1.2 Settle the plugin-root question before building on it: write `.claude-plugin/plugin.json` (`name: ai-toolkit`, plus `description`, `version`, `author`) and `.claude-plugin/marketplace.json` with a single plugin entry sourced at `"./"`, then confirm both `/plugin marketplace add ~/projects/ai-toolkit` **and** `/plugin install` succeed — `add` only validates the marketplace manifest, and can accept an entry whose `source` never resolves. If a root-level source is rejected, fall back to plugin under `plugins/ai-toolkit/` with the marketplace entry pointing at `./plugins/ai-toolkit`. Record the shape used in `design.md`, and if it is the fallback, correct the paths in `README.md`, `AGENTS.md`, and the placeholders before section 5 — **root-level `"source": "./"` was accepted**: both `add` and `install` succeeded
- [x] 1.3 Carry the plugin's own classification into the marketplace entry: `category` and `tags` on the entry itself
- [x] 1.4 Confirm the marketplace entry contains no `skills` enumeration array, so adding a skill later needs no manifest edit

## 2. Directory layout

- [x] 2.1 Create `skills/` with a placeholder stating that skills live at `skills/<skill-name>/SKILL.md`, one level down, and that the directory name is the invocation name. The follow-up change deletes this placeholder when it adds the first skill — one throwaway file, in exchange for a layout that is true from the first commit and a README listing command that returns an empty list rather than an error. Safe to place directly under `skills/`, since discovery looks only at subdirectories containing a `SKILL.md`
- [x] 2.2 Create `agents/` with a placeholder stating that subagent definitions live at `agents/<agent-name>.md`, flat, and that the flat shape keeps the invocation name free of grouping. Give the placeholder a form agent discovery ignores — confirmed empirically that every `.md` file directly inside `agents/` is read as an agent definition regardless of a leading dot in the filename, so the placeholder is `agents/README.txt`, not a `.md` file
- [x] 2.3 Create `rules/` with a placeholder stating that memory fragments live at `rules/<rule-name>.md`, flat, and are consumed by `@` import path rather than by copying

## 3. Conventions documentation

- [x] 3.1 Write `AGENTS.md`: the one-level layout for all three asset types, the tags convention, names unique per directory, and the rule that a skill's directory name determines its invocation name
- [x] 3.2 State the constraint behind the layout in `AGENTS.md` — skill discovery looks at exactly one level, and an agent subdirectory would be folded into the invocation name — so the rule reads as a constraint rather than a preference
- [x] 3.3 State in `AGENTS.md` that assets reach a project by plugin install, and that `rules/` fragments are consumed by `@` import path with no tooling
- [x] 3.4 State in `AGENTS.md` that tag vocabulary is checked before a new tag is coined, and that authoring standards live with the authoring skill rather than in this file
- [x] 3.5 State in `AGENTS.md` which directories are the library and which are not: `skills/`, `agents/`, and `rules/` ship in the plugin, while `.claude/` holds this repository's own tooling — the repo already carries OpenSpec skills under `.claude/skills/`, so without this an asset meant to ship gets written where it works locally and never ships
- [x] 3.6 Write `CLAUDE.md` containing only the `@AGENTS.md` import

## 4. README

- [x] 4.1 Write `README.md`: what the repository is, that the asset formats are portable while the packaging is Claude Code's, and the one-level layout for all three asset types
- [x] 4.2 Document consumption in `README.md`: `/plugin marketplace add ~/projects/ai-toolkit` then `/plugin install`, `claude --plugin-dir` as the no-install development loop, and `@` import paths for `rules/` fragments — noting that the import path is machine-local, so committing one to a repository shared with other people leaves a line that resolves only here
- [x] 4.3 Document the tags convention in `README.md`, and give the command that lists available assets with their descriptions — stating plainly that this replaces a maintained index

## 5. Verification

- [x] 5.1 Prove a component loads, not just that the plugin appears: add a throwaway `skills/_smoke/SKILL.md` with valid frontmatter, install the plugin into this repository, and confirm the smoke skill is listed as a skill *of this plugin*. A structurally wrong manifest installs without error and carries nothing, so an "the plugin appears" check cannot tell success from that failure — confirmed: `_smoke` appeared in the skills listing after install
- [x] 5.2 Delete `skills/_smoke/`, reinstall, and confirm the plugin still loads and the smoke skill is gone — nothing from the verification ships — confirmed: `_smoke` is gone from the listing after reinstall, plugin still loads
- [x] 5.3 While the plugin is installed, run `claude --plugin-dir /home/shatynska/projects/ai-toolkit` against this same repository and record in `design.md` what the duplicate registration does. This is the loop every later authoring session uses, so a collision here is worth knowing before it is relied on — confirmed: no collision, shows as a single `ai-toolkit` plugin (source `inline`), enabled
- [x] 5.4 Confirm the `agents/` placeholder exposes no agent and reports no parse failure in the installed plugin — first attempt (`agents/.gitkeep.md`) failed this and was loaded as agent `ai-toolkit:.gitkeep`; fixed by switching to `agents/README.txt`; reinstall + reload confirmed `ai-toolkit:.gitkeep` is gone and the agent count dropped 7→6 with no replacement ghost agent
- [x] 5.5 Confirm no asset type uses a grouping directory, and that `skills/`, `agents/`, and `rules/` sit beside `.claude-plugin/` at the plugin root rather than inside it — confirmed: each directory holds only its flat placeholder, and all three sit at the repository root alongside `.claude-plugin/`
- [x] 5.6 Verify the rule import form resolves before trusting the documentation: create a scratch fragment under `rules/`, `@` import it from a throwaway project's `CLAUDE.md` by `~`-rooted path, confirm the content is picked up, then remove both. If the form does not resolve, correct `README.md` and `AGENTS.md` before this change lands — confirmed: the fragment's content was picked up correctly, after a one-time "Allow external CLAUDE.md file imports?" confirmation prompt (expected Claude Code behavior for any external import, now noted in `design.md` and `README.md`)
- [x] 5.7 Verify `AGENTS.md` carries conventions only, with no authoring guidance that belongs to the follow-up change — confirmed: layout, tags, naming, and library-vs-tooling scope only; explicitly defers authoring standards in its own closing section
- [x] 5.8 Confirm `git status` is clean of ignored machine-local files — confirmed: `.claude/settings.local.json` isn't present, but `git check-ignore` confirms the rule matches it, and the rest of `.claude/` remains tracked
- [x] 5.9 Run `openspec validate bootstrap-toolkit-repo` and resolve any reported issues — passes with `--strict`
