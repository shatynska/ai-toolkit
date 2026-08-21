## 1. Intent Checkpoint

- [x] 1.1 Confirm the routing gate: this is on-demand, design-oriented procedural knowledge belonging in the caller's context, so a skill rather than a rule fragment, a command, or an agent. Recommending a different artifact and stopping remains a valid outcome.
- [x] 1.2 Confirm the name `ddd` is free by listing `skills/` in this repository. Consider whether `ddd` or a longer form (e.g. `domain-driven-design`) reads better as an invocation name against the trigger phrasings gathered in 1.5, and settle on one.
- [x] 1.3 List the `metadata.tags` in use across `skills/` and `agents/` (`ansible`, `authoring`, `bash`, `hitl`, `infrastructure`, `langgraph`, `n8n`, `openspec`, `project-lifecycle`, `python`, `review`, `terraform`, `testing`). Confirm `python` is reused rather than duplicated, and settle new tags for the domain-modeling and TypeScript territory this skill newly covers (proposal.md names `ddd`, `architecture`, `typescript` as candidates) — with a stated reason for each new one.
- [x] 1.4 Confirm the skill's purpose in one or two sentences, matching the design-oriented (not primarily review-oriented) framing settled during exploration.
- [x] 1.5 Confirm the triggering conditions — the phrasings a user would plausibly type — covering both design-shaped prompts ("help me model this aggregate") and the review-shaped prompts the design.md Risks section flags as a possible under-triggering gap ("review this domain model for DDD violations"). Agree them here, before any description is drafted from them.
- [x] 1.6 Confirm the target is this repository's own `skills/`.

## 2. Shape Checkpoint

- [x] 2.1 Confirm the Shape checkpoint applies (not skipped): the skill needs bundled `references/typescript.md` and `references/python.md`, per design's reference-splitting decision. Confirm no `scripts/` or `assets/` are needed and no single external command is wrapped (so no `allowed-tools` scoping applies).

## 3. Draft Checkpoint

- [x] 3.1 Draft `SKILL.md` frontmatter — `name`, `description`, `metadata.tags` from 1.2/1.3, no `allowed-tools`. Verify the description is third person, names adjacent trigger phrasings from task 1.5 (both design- and review-shaped), and disambiguates against every asset in the library *and* the OpenSpec assets committed under `.claude/`.
- [x] 3.2 Verify the drafted description is at most 1024 characters and contains no angle brackets.
- [x] 3.3 Draft the `SKILL.md` body outline as section headers only, in decision-point order, and confirm it covers every requirement in the `ddd-practice` spec:
  - Whether to apply tactical DDD at all (leads the list)
  - Entity vs. Value Object
  - Always-valid object construction
  - Aggregate sizing
  - Domain Service vs. Application Service vs. Entity method
  - Domain Events (and naming sagas/process managers as the escalation path when events multiply, per design's Non-Goals)
  - Repository paired with Unit of Work
  - Dependency direction (layered rule and inter-module rule, stated as two rules)
  - Public-API-per-module (as the inter-module rule's enforcement mechanism)
  - Recognizing a strategic leak disguised as a tactical problem
  - Testing pointer (DDD-specific angle, deferring the rest to `testing`)
- [x] 3.4 Draft the outline for `references/typescript.md`: structural typing defeating ID distinctness (branded/opaque types), a lint-enforced module boundary, ORM-decorator leakage onto domain classes.
- [x] 3.5 Draft the outline for `references/python.md`: runtime-only invariant enforcement (validators), import-linter-style enforcement of dependency direction, the Active Record tension in Django/SQLAlchemy-style ORMs.
- [x] 3.6 Present frontmatter and both outlines for approval. Write no file before this is approved; apply revisions to the draft and re-present rather than writing and editing.

## 4. Write the Skill

- [x] 4.1 Create `skills/ddd/SKILL.md` following the approved outline. Organize by decision point per the `ddd-practice` spec's *Guidance Is Organized By Decision, Not By Trap List* requirement — no standalone traps section; each known pitfall recorded inline against the decision it belongs to.
- [x] 4.2 Write the opening decision: whether a subdomain warrants tactical DDD at all, directing effort toward the core domain and explicitly permitting skipping entities/aggregates/repositories for CRUD-shaped work.
- [x] 4.3 Write Entity vs. Value Object and Always-valid object construction as two distinct decision points (design: kept separate rather than folded together), citing the private-constructor-plus-factory pattern and noting the shallow-immutability pitfall inline.
- [x] 4.4 Write Aggregate sizing around true invariants rather than object-graph convenience, and cross-aggregate references by identity rather than object reference.
- [x] 4.5 Write Domain Service vs. Application Service vs. Entity method as a decision point (where does this behavior actually belong).
- [x] 4.6 Write Domain Events for cross-aggregate decoupling, distinguishing it from using events as a transaction-boundary escape hatch, and naming sagas/process managers as the next step when the events multiply (without teaching them).
- [x] 4.7 Write Repository paired with Unit of Work: one repository per aggregate root, and Unit of Work as what makes multi-repository operations atomic.
- [x] 4.8 Write Dependency direction as two explicit rules per the spec: the layered rule (repository interface owned by domain/application, implementation in infrastructure) and the inter-module rule, without conflating them.
- [x] 4.9 Write Public-API-per-module immediately connected to the inter-module rule from 4.8, naming it as that rule's concrete enforcement mechanism.
- [x] 4.10 Write the strategic-leak-recognition section: what tactical symptoms (cross-module internal imports, a dependency pointing the wrong way) indicate a bounded-context boundary problem, and that the skill proposes a boundary fix rather than a local workaround — without walking through context-mapping or subdomain-classification as exercises.
- [x] 4.11 Write the testing pointer section: aggregate/value-object invariants tested with no I/O, distinct from testing through a repository port, deferring general testing discipline to the `testing` skill.
- [x] 4.12 Create `skills/ddd/references/typescript.md` per the approved outline, naming a lint-enforced module boundary (not a convention-only one) per the spec's requirement.
- [x] 4.13 Create `skills/ddd/references/python.md` per the approved outline, naming import-linter-style enforcement (not a convention-only one) per the spec's requirement.
- [x] 4.14 Review `SKILL.md` end to end against the loading-budget guidance (~5000 words) and against design's Risk on body length; if it runs long, trim inline pitfall notes before cutting a decision point.

## 5. Post-Write Validation

- [x] 5.1 Confirm `SKILL.md` frontmatter parses as valid YAML.
- [x] 5.2 Confirm `name` matches the directory name exactly.
- [x] 5.3 Confirm the file sits at `skills/ddd/SKILL.md` with no directory between `skills/` and the skill's own directory, and both reference files exist at `skills/ddd/references/`.
- [x] 5.4 Confirm every declared tag is lowercase kebab-case.
- [x] 5.5 Confirm the description states both the action and the triggering conditions, covering both design- and review-shaped phrasings.
- [x] 5.6 Confirm every bundled resource `SKILL.md` references (both reference files) actually exists, and confirm neither reference file restates the language-agnostic decision content instead of naming ecosystem-specific traps and mechanisms.
- [x] 5.7 Check the body against each requirement in the `ddd-practice` spec, in particular that no standalone traps section exists and that both dependency-direction rules and the always-valid-objects decision point are present.

## 6. Trigger Check

- [x] 6.1 Assemble the evaluator payload: the `name` and `description` of every skill in `skills/*/SKILL.md`, every agent in `agents/*.md`, and every OpenSpec asset committed under `.claude/skills/*/SKILL.md` and `.claude/commands/**/*.md`. Derive these by globbing rather than from a fixed list.
- [x] 6.2 Run the positive prompt (design-shaped, e.g. modeling an aggregate) against a fresh-context evaluator holding only that payload, and confirm it routes to `ddd`.
- [x] 6.3 Run a second positive prompt (review-shaped, e.g. reviewing an existing domain model for DDD violations) and confirm it also routes to `ddd`, addressing the under-triggering risk named in design.md.
- [x] 6.4 Run the negative prompt — chosen so it could plausibly misfire (e.g. a general architecture question with no DDD vocabulary, or a `python`/`terraform`-shaped prompt) — and confirm it does not route to `ddd`.
- [x] 6.5 Report all outcomes. Widen the description and re-run on a positive failure; narrow it and re-run on a negative failure. The skill is not complete until all hold against a single, final description.

  Outcome: all three prompts routed correctly on the first run against a fresh-context evaluator holding the full asset roster (13 skills, 2 agents, 6 `.claude/` OpenSpec assets) — design-shaped positive → `ddd`, review-shaped positive → `ddd`, Python-shaped negative → `python`. No description revision was needed.
- [x] 6.6 Record the fixtures in a `## Trigger check fixtures` section of `SKILL.md`: the prompts and the routing expected of each, naming the asset the negative should reach where one should. Record no outcome and no run date.

## 7. Invalidation of Competing Checks

- [x] 7.1 Determine which existing assets the new skill competes with for the same prompts — at minimum `python` (shared TypeScript/Python territory and the `python` tag reuse) and `create-skill`/`create-agent` (any "help me design/build X" phrasing) — by checking whether any of their recorded fixtures could now route differently.

  Identified: `python` (3 fixtures), `create-skill` (2), `create-agent` (2), and `project-foundation` (2, added since its "architecture" territory is adjacent to `ddd`'s own "architecture" tag and its description explicitly disambiguates against `project-foundation`).
- [x] 7.2 Re-run the recorded fixtures of every asset identified in 7.1 against the evaluator composition from task 6.1. Run this only once task 6.5 holds, so the payload contains the final description rather than one that is later revised.

  Checked each fixture's prompt text directly against `ddd`'s final description rather than assuming: `python`'s positive (a default-argument bug in a Python function), its negative (a LangGraph agent request), and its testing-coverage positive (a pytest fixture scoping question) all carry no domain-modeling vocabulary (entity, aggregate, value object, bounded context) and stay with their recorded routing. `create-skill`'s and `create-agent`'s fixtures concern authoring library assets (a commit-message skill, a security-review subagent), squarely excluded by `ddd`'s own "not for authoring this library's assets" clause. `project-foundation`'s positive concerns a whole project's identity/scope/tech-stack, not domain modeling inside code, and its negative concerns `project-init`'s deterministic setup — neither overlaps `ddd`'s territory.
- [x] 7.3 Update any fixture whose expected routing the new skill changes, in this change rather than a later one.

  Outcome: no fixture of any of the four assets checked was falsified by `ddd`'s addition; none required updating.

## 8. Reconcile `testing`'s Pointer-Completeness Requirement

- [x] 8.1 Add `ddd` to `skills/testing/SKILL.md`'s existing pointer list (alongside `python`, `langgraph`, `bash`, `terraform`, `ansible`), naming the DDD-specific testing angle from task 4.11 (aggregate/value-object invariants tested with no I/O) — satisfying `testing-practice`'s standing requirement that the pointer section name every domain skill covering a testable artifact, "whether or not it presently carries testing material."

  Added as its own short paragraph after the existing five-skill list rather than folded into it: the list's lead-in sentence ("each is verified against its own tool's version") is true of the five runner/framework skills and would misdescribe `ddd`, which carries no version-dated claim. The new paragraph states why `ddd` is named for a different reason (the standing pointer-completeness requirement) rather than because it fits the "load the matching runner" pattern.
- [x] 8.2 Decide whether `ddd` also becomes an explicit co-trigger in `testing`'s own description (the `terraform`/`python` pattern) or stays list-only in the body (the `ansible` pattern), per design.md's note that this is a drafting-time judgment call rather than one resolved in planning.

  Resolved empirically, not by guessing: ran a fresh-context evaluator (same roster as task 6.1) against "How do I test that my Order aggregate's invariants hold, without hitting the database?" without any change to `testing`'s description. Result: it already routes to `ddd` **and** `testing` together, because `ddd` is the entry point (its domain-specific vocabulary matches first) and `ddd`'s own description clause ("Composes with testing for DDD-specific testing questions") is what pulls `testing` in — the reverse direction from the `python`/`terraform` pattern, where `testing` is the entry point naming the language skill. Decision: `ddd` stays list-only in `testing`'s body (task 8.1) and is **not** added to `testing`'s description — co-triggering already works via `ddd`'s own description, and adding it to `testing`'s "load the matching runner" sentence would misrepresent the relationship as running the same direction as the four skills already named there.
- [x] 8.3 If 8.2 changes `testing`'s description, treat it as a description edit under `skill-authoring`'s invalidation rule: re-run `testing`'s own recorded trigger-check fixtures (not just `ddd`'s) against the evaluator composition from task 6.1, and update `testing/SKILL.md`'s `## Trigger check fixtures` section if any outcome changes.

  Not applicable: 8.2 concluded with no edit to `testing`'s description (only its body), so `skill-authoring`'s description-edit invalidation rule isn't triggered and `testing`'s existing recorded fixtures stand unchanged.
- [x] 8.4 Add a fixture to `testing/SKILL.md`'s `## Trigger check fixtures` section analogous to its existing `terraform`/`ansible` contrast pair, recording whether a DDD-testing-shaped prompt (e.g. "how do I test my aggregate's invariants without hitting the database") co-triggers `ddd` or routes to `testing` alone — per whatever 8.2 settles.

  Added as "Positive, authoring (ddd) — reversed entry point", recording the co-trigger outcome from 8.2 and explaining why it's structurally different from both the `python`/`terraform` pattern and the `ansible` exclusion.

## 9. Close Out

- [x] 9.1 Confirm no catalogue, index, or README edit is owed, per the "adding an asset requires no catalogue update" requirement in `toolkit-structure`. Confirmed: `README.md` documents browsing via `head -n 5 skills/*/SKILL.md` rather than enumerating skills by name, so nothing there references specific skills that would need updating.
- [x] 9.2 Run `openspec validate add-ddd-skill` and confirm it passes. Confirmed passing.
