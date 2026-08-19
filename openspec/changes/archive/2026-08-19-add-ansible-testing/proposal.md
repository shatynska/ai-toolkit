## Why

`skills/ansible/SKILL.md` currently says nothing about how Ansible content gets tested — no `ansible-lint`, no `--check`/`--diff`, no Molecule. Investigating this surfaced a second, sharper problem: `openspec/specs/testing-practice/spec.md` already requires `skills/testing/SKILL.md`'s pointer section to "name **every** domain skill in the library that covers a stack with a testable artifact, not a subset." Ansible playbooks and roles are testable artifacts, so `testing/SKILL.md`'s pointer list — which currently names `python`, `langgraph`, `bash`, `terraform` — is out of compliance with that existing requirement. This is a side effect of `add-ansible-skill` landing without the pointer list being updated at the same time, not a new requirement being introduced now.

## What Changes

- Add a new requirement to `ansible-practice`: the skill names the mechanisms available for testing Ansible content (static checking, live dry-run via `--check --diff`, and Molecule as a role-level harness) and states each one's real limit, rather than presenting any as a complete substitute for the others — matching the skill's existing posture of naming options and deferring proportionality to the project (see the Runtime-Engine and Inventory-Provenance requirements it already has).
- Point that new section back to the library's `testing` skill for language/tool-agnostic testing discipline, rather than restating it — the reciprocal half of the pointer relationship `testing-practice` already establishes from its own side.
- Fix `skills/testing/SKILL.md`'s pointer list by adding an `ansible` bullet, bringing it into compliance with `testing-practice`'s existing (unchanged) requirement.
- Re-run `ansible`'s trigger check if its description changes to signal the new coverage, per `create-skill`'s standing rule that a description edit invalidates recorded fixtures.

## Capabilities

### New Capabilities

_None._

### Modified Capabilities

- `ansible-practice`: adds a requirement that the skill name Ansible's testing mechanisms and their limits, pointing to `testing` for general discipline rather than restating it.

`testing-practice` is deliberately **not** listed here even though `skills/testing/SKILL.md`'s body changes. Its requirement ("Language and Tool Specifics Are Routed by Pointer, Not Restated") already reads "every domain skill... not a subset" — general, satisfied dynamically as the library grows. Nothing about that requirement's normative text changes; only `skills/testing/SKILL.md`'s body is presently out of date relative to it. This change corrects the implementation, not the requirement.

## Impact

- Modified: `skills/ansible/SKILL.md` (new section; possible description change and trigger-check re-run).
- Modified: `skills/testing/SKILL.md` (one new pointer-list bullet).
- Modified: `openspec/specs/ansible-practice/spec.md` (new requirement, via this change's delta spec).
- No change to `openspec/specs/testing-practice/spec.md` — see Capabilities above.
