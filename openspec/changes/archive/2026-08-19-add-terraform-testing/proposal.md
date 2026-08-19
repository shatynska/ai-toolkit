## Why

`skills/terraform/SKILL.md` currently says nothing about how Terraform code gets tested — no `terraform validate`, no static analysis, no `terraform test`. Investigating this surfaced that `skills/testing/SKILL.md`'s pointer list already names `terraform` and promises this exact content ("`terraform test`, plan-time validation, and what can be asserted without applying"), so the gap is a body that hasn't caught up to a promise already made, not a new promise being introduced now. This is the same shape of gap `add-ansible-testing` closed for Ansible, except here the `testing` skill side is already correct — only `terraform`'s own body is out of date relative to it.

## What Changes

- Add a new requirement to `terraform-practice`: the skill names the mechanisms available for testing Terraform code (static checking via `terraform validate`/`fmt -check`/linters, `terraform plan` as a dry-run, and `terraform test` as the closest thing to an actual test suite) and states each one's real limit, rather than presenting any as a complete substitute for the others — matching the skill's existing posture of naming options and deferring proportionality to the project.
- Point that new section back to the library's `testing` skill for language/tool-agnostic testing discipline, rather than restating it — the reciprocal half of the pointer relationship `testing-practice` already establishes from its own side, and the same relationship `ansible-practice` already has.
- Cross-reference rather than duplicate the skill's existing "The plan is a checkpoint, not a step" section, since `terraform plan`'s role as a dry-run is already covered there in depth.
- Confirm (no edit expected) that `skills/testing/SKILL.md`'s pointer list still correctly names `terraform` at implementation time — unlike the ansible case, this change does not need to add that bullet, only verify it remains accurate once the new section exists.
- Re-run `terraform`'s trigger check if its description changes to signal the new coverage, per `create-skill`'s standing rule that a description edit invalidates recorded fixtures. A fresh-context evaluator confirmed that, unlike the ansible case, a testing-shaped Terraform prompt co-triggers `terraform` **and** `testing` together — because `testing`'s own description already names `terraform` explicitly — so record a new fixture pair on both sides documenting that co-trigger (a body-only addition to `skills/testing/SKILL.md`, not a description change, so it does not invalidate `testing`'s own recorded fixtures per `create-skill`'s rule).

## Capabilities

### New Capabilities

_None._

### Modified Capabilities

- `terraform-practice`: adds a requirement that the skill name Terraform's testing mechanisms and their limits, pointing to `testing` for general discipline rather than restating it.

`testing-practice` is deliberately **not** listed here even though it is the reason this gap is visible. Its requirement ("Language and Tool Specifics Are Routed by Pointer, Not Restated") already reads "every domain skill... not a subset" and already names `terraform` — general, satisfied dynamically as the library grows, and already compliant on the `testing` side. Nothing about that requirement's normative text changes, and no edit to `skills/testing/SKILL.md` is anticipated. This change corrects `terraform`'s implementation relative to a promise already made, not the requirement that made it.

## Impact

- Modified: `skills/terraform/SKILL.md` (new section; description change and trigger-check re-run).
- Modified: `openspec/specs/terraform-practice/spec.md` (new requirement, via this change's delta spec).
- Modified: `skills/testing/SKILL.md` — body-only, trigger-check fixtures section only, adding a `terraform` co-trigger fixture confirmed by evaluation; the pointer list itself needed no edit (see What Changes), and `name`/`description` are unchanged so `testing`'s own recorded fixtures are not invalidated.
- Not modified: `openspec/specs/testing-practice/spec.md`.
