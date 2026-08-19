## ADDED Requirements

### Requirement: Testing Mechanisms and Their Limits Are Named

The skill SHALL name the mechanisms available for testing Ansible content and SHALL state each mechanism's limit rather than presenting any one of them as a complete substitute for the others:

- Static checking — `ansible-lint` and `ansible-playbook --syntax-check`.
- A live dry-run via `--check` combined with `--diff`, together with the explicit limit that many modules do not support check mode at all — including the `shell`/`command` modules this capability's idempotency-traps requirement already records as non-idempotent by default — so this is not a reliable preview the way a provisioning tool's plan step is.
- A role-level test harness (Molecule), which provisions an ephemeral instance and asserts against the result. The skill SHALL name it alongside a proportionality note — appropriate for a shared or reusable role, and likely disproportionate setup for a small-scale host count — and SHALL NOT mandate it, matching this capability's existing posture of naming options and deferring the choice to the project.

The skill SHALL direct that language- and tool-agnostic testing discipline (recording a baseline before a failure claim, the failure states a failing test can be in, and the rest of that floor) be read from the library's testing-practice skill rather than restated here.

#### Scenario: A testing-mechanism question is answered with the full set and their limits

- **WHEN** the user asks how to test a playbook or role
- **THEN** the skill SHALL name static checking, the live dry-run, and the role-level test harness together, rather than presenting any single one as sufficient alone

#### Scenario: The check-mode coverage gap is stated rather than assumed

- **WHEN** the user asks whether `--check`/`--diff` reliably previews a run before it's applied
- **THEN** the skill SHALL state that many modules do not support check mode, including the `shell`/`command` modules already flagged as non-idempotent, rather than presenting `--check`/`--diff` as a complete preview
