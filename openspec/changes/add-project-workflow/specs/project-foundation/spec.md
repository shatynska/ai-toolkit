## Purpose

Defines what establishing a new project's foundation must cover and how completion is judged: the decisions that must be settled before normal development begins, coverage expressed as named artifact sections rather than as conversation order, persistence that survives a conversation spanning sessions, and the one exemption from the workflow's own test-authoring rule.

## ADDED Requirements

### Requirement: The foundation checklist is a portable fragment, not a skill's private content

The decisions a foundation must settle SHALL be recorded in a rule fragment readable independently of any agent harness. A skill MAY wrap that fragment to supply conversation quality, but SHALL NOT be the only place the checklist exists.

The fragment SHALL NOT be inlined into a project's conventions file. It describes a one-time procedure rather than a standing constraint, and inlining it would leave permanent instructions for work already finished.

#### Scenario: A non-skill-aware tool follows the same procedure

- **WHEN** a developer or agent without a skills primitive begins establishing a project's foundation
- **THEN** the checklist is readable as a document, and the decisions it requires are the same ones a skill-driven session would cover

#### Scenario: The checklist does not accumulate in projects

- **WHEN** a project has completed its foundation
- **THEN** its conventions file carries the standing workflow rules but not the foundation checklist

### Requirement: The foundation covers a fixed set of decisions including non-goals

Foundation discovery SHALL cover, at minimum: what the project is, what problem it solves, its intended audience, its initial scope, **its non-goals**, its language and framework, its architecture, its testing strategy, and its development tooling.

Non-goals SHALL be a first-class decision rather than an aspect of scope. A scope statement records what is intended; only an explicit non-goal records what was considered and rejected, which is what prevents the same question being reopened repeatedly and what constrains later scope growth.

The development tooling decision SHALL carry one deliverable beyond a statement of intent: extending the project's ignore file with the exclusions its chosen stack requires. Initialization deliberately creates an ignore file carrying no stack assumption, because it cannot know the language. Foundation is the first point at which the language is known, so this is where that gap closes — and naming it here is what makes it closed rather than merely handed off.

#### Scenario: Non-goals are recorded even when scope is clear

- **WHEN** a project's scope has been stated
- **THEN** its non-goals are still recorded separately, rather than being treated as covered by the scope statement

#### Scenario: Stack-specific ignore entries are a foundation deliverable

- **WHEN** the project's language and framework have been decided
- **THEN** extending the ignore file with that stack's exclusions is recorded as a task of the foundation change, rather than left to be noticed later

### Requirement: Decisions are classified by whether they can be proposed

Foundation discovery SHALL distinguish decisions that must be supplied by the person from decisions that may be proposed with reasoning and confirmed.

Project identity, problem, audience, scope, and non-goals SHALL be supplied — they are not derivable from anything available. Language, framework, architecture, testing strategy, and development tooling MAY be proposed with the reasoning stated, for confirmation or rejection.

Discovery SHALL NOT present the checklist as a fixed sequence of questions. Coverage is the obligation; interrogation order is not, and a mechanical sequence produces worse discovery than a conversation that reaches the same coverage.

#### Scenario: A technical decision is proposed rather than asked

- **WHEN** the project's identity, problem, and scope are established and a testing strategy has not been discussed
- **THEN** a strategy is proposed with the reasoning that led to it, for confirmation or rejection, rather than posed as an open question

#### Scenario: An identity decision is not invented

- **WHEN** the project's non-goals have not been stated
- **THEN** they are elicited rather than inferred, because nothing available makes them derivable

### Requirement: Coverage is verifiable in the artifact, not only in the conversation

The foundation change's design artifact SHALL carry this fixed set of named sections, covering every decision the checklist requires:

```
## Identity
   - What it is
   - Problem it solves
   - Intended audience
## Scope
## Non-Goals
## Technology            language and framework
## Architecture
## Testing Strategy
## Development Tooling   including stack-specific ignore entries
```

The mapping from decision to section is fixed here rather than chosen per project, and is stated in this requirement rather than in a design document, because the requirement outlives the change that introduces it and an obligation deferred to an archived file cannot be checked afterwards.

A section covering more than one decision SHALL carry a named item per decision it absorbs — as `Identity` does — so that an unanswered decision remains individually visible rather than being concealed by a filled section covering several.

An unfilled section, or a filled section with an unanswered named item, SHALL be an unmet gate. A gate that exists only inside a model's conversation is not a gate, because nothing outside that conversation can check it.

#### Scenario: A skipped decision is detectable after the fact

- **WHEN** a foundation change is inspected by someone who was not present for the conversation
- **THEN** each required decision is either answered under its named section or item, or visibly absent, without the conversation being available

#### Scenario: A decision absorbed into a shared section stays visible

- **WHEN** one section covers several decisions and only some of them were settled
- **THEN** the unsettled ones are individually identifiable as unanswered, rather than the section reading as complete because its other items are filled

### Requirement: Decisions are persisted as they settle

Each decision SHALL be written into the change's artifacts as it settles, rather than accumulated and written once at the end.

A foundation conversation may span sessions. The workflow's own rule against relying on conversation context for what an artifact could hold applies to the conversation that establishes the project as much as to any later one.

#### Scenario: A conversation resumed in a new session loses nothing

- **WHEN** a foundation conversation is interrupted after several decisions are settled and resumed later with no conversation history
- **THEN** the settled decisions are readable from the change's artifacts, and only the unsettled ones remain open

### Requirement: Change authoring is delegated, not reimplemented

Foundation discovery SHALL produce its proposal, design, and task artifacts through the project's existing change-authoring mechanism rather than through a second implementation of artifact generation.

Its own contribution is coverage, classification, and a stop condition — not a competing way to write a change.

#### Scenario: Artifacts are produced by the existing mechanism

- **WHEN** foundation decisions are sufficiently settled to write the change
- **THEN** the established change-authoring path produces the artifacts, and foundation discovery supplies their content rather than generating them independently

### Requirement: The foundation change is exempt from test authoring

The workflow requires tests be derived from a change's specifications before implementation. The foundation change SHALL be exempt, and the exemption SHALL be stated explicitly rather than left to inference.

Test authoring requires the project's test command and test-path locations as inputs. Those are outputs of the foundation change, not inputs to it — foundation is the one change in a project's life for which test authoring is structurally impossible. Left unstated, an agent reaching this point either stalls on a missing input or produces a placeholder suite that asserts nothing.

#### Scenario: Test authoring is skipped for a stated reason

- **WHEN** the foundation change reaches the point where test authoring would normally run
- **THEN** the exemption is applied and its reason stated, rather than the step being attempted against an undefined test command or silently omitted

#### Scenario: The exemption does not extend past foundation

- **WHEN** the first change after foundation is prepared for implementation
- **THEN** test authoring applies normally, because the test command and locations the exemption depended on are now defined

### Requirement: Foundation completes at archival and remains complete

The foundation SHALL be complete when every required decision section is filled and the change is archived. Archival SHALL be the signal that a project has moved from establishment to normal development.

Foundation SHALL be treated as a historical change rather than as an invariant to be maintained. Nothing SHALL check whether a project still matches its foundation: a later architectural or tooling shift is a new change, not a foundation violation. Continuous reconciliation of a project against its foundation would be the workflow engine this design excludes.

#### Scenario: Lifecycle position is derived, not stored

- **WHEN** it must be determined whether a project has completed its foundation
- **THEN** the presence of the archived foundation change answers it, with no separate state file recording the project's phase

#### Scenario: A later architectural change is not a violation

- **WHEN** a project changes its architecture long after its foundation was archived
- **THEN** the change proceeds through the normal workflow, and the archived foundation is neither invalidated nor required to be updated
