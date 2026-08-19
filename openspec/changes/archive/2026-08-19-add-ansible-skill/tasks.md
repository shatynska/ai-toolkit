## 1. Checkpoint 1 — Intent (create-skill)

- [x] 1.1 Confirm `ansible` is available under `skills/` (list current directory names, check for collision).
- [x] 1.2 List `metadata.tags` already used across `skills/` and `agents/`; choose `ansible`'s tags from that vocabulary where possible, and state a reason for any new tag. Whether `hitl` applies is an open judgment call to make fresh against `ansible-practice`'s own spec content — unlike `terraform-practice`, `ansible-practice` has no HITL-confirmation-gate requirement, which bears on the call but isn't a precedent to cite.
- [x] 1.3 Draft the triggering phrasings the description must cover (canonical: "write an ansible playbook", "review my ansible role"; adjacent: "set up ansible in this repo", "why isn't this task idempotent", "should this playbook install docker").

## 2. Checkpoint 3 — Draft (create-skill)

- [x] 2.1 Draft frontmatter (`name`, `description`, `metadata.tags`) satisfying the description standard (third person, states action + trigger conditions, deliberately over-eager phrasing coverage, library-wide disambiguation against every other skill and agent — including the scope boundary against `terraform` and against a hypothetical Compose/Kubernetes-runtime skill).
- [x] 2.2 Draft a section-header-only body outline following design.md's section-shape mapping table.
- [x] 2.3 Present frontmatter + outline for approval before writing the file.

## 3. Write skills/ansible/SKILL.md body

- [x] 3.1 Write "Read the project's conventions first" section (satisfies Requirement: Consuming Project Conventions Take Precedence).
- [x] 3.2 Write the scope-boundary section near the top of the body, stating what's out (provisioning; application-runtime lifecycle) and where the skill's responsibility ends (Requirement: Scope Boundary Against Provisioning and Application Runtime).
- [x] 3.3 Write the runtime-engine installation section: mechanism choice not mandated for installing the runtime engine specifically; cross-reference the pinning trap written under 3.6 rather than restating it (Requirement: Runtime-Engine Installation Is Flexible But Pinned).
- [x] 3.4 Write the secrets section: boundary and named safe patterns, explicit plaintext-rendering-on-host risk (Requirement: Secrets Boundary Is Stated, Mechanism Is Not Prescribed).
- [x] 3.5 Write the host-security ownership section: cloud vs. host firewall split, SSH hardening, unattended upgrades, dual-firewall warning (Requirement: Host Security Ownership Is Explicit and Split From Cloud Firewall).
- [x] 3.6 Write the idempotency-traps section: stateless run model stated explicitly, the three named traps (shell/command non-idempotency and handler effects, over-broad `become`, inventory precedence), plus the pinning trap for any external Galaxy role or collection used "for this or any other purpose" — not scoped narrowly to the runtime-engine section, per design.md's section-mapping table (Requirements: Idempotency Traps Specific to a Stateless Run Model Are Recorded; Runtime-Engine Installation Is Flexible But Pinned).
- [x] 3.7 Write the inventory-provenance section: name the pattern menu (manual static, provisioning-writes-inventory, dynamic inventory plugin) and each pattern's failure mode, defer the choice to the project (Requirement: Inventory Provenance Is a Named Menu, Not a Mandate).

## 4. Validate

- [x] 4.1 Confirm frontmatter parses as valid YAML and `name` matches the directory name.
- [x] 4.2 Confirm the file sits at `skills/ansible/SKILL.md` with no directory between `skills/` and `ansible/`.
- [x] 4.3 Confirm declared tags are lowercase kebab-case.
- [x] 4.4 Walk every scenario in `specs/ansible-practice/spec.md` against the written body and confirm each is satisfied.
- [x] 4.5 Confirm the body excludes the content classes named in Requirement: Scope Boundary (no provisioning steps, no service-definition/lifecycle instructions).

## 5. Trigger check

- [x] 5.1 Per `skill-authoring`'s "adding an asset invalidates competing recorded checks" requirement: enumerate the recorded trigger fixtures across the library (`skills/*/SKILL.md`, `agents/*.md`, `.claude/skills/*/SKILL.md`, `.claude/commands/**/*.md` — the same fixture universe used in 5.2), identify any whose positive or negative prompt now plausibly competes with an Ansible-canonical prompt (e.g. "install docker", "harden ssh", "configure this server"), and update and re-run any that do, within this change.
- [x] 5.2 Run the positive prompt against a fresh-context evaluator holding every skill and agent's `name`+`description` (from `skills/*/SKILL.md`, `agents/*.md`, and `.claude/skills/*/SKILL.md` + `.claude/commands/**/*.md`) and confirm it selects `ansible`.
- [x] 5.3 Run the negative prompt (an adjacent Terraform-provisioning or Compose-lifecycle question) against the same evaluator and confirm it does NOT select `ansible`.
- [x] 5.4 If any of 5.1–5.3 fails, revise the description (or the affected existing fixture) and re-run before reporting the skill finished.
