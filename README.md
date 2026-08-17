# ai-toolkit

A library of reusable agent assets — skills, subagents, and rule fragments —
kept in one place so they survive past the session that produced them and
can be pulled into any project later.

The asset formats are portable: `SKILL.md` follows the Agent Skills format,
documented independently of any single tool, and rule fragments are plain
markdown any agent can be pointed at. Claude Code is this repository's
packaging, not the assets' identity — a plugin manifest is one consumer's
delivery mechanism, added alongside the portable formats rather than
replacing them.

## Layout

Every asset type sits at exactly one directory level, with no grouping
subdirectories:

```
skills/<skill-name>/SKILL.md
agents/<agent-name>.md
rules/<rule-name>.md
```

A skill's directory name is its invocation name. See `AGENTS.md` for the
full conventions and the constraints behind this layout.

Two further directories sit alongside these, in a separate category from
library assets: `scripts/` holds deterministic tooling that ships with the
library and is meant to be run directly (`scripts/project-init`, for
instance) — reachable by a consumer, a shell, or any harness, not only one
that loads `skills/`; `tests/` holds a dependency-free harness exercising
it. Neither is discovered by description the way an asset is. See
`AGENTS.md` for what belongs in each.

## Installing

```
/plugin marketplace add ~/projects/ai-toolkit
/plugin install
```

This installs every skill and agent in the library into the current
project — no files are copied.

To develop against the library without installing it, run:

```
claude --plugin-dir ~/projects/ai-toolkit
```

`rules/` fragments have no dedicated loading mechanism — installation
copies this repository's entire tree, so the files are present in an
installed copy, but nothing loads them automatically the way `skills/` and
`agents/` are loaded. Two paths reach a fragment: adopt one yourself by `@`
importing its path from a project's `CLAUDE.md` or `AGENTS.md`,

```
@~/projects/ai-toolkit/rules/<rule-name>.md
```

or let a shipped tool under `scripts/` read and inline it directly — this
is how `scripts/project-init` delivers `rules/development-workflow.md`
into a project's `AGENTS.md`, with no import involved.

The `@` import path is machine-local — it resolves only where this
repository is checked out at that path, so it is not suitable for a
`CLAUDE.md` committed to a repository shared with other people.

The first time a project's `CLAUDE.md` imports a path outside that project,
Claude Code shows a one-time confirmation before reading it. That's expected
behavior for any external import, not a sign the import failed.

## Tags

Every asset may declare `metadata.tags`, free-form lowercase kebab-case
labels. Tags are the only classification an asset carries — multi-valued,
and structurally inert. Check the vocabulary already in use before coining
a new tag, so synonyms (`git`, `vcs`, `version-control`) don't accumulate.

## Browsing what's available

There is no maintained index. Every asset's own `description` is required
to state what it does and when to use it — that requirement is what makes
listing frontmatter a substitute for an index. List what's available with:

```
head -n 5 skills/*/SKILL.md
head -n 5 agents/*.md
head -n 5 rules/*.md
```
