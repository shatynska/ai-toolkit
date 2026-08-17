---
name: project-init
description: >
  This skill should be used when the user wants to initialize a new project
  into this repository's development workflow, or adopt that workflow in an
  existing project — "set up a new project", "initialize this repo",
  "bootstrap this project for spec-driven development", "adopt this
  workflow here", "run project-init". It resolves the ai-toolkit toolkit
  root, invokes the deterministic `scripts/project-init` tool, relays its
  report verbatim, offers an initial commit, and names foundation discovery
  as the next step without starting it. It performs only deterministic
  setup — Git, OpenSpec, a managed workflow block in `AGENTS.md` — and
  makes no judgment about the project's identity, scope, or architecture;
  for those, see `project-foundation`, which it never invokes itself. Not
  for authoring library assets (`create-skill`, `create-agent`) and not for
  proposing an OpenSpec change once a project already has a foundation
  (`openspec-explore`, `openspec-propose`).
metadata:
  tags: [project-lifecycle, openspec]
---

# project-init

A thin wrapper around `scripts/project-init`. Every decision belongs to
that script; this skill's job is to find it, run it, relay what it says,
and stop.

## 1. Resolve the toolkit root

Try, in order, stopping at the first that resolves:

1. `$AI_TOOLKIT_ROOT`
2. `$CLAUDE_PLUGIN_ROOT`
3. the machine-local default, `~/projects/ai-toolkit`

If none resolves, report yourself blocked — name what you looked for — and
stop. Do not fall back to running `git init` or `openspec init` directly,
and do not write the workflow rules from memory. An improvised equivalent
produces a project initialized differently from every other one while
looking like it succeeded, which is the exact failure this workflow exists
to prevent.

## 2. Invoke the tool

Run it through its interpreter, never as a bare path:

```
bash "<resolved-root>/scripts/project-init" [--tools <value>] [TARGET_DIR]
```

Pass through whatever the user specified (a `--tools` value, a target
directory other than the current one). Do not parse or second-guess the
tool's internal logic — it owns every decision about what gets created,
skipped, or reported.

## 3. Relay the report

Show the user what the tool printed — target directory, each concern and
its outcome, the terminal outcome, and the next step. Do not summarize away
detail the report considered worth stating (an import line the user needs
to add, a version mismatch in an existing managed block, files a delegated
command wrote).

If the tool reported `BLOCKED` or `ERROR`, stop here. Explain the reason
from the report; do not attempt the failed step yourself.

## 4. Offer a commit, on `SUCCESS` only

Offer to create an initial commit covering what the tool just did. Wait for
confirmation — never commit without it, per this workflow's own rule that
commits are suggested, not automatic.

## 5. Name the next step; never take it

The tool's report already names the next step. Repeat it back and stop
there:

- **New project** — name foundation discovery (`project-foundation`) as
  available. Do not begin that conversation yourself; starting an
  open-ended discovery conversation decides that this is the right moment
  to spend an hour on it, and that decision belongs to the user.
- **Adoption** — the report already states that foundation discovery is
  available if the project's decisions should be recorded retroactively.
  Relay that; nothing further is required.

## Trigger check fixtures

- **Positive** — "I'm starting a brand new project, can you set it up with
  git, openspec, and the usual conventions?" → expected routing:
  `project-init`.
- **Negative** — "This project already exists — help me figure out what it
  actually is, its scope, and what tech stack makes sense." → expected
  routing: `project-foundation`.
