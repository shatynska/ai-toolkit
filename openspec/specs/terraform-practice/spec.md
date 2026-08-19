# terraform-practice Specification

## Purpose

Defines what the library's Terraform guidance asserts and where it stops: provider-neutral scope, the authoring and run-discipline halves it must cover, the human checkpoint before an apply, deference to a consuming project's own conventions, the boundary that keeps CI pipeline shape out of it, and the preference for recorded traps over tutorial content.

## Requirements

### Requirement: Guidance Is Provider-Neutral

The skill SHALL state Terraform practice in terms that hold for any provider. It SHALL NOT take provider-specific resource types, credential models, or console workflows as its subject matter, and SHALL NOT encode any single project's backend, region, sizing, or naming decisions.

Where provider-specific behaviour determines the answer, the skill SHALL direct the reader to the consuming project's own conventions rather than supplying one provider's specifics.

#### Scenario: Provider specifics are deferred rather than answered

- **WHEN** a question turns on a particular cloud's server types, regions, or protection attributes
- **THEN** the skill SHALL defer to the consuming project's conventions instead of answering for one provider

#### Scenario: Excluded content classes are absent from the body

- **WHEN** the body is checked for the content classes this requirement excludes — a named provider's resource types as subject matter, a provider's credential model, a console workflow, or a single project's backend, region, sizing, or naming choice
- **THEN** none of them SHALL be present

### Requirement: Both Authoring and Run Discipline Are Covered

The skill SHALL cover writing Terraform — module and environment boundaries, the file split within a module, variable design, and `variable validation` — and running it — planning, applying, state operations, and drift.

Neither half SHALL be deferred to a future asset.

#### Scenario: An authoring question is answered

- **WHEN** the user asks how to structure a module or what belongs in a caller rather than a module
- **THEN** the skill SHALL answer without directing them to another asset

#### Scenario: A run question is answered

- **WHEN** the user asks what a plan's output means or how to recover from state that no longer matches reality
- **THEN** the skill SHALL answer without directing them to another asset

### Requirement: The Plan Is a Human Checkpoint

Before any apply, the skill SHALL require that the plan diff be read and its blast radius stated: which resources are created, updated, replaced, and destroyed. Replacement SHALL be called out explicitly as destruction followed by creation rather than as a form of update.

The skill SHALL NOT present apply as a step that automatically follows plan.

Where a plan contains any replace or destroy action, the skill SHALL require explicit user confirmation before the apply proceeds. Stating the blast radius and continuing within the same turn SHALL NOT satisfy this. Where a plan contains only create and update actions, the blast radius SHALL still be stated, and the apply MAY proceed without a separate confirmation only where it consumes the saved plan that classification was made from. Where the apply would re-plan rather than consume that plan, the classification cannot be relied on — a replace or destroy can appear between the read and the run — and the confirmation rule applies regardless.

#### Scenario: Blast radius is stated before applying

- **WHEN** an agent working under this skill is about to run an apply
- **THEN** it SHALL first report the plan's counts and name every resource to be replaced or destroyed

#### Scenario: A replacement is surfaced, not absorbed

- **WHEN** a plan contains a replace action on a resource carrying data
- **THEN** the skill SHALL require that the destruction be surfaced and explicitly confirmed by the user before the apply runs

### Requirement: Consuming Project Conventions Take Precedence

The skill SHALL declare itself a floor rather than an authority: a consuming project's `AGENTS.md`, `CLAUDE.md`, and design documents override it wherever they conflict.

It SHALL instruct that those be read before Terraform work begins in an unfamiliar repository, and SHALL require that a conflict between its own guidance and a project convention be reported rather than silently resolved.

Where a question turns on a provider specific or a project decision and the project records no convention at all, the skill SHALL state that the answer is project- or provider-specific and ask, rather than supplying one from its own assumptions. A repository that has not yet recorded its conventions is the expected case, not an edge case.

#### Scenario: Project convention wins a conflict

- **WHEN** a consuming project's recorded convention contradicts a preference stated in the skill
- **THEN** the project's convention SHALL be followed and the conflict reported rather than silently resolved

#### Scenario: Absent conventions produce a question, not an invention

- **WHEN** a provider-specific or project-specific question arises in a repository that records no conventions
- **THEN** the skill SHALL state that the answer is provider- or project-specific and ask, rather than supplying one provider's specifics unmarked

### Requirement: CI Pipeline Shape Is Out of Scope

The skill SHALL own what a pipeline must *respect* about Terraform: that an apply must apply a plan a human has read, that a saved plan file is what makes an approval binding on a specific diff, and that state locking constrains concurrent runs.

The skill SHALL NOT specify how to build a pipeline. Job structure, approval mechanisms, secret storage and resolution, artifact passing, scheduling, and permission scoping belong to a CI-specific asset.

Where a project gates applies behind a pipeline, the skill SHALL state the prohibition on applying outside that pipeline as a principle, and SHALL defer the pipeline's shape to the project.

#### Scenario: Approval semantics are explained without prescribing a pipeline

- **WHEN** the user asks how to make an approval binding on the exact change being approved
- **THEN** the skill SHALL explain saved-plan semantics without prescribing job structure or an approval mechanism

#### Scenario: Two assets each supply their own half

- **WHEN** a task concerns running Terraform inside a CI system and both this skill and a CI-specific asset are relevant
- **THEN** both MAY load, each supplying its own half, and neither SHALL restate the other's content

### Requirement: Traps Are Recorded in Preference to Tutorial Content

The skill SHALL record at minimum these behaviours, each of which contradicts a reasonable expectation:

- `prevent_destroy` accepts only a literal value and cannot read a variable.
- `count` index shifts destroy and recreate resources that were not meant to change, where `for_each` keyed by a stable identifier does not.
- A version constraint without a committed lock file is not pinning.
- Marking a variable or output `sensitive` redacts it from output but does not keep its value out of state.

General Terraform material that a competent model already supplies unprompted SHALL NOT displace this content.

#### Scenario: A recorded trap is available before it is hit

- **WHEN** an agent is about to place `prevent_destroy` inside a reusable module, or index resources with `count` over a list whose order can change
- **THEN** the skill SHALL already carry the reason not to, without the user having to know to ask

#### Scenario: Base knowledge is deferred to rather than restated

- **WHEN** an agent working under this skill meets a question the base model already answers reliably, such as basic HCL block syntax or what a module is
- **THEN** the skill SHALL leave that to the model rather than carrying a restatement of it

### Requirement: Testing Mechanisms and Their Limits Are Named

The skill SHALL name the mechanisms available for testing Terraform code and SHALL state each mechanism's limit rather than presenting any one of them as a complete substitute for the others:

- Static checking — `terraform validate` and `terraform fmt -check`, together with third-party linters and policy tools (for example `tflint`, `checkov`, OPA/Sentinel) where the project uses them. This catches structural, style, and policy problems before anything runs, at effectively zero cost, but does not evaluate what a real apply against real state would actually do.
- `terraform plan` as a dry-run, with the explicit limit that its output is faithful only to the state and configuration at the moment it runs — the skill SHALL point to its own existing plan-as-checkpoint guidance rather than restating it here.
- `terraform test` (the native HCL-based test framework) as the closest thing to an actual test suite: it can run assertions against mocked providers or against real infrastructure. The skill SHALL name it alongside a proportionality note — most useful for a module meant to be shared or reused, and often more setup than a small, single-use configuration warrants — and SHALL NOT mandate it, matching this capability's existing posture of naming options and deferring the choice to the project. Where a `terraform test` run exercises real infrastructure rather than mocked providers, the skill SHALL state that it carries the same replace/destroy confirmation obligation this capability's plan-checkpoint requirement already imposes on an ordinary apply, rather than treating `terraform test` as a path exempt from that discipline because it is a different command.

The skill SHALL direct that language- and tool-agnostic testing discipline (recording a baseline before a failure claim, the failure states a failing test can be in, and the rest of that floor) be read from the library's testing-practice skill rather than restated here.

#### Scenario: A testing-mechanism question is answered with the full set and their limits

- **WHEN** the user asks how to test a Terraform module or configuration
- **THEN** the skill SHALL name static checking, `terraform plan`, and `terraform test` together, rather than presenting any single one as sufficient alone

#### Scenario: `terraform test` is named without being mandated

- **WHEN** the user asks whether they need a `terraform test` suite for a small, single-use configuration
- **THEN** the skill SHALL name `terraform test` and its proportionality note rather than mandating it, and SHALL defer the choice to the project

#### Scenario: Plan-as-dry-run points back to existing guidance instead of duplicating it

- **WHEN** the testing section covers `terraform plan`'s role as a dry-run
- **THEN** the skill SHALL point to its own existing plan-as-checkpoint content rather than restating that guidance

#### Scenario: A real-infrastructure `terraform test` run is not treated as exempt from the checkpoint requirement

- **WHEN** the user asks about running `terraform test` against real infrastructure rather than mocked providers
- **THEN** the skill SHALL state that the same replace/destroy confirmation obligation applies as for an ordinary apply, rather than presenting `terraform test` as a path around that discipline
