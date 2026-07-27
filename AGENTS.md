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

`rules/` is the exception: there is no rules primitive for a plugin to
carry, so a fragment is consumed by an `@` import naming its path in this
repository (e.g. `@~/projects/ai-toolkit/rules/<rule-name>.md`) from a
project's `CLAUDE.md` or `AGENTS.md`. This needs no tooling, but the path is
machine-local — it resolves only where this repository is checked out at
that path.

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
`skills/create-skill/SKILL.md`.

## The library vs. this repository's own tooling

`skills/`, `agents/`, and `rules/` are the library: what ships in the
plugin. `.claude/` holds this repository's own tooling — the OpenSpec
skills and commands used to work on this repository — and is not part of
the library. An asset meant to ship belongs in `skills/`, `agents/`, or
`rules/`, not under `.claude/`.
