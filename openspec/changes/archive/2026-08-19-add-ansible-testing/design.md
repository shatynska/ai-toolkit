## Context

See proposal.md - Why. `ansible-practice`'s seven existing requirements and `skills/ansible/SKILL.md`'s seven matching sections (archived as `add-ansible-skill`, `openspec/changes/archive/2026-08-19-add-ansible-skill/`) are the base this change adds one requirement to. `testing-practice`'s "Language and Tool Specifics Are Routed by Pointer, Not Restated" requirement and `skills/testing/SKILL.md`'s "## Language and framework specifics" pointer list are the other half of the coordination this change performs.

## Goals / Non-Goals

**Goals:**
- Bring `skills/testing/SKILL.md`'s pointer list into compliance with `testing-practice`'s existing requirement by naming `ansible`.
- Add testing-mechanism content to `ansible-practice` in the same voice and posture as its existing seven requirements — naming options and their limits, not mandating one, deferring proportionality to the project.

**Non-Goals:**
- Rewriting `testing-practice`'s spec text — unchanged, per proposal.md's Capabilities section.
- Writing a worked Molecule example, an `ansible-lint` config, or any other tutorial-shaped content — this skill records traps and named options, not how-tos, matching the existing "General Ansible material that a competent model already supplies unprompted SHALL NOT displace this content" clause its idempotency-traps requirement already carries.
- Deciding whether the consuming project should actually adopt Molecule — the new requirement explicitly defers that, the same way the existing Inventory-Provenance requirement defers its own choice.

## Decisions

**The new content is one requirement, not three.** The three mechanisms (lint, `--check`/`--diff`, Molecule) could have been split into separate requirements, but they answer a single question — "how do I test this?" — and splitting them would scatter a testing-specific answer where each existing requirement already the size of a single distinguishable behaviour with its own reason. `traps` (Idempotency Traps) is the closest precedent for "several named items under one requirement," and this follows that shape rather than the finer-grained one used for scope/secrets/firewall.

**`testing-practice` gets no spec delta.** Its own requirement text already reads "every domain skill... not a subset" — general and satisfied dynamically. Its scenario "No domain skill is omitted for currently having thin testing content" states this even more directly: "WHEN the pointer list is assembled and a domain skill in the library covers a stack whose artifacts can be tested THEN that skill SHALL be named, whether or not it presently carries testing material" — this is exactly the correction `skills/testing/SKILL.md` needs, already required by existing text. Treating the missing `ansible` bullet as a spec change would imply the requirement's *meaning* changed when only its *compliance state* did. The correct home for this fix is a task against the existing requirement, the same pattern used in the prior `add-ansible-skill` change for `skill-authoring`'s "adding an asset invalidates competing recorded checks" requirement (task 5.1 there added compliance work, not a spec delta).

**Reciprocal pointer, not restated content.** The new `ansible-practice` requirement points to `testing` for baseline-before-failure-claim and the four failure states, rather than repeating them. This mirrors `testing-practice`'s own "Language and Tool Specifics Are Routed by Pointer, Not Restated" requirement, applied in the other direction — `ansible` routes *out* to `testing` for the general floor, the same way `testing` routes *out* to `ansible` (once this change lands) for the Ansible-specific idiom. Neither skill is supposed to own both halves.

## Risks / Trade-offs

- **A description edit to `ansible` invalidates its recorded trigger check fixtures** (`create-skill`'s standing rule) → Mitigation: tasks.md checks whether the new testing content requires touching the `description` field (it likely does — none of the current trigger phrasings signal testing coverage) and re-runs the trigger check against a fresh-context evaluator if so, exactly as the prior change did.
- **Editing `skills/testing/SKILL.md`'s body could be read as requiring a re-run of *its* trigger fixtures too** → Per `create-skill`'s rule, only a `name`/`description` change or an evaluator-composition change invalidates recorded fixtures — a body-only edit to the pointer list does not. This is stated explicitly so a reviewer doesn't need to re-derive it, and tasks.md does not schedule a `testing` fixture re-run on that basis alone.
- **No fixture currently demonstrates the `testing` + `ansible` co-trigger the way `testing` + `python` already does** → Not a defect this change is obligated to fix (`terraform` has the identical gap today, and `testing-practice`'s fixture requirements don't demand one example per named tool). tasks.md includes it as an optional, explicitly-non-blocking task rather than a required one.
