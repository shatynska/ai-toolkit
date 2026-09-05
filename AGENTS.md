# ai-toolkit conventions

This repository is a library of reusable agent assets — skills, subagents,
and rule fragments — packaged as a Claude Code plugin so it can be installed
into any project without copying files. These are the conventions for
authoring in this repository.

## Layout

Every asset type sits at exactly one directory level, with no grouping
subdirectories:

- `skills/<skill-name>/SKILL.md`
- `agents/<agent-name>.md`
- `rules/<rule-name>.md`

This is a constraint, not a preference. Skill discovery scans `skills/` for
subdirectories that directly contain a `SKILL.md` and descends no further —
a `SKILL.md` placed any deeper is never found, and nothing reports the
omission. Agent discovery does walk subdirectories, but folds them into the
invocation name as `plugin:subdir:agent-name` — a subdirectory would make an
agent's name encode a grouping decision, so revising the grouping later
renames the agent and breaks every reference to it. Rules are constrained by
neither fact but take the same flat shape for consistency.

A skill's directory name is its invocation name. A `name` in the
frontmatter that differs from the directory is ignored at load time with no
error, so the two must match.

Because every directory is flat, names must be unique within their own
directory — the filesystem enforces this.

## Reaching a project

Assets reach a consuming project by installing this repository as a plugin
(`/plugin marketplace add`, then `/plugin install`) — not by copying files.

`rules/` fragments have no dedicated Claude Code primitive, so nothing
loads them automatically the way `skills/` and `agents/` are loaded. That
does not mean they are absent from an installed copy: plugin installation
copies this repository's entire tree, not only the directories backing a
primitive, so `rules/` is present and readable wherever the plugin is
installed — it just has no automatic loader. Two paths reach a fragment
from there:

- **`@` import** — a project's `CLAUDE.md` or `AGENTS.md` names the
  fragment's path in this repository (e.g.
  `@~/projects/ai-toolkit/rules/<rule-name>.md`). Needs no tooling, but the
  path is machine-local — it resolves only where this repository is
  checked out at that path.
- **A shipped tool reading it** — an executable under `scripts/` locates a
  fragment relative to its own installed location and reads it directly,
  with no import and no harness involved. `scripts/project-init` does
  this: it inlines `rules/development-workflow.md` into a project's
  `AGENTS.md`.

Both reach any fragment under `rules/`. What a binding fragment such as
`rules/development-workflow-database.md` lacks until tooling catches up is a
*tool* route, not a route: it is imported or copied by hand rather than written
into a managed block.

A `rules/` fragment is one of two kinds, declared in its own YAML
frontmatter:

```yaml
---
kind: standing-constraint    # or: procedural-checklist
version: 1                   # only if the fragment is inlined, now or later
---
```

A **standing constraint** is meant to reach a project's `CLAUDE.md` or
`AGENTS.md` and remain in force there — by either path above. A
**procedural checklist** describes a one-time procedure, read on demand,
and is never inlined into a project's conventions file — inlining it would
leave permanent instructions for work already finished.

## Tags

`metadata.tags` is the only classification an asset carries: a list of
free-form, lowercase kebab-case labels. Multi-valued, and structurally
inert — no directory or name depends on it.

Before coining a new tag, check the vocabulary already in use. Free-form
tags accumulate synonyms (`git`, `vcs`, `version-control`) with nothing to
make the drift visible, so reusing an existing tag over a new one is the
only thing keeping the vocabulary coherent.

## What this file does not cover

This file states conventions, not authoring standards. How to write a
skill well — the frontmatter contract, description criteria, review
checkpoints — lives with the skill that enforces it, not here: see
`skills/create-skill/SKILL.md`. The equivalent standard for an agent —
the reconciled frontmatter contract, the system-prompt requirements for a
fresh-context subprocess, and the trigger and cold-run checks — lives at
`skills/create-agent/SKILL.md`.

## Three categories, not two

- **Library assets** — `skills/`, `agents/`, and `rules/`. What ships in
  the plugin and is the library's substance.
- **Shipped tooling** — `scripts/`. Executables that ship with the library
  and are runnable directly, by a consumer, a shell, or an agent of any
  harness — without any harness-specific loading mechanism. `scripts/`
  conventionally names a repository's *internal* helpers in most projects;
  here it does not. Its contents ship and are meant to be run by
  consumers, exactly like `skills/` and `agents/` — they are simply not
  discovered by description the way those are, and carry no asset
  frontmatter. Belongs there: a deterministic operation with exactly one
  correct outcome, meant to be run directly rather than orchestrated by a
  model. Code needed by only one skill, that no other consumer invokes,
  stays inside that skill's own `scripts/` directory instead.
- **Repository tooling** — `.claude/`. This repository's own working
  configuration — the OpenSpec skills and commands used to develop this
  repository — and tooling meant only for working *on* this repository,
  never on a consuming project. Not part of the library, never shipped as
  a library asset.

An asset meant to ship belongs in `skills/`, `agents/`, `rules/`, or
`scripts/` — never under `.claude/`, which a project installing this
plugin never sees.

`tests/` holds a dependency-free harness exercising `scripts/`. Running
the tests may require the external commands that tooling itself drives
(`git`, `openspec`); *using* the library never requires anything
installed. `tests/` introduces no dependency manifest and no build step —
the library remains usable from a clone with nothing installed.
