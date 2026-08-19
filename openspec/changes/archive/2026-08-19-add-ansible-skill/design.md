## Context

See proposal.md - Why. `skills/terraform/SKILL.md` is the closest structural precedent in this library: same tier (a `skills/<name>/SKILL.md` provider-neutral practice skill), same posture (floor, not authority; defers to a consuming project's `AGENTS.md`/`CLAUDE.md`; states traps in preference to tutorial content). The `ansible-practice` spec (see `specs/ansible-practice/spec.md`) already fixes the requirements this skill must satisfy; this document covers structural and authoring decisions the spec doesn't pin down.

`skills/create-skill/SKILL.md` is the authoring standard for any skill added to this library, including this one — its Checkpoint 1 (name availability, tag-vocabulary reuse, purpose, triggering phrasings) and its trigger-check requirement apply at apply time, not to the specs/design captured here.

## Goals / Non-Goals

**Goals:**
- Produce a `skills/ansible/SKILL.md` whose section shape mirrors `skills/terraform/SKILL.md` closely enough that the two read as siblings in the same pipeline (a reader who's used one recognizes the other).
- Satisfy every requirement in `specs/ansible-practice/spec.md`.

**Non-Goals:**
- Deciding the skill's exact `metadata.tags` list or its `description` wording — those are apply-time authoring decisions governed by `create-skill`'s Checkpoint 1 (tag-vocabulary reuse, description-triggering standard), not design-time decisions to fix here.
- Producing Ansible Tower/AWX/Ansible Automation Platform guidance, or network-device automation guidance — out of scope per proposal.md - Impact; no stated need surfaced during exploration.

## Decisions

**Section shape mirrors `terraform`'s, mapped one-for-one onto the settled content pillars.** `terraform`'s body runs: read-project-conventions-first → authoring/run structural guidance → traps. The same shape maps directly onto what was settled during exploration:

| `terraform` section | `ansible` equivalent |
|---|---|
| "Read the project's conventions first" | Same, verbatim posture (Requirement: Consuming Project Conventions Take Precedence) |
| Module and environment boundaries | Scope boundary against provisioning/runtime (Requirement: Scope Boundary...) |
| `variable validation` as cheapest guardrail | *No direct equivalent — omit rather than force a mapping* |
| "Traps that cost a rewrite" | Idempotency traps section, plus the pinning trap folded in |
| *(no equivalent)* | Secrets boundary section (new — Ansible's secrets-in-rendered-files risk has no Terraform-shaped analogue) |
| *(no equivalent)* | Host-security ownership split section (new) |
| *(no equivalent)* | Inventory-provenance pattern menu (new) |

Three sections have no Terraform counterpart because they answer questions that only arise from Ansible sitting in the *middle* of a three-tool pipeline (Terraform before it, Compose/Kubernetes after it) rather than standing alone the way Terraform's provisioning stage does. That's expected, not a sign the mirroring broke down — `terraform` doesn't need a "who owns the firewall" section because it IS the firewall's owner.

**No `variable validation`-shaped section.** Terraform's cheapest-guardrail section works because `variable validation` blocks are a single, specific mechanism. Ansible has no single equivalent mechanism cheap enough to warrant its own section — the closest candidates (task-level `assert`, `failed_when`) are already ordinary base-model knowledge, so per the spec's "general material a competent model already supplies unprompted SHALL NOT displace this content" clause, this is left out rather than manufactured.

**Trap list stays at the spec's stated minimum, not expanded further at authoring time.** The spec names three idempotency traps (`shell`/`command` non-idempotency, over-broad `become`, inventory precedence) plus the separate pinning requirement. Authoring may phrase these more vividly (as `terraform`'s trap bullets do, each with a one-line mechanism explanation), but should resist adding a fourth or fifth trap beyond what the spec and this design record — an unbounded trap list is exactly the "tutorial content" the spec's last requirement is written to keep out.

## Risks / Trade-offs

- **Three genuinely new sections (secrets, host-security split, inventory menu) have no `terraform` precedent to check the phrasing against** → Mitigation: each is fully specified by name and by failure-mode in `specs/ansible-practice/spec.md`'s scenarios; authoring should satisfy the scenario text directly rather than inventing shape, and a review pass (see tasks.md) checks the finished skill against those scenarios line by line.
- **The provisioning/runtime scope boundary is easy to blur in practice** (a Docker-install task is one line away from also starting the stack) → Mitigation: the spec's scenario for this is deliberately literal — no service-definition templating, no lifecycle commands — and the skill body should state the boundary early, near the top, the way `terraform` states its provider-neutrality boundary in its second paragraph rather than burying it.
- **`skill-authoring`'s trigger-check requirement (the skill must be observed to trigger before being called finished) cannot be satisfied by this proposal** → Not a design risk to solve here; it's apply-time work, scheduled in `tasks.md` section 5, including the competing-recorded-check re-verification that requirement also mandates whenever a new asset is added.
