## 1. Write `rules/development-workflow.md` version 3

- [x] 1.1 Bump the frontmatter to `version: 3`. Keep `kind: standing-constraint`.
- [x] 1.2 State the fragment's assumptions in its opening: a remote, a forge that reports a pull request's merged state, continuous integration, a deploy triggered by merging to the trunk, several concurrent sessions, and specification tooling. State no conditional for their absence, and no account of what another project shape would need — the brevity rules forbid it.
- [x] 1.3 Keep the existing sections unchanged except where a task below names them: spec-driven development and spec review, test design before implementation, implementation and execution, verification before any completion claim, independent review before completion, small reviewable commits, incremental development and scope control, requirements and assumptions, the repository is the source of truth.
- [x] 1.4 Add the session's branch and working tree: the scope exclusion for a tooling-created tree, a tree and branch of its own from the freshly fetched trunk, the invariant stated as the change's rather than the session's — one change, one branch, one working tree, kept from proposal to record, with sessions running one after another and never concurrently — `.claude/worktrees/`, the ignore entry, and scoping every recursive tool that does not read it.
- [x] 1.5 Add provisioning: tracked files only, the false pass, completeness as an end state, the shared-service namespace brought to the project's initial state, provisioning as a state to reach rather than an act performed, and checking for a service before declaring it absent.
- [x] 1.6 Add the namespace rule service-neutrally, with the reclamation gap named inline.
- [x] 1.7 Add the report: the fixed row and its cells, on entering and again before stopping, derived from the repository, with the verification cell composed against provisioning.
- [x] 1.8 Add the stage vocabulary: the transitions as the closed set, the derivation rule, four examples, the two states whose derivation reorders (`plan:tests-derived`, `ship:pr-open`) and the off-path names. Do not enumerate every derived state. State that the family prefix is always written.
- [x] 1.9 Add the two records that gate a decision: the review verdict and what was done about it, at the review sections; and the production-confirmation waiver, at the delivery sequence. Both to the change's own artifacts. No ledger, no stage-derivability apparatus.
- [x] 1.10 Add delivery: the code-review loop bounded at three; the work's pull request; merge and deploy confirmed by the operator; the production-confirmation gate and the obligation to propose how the effect is observed; the record through the last pull request, with two stated as a floor and a remedial cycle carrying its own; the exemption for a change with no externally observable effect and the recorded operator waiver it rests on; the unhealthy-deploy and absent-effect paths; and that the pipeline is the only path to production. State the archive step as a role with the specification tooling named beneath it, never in the role sentence. Name the outcomes that exit the review loop rather than consume a round, alongside its bound of three.
- [x] 1.11 State both terminals of the absent-effect path: a defect re-enters at the review gate, and the wrong change is the confirmation gate's second waivable class — observation made, effect absent, not to be corrected in place — waived and recorded like the first, the waiver naming a successor's queue entry or proposal branch where one is intended. State that a recorded waiver satisfies `ship:confirmed` for reporting.
- [x] 1.12 State the branch invariant as the change's, not the session's: one change, one branch, one working tree, kept from proposal to record; sessions on one change run one after another and never concurrently; the branch is brought back to the freshly fetched trunk after each merge and rebased onto it periodically in between.
- [x] 1.13 Add teardown: the observable gate, both routes, which clauses the abandonment record displaces, committing the record first, the execution context, and that the namespace is not covered. State that it covers the change's one branch, locally and on the remote; that the abandonment record displaces both merge conjuncts and the unpushed clause; that the clause names the record's own pull request as its own conjunct, so a merged work pull request does not pass the gate at `ship:merged` and an abandoned change that opened none does not pass it vacuously; and that the clause reads a pull request's merged state rather than branch ancestry, so a squash- or rebase-merging forge does not make every branch permanently unremovable.
- [x] 1.14 Add the change queue: one change per session, the dependent and independent paths, `docs/change-queue.md` and how it differs from `docs/deferred-work.md`, the proposal-only branch, and the seam with the scope rule already in the fragment.
- [x] 1.15 Do not add the four setup rules to the fragment; record them in `docs/change-queue.md` for the capability that owns project setup, and state in the fragment's own capability that a one-time obligation is recorded rather than added.
- [x] 1.16 Read both fragments for references that only resolve inside this library — no `rules/` path, no sibling fragment, no import. The rule binds the binding fragment as well as the workflow one, and v3's reference to the binding is conditioned on the project carrying it.

## 2. Write `rules/development-workflow-database.md`

- [x] 2.1 Create it with `kind: standing-constraint` and `version: 1`.
- [x] 2.2 State the affordance first: a real database runs in a container, integration tests run against it and not against a double or a lighter engine, and the running containers are checked before concluding it is unavailable.
- [x] 2.3 Then the binding: a database per working tree named from it, never the development database or another session's; the environment file a working tree does not inherit; migrating is not seeding; and reading a failing test's assertion message before calling a failure pre-existing.
- [x] 2.4 Confirm v3 refers to this fragment as an adjacent section of the same conventions file, never by a `rules/` path, so a project holding v3 alone can still learn a binding exists.
- [x] 2.5 Check it restates no obligation the workflow fragment already states — it names the service and the operations that reach the stated end state, and nothing else.

## 3. Remove the three session fragments

- [x] 3.1 Delete `rules/worktree-isolation.md`, `rules/change-delivery.md`, `rules/deferred-work.md`.
- [x] 3.2 Rewrite the two-path account of how a fragment reaches a project in both `rules/README.md` and `AGENTS.md`, which offers an `@` import or a shipped tool and covers neither route the database binding fragment takes — hand-pasted now, a second managed block after the tooling change.
- [x] 3.3 Grep the repository for references to all three and repair each — `docs/deferred-work.md`, `AGENTS.md`, `openspec/changes/add-namespace-reclamation/proposal.md`, any skill or agent naming them.

## 4. Seed this repository's own artifacts

- [x] 4.1 Keep this change's own `gate-log.md`, which carries its review rounds. The rules no longer mandate a ledger; the file is this change's record of its own verdicts, which the surviving requirement does oblige.
- [x] 4.2 Create `docs/change-queue.md`, stating what it holds, when an entry is deleted, and how it differs from `docs/deferred-work.md`.
- [x] 4.3 Add the entry for `add-session-workflow-tooling`, naming this change as the one that argued it.
- [x] 4.4 Add a cross-reference from `docs/deferred-work.md` to the new file, so a reader who reaches the wrong one is redirected.

## 5. Update the suite

- [x] 5.1 Dispatch `ai-toolkit:change-test-writer` against the committed, reviewed delta specs — test command `bash tests/run.sh`, test-path glob `tests/cases/**`. The exemption recorded in `tests/README.md` does not apply here.
- [x] 5.2 Confirm the manifest accounts for the cases this change implicates: `session-fragments-name-fixed-paths.sh`, `session-fragments-name-no-sibling.sh`, `session-fragment-frontmatter.sh`, `session-fragments-not-inlined.sh`, `deferred-work-states-workflow-seam.sh` and `change-delivery-names-no-working-tree.sh` all assert fragments this change deletes; `inlined-body-matches-fragment.sh`, `managed-block-current-version.sh` and `managed-block-older-version.sh` are coupled to the workflow fragment's version.
- [x] 5.3 Rewrite `tests/coverage.md`'s `session-workflow` section against this change's delta scenarios, and delete the rows for the cases the manifest marks obsolete.
- [x] 5.4 Apply the manifest's obsolete-test entries. Do not weaken or delete a case to reach green.

## 6. Verify

- [x] 6.1 `openspec validate consolidate-development-workflow --strict`.
- [x] 6.2 `bash tests/run.sh` — full suite green.
- [x] 6.3 Walk the stage vocabulary against the repository: for each stage, confirm something readable distinguishes it from its neighbours.
- [x] 6.4 Read v3 end to end as a project would see it — inlined, with no fragment files in sight — and check that no rule arrives after the point it applies.
- [x] 6.5 Confirm nothing in the repository still names a deleted fragment.
- [x] 6.6 Walk the new sections against the retargeted rule that a rule states an action and a defect appears only as its reason — each new rule's durable half is its instruction and its perishable half its consequence.
- [x] 6.7 Walk all nineteen stage names: confirm each is classified, that every persistent one has a named trace, and that the fragment claims no transient one is recoverable.
- [x] 6.8 Walk v3 against the four `project-bootstrap` requirements governing it — role before tool, the ordered sequence with checkable preconditions, the bounded dispatch loop with its exit outcomes, and the version increment — and record the result in this change's artifacts. Nothing else in this change checks the file that capability governs.

## 7. Review and deliver

- [x] 7.1 `/code-review` over the diff. Apply the findings; re-review only where the fixes were substantial. Bound at three.
- [ ] 7.2 Commit, push, open the pull request, and let CI run.
- [x] 7.3 Establish whether a delta can carry the `## Purpose` change. **It cannot, and it fails silently.** A `## Purpose` block added to a delta for a *modified* capability passes `openspec validate --strict` and is parsed into no delta operation — `openspec show --deltas-only` reports the same 18 requirement deltas with or without it. The artifact instructions say purpose belongs to new capabilities only; what the probe adds is that the non-carrying case is silent rather than rejected, so a change that tried it would archive with the purpose unchanged and nothing reporting why.
- [ ] 7.4 Make the `## Purpose` edit by hand in the archive commit, where the deltas are applied and no window of inconsistency opens. `openspec/specs/session-workflow/spec.md`'s purpose is false on three counts: it describes the capability as governing three separate fragments, it says `project-bootstrap` owns the inlined workflow fragment "which this capability does not touch", and it says the capability governs fragment content only. Then confirm the rewritten purpose is true of the archived capability.
