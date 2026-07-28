## 1. Intent Checkpoint

- [ ] 1.1 Confirm the routing gate: the work is on-demand procedural knowledge belonging in the caller's context, so a skill rather than a rule fragment, a command, or an agent (design Decision 1). Recommending a different artifact and stopping remains a valid outcome.
- [ ] 1.2 Confirm the name `terraform` is free by listing `skills/` in this repository, and that it leaves `github-actions` available for the follow-on asset.
- [ ] 1.3 List the `metadata.tags` in use across `skills/` and `agents/`, and confirm `infrastructure` and `terraform` are genuinely new rather than synonyms of an existing label.
- [ ] 1.4 Settle the open question on `hitl`: confirm it reads correctly for a required human read of a plan, given it currently marks workflows that pause at named approval checkpoints. Reuse it or state why a new tag is warranted — do not coin a synonym.
- [ ] 1.5 Confirm the skill's purpose in one or two sentences.
- [ ] 1.6 Confirm the triggering conditions — the phrasings a user would plausibly type — and agree them here, before any description is drafted from them.
- [ ] 1.7 Confirm the target is this repository's own `skills/`, not the `infrastructure` project this skill is written for.

## 2. Shape and Draft Checkpoints

- [ ] 2.1 Record that the Shape checkpoint is skipped, and why: the skill is a single flat file wrapping no external command, which is the case the standard permits skipping for (design Decisions 3 and 7).
- [ ] 2.2 Draft the frontmatter — `name`, `description`, `metadata.tags` — with no `allowed-tools` (design Decision 7). Verify the description is third person, names adjacent trigger phrasings drawn from task 1.6, and disambiguates against every asset in the library *and* the OpenSpec assets committed under `.claude/`.
- [ ] 2.3 Verify the drafted description is at most 1024 characters and contains no angle brackets.
- [ ] 2.4 Draft the body outline as section headers only. Confirm it covers every requirement in the `terraform-practice` spec — including the Terraform-side content the *CI Pipeline Shape Is Out of Scope* requirement assigns to this skill, not only the two-halves requirement.
- [ ] 2.5 Resolve the open question on the "applies happen where the project says" section: decide whether it stays a bare principle or carries one worked example, treating an example as the most likely vector for CI content to leak in.
- [ ] 2.6 Present frontmatter and outline for approval. Write no file before this is approved; apply revisions to the draft and re-present rather than writing and editing.

## 3. Write the Skill

- [ ] 3.1 Create `skills/terraform/SKILL.md` as a single flat file — no `references/`, `scripts/`, or `assets/` (design Decisions 3 and 7).
- [ ] 3.2 Write the deference section: the skill is a floor that a consuming project's `AGENTS.md`, `CLAUDE.md`, and design documents override on conflict; those are read first in an unfamiliar repository; a conflict is reported rather than silently resolved; and where a project records no convention at all, the answer is named as project- or provider-specific and asked about rather than supplied from assumption.
- [ ] 3.3 Write the authoring half: module and environment boundaries, the file split within a module, variable design, and `variable validation` as a plan-time guardrail.
- [ ] 3.4 Write the traps section covering, at minimum, all four behaviours enumerated in the `terraform-practice` spec: `prevent_destroy` accepting only literals; `count` index shifts versus `for_each`; a version constraint without a committed lock file not being pinning; `sensitive` not keeping values out of state.
- [ ] 3.5 Write the state-and-secrets section: state holds values in cleartext regardless of `sensitive`, and what that implies for backends, plan artifacts, and what may be committed.
- [ ] 3.6 Write the plan-checkpoint section requiring the diff be read and its blast radius stated, with replacement called out as destruction followed by creation, and apply never presented as automatically following plan. State the confirmation rule the spec sets: a plan containing any replace or destroy requires explicit user confirmation before the apply runs, and stating the blast radius while continuing in the same turn does not satisfy it. State the condition on the permissive branch too — a create/update-only plan may proceed unconfirmed only where the apply consumes that saved plan; where the apply re-plans, the classification is stale and confirmation is required regardless.
- [ ] 3.7 Write the approval-binding section: `plan -out` produces the artifact an apply consumes, so an approval binds the exact diff that was read, whereas re-planning at apply time does not. This is the Terraform-side content the *CI Pipeline Shape Is Out of Scope* requirement assigns to this skill — keep it a property of the plan artifact and do not let it acquire job structure or approval mechanisms.
- [ ] 3.8 Write the run-location principle: where a project gates applies behind a pipeline, never apply outside it — stated as a principle, with the pipeline's shape deferred to the project, per the resolution of task 2.5.
- [ ] 3.9 Write the state-operations section treating `import`, `state mv`, and `state rm` as surgery, and prohibiting `-lock=false` on anything that writes. Cover state locking as a constraint on concurrent runs — the third element the *CI Pipeline Shape Is Out of Scope* requirement assigns to this skill — not only as a flag not to pass.
- [ ] 3.10 Write the drift section distinguishing provider-generated noise from a real out-of-band change, and stating when `ignore_changes` is honest rather than concealment.
- [ ] 3.11 Write the closing scope section naming what the skill does not decide: provider, backend, module sourcing, and CI pipeline shape.
- [ ] 3.12 Review the whole body against design Decision 6 and remove tutorial content that a competent model supplies unprompted, so it does not displace the traps.

## 4. Post-Write Validation

- [ ] 4.1 Confirm the frontmatter parses as valid YAML.
- [ ] 4.2 Confirm `name` matches the directory name exactly.
- [ ] 4.3 Confirm the file sits at `skills/terraform/SKILL.md` with no directory between `skills/` and the skill's own directory.
- [ ] 4.4 Confirm every declared tag is lowercase kebab-case.
- [ ] 4.5 Confirm the description states both the action and the triggering conditions.
- [ ] 4.6 Confirm no bundled resource is referenced that does not exist.
- [ ] 4.7 Check the body against each requirement in the `terraform-practice` spec, and confirm no provider-specific resource type, credential model, console workflow, or single project's backend, region, sizing, or naming choice has been encoded.

## 5. Trigger Check

- [ ] 5.1 Assemble the evaluator payload: the `name` and `description` of every skill in `skills/*/SKILL.md`, every agent in `agents/*.md`, and every OpenSpec asset committed under `.claude/skills/*/SKILL.md` and `.claude/commands/**/*.md`. Derive these by globbing rather than from a fixed list.
- [ ] 5.2 Run the positive prompt against a fresh-context evaluator holding only that payload, and confirm it routes to `terraform`.
- [ ] 5.3 Run the negative prompt — chosen so it could plausibly misfire, not an unrelated prompt — and confirm it does not route to `terraform`.
- [ ] 5.4 Report both outcomes. Widen the description and re-run on a positive failure; narrow it and re-run on a negative failure. The skill is not complete until both hold against a single, final description.
- [ ] 5.5 Record the fixtures in a `## Trigger check fixtures` section of `SKILL.md`: both prompts and the routing expected of each, naming the asset the negative should reach where one should. Record no outcome and no run date.

## 6. Invalidation of Competing Checks

- [ ] 6.1 Determine which existing assets the new skill competes with for the same prompts — `create-skill`, `create-agent`, and `openspec-change-reviewer` — by checking whether any of their recorded fixtures could now route differently.
- [ ] 6.2 Re-run the recorded fixtures of every asset identified in 6.1 against the evaluator composition from task 5.1. Run this only once task 5.4 holds on both prompts, so the payload contains the final description rather than one that is later revised.
- [ ] 6.3 Update any fixture whose expected routing the new skill changes, in this change rather than a later one. A recorded negative asserting "activates nothing" is the form most likely to have been silently falsified.

## 7. Close Out

- [ ] 7.1 Confirm no catalogue, index, or README edit is owed, per the "adding an asset requires no catalogue update" requirement in `toolkit-structure`.
- [ ] 7.2 Run `openspec validate add-terraform-skill` and confirm it passes.
- [ ] 7.3 Record in this change any trap or convention discovered during authoring that is worth harvesting into the skill later, so the design's "written partly ahead of practice" risk has a landing place.
