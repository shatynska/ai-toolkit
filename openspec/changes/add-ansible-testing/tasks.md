## 1. Write the new section in skills/ansible/SKILL.md

- [x] 1.1 Add a "Testing Ansible content" section (placement: after the existing traps section, before inventory provenance — it builds on the idempotency traps' `shell`/`command` point) covering: static checking (`ansible-lint`, `--syntax-check`), the live dry-run (`--check --diff`) with the check-mode coverage gap stated explicitly, and Molecule as a role-level harness with its proportionality note, per `specs/ansible-practice/spec.md`'s new requirement.
- [x] 1.2 In that section, point to the `testing` skill for language/tool-agnostic discipline rather than restating it (baseline-before-failure-claim, the failure states) — do not copy that content in.
- [x] 1.3 Decide whether the frontmatter `description` needs a phrase signalling testing coverage (e.g. a trigger phrasing like "how do I test this playbook") for the description standard's breadth requirement, given the section is now part of the skill's scope. If yes, revise it; if the existing phrasings already cover it adequately, state why no edit is needed. — Revised: added "how do I test this playbook" as a trigger phrase and "testing mechanisms and their limits (lint, check mode, Molecule)" to the coverage list; trimmed elsewhere to stay under the 1024-character limit (1014 chars).

## 2. Fix the compliance gap in skills/testing/SKILL.md

- [x] 2.1 Add an `ansible` bullet to the "## Language and framework specifics" pointer list, in the same one-line style as the existing `python`/`langgraph`/`bash`/`terraform` bullets (e.g. naming `ansible-lint`, `--check`/`--diff`, and Molecule as what that stack's testing material covers).
- [x] 2.2 Confirm this is a body-only edit (no change to `testing`'s `name` or `description`) so its own recorded trigger fixtures are not invalidated by `create-skill`'s rule — state this explicitly rather than silently assuming it. — Confirmed: `testing`'s frontmatter `name` and `description` are unchanged; only the body's pointer list gained one bullet.

## 3. Validate

- [x] 3.1 Confirm the new `ansible-practice` requirement's frontmatter/body changes parse correctly and `openspec validate add-ansible-testing --strict` passes (and, after this change is archived and synced, `openspec validate --strict` against the repo).
- [x] 3.2 Walk both new scenarios in the delta spec against the written `skills/ansible/SKILL.md` section and confirm each is satisfied.
- [x] 3.3 Confirm the new section does not restate `testing`'s own floor content (baseline recording, failure states) — points to it instead.

## 4. Trigger check (only if 1.3 changed the description)

- [x] 4.1 If the description changed: enumerate the library's recorded trigger fixtures (same fixture universe as the prior change's task 5.1) and check for new competition from an Ansible-testing-shaped prompt (e.g. "how do I test this ansible role"). — Description changed (see 1.3). Grepped all skill/agent/`.claude` fixture files for "molecule", "ansible-lint", "--check", "--diff", "check mode", "ansible" outside `ansible`'s and `testing`'s own files — no matches, nothing to update.
- [x] 4.2 If the description changed: re-run `ansible`'s own positive and negative trigger-check prompts against a fresh-context evaluator, and update `skills/ansible/SKILL.md`'s `## Trigger check fixtures` section to match (prompts and expected routing only, never outcome or date). — Re-ran via a fresh-context evaluator: original positive and negative both still hold; added a new "Positive, testing" fixture for the new coverage, correctly recorded as routing to `ansible` alone (not co-triggering `testing`, since `testing`'s description — deliberately unchanged — doesn't name `ansible`).
- [x] 4.3 If the description did not change, state that explicitly and skip 4.1–4.2 — no re-run is owed. — N/A; the description did change, so 4.1–4.2 applied.

## 5. Optional: testing/SKILL.md fixture precedent

- [x] 5.1 Consider adding a co-trigger fixture to `testing/SKILL.md` analogous to its existing "Write tests for this function in my Python module." → `testing` **and** `python` pair (e.g. "Write tests for this Ansible role." → `testing` **and** `ansible`). Not required — `terraform` has the same gap today — but note the decision either way rather than leaving it unaddressed silently. — Decided against, for now: the fresh-context evaluator run in task 4.2 confirmed a testing-shaped Ansible prompt currently routes to `ansible` alone, not `ansible` **and** `testing`, because `testing`'s description (left unchanged in this change, per design.md) doesn't name `ansible`. Recording a `testing` + `ansible` co-trigger fixture right now would assert something not currently true. Making it true would require editing `testing`'s description — a separate, larger decision outside this change's scope (see design.md's Non-Goals) — left for a future change if wanted.
