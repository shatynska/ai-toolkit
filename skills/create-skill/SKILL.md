---
name: create-skill
description: This skill should be used when the user wants to "create a skill", "add a skill", "write a new skill", "draft a SKILL.md", "turn this into a skill", or asks how to author a skill for the ai-toolkit library. It walks the frontmatter contract, the description standard that counters under-triggering, structure selection, the required human checkpoints, and the trigger check that must pass before a new skill is reported finished. It authors only into this repository's own skills/ directory, never into the project it happens to be invoked from. It is not for general "help me build something" requests, and it is not the authoring standard for agents (agents/) or rules (rules/) — see AGENTS.md for those.
metadata:
  tags: [authoring, hitl]
---

# create-skill

This skill produces skills for the `ai-toolkit` library and holds them to a fixed
standard. Two facts drive everything below: the `description` field is the *only*
signal used to decide whether a skill loads, and the observed failure mode is
under-triggering — a skill stays silent more often than it fires wrongly. A
reviewed description is still an unproven one, so this workflow does not call a
skill finished until it has been observed to trigger.

This skill always writes into **this repository's** `skills/` directory, never
into the project it was invoked from. If invoked from a project that installed
`ai-toolkit` as a plugin, say so explicitly and confirm that authoring into the
toolkit repository is what's wanted before continuing — every check below (name
collisions, tag vocabulary, disambiguation) is a statement about this library and
means nothing run against an unrelated project.

## Before anything else: is a skill the right artifact?

A meta-skill that always produces a skill is a template with extra steps. Before
opening the Intent checkpoint, check whether the need is better served by
something else:

- **A deterministic sequence invoked by name** → a slash command, not a skill.
- **Work that needs its own context or isolation** → a subagent.
- **A short standing instruction** ("always do X", "never do Y") → a rule
  fragment in `rules/`, or a line in project memory.
- **Genuinely needs description-triggered, on-demand procedural knowledge** → a
  skill. Proceed below.

Recommending the alternative and stopping is a valid, complete outcome. It is
also the outcome that keeps the library from filling with skills that never
fire because they never needed to exist.

## Checkpoint 1 — Intent (mandatory)

Confirm all of the following before any file is written:

- **Name** — kebab-case, becomes both the directory name and the invocation
  name (see *Directory name and invocation*, below).
- **Name availability** — list the directories under `skills/` in this
  repository and confirm the proposed name doesn't collide.
- **Tags** — list the `metadata.tags` already in use across `skills/*/SKILL.md`
  and choose from that vocabulary; a new tag needs a stated reason (see
  *Choosing tags*).
- **Purpose** — one or two sentences.
- **Triggering conditions** — the phrasings a user would plausibly type.
- **Target** — confirm this authors into `ai-toolkit`'s own `skills/`. If
  invoked from elsewhere, state that plainly and get confirmation.

## Checkpoint 2 — Shape (conditional)

Raise this only when the structure isn't obviously a single flat file: the
instructions are long enough to need splitting, the skill needs bundled
`scripts/`, `references/`, or `assets/`, or it wraps a single external command
(which needs a scoped `allowed-tools`). See *Choosing structure*, below.

When a skill plainly fits one short document and wraps no single command, skip
this checkpoint — asking is friction on a question that isn't in doubt, and a
workflow that feels heavy gets bypassed.

## Checkpoint 3 — Draft (mandatory)

Present the proposed frontmatter (`name`, `description`, `metadata.tags`, any
`allowed-tools`) and a body outline — section headers, not full prose — for
approval. **No file is written before this is approved.** A rejected draft
should cost a message, not a file deletion; apply requested revisions to the
draft and re-present it.

## Writing the frontmatter

`name` and `description` are the only required fields.

The schema-defined top-level fields, as verified on 2026-07-27 against the
validation script bundled with the official `skill-creator` plugin (not this
skill — see `skill-creator/skills/skill-creator/scripts/quick_validate.py` in
that plugin's own installation), are exactly: `name`, `description`, `license`,
`allowed-tools`, `compatibility`, and `metadata`. That script enforces this
list — any other top-level key fails validation. Notably, `version` is **not**
among them, despite appearing in some
hand-written examples in the wild; treat it, and anything else outside this
list, as belonging under `metadata` rather than at the top level. Because this
list is sourced from code that ships outside this repository, treat it as a
dated snapshot, not permanent authority — re-verify against the installed
`skill-creator` plugin if it's been a while.

The same source gives concrete constraints worth checking directly:

| Field | Constraint |
|---|---|
| `name` | kebab-case (`^[a-z0-9-]+$`), no leading/trailing/double hyphens, ≤64 characters |
| `description` | ≤1024 characters, no angle brackets (`<`, `>`) |
| `compatibility` | string, ≤500 characters |

`allowed-tools` is omitted by default. Declare it, scoped to that command only,
when — and only when — the skill is a thin wrapper around a single external
command; an open-ended skill blocked by a stray `allowed-tools` fails in ways
that surface far from the cause.

Fields the schema doesn't define go under `metadata` rather than becoming new
top-level keys.

### Directory name and invocation

`AGENTS.md` explains why the directory name is the invocation name and why a
mismatch resolves silently. This workflow's job is narrower: check the match
before Draft is approved and treat a mismatch as a defect to fix now, since
nothing later in the pipeline will catch it.

## Writing the description

The description is written to counter under-triggering, not to sound measured:

1. **Third person.** `This skill should be used when…`, never `Use this skill
   when you…`.
2. **State the action and the trigger conditions.** "Helps with skills" is
   rejected — no concrete action, no condition under which it fires.
3. **Deliberately over-eager coverage.** Name adjacent phrasings a user might
   actually type, not only the canonical term. If the canonical trigger is
   "create a skill", also name "add a skill", "write a new skill", "turn this
   into a skill".
4. **Library-wide disambiguation.** State what distinguishes this skill from
   every other skill in the library — not just the obviously related ones. The
   layout is flat and there is no index, so every skill competes with every
   other skill for the same trigger decision.

| Bad | Why | Better |
|---|---|---|
| `Helps with skills.` | No action, no trigger | States the action and names concrete trigger phrases |
| `Use this skill when you want to create a skill.` | Second person | `This skill should be used when the user wants to "create a skill"…` |
| `This skill should be used when the user wants to create a skill.` | Only the canonical phrasing; nothing distinguishes it from a hypothetical `skill-creator`-style skill | Names adjacent phrasings and states the library-specific scope that sets it apart |

Breadth and disambiguation pull against each other: breadth is about
*phrasings* of the same job, disambiguation is about *the job itself*. The
trigger check below is what proves the line was drawn in the right place.

## Choosing structure

Default to a single flat `SKILL.md`. Split only when the document stops being
readable in one pass, following the convention from
`plugin-dev/skills/skill-development` (referenced here rather than restated):

- `references/` — material loaded into context on demand.
- `scripts/` — code that must run deterministically. Bundling code here is
  permitted (this repository's own no-executable-code rule governs repository
  tooling, not a skill's bundled resources) but not yet used by anything in
  this library — reach for it only when the work is genuinely deterministic.
- `assets/` — files that end up in the skill's output, not read into context.

Loading budget: metadata is always resident, the body stays under roughly five
thousand words, and resources are read only when needed.

*This document applies that rule to itself: it stays flat because it is
comfortably readable in one pass.*

## Choosing tags

Before proposing a new tag, list the `metadata.tags` already used across
`skills/*/SKILL.md` and prefer an existing one over a synonym. A new tag needs
a stated reason. Tags are lowercase kebab-case.

## Where the skill is written

Always `skills/<name>/SKILL.md` inside this repository — never inside the
project the workflow happens to be invoked from, and never a project-level or
personal skills directory resolved as a fallback. Name uniqueness, the tag
vocabulary, and disambiguation are all checks against *this* library; run
anywhere else they pass without meaning anything.

## After writing: validate

Verify and report, explicitly — failures are reported, not silently patched:

- Frontmatter parses as valid YAML.
- `name` matches the directory name.
- The file sits at `skills/<name>/SKILL.md` with no directory between `skills/`
  and the skill's own directory.
- Declared tags are lowercase kebab-case.
- The description states both the action and the triggering conditions.
- Every bundled resource the body references actually exists.

## After writing: the trigger check

A reviewed description is still an untested one. Run two prompts against the
new skill:

- **Positive** — phrased the way a user plausibly would. It must activate the
  skill.
- **Negative** — an adjacent prompt just outside the skill's scope, chosen so
  it could plausibly misfire, not an unrelated prompt that proves nothing. It
  must not activate the skill.

**How the check runs.** Put each prompt to a fresh-context evaluator — an
agent given the candidate prompt and the `name` and `description` of every
skill currently in the library (read them from `skills/*/SKILL.md`), and
nothing from the conversation the skill was authored in. Ask which skill, if
any, it would invoke. A check run inside the authoring context is not
evidence: the skill is already sitting in that context, so it "fires" whether
or not the description is any good — the exact failure this step exists to
catch.

Report both outcomes. A positive-prompt failure means the description is too
narrow — widen it and re-run. A negative-prompt failure means it's too broad —
narrow it and re-run. A skill is not reported complete until both hold.

## When two prompts aren't enough

This is a floor, not a ceiling: it reliably catches "never fires" and "fires
on everything," and nothing more rigorous than that. For a skill that needs
quantitative trigger rates or variance analysis across many prompts, point to
the scripted eval loop in the official `skill-creator` plugin instead of
reproducing it here.

## Recorded trigger check

The check this skill's own authoring ran against itself, kept here so a later
edit to the description can be re-verified against the same pair rather than
inventing a new one from scratch:

- **Positive** — "I want to add a new skill to the ai-toolkit repo that helps
  write good commit messages. Can you walk me through creating it?" →
  activated `create-skill`.
- **Negative** — "Can you write me a subagent that reviews my commit messages
  for clarity before I push?" → activated nothing, correctly recognizing the
  request is for `agents/`, not `skills/`.

Both held on the first pass, run 2026-07-27.

## Also worth reading

`plugin-dev/skills/skill-development` covers the broader authoring
conventions this skill doesn't restate — body writing style, progressive
disclosure in practice, and plugin-specific skill discovery.
