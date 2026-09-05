---
kind: procedural-checklist
---

# Establishing a project's foundation

This is a one-time procedure for a new project, run once before normal development begins. It is not a standing rule and is never inlined into a project's conventions file — read it on demand, when establishing a foundation, not as an ongoing constraint.

## What must be settled

Nine decisions, falling into two groups by how they may be reached.

**Supplied — not derivable from anything available, and must come from the person establishing the project:**

- **Identity**: what the project is.
- **Problem**: what problem it solves.
- **Audience**: who or what it is intended for.
- **Scope**: its initial scope.
- **Non-goals**: what is deliberately out of scope. This is not the inverse of scope stated for form's sake — it is a first-class decision recording what was considered and rejected, not merely what was not mentioned. Its absence is what lets scope creep back in six weeks later; do not skip it because scope already sounds clear.

**Proposable — may be proposed with reasoning, for confirmation or rejection, once identity and scope are established:**

- **Technology**: language and framework.
- **Architecture**: the shape of the system.
- **Testing strategy**: how the project's behavior will be verified.
- **Development tooling**: linting, formatting, build tooling, and any other development-time tooling the project needs. This decision carries one concrete deliverable beyond a statement of intent: once the stack is known, extend the project's `.gitignore` with that stack's exclusions. Initialization deliberately created a `.gitignore` with no stack assumption, because it could not know the language yet — this is the first point the language is known, and closing that gap here is what makes it closed rather than merely handed off.

## How to cover them

Coverage is the obligation; interrogation order is not. Do not fire these nine items as a sequence of questions — that produces worse discovery than a conversation that reaches the same coverage by a natural route. Identity, problem, audience, scope, and non-goals must be elicited, since nothing available makes them derivable. The proposable four are faster to propose, with reasoning, than to ask about; propose and let the person confirm or redirect.

## Where the answers go

The foundation is a normal change, authored through the project's existing change-authoring mechanism — this procedure does not implement a competing way to produce a proposal, design, or task list. Its own contribution is coverage, classification, and knowing when there is enough to write.

Write each decision into the change's `design.md` as it settles, rather than holding it in conversation until a final write. A foundation conversation can span sessions, and a decision that exists only in conversation is invisible to whoever resumes it.

`design.md` carries a fixed set of named sections, one per decision (three of them — problem, audience, and identity itself — grouped under a single `Identity` heading, each as its own named item so an unanswered one stays individually visible):

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

An unfilled section, or an unfilled item within one, is a visible gap — that is what makes coverage checkable in the artifact rather than only inside the conversation that produced it.

## Decisions also reach README.md and AGENTS.md

`design.md` is the canonical, checkable record, but it is archived with the change once foundation completes — discoverable only by someone who goes looking inside OpenSpec's archive, not what a human landing on the project or a fresh agent session reads by default. As each decision settles, write it a second time into whichever of the project's `README.md` or `AGENTS.md` the decision belongs in, in addition to — never instead of — the `design.md` write.

The split is not by audience. Do not route a decision to `AGENTS.md` because an agent might someday want it, or to `README.md` because a human might read it. Route it by whether a future agent turn needs the fact without being told to go look for it: only `AGENTS.md` reaches an agent that way, since this workflow's own bootstrap step and this fragment's sibling change both established that Claude Code auto-loads `AGENTS.md` (via a `CLAUDE.md` import) every session, while `README.md` is never auto-loaded at all.

Under that test:

- **`README.md`** gets identity, problem, audience, scope, non-goals, technology, and architecture — decisions that inform without needing to shape a future agent turn automatically. Create the file if it is absent; otherwise append a section. Delimit it with `<!-- ai-toolkit:project-foundation -->` / `<!-- /ai-toolkit:project-foundation -->`, unversioned — this content is never regenerated from a toolkit fragment, so there is nothing to stamp a version against, and a human is free to edit it afterward. Use these headings, in order: `## What it is`, `## Problem`, `## Audience`, `## Scope`, `## Non-Goals`, `## Technology`, `## Architecture`. As each decision settles, rewrite the content between the markers rather than duplicating it.
- **`AGENTS.md`** gets testing strategy and development tooling only — the two decisions a later change's test-authoring step actually depends on as inputs (the test command, the test-path glob), and which reach an agent automatically only through this file. Append a second, separate section — outside the existing `<!-- ai-toolkit:development-workflow vN -->` block if one is present, never inside it, since that block is regenerated wholesale on update and would silently destroy project-owned content living inside it. Delimit it the same way, unversioned, with headings `## Testing Strategy` and `## Development Tooling`, placed after the workflow block where one exists. `AGENTS.md` is presupposed to already exist — this workflow's own initialization step always creates it before foundation can run — so there is no create-if-absent case to handle here, unlike `README.md`.

## The foundation change is exempt from test authoring

The workflow's rule that tests be derived from a change's specification before implementation does not apply to the foundation change. Test authoring needs the project's test command and test-path locations as inputs — and those are outputs of foundation, not inputs to it. Foundation is the one change in a project's life where deriving tests before implementation is structurally impossible, since the thing that would produce the inputs is the change itself.

State this exemption explicitly when foundation reaches the point where test authoring would normally run, rather than leaving it to be discovered by an agent stalling on an undefined test command, or invented around by writing a placeholder suite that asserts nothing. The exemption applies to this one change only — the very next change after foundation has a defined test command and test-path glob, and test authoring applies to it normally.

## Foundation is complete when archived, and stays complete

Foundation is done when every section above is filled and the change is archived. Archival is the signal that the project has moved from establishment into normal development — nothing else needs to track that transition.

Foundation is a historical record, not an invariant to maintain. Once archived, it stays complete regardless of what happens afterward. A later architectural change, a stack swap, a testing-strategy revision — each is simply a new change going through the normal workflow. None of them invalidates the foundation or requires it to be revisited or updated.
