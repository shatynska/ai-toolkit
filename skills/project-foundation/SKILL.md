---
name: project-foundation
description: >
  This skill should be used when the user wants to establish a new
  project's foundation — its identity, problem, audience, scope,
  non-goals, technology, architecture, testing strategy, and development
  tooling — "let's figure out what this project actually is", "establish
  this project's foundation", "run project-foundation", "define the scope
  and non-goals for this new project", "what should our testing strategy
  be". It wraps the checklist in `rules/project-foundation.md`
  conversationally: elicits decisions that must be supplied, proposes ones
  that may be proposed with reasoning, and writes each into a
  `project-foundation` change's `design.md` as it settles, delegating
  artifact generation to `openspec-propose`. Use only after a project has
  been initialized (see `project-init`, not invoked here). Not for
  authoring library assets (`create-skill`, `create-agent`), and not for a
  change unrelated
  to a project's own foundation.
metadata:
  tags: [project-lifecycle, openspec]
---

# project-foundation

The conversational wrapper over `rules/project-foundation.md`. That
fragment carries the checklist and the reasoning; this skill carries the
conversation and the gate. Read the fragment before starting — it is the
source of the nine decisions and their classification, not restated here.

## Converse, don't interrogate

Identity, problem, audience, scope, and non-goals must come from the user —
nothing available makes them derivable. Once those are established, propose
the technical decisions (language, framework, architecture, testing
strategy, development tooling) with your reasoning, for confirmation or
redirection — that is faster than asking about them, and it is not a
substitute for coverage.

Do not fire the nine decisions as a fixed sequence of questions. Coverage is
the obligation; interrogation order is not.

## Persist as you go

Create the `project-foundation` change early — dispatch or use
`openspec-propose` for the mechanics — and write each decision into its
`design.md` as it settles, rather than holding everything in conversation
until a final write. The conversation may span sessions; a decision that
exists only in this conversation is invisible to whoever resumes it.

`design.md` carries this fixed section layout, exactly as
`rules/project-foundation.md` specifies:

```
## Identity
   - What it is
   - Problem it solves
   - Intended audience
## Scope
## Non-Goals
## Technology
## Architecture
## Testing Strategy
## Development Tooling
```

An unfilled section, or an unfilled item within `Identity`, is a visible
gap — that is what makes coverage checkable in the artifact rather than
only inside this conversation.

## The development-tooling decision has a concrete deliverable

Once the stack is known, extend the project's `.gitignore` with that
stack's exclusions. `project-init` deliberately created a `.gitignore` with
no stack assumption; this is the first point the stack is known, and this
is where that gap closes.

## Test authoring does not apply to this change

State this explicitly when the point would normally arrive: this change's
test command and test-path glob don't exist yet — they're among its own
outputs — so deriving tests from its specification before implementing it
is structurally impossible. This exemption applies to the foundation
change alone; the next change after it has a defined test command and
test-path glob, and test authoring applies normally.

## Completion

Foundation is complete when every section is filled and the change is
archived. That archival is the signal — nothing else needs to track the
transition into normal development, and nothing afterward should try to
reconcile the project against it. A later architectural or tooling shift
is simply a new change.

## Trigger check fixtures

- **Positive** — "This project already exists — help me figure out what it
  actually is, its scope, and what tech stack makes sense." → expected
  routing: `project-foundation`.
- **Negative** — "I'm starting a brand new project, can you set it up with
  git, openspec, and the usual conventions?" → expected routing:
  `project-init`.
