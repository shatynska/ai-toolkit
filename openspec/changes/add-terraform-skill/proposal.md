## Why

Every asset this library ships is meta: `create-skill` and `create-agent` author assets, `openspec-change-reviewer` reviews change proposals, and all four capabilities describe authoring machinery. Nothing in it helps with the work those assets are used to build. A companion repository (`infrastructure`) is standing up Terraform against Hetzner Cloud with 58 open tasks, and its operator is new to Terraform — so the guidance is needed now, by someone not yet able to catch a bad plan by eye.

The reason to make it an asset rather than notes is durability. Procedural knowledge that lives in a change's `tasks.md` is archived when that change completes: the `infrastructure` repo's own tasks already carry hard-won warnings — `prevent_destroy` accepts only literals, no blanket `*.tfvars` ignore, no workflow-level `paths` filter on a required check — every one of which disappears from view the moment the change is archived. Requirements survive archiving; the procedure that produced them does not. A skill is where that half persists.

## What Changes

- Add `skills/terraform/SKILL.md` — the library's first domain asset, authored to `create-skill`'s standard, covering both writing Terraform and running it.
- Scope it **provider-neutral**. Hetzner, HCP Terraform, and any single project's decisions stay out; they belong in that project's own `AGENTS.md`. The skill states this deference explicitly so it composes with a project's conventions instead of competing with them.
- Weight the content against what a model already supplies unprompted. Terraform syntax, "use modules", "pin your providers" change no behaviour and are not the deliverable. The content that earns its place is the traps (`prevent_destroy` taking only literals; `count` index shifts destroying the wrong resource where `for_each` would not; version constraints without a committed lockfile not being pinning; `sensitive` not keeping values out of state) and the run discipline where a mistake is expensive.
- Make the plan a human checkpoint rather than a step — the skill requires the diff be read and its blast radius stated before an apply, and requires explicit confirmation before any apply whose plan contains a replace or destroy. That is what makes it useful to an operator who cannot yet read a plan unaided.
- Draw the boundary against a future `github-actions` skill **as a requirement, not a note**: this skill owns what a pipeline must *respect* about Terraform; how to build a gated pipeline belongs to the CI skill. Recorded in the spec so the next change inherits the line instead of re-deciding it.
- Introduce two tags, `infrastructure` and `terraform`, and reuse the existing `hitl`. The vocabulary in use (`authoring`, `hitl`, `review`, `openspec`) classifies authoring and OpenSpec process only, so this is the first domain vocabulary the library carries.
- Re-run the recorded trigger-check fixtures of any existing asset the new skill competes with, per the invalidation requirement in `skill-authoring`.

## Capabilities

### New Capabilities
- `terraform-practice`: What the library's Terraform guidance asserts and where it stops — provider-neutral scope, the authoring and run-discipline halves it must cover, the human checkpoint on the plan, deference to a consuming project's own conventions, and the boundary that keeps CI pipeline shape out of it.

### Modified Capabilities
(none)

`skill-authoring` governs *how* a skill is authored and places no constraint on subject matter, so a domain skill needs nothing added to it. `toolkit-structure` already makes tags the only classification and explicitly contemplates an asset belonging to more than one domain, requiring only that existing vocabulary be checked before a tag is coined — which this change does rather than changes. Its "adding an asset requires no catalogue update" requirement means no README or index edit is owed either.

## Impact

- **Affected**: new directory `skills/terraform/`. No existing asset changes.
- **Library positioning**: this is the first asset in the library that is not about authoring assets. `/plugin install` is all-or-nothing, so the skill loads in every project the plugin is installed into — accepted, since an untriggered skill costs only its description line, and the description is written to distinguish it from the meta assets.
- **Recorded checks elsewhere**: `skill-authoring` requires that adding an asset invalidates the recorded trigger checks of every asset it competes with for the same prompts. The fixtures of `create-skill`, `create-agent`, and `openspec-change-reviewer` must be re-run and updated if the new skill changes where any of their prompts route.
- **Follow-on work, not in scope**: a `github-actions` skill (deferred until the `infrastructure` repo's CI is built, so it can be harvested rather than guessed), a `kubernetes` skill (deferred until k3s has actually been run), and the consuming project's `AGENTS.md`, which is already task 3.7 in the `infrastructure` repository's own change.
- **No new dependencies**, no tooling, no build step — consistent with the repository carrying none.
