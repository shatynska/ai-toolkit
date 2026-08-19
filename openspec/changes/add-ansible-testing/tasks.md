## 1. Write the new section in skills/ansible/SKILL.md

- [ ] 1.1 Add a "Testing Ansible content" section (placement: after the existing traps section, before inventory provenance — it builds on the idempotency traps' `shell`/`command` point) covering: static checking (`ansible-lint`, `--syntax-check`), the live dry-run (`--check --diff`) with the check-mode coverage gap stated explicitly, and Molecule as a role-level harness with its proportionality note, per `specs/ansible-practice/spec.md`'s new requirement.
- [ ] 1.2 In that section, point to the `testing` skill for language/tool-agnostic discipline rather than restating it (baseline-before-failure-claim, the failure states) — do not copy that content in.
- [ ] 1.3 Decide whether the frontmatter `description` needs a phrase signalling testing coverage (e.g. a trigger phrasing like "how do I test this playbook") for the description standard's breadth requirement, given the section is now part of the skill's scope. If yes, revise it; if the existing phrasings already cover it adequately, state why no edit is needed.

## 2. Fix the compliance gap in skills/testing/SKILL.md

- [ ] 2.1 Add an `ansible` bullet to the "## Language and framework specifics" pointer list, in the same one-line style as the existing `python`/`langgraph`/`bash`/`terraform` bullets (e.g. naming `ansible-lint`, `--check`/`--diff`, and Molecule as what that stack's testing material covers).
- [ ] 2.2 Confirm this is a body-only edit (no change to `testing`'s `name` or `description`) so its own recorded trigger fixtures are not invalidated by `create-skill`'s rule — state this explicitly rather than silently assuming it.

## 3. Validate

- [ ] 3.1 Confirm the new `ansible-practice` requirement's frontmatter/body changes parse correctly and `openspec validate add-ansible-testing --strict` passes (and, after this change is archived and synced, `openspec validate --strict` against the repo).
- [ ] 3.2 Walk both new scenarios in the delta spec against the written `skills/ansible/SKILL.md` section and confirm each is satisfied.
- [ ] 3.3 Confirm the new section does not restate `testing`'s own floor content (baseline recording, failure states) — points to it instead.

## 4. Trigger check (only if 1.3 changed the description)

- [ ] 4.1 If the description changed: enumerate the library's recorded trigger fixtures (same fixture universe as the prior change's task 5.1) and check for new competition from an Ansible-testing-shaped prompt (e.g. "how do I test this ansible role").
- [ ] 4.2 If the description changed: re-run `ansible`'s own positive and negative trigger-check prompts against a fresh-context evaluator, and update `skills/ansible/SKILL.md`'s `## Trigger check fixtures` section to match (prompts and expected routing only, never outcome or date).
- [ ] 4.3 If the description did not change, state that explicitly and skip 4.1–4.2 — no re-run is owed.

## 5. Optional: testing/SKILL.md fixture precedent

- [ ] 5.1 Consider adding a co-trigger fixture to `testing/SKILL.md` analogous to its existing "Write tests for this function in my Python module." → `testing` **and** `python` pair (e.g. "Write tests for this Ansible role." → `testing` **and** `ansible`). Not required — `terraform` has the same gap today — but note the decision either way rather than leaving it unaddressed silently.
