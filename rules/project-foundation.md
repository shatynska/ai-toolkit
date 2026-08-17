---
kind: procedural-checklist
---

# Establishing a project's foundation

This is a one-time procedure for a new project, run once before normal
development begins. It is not a standing rule and is never inlined into a
project's conventions file — read it on demand, when establishing a
foundation, not as an ongoing constraint.

## What must be settled

Nine decisions, falling into two groups by how they may be reached.

**Supplied — not derivable from anything available, and must come from the
person establishing the project:**

- **Identity**: what the project is.
- **Problem**: what problem it solves.
- **Audience**: who or what it is intended for.
- **Scope**: its initial scope.
- **Non-goals**: what is deliberately out of scope. This is not the inverse
  of scope stated for form's sake — it is a first-class decision recording
  what was considered and rejected, not merely what was not mentioned. Its
  absence is what lets scope creep back in six weeks later; do not skip it
  because scope already sounds clear.

**Proposable — may be proposed with reasoning, for confirmation or
rejection, once identity and scope are established:**

- **Technology**: language and framework.
- **Architecture**: the shape of the system.
- **Testing strategy**: how the project's behavior will be verified.
- **Development tooling**: linting, formatting, build tooling, and any other
  development-time tooling the project needs. This decision carries one
  concrete deliverable beyond a statement of intent: once the stack is
  known, extend the project's `.gitignore` with that stack's exclusions.
  Initialization deliberately created a `.gitignore` with no stack
  assumption, because it could not know the language yet — this is the
  first point the language is known, and closing that gap here is what
  makes it closed rather than merely handed off.

## How to cover them

Coverage is the obligation; interrogation order is not. Do not fire these
nine items as a sequence of questions — that produces worse discovery than
a conversation that reaches the same coverage by a natural route. Identity,
problem, audience, scope, and non-goals must be elicited, since nothing
available makes them derivable. The proposable four are faster to propose,
with reasoning, than to ask about; propose and let the person confirm or
redirect.

## Where the answers go

The foundation is a normal change, authored through the project's existing
change-authoring mechanism — this procedure does not implement a competing
way to produce a proposal, design, or task list. Its own contribution is
coverage, classification, and knowing when there is enough to write.

Write each decision into the change's `design.md` as it settles, rather
than holding it in conversation until a final write. A foundation
conversation can span sessions, and a decision that exists only in
conversation is invisible to whoever resumes it.

`design.md` carries a fixed set of named sections, one per decision (three
of them — problem, audience, and identity itself — grouped under a single
`Identity` heading, each as its own named item so an unanswered one stays
individually visible):

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

An unfilled section, or an unfilled item within one, is a visible gap — that
is what makes coverage checkable in the artifact rather than only inside
the conversation that produced it.

## The foundation change is exempt from test authoring

The workflow's rule that tests be derived from a change's specification
before implementation does not apply to the foundation change. Test
authoring needs the project's test command and test-path locations as
inputs — and those are outputs of foundation, not inputs to it. Foundation
is the one change in a project's life where deriving tests before
implementation is structurally impossible, since the thing that would
produce the inputs is the change itself.

State this exemption explicitly when foundation reaches the point where
test authoring would normally run, rather than leaving it to be discovered
by an agent stalling on an undefined test command, or invented around by
writing a placeholder suite that asserts nothing. The exemption applies to
this one change only — the very next change after foundation has a defined
test command and test-path glob, and test authoring applies to it normally.

## Foundation is complete when archived, and stays complete

Foundation is done when every section above is filled and the change is
archived. Archival is the signal that the project has moved from
establishment into normal development — nothing else needs to track that
transition.

Foundation is a historical record, not an invariant to maintain. Once
archived, it stays complete regardless of what happens afterward. A later
architectural change, a stack swap, a testing-strategy revision — each is
simply a new change going through the normal workflow. None of them
invalidates the foundation or requires it to be revisited or updated.
