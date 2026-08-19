## ADDED Requirements

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
