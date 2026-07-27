## Context

`ai-toolkit` is a library of reusable agent assets. At the time of this change the repository contains OpenSpec scaffolding and its own `.claude/` configuration, and nothing else.

The asset formats are portable — `SKILL.md` follows the Agent Skills format, documented independently of any single tool, and rule fragments are plain markdown. Packaging is not: a plugin manifest, a marketplace entry, and subagent definitions are Claude Code's shapes. This design treats the formats as the library and the packaging as one consumer's delivery mechanism.

Three facts about how assets load constrain the decisions below.

1. **A skill's directory name is its invocation name.** At load time the directory name wins, and a differing `name` in frontmatter is ignored without an error.
2. **Plugins are how assets reach a project.** A plugin is a directory with `.claude-plugin/plugin.json` and component directories at its root; a marketplace manifest lists plugins and can point at a local path. Installing one brings its skills and agents into a project without copying files.
3. **Skill and agent discovery differ.** Skill discovery scans `skills/` for subdirectories that directly contain a `SKILL.md` and descends no further. Agent discovery walks subdirectories but folds them into the invocation name as `plugin:subdir:agent-name`.

## Goals / Non-Goals

**Goals:**

- Make the repository installable as-is, with no build step and no copy step between authoring an asset and using it.
- Keep the number of invariants small, and prefer invariants something checks over conventions nothing checks.
- Give the repository one source of truth for conventions.
- Keep the repository free of executable code: markdown plus two manifests.

**Non-Goals:**

- Any asset content, and any standard for authoring one.
- Publishing the plugin to a public marketplace or supporting installation by anyone else.
- Automated validation of assets.

## Decisions

### D1: The repository is the distribution unit

The repo *is* a plugin. Root holds `.claude-plugin/plugin.json` plus the component directories; a sibling `marketplace.json` in the same folder makes the repo addable by path, so a consuming project runs two commands and has every asset in the library.

The invariant is that component directories sit *beside* `.claude-plugin/`, not inside it. Whether that shared parent is the repository root or a subdirectory depends on whether a `"source": "./"` entry is accepted, which task 1.2 settles. The spec is written against the plugin root for that reason, so the fallback shape does not falsify it.

**Settled:** the root-level shape was accepted — `/plugin marketplace add ~/projects/ai-toolkit` and `/plugin install` both succeeded with `"source": "./"`. The plugin root is the repository root; the fallback (`plugins/ai-toolkit/`) was not needed.

```
   REPOSITORY (author & maintain)          PROJECT (activate & use)
   ─────────────────────────────          ────────────────────────
   skills/<name>/SKILL.md          ────▶   available as a plugin skill
   agents/<name>.md               install  available as ai-toolkit:<name>
   rules/<name>.md                 @import referenced in CLAUDE.md by path
```

*Alternative considered:* keep the assets in the personal skills directory (`~/.claude/skills/`) and version that directory instead. Rejected — personal skills load in every project unconditionally with no per-project opt-in, and that directory carries skills only, so agents and rules would need a second home. A plugin is enabled where it is wanted and carries every asset type as one unit.

*Consequence:* rules are the one asset type the packaging does not carry, because there is no rules primitive to carry them. They stay usable with no machinery at all, because `CLAUDE.md` `@` imports resolve `~`-rooted paths: a project writes `@~/projects/ai-toolkit/rules/<name>.md` and gets the fragment by reference rather than by copy.

**Settled (task 5.6):** the import form was verified against a scratch project — `~`-rooted `@` imports resolve, and the fragment's content is picked up correctly. The first time a project's `CLAUDE.md` imports a path outside that project, Claude Code shows a one-time "Allow external CLAUDE.md file imports?" confirmation before reading it. This is expected security behavior for any external import, not specific to this repository or a defect in the mechanism — worth documenting so it isn't mistaken for a failed import.

*Consequence:* the packaging is replaceable. If a second consumer needs a different format, that is a manifest added alongside these, not a restructuring — the assets are already in their portable formats.

### D2: One directory level for every asset type

```
skills/<skill-name>/SKILL.md      agents/<agent-name>.md      rules/<rule-name>.md
```

Fact 3 sets the depth, and it sets it differently for each type:

- **Skills** must sit immediately under `skills/`, because that is the only depth discovery looks at. A `SKILL.md` any deeper is never found, and nothing reports the omission.
- **Agents** sit directly in `agents/` so their invocation name stays `ai-toolkit:<name>`. Discovery would accept a subdirectory, but it would fold that directory into the name — making the name encode a grouping decision, so revising the grouping renames the agent and breaks every reference to it.

  The same fact makes `agents/` the one directory where a placeholder is not free: every `.md` file directly inside it is read as an agent definition. This was confirmed empirically during task 5.1: a first attempt at this placeholder, `agents/.gitkeep.md`, was installed and loaded as a real agent named `ai-toolkit:.gitkeep` — discovery strips the `.md` extension and uses whatever remains as the name, with no special case for a leading dot. The fix is a non-`.md` extension (`agents/README.txt`), which is not a file discovery reads at all. `skills/` has no such problem — discovery looks for subdirectories containing a `SKILL.md`, so a file directly under `skills/` is inert — and nothing discovers `rules/` at all.
- **Rules** are constrained by nothing, and take the same shape as the other two.

*Cost accepted:* no grouping is visible in the tree. Mitigated by tags being greppable and by names being descriptive; revisited if a directory listing stops being readable.

*Consequence:* names must be unique within each directory. The filesystem enforces this, so it is a real invariant rather than a convention.

### D3: Tags are the only classification

`metadata.tags` holds free-form, lowercase kebab-case labels. Multi-valued, structurally inert, and the only classification an asset carries.

*Alternative considered:* add a single-valued `category` alongside tags, drawn from a fixed axis such as the asset's domain. Rejected on three counts. Nothing structural would depend on it, since D2 leaves no directory for it to agree with. It would force one answer where assets legitimately span several domains — the case that justifies tags in the first place. And nothing could check it, so a wrong value would be invisible. Two classification fields also mean every authoring session first has to decide which field a label belongs in, which is friction that buys nothing.

*Anti-rot mechanism:* free-form tags accumulate synonyms — `git`, `vcs`, and `version-control` all end up in use — and unlike a directory taxonomy, nothing makes the mess visible. The convention is to check the vocabulary already in use before coining a tag. The follow-up change enforces this at authoring time; here it is stated in `AGENTS.md`.

*Note:* the plugin's own `category` and `tags` in the marketplace entry are unrelated. That is one classification for the whole plugin, which is what the marketplace schema asks for.

### D4: The directory is the catalogue

There is no asset index.

`skills/` *is* the listing, and every asset already carries a one-line summary in its own `description`, which has to be good regardless because loading depends on it. An index duplicates that field into a second location that drifts. Since nothing reads it, a stale index breaks nothing while quietly making the README untrustworthy — a failure with no forcing function to make anyone notice.

`README.md` instead documents how to list what's there: one command over the frontmatter that already exists, always accurate, nothing to maintain.

*Alternatives considered:* a hand-maintained index (rejected — drifts within weeks, and every future authoring workflow grows a step whose only job is preventing that); a generator script (rejected — puts the first executable code into a repository whose value proposition is that it has none).

*Trade-off accepted:* browsing costs a command instead of a scroll. Adding an index later is cheap, and by then its shape would be informed by how the library is actually used.

### D5: `AGENTS.md` is the source of truth; `CLAUDE.md` is a one-line import

`CLAUDE.md` is what Claude Code reads for project memory; `AGENTS.md` is the portable cross-tool convention. Writing the content once in `AGENTS.md` and reducing `CLAUDE.md` to `@AGENTS.md` gives both without duplication — and mirrors D1, where the portable thing is the content and the tool-specific thing is a thin adapter.

*Alternative considered:* symlink `CLAUDE.md` → `AGENTS.md`. Rejected — equivalent in effect, worse in Git on Windows clones.

`AGENTS.md` carries repo conventions only: the layout and the constraint behind it, tags, naming, and where authoring standards will live. Authoring standards themselves are long and needed rarely, so they belong behind an on-demand load rather than in a file loaded every session. The follow-up change adds the pointer to them.

### D6: The plugin is installed into its own repository as part of this change

Installing here proves the manifests work, and it is the only way to find out. A manifest that is syntactically fine but structurally wrong produces no error — the plugin simply carries nothing.

That failure mode is what makes "it installs and the plugin appears" the wrong acceptance test *for this change specifically*: with the library shipping no assets, a correctly wired plugin and a broken one produce the same observation. The test would pass in exactly the case it exists to catch.

So the acceptance test is a component loading, not a plugin appearing: add a throwaway `skills/_smoke/SKILL.md`, install, confirm it is listed as a skill *of this plugin*, then delete it and reinstall. Nothing ships, so the "no assets" non-goal holds — the smoke asset exists only inside the verification step. This costs one extra commit and is the only evidence that meets the standard stated above.

Doing it now also means the follow-up change starts from a working install rather than debugging packaging and authoring at once.

The no-install development loop is `claude --plugin-dir /home/shatynska/projects/ai-toolkit`, which is also how an asset gets tested before it is committed.

**Settled:** running `--plugin-dir` against this repository from the same project where it is also marketplace-installed produces no collision. It shows as a single `ai-toolkit` plugin, source `inline`, enabled — the flag-loaded copy is what takes effect, not a duplicate. Confirmed with `skills/` and `agents/` still holding only their placeholders, so no stray component appeared either.

## Risks / Trade-offs

- **Plugin install is per machine, not per project** → Copying an asset into a project's `.claude/skills/` would commit it alongside the team's code, so a teammate cloning the repo gets it for free. Plugin installation does not: each person installs the marketplace themselves. Accepted: this repository is authored and consumed by one person rather than distributed to a team. If an asset ever needs to ship with a team repo, copying that one asset by hand is the escape hatch.
- **Discoverability rests entirely on names and descriptions** → With no index and no grouping directories, an asset with a vague name or a weak description is effectively lost, and nothing surfaces that. This is the cost of D2 plus D4. Partially mitigated here by requiring descriptions to state what an asset does and when to use it; the follow-up change adds a description standard and a trigger check, which is where this risk is actually addressed.
- **Tag vocabulary drift** → Free-form tags accumulate synonyms, and nothing makes it visible. Mitigated by convention now and by the authoring workflow later. Weaker than a structural constraint, and accepted as such.
- **Manifest duplication** → `plugin.json` and the marketplace entry both carry `name` and `description`. Two places to edit, one of which will be forgotten. Accepted: it is two files, and a stale marketplace description is cosmetic.
- **A root-level plugin in its own marketplace is unverified** → Published marketplaces use relative sources like `./plugins/agent-sdk-dev`, with the plugin in a subdirectory of the marketplace repo. This change puts the plugin at the repo root, which implies a `"source": "./"` entry, and that form is not confirmed. If it fails, the fallback is the verified shape — plugin under `plugins/ai-toolkit/`, marketplace entry pointing at it — at the cost of a longer path to every asset. Task 1.2 settles this before anything is built on top of it. Taking the fallback also invalidates the paths `README.md` and `AGENTS.md` document and the target path `add-create-skill` assumes, so it is settled before those files are written, not after.
- **An empty `skills/` directory ships** → This change deliberately leaves `skills/` unpopulated, so the installed plugin demonstrates no working skill. Accepted: the alternative is bundling the authoring skill back in, which is what made the combined change hard to review. The verification gap this would otherwise open in D6 is closed by the smoke asset instead, which proves the wiring without shipping anything.
- **The rule import path is machine-local** → `@~/projects/ai-toolkit/rules/<name>.md` resolves only where this library is checked out at that path. A project that commits such an import to a repository shared with other people has committed a line that is dead for all of them — the fragment is a single source of truth only on this machine. Distinct from the per-machine plugin risk above, and unmitigated: documented as a limitation rather than solved, since no rules exist yet to justify machinery.
- **`~`-rooted `@` imports are assumed, not confirmed** → The whole rules consumption model rests on this one behavior, and unlike the plugin-root question it had no settling task. Task 5.6 adds one; documenting a mechanism that does not work would be worse here than elsewhere, since a failed import is silent.

## Migration Plan

No migration. The repository has no prior structure and no consumers.

Rollback is `git revert` of a single commit, plus `/plugin marketplace remove` if the plugin was installed. Nothing external depends on the layout yet.

## Open Questions

- Root-level plugin with `"source": "./"`, or the `plugins/ai-toolkit/` shape? Settled empirically by task 1.2, not by argument.
- Should `rules/` fragments be reachable through the plugin rather than only by `@` import path? Plugins carry a `CLAUDE.md`, so a rule could in principle be surfaced that way, but it would apply to every project with the plugin installed rather than to the ones that opt in. Left alone until there are rules to test it with.
