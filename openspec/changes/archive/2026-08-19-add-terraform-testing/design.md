## Context

See proposal.md - Why. `terraform-practice`'s existing requirements and `skills/terraform/SKILL.md`'s matching sections are the base this change adds one requirement to. `testing-practice`'s "Language and Tool Specifics Are Routed by Pointer, Not Restated" requirement and `skills/testing/SKILL.md`'s "## Language and framework specifics" pointer list are the other half of the coordination this change performs — and, unlike the `add-ansible-testing` precedent this change follows, that other half is already correct: the pointer list already names `terraform`. `add-ansible-testing`'s own design.md flagged this exact gap in passing ("`terraform` has the identical gap today") before it existed as a proposal.

## Goals / Non-Goals

**Goals:**
- Add testing-mechanism content to `terraform-practice` in the same voice and posture as its existing requirements — naming options and their limits, not mandating one, deferring proportionality to the project.
- Verify `skills/testing/SKILL.md`'s pointer list still correctly names `terraform` once the new section lands, without editing it absent an actual discrepancy.

**Non-Goals:**
- Rewriting `testing-practice`'s spec text — unchanged, per proposal.md's Capabilities section.
- Writing a worked `terraform test` example, a `tflint` config, or any other tutorial-shaped content — this skill records traps and named options, not how-tos, matching its existing "Traps Are Recorded in Preference to Tutorial Content" requirement.
- Deciding whether the consuming project should actually adopt `terraform test` — the new requirement explicitly defers that, the same way the existing CI-pipeline-shape requirement defers pipeline design.
- Restating the skill's existing plan-as-checkpoint guidance — the new section cross-references it instead.

## Decisions

**The new content is one requirement, not three.** The three mechanisms (static checking, `terraform plan`, `terraform test`) answer a single question — "how do I test this?" — and splitting them into separate requirements would scatter that answer across a capability whose existing requirements are each already sized to one distinguishable behavior with its own reason. This follows `ansible-practice`'s "Testing Mechanisms and Their Limits Are Named" requirement as its direct precedent, itself modeled on the "several named items under one requirement" shape `terraform-practice`'s own "Traps Are Recorded in Preference to Tutorial Content" requirement already uses.

**`testing-practice` gets no spec delta, and `skills/testing/SKILL.md` gets no edit.** This is where this change diverges from its `add-ansible-testing` precedent. That change had two gaps to close — the pointer list was missing the `ansible` bullet entirely, *and* `ansible`'s own body had no content. Here only the second gap exists: `skills/testing/SKILL.md` already reads "`terraform` — `terraform test`, plan-time validation, and what can be asserted without applying," which is already compliant with `testing-practice`'s "No domain skill is omitted for currently having thin testing content" scenario. Editing a line that is already correct would be a no-op dressed up as a task; tasks.md instead includes a verification step (re-read the line, confirm it still matches what the new section actually delivers) rather than an edit step.

**Reciprocal pointer, not restated content.** The new `terraform-practice` requirement points to `testing` for baseline-before-failure-claim and the four failure states, rather than repeating them — mirroring `testing-practice`'s own pointer requirement applied in the other direction, and matching exactly how `ansible-practice`'s equivalent requirement is worded.

## Risks / Trade-offs

- **`terraform test` against real infrastructure could read as exempt from the capability's own checkpoint discipline** → `openspec-change-reviewer` flagged this during review: the requirement named `terraform test` as capable of running "against real infrastructure" with only a proportionality caveat, while `terraform-practice`'s existing "The Plan Is a Human Checkpoint" requirement mandates blast-radius statement and explicit confirmation before any apply/destroy — and `terraform test` applies and tears down real resources through a path other than a reviewed `terraform apply`, so nothing bound it to that discipline as first drafted. Mitigation: the delta spec's `terraform test` bullet now states explicitly that a real-infrastructure run carries the same replace/destroy confirmation obligation as an ordinary apply, with a fourth scenario asserting it, and `tasks.md` gained a 1.1a step tying the SKILL.md content to that scenario the same way task 1.2 already ties `terraform plan` coverage to the existing checkpoint section.
- **A description edit to `terraform` invalidates its recorded trigger check fixtures** (`create-skill`'s standing rule) → Mitigation: tasks.md checks whether the new testing content requires touching the `description` field and re-runs the trigger check against a fresh-context evaluator if so, exactly as the `ansible` precedent did.
- **The verification step (confirming `skills/testing/SKILL.md`'s pointer line still matches) could be skipped as apparently redundant** → Stated explicitly as its own task so it isn't silently dropped: the promised content ("`terraform test`, plan-time validation, and what can be asserted without applying") should be checked against what the new section actually delivers, not assumed to match because the bullet already existed.
- **No fixture currently demonstrates the `testing` + `terraform` co-trigger the way `testing` + `python` already does** → Not a defect this change is obligated to fix; `testing-practice`'s fixture requirements don't demand one worked example per named tool. tasks.md includes it as an optional, explicitly-non-blocking task, matching how the `ansible` precedent treated the same gap for itself.
