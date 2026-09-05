## Why

The library publishes its session obligations as three fragments — `worktree-isolation.md`, `change-delivery.md`, `deferred-work.md` — and they are in force in no project.

That is the delivery path, not neglect. `rules/` has no loader; the `@`-import path is machine-local and, being expanded eagerly at load, costs exactly what inlining costs while resolving only where this repository sits at one particular path. The one mechanism that puts a fragment into a project is `scripts/project-init`, which inlines a fragment's body into `AGENTS.md` under a managed block and reads one hardcoded path:

```
FRAGMENT="$TOOLKIT_ROOT/rules/development-workflow.md"
```

So the workflow fragment reaches projects and the session fragments do not. `commerce-ops` shows what follows: it re-derived the same obligations by hand, below the managed block — worktree provisioning, the `.env` a worktree does not inherit, the skipped tier that reports success, a database per worktree. The same rules, written twice, already disagreeing.

**Reading the two copies against each other turned up three defects in what the library currently says.**

*The delivery sequence is wrong for a project that deploys.* `change-delivery.md` places the archive commit last on the work branch, inside the pull request that carries the work. Where merging to the trunk triggers a deploy, that writes "this change shipped" at the moment the work was merely merged, and writes it identically where the deploy that followed failed.

*A change's stage is not derivable.* The rules require a session to report where its change stands, derived from the repository rather than from recalled conversation. But three gates leave no trace: dispatching a plan review, receiving its verdict, and receiving a code review's findings all end in the conversation. A session that dispatched a review and then ended is indistinguishable from one that never dispatched, so the next session either re-dispatches a review that already passed or proceeds on a verdict that never existed.

*Identified work is routed to the wrong file.* `deferred-work.md` directs an independently identified change to `docs/deferred-work.md`. That file exists in this repository and in `commerce-ops`, and in both it holds something else: what the project has deliberately **not** done, deleted when it stops being true. An identified change is deleted when it is archived. `commerce-ops` grew the second artifact separately rather than conflating them.

**And the separation itself is what costs the most.** `session-workflow` requires each of the three to be adoptable without the others, with every gate checkable inside the fragment stating it and no fragment naming a sibling. That property is bought with conditionals — *where the project has a remote*, *a project that runs sessions serially*, route-one-or-route-two teardown, a paragraph excluding throwaway checkouts, a clause reconciling two fragments that may not refer to each other — and it costs roughly 20 KB across three files that still cannot be adopted together without repeating themselves.

The expensive property was never universality. It was independence.

## What Changes

- **`rules/development-workflow.md` reaches version 3, absorbing the session obligations.** One document, inlined by the mechanism that already works. It states a session's branch and working tree, provisioning, the report of where a change stands, the stage vocabulary that report names, delivery through pull requests, teardown, and the recording of work that outlives the session — alongside the spec-driven gates it already carries.

- **The three session fragments are removed.** Their obligations survive in v3; their conditionals do not. Keeping them would mean every future rule change made twice, in texts that already disagree about where the archive commit goes.

- **A change's stage is named from a fixed vocabulary of three families**, and the report is derived from the repository where it can be. Nothing requires that every stage be derivable — see the design's decision 6, which withdrew that requirement along with the ledger built to satisfy it. `plan:` and `build:` each carry their own review and their own relation to tests — `plan:tests-derived` is tests being written from the delta specs, `build:verifying` is tests being run against the implementation. `ship:` is where a session waits, and is a family of its own because the only actionable content of a waiting state is which one it is.

- **One new record is required.** A production-confirmation waiver, written to the artifacts of a change whose confirmation gate is waived, because the record is archived on the strength of it. The abandonment record the teardown gate already obliges is the only other, and this change does not add it. An earlier draft mandated a ledger holding eight kinds of record so every stage would be exactly derivable; that precision buys nothing anyone depends on, and it went. A review's verdict went with it: the rules already require the approved plan to be committed before tests are derived from it, so the commit is the marker that a verdict cleared it, and a separate record states the same fact twice.

- **Delivery is at least two pull requests, unconditionally.** The work merges and deploys; the deploy is confirmed healthy; the change's intended effect is confirmed in production or the gate waived; then the record is archived through a pull request of its own. Two is a floor: a failed deploy, or a deployed change whose effect is absent through a defect in it, produces a fix that reaches the trunk the same way any work does — its own pull request, its own review, its own deploy — so the record's is the *last* of a change's pull requests rather than the second. A healthy deploy reports that new code is running and reports nothing about whether the change did what it existed to do, and those fail separately.

- **The production-confirmation gate carries two waivable classes, stated in advance.** A gate asking what to look at cannot be answered by a change with no externally observable effect — a refactor, a dependency bump — nor by one whose observation was made and whose effect turned out absent because the change was the wrong change. Neither is a defect to re-fix, and neither can use the abandonment route, whose record must assert that work is unwanted when this work is merged and running. So each is a named class the operator waives, the waiver is recorded, and the record proceeds on it. Without them a compliant session stalls holding a branch and a working tree that no route can remove — and a change can be archived as shipped with its effect confirmed absent, which the waiver is what records.

- **A change's working tree moves to `.worktrees/<name>`**, with `.claude/worktrees/` demoted to a Claude Code binding named beneath the rule. The published requirement fixes the harness's own path in the rule sentence, and `project-bootstrap` forbids exactly that in the file it governs — a role stated in one harness's terms is not portable. Every adopting project sees the path change, which is why it is named here rather than left to the delta.

- **The report of where a change stands is a fixed row, not a paragraph**, given on entering a working tree and again as the last thing said before stopping.

- **Identified work is routed to `docs/change-queue.md`**, distinct from `docs/deferred-work.md`, with each artifact's deletion condition stated.

- **An identified change opened on a branch carries a `handoff.md` and no proposal.** A proposal is the artifact the workflow reviews before anything is built, so one written in passing draws a review round it has not earned; and it is a formed document, which a session with no time for it either writes badly or does not write at all. The handoff states what the originating session learned and the next will not, and the session that takes the change up writes the proposal from it. This is a new artifact type in every adopting project, which is why it is named here and not only in the design.

- **Four rules found in the two projects already running this workflow are recorded rather than added.** Continuous integration failing rather than skipping, a hook not being an authority, secrets excluded by the ignore file, and the project stating its test command and glob are each one-time setup obligations a session never performs — and the last is already `project-foundation`'s. They go to `docs/change-queue.md`, and a requirement states that a setup obligation found while writing the fragment is recorded, not added.

- **One thing does not go into v3: the database.** `rules/development-workflow-database.md` binds v3's service-neutral provisioning and namespace obligations to a containerized Postgres — the running container, a database per working tree, migrate-is-not-seed, and that integration tests run against the real engine rather than a double. v3 states the obligation; the fragment states the binding, exactly as v3 already states a role and names its Claude Code binding beneath it.

- **v3 assumes a remote, pull requests, CI, and a deploy triggered by merging to the trunk, and states no conditional for their absence.** Every project this library is written for has all four. The forge is not named separately among them: pull requests imply it, and teardown's merge clause already states what it must report — a pull request's merged state, the only merge evidence that survives a squash or rebase merge. This repository does not deploy and is deliberately not a consumer of its own workflow fragment; should a library-shaped consumer need one, it gets a publication of its own rather than a conditional in this one. The conditionals removed here are the same ones that made the three fragments expensive.

- **The tooling that installs any of this is a separate change and follows.** `scripts/project-init` will gain a workflow-variant selection so the database fragment can be written as a second managed block. In the interval v3 reaches projects exactly as v2 does, and the database fragment is pasted by hand.

## Capabilities

### Modified Capabilities

- `session-workflow` — its subject changes from three independent fragments to the session content of one inlined workflow fragment plus one binding fragment. Most requirements survive with their subject retargeted and their independence conditionals dropped; the requirement fixing the set at three is removed, as is the one forbidding a version on a fragment nothing inlines. Nine requirements are ADDED. Four — teardown, delivery, the change queue and the one-branch invariant — are renamed replacements for REMOVED ones, replaced rather than modified because their existing scenarios encode properties this change drops, which a `MODIFIED` block cannot shed: the tooling refuses a modified requirement that omits a scenario the current spec still holds. Five are genuinely new: the publication shape, the stage vocabulary, the production-confirmation waiver, the rule that a one-time setup obligation does not belong in the fragment, and the database binding. Of the four MODIFIED requirements, two retarget their subject from the three fragments to the workflow fragment with their substance otherwise unchanged. Two gain substance: the report requirement adds the fixed row, the departure report and two cells; and the rule-phrasing requirement adds the brevity rules and the precedence clause. The one-branch requirement, which also gains substance — the invariant restated as the change's rather than the session's, the return to the trunk after each merge, the periodic rebase between — is among the replacements rather than the modifications, because it sheds a scenario too.

- `change-test-authoring` — the test-authoring artifact is renamed from `test-manifest.md` to `test-plan.md`, and the library's fragment naming it from `rules/test-manifest.md` to `rules/test-plan.md`. `test-plan` is the name the wider OpenSpec ecosystem uses for an artifact of this shape, so a project forking a schema that declares `id: test-plan` gets this artifact unchanged rather than renaming it at the moment that is least wanted. Six requirements are MODIFIED and the change is the filename alone: what the artifact is and what it must carry are untouched. "Manifest" remains the capability's generic noun for the artifact — five further requirements use it and take no delta, and two more take none because they never name the artifact at all — so only the name of the file changes, not the word the specification calls it by. All six are named because a partial rename leaves the capability contradicting itself about its own artifact.

- `change-review` — the four recommended actions are renamed to `APPROVED`, `CONDITIONALLY APPROVED`, `FIX REQUIRED` and `REJECTED`, from `PROCEED`, `PROCEED WITH CHANGES`, `CHANGES REQUIRED` and `REJECT`, for the same reason: these are the verdicts the ecosystem's review artifacts already carry. Four requirements are MODIFIED — the verdict set, the severity floor that cites a verdict by name, the artifacts-are-data requirement whose planted-instruction example quotes one, and the clean-review requirement whose scenario names the clean verdict.

Both renames also rename the agents that implement the two capabilities: `openspec-change-reviewer` becomes `change-plan-reviewer` and `openspec-test-writer` becomes `change-test-writer`. The `openspec-` prefix named the tool rather than the work, and it collided with the OpenSpec skills installed under `.claude/`; `change-plan-reviewer` also pairs with the `change-code-reviewer` the workflow fragment names, which distinguishes the two review gates the fragment states. The renames are cheap now and expensive once archived, which is why they ride with this change rather than waiting: every `.checks.yaml` fixture, test case and fragment binding that names one would otherwise be rewritten twice. `handoff.md` records the survey they came from, including what it proposed and this change declined.

The implementation gate still names the review verdict among its preconditions. What decision 6 removes is the separate record of it: `project-bootstrap`'s scenario "A stage boundary names an observable rather than a stage" enumerates the verdict, the commit holding the approved plan, and the tests derived from that plan, and all three survive — the commit is how a later session observes the verdict, rather than a record written alongside it.

`project-bootstrap` owns how the workflow fragment reaches a project — the managed block, the version, the ordered sequence and the dispatch bound. Those requirements hold over v3 unchanged, and the seam between the two capabilities is stated in this change's design rather than left to be inferred. The second managed block the database fragment needs belongs to the follow-up change.

## Impact

- `rules/development-workflow.md` — version 3.
- `rules/development-workflow-database.md` — new.
- `rules/worktree-isolation.md`, `rules/change-delivery.md`, `rules/deferred-work.md` — removed.
- `openspec/specs/session-workflow/spec.md` — substantially rewritten. Its `## Purpose` is false on three counts once the deltas apply — it describes the capability as governing three separate fragments, says `project-bootstrap` owns an inlined fragment "which this capability does not touch", and says the capability governs fragment content only. A delta cannot carry a `## Purpose` change for a modified capability and fails silently when it tries, so the rewrite is made by hand in the archive commit.
- `openspec/specs/change-test-authoring/spec.md`, `openspec/specs/change-review/spec.md` — the artifact and verdict renames.
- `agents/change-plan-reviewer.md`, `agents/change-test-writer.md` and their `.checks.yaml` fixtures — renamed from `openspec-change-reviewer` and `openspec-test-writer`, with the fixtures' planted verdict and manifest filename brought to the new vocabulary.
- `rules/test-plan.md` — renamed from `rules/test-manifest.md`.
- `docs/change-queue.md` — new here, seeded with the follow-up change, the two containment obligations the fragment does not carry, and the four setup rules.
- `AGENTS.md` and `rules/README.md` — their two-path account of how a fragment reaches a project (an `@` import, or a shipped tool reading it) stands unchanged. An earlier draft added a third path for the database binding fragment; `toolkit-structure` fixes the count at two, and the justification was independently false — the `@` import reaches a binding fragment like any other, so what the binding lacks until the tooling change is a *tool* route, not a route.
- `openspec/changes/add-namespace-reclamation/proposal.md` — an active change whose text names `rules/worktree-isolation.md`.
- `tests/coverage.md` — names all three fragments being removed.
- `docs/deferred-work.md` — gains a cross-reference to the change queue, and its two entries argued from `add-session-workflow-fragments` name a fragment this change deletes.
- No record is written here. The one this change obliges — a production-confirmation waiver — arises only at a gate this repository never reaches, since it does not deploy and is deliberately not a consumer of the workflow fragment (design decision 3).
- `tests/` — the cases asserting the three fragments' content, their frontmatter and their fixed paths, plus the inlined-body and version-coupled cases that now cover a changed fragment.
- No obligation in this change reaches outside the library's own files. The four that would have are queued for the capability that owns project setup.
- `commerce-ops` — first consumer. Adopting v3 means deleting its hand-written session rules and reconciling `docs/proposed-change-order.md` against `docs/change-queue.md`. That project's work, not this change's.
- `update-managed-block` (active, unstarted) — three projects hold the `v1` block and v3 widens the gap it exists to close. Not blocked by this change; made more valuable by it.

## Open questions

None blocking. Two things this change decides that are cheap to reverse before it is applied: the database fragment's filename, and `docs/change-queue.md` over adopting `commerce-ops`'s existing `docs/proposed-change-order.md`.

## Follow-up

`add-session-workflow-tooling` — `scripts/project-init` learns a workflow variant, writes the database fragment as a second managed block, and reports version skew per block. Recorded in `docs/change-queue.md` by this change.
