## 1. `rules/worktree-isolation.md`

- [x] 1.1 Create the fragment with frontmatter `kind: standing-constraint`
      and no `version:` key.
- [x] 1.2 Write the orientation rule: on entering a working tree, report the
      change's stage, its verification result and its committed state, each
      derived from the repository rather than from recalled conversation —
      and, except as the composition clause below provides, from a real run. State how this composes with 1.5, since the two rules do
      not compose on their own: stage and committed state are readable at
      once, but a verification result from an unprovisioned tree is the false
      green 1.5 exists to reject. Require the verification half to come from a
      run made after provisioning, or to be reported as not run and why —
      never from a run against an unprovisioned tree. 1.5 is what makes that
      route safe: it phrases provisioning as a state to reach, so reaching it
      here needs no finding about what an earlier session did.
- [x] 1.3 Scope the fragment's rules before stating them: they govern a
      working tree in which a session is doing a change's work. A tree whose
      lifetime is bounded by the single act of tooling that created it, and
      which carries no branch destined for the trunk, is outside them. The
      discriminator is the branch and the lifetime, not the contents — a tree
      made from a committed ref carries that commit's change artifacts, so
      "holds no change" would exclude nothing. Unscoped, the rules bind trees
      that can satisfy neither the one-tree rule nor either gate route —
      `agent-authoring` in this repository mandates exactly such a tree for a
      cold-run check, so the collision is present, not hypothetical.
      Then write the isolation rule: one session, one branch, one working
      tree, created from the trunk — freshly fetched from the remote *where
      the project has one* — at the named path `.claude/worktrees/<name>`.
      Condition the fetch: an unconditional one is a remote presupposition in
      the fragment's first rule, and makes it unsatisfiable at creation in a
      no-remote project. Name the path in the fragment — the containment
      rules in 1.4 are uncheckable against a path left to the project's
      choice.
- [x] 1.4 Write the containment rules for `.claude/worktrees/` — the root is
      named in the repository's ignore file, and every recursive tool that
      does not read that file is scoped explicitly. State the failure each
      prevents: a run that silently includes a sibling session's copy of the
      tree, and a forced clean that destroys every session's unmerged work.
- [x] 1.5 Write the provisioning rule. State **first** what a new working
      tree carries — tracked files only: no ignored configuration, no
      installed dependencies, no build artifacts, no share of any external
      state the verification touches. That premise is what makes the rule
      actionable; without it the fragment says "provision before relying on a
      result" and never says what is missing. Then the false pass as the
      stated reason, not convenience. Include that provisioning is complete when the
      end state of every step the project's conventions name holds, not when
      the first one does, and that a shared service is checked for before
      being declared absent. Include the
      end-state obligation, conditioned on the project having a shared
      service at all: provisioning brings the session's namespace in it to the
      project's known initial state whether or not one already exists under
      that name. Since a namespace outlives its working tree and this fragment
      states no release, a later working tree taking the same deterministic
      name would otherwise inherit what the previous one left. State an end
      state, not commands — what reaches it is the project's binding.
      State the rule's headline obligation directly, not only as the premise's
      justification: provisioning is a precondition of relying on any
      verification result.
      And phrase the **whole** rule as a state to reach, never as an act
      performed once — the completeness clause included, since that is the one
      most likely to come out as "every step has been performed". A session
      entering a tree it did not provision must be able to reach the state
      without establishing what an earlier session did; otherwise the
      composition clause 1.2 states has no safe route, and a session that
      cannot tell whether re-performing a step is destructive reports
      verification as not run every time, in exactly the resumed-tree case
      orientation exists for.
- [x] 1.6 Write the external-state rule: a session takes its own namespace in
      any shared service its verification writes to, named deterministically
      from its working tree, in whatever form the project's naming
      constraints require. State the obligation generally; prescribe no
      naming form and no service. Determinism is all this fragment needs —
      that which session holds which namespace is readable rather than
      guessed. The further properties a name needs to be safely *reclaimable*
      belong to `add-namespace-reclamation` and are not stated here.
- [x] 1.7 State the boundary in terms an adopting project can act on: this
      fragment does not direct reclaiming an allocated namespace, so a
      project that allocates needs a sweep of its own. Say it rather than
      leave the gap to read as an oversight — an unstated gap in a rule about
      isolation is indistinguishable from a rule that forgot.
      **Name no OpenSpec change and no ship status in the fragment body.** A
      change ID from this library's own process resolves to nothing in a
      consuming project, and "until X ships" is a currency claim in a fragment
      that carries no version precisely because nothing would maintain such a
      claim. Both belong in this repository's `docs/deferred-work.md`, where
      6.1 already puts them.
- [x] 1.8 Write the teardown gate as an observable — branch merged into the
      trunk, nothing uncommitted, and nothing unpushed *where the project has
      a remote* — covering the local branch, the remote branch where one
      exists, and the working tree. State from where that removal is
      performed — the tree the gate authorises removing is ordinarily the one
      the session is running in, and an act with no stated execution context
      gets resolved by the first implementer's guess. The gate governs a
      working tree in which a session is doing a change's work, per 1.3. A
      tree outside that scope is excluded from the gate; do not assert that
      something else removes it, since nothing in this repository obliges
      anyone to.
      Teardown does not cover the shared-service namespace: stating half a reclamation rule here would leave one whose
      safety depends on clauses this fragment does not carry.
      Give the gate two routes, not one — a merge, or an abandonment the
      operator recorded — because with a merge as the only route an abandoned
      change's branch and working tree are permanently unremovable, which is
      the accumulation the gate exists to prevent. Make the second route as
      observable as the first: name where the record lives — the abandoned
      change's own artifacts — and what it must say. The parallel with how the
      deferred-work fragment places a blocking dependency is this task's
      reason, not fragment text: the fragment states the location alone and
      names no sibling. The record must say (the change is abandoned; the
      work on its branch is not wanted). And state what it displaces — the
      merge clause and, where there is a remote, the unpushed clause, both
      being commits the record covers; **not** the uncommitted clause, which
      the decision never mentioned. Unstated, the narrow reading blocks a
      never-pushed abandoned branch and the broad one discards uncommitted
      work on a decision that did not authorise it.
      State that the record is committed on the abandoned branch before the
      gate is read. Written and left uncommitted it trips the one clause it
      does not displace, so the act authorising teardown blocks it — and the
      stated remedy of extending the decision would discard the record the
      route rests on. Every remote clause is
      conditioned; an unconditional one makes the gate unsatisfiable in a
      project with no remote, which is one of the shapes this fragment is
      meant to serve.
- [x] 1.9 Read the finished fragment for sibling dependence: no sentence may
      name another session-scoped fragment or require one to be present.
      Where shared context is needed, restate it here rather than referring
      outward.

## 2. `rules/change-delivery.md`

- [x] 2.1 Create the fragment with frontmatter `kind: standing-constraint`
      and no `version:` key.
- [x] 2.2 Write the entry gate first: delivery begins only where the change's
      verification has run and passed against the branch head. The fragment
      is adoptable alone, so a sequence opening with the archive commit and
      no precondition sanctions delivering work nothing verified.
- [x] 2.3 Write the delivery sequence: archive the change's record as the
      last commit on the branch, push, open the pull request, let
      verification run. Name OpenSpec directly — the proposal's decision 2.
- [x] 2.4 State why the archive commit precedes the merge rather than
      following it: the record is reviewed by the pull request that reviews
      the work, instead of reaching the trunk outside any review.
- [x] 2.5 Write the confirmation rule: the operator confirms the merge, the
      session never infers it, and nothing is treated as delivered before
      that confirmation.
- [x] 2.6 State the fragment's adoption preconditions in the fragment itself:
      a remote, and — because 2.3 names OpenSpec directly rather than stating
      a role with the tool bound beneath — OpenSpec. Recording the narrowing
      only in this change's artifacts is what the delta forbids: those are
      archived, and a project with a remote and different specification
      tooling would then meet it at the archive step.
- [x] 2.7 Verify the fragment names no working tree and no branch-per-session
      obligation, so it is satisfiable in a project that has not adopted
      `worktree-isolation.md`.

## 3. `rules/deferred-work.md`

- [x] 3.1 Create the fragment with frontmatter `kind: standing-constraint`
      and no `version:` key.
- [x] 3.2 Write the one-change-per-session rule. State the reason as the
      observable one — two changes in flight in one session leaves it unclear
      which artifact and which commit belong to which change — rather than
      asserting a consequence about session capacity that no recorded
      incident in this change's evidence supports.
- [x] 3.3 Write the blocking-dependency path — record the dependency and the
      wait in the current change's artifacts *first*; then optionally a
      proposal-only branch and a recommendation to continue in a separate
      session. Make explicit that recording is the obligation and branching
      is the option.
- [x] 3.4 Write the independent-work path: a proposal-only branch, or an
      entry in the project's deferred-work file at the named path
      `docs/deferred-work.md`. State that the file is created where the
      project has none — an option that silently reduces to no option in a
      project lacking a file the fragment never told it to create is not an
      option.
- [x] 3.5 State the seam against `rules/development-workflow.md`, which a
      bootstrapped project carries inlined and which obliges out-of-scope work
      noticed during a change to become a separate proposed change rather
      than being folded in. State it against that **obligation**, not against
      a quoted sentence: that fragment is versioned and expected to change,
      and a seam pinned to its present wording is falsified by a reword that
      leaves the obligation intact. The seam is that a deferred-work entry
      *is* that separate proposed change,
      recorded rather than opened, and both rules share the obligation that
      the work leaves the change in progress. Without this, such a project
      holds two standing constraints on one act, one permitting what the
      other requires. This is the one reference outside the session-scoped
      set, and it is permitted because `development-workflow.md` is not a
      session-scoped fragment.
- [x] 3.6 State what becomes of a proposal-only branch on either path: it is
      created and left — no working tree of its own, and it does not become
      the session's working branch. Neither fragment may name the other, so a
      project that also keeps one branch and one working tree per session
      cannot reconcile this by cross-reference; stating it here is the only
      route open, and without it a session reads a permitted route as one its
      other rules forbid.
- [x] 3.7 State the reason the deferred-work file exists outside any change:
      a deferral recorded only inside a change stops being findable when the
      change is archived, so it is the change succeeding — not the session
      ending — that loses it.

## 4. Cross-fragment checks

- [x] 4.1 Check every rule in all three fragments against the phrasing
      standard: the instruction is the durable half, any defect appears only
      as the reason an instruction matters, and no rule consists of an
      incident alone.
      Check the converse too, which is the half most easily lost: no rule was
      *dropped* because the defect motivating it is being fixed, where the
      instruction survives the fix. `commerce-ops` nearly lost its
      `_test`-suffix rule that way — the change expected to obsolete it in
      fact enforced it harder, and only the consequence had gone stale.
- [x] 4.2 Confirm no session-scoped fragment names another session-scoped
      fragment, and no fragment's gate is expressed as another fragment's
      step having completed. Task 3.5's reference to
      `rules/development-workflow.md` is outside that set and is the one
      permitted reference; confirm it is the only one.
- [x] 4.3 Confirm each fragment carries `kind: standing-constraint` and no
      `version:`.
- [x] 4.4 Confirm the flat layout: all three sit directly under `rules/`,
      with no grouping subdirectory.
- [x] 4.5 Confirm every clause presupposing a remote is conditioned on the
      project having one, in `worktree-isolation.md` — the fetch at 1.3 and
      the gate at 1.8, which are where the delta states remote-conditioning
      obligations, and not only the gate.
      `change-delivery.md` is excluded deliberately: a remote is its
      applicability axis, so its push and pull-request clauses presuppose one
      by design and are not hedged.
- [x] 4.6 Confirm no fragment directs releasing, deleting or dropping a
      shared-service namespace at all. Scope the check by the *act*, not by
      timing: a release clause written into the teardown rule while the
      working tree still exists passes a timing-scoped check and is exactly
      the half-stated release rule this guard exists to catch. Bringing the
      session's own namespace to the project's known initial state during
      provisioning is required by 1.5 and is not a release. Reclamation is `add-namespace-reclamation`'s
      subject; a half-stated release rule arriving here by habit is the one
      way this split fails. Six review rounds on that rule are the reason to
      check this by reading rather than assume it.

- [x] 4.7 Confirm provisioning is stated as a state to reach throughout
      `worktree-isolation.md` — the completeness clause included — and that
      the fragment scopes its rules to a working tree in which a session is
      doing a change's work, per 1.3. Both were added late and each has already reached the delta
      once without reaching the fragment's own text.
## 5. Tests

- [x] 5.1 Dispatch `ai-toolkit:openspec-test-writer` against this change
      once the review verdict permits proceeding and the approved plan is
      committed. Test authoring is not exempt here: the delta states
      properties of three files a shell case can check by reading them.
      Supply the change name, its `changeRoot`, the resolved artifact
      paths, the absolute `.openspec.yaml` path, `AGENTS.md` and
      `CLAUDE.md`, the test command `bash tests/run.sh`, and the test-path
      glob `tests/cases/**`.
- [x] 5.2 Run `bash tests/run.sh` and confirm the pre-existing suite is
      unaffected — this change touches no executable, so any movement there
      is a defect in the change.

## 6. Deferred work, recorded where archiving cannot hide it

- [x] 6.1 Create `docs/deferred-work.md` in this repository — it has none —
      and record there, **before this change is archived**, that
      `worktree-isolation.md` ships allocating a shared-service namespace and
      not releasing it, that `add-namespace-reclamation` owns the release,
      and that until it ships an adopting project accumulates namespaces and
      needs a manual sweep. Record a second entry beside it: excluding a
      tooling-created working tree from these rules leaves a class of working
      tree that no capability in this repository obliges anyone to remove —
      `agent-authoring` mandates a cold-run worktree and states no removal —
      so the accumulation this fragment exists to prevent is displaced onto a
      class it now excludes rather than solved for it.
      The destination is the point, not a formality: a deferral left in this
      `tasks.md` moves to `openspec/changes/archive/` when this change ships
      and stops being findable — the exact failure the fragment being written
      here legislates against, and a change that recorded its own deferral
      the way its own rule forbids would be evidence against the rule. The
      entry names the change that argued it rather than repeating the
      argument.
