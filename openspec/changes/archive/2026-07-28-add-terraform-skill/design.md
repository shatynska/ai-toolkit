## Context

The library ships two skills and one agent, all meta: they author assets or review change proposals. Its four capabilities describe authoring machinery and repository structure. Nothing in it addresses a subject domain.

The motivating consumer is the `infrastructure` repository: Terraform against Hetzner Cloud, state in HCP Terraform with Local execution, applies gated through GitHub Actions, k3s deferred to a later change. It has 59 tasks with 1 complete, and a thorough `design.md` recording 14 decisions. Its operator is new to Terraform.

That repository matters here for two reasons beyond motivation. First, it already demonstrates the failure this change addresses: its `tasks.md` carries genuinely hard-won procedural knowledge inline, and `tasks.md` is archived when the change completes — the requirements survive, the procedure does not. Second, it is the source of the boundary problem, because every Terraform run it performs happens inside CI, which creates constant pull for a Terraform skill to absorb CI content.

## Goals / Non-Goals

**Goals:**
- Ship a Terraform standard that changes agent behaviour rather than restating what a competent model already supplies.
- Give an operator who cannot yet read a plan unaided a checkpoint that surfaces destruction before it happens.
- Compose with a consuming project's own conventions rather than competing with them.
- Fix the boundary against a future CI skill durably, so the next change inherits the line instead of re-deciding it.

**Non-Goals:**
- Teaching Terraform to a human. A skill loads into an agent's context; it is not documentation the user reads. The consuming project's own `design.md` is better Terraform reading than this skill will be.
- Provider coverage. Hetzner, AWS, and any other provider's specifics are out.
- CI pipeline construction — deferred to a `github-actions` skill.
- Kubernetes or k3s — deferred until that work has actually been performed.
- Any project's own decisions, which belong in that project's `AGENTS.md`.

## Decisions

**1. A skill, not a rule fragment, a command, or an agent.**
`create-skill`'s routing gate asks this first. A rule fragment is for short standing instructions and is always resident — the material here is several thousand words and would be pure context cost on every unrelated turn. A command suits a deterministic named sequence, which this is not. An agent is for work needing its own execution context; Terraform work happens in the caller's context, against the caller's working tree, and a subprocess would have to reconstruct all of it. On-demand, description-triggered procedural knowledge is exactly the skill shape.

**2. Provider-neutral, with project specifics in the consuming project's `AGENTS.md`.**
Three layers, each answering a different question. The skill holds what is true of Terraform anywhere. A CI skill holds how to build a gated pipeline anywhere. The project's `AGENTS.md` holds what that project decided. Two questions place any fact: *would it still be true in someone else's repo?* — if not, it is the project's; *would it still be true with a different CI system?* — if yes, it is the skill's.

The alternative — a Hetzner-flavoured skill — was rejected on two counts. `/plugin install` is all-or-nothing, so it would load into unrelated projects carrying cloud specifics they will never use; and it would duplicate the consuming project's `AGENTS.md`, creating two copies of the same decisions with nothing keeping them synchronised. The opposite alternative, putting everything in the skill and writing no `AGENTS.md`, was rejected because that project's 14 decisions would then live nowhere an agent loads automatically — which is the state the repository is in today, and the reason its decisions are currently invisible.

**3. One skill covering both writing and running, not two.**
Splitting into `terraform-authoring` and `terraform-operations` was considered and rejected as premature. Both would trigger on the same vocabulary and compete for one dispatch decision, and `create-skill`'s disambiguation standard makes that competition a real authoring cost. The combined body is projected around 3,000 words, inside the ~5,000-word budget, so nothing forces the split. Revisit if it outgrows one readable document — splitting later is cheap; merging two under-triggering skills later is not.

The run half is the more valuable of the two here, which is worth stating plainly: base models write competent HCL and do not reliably volunteer that a `replace` in a plan is a destruction.

**4. The boundary against a CI skill is a spec requirement, not a design note.**
This is the same argument the change makes about `tasks.md`. A boundary recorded only in `design.md` is archived with it, and the future `github-actions` change re-litigates from scratch. As a requirement in `terraform-practice` it persists in `openspec/specs/` and constrains the next change. The requirement is written to permit overlap — both assets may load on a task that spans them — while forbidding duplication, because duplicated content is what drifts.

**5. The follow-on CI skill will be `github-actions`, not `ci-for-infrastructure`.**
Recorded here because it determines what this skill defers *to*. Sorting the CI traps the consuming project hit shows six of seven are generic GitHub Actions facts that would bite any repository — a path filter on a required check deadlocking unrelated pull requests, environment secrets shadowing repository secrets, scheduled workflows auto-disabling, third-party action licensing and runtime removal, permission scoping, concurrency. Only the destroy-policy gate is infrastructure-specific, and its Terraform half belongs to this skill under Decision 4.

The deciding argument is triggering rather than reuse. `create-skill` is written against under-triggering as the documented failure mode, and a concern-named skill under-triggers: someone whose pipeline breaks types "my CI is failing," which does not route to `ci-for-infrastructure`. Tool names match what people type, and `terraform` / `github-actions` / later `kubernetes` is a scheme that extends. The gating material is roughly section-sized, not skill-sized, so it becomes a prominent section of `github-actions` rather than its own asset.

**6. Content weighted to traps and discipline over tutorial material.**
The deliverable is behaviour change. "Use modules", "pin your providers", and HCL syntax change nothing, because the base model already supplies them; including them costs context and dilutes what does not. The traps enumerated in the spec were selected for contradicting a reasonable expectation rather than for obscurity — each is something a competent practitioner can get wrong precisely because the intuitive reading is wrong.

**7. Name `terraform`; tags `infrastructure`, `terraform`, `hitl`; flat file; no `allowed-tools`.**
The bare tool name is what users type and keeps `github-actions` available for the series. Two tags are new and the reason is recorded per `toolkit-structure`: existing vocabulary (`authoring`, `hitl`, `review`, `openspec`) classifies authoring and OpenSpec process only. `hitl` is reused deliberately rather than coining a synonym — the plan checkpoint is the same human-in-the-loop shape the authoring skills carry. Flat, because the body fits one readable pass. No `allowed-tools`, because a scoped grant is for a skill wrapping one external command, and a stray restriction on an open-ended skill fails far from its cause.

**8. The plan checkpoint stops for confirmation on destructive plans, and deference has a defined dead end.**
Two questions the first draft left implicit, settled after review because each is the difference between the requirement working and merely reading well.

*Confirmation.* "Surface the blast radius before proceeding" is satisfied by an agent that reports the destruction and applies in the same turn, which defeats the goal for the operator this is written for. The rule is therefore graduated rather than uniform: a plan containing any replace or destroy requires explicit confirmation before the apply runs; a plan containing only creates and updates requires the blast radius be stated but may proceed. Uniform confirmation on every apply was rejected as friction that gets routed around, which would cost the protection where it actually matters.

Graduating the rule opens a seam the uniform version did not have: the permissive branch rests on a classification of *a* plan, and an apply that re-plans rather than consuming the plan that was classified can acquire a replace or destroy between the read and the run. The branch is therefore conditioned on the apply consuming that saved plan, which is the same property task 3.7's approval-binding content establishes; where it does not hold, the confirmation rule applies regardless. The permissive branch is the only one whose classification can go stale, so it is the only one that needs the condition.

*Deference with nothing to defer to.* Both the provider-neutrality and precedence requirements route unanswerable questions to the consuming project's recorded conventions, and the motivating project has none yet — its `AGENTS.md` is still future work. Left undefined, the likely resolution is that the agent supplies provider specifics unmarked, which is exactly the content the scoping excludes. So the absent case is defined: name the answer as project- or provider-specific and ask. This is the expected case rather than an edge case, since most repositories record nothing.

## Risks / Trade-offs

- **The skill drifts into being a CI skill.** Every Terraform run in the motivating project happens in CI, so the pull to make the "applies happen where the project says" section concrete — with jobs, environments, and tokens — is constant, and yielding to it leaves the later `github-actions` skill with nothing to say. *Mitigation*: the boundary is a spec requirement with a scenario, and the Draft checkpoint reviews that section specifically.
- **Provider-neutrality makes it less immediately useful to the one operator who needs it.** *Mitigation*: the specifics are not lost, they are relocated to that project's `AGENTS.md`, which is already task 3.7 in the `infrastructure` repository's own change and loads automatically where the skill does not.
- **Written partly ahead of practice.** The motivating project has completed 1 of 59 tasks, so parts of this are theory. *Mitigation*: restrict claims to what is verifiable now; make no version-specific assertions; expect the trap list to grow by harvest once that project's module work completes. A skill written entirely from theory is the failure mode; a skill written from settled fundamentals and grown by harvest is not.
- **"What the model already knows" is a moving target**, so the weighting in Decision 6 rests on an assumption that ages. *Mitigation*: the traps were chosen for being counterintuitive rather than obscure, which is the property more likely to survive model improvements.
- **First domain asset sets a precedent** for the library accumulating subject-matter skills without a stated limit. *Mitigation*: named rather than avoided. No structural change is required to absorb it, tags make the domain visible, and the follow-on assets are already scoped and sequenced in the proposal rather than left open-ended.
- **Trigger competition with `github-actions` does not exist yet and cannot be tested yet.** *Mitigation*: `skill-authoring` already requires that adding an asset invalidates the recorded checks of every asset it competes with, so the obligation lands on that change when it arrives; this change records fixtures that make the later re-run meaningful.

## Open Questions

- Whether the "applies happen where the project says" section can stay a bare principle or needs one worked example to be usable. An example is the most likely vector for CI content to leak in, so it is deliberately left unresolved until Draft.
- Whether `hitl` carries the right meaning here. In `create-skill` and `create-agent` it marks a workflow that pauses for human approval at named checkpoints; here it marks a required human read of a plan. Close enough to reuse rather than coin a synonym, but worth confirming at Intent.
- How far the trap list should grow before the flat file stops being readable in one pass, and whether that is what eventually forces the Decision 3 split.
