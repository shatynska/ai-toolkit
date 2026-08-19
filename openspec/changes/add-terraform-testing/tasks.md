## 1. Write the new section in skills/terraform/SKILL.md

- [ ] 1.1 Add a "Testing Terraform" section (placement: near the skill's other discipline sections, before "What this skill doesn't decide") covering: static checking (`terraform validate`, `terraform fmt -check`, and named third-party linters/policy tools such as `tflint`, `checkov`, OPA/Sentinel where the project uses them), `terraform plan` as a dry-run, and `terraform test` as a role-level-equivalent test harness with its proportionality note, per `specs/terraform-practice/spec.md`'s new requirement.
- [ ] 1.1a In the `terraform test` part of that section, state that a run exercising real infrastructure (no `mock_provider` blocks) carries the same replace/destroy confirmation obligation as an ordinary apply — cross-referencing "The plan is a checkpoint, not a step" rather than restating it — per the fourth scenario added to `specs/terraform-practice/spec.md`'s delta after review.
- [ ] 1.2 In that section, cross-reference the skill's existing "The plan is a checkpoint, not a step" section for `terraform plan`'s role as a dry-run rather than restating it.
- [ ] 1.3 In that section, point to the `testing` skill for language/tool-agnostic discipline rather than restating it (baseline-before-failure-claim, the failure states) — do not copy that content in.
- [ ] 1.4 Decide whether the frontmatter `description` needs a phrase signalling testing coverage (e.g. a trigger phrasing like "how do I test this module") for the description standard's breadth requirement, given the section is now part of the skill's scope. If yes, revise it; if the existing phrasings already cover it adequately, state why no edit is needed.

## 2. Verify skills/testing/SKILL.md's pointer list

- [ ] 2.1 Re-read the existing `terraform` bullet in the "## Language and framework specifics" pointer list and confirm it still accurately describes what the new section in `skills/terraform/SKILL.md` actually delivers (`terraform test`, plan-time validation, what can be asserted without applying). Edit only if a genuine mismatch is found — do not edit a bullet that already reads correctly.
- [ ] 2.2 State the outcome explicitly (matched as-is, or edited and why) rather than leaving it implicit.

## 3. Validate

- [ ] 3.1 Confirm the new `terraform-practice` requirement's frontmatter/body changes parse correctly and `openspec validate add-terraform-testing --strict` passes (and, after this change is archived and synced, `openspec validate --strict` against the repo).
- [ ] 3.2 Walk all four new scenarios in the delta spec against the written `skills/terraform/SKILL.md` section and confirm each is satisfied, including the real-infrastructure `terraform test` scenario against task 1.1a's content.
- [ ] 3.3 Confirm the new section does not restate `testing`'s own floor content (baseline recording, failure states) or the skill's own existing plan-as-checkpoint content — points to each instead.

## 4. Trigger check (only if 1.4 changed the description)

- [ ] 4.1 If the description changed: enumerate the library's recorded trigger fixtures and check for new competition from a Terraform-testing-shaped prompt (e.g. "how do I test this terraform module"). Update any fixture found to compete.
- [ ] 4.2 If the description changed: re-run `terraform`'s own positive and negative trigger-check prompts against a fresh-context evaluator, and update `skills/terraform/SKILL.md`'s `## Trigger check fixtures` section to match (prompts and expected routing only, never outcome or date). Add a new "Positive, testing" fixture for the new coverage.
- [ ] 4.3 If the description did not change, state that explicitly and skip 4.1–4.2 — no re-run is owed.

## 5. Optional: testing/SKILL.md fixture precedent

- [ ] 5.1 Consider adding a co-trigger fixture to `testing/SKILL.md` analogous to its existing "Write tests for this function in my Python module." → `testing` **and** `python` pair (e.g. "Write tests for this Terraform module." → `testing` **and** `terraform`). Not required — record the decision either way rather than leaving it unaddressed silently. Note: `add-ansible-testing`'s equivalent task found that an Ansible-testing-shaped prompt currently routes to `ansible` alone, not `ansible` **and** `testing`, because `testing`'s description doesn't name any domain skill by name; the same is likely true for `terraform` and should be checked with a fresh-context evaluator before deciding.
